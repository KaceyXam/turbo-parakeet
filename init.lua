vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Editor Options
vim.opt.nu = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.scrolloff = 8

-- Initalizing Lazy Plugin Manager
local lazypath = vim.fn.stdpath("data") .. "lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then 
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	{ 
		"ellisonleao/gruvbox.nvim", 
		priority = 1000,
		config = function()
			vim.cmd([[colorscheme gruvbox]])

			vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
			vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
		end
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate"
	},
    {
        "nvim-lualine/lualine.nvim",
    },
    {
        "williamboman/mason.nvim",
        build = ":MasonUpdate", -- :MasonUpdate updates registry contents
        ensure_installed = {
            "rust-analyzer",
            "ols",
        }
    },
    { "williamboman/mason-lspconfig.nvim" },
    { 
        "neovim/nvim-lspconfig",
        config = function()
        end
    },
    { "hrsh7th/nvim-cmp" },
    { "L3MON4D3/LuaSnip" },
    { 'saadparwaiz1/cmp_luasnip' },
    { "hrsh7th/cmp-nvim-lsp" },
    {
        "nvim-lua/plenary.nvim",
    },
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.1",
    }
})

-- Treesitter Setup
require'nvim-treesitter.configs'.setup {
  ensure_installed = { "lua", "rust", "odin", "go" },

  sync_install = false,

  auto_install = true,

  highlight = {
    enable = true,

    disable = function(lang, buf)
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
            return true
        end
    end,

    additional_vim_regex_highlighting = false,
  },
}

-- Lualine Setup
require("lualine").setup {
    options = { theme = "gruvbox" }
}

-- Lsp setup
require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = { "lua_ls", "ols", "rust_analyzer" }
})

local on_attach = function(_, _)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, {})
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, {})

    vim.keymap.set('n', 'K', vim.lsp.buf.hover, {}) 
    vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references, {}) 
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, {}) 
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})

end

local capabilities = require("cmp_nvim_lsp").default_capabilities()

require("lspconfig").lua_ls.setup {
    on_attach = on_attach,
    capabilities = capabilities,
}

require("lspconfig").ols.setup({
    on_attach = on_attach,
    capabilities = capabilities,
})

require("lspconfig").rust_analyzer.setup({
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        ['rust-analyzer'] = {
            cargo = {
                allFeatures = true,
            },
        }
    }
})

-- Nvim CMP setup
local cmp = require("cmp")
cmp.setup({
    snippet = {
        expand = function(args)
            require("luasnip").lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
    }),
    sources = cmp.config.sources({
        { name = "nvim_lsp" },
    }, {
        { name = "buffer" },
    }),
})

-- Telescope Setup
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
