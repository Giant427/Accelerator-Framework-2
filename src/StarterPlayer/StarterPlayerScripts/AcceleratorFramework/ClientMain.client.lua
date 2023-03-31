local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = game.Players.LocalPlayer
local GuiService = game:GetService("GuiService")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")

-- Inventory Folder
local InventoryFolder = Instance.new("Folder")
InventoryFolder.Name = "Inventory"
InventoryFolder.Parent = script.Parent

-- Equipped Value
local EquippedValue = Instance.new("ObjectValue")
EquippedValue.Name = "Equipped"
EquippedValue.Parent = script.Parent

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AcceleratorFramework"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = script.Parent.Parent.Parent.PlayerGui

-- AmmoGui
local AmmoGui = Instance.new("TextLabel")
AmmoGui.AnchorPoint = Vector2.new(0.5,0.5)
AmmoGui.BackgroundTransparency = 1
AmmoGui.BorderSizePixel = 0
AmmoGui.Name = "Ammo"
AmmoGui.Position = UDim2.new(0.84, 0, 0.84, 0)
AmmoGui.Size = UDim2.new(0.2, 0, 0.1, 0)
AmmoGui.Text = "0/0"
AmmoGui.TextColor3 = Color3.fromRGB(0,0,0)
AmmoGui.TextSize = 20
AmmoGui.Parent = ScreenGui

local Aim_Enabled = true
local SprintAnimation_Enabled = true

local ReplicatedStorageFolder = ReplicatedStorage:WaitForChild("AcceleratorFramework")

local MovementHandlerFolder = ReplicatedStorage:WaitForChild("MovementHandler")
local MovementHandler = require(MovementHandlerFolder:WaitForChild("MovementHandler"))
local MovementHandlerState = MovementHandlerFolder:WaitForChild("State")
local MovementHandlerHumanoidState = MovementHandlerFolder:WaitForChild("HumanoidState")

local PartManager = require(ReplicatedStorageFolder:WaitForChild("PartManager"))
local ViewmodelHandler = require(ReplicatedStorageFolder:WaitForChild("ViewmodelHandler"))
local ClientModule = require(ReplicatedStorageFolder:WaitForChild("ClientModule"))

local Server_Client_Comms = ReplicatedStorageFolder:WaitForChild("Comms"):WaitForChild("Server-Client")

-- Part management (dealing with high volume of parts)
-- Bullet Shells
for _,v in pairs(ReplicatedStorageFolder.Shells:GetChildren()) do
	task.spawn(function()
		PartManager:New("Shells_"..v.Name, 400, v, "BulletShells")
	end)
end

-- Bullets
task.spawn(function()
	PartManager:New("Bullets", 400, ReplicatedStorageFolder.Bullet)
end)

-- Tilt character joints according to camera
local CharacterUpdateComms = ReplicatedStorageFolder:WaitForChild("Comms"):WaitForChild("CharacterUpdate")
local function CharacterUpdate()
	while task.wait() do
		CharacterUpdateComms:FireServer("Update",game.Workspace.CurrentCamera.CFrame)
	end
end
task.spawn(CharacterUpdate)

-- Viewmodel
ViewmodelHandler:Transparency(1)
ViewmodelHandler:Initiate(LocalPlayer,1,0.05)

-- Server client communication
local function ServerClientComms(Request,arg1,arg2,arg3,arg4)
	-- Inventory
	if Request == "AddGun" then
		local GUN_NAME = arg1
		ClientModule:AddGun(LocalPlayer,GUN_NAME)
	end

	-- Replicating sound effects
	if Request == "PlaySfx" then
		local Player = arg1
		local GUN_NAME = arg2
		local GUN_COMPONENT = arg3
		local NAME = arg4

		if Player == LocalPlayer then return end

		ClientModule:PlaySfx(Player,GUN_NAME,GUN_COMPONENT,NAME)
	end

	-- Replicating visual effects
	if Request == "PlayVfx" then
		local Player = arg1
		local GUN_NAME = arg2
		local GUN_COMPONENT = arg3
		local NAME = arg4

		if Player == LocalPlayer then return end

		ClientModule:PlayVfx(Player,GUN_NAME,GUN_COMPONENT,NAME)
	end

	-- Replicating bullet shell ejections
	if Request == "EjectShell" then
		local Player = arg1
		local GUN_NAME = arg2

		if Player == LocalPlayer then return end

		ClientModule:EjectShell(Player,GUN_NAME)
	end

	-- Replicating Raycast
	if Request == "ReplicateRaycast" then
		local PLAYER = arg1
		local GUN_NAME = arg2
		local FILTER_INSTANCES = arg3

		if PLAYER == LocalPlayer then return end

		ClientModule:ReplicateRaycast(PLAYER, GUN_NAME, FILTER_INSTANCES)
	end
end

Server_Client_Comms.OnClientEvent:Connect(ServerClientComms)

-- Movement handler
local MovementProfile = MovementHandler:New({Player = LocalPlayer})
local function MovementHandlerStateChangedFunction()
	local EquippedGun = ClientModule:GetEquippedGun(LocalPlayer)

	if not EquippedGun.Value then return end

	EquippedGun = require(EquippedGun.Value)

	if SprintAnimation_Enabled == true then
		if MovementHandlerState.Value == "Sprinting" then
			if EquippedGun.Aiming == true then
				EquippedGun:AimOut()
			end
			EquippedGun:SprintStart()
		else
			EquippedGun:SprintStop()
		end
	end
end

local function MovementHandlerHumanoidStateChangedFunction()
	ViewmodelHandler:HumanoidStateChanged(MovementHandlerHumanoidState.Value)
end

MovementHandlerHumanoidState:GetPropertyChangedSignal("Value"):Connect(MovementHandlerHumanoidStateChangedFunction)
MovementHandlerState:GetPropertyChangedSignal("Value"):Connect(MovementHandlerStateChangedFunction)

MovementProfile:Initiate()

-- Getting user input
-- Reloading
local Reloading = false
local function Reload(_, InputState, InputObject)
	if not Reloading == false then return end
	if not GuiService.MenuIsOpen == false then return end

	Reloading = true

	local EquippedGun = ClientModule:GetEquippedGun(LocalPlayer)

	if not EquippedGun.Value then return end

	EquippedGun = require(EquippedGun.Value)
	if InputObject.KeyCode == Enum.KeyCode.R then
		if InputState == Enum.UserInputState.Begin then
			EquippedGun:Reload()
		end
	end

	Reloading = false
end

ContextActionService:BindAction("ClientReloadGun", Reload, false, Enum.KeyCode.R)

-- Aiming
local function Aim(_, InputState, InputObject)
	local EquippedGun = ClientModule:GetEquippedGun(LocalPlayer)

	if not EquippedGun.Value then return end

	EquippedGun = require(EquippedGun.Value)

	if InputObject.UserInputType == Enum.UserInputType.MouseButton2 then
		if InputState == Enum.UserInputState.Begin then
			if not GuiService.MenuIsOpen == false then return end
			EquippedGun:SprintStop()
			if MovementHandlerState.Value == "Sprinting" then
				MovementProfile:Sprint(Enum.UserInputState.End)
			end
			EquippedGun:AimIn()
		end
		if InputState == Enum.UserInputState.End then
			EquippedGun:AimOut()
		end
	end
end

if Aim_Enabled == true then
	ContextActionService:BindAction("ClientAimGun", Aim, false, Enum.UserInputType.MouseButton2)

	GuiService.MenuOpened:Connect(Aim, "ClientShootGun", Enum.UserInputState.End, {UserInputType = Enum.UserInputType.MouseButton2})
end

-- Shooting
local LastShot = tick()
local ShootFullAutoConnection = nil

-- Shoot burst fire
local function ShootGunBurst()
	local EquippedGun = ClientModule:GetEquippedGun(LocalPlayer)

	if not EquippedGun.Value then return end

	EquippedGun = require(EquippedGun.Value)

	if not ((tick() - LastShot) > EquippedGun.Stats.ShootDelay) then return end

	for i = 1,3,1 do
		EquippedGun:Shoot()
		task.wait(EquippedGun.Stats.BurstDelay)
	end

	LastShot = tick()
end

-- Shoot fully automatic
local function ShootGunAuto()
	local EquippedGun = ClientModule:GetEquippedGun(LocalPlayer)

	if not EquippedGun.Value then return end

	EquippedGun = require(EquippedGun.Value)

	if not ((tick() - LastShot) > EquippedGun.Stats.ShootDelay) then return end

	EquippedGun:Shoot()

	LastShot = tick()
end

local function Shoot(_, InputState, InputObject)
	local EquippedGun = ClientModule:GetEquippedGun(LocalPlayer)

	if not EquippedGun.Value then return end

	EquippedGun = require(EquippedGun.Value)

	local ShootConfig = EquippedGun.Stats.ShootConfig

	if InputObject.UserInputType == Enum.UserInputType.MouseButton1 then
		EquippedGun:SprintStop()
		if MovementHandlerState.Value == "Sprinting" then
			MovementProfile:Sprint(Enum.UserInputState.End)
		end

		if InputState == Enum.UserInputState.Begin then
			if not GuiService.MenuIsOpen == false then  return end
			if ShootConfig == "Burst" then
				ShootGunBurst()
			end
			if ShootConfig == "SemiAuto" then
				ShootGunAuto()
			end
			if ShootConfig == "FullAuto" then
				ShootFullAutoConnection = RunService.Heartbeat:Connect(ShootGunAuto)
			end
		end
		if InputState == Enum.UserInputState.End then
			if ShootFullAutoConnection then
				ShootFullAutoConnection:Disconnect()
			end
		end
	end
end

ContextActionService:BindAction("ClientShootGun", Shoot, false, Enum.UserInputType.MouseButton1)
GuiService.MenuOpened:Connect(Shoot, "ClientShootGun", Enum.UserInputState.End, {UserInputType = Enum.UserInputType.MouseButton1})

-- Equiping gun
local Equipping = false
local EnumKeyCodeNumberToStringNumber = {
	["Enum.KeyCode.One"] = "1",
	["Enum.KeyCode.Two"] = "2",
	["Enum.KeyCode.Three"] = "3",
	["Enum.KeyCode.Four"] = "4",
	["Enum.KeyCode.Five"] = "5",
	["Enum.KeyCode.Six"] = "6",
	["Enum.KeyCode.Seven"] = "7",
	["Enum.KeyCode.Eight"] = "8",
	["Enum.KeyCode.Nine"] = "9",
}

local function EquipGun(_, InputState, InputObject)
	if not Equipping == false then return end
	if not GuiService.MenuIsOpen == false then return end

	Equipping = true

	if InputState == Enum.UserInputState.Begin then
		if InputObject.UserInputType == Enum.UserInputType.Keyboard then
			local EquippedGun = ClientModule:GetEquippedGun(LocalPlayer)
			local SLOT_NUMBER

			for i,v in pairs(EnumKeyCodeNumberToStringNumber) do
				if i == tostring(InputObject.KeyCode) then
					SLOT_NUMBER = v
				end
			end

			local Gun = ClientModule:GetGun(LocalPlayer,SLOT_NUMBER)

			LastShot = 0

			if EquippedGun.Value == Gun then
				-- Same gun
				if Gun then
					require(Gun):Unequip()
				end
			else
				-- Different gun
				if EquippedGun.Value then
					-- Unequip equipped gun
					require(EquippedGun.Value):Unequip()
				end
				if Gun then
					-- Equip gun
					require(Gun):Equip()
				end
			end
		end
	end

	Equipping = false
end

ContextActionService:BindAction("ClientEquipGun", EquipGun, false,
	Enum.KeyCode.One,
	Enum.KeyCode.Two,
	Enum.KeyCode.Three,
	Enum.KeyCode.Four,
	Enum.KeyCode.Five,
	Enum.KeyCode.Six,
	Enum.KeyCode.Seven,
	Enum.KeyCode.Eight,
	Enum.KeyCode.Nine
)