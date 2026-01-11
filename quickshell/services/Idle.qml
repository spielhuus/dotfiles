import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Singleton {
    //300

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
        command: ["stdbuf", "-oL", "swayidle", "-w", "timeout", root.timeoutSeconds.toString(), "echo idle", "resume", "echo resume", "before-sleep", "echo idle"]
        onExited: (code) => {
            console.log(`[Idle] swayidle exited with code ${code}. Restarting...`);
            restartTimer.start();
        }

        stdout: SplitParser {
            onRead: (data) => {
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
