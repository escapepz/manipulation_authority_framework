local function onClientCommand(module, command, player, args)
    if module == "MAF_Example" and command == "toggleModData" then
        local sq = getSquare(args.x, args.y, args.z)
        ---@diagnostic disable-next-line: unnecessary-if
        if sq then
            local obj = sq:getObjects():get(args.index)
            ---@diagnostic disable-next-line: unnecessary-if
            if obj then
                local modData = obj:getModData()
                modData[args.key] = args.value
                obj:transmitModData() -- Transmit to all clients
            end
        end
    end
end

Events.OnClientCommand.Add(onClientCommand)
