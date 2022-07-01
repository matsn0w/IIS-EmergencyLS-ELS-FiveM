Platform = nil
VCFData = nil

AddEventHandler('onResourceStart', function (resourceName)
    if GetCurrentResourceName():lower() ~= resourceName:lower() then return end

    if not Config then
        Debug('error', 'Config not present')
        error('You probably forgot to copy the example configuration file. Please see the installation instructions for further details.')

        StopResource(GetCurrentResourceName())
        return
    end

    Print('==============================', Colors.BLUE)
    Print('Welcome to MISS ELS!', Colors.BLUE)
    Print('You are running v' .. GetResourceVersion(), Colors.BLUE)

    if Config.Debug then
        print()
        Print('Debugging is turned ' .. (Config.Debug and 'ON' or 'OFF') .. '.', Colors.BLUE)
    end

    local currentVersion = Semver(GetResourceVersion() or 'unknown')

    if currentVersion.prerelease then
        print()
        Print('WARNING: you are using a pre-release of MISS ELS!', Colors.YELLOW)
        Print('>> This version might be unstable and probably contains some bugs.', Colors.YELLOW)
        Print('>> Please report bugs and other problems via https://github.com/matsn0w/MISS-ELS/issues', Colors.YELLOW)
    end

    Print('==============================', Colors.BLUE)

    Platform = DetermineOS()

    if not Platform then
        error('Couldn\'t determine your OS! Are your running on steroids??')
    end

    CheckForUpdate()

    Citizen.CreateThread(function ()
        VCFData = LoadVCFs()
    end)
end)

AddEventHandler('onResourceStop', function (resourceName)
    if GetCurrentResourceName():lower() ~= resourceName:lower() then return end

    Print('I\'m sorry to see you go... Farewell my friend!')
end)
