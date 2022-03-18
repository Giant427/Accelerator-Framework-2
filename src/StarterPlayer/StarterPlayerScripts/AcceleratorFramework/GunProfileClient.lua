local GunProfileClient = {}

-- Constructor
function GunProfileClient:New(Metadata)
	Metadata = Metadata or {}
	setmetatable(Metadata, GunProfileClient)
	GunProfileClient.__index = GunProfileClient
	return Metadata
end

return GunProfileClient