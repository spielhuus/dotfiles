#pragma once
#include <QObject>
#include <QQmlEngine>
#include <vector>
#include <wayland-client.h>
#include "wlr-output-power-management-unstable-v1-client-protocol.h"

class WaylandPower : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit WaylandPower(QObject *parent = nullptr);
    
    // The function callable from QML
    Q_INVOKABLE void setDpms(bool on);

private:
    // Helper struct to hold data during the standalone connection
    struct Context {
        struct wl_display *display = nullptr;
        struct wl_registry *registry = nullptr;
        struct zwlr_output_power_manager_v1 *powerManager = nullptr;
        std::vector<struct wl_output *> outputs;
    };

    static void registry_global(void *data, struct wl_registry *registry, uint32_t name, const char *interface, uint32_t version);
    static void registry_global_remove(void *data, struct wl_registry *registry, uint32_t name);
};
