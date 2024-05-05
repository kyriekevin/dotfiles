return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "frappe",
        integrations = {
          neotree = true,
          which_key = true,
          telescope = {
            enabled = true,
            style = "nvchad",
          },
          alpha = true,
          navic = { enabled = true, custom_bg = "lualine" },
          treesitter = true,
          treesitter_context = true,
          indent_blankline = {
            enabled = true,
            colored_indent_levels = true,
          },
          cmp = true,
          mason = true,
          lsp_saga = true,
          native_lsp = {
            enabled = true,
            virtual_text = {
              errors = { "italic" },
              hints = { "italic" },
              warnings = { "italic" },
              information = { "italic" },
            },
            underlines = {
              errors = { "underline" },
              hints = { "underline" },
              warnings = { "underline" },
              information = { "underline" },
            },
            inlay_hints = {
              background = true,
            },
          },
          flash = true,
          gitsigns = true,
          markdown = true,
          noice = true,
          headlines = true,
          notify = true,
          lsp_trouble = true,
          illuminate = {
            enabled = true,
            lsp = true,
          },
          vimwiki = true,
        },
      })
      vim.cmd.colorscheme("catppuccin-frappe")
    end,
  },
}
