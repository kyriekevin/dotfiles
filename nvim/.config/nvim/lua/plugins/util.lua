return {
  {
    "rhysd/accelerated-jk",
    config = function()
      vim.keymap.set("n", "j", "<Plug>(accelerated_jk_gj)")
      vim.keymap.set("n", "k", "<Plug>(accelerated_jk_gk)")
    end,
  },
  {
    "folke/persistence.nvim",
    config = function()
      require("persistence").setup()
      vim.keymap.set("n", "<leader>qs", [[<cmd>lua require("persistence").load()<cr>]], { desc = "Restore Session" })
      vim.keymap.set("n", "<leader>ql", [[<cmd>lua require("persistence").load({ last = true})<cr>]],
        { desc = "Restore Last Session" })
      vim.keymap.set("n", "<leader>qd", [[<cmd>lua require("persistence").stop()<cr>]],
        { desc = "Don't Save Current Session" })
    end
  },
  {
    "windwp/nvim-autopairs",
    opts = {
      enable_check_bracket_line = false,
    },
  },
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<c-h>",  "<cmd><C-U>TmuxNavigateLeft<cr>" },
      { "<c-j>",  "<cmd><C-U>TmuxNavigateDown<cr>" },
      { "<c-k>",  "<cmd><C-U>TmuxNavigateUp<cr>" },
      { "<c-l>",  "<cmd><C-U>TmuxNavigateRight<cr>" },
      { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
    },
  }
}
