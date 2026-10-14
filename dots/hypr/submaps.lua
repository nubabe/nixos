hl.bind("Control_L + SPACE", hl.dsp.submap("main"), { description = "Enter main submap" })

local function bind_master_moves()
	hl.bind("c", hl.dsp.window.close(), { description = "Close active window" })

	hl.bind("h", hl.dsp.layout("focusmaster master"), { description = "Focus master window" })
	hl.bind("j", hl.dsp.layout("cyclenext"), { description = "Focus next window" })
	hl.bind("k", hl.dsp.layout("cycleprev"), { description = "Focus previous window" })
	hl.bind("l", hl.dsp.focus({ urgent_or_last = true }), { description = "Focus urgent or last window" })
	hl.bind("comma", hl.dsp.focus({ workspace = "r-1" }), { description = "Focus previous workspace" })
	hl.bind("period", hl.dsp.focus({ workspace = "r+1" }), { description = "Focus next workspace" })
	hl.bind("m", hl.dsp.focus({ monitor = "+1" }), { description = "Focus next monitor" })

	hl.bind(
		"SHIFT + h",
		hl.dsp.layout("swapwithmaster ignoremaster"),
		{ description = "Swap active window with master" }
	)
	hl.bind("SHIFT + j", hl.dsp.layout("swapnext"), { description = "Swap with next window" })
	hl.bind("SHIFT + k", hl.dsp.layout("swapprev"), { description = "Swap with previous window" })
	hl.bind(
		"SHIFT + comma",
		hl.dsp.window.move({ workspace = "r-1", follow = true }),
		{ description = "Move window to previous workspace" }
	)
	hl.bind(
		"SHIFT + period",
		hl.dsp.window.move({ workspace = "r+1", follow = true }),
		{ description = "Move window to next workspace" }
	)
	hl.bind(
		"SHIFT + m",
		hl.dsp.workspace.move({ monitor = "+1" }),
		{ description = "Move workspace to next monitor" }
	)

	for i = 1, 9 do
		local ws = tostring(i)
		hl.bind(ws, hl.dsp.focus({ workspace = ws }), { description = "Focus workspace " .. ws })
		hl.bind(
			"SHIFT + " .. ws,
			hl.dsp.window.move({ workspace = ws, follow = true }),
			{ description = "Move window to workspace " .. ws }
		)
	end
end

hl.define_submap("main", function()
	hl.bind("SPACE", hl.dsp.submap("repeat"), { description = "Enter repeat submap" })
	hl.bind("f", hl.dsp.submap("fullscreen"), { description = "Enter fullscreen submap" })
	hl.bind("o", hl.dsp.exec_cmd(os.getenv("APP_MENU_DRUN")), { description = "Open app launcher" })

	bind_master_moves()

	-- Any unbound key exits back to the global keymap.
	hl.bind("catchall", hl.dsp.submap("reset"), { description = "Exit submap" })
end)

hl.define_submap("repeat", function()
	hl.bind("SPACE", hl.dsp.submap("reset"), { description = "Exit submap" })
	bind_master_moves()
end)

hl.define_submap("fullscreen", function()
	hl.bind("f", hl.dsp.window.fullscreen({ mode = "fullscreen" }), { description = "Toggle fullscreen" })
	hl.bind("m", hl.dsp.window.fullscreen({ mode = "maximized" }), { description = "Toggle maximize" })
	hl.bind("j", hl.dsp.window.float(), { description = "Toggle floating" })
end)
