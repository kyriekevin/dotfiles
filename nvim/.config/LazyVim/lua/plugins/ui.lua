return {
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    config = true,
  },
  {
    "utilyre/barbecue.nvim",
    name = "barbecue",
    version = "*",
    dependencies = {
      "SmiteshP/nvim-navic",
    },
    config = function()
      require("barbecue").setup({
        theme = "tokyonight",
      })
    end,
  },
}
