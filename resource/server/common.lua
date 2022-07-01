function DetermineOS ()
    local platform = nil

    local unix = os.getenv('HOME')
    local windows = os.getenv('HOMEPATH')

    Debug('info', 'Unix HOME env: ' .. (unix or 'not set'))
    Debug('info', 'Windows HOMEPATH env: ' .. (windows or 'not set'))

    if unix then platform = 'unix' end
    if windows then platform = 'windows' end

    -- this guy probably has some custom ENV var set...
    if unix and windows then
        error('Couldn\'t identify the OS unambiguously.')
    end

    Debug('info', 'Platform is ' .. platform)

    return platform
end
