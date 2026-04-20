-- Runtime probe emitted by tests/nvim.sh. Keeps the lua out of a multi-line
-- `-c 'lua …'` arg (nvim's Ex parser can split those at newlines on some
-- builds; observed clean on v0.12.1 but we don't want to depend on it).
-- Loaded via `nvim --headless +luafile tests/nvim_probe.lua +qa` so init.lua
-- runs first and plugins are fully initialized.

local o = vim.opt

print("K_LEADER="    .. vim.g.mapleader)
print("K_COLORS="    .. (vim.g.colors_name or ""))
print("K_NUMBER="    .. tostring(o.number:get()))
print("K_RELNUM="    .. tostring(o.relativenumber:get()))
print("K_EXPANDTAB=" .. tostring(o.expandtab:get()))
print("K_TS="        .. tostring(o.tabstop:get()))
print("K_SW="        .. tostring(o.shiftwidth:get()))
print("K_UNDOFILE="  .. tostring(o.undofile:get()))
print("K_NETRW="     .. tostring(vim.g.loaded_netrw))
print("K_SNACKS="    .. tostring(_G.Snacks ~= nil))

-- Use vim.fn.maparg rather than scanning nvim_get_keymap for a literal
-- " cd" lhs — maparg accepts the <leader>cd notation directly and lets
-- nvim handle leader expansion / termcode encoding. Returns "" when unbound.
local cd_map = vim.fn.maparg("<leader>cd", "n")
print("K_LEADER_CD=" .. tostring(cd_map ~= ""))
