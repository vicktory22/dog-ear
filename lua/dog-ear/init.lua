local M = {}

local ns = vim.api.nvim_create_namespace("dog-ear")

local function reference(path, start_line, end_line)
  if start_line == end_line then
    return string.format("%s:%d", path, start_line)
  end
  return string.format("%s:%d-%d", path, start_line, end_line)
end

local function file_path()
  local abs_path = vim.fn.expand("%:p")
  if abs_path == "" then
    return nil
  end

  local git_root = vim.trim(vim.fn.system({ "git", "rev-parse", "--show-toplevel" }))
  if vim.v.shell_error == 0 and git_root ~= "" then
    return vim.fn.fnamemodify(abs_path, ":s?" .. git_root .. "/??")
  end
  return vim.fn.expand("%:t")
end

local function copy(text)
  if vim.fn.executable("wl-copy") == 1 then
    local job = vim.fn.jobstart({ "wl-copy" }, { stdin = "pipe" })
    if job > 0 then
      vim.fn.chansend(job, text)
      vim.fn.chanclose(job, "stdin")
      return true
    end
  end
  vim.fn.setreg("+", text)
  return vim.fn.getreg("+") == text
end

local function flash(buf, start_line, end_line)
  vim.api.nvim_set_hl(0, "Dog-EarFlash", { bg = "#1f7a32", fg = "#f0fff0" })
  -- One mark per line. A shared end row is inclusive and paints the line below.
  for line = start_line, end_line do
    vim.api.nvim_buf_set_extmark(buf, ns, line - 1, 0, {
      line_hl_group = "Dog-EarFlash",
      priority = vim.hl.priorities.user,
    })
  end
  vim.defer_fn(function()
    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    end
  end, 400)
end

function M.copy_visual()
  local buf = vim.api.nvim_get_current_buf()
  local start_line = vim.fn.line("v")
  local end_line = vim.fn.line(".")
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end

  local path = file_path()
  if not path then
    vim.notify("No file to copy", vim.log.levels.WARN)
    return
  end

  local text = reference(path, start_line, end_line)
  if not copy(text) then
    vim.notify("Failed to copy to clipboard", vim.log.levels.ERROR)
    return
  end

  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
  vim.schedule(function()
    flash(buf, start_line, end_line)
  end)
end

function M.setup()
  vim.keymap.set("x", "<leader>lr", M.copy_visual, { desc = "Copy filename and line numbers" })
end

return M
