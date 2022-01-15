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

            -- build menu if not done yet
            if not SetContains(kjEnabledVehicles, vehicle) then
                for extra, info in spairs(kjxmlData[GetCarHash(vehicle)].statics) do
                    local newitem = NativeUI.CreateCheckboxItem(info.name or ('Extra ' .. extra), extras[extra], '~italic~Extra ' .. extra)

                    -- add the item to the menu
                    mainMenu:AddItem(newitem)

                    -- store the menu item
                    table.insert(extras, {newitem, extra})
                end

                MenuPool:RefreshIndex()
            end

            if IsDisabledControlJustPressed(0, Config.KeyBinds.ExtrasMenu) then
                -- toggle the menu visibility
                mainMenu:Visible(not mainMenu:Visible())
            end
        end

        Citizen.Wait(0)
    end
end)
