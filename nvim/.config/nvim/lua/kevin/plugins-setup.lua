local ensure_packer = function()
	local fn = vim.fn
	local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
	if fn.empty(fn.glob(install_path)) > 0 then
		fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
		vim.cmd [[packadd packer.nvim]]
		return true
	end
	return false
end

local packer_bootstrap = ensure_packer()

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd([[
	augroup packer_user_config
    	autocmd!
    	autocmd BufWritePost plugins-setup.lua source <afile> | PackerSync
  	augroup end
]])

local status, packer = pcall(require, "packer")
if not status then
	return
end

return packer.startup({
	function(use)
	use 'wbthomason/packer.nvim'

	-- lua functions that many plugins use
	use("nvim-lua/plenary.nvim")

	-- Pretty Dress
	use { "bluz71/vim-nightfly-colors", as = "nightfly" }
	-- statusline
	use { 'nvim-lualine/lualine.nvim' }
	-- icons
	use "kyazdani42/nvim-web-devicons"

	-- tmux & split window navigation
	use("christoomey/vim-tmux-navigator")

	-- maximizes and restores current window
	use("szw/vim-maximizer")

	-- essential plugins
	use("tpope/vim-surround")
	use("vim-scripts/ReplaceWithRegister")

	-- commenting with gc
	use("numToStr/Comment.nvim")

	-- file explorer
	use("nvim-tree/nvim-tree.lua")

	-- fuzzy finding w/ telescope
	use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" }) -- dependency for better sorting performance
	use { 'nvim-telescope/telescope.nvim', tag = '0.1.1',
  		requires = { {'nvim-lua/plenary.nvim'} }
	}

	-- autocompletion
	use("hrsh7th/nvim-cmp")
	use("hrsh7th/cmp-buffer")
	use("hrsh7th/cmp-path")

	-- snippets
	use("L3MON4D3/LuaSnip")
	use("saadparwaiz1/cmp_luasnip")
	use("rafamadriz/friendly-snippets")

	if packer_bootstrap then
    	require("packer").sync()
	end
end,
	config = {
    	max_jobs = 16,
    	git = {
    		-- default_url_format = "https://hub.fastgit.xyz/%s",
    		-- default_url_format = "https://mirror.ghproxy.com/https://github.com/%s",
    		-- default_url_format = "https://gitcode.net/mirrors/%s",
    		default_url_format = "https://gitclone.com/github.com/%s",
    	},

	},
})
