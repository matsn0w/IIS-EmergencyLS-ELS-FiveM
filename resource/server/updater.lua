function CheckForUpdate()
    local currentVersion = Semver(GetResourceVersion() or 'unknown')

    Citizen.CreateThread(function () 
        PerformHttpRequest('https://api.github.com/repos/matsn0w/MISS-ELS/releases/latest', function (status, response, headers)
            if status ~= 200 then
                Print('Couldn\'t fetch latest version. Status code: ' .. tostring(status), Colors.RED)
                return
            end

            local newVersion = Semver(json.decode(response)['tag_name'] or 'unknown')

            if newVersion > currentVersion then
                Print('============================ MISS ELS ============================', Colors.PINK)
                Print('--------------------- NEW VERSION AVAILABLE! ---------------------', Colors.PINK)
                Print('>> You are using v' .. tostring(currentVersion)                    , Colors.PINK)
                Print('>> You can upgrade to v' .. tostring(newVersion)                   , Colors.PINK)
                print()
                Print('Download it at https://github.com/matsn0w/MISS-ELS/releases/latest', Colors.PINK)
                Print('==================================================================', Colors.PINK)
            end
        end)
    end)
end