--- @param xml table
--- @param fileName string
function ParseVCF(xml, fileName)

    local vcf = {
        patterns = {
            primary = {},
            secondary = {},
            rearreds = {},
        },
        extras = {},
        miscs = {},
        statics = {
            extras = {},
            miscs = {},
        },
        sounds = {},
    }

    fileName = string.sub(fileName, 1, -5)

    for i = 1, #xml.root.el do

        local rootElement = xml.root.el[i]

        if rootElement.name == 'EOVERRIDE' then
            for ex = 1, #rootElement.kids do
                local elem = rootElement.kids[ex]

                -- better way to filter if the current element contains an extra
                if string.find(elem.name, 'Extra', 1) then
                    -- if the string length is less then 7 chars, we assume a leading zero is missing
                    if (string.len(elem.name) < 7) then
                        -- use patternmatching to add a leading zero in front of the number
                    	elem.name = elem.name:gsub('(%d*%.?%d+)', '0%1')
                    end

                    -- extra should always have a leading zero here
                    local extra = tonumber(string.sub(elem.name, -2))

                    vcf.extras[extra] = {
                        enabled = true,
                        env_light = false,
                        env_pos = {
                            x = 0,
                            y = 0,
                            z = 0,
                        },
                        env_color = 'RED',
                    }

                    if elem.attr['AllowEnvLight'] == 'true' then
                        vcf.extras[extra].env_light = true
                        vcf.extras[extra].env_pos = {
                            x = tonumber(elem.attr['OffsetX'] or 0.0),
                            y = tonumber(elem.attr['OffsetY'] or 0.0),
                            z = tonumber(elem.attr['OffsetZ'] or 0.0),
                        }
                        vcf.extras[extra].env_color = string.upper(elem.attr['Color'] or 'RED')
                    end

                    -- backwards compatibility for VCF's without 'IsElsControlled' tag	
                    if elem.attr['IsElsControlled'] ~= nil then
                        vcf.extras[extra].enabled = elem.attr['IsElsControlled'] == 'true'
                    end
                elseif string.find(elem.name, 'Misc', 1) then
                    local misc = ConvertMiscNameToId(string.sub(elem.name, -1))

                    vcf.miscs[misc] = {
                        enabled = true,
                        env_light = false,
                        env_pos = {
                            x = 0,
                            y = 0,
                            z = 0,
                        },
                        env_color = 'RED',
                    }

                    if elem.attr['AllowEnvLight'] == 'true' then
                        vcf.miscs[misc].env_light = true
                        vcf.miscs[misc].env_pos = {
                            x = tonumber(elem.attr['OffsetX'] or 0.0),
                            y = tonumber(elem.attr['OffsetY'] or 0.0),
                            z = tonumber(elem.attr['OffsetZ'] or 0.0),
                        }
                        vcf.miscs[misc].env_color = string.upper(elem.attr['Color'] or 'RED')
                    end
                end
            end
        end

        if rootElement.name == 'STATIC' then
            for ex = 1, #rootElement.kids do
                local elem = rootElement.kids[ex]

                if string.upper(string.sub(elem.name, 1, -3)) == 'EXTRA' then
                    local extra = tonumber(string.sub(elem.name, -2))

                    if extra then
                        vcf.statics.extras[extra] = {}
                        vcf.statics.extras[extra].name = elem.attr['Name']
                    end
                elseif string.upper(string.sub(elem.name, 1, -2)) == 'MISC' then
                    local misc = ConvertMiscNameToId(string.sub(elem.name, -1))

                    vcf.statics.miscs[misc] = {}
                    vcf.statics.miscs[misc].name = elem.attr['Name']
                end
            end
        end

        if rootElement.name == 'SOUNDS' then
            for sid = 1, #rootElement.kids do
                local elem = rootElement.kids[sid]

                if elem.name == 'MainHorn' then
                    vcf.sounds.mainHorn = {}
                    vcf.sounds.mainHorn.allowUse = elem.attr['AllowUse'] == 'true'
                    vcf.sounds.mainHorn.audioString = elem.attr['AudioString'] or 'SIRENS_AIRHORN'
                    vcf.sounds.mainHorn.soundSet = elem.attr['SoundSet']
                end

                if string.upper(string.sub(elem.name, 1, -2)) == 'SRNTONE' then
                    local tone = string.sub(elem.name, -1)

                    vcf.sounds['srnTone' .. tone] = {}
                    vcf.sounds['srnTone' .. tone].allowUse = elem.attr['AllowUse'] == 'true'
                    vcf.sounds['srnTone' .. tone].audioString = elem.attr['AudioString']
                    vcf.sounds['srnTone' .. tone].soundSet = elem.attr['SoundSet']
                end
            end
        end

        if rootElement.name == 'PATTERN' then
            for pid = 1, #rootElement.kids do
                local elem = rootElement.kids[pid]
                local type = string.lower(elem.name)

                if TableHasValue({'primary', 'secondary', 'rearreds'}, type) then
                    local id = 1

                    -- whether the pattern toggles the 'emergency state', default is true
                    if elem.attr['IsEmergency'] then
                        vcf.patterns[type].isEmergency = elem.attr['IsEmergency'] == 'true'
                    else
                        vcf.patterns[type].isEmergency = true
                    end

                    -- whether the pattern toggles flashing the high beam, default is false
                    if elem.attr['FlashHighBeam'] then
                        vcf.patterns[type].flashHighBeam = elem.attr['FlashHighBeam'] == 'true'
                    else
                        vcf.patterns[type].flashHighBeam = false
                    end

                    -- whether the pattern enables a warning beep, default is false
                    if elem.attr['EnableWarningBeep'] then
                        vcf.patterns[type].enableWarningBeep = elem.attr['EnableWarningBeep'] == 'true'
                    else
                        vcf.patterns[type].enableWarningBeep = false
                    end

                    for _, flash in ipairs(elem.kids) do
                        -- backwards compatibility for VCF's with 'FlashXX' tags
                        local tag = string.upper(string.sub(flash.name, 1, 5))

                        if tag == 'FLASH' then
                            vcf.patterns[type][id] = {}
                            vcf.patterns[type][id].extras = {}
                            vcf.patterns[type][id].miscs = {}
                            vcf.patterns[type][id].duration = tonumber(flash.attr['Duration'] or '100')

                            for extra in string.gmatch(flash.attr['Extras'] or '', '([0-9]+)') do
                                -- remove leading zero's
                                extra = string.format('%u', extra)

                                -- insert extra # in the table
                                table.insert(vcf.patterns[type][id].extras, tonumber(extra))
                            end

                            for misc in string.gmatch(flash.attr['Miscs'] or '', '([a-z]+)') do
                                -- insert misc in the table
                                table.insert(vcf.patterns[type][id].miscs, ConvertMiscNameToId(misc))
                            end

                            id = id + 1
                        end
                    end
                end
            end
        end

    end

    VcfData[fileName] = vcf
end
