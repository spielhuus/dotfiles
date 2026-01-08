#pragma once
#include <QObject>
#include <QQmlEngine>
#include <QString>
#include <security/pam_appl.h>

class PamAuth : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit PamAuth(QObject *parent = nullptr);

    // Call this from QML
    Q_INVOKABLE bool checkPassword(const QString &password);
    Q_INVOKABLE QString getUser();

private:
    static int conversation(int num_msg, const struct pam_message **msg,
                            struct pam_response **resp, void *appdata_ptr);
    QString m_passwordBuffer;
};
