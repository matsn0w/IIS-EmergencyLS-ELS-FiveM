-- store menu entries
local menuItems = {}
local currentVehicle = nil

local function ShowNotification(text)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(text)
    DrawNotification(false, false)
end

local function ToggleMenu(menu)
    -- toggle the menu visibility
    menu:Visible(not menu:Visible())
end

local function AddHighBeamMenuEntry(menu, vehicle)
    if kjEnabledVehicles[vehicle] == nil then AddVehicleToTable(vehicle) end

    local checked = kjEnabledVehicles[vehicle].highBeamEnabled
    local newItem = NativeUI.CreateCheckboxItem("Flashing high beam", checked, "Enables/disables the flashing of high beams on the vehicle.")

    -- add the item to the menu
    menu:AddItem(newItem)

    -- store the menu item
    table.insert(menuItems, {newItem, checked, 'highBeam'})
end

local function AddStaticExtraEntries(menu, vehicle)
    local statics = kjxmlData[GetCarHash(vehicle)].statics

    for extra, info in spairs(statics) do
        local name = info.name or ('Extra ' .. extra)
        local checked = menuItems[extra] or IsVehicleExtraTurnedOn(vehicle, extra)
        local description = '~italic~Extra ' .. extra

        -- create the new menu item for the extra
        local newitem = NativeUI.CreateCheckboxItem(name, checked, description)

        -- add the item to the menu
        menu:AddItem(newitem)

        -- store the menu item
        table.insert(menuItems, {newitem, extra, 'extra'})
    end
end

-- create a menu pool
MenuPool = NativeUI.CreatePool()

-- create a menu
local mainMenu = NativeUI.CreateMenu('MISS ELS', '~b~Vehicle Control Menu')
MenuPool:Add(mainMenu)

-- listen for changes
mainMenu.OnCheckboxChange = function(sender, item, checked)
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped)

    for _, v in pairs(menuItems) do
        local menuItem = v[1]
        local setting = v[2]
        local type = v[3]

        if menuItem == item then
            if type == 'extra' then
                if not DoesExtraExist(vehicle, setting) then
                    ShowNotification('~r~Extra ' .. setting .. ' does not exist on this vehicle!')
                    return
                end

                -- disable auto repairs
                SetVehicleAutoRepairDisabled(vehicle, true)

                -- toggle the extra
                SetVehicleExtra(vehicle, setting, checked and 0 or 1)
            end

            if type == 'highBeam' then
                kjEnabledVehicles[vehicle].highBeamEnabled = checked
            end
        end
    end
end

-- disable mouse input
MenuPool:ControlDisablingEnabled(false)
MenuPool:MouseControlsEnabled(false)

Citizen.CreateThread(function()
    while true do
        local function process()
            -- wait for the data to load
            while not kjxmlData do Citizen.Wait(0) end
            while not kjEnabledVehicles do Citizen.Wait(0) end

            local ped = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(ped)

            -- wait untill the player is in a vehicle
            while not IsPedInAnyVehicle(ped, false) do Citizen.Wait(0) end

            -- wait untill the player is in an ELS enabled vehicle and can control the sirens
            if not IsELSVehicle(vehicle) or not CanControlSirens(vehicle) then return end

            MenuPool:ProcessMenus()

            if vehicle ~= currentVehicle then
                -- reset the menu
                mainMenu:Clear()

                -- insert menu entries
                AddHighBeamMenuEntry(mainMenu, vehicle)
                AddStaticExtraEntries(mainMenu, vehicle)

                -- store this as the current vehicle
                currentVehicle = vehicle

                MenuPool:RefreshIndex()
            end
        end

        process()
        Citizen.Wait(0)
    end
end)

RegisterCommand('MISS-ELS:open-statics-menu', function ()
    ToggleMenu(mainMenu)
end)
