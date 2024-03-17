return {
  {
    "lewis6991/gitsigns.nvim",
    config = true
  },
  {
    "RRethy/vim-illuminate",
    config = function()
      require("illuminate").configure()
    end
  }
}
