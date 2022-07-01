AddEventHandler('onClientResourceStart', function (resourceName)
    if GetCurrentResourceName():lower() ~= resourceName:lower() then return end
end)
