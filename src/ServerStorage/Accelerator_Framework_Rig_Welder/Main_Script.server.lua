local sp = script.Parent
local SelectionService = game:GetService("Selection")

-- User Interface

local UI_Folder = sp:WaitForChild("UI")
local MainUiFrame = UI_Folder:WaitForChild("Main")
local UiCharacterWeld = MainUiFrame:WaitForChild("CharacterWeld")
local UiViewmodelWeld = MainUiFrame:WaitForChild("ViewmodelWeld")

-- Resources

local Resources_Folder = sp:WaitForChild("Resources")
local CharacterResource = Resources_Folder:WaitForChild("Character")
local ViewmodelResource = Resources_Folder:WaitForChild("Viewmodel")

-- Toolbar

local Toolbar = plugin:CreateToolbar("Accelerator Framework Rig Welder")

-- Toolbar Button

local ToolbarWeldButton = Toolbar:CreateButton("Weld Rig", "Weld Rig as Viewmodel or Character", "rbxassetid://2778270261")
ToolbarWeldButton.ClickableWhenViewportHidden = true

-- Widget

local WidgetInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Float,  -- Widget will be initialized in floating panel
	true,   -- Widget will be initially enabled
	false,  -- Don't override the previous enabled state
	200,    -- Default width of the floating window
	300,    -- Default height of the floating window
	150,    -- Minimum width of the floating window (optional)
	150     -- Minimum height of the floating window (optional)
)

local Widget = plugin:CreateDockWidgetPluginGui("Accelerator_Framework_Rig_Welder", WidgetInfo)
Widget.Title = "Accelerator Framework Rig Welder"

-- Widget UI

MainUiFrame.Parent = Widget

-- Weld Character

local function WeldCharacter()
	local Selection = SelectionService:Get()
	local gun = Selection[1]:Clone()
	local character = CharacterResource:Clone()

	local handle = gun.GunComponents.Handle

	for _,v in pairs(gun.GunComponents:GetChildren()) do
		if v:IsA("BasePart") and v ~= handle then
			local newMotor = Instance.new("Weld")
			newMotor.Name = v.Name
			newMotor.Part0 = handle
			newMotor.Part1 = v
			newMotor.C0 = newMotor.Part0.CFrame:inverse() * newMotor.Part1.CFrame
			newMotor.Parent = handle
		end
	end

	for _,v in pairs(gun:GetChildren()) do
		if v:IsA("BasePart") and v ~= handle then
			local newMotor = Instance.new("Motor6D")
			newMotor.Name = v.Name
			newMotor.Part0 = handle
			newMotor.Part1 = v
			newMotor.C0 = newMotor.Part0.CFrame:inverse() * newMotor.Part1.CFrame
			newMotor.Parent = handle
		end
	end

	local motor = Instance.new("Motor6D")
	motor.Name = "HandleWeld"

	local part0 = character:FindFirstChild("RightLowerArm")

	if part0 then
		motor.Parent = part0
		motor.Part0 = part0
	end

	motor.Part1 = gun.GunComponents.Handle
	gun.Parent = character

	character.Name = gun.Name.."_"..character.Name
	character.Parent = workspace

	SelectionService:Remove(SelectionService:Get())
	SelectionService:Add({character})
end

-- Weld Viewmodel

local function WeldViewmodel()
	local Selection = SelectionService:Get()
	local gun = Selection[1]:Clone()
	local viewmodel = ViewmodelResource:Clone()

	local handle = gun.GunComponents.Handle

	local handleMotor = Instance.new("Motor6D")
	handleMotor.Name = "Handle"
	handleMotor.Parent = viewmodel.HumanoidRootPart
	handleMotor.Part0 = viewmodel.HumanoidRootPart
	handleMotor.Part1 = handle

	for _,v in pairs(gun:GetChildren()) do
		if v:IsA("BasePart") and v ~= handle then
			local newMotor = Instance.new("Motor6D")
			newMotor.Name = v.Name
			newMotor.Part0 = handle
			newMotor.Part1 = v
			newMotor.C0 = newMotor.Part0.CFrame:inverse() * newMotor.Part1.CFrame
			newMotor.Parent = handle
		end
	end

	for _,v in pairs(gun.GunComponents:GetChildren()) do
		if v:IsA("BasePart") and v ~= handle then
			local newMotor = Instance.new("Weld")
			newMotor.Name = v.Name
			newMotor.Part0 = handle
			newMotor.Part1 = v
			newMotor.C0 = newMotor.Part0.CFrame:inverse() * newMotor.Part1.CFrame
			newMotor.Parent = handle
		end
	end

	gun.Parent = viewmodel
	viewmodel.Name = gun.Name.."_"..viewmodel.Name
	viewmodel.Parent = workspace
	
	SelectionService:Remove(SelectionService:Get())
	SelectionService:Add({viewmodel})
end

-- Toolbar weld button click

local function ToolbarWeldButtonClick()
	Widget.Enabled = not Widget.Enabled
end

ToolbarWeldButton.Click:Connect(ToolbarWeldButtonClick)

UiCharacterWeld.MouseButton1Down:Connect(WeldCharacter)
UiViewmodelWeld.MouseButton1Down:Connect(WeldViewmodel)