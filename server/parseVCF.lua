function ParseVCF(xml, fileName)

    local vcf = {}
    fileName = string.sub(fileName, 1, -5)

    vcf.patterns = {}
    vcf.patterns.primary = {}
    vcf.patterns.secondary = {}
    vcf.patterns.rearreds = {}
    vcf.extras = {}
    vcf.sounds = {}

    -- Default Primary Lights pattern
    table.insert(vcf.patterns.primary, {duration = 80, extras = {1, 2}})
    table.insert(vcf.patterns.primary, {duration = 80, extras = {1, 2, 3, 4}})
    table.insert(vcf.patterns.primary, {duration = 80, extras = {3, 4}})
    table.insert(vcf.patterns.primary, {duration = 80, extras = {}})
    table.insert(vcf.patterns.primary, {duration = 80, extras = {1, 2}})

    -- Default Secondary Lights pattern
    table.insert(vcf.patterns.secondary, {duration = 280, extras = {6}})
    table.insert(vcf.patterns.secondary, {duration = 160, extras = {}})
    table.insert(vcf.patterns.secondary, {duration = 280, extras = {5}})
    table.insert(vcf.patterns.secondary, {duration = 160, extras = {}})

    -- Default Rear Red Lights pattern
    table.insert(vcf.patterns.rearreds, {duration = 160, extras = {9}})
    table.insert(vcf.patterns.rearreds, {duration = 160, extras = {}})
    table.insert(vcf.patterns.rearreds, {duration = 160, extras = {7}})
    table.insert(vcf.patterns.rearreds, {duration = 160, extras = {}})

    for i = 1, #xml.root.el do

        local rootElement = xml.root.el[i]

        if rootElement.name == 'EOVERRIDE' then
            for ex = 1, #rootElement.kids do
                local elem = rootElement.kids[ex]

                if string.upper(string.sub(elem.name, 1, -3)) == 'EXTRA' then
                    local extra = tonumber(string.sub(elem.name, -2))

                    vcf.extras[extra] = {}
                    vcf.extras[extra].enabled = elem.attr['IsElsControlled'] == 'true'
                    vcf.extras[extra].env_light = false
                    vcf.extras[extra].env_pos = {}
                    vcf.extras[extra].env_pos['x'] = 0
                    vcf.extras[extra].env_pos['y'] = 0
                    vcf.extras[extra].env_pos['z'] = 0
                    vcf.extras[extra].env_color = 'RED'

                    if elem.attr['AllowEnvLight'] == 'true' then
                        vcf.extras[extra].env_light = true
                        vcf.extras[extra].env_pos['x'] = tonumber(elem.attr['OffsetX'] or 0.0)
                        vcf.extras[extra].env_pos['y'] = tonumber(elem.attr['OffsetY'] or 0.0)
                        vcf.extras[extra].env_pos['z'] = tonumber(elem.attr['OffsetZ'] or 0.0)
                        vcf.extras[extra].env_color = string.upper(elem.attr['Color'] or 'RED')
                    end
                end
            end
        end

        if rootElement.name == 'SOUNDS' then
            vcf.sounds.nineMode = false

            for sid = 1, #rootElement.kids do
                local elem = rootElement.kids[sid]

                if elem.name == 'MainHorn' then
                    vcf.sounds.mainHorn = {}
                    vcf.sounds.mainHorn.allowUse = elem.attr['AllowUse'] == 'true'
                    vcf.sounds.mainHorn.audioString = elem.attr['AudioString'] or 'SIRENS_AIRHORN'
                    vcf.sounds.mainHorn.soundSet = elem.attr['SoundSet']
                end

                if elem.name == 'NineMode' then
                    vcf.sounds.nineMode = elem.attr['AllowUse'] == 'true'
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

                    for _, flash in ipairs(elem.kids) do
                        -- backwards compatibility for VCF's with 'FlashXX' tags
                        local tag = string.upper(string.sub(flash.name, 1, 5))

                        if tag == 'FLASH' then
                            vcf.patterns[type][id] = {}
                            vcf.patterns[type][id].extras = {}
                            vcf.patterns[type][id].duration = tonumber(flash.attr['Duration'] or '100')

                            for extra in string.gmatch(flash.attr['Extras'], '([0-9]+)') do
                                -- remove leading zero's
                                extra = string.format('%u', extra)

                                -- insert extra # in the table
                                table.insert(vcf.patterns[type][id].extras, tonumber(extra))
                            end

                            id = id + 1
                        end
                    end
                end
            end
        end

    end

    kjxmlData[fileName] = vcf

    print('ELS: Parsed VCF for ' .. fileName)
end
