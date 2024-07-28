return {
  {
    "kawre/leetcode.nvim",
    build = ":TSUpdate html",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim", -- required by telescope
      "MunifTanjim/nui.nvim",

      -- optional
      "nvim-treesitter/nvim-treesitter",
      "rcarriga/nvim-notify",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("leetcode").setup({
        -- configuration goes here
        lang = "python3",
        cn = {
          enabled = true,
          translator = true,
          translate_problems = true,
        },
        storage = {
          home = "~/.github/leetcode",
        },
        image_support = false,
      })

      local keymap = vim.keymap

      keymap.set("n", "<leader>ld", "<cmd>Leet desc<CR>", { desc = "question description" })
      keymap.set("n", "<leader>ll", "<cmd>Leet lang<CR>", { desc = "code lang" })
      keymap.set("n", "<leader>lt", "<cmd>Leet test<CR>", { desc = "code test" })
      keymap.set("n", "<leader>ls", "<cmd>Leet submit<CR>", { desc = "code submit" })
    end,
  },
  {
    "xeluxee/competitest.nvim",
    dependencies = "MunifTanjim/nui.nvim",
    config = function()
      require("competitest").setup({
        runner_ui = {
          interface = "split",
        },
        compile_command = {
          cpp = { exec = "g++", args = { "$(FNAME)", "-std=c++17", "-O2", "-g", "-Wall", "-o", "$(FNOEXT)" } },
          some_lang = { exec = "some_compiler", args = { "$(FNAME)" } },
        },
        run_command = {
          cpp = { exec = "./$(FNOEXT)" },
          some_lang = { exec = "some_interpreter", args = { "$(FNAME)" } },
        },
      })

      local keymap = vim.keymap
      keymap.set("n", "<leader>rr", "<cmd>CompetiTest run<CR>", { desc = "run" })
      keymap.set("n", "<leader>ra", "<cmd>CompetiTest add_testcase<CR>", { desc = "add testcase" })
      keymap.set("n", "<leader>re", "<cmd>CompetiTest edit_testcase<CR>", { desc = "edit testcase" })
      keymap.set("n", "<leader>ri", "<cmd>CompetiTest receive testcases<CR>", { desc = "receive testcases" })
      keymap.set("n", "<leader>rd", "<cmd>CompetiTest delete_testcase<CR>", { desc = "delete testcase" })
      keymap.set("n", "<leader>rm", function()
        vim.cmd('silent ! rm -f "./%<" && rm -f "./%<"_(in|out)put*.txt')
        vim.notify(" 󰆴 Clean")
      end, { desc = "clean testcases" })
    end,
  },
}
