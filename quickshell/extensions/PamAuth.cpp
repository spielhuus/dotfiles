#include "PamAuth.h"
#include <unistd.h>
#include <sys/types.h>
#include <pwd.h>
#include <cstring>
#include <cstdlib>

PamAuth::PamAuth(QObject *parent) : QObject(parent) {}

// Standard PAM conversation function
int PamAuth::conversation(int num_msg, const struct pam_message **msg,
                          struct pam_response **resp, void *appdata_ptr)
{
    if (num_msg <= 0 || num_msg > PAM_MAX_NUM_MSG) return PAM_CONV_ERR;

    auto *authenticator = static_cast<PamAuth*>(appdata_ptr);
    struct pam_response *reply = (struct pam_response *)calloc(num_msg, sizeof(struct pam_response));

    for (int i = 0; i < num_msg; ++i) {
        // If PAM asks for a password (PAM_PROMPT_ECHO_OFF), give it the stored password
        if (msg[i]->msg_style == PAM_PROMPT_ECHO_OFF) {
            reply[i].resp = strdup(authenticator->m_passwordBuffer.toStdString().c_str());
            reply[i].resp_retcode = 0;
        } else {
            // Ignore other prompts (info messages, etc)
            reply[i].resp = nullptr;
            reply[i].resp_retcode = 0;
        }
    }

    *resp = reply;
    return PAM_SUCCESS;
}

QString PamAuth::getUser() {
    struct passwd *pw = getpwuid(getuid());
    return QString::fromLocal8Bit(pw ? pw->pw_name : "user");
}

bool PamAuth::checkPassword(const QString &password)
{
    m_passwordBuffer = password;

    struct pam_conv conv = {
        &PamAuth::conversation,
        this
    };

    pam_handle_t *pamh = nullptr;
    QString user = getUser();
    int retval;

    // Start PAM
    retval = pam_start("login", user.toStdString().c_str(), &conv, &pamh);

    // Attempt authentication
    if (retval == PAM_SUCCESS) {
        retval = pam_authenticate(pamh, 0);
    }

    // Check account validity (e.g. is account expired?)
    if (retval == PAM_SUCCESS) {
        retval = pam_acct_mgmt(pamh, 0);
    }

    bool success = (retval == PAM_SUCCESS);

    // Cleanup
    if (pamh) {
        pam_end(pamh, retval);
    }
    
    // Clear buffer for security
    m_passwordBuffer.clear();

    return success;
}
