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
    config = true
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    config = true
  },
  {
    'akinsho/bufferline.nvim',
    event = "VeryLazy",
    config = true
  },
  {
    'stevearc/dressing.nvim',
    event = "VeryLazy",
    config = true
  },
  {
    "utilyre/barbecue.nvim",
    name = "barbecue",
    version = "*",
    dependencies = {
      "SmiteshP/nvim-navic",
    },
    config = function()
      require("barbecue").setup {
        theme = "catppuccin-frappe"
      }
    end,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    event = "VeryLazy",
    opts = {
      indent = {
        char = "|",
        tab_char = "|",
      },
      scope = { enabled = false },
    },
    main = "ibl",
  },
  {
    "goolord/alpha-nvim",
    event = "VeryLazy",
    config = function()
      require 'alpha'.setup(require 'alpha.themes.dashboard'.config)
    end
  },
}
