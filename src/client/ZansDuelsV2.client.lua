-- Zans Duels V2 Client
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Components = require(script.Parent.Parent.ui.Components)

local player = Players.LocalPlayer
local Remote = ReplicatedStorage:WaitForChild("ZansDuelRemote")

local gui = Instance.new("ScreenGui")
gui.Name = "ZansDuelGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local main = Components:MainFrame(gui)

local title = Instance.new("TextLabel")
title.Size = UDim2.fromScale(1,0.25)
title.BackgroundTransparency = 1
title.Text = "ZANS DUEL"
title.TextSize = 22
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.fromRGB(255,80,80)
title.Parent = main

print("Zans Duels client loaded")

-- github force update 02/01/2026 14:01:24
