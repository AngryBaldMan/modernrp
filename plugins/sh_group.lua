local PLUGIN = PLUGIN
PLUGIN.name = "Group"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "You can make the groups."

-- make it like lib.
local charMeta = FindMetaTable("Character")
nut.group = nut.group or {}
nut.group.list = nut.group.list or {}

GROUP_OWNER = 0
GROUP_ADMIN = 1
GROUP_NORMAL = 2

if (SERVER) then
	function PLUGIN:SaveData()
		nut.group.saveAll()
	end
	
	function nut.group.save(groupID)
		local save = nut.group.list[groupID]
		return nut.data.set("groups/" .. groupID, save, false, true)
	end
	
	function nut.group.saveAll()
		for k, v in pairs(nut.group.list) do
			nut.group.save(k)
		end
	end

	function nut.group.load(groupID)
		local save = nut.group.list[groupID]
		return nut.data.get("groups/" .. groupID, save, false, true)
	end

	function nut.group.create(char, name)
		if (char) then
			local id = char:getID()
			nut.group.list[id] = {
				name = name,
				desc = "This is group.",
				password = "",
				isPrivate = false,
				members = {
					[id] = GROUP_OWNER,
				}
			}

			nut.group.syncGroup(id, nut.group.list[id])
			hook.Add("OnGroupCreated", id)
			return id
		end

		return false
	end

	function nut.group.delete(groupID)
		if (nut.group.list[groupID]) then
			nut.group.list[groupID] = nil

			nut.group.syncGroup(groupID, nil)
			hook.Add("OnGroupDissmissed", groupID)
			return true
		end

		return false
	end

	function charMeta:createGroup(name)
		local client = self:getPlayer()
		local group = nut.group.list[self:getGroup()]

		if (!group) then
			local groupID = nut.group.create(self, name)

			if (groupID) then
				self:setData("groupID", groupID)
				client:notify(L("groupCreated", client))
			else
				client:notify(L("groupFail", client))
			end
		else
			client:notify(L("groupExists", client))
		end
	end

	function charMeta:dismissGroup()
		local client = self:getPlayer()
		local groupID = self:getGroup()
		local group = nut.group.list[groupID]

		if (group) then
			local members = nut.group.getMembers(groupID)
			local ranks = members[self:getID()]
			
			if (ranks and ranks == GROUP_OWNER) then
				client:notify(L("groupDeleted", client))
				nut.group.delete(groupID)
			else
				client:notify(L("noPermission", client))
			end
		else
			client:notify(L("groupInvalid", client))
		end
	end
	
	function charMeta:kickGroup(kickerCharID, groupID)
		local groupID = nut.group.list[groupID]

		if (group) then
			local members = nut.group.getMembers(id)
			local kickerRank = (kickerCharID == 0 and 0 or members[kickerCharID])
			local charRank = members[self:getID()]

			if (kickerRank < charRank) then
				self:SetData("groupID", 0)
				print("You're kicked.")
			end
		end
	end

	function charMeta:inviteGroup(inviterCharID, groupID)
		local groupID = nut.group.list[groupID]

		if (group) then
			-- varies on group setting.
		end
	end

	function charMeta:joinGroup(groupID)
		local groupID = nut.group.list[groupID]

		if (groupID) then
			self:setData("groupID", groupID)
		end
	end

	function nut.group.syncGroup(groupID)
		groupTable = nut.group.list[groupID]

		if (groupTable) then
			groupTable = table.Copy(groupTable)
			groupTable.password = nil
		end

		netstream.Start(player.GetAll(), "nutGroupSync", groupID, groupTable)
	end

	function nut.group.syncAll(client)
		for k, v in pairs(nut.group.list) do
			netstream.Start(client, "nutGroupSync", k, v)
		end
	end

	function PLUGIN:PlayerLoadedChar(client, charID, prevID)
		local groupID = self:getGroup()
		local groupTable = nut.group.list[groupID]

		if (!groupTable) then
			local groupInfo = nut.group.load(groupID)

			if (groupInfo) then
				nut.group.list[groupID] = groupInfo
			end
		end

		nut.group.syncAll(client)
	end

	function PLUGIN:PlayerDisconnected(client)
		local char = client:getChar()

		if (char) then
			local groupID = char:getGroup()
			local aliveMembers = nut.group.getAliveMembers()

			if (table.Count(aliveMembers) <= 0) then
				nut.group.save(groupID)
				nut.group.list[groupID] = nil
			end
		end
	end
else
	netstream.Hook("nutGroupSync", function(id, groupTable)
		nut.group.list[id] = groupTable
	end)

	local tx, ty 
	function PLUGIN:DrawCharInfo(character, x, y, alpha)
		tx, ty = nut.util.drawText("Current Group: " .. character:getGroup(), x, y, ColorAlpha(color_white, alpha), 1, 1, "nutSmallFont", alpha * 0.65)
		y = y + ty

		return x, y
	end
end

function charMeta:getGroup()
	return self:getData("groupID", 0)
end

function nut.group.getMembers(id)
	return (nut.group.list[id] and (nut.group.list[id].members or {}) or {})
end

function nut.group.getAliveMembers(id)
	local groupMembers = nut.group.getMembers(id)
	local aliveMembers = {}
	local char, charID

	for k, v in ipairs(player.GetAll()) do
		char = v:getChar()
		
		if (char) then
			charID = char:getID()
			if (groupMembers[charID]) then
				table.insert(aliveMembers, charID)
			end
		end
	end

	return aliveMembers
end

do
	nut.command.add("groupcreate", {
		syntax = "<string name>",
		onRun = function(client, arguments)
			local char = client:getChar()

			if (char and hook.Run("CanCharCreateGroup", char) != false) then
				local groupName = table.concat(arguments, " ")

				if (groupName != "" and groupName:utf8len() > 3) then
					char:createGroup(groupName)
				end
			end
		end
	})

	nut.command.add("groupdismiss", {
		syntax = "",
		onRun = function(client, arguments)
			local char = client:getChar()

			if (char and hook.Run("CanCharCreateGroup", char) != false) then				
				char:dismissGroup()
			end
		end
	})
end