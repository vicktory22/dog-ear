if vim.g.loaded_dog_ear then
  return
end
vim.g.loaded_dog_ear = true

local opts = vim.g.dog_ear
if type(opts) ~= "table" then
  opts = nil
end
require("dog-ear").setup(opts)
