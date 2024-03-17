return {
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup {
        options = { theme = "catppuccin-frappe" }
      }
    end
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {},
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    }
  },
  { 
    'akinsho/bufferline.nvim', 
    version = "*", 
    dependencies = 'nvim-tree/nvim-web-devicons',
    opts = {
      options = {
        mode = "tabs",
        separator_style = "slant",
      }
    }
  },
  {
    'stevearc/dressing.nvim',
    event = "VeryLazy",
  }
}
