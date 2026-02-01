local Settings = {}

-- UI / Keybind
Settings.OpenKey = Enum.KeyCode.RightShift

-- Limits (server clamps these)
Settings.Movement = {
	WalkSpeedMin = 8,
	WalkSpeedMax = 80,
	JumpPowerMin = 25,
	JumpPowerMax = 150,
}

-- Assist settings
Settings.Assist = {
	PickupRange = 10,          -- studs
	PickupTick = 0.12,         -- seconds between pickup attempts
	AutoDisableOnPlot = true,  -- client logic toggle supported
}

-- CollectionService tag used for "brainrots"
Settings.BrainrotTag = "Brainrot"

-- If your game has plot zones tagged with this, we can auto-disable on plot.
Settings.PlotZoneTag = "PlotZone"

return Settings
