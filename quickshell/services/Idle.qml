import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Singleton {
    id: root

    property bool locked: false
    property int timeoutSeconds: 300 // 5 mins

    function lock() {
        console.log("[Idle] Locking screen");
        root.locked = true;
    }

    function unlock() {
        console.log("[Idle] Unlocking screen");
        root.locked = false;
    }

    Process {
        id: audioCheckProc

        command: ["sh", "-c", "pactl list sinks | grep 'State: RUNNING'"]
        onExited: (code) => {
            if (code === 0) {
                console.log("[Idle] Media playing. Resetting idle timer...");
                idleProc.running = false;
                restartTimer.start();
            } else {
                root.lock();
            }
        }
    }

    Process {
        // specific unlock logic if needed

        id: idleProc

        running: true
        command: ["stdbuf", "-oL", "swayidle", "-w", "timeout", root.timeoutSeconds.toString(), "echo idle", "resume", "echo resume", "before-sleep", "echo idle"]
        onExited: (code) => {
            console.log(`[Idle] swayidle exited with code ${code}. Restarting...`);
            if (running)
                restartTimer.start();

        }

        stdout: SplitParser {
            onRead: (data) => {
                const msg = data.trim();
                if (msg === "idle")
                    audioCheckProc.running = true;
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
