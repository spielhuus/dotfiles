#pragma once
#include <QObject>
#include <QQmlEngine>
#include <QVariantMap>
#include <QNetworkAccessManager>
#include <QNetworkReply>

class AiPlugin : public QObject
{
    Q_OBJECT
    QML_ELEMENT

public:
    explicit AiPlugin(QObject *parent = nullptr);

    Q_INVOKABLE QString generateText(const QString &prompt);
    
    // Parses chat content returning { yaml: {}, messages: [] }
    Q_INVOKABLE QVariantMap parseChat(const QString &content);

    // Creates a new chat file with YAML frontmatter and initial messages
    Q_INVOKABLE bool createChatFile(const QString &path, const QVariantMap &config, const QVariantList &messages);

    // Appends a single message entry to an existing file
    Q_INVOKABLE bool appendMessage(const QString &path, const QString &role, const QString &content);

    // Creates the JSON payload string for the chat request
    Q_INVOKABLE QString createChatPayload(const QVariantMap &settings, const QVariantList &messages);

    // New: Send streaming request
    Q_INVOKABLE void sendChatRequest(const QString &url, const QString &payload, const QString &apiKey = "");
    
    // New: Cancel active request
    Q_INVOKABLE void cancelRequest();

signals:
    void streamReceived(QString content);
    void streamFinished();
    void streamError(QString error);

private slots:
    void onReadyRead();
    void onReplyFinished();

private:
    QNetworkAccessManager *m_manager;
    QNetworkReply *m_reply = nullptr;
    QString m_buffer; // To handle split SSE chunks
};
