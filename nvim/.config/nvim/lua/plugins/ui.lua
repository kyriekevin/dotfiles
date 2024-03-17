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
    config = true
  },
  {
    'stevearc/dressing.nvim',
    event = "VeryLazy",
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
    opts = {
      indent = {
        char = "|",
        tab_char = "|",
      },
      scope = { enabled = false },
    },
    main = "ibl",
    config = function()
      require("ibl").setup(opts)
    end
  },
  {
    "goolord/alpha-nvim",
    config = function()
      require'alpha'.setup(require'alpha.themes.dashboard'.config)
    end
  }
}
