return {
  "neovim/nvim-lspconfig",
  cmd = { "Mason", "Neoconf" },
  event = { "BufReadPost", "BufNewFile" },
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig",
    "folke/neoconf.nvim",
    "folke/neodev.nvim",
    {
      "j-hui/fidget.nvim",
      tag = "legacy",
    },
    "nvimdev/lspsaga.nvim",
    { "antosha417/nvim-lsp-file-operations", config = true },
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
    local servers = {
      lua_ls = {
        settings = {
          Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
          },
        },
      },
      pyright = {},
      jsonls = {},
      clangd = {},
    }
    local on_attach = function(_, bufnr)
      -- Enable completion triggered by <c-x><c-o>
      local nmap = function(keys, func, desc)
        if desc then
          desc = "LSP: " .. desc
        end

        vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
      end

      nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
      nmap("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
      nmap("ghd", "<cmd>Lspsaga hover_doc<CR>", "[G]oto [H]over [D]ocumentation")
      nmap("gi", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
      nmap("gsd", vim.lsp.buf.signature_help, "[G]et [S]ignature [D]ocumentation")
      nmap("gy", vim.lsp.buf.type_definition, "[G]oto T[y]pe Definition")
      nmap("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
      nmap("<leader>cr", "<cmd>Lspsaga rename ++project<cr>", "reame")
      nmap("<leader>ca", "<cmd>Lspsaga code_action<CR>", "[C]ode [A]ction")
      nmap("<leader>ud", require("telescope.builtin").diagnostics, "Toggle Diagnostics")
    end
    require("neoconf").setup()
    require("neodev").setup()
    require("fidget").setup()
    require("lspsaga").setup({
      ui = {
        kind = require("catppuccin.groups.integrations.lsp_saga").custom_kind(),
      },
    })

    require("mason").setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    require("mason-tool-installer").setup({
      ensure_installed = {
        "prettier", -- prettier formatter
        "stylua", -- lua formatter
        "isort", -- python formatter
        "black", -- python formatter
        "pylint", -- python linter
      },
    })

    local keymap = vim.keymap
    keymap.set("n", "<leader>cm", "<cmd>Mason<cr>", { desc = "Mason" })

    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    require("mason-lspconfig").setup({
      ensure_installed = vim.tbl_keys(servers),
    })

    for server, config in pairs(servers) do
      require("lspconfig")[server].setup(vim.tbl_deep_extend("keep", {
        on_attach = on_attach,
        capabilities = capabilities,
      }, config))
    end
  end,
}
