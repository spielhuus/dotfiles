pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool locked: false
    // 5 Minutes timeout
    property int timeoutSeconds: 300 

    // We use swayidle as the backend detection engine
    Process {
        id: idleProc
        running: true
        
        // 'stdbuf -oL' forces swayidle to output text immediately instead of buffering it
        command: [
            "stdbuf", "-oL", 
            "swayidle", "-w", 
            "timeout", root.timeoutSeconds.toString(), "echo idle", 
            "resume", "echo resume"
        ]

        stdout: SplitParser {
            onRead: data => {
                const msg = data.trim()
                if (msg === "idle") {
                    root.lock()
                } 
                // Uncomment to auto-unlock when mouse moves (screensaver behavior)
                // else if (msg === "resume") {
                //     root.unlock()
                // }
            }
        }
        
        onExited: code => console.log(`[Idle] swayidle exited with code ${code}`)
    }

    function lock() {
        console.log("[Idle] Locking screen")
        root.locked = true
    }

    function unlock() {
        console.log("[Idle] Unlocking screen")
        root.locked = false
    }
}
