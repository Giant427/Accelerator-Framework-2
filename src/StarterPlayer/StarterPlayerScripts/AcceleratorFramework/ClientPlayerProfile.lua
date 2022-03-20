local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorageFolder = ReplicatedStorage:WaitForChild("AcceleratorFramework")
local GunResourcesHandler = require(ReplicatedStorageFolder:WaitForChild("Modules"):WaitForChild("GunResourcesHandler"))
local MovementHandler = require(game.ReplicatedStorage:WaitForChild("MovementHandler"):WaitForChild("MovementHandler"))

local ClientPlayerProfile = {}

-- Properties
ClientPlayerProfile.Player = nil
ClientPlayerProfile.Character = nil
ClientPlayerProfile.RemoteEvent = nil
ClientPlayerProfile.Enabled = false
ClientPlayerProfile.MovementProfile = {}
ClientPlayerProfile.ViewmodelProfile = {}
ClientPlayerProfile.UiProfile = {}
ClientPlayerProfile.GunProfileClient = {}
ClientPlayerProfile.Equipping = false
ClientPlayerProfile.Inventory = {}
ClientPlayerProfile.InventoryMaxSlots = 3
ClientPlayerProfile.EquippedGunSlot = false
ClientPlayerProfile.onCharacterAddedConnection = nil
ClientPlayerProfile.onClientEventConnection = nil

-- Starter function to assemble the whole profile for functionality
function ClientPlayerProfile:Initiate()
	-- Saftey measures incase character has already loaded
	self.Character = self.Player.Character
	self.onCharacterAddedConnection = self.Player.CharacterAdded:Connect(function(Character)
		self:onCharacterAdded(Character)
	end)
	-- Remote event
	self.RemoteEvent = ReplicatedStorageFolder:WaitForChild("RemoteEventsFolder"):WaitForChild(self.Player.UserId)
	self.onServerEventConnection = self.RemoteEvent.OnClientEvent:Connect(function(Request, arg1)
		if not self.Enabled then return end
		self:onClientEvent(Request, arg1)
	end)
	task.spawn(function()
		while task.wait(0.01) and self.Enabled do
			self.RemoteEvent:FireServer("RjacProfile:UpdateTiltDirection()", game.Workspace.CurrentCamera.CFrame)
		end
	end)
	-- Movement handler
	local MovementState = Instance.new("StringValue")
	local HumanoidState = Instance.new("StringValue")
	MovementState.Name = "MovementState"
	HumanoidState.Name = "HumanoidState"
	MovementState.Parent = self.Player.PlayerScripts.AcceleratorFramework.ClientProfile
	HumanoidState.Parent = self.Player.PlayerScripts.AcceleratorFramework.ClientProfile
	local MovementProfileInfo = {}
	MovementProfileInfo.Player = self.Player
	MovementProfileInfo.MovementState = MovementState
	MovementProfileInfo.HumanoidState = HumanoidState
	self.MovementProfile = MovementHandler:New(MovementProfileInfo)
	self.MovementProfile:Initiate()
	-- Viewmodel profile
	local ProfileInfo = {}
	ProfileInfo.Player = self.Player
	self.ViewmodelProfile = require(script.Parent.ViewmodelProfile):New(ProfileInfo)
	self.ViewmodelProfile:Initiate()
	self.ViewmodelProfile:ChangeTransparency(1)
	-- Ui profile
	ProfileInfo = {}
	ProfileInfo.Player = self.Player
	self.UiProfile = require(script.Parent.UiProfile):New(ProfileInfo)
	self.UiProfile:Initiate()
	-- Gun profile client
	for i,v in pairs(require(self.Player.PlayerScripts.AcceleratorFramework.GunProfileClient)) do
		self.GunProfileClient[i] = v
	end
	-- User input
	local function ProcessUserInput(ActionName, InputState, InputObject)
		self:ProcessUserInput(ActionName, InputState, InputObject)
	end
	ContextActionService:BindAction("ClientEquipGun", ProcessUserInput, false,
		Enum.KeyCode.One,
		Enum.KeyCode.Two,
		Enum.KeyCode.Three
	)
	-- Enable
	self.Enabled = true
	self.MovementProfile.Enabled = true
	self.ViewmodelProfile.Enabled = true
	-- Script clean up
	--[[
		Destroying ClientMain just completely disables everything in the Profile :(
		self.Player.PlayerScripts.AcceleratorFramework.ClientMain:Destroy()
	]]
	self.Player.PlayerScripts.AcceleratorFramework.ClientPlayerProfile:Destroy()
	self.Player.PlayerScripts.AcceleratorFramework.ViewmodelProfile:Destroy()
	self.Player.PlayerScripts.AcceleratorFramework.UiProfile:Destroy()
	self.Player.PlayerScripts.AcceleratorFramework.GunProfileClient:Destroy()
end

-- On character added
function ClientPlayerProfile:onCharacterAdded(Character)
	self.Character = Character
end

-- On client event
function ClientPlayerProfile:onClientEvent(Request, arg1)
	-- Destroy class
	if Request == ":Destroy()" then
		self:Destroy()
	end
	-- Add gun
	if Request == ":AddGun(GunName)" then
		local GunName = arg1
		self:AddGun(GunName)
	end
end

-- Process user input
function ClientPlayerProfile:ProcessUserInput(ActionName, InputState, InputObject)
	if not self.Enabled then return end
	if GuiService.MenuIsOpen then return end
	if ActionName == "ClientEquipGun" then
		if self.Equipping then return end
		self.Equipping = true
		local EnumKeyCodeToNumber = {
			["Enum.KeyCode.One"] = 1,
			["Enum.KeyCode.Two"] = 2,
			["Enum.KeyCode.Three"] = 3,
		}
		if InputState == Enum.UserInputState.Begin then
			if InputObject.UserInputType == Enum.UserInputType.Keyboard then
				local SlotNumber = nil
				for i,v in pairs(EnumKeyCodeToNumber) do
					if i == tostring(InputObject.KeyCode) then
						SlotNumber = v
						break
					end
				end
				local Gun = self.Inventory[SlotNumber]
				if self.EquippedGunSlot == SlotNumber then
					if Gun then
						self:UnequipGun(SlotNumber)
					end
				else
					if self.EquippedGunSlot ~= false and self.Inventory[self.EquippedGunSlot] then
						self:UnequipGun(self.EquippedGunSlot)
					end
					if Gun then
						self:EquipGun(SlotNumber)
					end
				end
			end
		end
		self.Equipping = false
	end
end

-- Equip gun
function ClientPlayerProfile:EquipGun(SlotNumber)
	self.EquippedGunSlot = SlotNumber
	self.UiProfile:EquipInventorySlot(SlotNumber)
	local GunProfileClient = self.Inventory[SlotNumber]
	GunProfileClient:Equip()
end

-- Unequip gun
function ClientPlayerProfile:UnequipGun(SlotNumber)
	local GunProfileClient = self.Inventory[SlotNumber]
	GunProfileClient:Unequip()
	self.UiProfile:UnequipInventorySlot(SlotNumber)
	self.EquippedGunSlot = false
end

-- Add gun to inventory
function ClientPlayerProfile:AddGun(GunName)
	if #self.Inventory + 1 > self.InventoryMaxSlots then return end
	local SlotNumber = #self.Inventory + 1
	local Metadata = GunResourcesHandler:GetResource(GunName, "Metadata")
	Metadata.Player = self.Player
	Metadata.Character = self.Character
	Metadata.GunName = GunName
	Metadata.Parent = self
	local GunProfileClient = self.GunProfileClient:New(Metadata)
	getmetatable(GunProfileClient)["New"] = nil
	self.Inventory[SlotNumber] = GunProfileClient
	self.UiProfile:UpdateInventorySlot(SlotNumber, GunProfileClient.GunName)
	GunProfileClient:Initiate()
end

-- Play sound
function ClientPlayerProfile:PlaySound(GunModel, GunComponentName, SoundName)
	local GunComponent = GunModel.GunComponents:FindFirstChild(GunComponentName)
	if not GunComponent then return end
	local Sound = GunComponent:FindFirstChild(SoundName)
	if not Sound then return end
	if not Sound:IsA("Sound") then return end
	Sound:Play()
end

-- Emit particles
function ClientPlayerProfile:EmitParticles(GunModel, GunComponentName, ParticleEmitterName)
	local GunComponent = GunModel.GunComponents:FindFirstChild(GunComponentName)
	if not GunComponent then return end
	local ParticleEmitter = GunComponent:FindFirstChild(ParticleEmitterName)
	if not ParticleEmitter then return end
	if not ParticleEmitter:IsA("ParticleEmitter") then return end
	ParticleEmitter.Enabled = true
	task.spawn(function()
		task.wait(0.1)
		ParticleEmitter.Enabled = false
	end)
end

-- Destructor
function ClientPlayerProfile:Destroy()
	local Player = self.Player
	self.Enabled = false
	self.ViewmodelProfile:Destroy()
	self.MovementProfile:Destroy()
	self.Player.PlayerScripts.AcceleratorFramework.ClientProfile.MovementState:Destroy()
	self.Player.PlayerScripts.AcceleratorFramework.ClientProfile.HumanoidState:Destroy()
	self.onCharacterAddedConnection:Disconnect()
	self.onServerEventConnection:Disconnect()
	for i,_ in pairs(self) do
		self[i] = nil
	end
	for i,_ in pairs(getmetatable(self)) do
		getmetatable(self)[i] = nil
	end
	require(Player.PlayerScripts.AcceleratorFramework.ClientProfile)["Profile"] = nil
end

-- Constructor
local ClientPlayerProfileModule = {}
function ClientPlayerProfileModule:New(ProfileInfo)
	ProfileInfo = ProfileInfo or {}
	setmetatable(ProfileInfo, ClientPlayerProfile)
	ClientPlayerProfile.__index = ClientPlayerProfile
	return ProfileInfo
end

return ClientPlayerProfileModule