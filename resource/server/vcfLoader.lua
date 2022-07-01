local function ParseExtras (element)
    local extras = {}

    for i = 1, #element.kids do
        local elem = element.kids[i]

        if ArrayContains({'#text', '#comment'}, elem.name) then goto continue end

        Debug('info', 'Parsing ' .. elem.name)

        if string.upper(string.sub(elem.name, 1, -3)) ~= 'EXTRA' then
            Debug('warning', 'Invalid extra object \'' .. elem.name .. '\'')
            goto continue
        end

        -- if the string length is less then 7 chars, we assume a leading zero is missing
        if (string.len(elem.name) < 7) then
            -- use pattern matching to add a leading zero in front of the number
            elem.name = elem.name:gsub('(%d*%.?%d+)', '0%1')
        end

        -- extra should always have a leading zero here
        local extraIdString = string.sub(elem.name, -2)
        local extraId = tonumber(extraIdString)

        if not extraId then
            Debug('error', 'Invalid extra ID \'' .. extraIdString .. '\'')
            goto continue
        end

        local extra = {
            enabled = elem.attr['IsElsControlled'] == 'true',
            env_light = false,
            env_pos = {
                x = 0.0,
                y = 0.0,
                z = 0.0,
            },
            env_color = 'RED',
        }

        if elem.attr['AllowEnvLight'] == 'true' then
            extra.env_light = true
            extra.env_pos['x'] = tonumber(elem.attr['OffsetX'] or 0.0)
            extra.env_pos['y'] = tonumber(elem.attr['OffsetY'] or 0.0)
            extra.env_pos['z'] = tonumber(elem.attr['OffsetZ'] or 0.0)
            extra.env_color = string.upper(elem.attr['Color'] or 'RED')
        end

        extras[extraId] = extra

        ::continue::
    end

    return extras
end

local function ParseStatics (element)
    local statics = {}

    for i = 1, #element.kids do
        local elem = element.kids[i]

        if ArrayContains({'#text', '#comment'}, elem.name) then goto continue end

        Debug('info', 'Parsing static ' .. elem.name)

        if not string.upper(string.sub(elem.name, 1, -3)) == 'EXTRA' then
            Debug('warning', 'Invalid extra object \'' .. elem.name .. '\'')
            goto continue
        end

        -- if the string length is less then 7 chars, we assume a leading zero is missing
        if (string.len(elem.name) < 7) then
            -- use pattern matching to add a leading zero in front of the number
            elem.name = elem.name:gsub('(%d*%.?%d+)', '0%1')
        end

        local extraIdString = string.sub(elem.name, -2)
        local extraId = tonumber(extraIdString)

        if not extraId then
            Debug('error', 'Invalid static extra ID \'' .. extraIdString .. '\'')
            goto continue
        end

        local static = {
            name = elem.attr['Name']
        }

        statics[extraId] = static

        ::continue::
    end

    return statics
end

local function ParseSounds (element)
    local sounds = {
        nineMode = false,
        mainHorn = {
            allowUse = false,
            audioString = 'SIRENS_AIRHORN',
            soundSet = nil,
        },
    }

    for i = 1, #element.kids do
        local elem = element.kids[i]

        if ArrayContains({'#text', '#comment'}, elem.name) then goto continue end

        Debug('info', 'Parsing sound ' .. elem.name)

        if elem.name == 'MainHorn' then
            sounds.mainHorn.allowUse = elem.attr['AllowUse'] == 'true'
            sounds.mainHorn.audioString = elem.attr['AudioString'] or 'SIRENS_AIRHORN'
            sounds.mainHorn.soundSet = elem.attr['SoundSet']
        end

        if elem.name == 'NineMode' then
            sounds.nineMode = elem.attr['AllowUse'] == 'true'
        end

        if string.upper(string.sub(elem.name, 1, -2)) == 'SRNTONE' then
            local tone = string.sub(elem.name, -1)

            sounds['srnTone' .. tone] = {
                allowUse = elem.attr['AllowUse'] == 'true',
                audioString = elem.attr['AudioString'],
                soundSet = elem.attr['SoundSet'],
            }
        end

        ::continue::
    end

    return sounds
end

local function ParsePatterns (element)
    local patterns = {}

    for i = 1, #element.kids do
        local elem = element.kids[i]
        local type = string.upper(elem.name)

        if ArrayContains({'#text', '#comment'}, elem.name) then goto continue end

        Debug('info', 'Parsing pattern ' .. elem.name)

        if not ArrayContains({'PRIMARY', 'SECONDARY', 'REARREDS'}, type) then
            Debug('warning', 'Unknown pattern type \'' .. elem.name .. '\'')
            goto continue
        end

        local pattern = {
            isEmergency = true,
            flashHighBeam = false,
            enableWarningBeep = false,
            flashes = {},
        }

        -- whether the pattern toggles the 'emergency state'
        if elem.attr['IsEmergency'] then
            pattern.isEmergency = elem.attr['IsEmergency'] == 'true'
        end

        -- whether the pattern toggles flashing the high beam
        if elem.attr['FlashHighBeam'] then
            pattern.flashHighBeam = elem.attr['FlashHighBeam'] == 'true'
        end

        -- whether the pattern enables a warning beep
        if elem.attr['EnableWarningBeep'] then
            pattern.enableWarningBeep = elem.attr['EnableWarningBeep'] == 'true'
        end

        local flashId = 1

        for j = 1, #elem.kids do
            local flashElem = elem.kids[j]

            if ArrayContains({'#text', '#comment'}, flashElem.name) then goto skip end

            Debug('info', 'Parsing flash ' .. flashId)

            -- backwards compatibility for VCF's with 'FlashXX' tags
            local tag = string.upper(string.sub(flashElem.name, 1, 5))

            if tag ~= 'FLASH' then
                Debug('error', 'Invalid flash element \'' .. flashElem.name .. '\'')
                goto skip
            end

            local flash = {
                duration = tonumber(flashElem.attr['Duration'] or '100'),
                extras = {},
            }

            for extra in string.gmatch(flashElem.attr['Extras'] or '', '([0-9]+)') do
                -- remove leading zero's
                extra = string.format('%u', extra)

                -- insert extra # in the table
                table.insert(flash.extras, tonumber(extra))
            end

            table.insert(pattern.flashes, flash)
            flashId = flashId + 1

            ::skip::
        end

        patterns[type] = pattern

        ::continue::
    end

    return patterns
end

local function ScanDir (folder)
    local pathSeparator = '/'
    local command = 'ls -A'

    if Platform == 'windows' then
        pathSeparator = '\\'
        command = 'dir /R /B'
    end

    local resourcePath = GetResourcePath(GetCurrentResourceName())
    local directory = resourcePath .. pathSeparator .. folder
    local i, t, popen = 0, {}, io.popen
    local pfile = popen(command .. ' "' .. directory .. '"')

    if not pfile then
        error('Could not read directory ' .. directory)
    end

    for filename in pfile:lines() do
        Debug('info', 'Found file ' .. filename)
        i = i + 1
        t[i] = filename
    end

    if #t == 0 then
        error('Couldn\'t find any VCF files. Are they in the correct directory?')
    end

    pfile:close()
    return t
end

local function LoadFile(file)
    return LoadResourceFile(GetCurrentResourceName(), file)
end

local function ParseVCF (xml)
    -- initialize the configuration
    local vcf = {
        extras = {},
        statics = {},
        sounds = {},
        patterns = {
            primary = {},
            secondary = {},
            rearreds = {},
        },
    }

    for i = 1, #xml.root.el do
        local rootElement = xml.root.el[i]

        if rootElement.name == 'EOVERRIDE' then
            vcf.extras = ParseExtras(rootElement)
        end

        if rootElement.name == 'STATIC' then
            vcf.statics = ParseStatics(rootElement)
        end

        if rootElement.name == 'SOUNDS' then
            vcf.sounds = ParseSounds(rootElement)
        end

        if rootElement.name == 'PATTERN' then
            vcf.patterns = ParsePatterns(rootElement)
        end
    end

    return vcf
end

local function ParseXML(content)
    local xml = SLAXML:dom(content)

    if not xml or not xml.root or xml.root.name ~= 'vcfroot' then
        Debug('error', 'File contains invalid XML')
        return nil
    end

    return xml
end

function LoadVCFs ()
    local vcfs = {}

    local folder = 'xmlFiles'
    local files = ScanDir(folder)

    for _, file in ipairs(files) do
        local content = LoadFile(folder .. '/' .. file)

        if not content then
            Print('VCF file ' .. file .. ' not found: does the file exist?', Colors.YELLOW)
            goto continue
        end

        local xml = ParseXML(content)

        if not xml then
            -- VCF is faulty, notify the user and continue
            Print('VCF file ' .. file .. ' could not be parsed: is your XML valid?', Colors.RED)
        end

        Debug('info', 'Parsing file ' .. file)

        local vcf = ParseVCF(xml)
        table.insert(vcfs, vcf)

        Print('Parsed VCF for: ' .. file, Colors.GREEN)

        ::continue::
    end

    return vcfs
end
