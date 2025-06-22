fx_version 'cerulean'
game 'gta5'

author 'Janis'
description 'Discord API Permission System with integrated Whitelist by Janis Scripts'
version '1.0'

shared_scripts {
    'config.lua'
}

client_scripts {
	'client/*.lua',
}

server_scripts {
	"server/*.lua",
}

files {
	'background.png'
}

server_exports { 
	'GetDiscordAvatar',
	'RemoveRole',
	'AddRole',
	'GetUserRoles',
	'GetGuildRoleList',
	'GetGuildName',
	'GetGuildMemberCount',
	'GetGuildOnlineMemberCount',
	'GetDiscordName',
	'ClearCaches',
	'GetIdentifier',
	'FetchRoleID'
} 