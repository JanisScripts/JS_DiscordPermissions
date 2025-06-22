local playerSpawned = false 

AddEventHandler("playerSpawned", function()
    if not playerSpawned then 
        playerSpawned = true;
        Citizen.Wait((1000 * 20)); 
        TriggerServerEvent('JS_DiscordPermissions:playerLoaded');
    end
end)


RegisterNetEvent("JS_DiscordPermissions:sendNotification")
AddEventHandler("JS_DiscordPermissions:sendNotification", function (message)
    ShowNotification(message)
end)


-- Notification function
    function ShowNotification(text)
        SetNotificationTextEntry("STRING")
        AddTextComponentString(text)
        DrawNotification(false, false)
    end


