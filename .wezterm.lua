local wezterm = require('wezterm')
local config = wezterm.config_builder()
config.colors = {
  background = 'white',
}
config['audible_bell'] = 'Disabled'
config['max_fps'] = 120
return config
