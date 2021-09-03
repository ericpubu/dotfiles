-- Important globals settings
vim.g.mapleader = " "
vim.opt.shell = '/bin/bash'

-- General configs
require('ericus.settings')
require('ericus.syntax')
-- Load plugins with packer
require('plugins')
require('impatient') -- Workaround while https://github.com/neovim/neovim/pull/15436 is ready
-- Plugin required configs
require('ericus.editor')
require('ericus.status-line')
require('ericus.lang-tools')
require("ericus.completion")
require("ericus.telescope")
require("ericus.git")
require("ericus.lsp")
require("ericus.dap")
