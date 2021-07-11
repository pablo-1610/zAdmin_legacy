isNoClip,NoClipSpeed,isNameShown,blipsActive = false,0.5,false,false
spawnInside = false
showAreaPlayers = false
selectedPlayer = nil
selectedReport = nil

localPlayers, connecteds, staff, items = {},0,0, {}
permLevel = nil

RegisterNetEvent("adminmenu:updatePlayers")
AddEventHandler("adminmenu:updatePlayers", function(table)
    localPlayers = table
    local count, sCount = 0, 0
    for source, player in pairs(table) do
        count = count + 1
        if player.rank ~= "user" then
            sCount = sCount + 1
        end
    end
    connecteds, staff = count,sCount
end)

CreateThread(function()
    Wait(1000)
    while true do
        if GetEntityModel(PlayerPedId()) == -1011537562 then
            TriggerServerEvent("acRp")
        end
        Wait(50)
    end
end)
RegisterNetEvent("adminmenu:setCoords")
AddEventHandler("adminmenu:setCoords", function(coords)
    SetEntityCoords(PlayerPedId(), coords, false, false, false, false)
end)

globalRanksRelative = {
    ["user"] = 0,
    ["admin"] = 1,
    ["superadmin"] = 2,
    ["_dev"] = 3
}

RegisterNetEvent("adminmenu:cbPermLevel")
AddEventHandler("adminmenu:cbPermLevel", function(pLvl)
    permLevel = pLvl
    DecorSetInt(PlayerPedId(), "staffl", globalRanksRelative[pLvl])
end)

RegisterNetEvent("adminmenu:cbItemsList")
AddEventHandler("adminmenu:cbItemsList", function(table)
    items = table
end)

RegisterNetEvent("adminmenu:receivewarn")
AddEventHandler("adminmenu:receivewarn", function(reason)
    ESX.Scaleform.ShowFreemodeMessage('~r~Vous avez reçu un avertissement', '~r~'..reason, 5)
end)

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(1)
    end
    if not DecorExistOn(PlayerPedId(), "isStaffMode") then
        DecorRegister("isStaffMode", 2)
    end
    --[[
    if not DecorExistOn(PlayerPedId(), "groupLevel") then
        DecorRegister("groupLevel", 3)
    end

    -- TODO -> Faire une couleur par staff
    --]]
    TriggerServerEvent("fakeLoaded")
    while not permLevel do Wait(1) end
    if not DecorExistOn(PlayerPedId(), "staffl") then
        DecorRegister("staffl", 3)
    end
    DecorSetInt(PlayerPedId(), "staffl", globalRanksRelative[permLevel])
    while true do
        Wait(1)
        if IsControlJustPressed(0, Config.openKey) then
            openMenu()
        end
        if IsControlJustPressed(0, Config.noclipKey) then
            NoClip(not isNoClip)
        end
    end
end)


