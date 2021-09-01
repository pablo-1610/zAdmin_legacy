local userGroup = nil
local filterType = 1
local NoClipSpeed = 1
local menuOpened, zoneOnly, noclip, blips, names = false, false, false, false, false
local ESX, players, reports = {}, {}, {}

-- Init
Citizen.CreateThread(function()
    TriggerEvent("esx:getSharedObject", function(API)
        ESX = API
    end)
    while not ESX do
        Wait(1)
    end
    ESX.TriggerServerCallback('KorioZ-PersonalMenu:Admin_getUsergroup', function(group)
        userGroup = group
        RegisterCommand("zAdmin", function()
            if not userGroup then
                return
            end
            if Permissions.hasPermission("open_menu", userGroup) then
                TriggerEvent("zAdmin:openMenu")
            end
        end, false)
    end)
end)

-- Key mapping
RegisterKeyMapping("zAdmin", Translations.open_menu, "keyboard", "f11")

-- Utils
local function countTableLenght(table)
    local ret = 0
    for _, _ in pairs(table) do
        ret = (ret + 1)
    end
    return ret
end

local function getPrefixFromRank(rank)
    return (Permissions.ranksPrefix[rank].prefix) or ""
end

local function getPowerFromRank(rank)
    return (Permissions.ranksPrefix[rank].power) or 0
end

-- Server communication
local function registerHandle(event, ...)
    event = ("zAdmin:%s"):format(event)
    RegisterNetEvent(event)
    AddEventHandler(event, ...)
end

local function sendToServer(event, ...)
    event = ("zAdmin:%s"):format(event)
    TriggerServerEvent(event, ...)
end

registerHandle("receivePlayers", function(receivedTable)
    if filterType == 1 then
        table.sort(receivedTable, function(a, b)
            return getPowerFromRank(a.group) > getPowerFromRank(b.group)
        end)
    else
        table.sort(receivedTable, function(a, b)
            return a.sID > b.sID
        end)
    end
    players = receivedTable
end)

-- Menu
local title, cat, desc = "zAdmin", "zAdmin", Translations.admin_panel

local sub = function(str)
    return ("%s_%s"):format(cat, str)
end

local function setOpenedState(boolean)
    menuOpen = boolean
end

local function addPanels(subPanels)
    RMenu.Add(cat, sub("main"), RageUI.CreateMenu(title, desc, nil, nil, "pablo", "black"))
    RMenu:Get(cat, sub("main")).Closed = function()
    end

    for _, v in pairs(subPanels) do
        RMenu.Add(cat, sub(v.name), RageUI.CreateSubMenu(RMenu:Get(cat, sub(v.from)), title, desc, nil, nil, "pablo", "black"))
        RMenu:Get(cat, sub(v.name)).Closed = function()
        end
    end

    return subPanels
end

local function delPanels(subPanels)
    RMenu:Delete(cat, sub("main"))

    for panel, _ in pairs(subPanels) do
        RMenu:Delete(cat, sub(panel))
    end
end

AddEventHandler("zAdmin:openMenu", function()
    if menuOpen then
        return
    end
    sendToServer("requestPlayers")
    setOpenedState(true)
    local toDelete, selectedPlayer = addPanels({
        { name = "players", from = "main" },
        { name = "players_sel", from = "players" },
        { name = "reports", from = "main" },
        { name = "vehicles", from = "main" },
        { name = "other", from = "main" },
    }), nil
    RageUI.Visible(RMenu:Get(cat, sub("main")), true)
    Citizen.CreateThread(function()
        while menuOpen do
            local shouldStayOpened = false
            local function tick()
                shouldStayOpened = true
            end

            RageUI.IsVisible(RMenu:Get(cat, sub("main")), true, true, true, function()
                tick()
                RageUI.Separator(Translations.admin_header_main)
                RageUI.ButtonWithStyle(("%s ~s~(~o~%s~s~)"):format(Translations.category_players, countTableLenght(players)), nil, { RightLabel = "→" }, true, function()
                end, RMenu:Get(cat, sub("players")))
                RageUI.ButtonWithStyle(("%s ~s~(~r~%s~s~)"):format(Translations.category_reports, countTableLenght(reports)), nil, { RightLabel = "→" }, true, function()
                end, RMenu:Get(cat, sub("reports")))
                RageUI.ButtonWithStyle(Translations.category_vehicles, nil, { RightLabel = "→" }, true, function()
                end, RMenu:Get(cat, sub("vehicles")))
                RageUI.ButtonWithStyle(Translations.category_other, nil, { RightLabel = "→" }, true, function()
                end, RMenu:Get(cat, sub("other")))
            end, function()
            end)

            RageUI.IsVisible(RMenu:Get(cat, sub("players")), true, true, true, function()
                tick()
                RageUI.Separator(Translations.admin_header_players_options)
                --[[

                // WIP

                RageUI.Checkbox(Translations.sort_by_zone, nil, zoneOnly, { Style = RageUI.CheckboxStyle.Tick }, function(Hovered, Selected, Active, Checked)
                    zoneOnly = Checked;
                end, function()
                    zoneOnly = true
                end, function()
                    zoneOnly = false
                end)
                --]]
                if filterType == 1 then
                    RageUI.ButtonWithStyle(Translations.sort_by_id, nil, { RightLabel = "→" }, true, function(_, _, s)
                        if s then
                            table.sort(players, function(a, b)
                                return a.sID > b.sID
                            end)
                            filterType = 2
                        end
                    end)
                else
                    RageUI.ButtonWithStyle(Translations.sort_by_group, nil, { RightLabel = "→" }, true, function(_, _, s)
                        if s then
                            table.sort(players, function(a, b)
                                return getPowerFromRank(a.group) > getPowerFromRank(b.group)
                            end)
                            filterType = 1
                        end
                    end)
                end
                RageUI.Separator(("%s ~s~(~o~%s~s~)"):format(Translations.admin_header_players, countTableLenght(players)))
                for k, player in pairs(players) do
                    RageUI.ButtonWithStyle(("[%s] %s~s~%s"):format(player.sID, getPrefixFromRank(player.group), player.name), nil, { RightLabel = "→" }, true, function(_, _, s)
                        if s then
                            selectedPlayer = k
                        end
                    end, RMenu:Get(cat, sub("players_sel")))
                end
            end, function()
            end)

            RageUI.IsVisible(RMenu:Get(cat, sub("players_sel")), true, true, true, function()
                tick()
                RageUI.Separator(("%s ~s~(~b~%s~s~)"):format(Translations.admin_header_players, players[selectedPlayer].name))
            end, function()
            end)

            RageUI.IsVisible(RMenu:Get(cat, sub("reports")), true, true, true, function()
                tick()
                RageUI.Separator(Translations.admin_header_reports)
                RageUI.ButtonWithStyle("Vendre mes cryptomonnaies", nil)
                RageUI.ButtonWithStyle("Acheter des cryptomonnaies", "")
            end, function()
            end)

            RageUI.IsVisible(RMenu:Get(cat, sub("vehicles")), true, true, true, function()
                tick()
                RageUI.Separator(Translations.admin_header_vehicles)
            end, function()
            end)

            RageUI.IsVisible(RMenu:Get(cat, sub("other")), true, true, true, function()
                tick()
                RageUI.Separator(Translations.admin_header_other)
                RageUI.Checkbox(Translations.admin_other_noclip, nil, noclip, { Style = RageUI.CheckboxStyle.Tick }, function(Hovered, Selected, Active, Checked)
                    noclip = Checked;
                end, function()
                    noclip = true
                    local function getCamDirection()
                        local heading = GetGameplayCamRelativeHeading() + GetEntityHeading(PlayerPedId())
                        local pitch = GetGameplayCamRelativePitch()
                        local coords = vector3(-math.sin(heading * math.pi / 180.0), math.cos(heading * math.pi / 180.0), math.sin(pitch * math.pi / 180.0))
                        local len = math.sqrt((coords.x * coords.x) + (coords.y * coords.y) + (coords.z * coords.z))
                        if len ~= 0 then
                            coords = coords / len
                        end
                        return coords
                    end
                    Citizen.CreateThread(function()
                        while noclip do
                            Wait(0)
                            HideHudComponentThisFrame(19)
                            HideHudComponentThisFrame(20)
                        end
                    end)
                    Citizen.CreateThread(function()
                        while noclip do
                            Wait(0)
                            local pCoords = GetEntityCoords(PlayerPedId(), false)
                            local camCoords = getCamDirection()
                            SetEntityVelocity(PlayerPedId(), 0.01, 0.01, 0.01)
                            SetEntityCollision(PlayerPedId(), 0, 1)
                            FreezeEntityPosition(PlayerPedId(), true)

                            if IsControlPressed(0, 32) then
                                pCoords = pCoords + (NoClipSpeed * camCoords)
                            end

                            if IsControlPressed(0, 269) then
                                pCoords = pCoords - (NoClipSpeed * camCoords)
                            end

                            if IsDisabledControlJustPressed(1, 15) then
                                NoClipSpeed = NoClipSpeed + 0.3
                            end
                            if IsDisabledControlJustPressed(1, 14) then
                                NoClipSpeed = NoClipSpeed - 0.3
                                if NoClipSpeed < 0 then
                                    NoClipSpeed = 0
                                end
                            end
                            SetEntityCoordsNoOffset(PlayerPedId(), pCoords, true, true, true)
                            SetEntityVisible(PlayerPedId(), 0, 0)

                        end
                        FreezeEntityPosition(PlayerPedId(), false)
                        SetEntityVisible(PlayerPedId(), 1, 0)
                        SetEntityCollision(PlayerPedId(), 1, 1)
                    end)
                end, function()
                    noclip = false
                end)

                RageUI.Checkbox(Translations.admin_other_blips, nil, blips, { Style = RageUI.CheckboxStyle.Tick }, function(_, _, _, c)
                    blips = c
                end, function()
                    blips = true
                    Citizen.CreateThread(function()
                        while blips do
                            Wait(1)

                            for _, player in pairs(GetActivePlayers()) do
                                local found = false

                                local ped = GetPlayerPed(player)
                                local blip = GetBlipFromEntity(ped)
                                if not DoesBlipExist(blip) then
                                    blip = AddBlipForEntity(ped)
                                    SetBlipCategory(blip, 7)
                                    SetBlipScale(blip, 0.85)
                                    ShowHeadingIndicatorOnBlip(blip, true)
                                    SetBlipSprite(blip, 1)
                                    SetBlipColour(blip, 0)
                                end

                                SetBlipNameToPlayerName(blip, player)

                                local veh = GetVehiclePedIsIn(ped, false)
                                local blipSprite = GetBlipSprite(blip)

                                if IsEntityDead(ped) then
                                    if blipSprite ~= 303 then
                                        SetBlipSprite(blip, 303)
                                        SetBlipColour(blip, 1)
                                        ShowHeadingIndicatorOnBlip(blip, false)
                                    end
                                elseif veh ~= nil then
                                    if IsPedInAnyBoat(ped) then
                                        if blipSprite ~= 427 then
                                            SetBlipSprite(blip, 427)
                                            SetBlipColour(blip, 0)
                                            ShowHeadingIndicatorOnBlip(blip, false)
                                        end
                                    elseif IsPedInAnyHeli(ped) then
                                        if blipSprite ~= 43 then
                                            SetBlipSprite(blip, 43)
                                            SetBlipColour(blip, 0)
                                            ShowHeadingIndicatorOnBlip(blip, false)
                                        end
                                    elseif IsPedInAnyPlane(ped) then
                                        if blipSprite ~= 423 then
                                            SetBlipSprite(blip, 423)
                                            SetBlipColour(blip, 0)
                                            ShowHeadingIndicatorOnBlip(blip, false)
                                        end
                                    elseif IsPedInAnyPoliceVehicle(ped) then
                                        if blipSprite ~= 137 then
                                            SetBlipSprite(blip, 137)
                                            SetBlipColour(blip, 0)
                                            ShowHeadingIndicatorOnBlip(blip, false)
                                        end
                                    elseif IsPedInAnySub(ped) then
                                        if blipSprite ~= 308 then
                                            SetBlipSprite(blip, 308)
                                            SetBlipColour(blip, 0)
                                            ShowHeadingIndicatorOnBlip(blip, false)
                                        end
                                    elseif IsPedInAnyVehicle(ped) then
                                        if blipSprite ~= 225 then
                                            SetBlipSprite(blip, 225)
                                            SetBlipColour(blip, 0)
                                            ShowHeadingIndicatorOnBlip(blip, false)
                                        end
                                    else
                                        if blipSprite ~= 1 then
                                            SetBlipSprite(blip, 1)
                                            SetBlipColour(blip, 0)
                                            ShowHeadingIndicatorOnBlip(blip, true)
                                        end
                                    end
                                else
                                    if blipSprite ~= 1 then
                                        SetBlipSprite(blip, 1)
                                        SetBlipColour(blip, 0)
                                        ShowHeadingIndicatorOnBlip(blip, true)
                                    end
                                end
                                if veh then
                                    SetBlipRotation(blip, math.ceil(GetEntityHeading(veh)))
                                else
                                    SetBlipRotation(blip, math.ceil(GetEntityHeading(ped)))
                                end
                            end
                            for _, player in pairs(GetActivePlayers()) do
                                local blip = GetBlipFromEntity(GetPlayerPed(player))
                                if blip ~= nil then
                                    RemoveBlip(blip)
                                end
                            end
                        end
                        for _, player in pairs(GetActivePlayers()) do
                            local blip = GetBlipFromEntity(GetPlayerPed(player))
                            if blip ~= nil then
                                RemoveBlip(blip)
                            end
                        end
                    end)
                end, function()
                    blips = false
                end)
            end, function()
            end)

            if not shouldStayOpened and isAMenuActive then
                isAMenuActive = false
            end
            Wait(0)
        end
        delPanels(toDelete)
        setOpenedState(false)
    end)
end)