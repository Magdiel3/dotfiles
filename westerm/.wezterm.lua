local wezterm = require 'wezterm'

return {
  colors = {
    background = '#1E1E1E',
  },
  --font = wezterm.font("BitstromWera Nerd Font Mono", {weight="Regular", stretch="Normal", style="Normal"}),
  --font = wezterm.font("JetBrains Mono", {weight="Regular", stretch="Normal", style="Normal"}),
  --font = wezterm.font('MartianMono Nerd Font'),
  font = wezterm.font('CommitMonoCustomized', {weight=375, style="Normal"}),
  font_size = 11.0, -- Set the font size to your preference
  hide_tab_bar_if_only_one_tab = true,
  keys = {
    {
        key = 'F11',
        action = wezterm.action.ToggleFullScreen,
    },
  },
}