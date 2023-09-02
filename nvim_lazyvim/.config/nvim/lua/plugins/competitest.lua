return {
  "xeluxee/competitest.nvim",
  dependencies = "MunifTanjim/nui.nvim",
  event = "VeryLazy",
  config = function()
    require("competitest").setup()
  end,
}
