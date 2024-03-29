return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  config = function()
    require("catppuccin").setup({
      flavour = "frappe",
      integrations = {
        alpha = true,
        cmp = true,
        dashboard = true,
        flash = true,
        gitsigns = true,
        mason = true,
        markdown = true,
        navic = { enabled = true, custom_bg = "lualine" },
        neotree = true,
        noice = true,
        telescope = {
          enabled = true,
        },
        which_key = true,
        barbecue = {
          dim_dirname = true,
          bold_basename = true,
          dim_context = false,
          alt_background = false,
        },
        indent_blankline = {
          enabled = true,
          scope_color = "",
          colored_indent_levels = false,
        },
        illuminate = {
          enabled = true,
          lsp = false
        },
        treesitter = true,
        treesitter_context = true,
        dap = true,
        dap_ui = true,
        notify = true,
      },
    })
    vim.cmd.colorscheme "catppuccin"
  end,
}
