local function AddHighBeamMenuEntry(vehicle)
    local checked = kjEnabledVehicles[vehicle].highBeamEnabled

    if WarMenu.CheckBox(Config.Translations.VehicleControlMenu.FlashingHighBeam, checked) then
        kjEnabledVehicles[vehicle].highBeamEnabled = not checked
    end
end

local function AddStaticExtraEntries(vehicle)
    local statics = kjxmlData[GetCarHash(vehicle)].statics

    for extra, info in spairs(statics) do
        local name = info.name or ('Extra ' .. extra)
        local checked = IsVehicleExtraTurnedOn(vehicle, extra) and true or false
        local extraExists = DoesExtraExist(vehicle, extra)

        if WarMenu.CheckBox(name, checked) and extraExists then
            -- disable auto repairs
            SetVehicleAutoRepairDisabled(vehicle, true)

            -- toggle the extra
            SetVehicleExtra(vehicle, extra, checked)
        end

        if not extraExists then
            if WarMenu.IsItemHovered() then
                WarMenu.ToolTip(Config.Translations.VehicleControlMenu.ExtraDoesNotExist)
            end
        end
    end
end

local function ShowMainMenu()
    Citizen.CreateThread(function ()
        WarMenu.OpenMenu('main')

        while true do
            local ped = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(ped)

            if WarMenu.Begin('main') then
                AddHighBeamMenuEntry(vehicle)
                AddStaticExtraEntries(vehicle)

                WarMenu.End()
            else return end

            Citizen.Wait(0)
        end
    end)
end

local function ToggleMainMenu()
    if WarMenu.IsAnyMenuOpened() then
        WarMenu.CloseMenu()
        return
    end

    ShowMainMenu()
end

local style = {
    backgroundColor = { 0, 0, 0, 200 },
    titleBackgroundColor = { 10, 60, 120, 200 },
    titleColor = { 255, 255, 255 },
    subTitleBackgroundColor = { 0, 0, 0, 200 },
    subTitleColor = { 88, 172, 217 },
}

WarMenu.CreateMenu('main', 'MISS ELS', Config.Translations.VehicleControlMenu.MenuTitle)
WarMenu.SetMenuStyle('main', style)

RegisterCommand('MISS-ELS:open-statics-menu', function ()
    if not CanControlELS() then return end

    ToggleMainMenu()
end)
