local config = {options = {opt = {}}, plugins = {init = {}},colorscheme}
local plugins = config.plugins.init
local options = config.options.opt
local colorscheme = "default_theme"

local theme_installed, _ = pcall(require, "pywal")
if theme_installed then
  colorscheme = "pywal"
end
config.colorscheme = colorscheme
options['spell'] = true
plugins['ActivityWatch/aw-watcher-vim'] = {}
plugins['AlphaTechnolog/pywal.nvim'] = {as = 'pywal'}
return config
