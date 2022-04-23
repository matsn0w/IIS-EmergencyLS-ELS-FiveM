local function ShowNotification(text)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(text)
    DrawNotification(false, false)
end

-- create a menu
MenuPool = NativeUI.CreatePool()
local mainMenu = NativeUI.CreateMenu('MISS ELS', '~b~Static extras menu')
MenuPool:Add(mainMenu)

-- disable mouse input
MenuPool:ControlDisablingEnabled(false)
MenuPool:MouseControlsEnabled(false)

-- store menu entries
local extras = {}
local currentVehicle = nil

-- listen for changes
mainMenu.OnCheckboxChange = function(sender, item, checked)
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped)

    for k, v in pairs(extras) do
        local extra = v[2]

        if v[1] == item then
            if not DoesExtraExist(vehicle, extra) then
                ShowNotification('~r~Extra ' .. extra .. ' does not exist on this vehicle!')
                return
            end

            -- toggle the extra
            SetVehicleExtra(vehicle, v[2], checked and 0 or 1)
        end
    end
end

RegisterCommand('MISS-ELS:open-statics-menu', function ()
    -- toggle the menu visibility
    mainMenu:Visible(not mainMenu:Visible())
end)

Citizen.CreateThread(function()
    while true do
        if not kjxmlData then
            -- wait for the data to load
            while not kjxmlData do Citizen.Wait(0) end
        end

        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped)

        -- wait untill the player is in a vehicle
        while not IsPedInAnyVehicle(ped, false) do Citizen.Wait(0) end

        if IsELSVehicle(vehicle) and CanControlSirens(vehicle) then
            MenuPool:ProcessMenus()

            if vehicle ~= currentVehicle then
                mainMenu:Clear()
                extras = {}

                for extra, info in spairs(kjxmlData[GetCarHash(vehicle)].statics) do
                    local name = info.name or ('Extra ' .. extra)
                    local checked = extras[extra] or IsVehicleExtraTurnedOn(vehicle, extra)
                    local description = '~italic~Extra ' .. extra

                    -- create the new menu item for the extra
                    local newitem = NativeUI.CreateCheckboxItem(name, checked, description)

                    -- add the item to the menu
                    mainMenu:AddItem(newitem)

                    -- store the menu item
                    table.insert(extras, {newitem, extra})
                end

                -- check if there isn't any extra
                if #extras == 0 then
                    local nothing = NativeUI.CreateItem('No statics available...', 'Select to close the menu')
                    mainMenu:AddItem(nothing)
                    mainMenu.OnItemSelect = function(sender, item, index)
                        if item == nothing then
                            -- close the menu
                            mainMenu:Visible(false)
                        end
                    end
                end

                -- store this as the current vehicle
                currentVehicle = vehicle

                MenuPool:RefreshIndex()
            end
        end

        Citizen.Wait(0)
    end
end)
