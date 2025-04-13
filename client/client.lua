ESX = exports[Config.Engine]:getSharedObject()

Whitelist = {
    hasKrimRole = false,
    hasWhitelistRole = false,
    hasPedRole = false,
}

CreateThread(function()
    while not ESX.IsPlayerLoaded() do Wait(1000) end

    TriggerServerEvent("semiwhitelist:server:playerSpawned")
end)

CreateThread(function()
    while true do
        if not Whitelist.hasWhitelistRole then 
            local playerPed = PlayerPedId()
            DisablePlayerFiring(playerPed, true)
            DisableControlAction(0, 140, true)
        end

        Wait(0)
    end
end)

RegisterNetEvent("semiwhitelist:client:playerSpawned")
AddEventHandler("semiwhitelist:client:playerSpawned", function(playerRoles)
    NetworkSetFriendlyFireOption(true)
    SetCanAttackFriendly(PlayerPedId(), true, true)

    for key, value in pairs(playerRoles) do
        if value == Config.DiscordRoles.krimRole then
            Whitelist.hasKrimRole = true
        end

        if value == Config.DiscordRoles.pedRole then
            Whitelist.hasPedRole = true
        end

        if value == Config.DiscordRoles.whitelistRole then
            Whitelist.hasWhitelistRole = true
        end
    end
end)

exports('HasWhitelistRole', function()
    return Whitelist.hasWhitelistRole
end)

exports('HasPedRole', function()
    return Whitelist.hasPedRole
end)

exports('HasKrimRole', function()
    return Whitelist.hasKrimRole
end)
