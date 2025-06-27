local buttonsJson = ''

if Config.EnableWebsiteLink then
    buttonsJson = [[
    {
      "type": "ColumnSet",
      "spacing": "Medium",
      "horizontalAlignment": "Center",
      "columns": [
        {
          "type": "Column",
          "width": "auto",
          "horizontalAlignment": "Center",
          "items": [
            {
              "type": "ActionSet",
              "actions": [
                {
                  "type": "Action.OpenUrl",
                  "title": "💠 DISCORD 💠",
                  "url": "]] .. Config.DiscordInvite .. [[",
                  "style": "positive"
                }
              ]
            }
          ]
        },
        {
          "type": "Column",
          "width": "auto",
          "horizontalAlignment": "Center",
          "items": [
            {
              "type": "ActionSet",
              "actions": [
                {
                  "type": "Action.OpenUrl",
                  "title": "🌐 WEBSITE 🌐",
                  "url": "]] .. Config.WebsiteLink .. [[",
                  "style": "positive"
                }
              ]
            }
          ]
        }
      ]
    }
    ]]
else
    buttonsJson = [[
    {
      "type": "ColumnSet",
      "spacing": "Medium",
      "horizontalAlignment": "Center",
      "columns": [
        {
          "type": "Column",
          "width": "auto",
          "horizontalAlignment": "Center",
          "items": [
            {
              "type": "ActionSet",
              "actions": [
                {
                  "type": "Action.OpenUrl",
                  "title": "💠 DISCORD 💠",
                  "url": "]] .. Config.DiscordInvite .. [[",
                  "style": "positive"
                }
              ]
            }
          ]
        }
      ]
    }
    ]]
end

local AdaptiveCard = [[
{
  "type": "AdaptiveCard",
  "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
  "version": "1.2",
  "backgroundImage": {
    "url": "]] .. Config.BackgroundLink .. [[",
    "fillMode": "Cover",
    "horizontalAlignment": "Top",
    "verticalAlignment": "Center"
  },
  "body": [
    {
      "type": "Container",
      "bleed": true,
      "spacing": "None",
      "items": [
        {
          "type": "TextBlock",
          "text": "🌟 Willkommen auf ]] .. (Config.ServerName or GetGuildName()) .. [[ 🌟",
          "weight": "Bolder",
          "size": "ExtraLarge",
          "wrap": true,
          "horizontalAlignment": "Center",
          "color": "Light"
        },
        {
          "type": "TextBlock",
          "text": "Du wurdest nicht auf unserem Discord erkannt!",
          "weight": "Bolder",
          "size": "Medium",
          "color": "Attention",
          "wrap": true,
          "horizontalAlignment": "Center"
        },
        {
          "type": "TextBlock",
          "text": "Verifiziere dich auf unserem Discord und hab Spaß!",
          "size": "Medium",
          "wrap": true,
          "horizontalAlignment": "Center",
          "color": "Light"
        },
        ]] .. buttonsJson .. [[,
        {
          "type": "TextBlock",
          "text": "Powered by Janis Scripts",
          "horizontalAlignment": "Center",
          "wrap": true,
          "spacing": "Large",
          "isSubtle": true,
          "color": "Default"
        }
      ]
    }
  ]
}
]]




local errorCodes = {
    [200] = 'OK - The request was completed successfully..!',
	[204] = 'OK - No Content',
	[400] = "Error - The request was improperly formatted, or the server couldn't understand it..!",
	[401] = 'Error - The Authorization header was missing or invalid..! Your Discord Token is probably wrong or does not have correct permissions attributed to it.',
	[403] = 'Error - The Authorization token you passed did not have permission to the resource..! Your Discord Token is probably wrong or does not have correct permissions attributed to it.',
	[404] = "Error - The resource at the location specified doesn't exist.",
	[429] = 'Error - Too many requests, you hit the Discord rate limit. https://discord.com/developers/docs/topics/rate-limits',
	[502] = 'Error - Discord API may be down?...'
}

local formattedToken = 'Bot ' .. Config.BotToken
local guildId = Config.GuildID
local roleList = Config.Permissions

local loadedPlayers = {}
local ConnectingPlayers = {}
local DetectedPlayers = {}

local Caches = {
	ServerRoles = {},
	PlayerRoles = {},
	PlayerPermissions = {},
	PermissionRoles = {},
	Avatars = {}
}

RegisterNetEvent('JS_DiscordPermissions:playerLoaded')
AddEventHandler('JS_DiscordPermissions:playerLoaded', function()
	local license = GetIdentifier(source, 'license');
	if (loadedPlayers[license] == nil) then 
		loadedPlayers[license] = true;
	end
end)

Citizen.CreateThread(function()
	local guild = DiscordRequest("GET", "guilds/".. Config.GuildID, {})
	if guild.code == 200 then
	  	local data = json.decode(guild.data)
	  	sendDebug("Successful connection to Guild : "..data.name.." ("..data.id..")", "success")
	else
		sendDebug("An error occured, please check your config and ensure everything is correct. Error: "..(guild.data and json.decode(guild.data) or guild.code), "error") 
	end
end)

AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    deferrals.defer()
    local src = source
    local license = GetIdentifier(src, 'license')
    local discordId = GetIdentifier(src, 'discord')
    discordId = discordId and discordId:gsub("discord:", "")

    -- Temporäre Flag, um in dieser Funktion zu merken, ob schon eine Card gezeigt wurde
    local cardShown = false

    if discordId then
        if not RegisterPermissions(src, 'playerConnecting') then
            if not cardShown then
                cardShown = true
                deferrals.presentCard(AdaptiveCard, function(data, _)
                    if data.submitId == 'played' then
                        deferrals.done("Du hast die Regeln akzeptiert!")
                    else
                        deferrals.done("Du wurdest abgelehnt!")
                    end
                end)
                return
            end
        else
            if Config.EnableWhitelist then
                local userRoles = GetUserRoles(src)
                if not userRoles or not userRoles[Config.WhitelistRoleID] then
                    if not cardShown then
                        cardShown = true
                        sendDebug("Spieler " .. GetPlayerName(src) .. " besitzt keine Whitelist-Rolle!", "warning")
                        deferrals.presentCard(AdaptiveCard, function(data, _)
                            if data.submitId == 'played' then
                                deferrals.done()
                            else
                                deferrals.done("Keine Whitelist-Rolle!")
                            end
                        end)
                        return
                    end
                end
            end

            TriggerEvent('vMenu:RequestPermissions', src)
        end
    else
        sendDebug("Discord wurde nicht gefunden für Spieler " .. GetPlayerName(src), "warning")
        if not cardShown then
            cardShown = true
            deferrals.presentCard(AdaptiveCard, function(data, _)
                if data.submitId == 'played' then
                    deferrals.done()
                else
                    deferrals.done("Discord Account wird benötigt!")
                end
            end)
            return
        end
    end

    deferrals.done()
end)


-- AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
--     deferrals.defer()
--     local src = source
--     local license = GetIdentifier(src, 'license')
--     local discordId = GetIdentifier(src, 'discord')
--     discordId = discordId and discordId:gsub("discord:", "")

--     -- Temporäre Flag, um in dieser Funktion zu merken, ob schon eine Card gezeigt wurde
--     local cardShown = false

--     if discordId then
--         if not RegisterPermissions(src, 'playerConnecting') then
--             if not cardShown then
--                 cardShown = true
--                 deferrals.presentCard(AdaptiveCard, function(data, _)
--                     if data.submitId == 'played' then
--                         deferrals.done("Du hast die Regeln akzeptiert!")
--                     else
--                         deferrals.done("Du wurdest abgelehnt!")
--                     end
--                 end)
--                 return -- Event beenden, deferrals.done wurde im Callback aufgerufen
--             end
--         else
--             local userRoles = GetUserRoles(src)
--             if not userRoles or not userRoles[Config.WhitelistRoleID] then
--                 if not cardShown then
--                     cardShown = true
--                     sendDebug("Spieler " .. GetPlayerName(src) .. " besitzt keine Whitelist-Rolle!", "warning")
--                     deferrals.presentCard(AdaptiveCard, function(data, _)
--                         if data.submitId == 'played' then
--                             deferrals.done()
--                         else
--                             deferrals.done("Keine Whitelist-Rolle!")
--                         end
--                     end)
--                     return
--                 end
--             end

--             TriggerEvent('vMenu:RequestPermissions', src)
--         end
--     else
--         sendDebug("Discord wurde nicht gefunden für Spieler " .. GetPlayerName(src), "warning")
--         if not cardShown then
--             cardShown = true
--             deferrals.presentCard(AdaptiveCard, function(data, _)
--                 if data.submitId == 'played' then
--                     deferrals.done()
--                 else
--                     deferrals.done("Discord Account wird benötigt!")
--                 end
--             end)
--             return
--         end
--     end

--     deferrals.done()
-- end)


AddEventHandler('playerDropped', function (reason) 
	local src = source;
	local discord = GetIdentifier(src, 'discord'):gsub("discord:", "");
	local license = GetIdentifier(src, 'license');
	if Caches.PlayerPermissions[discord] ~= nil then 
		-- They have perms that need to be removed:
		local list = Caches.PlayerPermissions[discord];
		for i = 1, #list do 
			local permGroup = list[i];
			ExecuteCommand('remove_principal identifier.discord:' .. discord .. " " .. permGroup);
			if (Config.UseLogs) then
				sendDebug("(playerDropped) Removed " 
					.. GetPlayerName(src) .. " from role group " .. permGroup, "info")
			end
		end
		Caches.PlayerPermissions[discord] = nil;
	end
	DetectedPlayers[license] = nil;
end)
-- ############################ Functions ############################

function RegisterPermissions(src, eventLocation)
	local license = GetIdentifier(src, 'license');
	local discordId = GetIdentifier(src, 'discord'):gsub("discord:", "");
	if (discordId) then
		sendDebug("Player " .. GetPlayerName(src) .. " had their Discord identifier found...", "info");
		ClearCaches(2, discordId);
		Caches.PlayerPermissions[discordId] = nil;
		local permAdd = "add_principal identifier.discord:" .. discordId .. " ";
		local roleIDs = GetUserRoles(src);
		if not (roleIDs == false) then
			local roleMap = ConvertUserRolesToMap(roleIDs);
			sendDebug("Player " .. GetPlayerName(src) .. " had a valid roleIDs... Length: " .. tostring(#roleIDs), "info");
			for i = 1, #roleList do
				local roleEntry = roleList[i]
				local discordRoleId = nil
			
				if (Caches.PermissionRoles[roleEntry.roleid] ~= nil) then
					discordRoleId = Caches.PermissionRoles[roleEntry.roleid]
				else
					discordRoleId = FetchRoleID(roleEntry.roleid)
					if (discordRoleId ~= nil) then
						Caches.PermissionRoles[roleEntry.roleid] = discordRoleId
					end
				end
			
				sendDebug(
					"Checking to add permission: " .. roleEntry.groupname ..
					" => Player " .. GetPlayerName(src) ..
					" has role " .. tostring(discordRoleId) ..
					" and it was compared against " .. tostring(roleEntry.roleid),
					"info"
				)
			
				if roleMap[tostring(discordRoleId)] ~= nil then
					if (Config.UseLogs) then
						print("(" .. eventLocation .. ") Added " .. GetPlayerName(src) .. " to role group " .. roleEntry.groupname, "info")
					end
					ExecuteCommand(permAdd .. roleEntry.groupname)
			
					-- Track the permission node given:
					Caches.PlayerPermissions[discordId] = Caches.PlayerPermissions[discordId] or {}
					table.insert(Caches.PlayerPermissions[discordId], roleEntry.groupname)
				end
			end
			return true;
		else
			return false;
		end
	end
	return false;
end

-- Gets the Avatar of a user as an image URL
function GetDiscordAvatar(user) 
    local discordId = string.gsub(GetIdentifier(user, 'discord'), "discord:", "")
    local imgURL = nil;
   
	if discordId then 
		if Caches.Avatars[discordId] == nil then 
			local endpoint = ("users/%s"):format(discordId)
			local member = DiscordRequest("GET", endpoint, {})
			if member.code == 200 then
				local data = json.decode(member.data)
				if data ~= nil and data.avatar ~= nil then 
					-- It is valid data 
					if (data.avatar:sub(1, 1) and data.avatar:sub(2, 2) == "_") then 
						imgURL = "https://cdn.discordapp.com/avatars/" .. discordId .. "/" .. data.avatar .. ".gif";
					else 
						imgURL = "https://cdn.discordapp.com/avatars/" .. discordId .. "/" .. data.avatar .. ".png"
					end
				end
			else 
				sendDebug("ERROR: Code 200 was not reached. DETAILS: " .. errorCodes[member.code], "error")
			end
			Caches.Avatars[discordId] = imgURL;
		else 
			imgURL = Caches.Avatars[discordId];
		end 
	else 
		sendDebug("ERROR: Discord ID was not found...", "error")
	end
    return imgURL;
end

-- Removes a Role from a User on your Discord
function RemoveRole(user, roleId, reason)
    local discordId = GetIdentifier(user, 'discord')
    if not discordId then
        print("[RemoveRole] ❌ Keine Discord-ID gefunden für User:", user)
        return false
    end

    discordId = discordId:gsub("discord:", "")
    print("[RemoveRole] Discord-ID:", discordId)

    -- Optional: Cache leeren, um sicherzustellen, dass GetUserRoles aktuelle Daten liefert
    ClearCaches(2, discordId)

    local currentRoles = GetUserRoles(user)
    if not currentRoles or type(currentRoles) ~= "table" then
        print("[RemoveRole] ❌ Rollen konnten nicht geladen werden.")
        return false
    end

    local updatedRoles = {}
    local removed = false

    for id, _ in pairs(currentRoles) do
        if tostring(id) ~= tostring(roleId) then
            table.insert(updatedRoles, id)
        else
            removed = true
            print("[RemoveRole] ✅ Entferne Rolle: " .. id .. " (" .. (Caches.ServerRoles[id] or "Unbekannt") .. ")")
        end
    end

    if not removed then
        print("[RemoveRole] ⚠️ Die Rolle war nicht vorhanden oder Vergleich schlug fehl.")
    end

    -- Debug-Ausgabe der neuen Rollenliste
    print("[RemoveRole] Neue Rollenliste:")
    for _, id in ipairs(updatedRoles) do
        print(" - " .. id .. " (" .. (Caches.ServerRoles[id] or "??") .. ")")
    end

    -- Discord PATCH Request
    local endpoint = ("guilds/%s/members/%s"):format(guildId, discordId)
    local payload = json.encode({ roles = updatedRoles })
    local result = DiscordRequest("PATCH", endpoint, payload, reason or "Rolle entfernt")

    print("[RemoveRole] API Request ->", endpoint)
    print("[RemoveRole] Statuscode:", result.code)

    if result.code == 200 or result.code == 204 then
        -- Cache aktualisieren
        if Config.CacheRoles.UserRoles and Caches.PlayerRoles[discordId] then
            Caches.PlayerRoles[discordId][roleId] = nil
            GetUserRoles(user) -- Cache neu setzen
        end

        print("[RemoveRole] ✅ Rolle erfolgreich entfernt: " .. roleId)
        return true
    else
        local msg = errorCodes[result.code] or "Unbekannter Fehler"
        print("[RemoveRole] ❌ Fehler beim Entfernen der Rolle:", msg, "Code:", result.code)
        return false
    end
end

-- Adds a Role to a user on Discord
function AddRole(user, roleId, reason)
    local discordId = GetIdentifier(user, 'discord')
    if not discordId then
        print("[AddRole] ❌ Keine Discord-ID gefunden für User:", user)
        return false
    end

    discordId = discordId:gsub("discord:", "")
    print("[AddRole] Discord-ID:", discordId)

    -- Optional: Cache leeren, um sicherzustellen, dass GetUserRoles aktuelle Daten liefert
    ClearCaches(2, discordId)

    local currentRoles = GetUserRoles(user)
    if not currentRoles or type(currentRoles) ~= "table" then
        print("[AddRole] ❌ Rollen konnten nicht geladen werden.")
        return false
    end

    local updatedRoles = {}
    local alreadyHasRole = false

    for id, _ in pairs(currentRoles) do
        table.insert(updatedRoles, id)
        if tostring(id) == tostring(roleId) then
            alreadyHasRole = true
        end
    end

    if not alreadyHasRole then
        table.insert(updatedRoles, roleId)
        print("[AddRole] ✅ Rolle hinzugefügt: " .. roleId .. " (" .. (Caches.ServerRoles[roleId] or "Unbekannt") .. ")")
    else
        print("[AddRole] ⚠️ Rolle war bereits vorhanden, wird aber erneut gesetzt.")
    end

    -- Debug-Ausgabe der neuen Rollenliste
    print("[AddRole] Neue Rollenliste:")
    for _, id in ipairs(updatedRoles) do
        print(" - " .. id .. " (" .. (Caches.ServerRoles[id] or "??") .. ")")
    end

    -- Discord PATCH Request
    local endpoint = ("guilds/%s/members/%s"):format(guildId, discordId)
    local payload = json.encode({ roles = updatedRoles })
    local result = DiscordRequest("PATCH", endpoint, payload, reason or "Rolle hinzugefügt")

    print("[AddRole] API Request ->", endpoint)
    print("[AddRole] Statuscode:", result.code)

    if result.code == 200 or result.code == 204 then
        -- Cache aktualisieren
        if Config.CacheRoles.UserRoles then
            Caches.PlayerRoles[discordId] = Caches.PlayerRoles[discordId] or {}
            Caches.PlayerRoles[discordId][roleId] = true
            GetUserRoles(user) -- Cache neu setzen
        end

        print("[AddRole] ✅ Rolle erfolgreich hinzugefügt: " .. roleId)
        return true
    else
        local msg = errorCodes[result.code] or "Unbekannter Fehler"
        print("[AddRole] ❌ Fehler beim Hinzufügen der Rolle:", msg, "Code:", result.code)
        return false
    end
end

-- Gets the Roles IDs and Names from a User on your Discord Server 
function GetUserRoles(user)
    if not user then return nil end

	local discordId = string.gsub(GetIdentifier(user, 'discord'), "discord:", "")

    if not discordId then
        sendDebug("Kein Discord-Identifier für Player "..tostring(user), "warn")
        return nil
    end

    -- Wenn Caching aktiv ist und der User bereits gecached ist
    if Config.CacheRoles.UserRoles and Caches.PlayerRoles[discordId] then
        ClearCaches(2, discordId) -- Cache nur für PlayerRoles leeren
    end

    -- API Request: Discord Member Info
    local member = DiscordRequest("GET", "guilds/" .. guildId .. "/members/" .. discordId, {})

    if member.code ~= 200 then
        sendDebug("Fehler beim Abrufen der Rollen für Discord-ID: " .. discordId .. " – Code: " .. tostring(member.code), "error")
        return nil
    end

    local data = json.decode(member.data)

    local roles = data.roles or {}
    local roleList = {}

    for _, roleId in ipairs(roles) do
        local roleName = Caches.ServerRoles[roleId]

        -- Falls Rollenname nicht vorhanden → Cache neu laden
        if not roleName then
            GetGuildRoleList()
            roleName = Caches.ServerRoles[roleId] or "Unbekannt"
        end

        roleList[roleId] = roleName
    end

    -- Caching aktiv → speichern
    if Config.CacheRoles.UserRoles then
        Caches.PlayerRoles[discordId] = roleList
    end

    return roleList
end

-- Gets all Roles from your Discord Server
function GetGuildRoleList()
	print("Caches List grade:" .. json.encode(Caches.ServerRoles))
    if (Caches.ServerRoles == nil or next(Caches.ServerRoles) == nil) then 
        local guild = DiscordRequest("GET", "guilds/"..guildId .."/roles", {})
        if guild.code == 200 then
            local data = json.decode(guild.data)
			print("Data: " .. json.encode(data))

            -- Image 
            local roles = data;
            local roleList = {};
            for i = 1, #roles do 
                roleList[roles[i].id] = roles[i].name;
            end
            
			Caches.ServerRoles = roleList;
        else
            sendDebug("An error occured, please check your config and ensure everything is correct. Error: "..(guild.data or guild.code), "error") 
            Caches.ServerRoles = nil;
        end
    end
    return Caches.ServerRoles;
end

-- Gets the Full server name of your guild 
function GetGuildName()
    local guild = DiscordRequest("GET", "guilds/"..guildId, {})
    if guild.code == 200 then
        local data = json.decode(guild.data)
        return data.name;
    else
        sendDebug("An error occured, please check your config and ensure everything is correct. Error: "..(guild.data or guild.code), "error") 
    end
    return nil;
end

-- Gets the total amount of members on your Discord Server
function GetGuildMemberCount()
    local guild = DiscordRequest("GET", "guilds/" .. guildId .. "?with_counts=true", {})
    if guild.code == 200 then
        local data = json.decode(guild.data)
        return data.approximate_member_count;
    else
        sendDebug("An error occured, please check your config and ensure everything is correct. Error: "..(guild.data or guild.code), "error") 
    end
    return nil;
end

-- Gets the amount of online players on your discord server 
function GetGuildOnlineMemberCount()
    local guild = DiscordRequest("GET", "guilds/"..guildId.."?with_counts=true", {})
    if guild.code == 200 then
        local data = json.decode(guild.data)
        return data.approximate_presence_count;
    else
        sendDebug("An error occured, please check your config and ensure everything is correct. Error: "..(guild.data or guild.code), "error") 
    end
    return nil;
end

-- Gets the Discord Name of the user
function GetDiscordName(user) 
    
    local nameData = nil;
   
	local discordId = string.gsub(GetIdentifier(user, 'discord'), "discord:", "")

    if discordId then 
        local endpoint = ("users/%s"):format(discordId)
        local member = DiscordRequest("GET", endpoint, {})
        if member.code == 200 then
            local data = json.decode(member.data)
            if data ~= nil then 
			-- It is valid data 
			if data.discriminator == 0 or data.discriminator == "0" then 
				return data.username 
			end			
				nameData = data.username .. "#" .. data.discriminator;
			end
		else 
			sendDebug("ERROR: Code 200 was not reached. DETAILS: " .. error_codes_defined[member.code], "error")
		end
    end
    return nameData;
end

-- Resets/Clears the Cache 
function ClearCaches(type, discordID)
	if type == 1 then 
		Caches.ServerRoles = {}
	elseif type == 2 then 
		if not discordID then  
			Caches.PlayerRoles = {}
		else 
			if Caches.PlayerRoles[discordID] ~= nil or Caches.PlayerRoles[discordID] ~= {} then
				Caches.PlayerRoles[discordID] = {}
			else 
				sendDebug("Player has no Entry yet.. DiscordID: " .. discordID, "info")
			end
		end
	elseif type == 3 then 
		Caches.Avatars = {}
	else 
		Caches = {
			ServerRoles = {},
			PlayerRoles = {},
			Avatars = {}
		}
	end
end

-- Returns the wanted Identifier
function GetIdentifier(source, id_type)
    if type(id_type) ~= "string" then return; end
    for _, identifier in pairs(GetPlayerIdentifiers(source)) do
        if string.find(identifier, id_type) then
            return identifier
        end
    end
    return nil
end


-- General Discord API 
function DiscordRequest(method, endpoint, jsondata, reason)
    local data = nil
    PerformHttpRequest("https://discord.com/api/"..endpoint, function(errorCode, resultData, resultHeaders)
		data = {data=resultData, code=errorCode, headers=resultHeaders}
    end, method, #jsondata > 0 and jsondata or "", {["Content-Type"] = "application/json", ["Authorization"] = formattedToken, ['X-Audit-Log-Reason'] = reason})

    while data == nil do
        Citizen.Wait(0)
    end
	
    return data
end

function FetchRoleID(labelOrId)
    -- Falls direkt eine Zahl oder Zahl-String → gib zurück
    if type(labelOrId) == "number" then
        return labelOrId
    elseif type(labelOrId) == "string" and tonumber(labelOrId) then
        return tonumber(labelOrId)
    elseif type(labelOrId) ~= "string" then
        return nil
    end

    -- Suche in Config.Permissions nach dem Label
    for _, entry in ipairs(Config.Permissions) do
        if entry.label:lower() == labelOrId:lower() then
            return entry.roleid
        end
    end

    -- Nichts gefunden
    return nil
end


function ConvertUserRolesToMap(roleList)
    local roleMap = {}
    if not roleList then return roleMap end

    for roleId, _ in pairs(roleList) do
        roleMap[roleId] = true
    end

    return roleMap
end

-- Debug
function sendDebug(message, type)
    local types = {
        ["error"] = "^1",
        ["info"] = "^5",
        ["success"] = "^2",
        ["warning"] = "^3"
    }
	print("" .. types[type] .. "[JS_DiscordPermissions] ^7" .. message);
end


function Notify(src, message)
	TriggerClientEvent("JS_DiscordPermissions:sendNotification", src, message)
end 

-- ############################ Command Section ############################

local UplinkTimer = {}

Citizen.CreateThread(function()
	while true do 
		for discord, count in pairs(UplinkTimer) do 
			UplinkTimer[discord] = (UplinkTimer[discord] - 1);
			if (UplinkTimer[discord] <= 0) then 
				UplinkTimer[discord] = nil;
			end
		end
		Wait(1000);
	end
end)


if Config.AllowRefreshCommand then 
	RegisterCommand('refreshPerms', function(src, args, rawCommand)
		local discordIdentifier = GetIdentifier(src, 'discord');
		if (discordIdentifier ~= nil) then 
			local discord = discordIdentifier:gsub("discord:", "");
			if (UplinkTimer[discord] == nil) then 
				UplinkTimer[discord] = Config.CommandUplinkTime;
				Notify(src, "Your permissions have been refreshed ~g~successfully~w~...");
				RegisterPermissions(src, 'refreshPerms');
				TriggerEvent('vMenu:RequestPermissions', src);
			else 
				local currentThrottle = UplinkTimer[discord];
				Notify(src, "~r~You cannot refresh your permissions since you are on a cooldown. You can refresh in ~y~" .. currentThrottle .. "s");
			end
		else 
			Notify(src, "~r~ERR: Your discord identifier was not found...");
		end
	end)
end 

