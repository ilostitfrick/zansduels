local Theme = require(script.Parent.Theme)

local Components = {}

function Components:MainFrame(parent)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromScale(0.32,0.28)
    frame.Position = UDim2.fromScale(0.5,0.5)
    frame.AnchorPoint = Vector2.new(0.5,0.5)
    frame.BackgroundColor3 = Theme.Background
    frame.Visible = false
    frame.Parent = parent
    return frame
end

function Components:Button(text, parent)
    local btn = Instance.new("TextButton")
    btn.Text = text
    btn.Parent = parent
    return btn
end

return Components

-- github force update 02/01/2026 14:01:24
