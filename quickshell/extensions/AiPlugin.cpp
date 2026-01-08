#include "AiPlugin.h"
#include <iostream>
#include <QRegularExpression>
#include <QVariantList>
#include <QDebug>
#include <QFile>
#include <QFileInfo>
#include <QDir>
#include <QTextStream>
#include <yaml-cpp/yaml.h>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QNetworkRequest>

int approximateTokenCount(const QString &text) {
    if (text.isEmpty()) return 0;
    // Heuristic: 4 characters per token
    return (text.length() + 3) / 4; 
}

AiPlugin::AiPlugin(QObject *parent) : QObject(parent)
{
    m_manager = new QNetworkAccessManager(this);
}

QString AiPlugin::generateText(const QString &prompt)
{
    return "AI Response to: " + prompt;
}

// Helper: Convert YAML node to QVariant
QVariant yamlToVariant(const YAML::Node& node) {
    if (node.IsScalar()) {
        std::string str = node.as<std::string>();
        QString qStr = QString::fromStdString(str);
        if (qStr.compare("true", Qt::CaseInsensitive) == 0) return true;
        if (qStr.compare("false", Qt::CaseInsensitive) == 0) return false;
        bool ok;
        qlonglong lVal = qStr.toLongLong(&ok);
        if (ok) return lVal;
        double dVal = qStr.toDouble(&ok);
        if (ok) return dVal;
        return qStr;
    }
    if (node.IsSequence()) {
        QVariantList list;
        for (const auto& child : node) list.append(yamlToVariant(child));
        return list;
    }
    if (node.IsMap()) {
        QVariantMap map;
        for (auto it = node.begin(); it != node.end(); ++it) {
            QString key = QString::fromStdString(it->first.as<std::string>());
            map.insert(key, yamlToVariant(it->second));
        }
        return map;
    }
    return QVariant();
}

YAML::Node variantToYaml(const QVariant &data) {
    if (data.typeId() == QMetaType::QVariantMap) {
        YAML::Node node;
        QVariantMap map = data.toMap();
        for (auto it = map.begin(); it != map.end(); ++it) node[it.key().toStdString()] = variantToYaml(it.value());
        return node;
    }
    if (data.typeId() == QMetaType::QVariantList) {
        YAML::Node node;
        QVariantList list = data.toList();
        for (const auto &item : list) node.push_back(variantToYaml(item));
        return node;
    }
    return YAML::Node(data.toString().toStdString());
}

QVariantMap AiPlugin::parseChat(const QString &content)
{
    QVariantMap result;
    QVariantList messages;
    QString body = content;
    QString yamlText = "";

    if (content.isEmpty()) {
        result["yaml"] = QVariantMap();
        result["messages"] = messages;
        return result;
    }

    QRegularExpression fmRegex("^\\s*---\\s*\\n([\\s\\S]*?)\\n---\\s*\\n([\\s\\S]*)");
    QRegularExpressionMatch fmMatch = fmRegex.match(content);

    if (fmMatch.hasMatch()) {
        yamlText = fmMatch.captured(1);
        body = fmMatch.captured(2);
    }

    QVariant parsedYaml;
    if (!yamlText.isEmpty()) {
        try {
            YAML::Node extractedConfig = YAML::Load(yamlText.toStdString());
            parsedYaml = yamlToVariant(extractedConfig);
        } catch (const YAML::Exception& e) {
            qWarning() << "YAML Parse Error:" << e.what();
            parsedYaml = QVariantMap();
        }
    } else {
        parsedYaml = QVariantMap();
    }

    QRegularExpression msgRegex("<==\\s+(\\w+)\\s+([\\s\\S]*?)\\s+==>");
    QRegularExpressionMatchIterator i = msgRegex.globalMatch(body);

    while (i.hasNext()) {
        QRegularExpressionMatch match = i.next();
        QVariantMap msg;
        msg["role"] = match.captured(1);
        msg["content"] = match.captured(2).trimmed();
        messages.append(msg);
    }

    result["yaml"] = parsedYaml; 
    result["messages"] = messages;

    return result;
}

bool AiPlugin::createChatFile(const QString &path, const QVariantMap &config, const QVariantList &messages)
{
    QFileInfo fileInfo(path);
    QDir dir = fileInfo.absoluteDir();
    if (!dir.exists()) {
        if (!dir.mkpath(".")) {
            qWarning() << "Failed to create directory:" << dir.absolutePath();
            return false;
        }
    }

    QFile file(path);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qWarning() << "Failed to open file for writing:" << path;
        return false;
    }

    QTextStream out(&file);

    if (!config.isEmpty()) {
        out << "---\n";
        try {
            YAML::Emitter emitter;
            emitter << variantToYaml(config);
            out << QString::fromStdString(emitter.c_str()) << "\n";
        } catch (const std::exception &e) {
            qWarning() << "YAML Serialization Error:" << e.what();
        }
        out << "---\n\n";
    }

    for (const auto &msgVar : messages) {
        QVariantMap msg = msgVar.toMap();
        QString role = msg["role"].toString();
        QString content = msg["content"].toString();
        
        if (role == "system") continue;

        out << "<== " << role << "\n";
        out << content << "\n";
        out << "==>\n\n";
    }

    file.close();
    return true;
}

bool AiPlugin::appendMessage(const QString &path, const QString &role, const QString &content)
{
    QFile file(path);
    if (!file.open(QIODevice::Append | QIODevice::Text)) {
        qWarning() << "Failed to open file for appending:" << path;
        return false;
    }

    QTextStream out(&file);
    out << "<== " << role << "\n";
    out << content << "\n";
    out << "==>\n\n";

    file.close();
    return true;
}

QString AiPlugin::createChatPayload(const QVariantMap &settings, const QVariantList &messages)
{
    QJsonObject root;

    int contextLimit = 4096;
    if (settings.contains("num_ctx")) {
        bool ok;
        int val = settings["num_ctx"].toInt(&ok);
        if (ok) contextLimit = val;
    }

    QString systemPrompt = "You are a helpful assistant.";
    if (settings.contains("system_prompt")) {
        systemPrompt = settings["system_prompt"].toString();
    }

    int currentTokens = approximateTokenCount(systemPrompt);
    
    QList<QJsonObject> tempHistory;

    for (int i = messages.size() - 1; i >= 0; --i) {
        QVariantMap map = messages[i].toMap();
        QString content = map["content"].toString();
        int tokens = approximateTokenCount(content);

        if (currentTokens + tokens > contextLimit) {
            break;
        }

        currentTokens += tokens;

        QJsonObject msgObj;
        msgObj["role"] = map["role"].toString();
        msgObj["content"] = content;
        tempHistory.prepend(msgObj); 
    }

    QJsonArray finalMessages;
    
    QJsonObject systemMsg;
    systemMsg["role"] = "system";
    systemMsg["content"] = systemPrompt;
    finalMessages.append(systemMsg);

    for (const auto &msg : tempHistory) {
        finalMessages.append(msg);
    }

    root["messages"] = finalMessages;

    QString modelName = "default";
    if (settings.contains("model")) {
        modelName = settings["model"].toString();
    } else if (settings.contains("provider")) {
        QVariant providerVar = settings["provider"];
        if (providerVar.typeId() == QMetaType::QVariantMap) {
            QVariantMap provider = providerVar.toMap();
            if (provider.contains("model")) {
                modelName = provider["model"].toString();
            }
        }
    }
    root["model"] = modelName;

    // Force stream to true for this plugin if not set, or respect setting
    root["stream"] = settings.value("stream", true).toBool();

    if (settings.contains("options")) {
        QVariant optionsVar = settings["options"];
        if (optionsVar.typeId() == QMetaType::QVariantMap) {
            QVariantMap options = optionsVar.toMap();
            for (auto it = options.begin(); it != options.end(); ++it) {
                root[it.key()] = QJsonValue::fromVariant(it.value());
            }
        }
    }

    QJsonDocument doc(root);
    return QString::fromUtf8(doc.toJson(QJsonDocument::Compact));
}

void AiPlugin::sendChatRequest(const QString &url, const QString &payload, const QString &apiKey)
{
    cancelRequest(); // Cancel any ongoing request

    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    if (!apiKey.isEmpty()) {
        request.setRawHeader("Authorization", "Bearer " + apiKey.toUtf8());
    }

    m_reply = m_manager->post(request, payload.toUtf8());
    
    // Connect signals
    connect(m_reply, &QNetworkReply::readyRead, this, &AiPlugin::onReadyRead);
    connect(m_reply, &QNetworkReply::finished, this, &AiPlugin::onReplyFinished);
}

void AiPlugin::cancelRequest()
{
    if (m_reply) {
        if (m_reply->isRunning()) {
            m_reply->abort();
        }
        m_reply->deleteLater();
        m_reply = nullptr;
    }
    m_buffer.clear();
}

void AiPlugin::onReadyRead()
{
    if (!m_reply) return;

    QByteArray data = m_reply->readAll();
    m_buffer.append(QString::fromUtf8(data));

    // Process lines in buffer
    int index;
    while ((index = m_buffer.indexOf('\n')) != -1) {
        QString line = m_buffer.left(index).trimmed();
        m_buffer.remove(0, index + 1);

        if (line.isEmpty()) continue;

        if (line.startsWith("data: ")) {
            QString jsonStr = line.mid(6); // Remove "data: "

            if (jsonStr == "[DONE]") {
                // Stream finished indicator from OpenAI/Ollama
                continue;
            }

            QJsonParseError error;
            QJsonDocument doc = QJsonDocument::fromJson(jsonStr.toUtf8(), &error);
            if (error.error == QJsonParseError::NoError && doc.isObject()) {
                QJsonObject obj = doc.object();
                
                // Handle standard OpenAI/Ollama stream format
                if (obj.contains("choices") && obj["choices"].isArray()) {
                    QJsonArray choices = obj["choices"].toArray();
                    if (!choices.isEmpty()) {
                        QJsonObject firstChoice = choices[0].toObject();
                        if (firstChoice.contains("delta") && firstChoice["delta"].isObject()) {
                            QJsonObject delta = firstChoice["delta"].toObject();
                            if (delta.contains("content")) {
                                emit streamReceived(delta["content"].toString());
                            }
                        }
                    }
                } 
                // Handle non-stream format (just in case)
                else if (obj.contains("message") && obj["message"].isObject()) {
                     QJsonObject msg = obj["message"].toObject();
                     if (msg.contains("content")) {
                         emit streamReceived(msg["content"].toString());
                     }
                }
            }
        }
    }
}

void AiPlugin::onReplyFinished()
{
    if (!m_reply) return;

    if (m_reply->error() != QNetworkReply::NoError && m_reply->error() != QNetworkReply::OperationCanceledError) {
        emit streamError(m_reply->errorString());
    } else {
        emit streamFinished();
    }

    m_reply->deleteLater();
    m_reply = nullptr;
    m_buffer.clear();
}
