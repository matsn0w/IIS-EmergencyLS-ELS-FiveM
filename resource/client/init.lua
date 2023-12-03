--- @type table All ELS enabled vehicles, keyed by network ID
ElsEnabledVehicles = {}

--- @type table All available VCF entries, keyed by vehicle model name
VcfData = nil

local function loadAudioBanks()
    for _, bank in ipairs(Config.AudioBanks) do
        Debug.info('Requesting audio bank ' .. bank)
        RequestScriptAudioBank(bank, false)
    end
end

AddEventHandler('onClientResourceStart', function(name)
    if not Config then
        CancelEvent()
        return
    end

    if name:lower() ~= GetCurrentResourceName():lower() then
        CancelEvent()
        return
    end

    loadAudioBanks()
end)

RegisterNetEvent('MISS-ELS:client:sendElsInformation')
AddEventHandler('MISS-ELS:client:sendElsInformation', function(information)
    VcfData = information
end)
