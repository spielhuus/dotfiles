local wezterm = require 'wezterm'
local act = wezterm.action
return {
  keys = {
    { key = 'PageUp', mods = 'SHIFT', action = act.ScrollByPage(-0.5) },
    { key = 'PageDown', mods = 'SHIFT', action = act.ScrollByPage(0.5) },
  },
  font = wezterm.font 'JetBrainsMono Nerd Font Mono',
  color_scheme = 'Dracula+',
  window_background_opacity = 0.9,
  hide_tab_bar_if_only_one_tab = true,
}
