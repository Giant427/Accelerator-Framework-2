-- Objects
local Objects = script.Parent:WaitForChild("Objects")
local PlayerProfile = Objects:WaitForChild("PlayerProfile")
local ClientPlayerProfile = Objects:WaitForChild("ClientPlayerProfile")
local Rjac = Objects:WaitForChild("Rjac")

-- Object creator
local ObjectCreator = {}

-- Creating player profile
function ObjectCreator:CreatePlayerProfile(Player)
    local Profile = PlayerProfile:Clone()
    local ProfileObject = require(Profile)
    ProfileObject.Player = Player
    return Profile
end

-- Creating client player profile
function ObjectCreator:CreateClientPlayerProfile(Player)
    local Profile = ClientPlayerProfile:Clone()
    local ProfileObject = require(Profile)
    ProfileObject.Player = Player
    return Profile
end

-- Creating rjac profile
function ObjectCreator:CreateRjacProfile(Player)
    local Profile = Rjac:Clone()
    local ProfileObject = require(Profile)
    ProfileObject.Player = Player
    return Profile
end

return ObjectCreator