#pragma once
#include <QObject>
#include <QQmlEngine>
#include <QVariantMap> // Added include

class AiPlugin : public QObject
{
    Q_OBJECT
    QML_ELEMENT

public:
    explicit AiPlugin(QObject *parent = nullptr);

    Q_INVOKABLE QString generateText(const QString &prompt);
    
    // New method to parse chat content
    Q_INVOKABLE QVariantMap parseChat(const QString &content);
};
