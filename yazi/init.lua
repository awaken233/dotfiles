-- ~/.config/yazi/init.lua

-- 状态栏美化
require("yaziline"):setup {
	separator_style = "curvy",
	select_symbol = "",
	yank_symbol = "󰆐",
	filename_max_length = 24,
	filename_trim_length = 6
}

-- Starship 风格路径栏
require("starship"):setup()

-- Git 状态显示
require("git"):setup()

-- 状态栏显示文件所有者
Status:children_add(function()
	local h = cx.active.current.hovered
	if h == nil or ya.target_family() ~= "unix" then
		return ui.Line {}
	end
	return ui.Line {
		ui.Span(ya.user_name(h.cha.uid) or tostring(h.cha.uid)):fg("magenta"),
		ui.Span(":"),
		ui.Span(ya.group_name(h.cha.gid) or tostring(h.cha.gid)):fg("magenta"),
		ui.Span(" "),
	}
end, 500, Status.RIGHT)

-- 书签管理 (yamb)
require("yamb"):setup {
	cli = "fzf",
}
