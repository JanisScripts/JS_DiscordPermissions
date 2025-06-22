Config = {}

Config.Debug = false

Config.UseLogs = true 

Config.AllowRefreshCommand = true -- To Refresh permissions
Config.CommandUplinkTime = 5 -- You can use the command every 5 Minutes 

Config.CacheRoles = {
    ServerRoles = true,
    UserRoles = false
}

Config.Permissions = {
    -- { label = "NameOfTheRole", roleid = DiscordRoleId, groupname = "NameOfTheGroup"}
    { label = "Owner", roleid = 1125840816707993649, groupname = "group.owner"},
    { label = "Dev", roleid = 1125840816707993646, groupname = "group.admin"},
    { label = "Admin", roleid = 1125840816707993643, groupname = "group.admin"},
    { label = "Mod", roleid = 1125840816666071199, groupname = "group.mod"},
    { label = "Staff", roleid = 1125840816666071192, groupname = "group.staff"},
    { label = "Streamer", roleid = 1125840816666071191, groupname = "group.streamer"},
    { label = "Player", roleid = 1125840816666071195, groupname = "group.member"}
}

Config.WhitelistRoleID = "1125840816666071195" -- Id of the Role you want to be able to connect

Config.GuildID = 'YOURGUILDID' -- ID of your Discord Server

Config.BotToken = 'YOURTOKEN'

Config.WebsiteLink = "https://hyrune.net/"
Config.DiscordInvite = "https://discord.gg/JmYW5yECaS"
Config.BackgroundLink = "https://media.discordapp.net/attachments/1125840819371393166/1386368202287878266/fivem-bg.png?ex=68597380&is=68582200&hm=538ba1ea18e8dbe16154bef99a27394513b3ddcc1447503563f2c2099fc7fa33&=&format=webp&quality=lossless&width=1522&height=856"
Config.ServerName = "Hyrunet.net" -- If you leave "" it automatically gets your Guild Name or you type in a preferred Name
