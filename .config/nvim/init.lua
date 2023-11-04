--[[--
 
   ▄███████▄                  ▄██████▄      ▄██████▄      ▄██████▄      ▄██████▄      ▄██████▄
 ▄█████████▀▀               ▄█▀████▀███▄  ▄██████████▄  ▄██████████▄  ▄██████████▄  ▄███▀████▀█▄
 ███████▀      ▄▄  ▄▄  ▄▄   █▄▄███▄▄████  ███ ████ ███  ███ ████ ███  ███ ████ ███  ████▄▄███▄▄█
 ███████▄      ▀▀  ▀▀  ▀▀   ████████████  ████████████  ████████████  ████████████  ████████████
 ▀█████████▄▄               ██▀██▀▀██▀██  ██▀██▀▀██▀██  ██▀██▀▀██▀██  ██▀██▀▀██▀██  ██▀██▀▀██▀██
   ▀███████▀                ▀   ▀  ▀   ▀  ▀   ▀  ▀   ▀  ▀   ▀  ▀   ▀  ▀   ▀  ▀   ▀  ▀   ▀  ▀   ▀

   ▄███████▄                  ▄██████▄      ▄██████▄      ▄██████▄      ▄██████▄      ▄██████▄
 ▄█████████▀▀               ▄█▀████▀███▄  ▄██ ████ ██▄  ▄██ ████ ██▄  ▄██ ████ ██▄  ▄███▀████▀█▄
 ███████▀      ▄▄  ▄▄  ▄▄   █▄▄███▄▄████  ████████████  ████████████  ████████████  ████▄▄███▄▄█
 ███████▄      ▀▀  ▀▀  ▀▀   ████████████  ████████████  ████████████  ████████████  ████████████
 ▀█████████▄▄               ██▀██▀▀██▀██  ██▀██▀▀██▀██  ██▀██▀▀██▀██  ██▀██▀▀██▀██  ██▀██▀▀██▀██
   ▀███████▀                ▀   ▀  ▀   ▀  ▀   ▀  ▀   ▀  ▀   ▀  ▀   ▀  ▀   ▀  ▀   ▀  ▀   ▀  ▀   ▀

--]]--

-- vim.g.loaded_netrw = 1
-- vim.g.loaded_netrwPlugin = 1
local km = vim.keymap
local newcmd = function (name, command)
	vim.api.nvim_create_user_command(name, command, {})
end
vim.g.mapleader = ';'

--# # # # # # # #-- 
--    $PLUGINS   --
--# # # # # # # #--

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system {
		'git',
		'clone',
		'--filter=blob:none',
		'https://github.com/folke/lazy.nvim.git',
		'--branch=stable', -- latest stable release
		lazypath,
	}
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
	'tpope/vim-fugitive',
	'tpope/vim-rhubarb',
	'tpope/vim-surround',
	'nanozuki/tabby.nvim',
	'lervag/vimtex',
	'farmergreg/vim-lastplace',
	-- 'Xe/lolcode.vim',
	'sirver/ultisnips',
	'nvim-tree/nvim-tree.lua',
	'neovimhaskell/haskell-vim',
	'nvim-lualine/lualine.nvim',
	'archibate/lualine-time',
	'dkarter/bullets.vim',
	-- 'cljoly/telescope-repo.nvim',

	{
		"AckslD/nvim-neoclip.lua",
		config = function() require('neoclip').setup() end,
	},

	{
		'windwp/nvim-autopairs',
		event = "InsertEnter",
		opts = {}
	},

	{
		'glepnir/dashboard-nvim',
		dependencies = {{'nvim-tree/nvim-web-devicons'}},
	},

	{
		'navarasu/onedark.nvim',
		priority = 1000,
	},

	{
		'lukas-reineke/indent-blankline.nvim',
		main = "ibl",
		opts = {},
	},

	{ 'numToStr/Comment.nvim', opts = {} },

	{ 'nvim-telescope/telescope.nvim', branch = '0.1.x', dependencies = { 'nvim-lua/plenary.nvim' } },

	{
		'nvim-treesitter/nvim-treesitter',
		dependencies = {
			'nvim-treesitter/nvim-treesitter-textobjects',
		},
		build = ':TSUpdate',
	},
}, {})

--# # # # # # # #--
--     $SETUP    --
--# # # # # # # #--

-- $Comment setup
require('Comment').setup({
    padding = true,
    sticky = true,
    toggler = {
        line = '<C-del>',
        block = '<S-del>',
    },
    opleader = {
        line = '<C-del>',
        block = '<S-del>',
    },
    extra = {
        above = 'gcO',
        below = 'gco',
        eol = 'gcA',
    },
    mappings = {
        basic = true,
        extra = true,
    },
    pre_hook = nil,
    post_hook = nil,
})
local ft = require('Comment.ft')
ft.set('asy', { '//%s', '/*%s*/' })
local autochange = true
local updatecomment = function ()
	local r, _ = unpack(vim.api.nvim_win_get_cursor(0))
	local strings = vim.api.nvim_buf_get_lines(0,0,r,true)
	for index = 1, #strings do
		local str = strings[#strings + 1 - index]
		if string.len(str) > 3 and string.sub(str, 0, 4) == '///<' then
			ft.set('tex', { '//%s', '/*%s*/' })
			return
		elseif string.len(str) > 3 and string.sub(str, 0, 4) == '///>' then
			ft.set('tex', '%%s')
			return
		end
	end
	ft.set('tex', '%%s')
end
vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
	pattern = '*.tex',
	callback = function ()
		if autochange then
			updatecomment()
		end
	end
})
vim.keymap.set('n', '<leader>zc', updatecomment)
newcmd('CC', function ()
	autochange = not autochange
	print('autochange: '..tostring(autochange))
end)

-- $nvim-tree setup
local function on_attach (bufnr)
	local api = require('nvim-tree.api')

	local function opts(desc)
		return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
	end

	km.set('n', '<M-Right>',				api.tree.change_root_to_node,      	   opts('CD'))
	km.set('n', 'i',						api.node.show_info_popup,              opts('Info'))
	km.set('n', '<C-r>',					api.fs.rename_sub,                     opts('Rename: Omit Filename'))
	km.set('n', '<C-t>',				    api.node.open.tab,                     opts('Open: New Tab'))
	km.set('n', '<C-v>',				    api.node.open.vertical,                opts('Open: Vertical Split'))
	km.set('n', '<C-x>',				    api.node.open.horizontal,              opts('Open: Horizontal Split'))
	km.set('n', '<Left>',  				function()
		api.node.navigate.parent_close()
		api.node.open.edit()
	end,  								   opts("Navigate Back"))
	km.set('n', '<Right>',  				api.node.open.edit,                    opts('Open'))
	km.set('n', '<Tab>', 					api.node.open.preview,                 opts('Open Preview'))
	km.set('n', '<C-Down>',     			api.node.navigate.sibling.next,        opts('Next Sibling'))
	km.set('n', '<C-Up>',					api.node.navigate.sibling.prev,   	   opts('Previous Sibling'))
	km.set('n', '.',    					api.node.run.cmd,                      opts('Run Command'))
	km.set('n', 'a',    					api.fs.create,                         opts('Create'))
	km.set('n', 'B',    					api.tree.toggle_no_buffer_filter,      opts('Toggle Filter: No Buffer'))
	km.set('n', 'zh',   					api.tree.toggle_hidden_filter,         opts('Toggle Filter: Dotfiles'))
	km.set('n', 'I',    					api.tree.toggle_gitignore_filter,      opts('Toggle Filter: Git Ignore'))
	km.set('n', 'c',    					api.fs.copy.node,                      opts('Copy'))
	km.set('n', 'C',    					api.tree.toggle_git_clean_filter,      opts('Toggle Filter: Git Clean'))
	km.set('n', '[c',   					api.node.navigate.git.prev,            opts('Prev Git'))
	km.set('n', ']c',   					api.node.navigate.git.next,            opts('Next Git'))
	km.set('n', 'd',    					api.fs.remove,                         opts('Delete'))
	km.set('n', 'D',    					api.fs.trash,                          opts('Trash'))
	km.set('n', 'E',    					api.tree.expand_all,                   opts('Expand All'))
	km.set('n', 'W',    					api.tree.collapse_all,                 opts('Collapse'))
	km.set('n', 'e',    					api.fs.rename_basename,                opts('Rename: Basename'))
	km.set('n', 'g?',   					api.tree.toggle_help,                  opts('Help'))
	km.set('n', 'gy',   					api.fs.copy.absolute_path,             opts('Copy Absolute Path'))
	km.set('n', 'r',    					api.fs.rename,                         opts('Rename'))
	km.set('n', 'R',    					api.tree.reload,                       opts('Refresh'))
	km.set('n', 's',    					api.node.run.system,                   opts('Run System'))
	km.set('n', 'S',    					api.tree.search_node,                  opts('Search'))
	km.set('n', 'U',    					api.tree.toggle_custom_filter,         opts('Toggle Filter: Hidden'))
	km.set('n', 'p',    					api.fs.paste,                          opts('Paste'))
	km.set('n', 'x',    					api.fs.cut,                            opts('Cut'))
	km.set('n', 'y',    					api.fs.copy.filename,                  opts('Copy Name'))
	km.set('n', 'Y',    					api.fs.copy.relative_path,             opts('Copy Relative Path'))
end
km.set('n', '<C-f>', function ()
	vim.cmd('NvimTreeToggle')
end)
require("nvim-tree").setup({
	actions = {
		open_file = {
			quit_on_open = true,
		},
	},
	renderer = {
		group_empty = true,
		icons = {
			symlink_arrow = " >> ",
			glyphs = {
				folder = {
					arrow_closed = " ",
					arrow_open = ">",
				},
			},
		},
	},
	update_cwd = true,
	update_focused_file = {
		enable = true,
		update_cwd = true,
	},
	filters = {
		dotfiles = true,
	},
	on_attach = on_attach
})

-- $tabby setup
local theme = {
	fill = 'TabLineFill',
	head = 'TabLine',
	current_tab = { fg = '#000000', bg = '#89a870', style = 'italic' },--'TabLineSel',
	tab = 'TabLine',
	win = 'TabLine',
	tail = 'TabLine',
}
require('tabby.tabline').set(function(line)
	return {
		line.tabs().foreach(function(tab)
			local hl = tab.is_current() and theme.current_tab or theme.tab
			return {
				line.sep('', hl, theme.fill),
				-- tab.is_current() and '' or '󰆣',
				tab.name(),
				line.sep('', hl, theme.fill),
				hl = hl,
				margin = ' ',
			}
		end),
	}
end)


-- $dashboard setup
vim.g.dashboard_default_executive = 'telescope'
require('dashboard').setup({
	theme = 'hyper',
	event = 'VimEnter',
	config = {
		packages = {enable = true},
		header = {
			[[                                   ░▓▓                                 ]],
			[[                                ▓▓▓▓▓▓▓▓▓                              ]],
			[[                         ▓░  ▓▓▓▓▓▓▓▓▓▓▓                               ]],
			[[                       ▓▓▓  ▓▓▓▓▓▓▓▓▓▓▓▓                               ]],
			[[                 ▓    ▓▓▓   ▓▒      ░▓▓▓▓▓                             ]],
			[[               ▒▓▓   ▓▓▓▓          ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▒                 ]],
			[[               ▓▓▓  ▓▓▓▓▓   ▓▓▓   ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓             ]],
			[[               ▓▓▓▓▒▓▓▓▓▓ ▓▓▓▓▒   ▓▓░      ▒▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓           ]],
			[[              ▒▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓                   ▒▓▓▓▓▓▓▓▓▓▓▓          ]],
			[[              ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓   ░▓▓▓▓     ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓         ]],
			[[              ▓▓▓▓▓   ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓    ▓▓▓▓▓▓▓▓▓▓          ▓         ]],
			[[              ▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓   ▒▓▓▓▓▓▓▓▓▓▓▓                     ]],
			[[             ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓   ░▓▓▓▓▓▓▓▓▓▓▓                    ]],
			[[            ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓   ▓▓▓▓▓▓▓▓▓▓▓                   ]],
			[[     ▓     ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓   ▓▓▓▓▓▓▓▓▓▓▓▓▓                ]],
			[[    ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░   ▓▓▓▓▓▓▓▓▓▒           ▓▓▓▓▓▓▓▓▓▓▓▓              ]],
			[[     ▓▓▓▓▓▓▓▓▓▓▓▓▓▓     ▓▓▓▓▓▓▓     ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓            ]],
			[[     ▓▓▓▓▓▓▓▓▓▓▓▓       ▓▓▓▓▓░    ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓           ]],
			[[      ▓▓▓▓▓ ▓▓        ▓▓▓▓▓▓▓         ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▒          ]],
			[[        ▓▓▓       ▓▓▓▓▓▓▓▓▓▓            ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓           ]],
			[[                ▓▓▓▓▓▓▓  ▒▓▓            ▓▓▓▓▓▓▓▓▓▓▓▓      ▓▓           ]],
			[[             ▓▓▓▓▓▓▓▓                  ▓▓▓▓▓▓▓▓▓▓▓▓                    ]],
			[[               ▓▓▓▓▓▓                ▓▓▓▓▓▓▓▓▓▓▓▓▓▓                    ]],
			[[                  ▓▓▓▓▓          ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓                    ]],
			[[                            ░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓                   ]],
			[[																		]],
			[[																		]],
		},
		footer = {
			[[]],
			[[]],
			[[You wanna do something already?]]
		},
		shortcut = {
			{ desc = '󰊳 Update', group = '@property', action = 'Lazy update', key = 'u' },
			{
				desc = ' Files',
				group = 'Label',
				action = 'Telescope find_files hidden=true',
				key = '/',
			},
			{
				desc = ' Config',
				group = 'Label',
				action = 'edit ~/.config/nvim/init.lua',
				key = 'c',
			},
		},
	},
})

-- $telescope setup
require('telescope').setup {
	defaults = {
		mappings = {
			i = {
				['<C-u>'] = false,
				['<C-d>'] = false,
			},
		},
	},
}
-- pcall(require'telescope'.load_extension, 'repo')
pcall(require'telescope'.load_extension, 'neoclip')
km.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
km.set('n', '<leader>b', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
km.set('n', '<leader>sa', function()
	require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
		previewer = false,
	})
end, { desc = '[/] Fuzzily search in current buffer' })
km.set('n', 'tb', require('telescope.builtin').builtin, { desc = '[T]elescope [B]uiltin' })
-- km.set('n', '<leader>gf', require('telescope').extensions.repo.list, { desc = 'Search [G]it [F]iles' })
km.set('n', '<leader>cv', require('telescope').extensions.neoclip['a'], { desc = 'Search Clipboard' })
km.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
km.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
km.set('n', '<leader>sw', require'telescope.builtin'.grep_string, { desc = '[S]earch current [W]ord' })
km.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
km.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
km.set('n', '<leader>ds', require('telescope.builtin').jumplist, { desc = '[D]jump [S]earch' })

-- $treesitter setup
require('nvim-treesitter.configs').setup {
	modules = {},
	sync_install = true,
	ignore_install = {},
	ensure_installed = { 'cpp', 'lua', 'python', 'vimdoc', 'vim' },
	highlight = { enable = true },
	indent = { enable = false },
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = '<c-space>',
			node_incremental = '<c-space>',
			scope_incremental = '<c-s>',
			node_decremental = '<M-space>',
		},
	},
}

local function keymap()
	if vim.opt.iminsert:get() > 0 and vim.b.keymap_name then
		return vim.b.keymap_name
	end
	return 'en'
end


-- $lualine setup
require('lualine').setup{
	options = {
		icons_enabled = true,
		theme = 'onedark',
		component_separators = '|',
		section_separators = '',
	},
	sections = {
		lualine_a = {'mode'},
		lualine_b = {'branch', 'diff', 'diagnostics'},
		lualine_c = {'filename', keymap},
		lualine_x = {'cdate', 'ctime', 'filetype'},
		lualine_y = {'progress'},
		lualine_z = {'location'},
	},
}

require('onedark').setup  {
	style = 'dark',
	transparent = false,  -- Show/hide background
	term_colors = true, -- Change terminal color as per the selected theme style
	ending_tildes = false, -- Show the end-of-buffer tildes. By default they are hidden
	cmp_itemkind_reverse = false, -- reverse item kind highlights in cmp menu
	toggle_style_key = "<leader>wt",
	toggle_style_list = {'dark', 'darker', 'cool', 'deep', 'warm', 'warmer', 'light'},
	code_style = {
		comments = 'italic',
		keywords = 'none',
		functions = 'none',
		strings = 'none',
		variables = 'none'
	},
	lualine = {
		transparent = false,
	},
	colors = {},
	highlights = {},
	diagnostics = {
		darker = true,
		undercurl = true,
		background = true,
	},
}

require 'ibl'.setup({
	indent = {
		char = '┊',
	},
	whitespace = {
		remove_blankline_trail = true,
	},
	-- char = ,
	-- show_trailing_blankline_indent = false,
})

vim.cmd.colorscheme 'onedark'

--# # # # # # # #--
--   $SETTINGS   --
--# # # # # # # #--

vim.o.swapfile = false
vim.o.wrap = true
vim.o.linebreak = true
vim.o.list = false
vim.o.breakat = '   '
vim.opt.autochdir=true
vim.o.shell = '/bin/zsh'
vim.o.hlsearch = false
vim.wo.number = true
vim.wo.relativenumber = true
vim.o.mouse = 'a'
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.wo.signcolumn = 'yes'
vim.o.updatetime = 700
vim.o.timeout = false
vim.o.completeopt = 'menuone,noselect'
vim.o.termguicolors = true
vim.o.cmdheight = 1
vim.o.ruler = false
vim.o.termguicolors = true
vim.o.scrolloff = 5
vim.o.colorcolumn = 20
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.compatible = false
vim.o.cursorline = true

-- $highlight settings
vim.cmd(
[[
highlight Function guifg=burlywood
highlight Number guifg=lightsteelblue
highlight Include guifg=orchid
highlight Type guifg=lightseagreen
highlight Constant guifg=palevioletred gui=italic cterm=italic
highlight Operator guifg=aquamarine
highlight Keyword guifg=plum
]])
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
	callback = function()
		vim.highlight.on_yank()
	end,
	group = highlight_group,
	pattern = '*',
})

vim.g.haskell_classic_highlighting = 1

-- $nvim-tree settings
vim.g.nvim_tree_quit_on_open = 1
vim.g.nvim_tree_indent_markers = 1
vim.g.nvim_tree_git_hl = 1
vim.g.nvim_tree_highlight_opened_files = 1
vim.g.nvim_tree_root_folder_modifier = ':~'
vim.g.nvim_tree_add_trailing = 1
vim.g.nvim_tree_group_empty = 1
vim.g.nvim_tree_icon_padding = ' '
vim.g.nvim_tree_symlink_arrow = ' >> '
vim.g.nvim_tree_respect_buf_cwd = 1
vim.g.nvim_tree_create_in_closed_folder = 0
vim.g.nvim_tree_refresh_wait = 500

-- $vimtex settings
vim.g.vimtex_quickfix_enabled = 0
vim.g.vimtex_view_method = 'zathura'
vim.g.latex_view_general_viewer = 'zathura'
vim.g.vimtex_compiler_progname = 'nvr'
vim.g.vimtex_view_general_options = '-reuse-instance -forward-search @tex @line @pdf'
vim.g.vimtex_view_automatic = 1
vim.g.vimtex_mappings_prefix = '\\'
-- vim.cmd([[let g:vimtex_compiler_latexmk = {'continuous': 0}]])
-- vim.o.conceallevel = 1
-- vim.g.tex_conceal = 'abdmg'
-- vim.cmd('hi Conceal ctermbg=none')

vim.g.UltiSnipsExpandTrigger='<tab>'
vim.g.UltiSnipsJumpForwardTrigger='`'
vim.g.UltiSnipsJumpBackwardTrigger='<C-`>'
vim.g.UltiSnipsEditSplit='vertical'

-- $autosave settings
local autosave = true
newcmd("AS", function() autosave = not autosave end)
local autosavepattern = { '*.tex', '*.asy', '*.md', '*.lua', '*.cpp', '*.py', '*.hs', '*.txt', '*.lol', '*.r' }
vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI', 'TextChangedP' }, {
	pattern = autosavepattern,
	callback = function()
		if autosave then vim.cmd('silent write') end
	end
})

-- $spellcheck settings
vim.api.nvim_create_autocmd({'BufRead', 'BufNewFile'}, {
	pattern = {'*.md', '*.txt'},
	command = 'setlocal spell! spelllang=en_us'
})

-- $markdown settings
--vim.o.vim_markdown_folding_disabled = 1
vim.o.vim_markdown_folding_level = 6
vim.o.vim_markdown_folding_style_pythonic = 1

--# # # # # # # #--
--   $MAPPING    --
--# # # # # # # #--

local home = '/home/ramak/projects'
local scriptdir = home..'/scripts'
local testdir = '/home/ramak/projects/sandbox/'

-- $commands

local emptycompile = 'echo \"not set to compile\"';
local compilecmd = {
	['asy'] = 'asy -nosafe -noV',
	['r'] = 'Rscript',
	['py'] = 'python',
	['c'] = 'gcc',
	['cpp'] = 'g++ -o cpp.out',
	['hs'] = 'ghc -o hs.out',
	['tex'] = 'latexmk -g -pdf',
	['lua'] = 'lua',
	['lol'] = 'lci',
}
local compilefunc = {
	['asy'] = function (name) return ('!asy -noV -nosafe ' .. name) end,
	['r'] = function (name) return ('!Rscript ' .. name) end,
	['python'] = function (name) return ('!python ' .. name) end,
	['c'] = function (name) return ('!gcc ' .. name .. ' && ./a.out') end,
	['cpp'] = function (name) return ('!g++ -Wall ' .. name .. ' -o cpp.out && ./cpp.out') end,
	['haskell'] = function (name) return ('!ghc ' .. name .. ' -o hs.out && ./hs.out') end,
	['tex'] = function (name) return ('!latexmk -g -pdf ' .. name) end,
	['lua'] = function (name) return ('!lua ' .. name) end,
	['lolcode'] = function (name) return ('!lci ' .. name) end,
}

newcmd('C', function () vim.cmd('tabclose') end)
newcmd('Compile', function () 
	local ccmd = compilefunc[vim.bo.filetype]
	vim.cmd(not ccmd and emptycompile or ccmd('%:t'))
end)
newcmd('CompileSilent', function () 
	local ccmd = compilefunc[vim.bo.filetype]
	vim.cmd(not ccmd and '' or 'silent '..ccmd('%:t'))
end)

vim.api.nvim_create_user_command('BC', function (ext)
	local cmd = compilecmd[ext['args']]
	if not cmd then
		print('invalid file extension provided')
	else
		vim.cmd('!'..scriptdir..'/bulkcompile.sh '..ext['args']..' '..'\"'..cmd..'\"')
	end
end, { nargs='?' })

local autocompile = false
local autocompilepattern = { '*.asy', '*.cpp', '*.tex', '*.hs' }
newcmd('AC', function ()
	autocompile = not autocompile
	print('autocompile: '..tostring(autocompile))
end)
vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
	pattern = autocompilepattern,
	callback = function ()
		if autocompile then vim.cmd('CompileSilent') end
	end
})

local defaultoutputname = 'output'
local don = function (name) defaultoutputname = name end

newcmd('View', function ()
	local file_exists_gif = io.open(defaultoutputname..'.gif', 'r') ~= nil
	local file_exists_pdf = io.open(defaultoutputname..'.pdf', 'r') ~= nil
	if file_exists_gif then
		vim.cmd('silent !sxiv -a '..defaultoutputname..'.gif&')
	elseif file_exists_pdf then
		vim.cmd('silent !zathura '..defaultoutputname..'.pdf&')
	else
		vim.cmd('silent !'..scriptdir..'/pdfviewall.sh')
		vim.cmd('silent !'..scriptdir..'/gifviewall.sh')
	end
end)
newcmd('ViewPdf', function ()
	if io.open(vim.fn.expand('%:r')..'.pdf', 'r') ~= nil then
		vim.cmd('silent !zathura %:r.pdf&')
	elseif io.open(defaultoutputname..'.pdf', 'r') ~= nil then
		vim.cmd('silent !zathura '..defaultoutputname..'.pdf&')
	else
		vim.cmd('silent !'..scriptdir..'/pdfviewall.sh')
	end
end)
newcmd('ViewGif', function ()
	if io.open(vim.fn.expand('%:r')..'.gif', 'r') ~= nil then
		vim.cmd('silent !sxiv -a %:r.gif&')
	elseif io.open(defaultoutputname..'.gif', 'r') ~= nil then
		vim.cmd('silent !sxiv -a '..defaultoutputname..'.gif&')
	else
		vim.cmd('silent !'..scriptdir..'/gifviewall.sh')
	end
end)
newcmd('Asytest', function ()
	local pwd = vim.fn.expand('%:p:h')
	vim.cmd('cd ' .. testdir)
	vim.cmd('!asy -noV ' .. testdir .. 'asytest.asy')
	vim.cmd('cd ' .. pwd)
end)
newcmd('AsytestSilent', function ()
	local pwd = vim.fn.expand('%:p:h')
	vim.cmd('cd ' .. testdir)
	vim.cmd('silent !asy -noV ' .. testdir .. 'asytest.asy')
	vim.cmd('cd ' .. pwd)
end)
newcmd('AsytestView', function ()
	local file_exists_gif = io.open(testdir .. 'asytest.gif', 'r') ~= nil
	local file_exists_pdf = io.open(testdir .. 'asytest.pdf', 'r') ~= nil
	if file_exists_gif then
		vim.cmd('silent !sxiv -a ' .. testdir .. 'asytest.gif&')
	elseif file_exists_pdf then
		vim.cmd('silent !zathura ' .. testdir .. 'asytest.pdf&')
	end
end)
newcmd('E', function () vim.o.keymap = '' end)
newcmd('R', function () vim.o.keymap = 'russian-jcuken' end)
newcmd('J', function () vim.o.keymap = 'kana' end)
newcmd('S', function () vim.o.spell = not vim.o.spell end)
newcmd('NS', function () vim.cmd('set nospell') end)

-- $keymaps
-- $visual keymaps
km.set('v', '<M-c>', 'ygv<Esc>')
km.set('v', '<Down>', ":m '>+1<CR>gv=gv")
km.set('v', '<Up>', ":m '<-2<CR>gv=gv")
km.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
km.set('v', '<C-c>', '\"+y')
km.set('v', '<C-x>', '\"+d')
km.set('v', 'z', '<esc>')
km.set('v', '<S-Up>', '<Up>')
km.set('v', '<S-Down>', '<Down>')
km.set('n', '<S-Down>', '<S-v>j')
km.set('n', '<S-Up>', '<S-v>k')
km.set('i', '<C-v>', '<CR><C-v>')
km.set('v', '<leader>a', ':s/\\d\\+/\\=(submatch(0)+1)/g')
-- $insert keymaps
km.set('n', 'x', 'i')
km.set('i', '<M-z>', '<C-n>')
km.set('i', '<C-z>', '<esc>:R<CR>a')
km.set('i', '<C-x>', '<esc>:E<CR>a')
km.set('i', '<M-s>', '<C-o>$;<CR>')
km.set('i', '<C-s>', '<C-o>o')
km.set('i', '<C-q>', '<Esc>[s1z=A')
-- $navigation keymaps
km.set('n', '<Up>', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
km.set('n', '<Down>', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
km.set('i', '<Up>', '<C-o>gk')
km.set('i', '<Down>', '<C-o>gj')
km.set('n', '<S-Right>', function () vim.cmd('tabn') end)
km.set('n', '<S-Left>', function () vim.cmd('tabp') end)
km.set('n', '<C-Left>', '<C-w>h')
km.set('n', '<C-Right>', '<C-w>l')
km.set('n', '<C-Up>', '<C-w>k')
km.set('n', '<C-Down>', '<C-w>j')
km.set('i', '<S-Left>', function () vim.cmd('tabp') end)
km.set('i', '<S-Right>', function () vim.cmd('tabn') end)
km.set('i', '<C-Up>', '<esc><C-w>ki')
km.set('i', '<C-Down>', '<esc><C-w>ji')
km.set('i', '<C-Left>', '<esc><C-w>hi')
km.set('i', '<C-Right>', '<esc><C-w>li')
km.set({'n', 'v'}, '<M-Up>', '10k')
km.set({'n', 'v'}, '<M-Down>', '10j')
km.set({'n', 'v'}, '<M-Left>', 'b')
km.set({'n', 'v'}, '<M-Right>', 'w')
km.set('i', '<M-Up>', '<esc>10ki')
km.set('i', '<M-Down>', '<esc>10ji')
km.set('i', '<M-Left>', '<esc>bi')
km.set('i', '<M-Right>', '<esc>wa')
km.set('n', '<C-M-Left>', '<C-^>')
km.set('n', '<C-M-Right>', 'gf')
km.set({'n', 'v'}, '<M-a>', '%')
km.set('n', 'n', 'nzz')
km.set('n', 'N', 'Nzz')
-- $window keymaps
km.set('n', '<C-S-Left>', '<C-w>H')
km.set('n', '<C-S-Right>', '<C-w>L')
km.set('n', '<C-S-Up>', '<C-w>K')
km.set('n', '<C-S-Down>', '<C-w>J')
km.set('n', '<M-s>', '<C-w>+')
km.set('n', '<M-d>', '<C-w>-')
km.set('n', '<M-z>', '<C-w>>')
km.set('n', '<M-x>', '<C-w><')
km.set('n', '<M-e>', '<C-w>=')
-- $text keymaps
km.set('n', '<M-v>', 'p')
km.set('n', '<M-c>', 'yy')
km.set('n', '<leader>cw', ":%s/\\<<C-r><C-w>\\>/")
km.set('n', 'cw', 'ciw')
km.set('n', '<C-z>', 'u')
km.set('x', '<leader>p', '\"_dP')
km.set('n', '<leader>f', 'zf%')
-- $command keymaps
km.set('n', '<leader>tr', function () vim.cmd('silent !alacritty&') end)
km.set('n', '<leader>l', function () vim.cmd('tabnew ~/.config/nvim/init.lua') end)
km.set('n', '<leader>o', ':Compile<CR>')
km.set('n', '<leader>k', function () vim.cmd('CompileSilent') end)
km.set('n', '<leader>vp', function () vim.cmd('ViewPdf') end)
km.set('n', '<leader>vg', function () vim.cmd('ViewGif') end)
km.set('n', '<leader>vv', function () vim.cmd('View') end)
km.set('n', '<leader>xo', ':Asytest<CR>')
km.set('n', '<leader>xk', function () vim.cmd('AsytestSilent') end)
km.set('n', '<leader>xv', function () vim.cmd('AsytestView') end)
km.set('n', '<leader>ee', function () vim.cmd('UltiSnipsEdit') end)
km.set('n', 'd[', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
km.set('n', 'd]', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
km.set('n', '<leader>de', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
km.set('n', '<leader>dq', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })
km.set('n', '<C-e>', function () vim.cmd('tabnew') end)
km.set('n', '<C-d>', function ()
	vim.cmd('silent tabonly')
	vim.cmd('cd ' .. home)
	vim.cmd('Dashboard')
end)
