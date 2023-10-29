return {
  -- telescope
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { 
        'nvim-telescope/telescope-fzf-native.nvim', 
        build = 'make' 
      }
    },
    config = function()
      require('telescope').setup {
        extensions = {
          fzf = {
            fuzzy = true,                    -- false will only do exact matching
            override_generic_sorter = true,  -- override the generic sorter
            override_file_sorter = true,     -- override the file sorter
            case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
            -- the default case_mode is "smart_case"
          }
        }
      }
      require('telescope').load_extension('fzf')
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
      vim.keymap.set('n', '<leader><space>', builtin.buffers, {})
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
      vim.keymap.set('n', '<leader>?', builtin.oldfiles, { desc = '[?] Find recently opened files' })
      vim.keymap.set('n', '<leader>/', function()
        -- You can pass additional configuration to telescope to change theme, layout, etc.
        require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })
    end
  },

  -- flash
  {
    "folke/flash.nvim",
    config = function()
      require("flash").setup()
      vim.keymap.set({"n","x","o"},"s",
        function()
          require("flash").jump({
            search = {
              mode = function(str)
                return "\\<" .. str
              end,
            },
          })
        end
      )
      vim.keymap.set({"n","x","o"},"S",
        function()
          require("flash").treesitter()
        end
      )
      vim.keymap.set({"o"},"r",
        function()
          require("flash").remote()
        end
      )
      vim.keymap.set({"o","x"},"R",
        function()
          require("flash").treesitter_search()
        end
      )
    end,
  },

  -- neo-tree
  {
    "nvim-neo-tree/neo-tree.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup()
      vim.keymap.set({"n", "v"},"<leader>e",[[<cmd>Neotree toggle<CR>]])
    end
  },

  -- which key
  {
    "folke/which-key.nvim",
    config = true,
  },

  -- gitsigns
  {
    "lewis6991/gitsigns.nvim",
    config = true,
  },

  -- vim-illuminate 
  {
    "RRethy/vim-illuminate",
    config = function()
      require('illuminate').configure()
    end
  },
}
