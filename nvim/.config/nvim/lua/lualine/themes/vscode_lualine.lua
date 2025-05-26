local colors = {
    accent      = "#007acc", -- blue accent
    bg          = "#1e1e1e",
    fg          = "#d4d4d4",
    white       = "#ffffff",
    black       = "#000000",
    red         = "#f14c4c",
    green       = "#366432",
    blue        = "#3794ff",
    dark_blue   = "#001144",
    magenta     = "#68217a",
    cyan        = "#1177bb",
    yellow      = "#ffcc00", -- strong yellow
    --yellow      = "#cca700",
    gray        = "#3a3d41",
    ligh_gray   = "#a6a6a6",
    dark_gray   = "#0e0e0e", -- custom pick
}

return {
  normal =      {
      a = { fg = colors.fg,         bg = colors.dark_blue },
      b = { fg = colors.fg,         bg = colors.accent },
      c = { fg = colors.fg,         bg = colors.accent },
  },
  insert =      {
      a = { fg = colors.fg,         bg = colors.green },
      b = { fg = colors.fg,         bg = colors.accent },
      c = { fg = colors.fg,         bg = colors.accent },
  },
  visual =      {
      a = { fg = colors.fg,         bg = colors.magenta },
      b = { fg = colors.fg,         bg = colors.accent },
      c = { fg = colors.fg,         bg = colors.accent },
  },
  replace =     {
      a = { fg = colors.fg,         bg = colors.red },
      b = { fg = colors.fg,         bg = colors.accent },
      c = { fg = colors.fg,         bg = colors.accent },
  },
  command =     {
      a = { fg = colors.bg,         bg = colors.yellow },
      b = { fg = colors.fg,         bg = colors.accent },
      c = { fg = colors.fg,         bg = colors.accent },
  },
  inactive =    {
      a = { fg = colors.light_gray, bg = colors.gray },
      b = { fg = colors.light_gray, bg = colors.gray },
      c = { fg = colors.light_gray, bg = colors.gray },
  },
}
