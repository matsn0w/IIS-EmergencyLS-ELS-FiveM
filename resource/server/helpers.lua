function DetermineServerOS()
    local system = nil

    local unix = os.getenv('HOME')
    local windows = os.getenv('HOMEPATH')

    if unix then system = 'unix' end
    if windows then system = 'windows' end

    --- this guy probably has some custom ENV var set...
    if unix and windows then error('Couldn\'t identify the OS unambiguously.') end

    Debug.info('Determined server OS to be ' .. system)

    return system
end

--- @param folder string The folder to scan for VCF files (.xml)
function ScanDirectory(folder)
    local pathSeparator = '/'
    local command = 'ls -A'

    if SystemOS == 'windows' then
        pathSeparator = '\\'
        command = 'dir /R /B'
    end

    local resourcePath = GetResourcePath(GetCurrentResourceName())
    local directory = resourcePath .. pathSeparator .. folder
    local i, t, popen = 0, {}, io.popen
    local pfile = popen(command .. ' "' .. directory .. '"')

    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename
    end

    if #t == 0 then
        error('Couldn\'t find any VCF files. Are they in the correct directory?')
    end

    pfile:close()
    return t
end

function LoadFile(file)
    return LoadResourceFile(GetCurrentResourceName(), file)
end
