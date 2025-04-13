ESX = exports[Config.Engine]:getSharedObject()

Whitelist = {
    serverRoles = {},
    discordInteraction = {
        guildId = , -- Discord Server ID
        botToken = "", -- Your Bot Token
    },
}

RegisterCommand('who', function(source, args, rawCommand)
    if args[1] == nil then 
        TriggerClientEvent('esx:showNotification', source, 'Du måste ange ett ID.')  -- You must enter an ID. | Du måste ange ett ID.
        return
    end; 

    local targetId = tonumber(args[1])
    
    if GetPlayerPing(targetId) <= 0 then
        TriggerClientEvent('esx:showNotification', source, ("Spelare %s finns ej på servern."):format(targetId))  -- Player %s does not exist on the server. | Spelare %s finns ej på servern.
        return
    end

    local playerRoles = Whitelist:getPlayerRoles(args[1])

    local whitelistMessage = ("^3 ServerName | ID [%s] : "):format(targetId)

    if #playerRoles == 0 then
        whitelistMessage = whitelistMessage .. 'Non-Member.' -- Non-Member | Non-Member.
    elseif contains(playerRoles, Config.DiscordRoles.krimRole) and contains(playerRoles, Config.DiscordRoles.whitelistRole) and contains(playerRoles, Config.DiscordRoles.pedRole) then
        whitelistMessage = whitelistMessage .. 'Member, Criminal & Ped.' -- Member, Criminal & Ped. | Member, Criminal & Ped.
            elseif contains(playerRoles, Config.DiscordRoles.krimRole) and contains(playerRoles, Config.DiscordRoles.whitelistRole) then
        whitelistMessage = whitelistMessage .. 'Member & Criminal.' -- Member & Criminal | Member & Criminal.
    elseif contains(playerRoles, Config.DiscordRoles.whitelistRole) and contains(playerRoles, Config.DiscordRoles.pedRole)  then
        whitelistMessage = whitelistMessage .. 'Member & Ped.' --  Member & Ped. | Member & Ped.
    elseif contains(playerRoles, Config.DiscordRoles.krimRole) then
        whitelistMessage = whitelistMessage .. 'Criminal.' -- Criminal | Criminal.
            elseif contains(playerRoles, Config.DiscordRoles.whitelistRole) then
        whitelistMessage = whitelistMessage .. 'Member.' --         Member | Medlem.
            elseif contains(playerRoles, Config.DiscordRoles.pedRole) then
        whitelistMessage = whitelistMessage .. 'Ped.' -- Ped. | Ped.
    else
        whitelistMessage = whitelistMessage .. 'Non-Member.' -- Non-Member | Non-Member.
    end

    TriggerClientEvent('chat:addMessage', source, {
        template = '<div font-size: 15px"><span style="font-weight: 700">ServerName</span><br>{0}</div>',
        args = {whitelistMessage}
    })
end)

function contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

CreateThread(function()
    PerformHttpRequest(("https://discord.com/api/v8/guilds/%s/roles"):format(Whitelist.discordInteraction.guildId), function(code, data, headers)
        if tonumber(code) == 200  then
            Whitelist.serverRoles = json.decode(data)
        end
    end, "GET", "", { 
        ['Content-Type'] = 'application/json',
        ["Authorization"] = "Bot " .. Whitelist.discordInteraction.botToken
    })
end)

RegisterNetEvent("semiwhitelist:server:playerSpawned")
AddEventHandler("semiwhitelist:server:playerSpawned", function()
    local _source = source
    local playerRoles = Whitelist:getPlayerRoles(_source)

    TriggerClientEvent("semiwhitelist:client:playerSpawned", _source, playerRoles)
end)

function Whitelist:getDiscordId(source)
    local discord = ""

    for i = 0, GetNumPlayerIdentifiers(source) do
        if GetPlayerIdentifier(source, i) ~= nil then
            if string.match(GetPlayerIdentifier(source, i), "discord") then
                discord = GetPlayerIdentifier(source, i):sub(9)
            end
        end
    end

    return discord
end

function Whitelist:getPlayerRoles(source)
    local discordId = Whitelist:getDiscordId(source)
    local playerRoles = {}
    local checked = false
    
    if discordId ~= nil then
        PerformHttpRequest(("https://discord.com/api/v8/guilds/%s/members/%s"):format(Whitelist.discordInteraction.guildId, discordId), function(code, data, headers)
            if tonumber(code) == 200 then
                data = json.decode(data)

                for i = 1, #data.roles do
                    table.insert(playerRoles, data.roles[i])
                end

                checked = true
            else
                checked = true
            end
        end, "GET", "", { 
            ['Content-Type'] = 'application/json',
            ["Authorization"] = "Bot " .. Whitelist.discordInteraction.botToken
        })
    else
        checked = true
    end

    repeat Wait(50) until checked == true

    return playerRoles
end
