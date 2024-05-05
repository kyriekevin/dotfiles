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
  {
    "linux-cultist/venv-selector.nvim",
    config = function()
      require("venv-selector").setup({
        anaconda_base_path = "/opt/homebrew/anaconda3/",
        anaconda_envs_path = "/opt/homebrew/anaconda3/envs/",
      })
    end,
  },
  {
    "hkupty/iron.nvim",
    config = function(plugins, opts)
      local iron = require("iron.core")

      iron.setup({
        config = {
          -- Whether a repl should be discarded or not
          scratch_repl = true,
          -- Your repl definitions come here
          repl_definition = {
            python = {
              -- Can be a table or a function that
              -- returns a table (see below)
              command = { "ipython" },
              format = require("iron.fts.common").bracketed_paste,
            },
            sh = {
              command = { "zsh" },
            },
          },
          -- How the repl window will be displayed
          -- See below for more information
          repl_open_cmd = require("iron.view").right(60),
        },
        -- Iron doesn't set keymaps by default anymore.
        -- You can set them here or manually add keymaps to the functions in iron.core
        keymaps = {
          send_motion = "<space>rc",
          visual_send = "<space>rc",
          send_file = "<space>rf",
          send_line = "<space>rl",
          send_mark = "<space>rm",
          mark_motion = "<space>rmc",
          mark_visual = "<space>rmc",
          remove_mark = "<space>rmd",
          cr = "<space>r<cr>",
          interrupt = "<space>r<space>",
          exit = "<space>rq",
          clear = "<space>rx",
        },
        -- If the highlight is on, you can change how it looks
        -- For the available options, check nvim_set_hl
        highlight = {
          italic = true,
        },
        ignore_blank_lines = true, -- ignore blank lines when sending visual select lines
      })

      -- iron also has a list of commands, see :h iron-commands for all available commands
      vim.keymap.set("n", "<space>rs", "<cmd>IronRepl<cr>")
      vim.keymap.set("n", "<space>rr", "<cmd>IronRestart<cr>")
      vim.keymap.set("n", "<space>rF", "<cmd>IronFocus<cr>")
      vim.keymap.set("n", "<space>rh", "<cmd>IronHide<cr>")
    end,
  },
}
