# JS_DiscordPermissions
A FiveM Permission System using Discord Roles including an integrated Whitelist

### My Discord: https://discord.gg/JN7EjwAMmF
### More Scripts: https://janisscripts.tebex.io/


## Installation
1. Download the Resource
2. Drag and Drop in your resource Folder
3. put "start JS_DiscordPermissions" into your server.cfg
4. Enjoy ;)

## Usage
### Important 
For use in other resources, you will need to use: 

--> exports.JS_DiscordPermissions:Function()

For example:

--> exports.JS_DiscordPermissions:AddRole(player, RoleID, reason)

### Functions
* GetDiscordAvatar(user) --> Gets the Avatar of the User
* RemoveRole(user, RoleID, reason) --> Removes the Role from the User
* AddRole(user, RoleID, reason) --> Adds the Role to the User
* GetUserRoles(user) --> Returns all Roles (RoleID and RoleName) from the User
* GetGuildRoleList() -- Returns all Roles (RoleID and RoleName) from your Discord Server
* GetGuildName() --> Returns the Name of your Discord Server
* GetGuildMemberCount() --> Returns the Amount of Members on your Discord Server
* GetGuildOnlineMemberCount() --> Returns the Amount of Online Members on your Discord Server
* GetDiscordName(user) --> Returns the Discord Username of the Player
* ClearCaches(type, discordID) --> Clears the Selected Cache (Types: 1 = ServerRoles, 2 = PlayerRoles, 3 = Avatars, Leave Type Clear to Clear all | If you enter a discordID you can clear the specific Cache. Leave blank to Clear Cache for all Users)
* GetIdentifier(user, 'type') --> Returns the Identifier from the User (For more: https://docs.fivem.net/docs/scripting-reference/runtimes/lua/functions/GetPlayerIdentifiers/) 
