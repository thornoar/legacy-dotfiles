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

-- // VARIABLES // --

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.mapleader = ';'

autosave = true
autosavepattern = { '*.tex', '*.asy', '*.md', '*.lua', '*.cpp', '*.py', '*.hs', '*.txt', '*.lol', '*.r', '*.snippets' }
newcmd = function (name, command)
	vim.api.nvim_create_user_command(name, command, {})
end
km = vim.keymap

-- // PLUGINS // --

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
	-- 'nvim-tree/nvim-tree.lua',
	'neovimhaskell/haskell-vim',
	'nvim-lualine/lualine.nvim',
	'archibate/lualine-time',
	'dkarter/bullets.vim',
	-- 'cljoly/telescope-repo.nvim',
	'folke/zen-mode.nvim',
	'numToStr/Comment.nvim',

	{
		'windwp/nvim-autopairs',
		event = 'InsertEnter',
		opts = {}
	},

	{
		'navarasu/onedark.nvim',
		priority = 1000,
	},

	{
		'lukas-reineke/indent-blankline.nvim',
		main = 'ibl',
		opts = {},
	},

	{
		'nvim-telescope/telescope-file-browser.nvim',
		dependencies = { 'nvim-telescope/telescope.nvim', 'nvim-lua/plenary.nvim' }
	},

	{
		'AckslD/nvim-neoclip.lua',
		config = function() require('neoclip').setup() end,
	},

	{ 'nvim-telescope/telescope.nvim', branch = '0.1.x', dependencies = { 'nvim-lua/plenary.nvim' } },

	{
		'nvim-treesitter/nvim-treesitter',
		dependencies = {
			'nvim-treesitter/nvim-treesitter-textobjects',
		},
		build = ':TSUpdate',
	},
}, {})

-- // SETUP // --

require('commands')
require('keymaps')

require('telescope_setup')
require('rest_setup')

require('settings')

local sub_file_count = 0
local create_subfile_dir = false
local subfile_dir = 'subfiles'

local figure_count = 0
local create_figure_dir = true
local figure_dir = 'figures'
local default_in_format = 'asy'
local default_out_format = 'pdf'
local default_env = 'figure'
local default_width_in = '4'
local default_pos = ''

local jump_to_file = false

mysplit = function (str, delim)
	if #str == 0 then return {''} end
	local lastpos = (str:reverse()):find(delim)
	if not lastpos then
		return {str}
	end
	lastpos = (-lastpos) % #str + 1
	print(str)
	-- print(lastpos)
	-- print(str:sub(lastpos+1))
	local res = mysplit(str:sub(1, lastpos-1), delim)
	table.insert(res, str:sub(lastpos+1))
	return res
end

getargs = function (args, delim)
	delim = delim or '%s'
	local rargs = mysplit(args['args'], delim)
	for key,val in pairs(rargs) do
		if #rargs[key] == 0 then rargs[key] = nil end
	end
	return rargs
end

local figure_template = function (name, ftin, ftout, width_in)
	if (ftin == 'asy') then
		return {
			'size('..width_in..' in)',
			'settings.outformat = \"'..ftout..'\"',
			'//|return|[../'..vim.fn.expand("%:t")..']',
		}
	elseif (ftin == 'r') then
		return {
			ftout..'(\"'..name..'.'..ftin..'\", width = '..width_in..')',
		}
	end
end

vim.api.nvim_create_user_command('SF', function (args)
	local rargs = getargs(args, '%.')
	local dir = (rargs[1] or subfile_dir)..'/'
	local name = rargs[2]
	if (not name) then
		sub_file_count = sub_file_count + 1
		name = 'sub-'..vim.fn.expand('%:r')..'-'..tostring(sub_file_count)
	end
	name = name..'.tex'
	vim.fn.append(vim.fn.line('.')-1, '\\subfile{'..dir..name..'}')
	vim.fn.append(vim.fn.line('.')-1, '%|sub|['..dir..name..']')
	print (dir..name)
	if vim.fn.filereadable(dir..name) == 1 then
		vim.cmd('find '..dir..name)
		return
	end
	local parent = nil
	for i = 1,1,vim.fn.line('$') do
		local line = vim.fn.getline(i);
		if string.find(line, '\\documentclass') then
			local class = line:match('%{.+%}')
			if (class == '{subfiles}') then
				local opts = line:match('%[.+%]')
				if opts then
					parent = opts:sub(2, #opts-1)
				else
					print('please specify path to main document in the preamble')
					return
				end
			else
				parent = '../'..vim.fn.expand('%:t')
			end
		end
	end
	if vim.fn.isdirectory(dir) == 0 then os.execute('mkdir '..dir) end
	vim.cmd('edit '..dir..name)
	vim.fn.append(vim.fn.line('.'), '\\end{document}')
	vim.fn.append(vim.fn.line('.'), '')
	vim.fn.append(0, '')
	vim.fn.append(0, '\\begin{document}')
	vim.fn.append(0, '\\documentclass['..parent..']{subfiles}')
	vim.cmd('silent write')
	if not jump_to_file then vim.cmd('b#') end
end, { nargs = '?' })

vim.api.nvim_create_user_command('Fig', function (args)
	local rargs = getargs(args, '%.')
	for key,val in pairs(rargs) do
		print(key, val)
	end
	local name = rargs[1]
	if not name then
		figure_count = figure_count + 1
		name = 'fig-'..vim.fn.expand('%:r')..'-'..tostring(figure_count)
	end
	local ftin = rargs[2] or default_in_format
	local ftout = rargs[3] or default_out_format
	local env = rargs[4] or default_env
	local width_in = rargs[5] or default_width_in
	local pos = rargs[6] or default_pos
	print('name : '..name)
	local templ = figure_template(name, ftin, ftout, width_in)
end, { nargs = '?' })

km.set('n', 'sf', ':SF<CR>:b#<CR>')

km.set('n', 's<Left>', 'gg0f[gf')
km.set('n', 's<Down>', '/|sub|<CR>f[gf')
km.set('n', 's<Up>', '?|sub|<CR>f[gf')
km.set('n', 'S<Left>', 'gg0f[<C-w>f')
km.set('n', 'S<Down>', '/|sub|<CR>f[<C-w>f')
km.set('n', 'S<Up>', '?|sub|<CR>f[<C-w>f')

km.set('n', 'f<Left>', 'gg0f[gf')
km.set('n', 'f<Down>', '/|fig|<CR>f[gf')
km.set('n', 'f<Up>', '?|fig|<CR>f[gf')
km.set('n', 'F<Left>', 'gg0f[<C-w>f')
km.set('n', 'F<Down>', '/|fig|<CR>f[<C-w>f')
km.set('n', 'F<Up>', '?|fig|<CR>f[<C-w>f')

km.set('n', 'sd<Down>', '/|sub|<CR>f[:silent !rm <C-r><C-f><CR>dk')
km.set('n', 'sd<Up>', '?|sub|<CR>f[:silent !rm <C-r><C-f><CR>dk')
km.set('n', 'fd<Down>', '/|fig|<CR>f[:silent !rm <C-r><C-f><CR>')
km.set('n', 'fd<Up>', '?|fig|<CR>f[:silent !rm <C-r><C-f><CR>')

km.set('n', '<S-Left>', '<C-^>')
km.set('n', '<C-M-Right>', '<C-w>f')
km.set('n', '<S-Right>', 'gf')
