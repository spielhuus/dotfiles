#include "AiPlugin.h"
#include <iostream>
#include <QRegularExpression>
#include <QVariantList>
#include <QDebug>
#include <yaml-cpp/yaml.h> // Include the library

AiPlugin::AiPlugin(QObject *parent) : QObject(parent)
{
}

QString AiPlugin::generateText(const QString &prompt)
{
    return "AI Response to: " + prompt;
}

// Helper function to convert YAML nodes to Qt Types
QVariant yamlToVariant(const YAML::Node& node) {
    if (node.IsScalar()) {
        std::string s = node.as<std::string>();
        // Simple heuristic for types, or just return String for everything
        // Here we return string to be safe, QML handles type coercion well
        return QString::fromStdString(s);
    }
    
    if (node.IsSequence()) {
        QVariantList list;
        for (const auto& child : node) {
            list.append(yamlToVariant(child));
        }
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

QVariantMap AiPlugin::parseChat(const QString &content)
{
    QVariantMap result;
    QVariantList messages;
    QString body = content;
    QString yamlText = "";

    if (content.isEmpty()) {
        result["yaml"] = QVariantMap(); // Return empty map instead of string
        result["messages"] = messages;
        return result;
    }

    // 1. Extract Frontmatter (YAML)
    QRegularExpression fmRegex("^\\s*---\\s*\\n([\\s\\S]*?)\\n---\\s*\\n([\\s\\S]*)");
    QRegularExpressionMatch fmMatch = fmRegex.match(content);

    if (fmMatch.hasMatch()) {
        yamlText = fmMatch.captured(1);
        body = fmMatch.captured(2);
    }

    // 2. Parse YAML using yaml-cpp
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

    // 3. Extract Messages
    QRegularExpression msgRegex("<==\\s+(\\w+)\\s+([\\s\\S]*?)\\s+==>");
    QRegularExpressionMatchIterator i = msgRegex.globalMatch(body);

    while (i.hasNext()) {
        QRegularExpressionMatch match = i.next();
        QVariantMap msg;
        msg["role"] = match.captured(1);
        msg["content"] = match.captured(2).trimmed();
        messages.append(msg);
    }

    // Return the native object, not a string
    result["yaml"] = parsedYaml; 
    result["messages"] = messages;

    return result;
}
