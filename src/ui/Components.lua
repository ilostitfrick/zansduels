local TweenService = game:GetService("TweenService")
local Theme = require(script.Parent.Theme)

local Components = {}

local function corner(inst, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r)
	c.Parent = inst
end

function Components:Card(parent, size, pos)
	local f = Instance.new("Frame")
	f.Size = size
	f.Position = pos
	f.BackgroundColor3 = Theme.Panel
	f.BorderSizePixel = 0
	f.Parent = parent
	corner(f, Theme.Radius)

	local s = Instance.new("UIStroke")
	s.Color = Theme.Accent
	s.Transparency = 0.65
	s.Thickness = 1.5
	s.Parent = f

	return f
end

function Components:Label(parent, text, y, bold)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Size = UDim2.new(1, -20, 0, 18)
	l.Position = UDim2.new(0, 10, 0, y)
	l.Font = bold and Theme.FontBold or Theme.Font
	l.TextSize = bold and 14 or 13
	l.TextColor3 = bold and Theme.Text or Theme.SubText
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Text = text
	l.Parent = parent
	return l
end

function Components:Button(parent, text, size, pos)
	local b = Instance.new("TextButton")
	b.Size = size
	b.Position = pos
	b.BackgroundColor3 = Theme.Accent
	b.BorderSizePixel = 0
	b.Text = text
	b.Font = Theme.FontBold
	b.TextSize = 14
	b.TextColor3 = Color3.fromRGB(255,255,255)
	b.AutoButtonColor = false
	b.Parent = parent
	corner(b, Theme.Radius)

	b.MouseEnter:Connect(function()
		TweenService:Create(b, TweenInfo.new(0.12), {BackgroundTransparency = 0.05}):Play()
	end)
	b.MouseLeave:Connect(function()
		TweenService:Create(b, TweenInfo.new(0.12), {BackgroundTransparency = 0}):Play()
	end)

	return b
end

function Components:Toggle(parent, text, y)
	local holder = Instance.new("Frame")
	holder.BackgroundTransparency = 1
	holder.Size = UDim2.new(1, -20, 0, 26)
	holder.Position = UDim2.new(0, 10, 0, y)
	holder.Parent = parent

	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Size = UDim2.new(1, -56, 1, 0)
	t.Position = UDim2.new(0, 0, 0, 0)
	t.Font = Theme.Font
	t.TextSize = 13
	t.TextColor3 = Theme.SubText
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.Text = text
	t.Parent = holder

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 46, 0, 22)
	btn.Position = UDim2.new(1, -46, 0.5, -11)
	btn.BackgroundColor3 = Theme.Muted
	btn.BorderSizePixel = 0
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.Parent = holder
	corner(btn, 11)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 18, 0, 18)
	knob.Position = UDim2.new(0, 2, 0.5, -9)
	knob.BackgroundColor3 = Theme.Text
	knob.BorderSizePixel = 0
	knob.Parent = btn
	corner(knob, 9)

	local state = {On=false}

	local function set(on)
		state.On = on
		btn.BackgroundColor3 = on and Theme.Accent or Theme.Muted
		knob:TweenPosition(on and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
			Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.12, true)
	end

	btn.MouseButton1Click:Connect(function()
		set(not state.On)
	end)

	return state, set, btn
end

function Components:Slider(parent, text, y, min, max, initial)
	local holder = Instance.new("Frame")
	holder.BackgroundTransparency = 1
	holder.Size = UDim2.new(1, -20, 0, 46)
	holder.Position = UDim2.new(0, 10, 0, y)
	holder.Parent = parent

	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Size = UDim2.new(1, -64, 0, 18)
	title.Position = UDim2.new(0, 0, 0, 0)
	title.Font = Theme.Font
	title.TextSize = 13
	title.TextColor3 = Theme.SubText
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Text = text
	title.Parent = holder

	local value = Instance.new("TextLabel")
	value.BackgroundTransparency = 1
	value.Size = UDim2.new(0, 60, 0, 18)
	value.Position = UDim2.new(1, -60, 0, 0)
	value.Font = Theme.FontBold
	value.TextSize = 13
	value.TextColor3 = Theme.Accent
	value.TextXAlignment = Enum.TextXAlignment.Right
	value.Parent = holder

	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(1, 0, 0, 10)
	bar.Position = UDim2.new(0, 0, 0, 28)
	bar.BackgroundColor3 = Color3.fromRGB(32,32,40)
	bar.BorderSizePixel = 0
	bar.Parent = holder
	corner(bar, 8)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.BackgroundColor3 = Theme.Accent
	fill.BorderSizePixel = 0
	fill.Parent = bar
	corner(fill, 8)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 16, 0, 16)
	knob.Position = UDim2.new(0, 0, 0.5, -8)
	knob.BackgroundColor3 = Theme.Text
	knob.BorderSizePixel = 0
	knob.Parent = bar
	corner(knob, 8)

	local state = {Min=min, Max=max, Value=initial}

	local function set(v)
		state.Value = math.clamp(v, min, max)
		value.Text = tostring(math.floor(state.Value + 0.5))
		local a = (state.Value - min) / (max - min)
		fill.Size = UDim2.new(a, 0, 1, 0)
		knob.Position = UDim2.new(a, -8, 0.5, -8)
	end

	set(initial)

	return state, set, bar
end

return Components
