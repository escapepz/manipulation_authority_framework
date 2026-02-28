local maf_utils = require("maf_example_rules")

local SafeLogger = maf_utils.SafeLogger
local KUtilities = maf_utils.KUtilities

---@param playerIndex integer
---@param context ISContextMenu
---@param worldObject IsoObject
local function DoContextMenu(playerIndex, context, worldObject)
    local playerObj = getSpecificPlayer(playerIndex)
    local isAdmin = KUtilities.IsPlayerAdmin(playerObj)

    local modData = worldObject:getModData()
    local indestructible = modData.indestructible or false
    local immovable = modData.immovable or false

    -- Submenu (Registration/NPC/Management)
    local jOption = context:addOption("[MP] MAF Example Rules", worldObject, nil)
    local jMenu = ISContextMenu:getNew(context)
    context:addSubMenu(jOption, jMenu)

    local function getObjectIndex(obj)
        local sq = obj:getSquare()
        if not sq then
            return -1
        end
        local objs = sq:getObjects()
        for i = 0, objs:size() - 1 do
            if objs:get(i) == obj then
                return i
            end
        end
        return -1
    end

    jMenu:addOption("indestructible [" .. tostring(indestructible) .. "]", worldObject, function()
        local args = {
            x = worldObject:getX(),
            y = worldObject:getY(),
            z = worldObject:getZ(),
            index = getObjectIndex(worldObject),
            key = "indestructible",
            value = not indestructible,
        }
        KUtilities.SendClientCommand("MAF_Example", "toggleModData", args)
    end)
    jMenu:addOption("immovable [" .. tostring(immovable) .. "]", worldObject, function()
        local args = {
            x = worldObject:getX(),
            y = worldObject:getY(),
            z = worldObject:getZ(),
            index = getObjectIndex(worldObject),
            key = "immovable",
            value = not immovable,
        }
        KUtilities.SendClientCommand("MAF_Example", "toggleModData", args)
    end)

    -- Submenu (Admin Only)
    if isAdmin then
    end
end

local function onFillWorldObjectContextMenu(playerIndex, context, worldObjects)
    if worldObjects and #worldObjects > 0 then
        ---@type IsoObject
        local wObj = worldObjects and worldObjects[1] or nil
        ---@diagnostic disable-next-line: unnecessary-if
        if wObj then --and wObj:getContainer() then
            DoContextMenu(playerIndex, context, wObj)
        end
    end
end

Events.OnFillWorldObjectContextMenu.Add(onFillWorldObjectContextMenu)
