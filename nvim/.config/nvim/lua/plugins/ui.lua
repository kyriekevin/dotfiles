return {
  -- bufferline
  {
    "akinsho/bufferline.nvim",
    config = true, 
  },

  -- indent-blankline
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = true,
  },

  -- alpha-nvim
  {
    "goolord/alpha-nvim",
    config = function()
      require'alpha'.setup(require'alpha.themes.dashboard'.config)
    end
  },
}
