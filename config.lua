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

Config.EnableWhitelist = true 

Config.WhitelistRoleID = "1125840816666071195" -- Id of the Role you want to be able to connect

Config.GuildID = 'YOURGUILDID' -- ID of your Discord Server

Config.BotToken = 'YOURTOKEN'

Config.EnableWebsiteLink = true
Config.WebsiteLink = "https://valerobay.net/"
Config.DiscordInvite = "https://discord.gg/JmYW5yECaS"
Config.BackgroundLink = "https://media.discordapp.net/attachments/1125840819371393166/1386368202287878266/fivem-bg.png?ex=685f6240&is=685e10c0&hm=1f27cf33508c746b9996e6a62c278904b1cc0939a381d7d7e565048778268a8b&=&format=webp&quality=lossless&width=1522&height=856"
Config.ServerName = "ValeroBay.net" -- If you leave "" it automatically gets your Guild Name or you type in a preferred Name
