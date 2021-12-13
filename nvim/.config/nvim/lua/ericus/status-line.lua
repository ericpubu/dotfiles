local builtin = require "el.builtin"
local extensions = require "el.extensions"
local sections = require "el.sections"
local subscribe = require "el.subscribe"
local lsp_statusline = require "el.plugins.lsp_status"

local lenght = require("ericus.vim-utils").tablelength

local file_icon = subscribe.buf_autocmd("el_file_icon", "BufRead", function(_, bufnr)
  local icon = extensions.file_icon(_, bufnr)
  if icon then
    return icon .. " "
  end

  return ""
end)

local git_branch = subscribe.buf_autocmd("el_git_branch", "BufEnter", function(window, buffer)
  local branch = extensions.git_branch(window, buffer)
  if branch then
    return " " .. extensions.git_icon() .. " " .. branch
  end
end)

local git_changes = subscribe.buf_autocmd("el_git_changes", "BufWritePost", function(window, buffer)
  return extensions.git_changes(window, buffer)
end)

local function client_connected()
  return not vim.tbl_isempty(vim.lsp.buf_get_clients(0))
end

local diagnostic_counts = function(_, _)
  if not client_connected() then
    return ""
  end

  local messages = {}

  local error_icon = ""
  local warning_icon = ""
  local info_icon = ""
  local hint_icon = ""

  -- Show global for errors, but local for others
  local error_count = lenght(vim.diagnostic.get(nil, { severity = vim.diagnostic.severity.ERROR }))
  local warning_count = lenght(vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN }))
  local info_count = lenght(vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO }))
  local hint_count = lenght(vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT }))

  if error_count == 0 and warning_count == 0 and info_count == 0 and hint_count == 0 then
    return " "
  end

  if error_count ~= 0 then
    table.insert(messages, string.format("%s %d ", error_icon, error_count))
  end
  if warning_count ~= 0 then
    table.insert(messages, string.format("%s %d ", warning_icon, warning_count))
  end
  if info_count ~= 0 then
    table.insert(messages, string.format("%s %d ", info_icon, info_count))
  end
  if hint_count ~= 0 then
    table.insert(messages, string.format("%s %d ", hint_icon, hint_count))
  end

  return table.concat(messages, "")
end

local show_current_func = function(window, buffer)
  if buffer.filetype == "lua" then
    return ""
  end

  return lsp_statusline.current_function(window, vim.api.nvim_win_get_buf())
end

require("el").setup {
  generator = function(_, _)
    return {
      extensions.gen_mode {
        format_string = " %s ",
      },
      git_branch,
      " ",
      git_changes,
      " ",
      sections.split,
      file_icon,
      sections.maximum_width(builtin.make_responsive_file(140, 90), 0.25),
      sections.collapse_builtin {
        " ",
        builtin.modified_flag,
      },
      "  ",
      sections.split,
      show_current_func,
      lsp_statusline.server_progress,
      diagnostic_counts,
      "[",
      builtin.line_with_width(3),
      ":",
      builtin.column_with_width(2),
      "]",
      sections.collapse_builtin {
        "[",
        builtin.help_list,
        builtin.readonly_list,
        "]",
      },
      builtin.filetype,
    }
  end,
}
