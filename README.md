# Dog-Ear

Dog-Ear copies a location you can hand to an agent. Select one or more lines in Neovim and it puts the file path and those line numbers on the system clipboard, then flashes the lines green so you can see what was copied.

```
+-------------------- [ USE ] ---------------------+
|                                                  |
| ●  select the lines                              |
| │                                                |
| ●  press <leader>lr                              |
| │                                                |
| ○  paste into the agent                          |
|                                                  |
+--------------------------------------------------+
```

It does not copy the code. The agent gets a place to open, which keeps the chat short and points at the current file instead of a stale paste. What you paste looks like `lua/dog-ear/init.lua:91-108`.

`<leader>` is your leader key: `\` unless you set `mapleader`, and space in a lot of configs. Press that key, then `l`, then `r`, while the lines are still selected. The mapping exists only in visual mode.

## Install

Needs Neovim 0.11 or newer, and a clipboard Neovim can write to. Add the repo, restart Neovim, and the mapping is already there. No setup call is required.

Neovim 0.12, in `init.lua`. During startup, `vim.pack.add` skips `plugin/` unless `load` is true:

```lua
vim.pack.add({ "https://github.com/vicktory22/dog-ear" }, { load = true })
```

lazy.nvim:

```lua
{ "vicktory22/dog-ear" }
```

Any other plugin manager works the same way. Add `https://github.com/vicktory22/dog-ear` and let it load `plugin/`.

Open a named file. Select the lines you want the agent to read, press `<leader>lr`, and paste into the chat. The clipboard gets only the location: one line, or a range, not both.

```
+------------------- [ OUTPUT ] -------------------+
|                                                  |
| one line  file.lua:12                            |
| or range  file.lua:12-18                         |
|                                                  |
+--------------------------------------------------+
```

A single line uses one number. A selection that spans lines uses a range. The path is relative to the current working directory, or absolute when the file is not under that directory. Dog-Ear then leaves visual mode and flashes each selected line. The flash is the whole line, green, and then it clears.

## Change the key

The only mapping is `<leader>lr`. To pick different keys, set `keymap` to that string before the plugin loads. `false` maps nothing.

```lua
vim.g.dog_ear = { keymap = "<leader>lr" }
```

Set `vim.g.loaded_dog_ear = true` first if you will call `setup` yourself. Calling `setup` again replaces the previous mapping.

```lua
vim.g.loaded_dog_ear = true

require("dog-ear").setup({ keymap = "<leader>lr" })
```

With lazy.nvim, pass the same table as `opts`. Lazy calls `setup` after the plugin loads:

```lua
{
  "vicktory22/dog-ear",
  opts = { keymap = "<leader>lr" },
}
```

The flash uses the `Dog-EarFlash` highlight. Set that group from your colorscheme if you want a different color.

## If paste does nothing

Dog-Ear writes the `+` register. Another app only sees that when Neovim has a clipboard provider. Run `:checkhealth` and look at the clipboard report. On Linux, install `xclip`, `xsel`, or `wl-clipboard` when that check fails.

Nothing is copied, and the lines do not flash, when the selection is empty, the buffer has no filename, or the clipboard write fails. Dog-Ear shows a message instead.
