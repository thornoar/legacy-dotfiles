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
km.set('n', '<leader>zc', updatecomment)
newcmd('AC', function ()
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
