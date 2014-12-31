-- This hook returns whether player can use bank or not.
function SCHEMA:CanUseBank(client, atmEntity)
	return true
end

-- This hook returns whether character is recognised or not.
function SCHEMA:IsCharRecognised(char, id)
	local client = char:getPlayer()

	if (client) then
		local faction = nut.faction.indices[client:Team()]

		if (faction and faction.isPublic) then
			return true
		end
	end
end