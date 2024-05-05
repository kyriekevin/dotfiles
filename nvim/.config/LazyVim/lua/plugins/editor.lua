return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
    },
    config = function()
      require("telescope").setup({
        extensions = {
          fzf = {
            fuzzy = true, -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true, -- override the file sorter
            case_mode = "smart_case", -- or "ignore_case" or "respect_case"
            -- the default case_mode is "smart_case"
          },
        },
      })
      require("telescope").load_extension("fzf")
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Lists files in current working directory" })
      vim.keymap.set(
        "n",
        "<leader>fg",
        builtin.live_grep,
        { desc = "Search for a string in current working directory and get results" }
      )
      vim.keymap.set(
        "n",
        "<leader><space>",
        builtin.buffers,
        { desc = "Lists open buffers in current neovim instance" }
      )
      vim.keymap.set(
        "n",
        "<leader>fh",
        builtin.help_tags,
        { desc = "Lists available help tags and opens a new window with the relevant help info on <cr>" }
      )
      vim.keymap.set("n", "<leader>?", builtin.oldfiles, { desc = "[?] Find recently opened files" })
      vim.keymap.set("n", "<leader>/", function()
        -- You can pass additional configuration to telescope to change theme, layout, etc.
        require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
          winblend = 10,
          previewer = false,
        }))
      end, { desc = "[/] Fuzzily search in current buffer" })
    end,
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    config = function()
      require("neo-tree").setup({
        source_selector = {
          winbar = true,
          statusline = true,
        },
        default_component_configs = {
          indent = {
            with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
            expander_collapsed = "",
            expander_expanded = "",
            expander_highlight = "NeoTreeExpander",
          },
        },
      })

      -- set keymap
      local keymap = vim.keymap -- for conciseness

      keymap.set("n", "<leader>e", "<cmd>Neotree toggle<CR>", { desc = "Toggle file explorer" })
      keymap.set("n", "<leader>be", "<cmd>Neotree toggle buffers<CR>", { desc = "Toggle buffer explorer" })
      keymap.set("n", "<leader>ge", "<cmd>Neotree toggle git_status<CR>", { desc = "Toggle git status explorer" })
    end,
  },
  {
    {
      "folke/which-key.nvim",
      event = "VeryLazy",
      opts = {
        plugins = { spelling = true },
        defaults = {
          mode = { "n", "v" },
          ["g"] = { name = "+goto" },
          ["gs"] = { name = "+surround" },
          ["z"] = { name = "+fold" },
          ["]"] = { name = "+next" },
          ["["] = { name = "+prev" },
          ["<leader><tab>"] = { name = "+tabs" },
          ["<leader>b"] = { name = "+buffer" },
          ["<leader>c"] = { name = "+code" },
          ["<leader>f"] = { name = "+file/find" },
          ["<leader>g"] = { name = "+git" },
          ["<leader>gh"] = { name = "+hunks" },
          ["<leader>r"] = { name = "+CompetiTest" },
          ["<leader>l"] = { name = "+LeetCode" },
          ["<leader>q"] = { name = "+quit/session" },
          ["<leader>s"] = { name = "+search" },
          ["<leader>u"] = { name = "+ui" },
          ["<leader>w"] = { name = "+windows" },
          ["<leader>x"] = { name = "+diagnostics/quickfix" },
        },
      },
      config = function(_, opts)
        local wk = require("which-key")
        wk.setup(opts)
        wk.register(opts.defaults)
      end,
    },
  },
}
