function ParseVehData(xml, fileName)

    local a = {}
    fileName = string.sub(fileName, 1, -5)

    a = {}
    a.patterns = {}
    a.patterns.primary = {}
    a.patterns.secondary = {}
    a.patterns.rearreds = {}
    a.patterns.scene = {}
    a.extras = {}
    a.sounds = {}

    --[[ Defaults for the Patterns ]] --
    -- Primary Lights Pattern
    table.insert(a.patterns.primary, {duration = 80, extras = {1, 2}})
    table.insert(a.patterns.primary, {duration = 80, extras = {1, 2, 3, 4}})
    table.insert(a.patterns.primary, {duration = 80, extras = {3, 4}})
    table.insert(a.patterns.primary, {duration = 80, extras = {}})
    table.insert(a.patterns.primary, {duration = 80, extras = {1, 2}})
    -- Secondary Lights Pattern
    table.insert(a.patterns.secondary, {duration = 280, extras = {6}})
    table.insert(a.patterns.secondary, {duration = 160, extras = {}})
    table.insert(a.patterns.secondary, {duration = 280, extras = {5}})
    table.insert(a.patterns.secondary, {duration = 160, extras = {}})
    -- Rear Red Lights Pattern
    table.insert(a.patterns.rearreds, {duration = 160, extras = {9}})
    table.insert(a.patterns.rearreds, {duration = 160, extras = {}})
    table.insert(a.patterns.rearreds, {duration = 160, extras = {7}})
    table.insert(a.patterns.rearreds, {duration = 160, extras = {}})
    --[[                           ]] --

    for i = 1, #xml.root.el do

        if (xml.root.el[i].name == "EOVERRIDE") then
            for ex = 1, #xml.root.el[i].kids do
                if (string.upper(string.sub(xml.root.el[i].kids[ex].name, 1, -3)) ==
                    "EXTRA") then
                    local elem = xml.root.el[i].kids[ex]
                    local extra = tonumber(string.sub(elem.name, -2))
                    a.extras[extra] = {}
                    if elem.attr['IsElsControlled'] == "true" then
                        a.extras[extra].enabled = true
                    else
                        a.extras[extra].enabled = false
                    end
                    if elem.attr['Secondary'] == "true" then
                        a.extras[extra].secondary = true
                    else
                        a.extras[extra].secondary = false
                    end

                    a.extras[extra].env_light = false
                    a.extras[extra].env_pos = {}
                    a.extras[extra].env_pos['x'] = 0
                    a.extras[extra].env_pos['y'] = 0
                    a.extras[extra].env_pos['z'] = 0
                    a.extras[extra].env_color = "RED"

                    if (elem.attr['AllowEnvLight'] == "true") then
                        a.extras[extra].env_light = true
                        a.extras[extra].env_pos = {}
                        a.extras[extra].env_pos['x'] = tonumber(
                                                           elem.attr['OffsetX'])
                        a.extras[extra].env_pos['y'] = tonumber(
                                                           elem.attr['OffsetY'])
                        a.extras[extra].env_pos['z'] = tonumber(
                                                           elem.attr['OffsetZ'])
                        a.extras[extra].env_color = string.upper(
                                                        elem.attr['Color'])
                    end
                end

            end
        end

        if (xml.root.el[i].name == "SOUNDS") then
            a.sounds.total = 0
            a.sounds.nineMode = false

            for ex = 1, #xml.root.el[i].kids do
                local elem = xml.root.el[i].kids[ex]

                if (xml.root.el[i].kids[ex].name == "MainHorn") then
                    a.sounds.mainHorn = {}
                    if elem.attr['InterruptsSiren'] == "true" then
                        a.sounds.mainHorn.interrupt = true
                    else
                        a.sounds.mainHorn.interrupt = false
                    end
                    a.sounds.mainHorn.audioString = elem.attr['AudioString']
                end

                if (xml.root.el[i].kids[ex].name == "NineMode") then
                    if elem.attr['AllowUse'] == "true" then
                        a.sounds.nineMode = true
                    end
                end

                if (xml.root.el[i].kids[ex].name == "SrnTone1") then
                    a.sounds.srnTone1 = {}
                    if elem.attr['AllowUse'] == "true" then
                        a.sounds.srnTone1.allowUse = true
                        a.sounds.total = a.sounds.total + 1
                    else
                        a.sounds.srnTone1.allowUse = false
                    end
                    a.sounds.srnTone1.audioString = elem.attr['AudioString']
                    a.sounds.srnTone1.soundSet = elem.attr['SoundSet']
                end

                if (xml.root.el[i].kids[ex].name == "SrnTone2") then
                    a.sounds.srnTone2 = {}
                    if elem.attr['AllowUse'] == "true" then
                        a.sounds.srnTone2.allowUse = true
                        a.sounds.total = a.sounds.total + 1
                    else
                        a.sounds.srnTone2.allowUse = false
                    end
                    a.sounds.srnTone2.audioString = elem.attr['AudioString']
                    a.sounds.srnTone2.soundSet = elem.attr['SoundSet']
                end

                if (xml.root.el[i].kids[ex].name == "SrnTone3") then
                    a.sounds.srnTone3 = {}
                    if elem.attr['AllowUse'] == "true" then
                        a.sounds.srnTone3.allowUse = true
                        a.sounds.total = a.sounds.total + 1
                    else
                        a.sounds.srnTone3.allowUse = false
                    end
                    a.sounds.srnTone3.audioString = elem.attr['AudioString']
                    a.sounds.srnTone3.soundSet = elem.attr['SoundSet']
                end

                if (xml.root.el[i].kids[ex].name == "SrnTone4") then
                    a.sounds.srnTone4 = {}
                    if elem.attr['AllowUse'] == "true" then
                        a.sounds.srnTone4.allowUse = true
                        a.sounds.total = a.sounds.total + 1
                    else
                        a.sounds.srnTone4.allowUse = false
                    end
                    a.sounds.srnTone4.audioString = elem.attr['AudioString']
                    a.sounds.srnTone4.soundSet = elem.attr['SoundSet']
                end
            end
        end

        if (xml.root.el[i].name == "PATTERN") then
            for type = 1, #xml.root.el[i].kids do -- Loop through the children of PATTERN.

                if (xml.root.el[i].kids[type].name == "PRIMARY") then -- IF PRIMARY
                    for flash = 1, #xml.root.el[i].kids[type].kids do -- Loop through the children of PRIMARY.

                        if (string.upper(string.sub(
                                             xml.root.el[i].kids[type].kids[flash]
                                                 .name, 1, -3)) == "FLASH") then -- IF STARTS WITH FLASH

                            local elem = xml.root.el[i].kids[type].kids[flash]
                            local flash = tonumber(string.sub(elem.name, -2))

                            a.patterns.primary[flash] = {}

                            local extras = {}
                            for extr in string.gmatch(elem.attr['Extras'],
                                                      '([^,]+)') do
                                table.insert(extras,
                                             tonumber(string.sub(extr, -2)))
                            end

                            a.patterns.primary[flash].extras = extras
                            a.patterns.primary[flash].duration = tonumber(
                                                                     elem.attr['Duration'])

                        end

                    end
                elseif (xml.root.el[i].kids[type].name == "SECONDARY") then -- IF SECONDARY
                    for flash = 1, #xml.root.el[i].kids[type].kids do -- Loop through the children of SECONDARY.

                        if (string.upper(string.sub(
                                             xml.root.el[i].kids[type].kids[flash]
                                                 .name, 1, -3)) == "FLASH") then -- IF STARTS WITH FLASH

                            local elem = xml.root.el[i].kids[type].kids[flash]
                            local flash = tonumber(string.sub(elem.name, -2))

                            a.patterns.secondary[flash] = {}

                            local extras = {}
                            for extr in string.gmatch(elem.attr['Extras'],
                                                      '([^,]+)') do
                                table.insert(extras,
                                             tonumber(string.sub(extr, -2)))
                            end

                            a.patterns.secondary[flash].extras = extras
                            a.patterns.secondary[flash].duration = tonumber(
                                                                       elem.attr['Duration'])

                        end

                    end
                elseif (xml.root.el[i].kids[type].name == "REARREDS") then -- IF REARREDS
                    for flash = 1, #xml.root.el[i].kids[type].kids do -- Loop through the children of REARREDS.

                        if (string.upper(string.sub(
                                             xml.root.el[i].kids[type].kids[flash]
                                                 .name, 1, -3)) == "FLASH") then -- IF STARTS WITH FLASH

                            local elem = xml.root.el[i].kids[type].kids[flash]
                            local flash = tonumber(string.sub(elem.name, -2))

                            a.patterns.rearreds[flash] = {}

                            local extras = {}
                            for extr in string.gmatch(elem.attr['Extras'],
                                                      '([^,]+)') do
                                table.insert(extras,
                                             tonumber(string.sub(extr, -2)))
                            end

                            a.patterns.rearreds[flash].extras = extras
                            a.patterns.rearreds[flash].duration = tonumber(
                                                                      elem.attr['Duration'])

                        end

                    end
                end

            end

        end

    end

    kjxmlData[fileName] = a

    print("ELS: Done with vehicle: " .. fileName)
end
