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

  local dir = vim.fn.fnamemodify(abs_path, ":h")
  local git_root = vim.fs.root(dir, ".git")
  if not git_root then
    return vim.fn.fnamemodify(abs_path, ":t")
  end

  local rel = vim.fs.relpath(git_root, abs_path)
  if not rel or rel == "." then
    return vim.fn.fnamemodify(abs_path, ":t")
  end
  return rel
end

local function copy(text)
  -- Without a clipboard provider, "+" is only an internal register.
  if vim.fn.has("clipboard") ~= 1 then
    return false
  end
  local ok = pcall(vim.fn.setreg, "+", text)
  return ok and vim.fn.getreg("+") == text
end

local function define_hl()
  vim.api.nvim_set_hl(0, "Dog-EarFlash", { bg = "#1f7a32", fg = "#f0fff0", default = true })
end

local function flash(buf, start_line, end_line)
  -- One mark per line. A shared end row is inclusive and paints the line below.
  -- Delete only these ids so a second flash does not wipe the first.
  local marks = {}
  for line = start_line, end_line do
    marks[#marks + 1] = vim.api.nvim_buf_set_extmark(buf, ns, line - 1, 0, {
      line_hl_group = "Dog-EarFlash",
      priority = vim.hl.priorities.user,
    })
  end
  vim.defer_fn(function()
    if not vim.api.nvim_buf_is_valid(buf) then
      return
    end
    for _, id in ipairs(marks) do
      vim.api.nvim_buf_del_extmark(buf, ns, id)
    end
  end, 400)
end

local function is_before(a, b)
  if a[2] ~= b[2] then
    return a[2] < b[2]
  end
  return a[3] < b[3]
end

local function selection_lines()
  -- getpos("v") is the anchor and is current while this mapping runs.
  -- '< and '> still point at the previous visual selection.
  local anchor = vim.fn.getpos("v")
  local cursor = vim.fn.getpos(".")
  local earlier, later = anchor, cursor
  if is_before(cursor, anchor) then
    earlier, later = cursor, anchor
  end

  local start_line = earlier[2]
  local end_line = later[2]

  -- Exclusive characterwise mode omits the later position, whichever end the
  -- cursor is on. Column 1 means that line has no selected characters.
  -- Identical positions are an empty selection.
  if vim.fn.mode() == "v" and vim.o.selection == "exclusive" then
    if later[2] == earlier[2] and later[3] == earlier[3] then
      return nil
    end
    if later[3] == 1 then
      end_line = end_line - 1
    end
  end

  if end_line < start_line or start_line < 1 then
    return nil
  end
  return start_line, end_line
end

function M.copy_visual()
  local buf = vim.api.nvim_get_current_buf()
  local start_line, end_line = selection_lines()
  if not start_line then
    vim.notify("No lines selected", vim.log.levels.WARN)
    return
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
  define_hl()
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("dog-ear", { clear = true }),
    callback = define_hl,
  })
  vim.keymap.set("x", "<leader>lr", M.copy_visual, { desc = "Copy filename and line numbers" })
end

return M
