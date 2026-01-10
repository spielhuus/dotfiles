import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Singleton {
    id: root

    property bool locked: false
    // Set to 300 (5 mins) for production, or 5 for testing
    property int timeoutSeconds: 300

    function lock() {
        console.log("[Idle] Locking screen");
        root.locked = true;
    }

    function unlock() {
        console.log("[Idle] Unlocking screen");
        root.locked = false;
    }

    Process {
        id: idleProc

        running: true
        // We run swayidle.
        // timeout: Triggers when user is inactive.
        // resume: Triggers when user moves mouse/types AFTER timeout has fired.
        // before-sleep: Triggers immediately before system suspend.
        command: ["stdbuf", "-oL", "swayidle", "-w", "timeout", root.timeoutSeconds.toString(), "echo idle", "resume", "echo resume", "before-sleep", "echo idle"]
        onExited: (code) => {
            console.log(`[Idle] swayidle exited with code ${code}. Restarting...`);
            restartTimer.start();
        }

        stdout: SplitParser {
            onRead: (data) => {
                // Note: Once the WlSessionLock is active, the compositor might
                // not send a 'resume' event until the lock surface is destroyed
                // or configured specific ways. This is mostly for safety.
                // root.unlock()

                const msg = data.trim();
                if (msg === "idle")
                    root.lock();
                else if (msg === "resume")
                    console.log("[Idle] Resume detected");
            }
        }

    }

    Timer {
        id: restartTimer

        interval: 2000
        repeat: false
        onTriggered: idleProc.running = true
    }

}
