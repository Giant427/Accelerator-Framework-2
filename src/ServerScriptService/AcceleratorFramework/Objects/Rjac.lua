--[[
	Made by: GiantDefender427

	Devforum Post: https://devforum.roblox.com/t/rjac-rotating-joints-according-to-camera/1601251

	Accelerator Framework version
]]

----------
-- Rjac --
----------

local Rjac = {}

-- Properties
Rjac.Player = nil
Rjac.Character = nil
Rjac.Configurations = {}
Rjac.TiltDirection = Vector3.new(0, 0, 0)
Rjac.Enabled = false

-- Functions

-- Starter function to assemble the whole profile for functionality
function Rjac:Initiate()
	self.Character = self.Player.Character

	-- Character  added
	self.Player.CharacterAdded:Connect(function(Character)
		self:onCharacterAdded(Character)
	end)
end

-- On character added

function Rjac:onCharacterAdded(Character)
	-- Wait till the character appearance has fully loaded for proper joint offsets
    Character:WaitForChild("Humanoid")
	self.Character = Character

	-- Reset joint offset configurations
	self:ResetJointOffsets()
end

-- Update character
function Rjac:UpdateCharacter()
	if not self.Enabled then return end

	if not self.Character then
		warn("Character does not exist for Player:", self.Player.Name)
		return
	end

	for _,v in pairs(self.Configurations) do
		-- Drops unnecesarry errors when character is being removed or player is leaving, kind of stupid to add "if"s every now and then, "pcall" is better

        pcall(function()
            local JointValue = CFrame.Angles(math.asin(self.TiltDirection.Y) * v.MultiplierVector.X, -math.asin(self.TiltDirection.X) * v.MultiplierVector.Y, math.asin(self.TiltDirection.Z) * v.MultiplierVector.Z)

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

-- Update tilt direction
function Rjac:UpdateTiltDirection(CameraCFrame)
	if not self.Character then
		warn("Character does not exist for Player:", self.Player.Name)
		return
	end

	local TiltDirection = self.Character.HumanoidRootPart.CFrame:toObjectSpace(CameraCFrame).LookVector

	-- If TiltDirection.Y is less than -0.965, character shows weird behaviour
	if TiltDirection.Y < -0.965 then
		TiltDirection = Vector3.new(TiltDirection.X, -0.965, TiltDirection.Z)
	end

	self.TiltDirection = TiltDirection
end

-- Add/Remove body joint
do
	-- Add body joint
	function Rjac:AddBodyJoint(BodyPart, BodyJoint, MultiplierVector)
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

		table.insert(self.Configurations, Configuration)

		-- Set joint offset
		if self.Character then
			local CharacterBodyPart = self.Character:FindFirstChild(Configuration.BodyPart)
			local CharacterBodyJoint

			if CharacterBodyPart then
				CharacterBodyJoint = CharacterBodyPart:FindFirstChild(Configuration.BodyJoint)

				if CharacterBodyJoint then
                    self:UpdateBodyJointOffset(Configuration.BodyPart, Configuration.BodyJoint, CharacterBodyJoint.C0)
				end
			end
		end
	end

	-- Remove body joint
	function Rjac:RemoveBodyJoint(BodyPart, BodyJoint)
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
	-- Reset joint offset configurations
	function Rjac:ResetJointOffsets()
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

	-- Update body joint offset
	function Rjac:UpdateBodyJointOffset(BodyPart, BodyJoint, JointOffset)
		for _,v in pairs(self.Configurations) do
			if v.BodyPart == BodyPart and v.BodyJoint == BodyJoint then
				v.JointOffset = JointOffset
				break
			end
		end
	end

	-- Update body joint multiplier vector
	function Rjac:UpdateBodyJointMultiplierVector(BodyPart, BodyJoint, MultiplierVector)
		for _,v in pairs(self.Configurations) do
			if v.BodyPart == BodyPart and v.BodyJoint == BodyJoint then
				v.MultiplierVector = MultiplierVector
				break
			end
		end
	end
end

return Rjac