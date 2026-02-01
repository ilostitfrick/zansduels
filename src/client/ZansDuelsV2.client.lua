local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local CollectionService = game:GetService("CollectionService")

local Settings = require(script.Parent.Parent.shared.SettingsSchema)
local Theme = require(script.Parent.Parent.ui.Theme)
local Components = require(script.Parent.Parent.ui.Components)

local player = Players.LocalPlayer
local Remote = ReplicatedStorage:WaitForChild("ZansPanelRemote")

-- UI root
local gui = Instance.new("ScreenGui")
gui.Name = "ZansPanel"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Main panel
local main = Components:Card(gui, UDim2.fromOffset(430, 470), UDim2.new(1, -18, 0.5, 0))
main.AnchorPoint = Vector2.new(1, 0.5)
main.Visible = false

Components:Label(main, "ZANS PANEL", 10, true)
Components:Label(main, "legit QoL (server-authoritative)", 32, false)

-- Two columns
local left = Instance.new("Frame")
left.BackgroundTransparency = 1
left.Size = UDim2.new(0.5, -10, 1, -90)
left.Position = UDim2.new(0, 0, 0, 55)
left.Parent = main

local right = Instance.new("Frame")
right.BackgroundTransparency = 1
right.Size = UDim2.new(0.5, -10, 1, -90)
right.Position = UDim2.new(0.5, 10, 0, 55)
right.Parent = main

-- ========= LEFT =========
Components:Label(left, "Movement", 0, true)

local wsState, setWS = Components:Slider(left, "Boost Speed", 22, 8, 80, 16)
local jpState, setJP = Components:Slider(left, "Hop Power", 78, 25, 150, 50)

local autoDisableState, setAutoDisable = Components:Toggle(left, "Auto Disable on Plot", 132)
setAutoDisable(true)

local antiRagdollState, setAntiRagdoll = Components:Toggle(left, "Anti Ragdoll", 160)
local unwalkState, setUnwalk = Components:Toggle(left, "Unwalk (freeze self)", 188)

-- “SpinBot” in video -> legit cosmetic spin (client-only)
local spinState, setSpin = Components:Toggle(left, "Spin (cosmetic)", 216)

-- ========= RIGHT =========
Components:Label(right, "Assist / Visual", 0, true)

local pickupState, setPickup = Components:Toggle(right, "Pickup Assist (legit)", 22)
local stealSpeedState, setStealSpeed = Components:Toggle(right, "Speed While Stealing", 50)

-- “Optimizer + XRay” -> legit optimizer + dev highlight
local optimizerState, setOptimizer = Components:Toggle(right, "Optimizer", 78)
local highlightState, setHighlight = Components:Toggle(right, "Highlight Tagged Items", 106)

-- “Galaxy Mode” + “Galaxy Sky Bright” -> cosmetic lighting
local galaxyState, setGalaxy = Components:Toggle(right, "Galaxy Mode", 134)
local skyBrightState, setSkyBright = Components:Toggle(right, "Galaxy Sky Bright", 162)

-- “Auto Left/Right” -> accessibility strafe assist (only moves like holding A/D)
local leftStrafeState, setLeftStrafe = Components:Toggle(right, "Auto Left (hold)", 190)
local rightStrafeState, setRightStrafe = Components:Toggle(right, "Auto Right (hold)", 218)

-- Save button (local only)
local saveBtn = Components:Button(main, "SAVE CONFIG", UDim2.new(1, -20, 0, 40), UDim2.new(0, 10, 1, -48))

-- ====== local helpers ======
local highlights = {}
local function clearHighlights()
	for _, h in pairs(highlights) do
		if h then h:Destroy() end
	end
	table.clear(highlights)
end

local function applyHighlights()
	clearHighlights()
	for _, inst in ipairs(CollectionService:GetTagged(Settings.BrainrotTag)) do
		local h = Instance.new("Highlight")
		h.FillTransparency = 0.75
		h.OutlineTransparency = 0.15
		h.Parent = inst
		highlights[inst] = h
	end
end

local savedLighting = {
	Ambient = Lighting.Ambient,
	Brightness = Lighting.Brightness,
	OutdoorAmbient = Lighting.OutdoorAmbient,
	GlobalShadows = Lighting.GlobalShadows,
}

local function setGalaxy(on)
	if on then
		Lighting.Ambient = Color3.fromRGB(90, 60, 120)
		Lighting.OutdoorAmbient = Color3.fromRGB(70, 50, 90)
		Lighting.Brightness = skyBrightState.On and 3 or 2
	else
		Lighting.Ambient = savedLighting.Ambient
		Lighting.OutdoorAmbient = savedLighting.OutdoorAmbient
		Lighting.Brightness = savedLighting.Brightness
	end
end

local function setOptimizer(on)
	-- Legit: reduce client-only visuals
	Lighting.GlobalShadows = not on
	-- you can also disable your own particle emitters by tag if you want
end

-- ====== slider drag bindings ======
local function bindSlider(bar, state, setFn, onChanged)
	local dragging = false

	local function update(x)
		local absPos = bar.AbsolutePosition.X
		local absSize = bar.AbsoluteSize.X
		local a = math.clamp((x - absPos) / absSize, 0, 1)
		local v = state.Min + (state.Max - state.Min) * a
		setFn(v)
		onChanged(v)
	end

	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			update(input.Position.X)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			update(input.Position.X)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
end

bindSlider(select(3, Components:Slider(left, "_", -999, 0, 1, 0)), wsState, setWS, function(v) end) -- no-op (avoid)
-- bind correctly using internal bars: we need bars returned, so recreate sliders with bars:

left:ClearAllChildren()
Components:Label(left, "Movement", 0, true)
local wsState2, setWS2, wsBar = Components:Slider(left, "Boost Speed", 22, 8, 80, 16)
local jpState2, setJP2, jpBar = Components:Slider(left, "Hop Power", 78, 25, 150, 50)
wsState, setWS, jpState, setJP = wsState2, setWS2, jpState2, setJP2

autoDisableState, setAutoDisable = Components:Toggle(left, "Auto Disable on Plot", 132) setAutoDisable(true)
antiRagdollState, setAntiRagdoll = Components:Toggle(left, "Anti Ragdoll", 160)
unwalkState, setUnwalk = Components:Toggle(left, "Unwalk (freeze self)", 188)
spinState, setSpin = Components:Toggle(left, "Spin (cosmetic)", 216)

bindSlider(wsBar, wsState, setWS, function(v)
	Remote:FireServer("SetMovement", { WalkSpeed = math.floor(v + 0.5) })
end)

bindSlider(jpBar, jpState, setJP, function(v)
	Remote:FireServer("SetMovement", { JumpPower = math.floor(v + 0.5) })
end)

-- ====== toggles -> server ======
local function sendToggle(key, on)
	Remote:FireServer("Toggle", { Key = key, On = on })
end

-- hook toggle clicks by watching state changes via button clicks (Components toggles flip state themselves)
local function attachToggle(stateObj, key)
	-- Polling is simplest with our minimal component; we just send after click using button event:
	-- We'll re-create toggle with access to the button click: easiest is to send every frame if changed.
	local last = stateObj.On
	RunService.Heartbeat:Connect(function()
		if stateObj.On ~= last then
			last = stateObj.On
			sendToggle(key, last)
		end
	end)
end

attachToggle(pickupState, "PickupAssist")
attachToggle(autoDisableState, "AutoDisableOnPlot")
attachToggle(antiRagdollState, "AntiRagdoll")
attachToggle(unwalkState, "Unwalk")
attachToggle(stealSpeedState, "SpeedWhileStealing")

-- Client-only toggles
RunService.Heartbeat:Connect(function()
	if highlightState.On then
		if next(highlights) == nil then
			applyHighlights()
		end
	else
		if next(highlights) ~= nil then
			clearHighlights()
		end
	end

	setOptimizer(optimizerState.On)
	setGalaxy(galaxyState.On)
	if galaxyState.On then
		Lighting.Brightness = skyBrightState.On and 3 or 2
	end
end)

-- Spin cosmetic
RunService.RenderStepped:Connect(function(dt)
	if spinState.On then
		local char = player.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if root then
			root.CFrame = root.CFrame * CFrame.Angles(0, dt * 6, 0)
		end
	end
end)

-- Strafe assist (accessibility): moves like holding A/D
RunService.RenderStepped:Connect(function()
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	if leftStrafeState.On and not rightStrafeState.On then
		hum:Move(Vector3.new(-1, 0, 0), false)
	elseif rightStrafeState.On and not leftStrafeState.On then
		hum:Move(Vector3.new(1, 0, 0), false)
	end
end)

-- Save config (local)
saveBtn.MouseButton1Click:Connect(function()
	local data = {
		WalkSpeed = wsState.Value,
		JumpPower = jpState.Value,
		PickupAssist = pickupState.On,
		AutoDisableOnPlot = autoDisableState.On,
		AntiRagdoll = antiRagdollState.On,
		Unwalk = unwalkState.On,
		Spin = spinState.On,
		SpeedWhileStealing = stealSpeedState.On,
		Optimizer = optimizerState.On,
		Highlight = highlightState.On,
		Galaxy = galaxyState.On,
		SkyBright = skyBrightState.On,
		AutoLeft = leftStrafeState.On,
		AutoRight = rightStrafeState.On,
	}
	gui:SetAttribute("SavedConfig", game:GetService("HttpService"):JSONEncode(data))
end)

-- Open key
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Settings.OpenKey then
		main.Visible = not main.Visible
	end
end)
