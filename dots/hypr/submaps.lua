hl.bind("CTRL + space", hl.dsp.submap("main"), { description = "Enter main submap" })

-- Runs dispatcher then resets the submap, for one-shot binds (main/fullscreen)
-- that should drop back to the global keymap right after the action.
local function exit_after(dispatcher)
	return function()
		hl.dispatch(dispatcher)
		hl.dispatch(hl.dsp.submap("reset"))
	end
end

local function bind_master_moves(exit_submap)
	local wrap = exit_submap and exit_after or function(dispatcher)
		return dispatcher
	end

	hl.bind("c", wrap(hl.dsp.window.close()), { description = "Close active window" })

	hl.bind("h", wrap(hl.dsp.layout("focusmaster master")), { description = "Focus master window" })
	hl.bind("j", wrap(hl.dsp.layout("cyclenext")), { description = "Focus next window" })
	hl.bind("k", wrap(hl.dsp.layout("cycleprev")), { description = "Focus previous window" })
	hl.bind("l", wrap(hl.dsp.focus({ urgent_or_last = true })), { description = "Focus urgent or last window" })
	hl.bind("comma", wrap(hl.dsp.focus({ workspace = "r-1" })), { description = "Focus previous workspace" })
	hl.bind("period", wrap(hl.dsp.focus({ workspace = "r+1" })), { description = "Focus next workspace" })
	hl.bind("m", wrap(hl.dsp.focus({ monitor = "+1" })), { description = "Focus next monitor" })

	hl.bind(
		"SHIFT + h",
		wrap(hl.dsp.layout("swapwithmaster ignoremaster")),
		{ description = "Swap active window with master" }
	)
	hl.bind("SHIFT + j", wrap(hl.dsp.layout("swapnext")), { description = "Swap with next window" })
	hl.bind("SHIFT + k", wrap(hl.dsp.layout("swapprev")), { description = "Swap with previous window" })
	hl.bind(
		"SHIFT + comma",
		wrap(hl.dsp.window.move({ workspace = "r-1", follow = true })),
		{ description = "Move window to previous workspace" }
	)
	hl.bind(
		"SHIFT + period",
		wrap(hl.dsp.window.move({ workspace = "r+1", follow = true })),
		{ description = "Move window to next workspace" }
	)
	hl.bind(
		"SHIFT + m",
		wrap(hl.dsp.workspace.move({ monitor = "+1" })),
		{ description = "Move workspace to next monitor" }
	)

	for i = 1, 9 do
		local ws = tostring(i)
		hl.bind(ws, wrap(hl.dsp.focus({ workspace = ws })), { description = "Focus workspace " .. ws })
		hl.bind(
			"SHIFT + " .. ws,
			wrap(hl.dsp.window.move({ workspace = ws, follow = true })),
			{ description = "Move window to workspace " .. ws }
		)
	end
end

hl.define_submap("main", function()
	hl.bind("space", hl.dsp.submap("repeat"), { description = "Enter repeat submap" })
	hl.bind("f", hl.dsp.submap("fullscreen"), { description = "Enter fullscreen submap" })
	hl.bind("o", exit_after(hl.dsp.exec_cmd(os.getenv("APP_MENU_DRUN"))), { description = "Open app launcher" })

	-- main is one-shot: every action below drops back to the global keymap.
	bind_master_moves(true)

	hl.bind("escape", hl.dsp.submap("reset"), { description = "Exit submap" })

	-- Any unbound key exits back to the global keymap.
	-- release: true, else catchall fires on a modifier's own keydown
	-- (e.g. SHIFT) before the full SHIFT+<key> combo registers. See
	-- https://github.com/hyprwm/Hyprland/issues/5073
	hl.bind("catchall", hl.dsp.submap("reset"), { description = "Exit submap", release = true })
end)

hl.define_submap("repeat", function()
	hl.bind("space", hl.dsp.submap("reset"), { description = "Exit submap" })
	hl.bind("escape", hl.dsp.submap("reset"), { description = "Exit submap" })
	-- repeat stays open: chain as many actions as you want, exit manually.
	bind_master_moves(false)
end)

hl.define_submap("fullscreen", function()
	hl.bind(
		"f",
		exit_after(hl.dsp.window.fullscreen({ mode = "fullscreen" })),
		{ description = "Toggle fullscreen" }
	)
	hl.bind(
		"m",
		exit_after(hl.dsp.window.fullscreen({ mode = "maximized" })),
		{ description = "Toggle maximize" }
	)
	hl.bind("j", exit_after(hl.dsp.window.float()), { description = "Toggle floating" })

	hl.bind("escape", hl.dsp.submap("reset"), { description = "Exit submap" })

	-- Any unbound key exits back to the global keymap. release: true, see
	-- the "main" submap's catchall above for why.
	hl.bind("catchall", hl.dsp.submap("reset"), { description = "Exit submap", release = true })
end)
