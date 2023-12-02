--- @type table All ELS enabled vehicles, keyed by network ID
ElsEnabledVehicles = {}

--- @type table All available VCF entries, keyed by vehicle model name
VcfData = nil

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

RegisterNetEvent('MISS-ELS:sendELSInformation')
AddEventHandler('MISS-ELS:sendELSInformation', function(information) VcfData = information end)

RegisterNetEvent('MISS-ELS:initVehicle')
AddEventHandler('MISS-ELS:initVehicle', function()
    local vehicle = VehToNet(GetVehiclePedIsUsing(PlayerPedId()))

    if ElsEnabledVehicles[vehicle] == nil then AddVehicleToTable(vehicle) end
end)
