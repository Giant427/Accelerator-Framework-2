local WorkspaceFolder = workspace:FindFirstChild("AcceleratorFramework")
local CharacterProfileFolder = WorkspaceFolder:FindFirstChild("CharacterProfile")

-----------------------
-- Character Profile --
-----------------------

local CharacterProfile = {}

---------------
-- Variables --
---------------

CharacterProfile.Player = nil
CharacterProfile.Character = nil
CharacterProfile.Humanoid = nil

CharacterProfile.Configurations = {}
CharacterProfile.TiltPart = nil
CharacterProfile.BodyPosition = nil
CharacterProfile.Enabled = false

---------------
-- Functions --
---------------

-- Initiate

function CharacterProfile:Initiate()
	-- Character added

	self.Player.CharacterAdded:Connect(function(Character)
		self:CharacterAdded(Character)
	end)

	-- Build TiltPart

	if not self.TiltPart then
		self.TiltPart = Instance.new("Part")
		self.TiltPart.Name = self.Player.Name
		self.TiltPart.Size = Vector3.new(0.1, 0.1, 0.1)
		self.TiltPart.Transparency = 1
		self.TiltPart.CanTouch = false
		self.TiltPart.CanCollide = false
		self.TiltPart.Parent = CharacterProfileFolder
	end

	-- Build BodyPosition

	if not self.BodyPosition then
		self.BodyPosition = Instance.new("BodyPosition")
		self.BodyPosition.D = 5000
		self.BodyPosition.P = 1000000
		self.BodyPosition.MaxForce = Vector3.new(1,1,1) * 1000000
		self.BodyPosition.Parent = self.TiltPart
	end
end

-- Character added

function CharacterProfile:CharacterAdded(Character)
	self.Humanoid = Character:WaitForChild("Humanoid")
	self.Character = Character

	-- Replace body joint offsets

	for _,v in pairs(self.Configurations) do
		local BodyPart = self.Character:FindFirstChild(v.BodyPart)
		local BodyJoint
		if BodyPart then
			BodyJoint = BodyPart:FindFirstChild(v.BodyJoint)

			if BodyJoint then
				v.JointOffset = BodyJoint.C0
			end
		end
	end
end

-- Update character

function CharacterProfile:UpdateCharacter()
	if not self.Enabled then return end

	if not self.Character then
		warn("Character does not exist for Player:", self.Player.Name)
		return
	end

	for _,v in pairs(self.Configurations) do
		-- Drops unnecesarry errors when character is being removed or player is leaving, kind of stupid to add "if"s every now and then, "pcall" is better

		pcall(function()
			local JointValue = CFrame.Angles(math.asin(self.TiltPart.Position.Y) * v.MultiplierVector.X, math.asin(self.TiltPart.Position.X) * v.MultiplierVector.Y, math.asin(self.TiltPart.Position.Z) * v.MultiplierVector.Z)

			local BodyPart = self.Player.Character:FindFirstChild(v.BodyPart)
			local BodyJoint

			if BodyPart then
				BodyJoint = BodyPart:FindFirstChild(v.BodyJoint)

				if BodyJoint then
					BodyJoint.C0 = v.JointOffset * JointValue
				end
			end
		end)
	end
end

-- Update body position

function CharacterProfile:UpdateBodyPosition(CameraCFrame)
	if not self.Character then
		warn("Character does not exist for Player:", self.Player.Name)
		return
	end

	self.BodyPosition.Position = self.Character.HumanoidRootPart.CFrame:toObjectSpace(CameraCFrame).LookVector
end

-- Add/Remove body joint

do
	-- Add body joint

	function CharacterProfile:AddBodyJoint(BodyPart, BodyJoint, MultiplierVector)
		for _,v in pairs(self.Configurations) do
			if v.BodyPart == BodyPart and v.BodyJoint == BodyJoint then
				return
			end
		end

		-- Create configuration

		local Configuration = {
			BodyPart = BodyPart,
			BodyJoint = BodyJoint,
			JointOffset = CFrame.new(),
			MultiplierVector = MultiplierVector,
		}

		-- Set joint offset

		if self.Character then
			local CharacterBodyPart = self.Character:FindFirstChild(Configuration.BodyPart)
			local CharacterBodyJoint
			if CharacterBodyPart then
				CharacterBodyJoint = CharacterBodyPart:FindFirstChild(Configuration.BodyJoint)

				if CharacterBodyJoint then
					Configuration.JointOffset = CharacterBodyJoint.C0
				end
			end
		end

		-- Insert Configuration

		table.insert(self.Configurations, Configuration)
	end

	-- Remove body joint

	function CharacterProfile:RemoveBodyJoint(BodyPart, BodyJoint)
		-- Remove and store configuration

		local Configuration

		for i,v in pairs(self.Configurations) do
			if v.BodyPart == BodyPart and v.BodyJoint == BodyJoint then
				Configuration = v
				table.remove(self.Configurations, i)
				break
			end
		end

		-- Reset joint offset in character

		if self.Character then
			local CharacterBodyPart = self.Character:FindFirstChild(Configuration.BodyPart)
			local CharacterBodyJoint
			if CharacterBodyPart then
				CharacterBodyJoint = CharacterBodyPart:FindFirstChild(Configuration.BodyJoint)

				if CharacterBodyJoint then
					CharacterBodyJoint.C0 = Configuration.JointOffset
				end
			end
		end
	end
end

-- Body joint properties

do
	-- Update body joint offset

	function CharacterProfile:UpdateBodyJointOffset(BodyPart, BodyJoint, JointOffset)
		for _,v in pairs(self.Configurations) do
			if v.BodyPart == BodyPart and v.BodyJoint == BodyJoint then
				v.JointOffset = JointOffset
				break
			end
		end
	end

	-- Update body joint multiplier vector

	function CharacterProfile:UpdateBodyJointMultiplierVector(BodyPart, BodyJoint, MultiplierVector)
		for _,v in pairs(self.Configurations) do
			if v.BodyPart == BodyPart and v.BodyJoint == BodyJoint then
				v.MultiplierVector = MultiplierVector
				break
			end
		end
	end
end

------------------------------
-- Character profile module --
------------------------------

local CharacterProfileModule = {}

-----------------
-- Constructor --
-----------------

function CharacterProfileModule:New(ProfileInfo)
    ProfileInfo = ProfileInfo or {}
	setmetatable(ProfileInfo, CharacterProfile)
	CharacterProfile.__index = CharacterProfile
	return ProfileInfo
end

return CharacterProfileModule