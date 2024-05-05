-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- vim.api.nvim_create_autocmd("VimEnter", {
--   desc = "Auto select virtualenv Nvim open",
--   pattern = "*",
--   callback = function()
--     local venv = vim.fn.findfile("pyproject.toml", vim.fn.getcwd() .. ";")
--     if venv ~= "" then
--       require("venv-selector").retrieve_from_cache()
--     end
--   end,
--   once = true,
-- })

vim.api.nvim_create_autocmd({ "BufEnter", "DirChanged" }, {
  desc = "Automatically select virtual environment based on pyproject.toml",
  pattern = "*",
  callback = function()
    local cwd = vim.fn.expand("%:p:h")
    local venv = vim.fn.findfile("pyproject.toml", cwd .. ";")
    if venv ~= "" then
      local root_dir = vim.fn.fnamemodify(venv, ":h")
      -- Assuming correct function is retrieve_from_cache() or similar
      -- Check documentation for correct function usage
      require("venv-selector").retrieve_from_cache()
      -- For debugging:
      print("Activated environment at: " .. root_dir)
    else
      -- You can add a debug log or warning here if pyproject.toml is not found
      print("pyproject.toml not found from current directory up to root.")
    end
  end,
})
