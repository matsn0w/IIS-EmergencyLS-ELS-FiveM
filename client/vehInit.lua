kjEnabledVehicles = {}
kjxmlData = nil

DisableControlAction(0, 73, true)
DisableControlAction(0, 81, true)
DisableControlAction(0, 84, true) -- INPUT_VEH_PREV_RADIO_TRACK  
DisableControlAction(0, 83, true) -- INPUT_VEH_NEXT_RADIO_TRACK 
DisableControlAction(0, 82, true) -- INPUT_VEH_PREV_RADIO
DisableControlAction(0, 85, true) -- INPUT_VEH_PREV_RADIO
DisableControlAction(0, 58, true)
DisableControlAction(0, 80, true)
DisableControlAction(1, 80, true)

function addVehicleToTable(vehicle)
    kjEnabledVehicles[vehicle] = {}
    kjEnabledVehicles[vehicle]["primary"] = false
    kjEnabledVehicles[vehicle]["secondary"] = false
    kjEnabledVehicles[vehicle]["warning"] = false
    kjEnabledVehicles[vehicle]["siren"] = 0
    kjEnabledVehicles[vehicle]["sound"] = nil

    TriggerEvent("kjELS:resetExtras", vehicle)
end

RegisterNetEvent("kjELS:sendELSInformation")

AddEventHandler("kjELS:sendELSInformation",
                function(information) kjxmlData = information end)
