return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  build = ":Copilot auth",
  opts = {
    suggestion = { enabled = false },
    panel = { enabled = false },
    filetypes = {
      terraform = false,
      yaml = false,
      hgcommit = false,
      svn = false,
      cvs = false,
      javascript = false,
      typescript = false,
      ["."] = true,
    },
  },
}
