hl.bind("SUPER + O", hl.dsp.exec_cmd(os.getenv("APP_MENU_DRUN")), { description = "Open app launcher" })
hl.bind(
	"SUPER + T",
	hl.dsp.exec_cmd(os.getenv("APP_RUNNER") .. os.getenv("TERMINAL")),
	{ description = "Open terminal" }
)
hl.bind(
	"SUPER + B",
	hl.dsp.exec_cmd(os.getenv("APP_RUNNER") .. os.getenv("BROWSER")),
	{ description = "Open browser" }
)

hl.bind(
	"XF86MonBrightnessUp",
	hl.dsp.exec_cmd(os.getenv("INCREASE_BRIGHTNESS")),
	{
		locked = true,
		repeating = true,
		submap_universal = true,
		ignore_mods = true,
		description = "Increase screen brightness",
	}
)
hl.bind(
	"XF86MonBrightnessDown",
	hl.dsp.exec_cmd(os.getenv("DECREASE_BRIGHTNESS")),
	{
		locked = true,
		repeating = true,
		submap_universal = true,
		ignore_mods = true,
		description = "Decrease screen brightness",
	}
)

hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_SINK@ 5%+"),
	{
		locked = true,
		repeating = true,
		submap_universal = true,
		ignore_mods = true,
		description = "Raise volume",
	}
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_SINK@ 5%-"),
	{
		locked = true,
		repeating = true,
		submap_universal = true,
		ignore_mods = true,
		description = "Lower volume",
	}
)

hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_SINK@ toggle"),
	{ locked = true, submap_universal = true, ignore_mods = true, description = "Toggle mute" }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_SOURCE@ toggle"),
	{ locked = true, submap_universal = true, ignore_mods = true, description = "Toggle mic mute" }
)

hl.bind(
	"XF86AudioPrev",
	hl.dsp.exec_cmd("playerctl previous"),
	{ locked = true, submap_universal = true, ignore_mods = true, description = "Previous track" }
)
hl.bind(
	"XF86AudioNext",
	hl.dsp.exec_cmd("playerctl next"),
	{ locked = true, submap_universal = true, ignore_mods = true, description = "Next track" }
)
hl.bind(
	"XF86AudioPlay",
	hl.dsp.exec_cmd("playerctl play-pause"),
	{ locked = true, submap_universal = true, ignore_mods = true, description = "Play/pause track" }
)
