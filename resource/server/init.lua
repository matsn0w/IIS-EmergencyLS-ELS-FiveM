--- The determined OS of the server
--- @type string|nil
SystemOS = nil

--- Check if there is a newer version of the resource available
local function checkForUpdate()
    local versionFile = LoadResourceFile(GetCurrentResourceName(), 'version.json')

    if not versionFile then
        print('Couldn\'t read version file!')
        return
    end

    local currentVersion = Semver(json.decode(versionFile)['version'] or 'unknown')

    if currentVersion.prerelease then
        print('WARNING: you are using a pre-release of MISS ELS!')
        print('>> This version might be unstable and probably contains some bugs.')
        print('>> Please report bugs and other problems via https://github.com/matsn0w/MISS-ELS/issues')
    end

    PerformHttpRequest('https://api.github.com/repos/matsn0w/MISS-ELS/releases/latest', function(status, response, headers)
        if status ~= 200 then
            print('Something went wrong! Couldn\'t fetch latest version. Status: ' .. tostring(status))
            return
        end

        local newVersion = Semver(json.decode(response)['tag_name'] or 'unknown')

        if newVersion > currentVersion then
            print('---------------------------- MISS ELS ----------------------------')
            print('--------------------- NEW VERSION AVAILABLE! ---------------------')
            print('>> You are using v' .. tostring(currentVersion))
            print('>> You can upgrade to v' .. tostring(newVersion))
            print()
            print('Download it at https://github.com/matsn0w/MISS-ELS/releases/latest')
            print('------------------------------------------------------------------')
        end
    end)
end

local function parseObjSet(data, fileName)
    local xml = SLAXML:dom(data)

    if xml and xml.root and xml.root.name == 'vcfroot' then ParseVCF(xml, fileName) end
end

local function loadVcfs(folder)
    for _, file in pairs(ScanDirectory(folder)) do
        local data = LoadFile(folder .. '/' .. file)

        if data then
            if pcall(function() parseObjSet(data, file) end) then
                --- no errors
                Print('Parsed VCF for: ' .. file, PrintColors.GREEN)
            else
                --- VCF is faulty, notify the user and continue
                Print('VCF file ' .. file .. ' could not be parsed: is your XML valid?', PrintColors.YELLOW)
            end
        else
            Print('VCF file ' .. file .. ' not found: does the file exist?', PrintColors.YELLOW)
        end
    end
end

AddEventHandler('onResourceStart', function(name)
    if not Config then
        error('You probably forgot to copy the example configuration file. Please see the installation instructions for further details.')
        StopResource(GetCurrentResourceName())
        CancelEvent()
        return
    end

    if name:lower() ~= GetCurrentResourceName():lower() then
        CancelEvent()
        return
    end

    Citizen.CreateThread(function()
        checkForUpdate()
    end)

    SystemOS = DetermineServerOS()

    if not SystemOS then
        error('Couldn\'t determine your OS! Are your running on steroids??')
    end

    Citizen.CreateThread(function()
        loadVcfs('xmlFiles')
    end)
end)
