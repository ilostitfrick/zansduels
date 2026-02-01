local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local Settings = require(script.Parent.Parent.shared.SettingsSchema)

-- Remote for the panel
local Remote = ReplicatedStorage:FindFirstChild("ZansPanelRemote")
if not Remote then
	Remote = Instance.new("RemoteEvent")
	Remote.Name = "ZansPanelRemote"
	Remote.Parent = ReplicatedStorage
end

-- =========================
-- LEGIT HOOKS YOU OWN
-- =========================
local ServerHooks = {}

-- IMPORTANT:
-- This must call YOUR real pickup logic.
-- If brainrots are Tools, this works by parenting to backpack.
function ServerHooks.Pickup(player: Player, brainrot: Instance): boolean
	if not brainrot or not brainrot.Parent then return false end

	-- If your brainrots are Tools in workspace:
	if brainrot:IsA("Tool") then
		brainrot.Parent = player:FindFirstChildOfClass("Backpack") or player:WaitForChild("Backpack")
		return true
	end

	-- If your brainrots are Models/Parts, you MUST wire your real function here.
	-- Example (you replace this):
	-- return require(ServerScriptService.BrainrotService).Pickup(player, brainrot)

	return false
end

-- =========================
-- Player state
-- =========================
local state = {}
local function getState(plr)
	state[plr] = state[plr] or {
		PickupAssist = false,
		AutoDisableOnPlot = Settings.Assist.AutoDisableOnPlot,
		SpeedBoost = false,
		WalkSpeed = 16,
		JumpPower = 50,
		SpeedWhileStealing = false,
		Unwalk = false,
	}
	return state[plr]
end

local function clampMove(ws, jp)
	local m = Settings.Movement
	ws = math.clamp(ws, m.WalkSpeedMin, m.WalkSpeedMax)
	jp = math.clamp(jp, m.JumpPowerMin, m.JumpPowerMax)
	return ws, jp
end

local function applyMovement(plr)
	local st = getState(plr)
	local char = plr.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return end

	local ws, jp = clampMove(st.WalkSpeed, st.JumpPower)

	-- “Speed While Stealing” legit: only if your own game sets this attribute
	if st.SpeedWhileStealing and plr:GetAttribute("IsStealing") == true then
		ws = math.clamp(ws + 8, Settings.Movement.WalkSpeedMin, Settings.Movement.WalkSpeedMax)
	end

	if st.Unwalk then
		hum.WalkSpeed = 0
		hum.JumpPower = 0
	else
		hum.WalkSpeed = ws
		hum.JumpPower = jp
	end
end

Remote.OnServerEvent:Connect(function(plr, action, payload)
	local st = getState(plr)

	if action == "SetMovement" then
		st.WalkSpeed = tonumber(payload.WalkSpeed) or st.WalkSpeed
		st.JumpPower = tonumber(payload.JumpPower) or st.JumpPower
		applyMovement(plr)

	elseif action == "Toggle" then
		local key = tostring(payload.Key)
		local on = payload.On == true

		if key == "PickupAssist" then
			st.PickupAssist = on
		elseif key == "AutoDisableOnPlot" then
			st.AutoDisableOnPlot = on
		elseif key == "SpeedWhileStealing" then
			st.SpeedWhileStealing = on
			applyMovement(plr)
		elseif key == "Unwalk" then
			st.Unwalk = on
			applyMovement(plr)
		elseif key == "AntiRagdoll" then
			-- Legit hook point: your ragdoll system should check this
			plr:SetAttribute("AntiRagdoll", on)
		end
	end
end)

Players.PlayerAdded:Connect(function(plr)
	getState(plr)
	plr.CharacterAdded:Connect(function()
		task.wait(0.25)
		applyMovement(plr)
	end)
end)

Players.PlayerRemoving:Connect(function(plr)
	state[plr] = nil
end)

-- =========================
-- Pickup Assist (LEGIT, server-checked)
-- =========================
local accum = 0
RunService.Heartbeat:Connect(function(dt)
	accum += dt
	if accum < Settings.Assist.PickupTick then return end
	accum = 0

	for plr, st in pairs(state) do
		if not st.PickupAssist then continue end
		local char = plr.Character
		if not char then continue end
		local root = char:FindFirstChild("HumanoidRootPart")
		if not root then continue end

		-- Optional: if your game tags plot zones, and you want auto-disable on plot:
		if st.AutoDisableOnPlot then
			-- client handles most of this; server kept simple.
			-- leave as-is to avoid wrong disabling in unknown games.
		end

		local nearest, nd = nil, math.huge
		for _, inst in ipairs(CollectionService:GetTagged(Settings.BrainrotTag)) do
			if not inst:IsDescendantOf(workspace) then continue end

			local pos
			if inst:IsA("BasePart") then
				pos = inst.Position
			elseif inst:IsA("Model") and inst.PrimaryPart then
				pos = inst.PrimaryPart.Position
			end
			if not pos then continue end

			local d = (pos - root.Position).Magnitude
			if d <= Settings.Assist.PickupRange and d < nd then
				nearest, nd = inst, d
			end
		end

		if nearest then
			-- This will only work out of the box if brainrots are Tools.
			-- Otherwise wire ServerHooks.Pickup() to your real pickup function.
			ServerHooks.Pickup(plr, nearest)
		end
	end
end)
