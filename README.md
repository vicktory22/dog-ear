Dog-Ear copies a location you can hand to an agent. Select one or more lines in Neovim and it puts the file and those line numbers on the system clipboard, then flashes the lines green so you can see what was copied.

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

It does not copy the code itself. The agent gets a place to open, which keeps the chat short and points at the current file instead of a stale paste.

```
+------------------- [ OUTPUT ] -------------------+
|                                                  |
| key       <leader>lr                             |
| mode      visual                                 |
| one line  file.lua:12                            |
| range     file.lua:12-18                         |
| path      relative to the git root               |
| flash     the whole line, green                  |
|                                                  |
+--------------------------------------------------+
```

Inside a git repository the path is relative to the repository root. Outside a repository it is only the filename. A single line uses one number. A selection that spans lines uses a range.

## Install

```lua
vim.pack.add({ "https://github.com/vicktory22/dog-ear" })
```

`vim.pack` clones the repo and adds it with `:packadd`. These two files are enough. No `doc/`, license, or `pkg.json` is required.

```
+------------------- [ FILES ] --------------------+
|                                                  |
| dog-ear                                          |
| ├─ plugin                                        |
| │  └─ dog-ear.lua  sourced on load               |
| └─ lua                                           |
|    └─ dog-ear                                    |
|       └─ init.lua  require("dog-ear")            |
|                                                  |
+--------------------------------------------------+
```

`plugin/dog-ear.lua` calls `require("dog-ear").setup()`, which loads `lua/dog-ear/init.lua` and maps `<leader>lr` in visual mode. Set `vim.g.dog_ear` before that load to change it: `{ keymap = "<leader>de" }` uses another key, and `{ keymap = false }` maps nothing. Set `vim.g.loaded_dog_ear = true` first if you will call `setup` yourself. Calling `setup` again replaces the previous Dog-Ear mapping.

```
+-------------------- [ LOAD ] --------------------+
|                                                  |
| ●  vim.pack clones the repo                      |
| │                                                |
| ●  packadd sources plugin/dog-ear.lua            |
| │                                                |
| ○  setup maps <leader>lr                         |
|                                                  |
+--------------------------------------------------+
```

If that `add()` call is in `init.lua`, Neovim waits until startup finishes before sourcing `plugin/`. The mapping is still set before you use it.
