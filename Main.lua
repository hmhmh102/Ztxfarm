local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

--// GUI
local gui = Instance.new("ScreenGui")
gui.Name = "RivalsRagingComp"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = game:GetService("CoreGui")

--// COLORS
local bg = Color3.fromRGB(22,22,28)
local accent = Color3.fromRGB(120,50,180)
local accent2 = Color3.fromRGB(180,60,255)
local text = Color3.fromRGB(210,210,220)
local subtext = Color3.fromRGB(140,140,160)

--// MAIN FRAME
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 280, 0, 300)
main.Position = UDim2.new(0.5, -140, 0.5, -150)
main.BackgroundColor3 = Color3.fromRGB(14,14,18)
main.BorderColor3 = accent
main.ClipsDescendants = true

-- header
local header = Instance.new("TextLabel", main)
header.Size = UDim2.new(1, 0, 0, 32)
header.BackgroundColor3 = Color3.fromRGB(8,8,12)
header.Text = "Rivals Raging Comp — Mobile"
header.TextColor3 = accent2
header.Font = Enum.Font.GothamBold
header.TextSize = 12

--// SCROLLING CONTENT (THIS IS THE IMPORTANT PART)
local content = Instance.new("ScrollingFrame", main)
content.Size = UDim2.new(1, 0, 1, -32)
content.Position = UDim2.new(0, 0, 0, 32)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 4
content.ScrollBarImageColor3 = accent
content.CanvasSize = UDim2.new(0,0,0,0)
content.ClipsDescendants = true
content.ScrollingDirection = Enum.ScrollingDirection.Y

-- layout
local layout = Instance.new("UIListLayout", content)
layout.Padding = UDim.new(0,6)
layout.SortOrder = Enum.SortOrder.LayoutOrder

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	content.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
end)

--// HELPER TO CREATE ITEMS
local function createItem(titleText)
	local frame = Instance.new("Frame", content)
	frame.Size = UDim2.new(1, -8, 0, 40)
	frame.BackgroundColor3 = bg
	frame.BorderSizePixel = 0

	local label = Instance.new("TextLabel", frame)
	label.Size = UDim2.new(1, -10, 1, 0)
	label.Position = UDim2.new(0, 8, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = titleText
	label.TextColor3 = text
	label.Font = Enum.Font.Gotham
	label.TextSize = 11
	label.TextXAlignment = Enum.TextXAlignment.Left

	return frame
end

--// ADD A BUNCH OF ITEMS (so you can scroll)
createItem("Void Control")
createItem("Enable Void")
createItem("Void Method: Quantum Tunneling")
createItem("Bypass Method: Extreme Networking")
createItem("Drift Speed")
createItem("Drift Chaos")
createItem("Void Altitude")
createItem("Scramble Position")
createItem("Lissajous A")
createItem("Lissajous B")

-- duplicate more to show scrolling
for i = 1, 15 do
	createItem("Extra Setting "..i)
end

--// TOGGLE BUTTON
local toggle = Instance.new("TextButton", gui)
toggle.Size = UDim2.new(0, 140, 0, 30)
toggle.Position = UDim2.new(0.5, -70, 1, -80)
toggle.BackgroundColor3 = accent
toggle.Text = "Open UI"
toggle.TextColor3 = Color3.new(1,1,1)
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 12

local open = true

toggle.MouseButton1Click:Connect(function()
	open = not open
	main.Visible = open
	toggle.Text = open and "Close UI" or "Open UI"
end)