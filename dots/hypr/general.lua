hl.config({
	general = {
		border_size = 3,
		gaps_in = 3,
		gaps_out = 5,
		resize_on_border = true,
		layout = "master",
	},
	decoration = {
		border_part_of_window = false,
		dim_inactive = true,
		rounding = 10,
		blur = {
			enabled = false,
			passes = 4,
			xray = true,
		},
		shadow = { enabled = false },
	},
	misc = {
		allow_session_lock_restore = true,
		disable_hyprland_logo = true,
		disable_splash_rendering = true,
		middle_click_paste = false,
		mouse_move_focuses_monitor = false,
	},
	binds = {
		hide_special_on_workspace_change = true,
	},
})
