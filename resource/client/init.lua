kjEnabledVehicles = {}
kjxmlData = nil


Citizen.CreateThread(function()
	while not NetworkIsSessionStarted() do
		Citizen.Wait(100)
	end

    local DayBrightness = Config.DefaultLightBrightness.day
    local NightBrightness = Config.DefaultLightBrightness.night

    if GetResourceKvpFloat('elsdaybrightness') ~= 0.0 then
        DayBrightness = GetResourceKvpInt('elsdaybrightness')
    end

    if GetResourceKvpFloat('elsnightbrightness') ~= 0.0 then
        NightBrightness = GetResourceKvpFloat('elsnightbrightness')
    end


    -- adjust light intensity, without this it would be very dull.
    SetVisualSettingFloat("car.defaultlight.night.emissive.on", NightBrightness)
    SetVisualSettingFloat("car.defaultlight.day.emissive.on", DayBrightness)
end)

AddEventHandler('onClientResourceStart', function(name)
    if not Config then
        CancelEvent()
        return
    end

    if name:lower() ~= GetCurrentResourceName():lower() then
        CancelEvent()
        return
    end

    -- load audio banks
    for _, v in ipairs(Config.AudioBanks) do RequestScriptAudioBank(v, false) end
end)

RegisterNetEvent('kjELS:sendELSInformation')
AddEventHandler('kjELS:sendELSInformation', function(information) kjxmlData = information end)

RegisterNetEvent('kjELS:initVehicle')
AddEventHandler('kjELS:initVehicle', function()
    local vehicle = GetVehiclePedIsUsing(PlayerPedId())

    if kjEnabledVehicles[vehicle] == nil then AddVehicleToTable(vehicle) end
end)
