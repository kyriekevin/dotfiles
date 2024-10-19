local wezterm = require 'wezterm'
local config = {}

if wezterm.config_builder() then
    config = wezterm.config_builder()
end

config.color_scheme = "Catppuccin Mocha"

config.window_close_confirmation = "NeverPrompt"

config.window_background_opacity = 0.9

config.window_decorations = "RESIZE"

config.enable_tab_bar = false

config.enable_scroll_bar = false

return config
