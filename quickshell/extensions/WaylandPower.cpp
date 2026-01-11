#include "WaylandPower.h"
#include <QDebug>
#include <cstring> // for strcmp

WaylandPower::WaylandPower(QObject *parent) : QObject(parent) {}

// Static callback to handle registry events
void WaylandPower::registry_global(void *data, struct wl_registry *registry, uint32_t name, const char *interface, uint32_t version)
{
    auto *ctx = static_cast<Context*>(data);

    if (strcmp(interface, "zwlr_output_power_manager_v1") == 0) {
        ctx->powerManager = static_cast<struct zwlr_output_power_manager_v1*>(
            wl_registry_bind(registry, name, &zwlr_output_power_manager_v1_interface, 1)
        );
    }
    else if (strcmp(interface, "wl_output") == 0) {
        struct wl_output *output = static_cast<struct wl_output*>(
            wl_registry_bind(registry, name, &wl_output_interface, 1)
        );
        ctx->outputs.push_back(output);
    }
}

void WaylandPower::registry_global_remove(void *data, struct wl_registry *registry, uint32_t name)
{
    // No-op for a transient connection
}

void WaylandPower::setDpms(bool on)
{
    Context ctx;
    
    // 1. Connect to the Wayland display
    ctx.display = wl_display_connect(nullptr);
    if (!ctx.display) {
        qWarning() << "WaylandPower: Failed to connect to Wayland display";
        return;
    }

    // 2. Get Registry
    ctx.registry = wl_display_get_registry(ctx.display);
    
    static const struct wl_registry_listener registry_listener = {
        .global = registry_global,
        .global_remove = registry_global_remove
    };
    
    wl_registry_add_listener(ctx.registry, &registry_listener, &ctx);

    // 3. Roundtrip to fetch globals (Power Manager and Outputs)
    wl_display_roundtrip(ctx.display);

    if (!ctx.powerManager) {
        qWarning() << "WaylandPower: wlr-output-power-management protocol not supported by compositor";
        // Clean up
        if (ctx.registry) wl_registry_destroy(ctx.registry);
        wl_display_disconnect(ctx.display);
        return;
    }

    // 4. Send DPMS command to all outputs
    uint32_t mode = on ? ZWLR_OUTPUT_POWER_V1_MODE_ON : ZWLR_OUTPUT_POWER_V1_MODE_OFF;

    for (struct wl_output *wlOutput : ctx.outputs) {
        struct zwlr_output_power_v1 *power_output = 
            zwlr_output_power_manager_v1_get_output_power(ctx.powerManager, wlOutput);
        
        zwlr_output_power_v1_set_mode(power_output, mode);
        zwlr_output_power_v1_destroy(power_output);
        
        // Destroy local output proxy
        wl_output_destroy(wlOutput);
    }

    // 5. Roundtrip to ensure commands are sent
    wl_display_roundtrip(ctx.display);

    qDebug() << "WaylandPower: DPMS set to" << (on ? "ON" : "OFF");

    // 6. Clean up
    if (ctx.powerManager) zwlr_output_power_manager_v1_destroy(ctx.powerManager);
    if (ctx.registry) wl_registry_destroy(ctx.registry);
    wl_display_disconnect(ctx.display);
}
