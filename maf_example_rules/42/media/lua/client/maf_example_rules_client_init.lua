local maf_utils = require("maf_example_rules")

local SafeLogger = maf_utils.SafeLogger
local KUtilities = maf_utils.KUtilities

local function init()
    SafeLogger.log("[MAF] Initializing Example Rules (Client Visual)...", 30)
    -- MAF Example Rules Client Initialization
    require("maf_example_rules/rules/visual_cursor_example")()
    require("maf_example_rules/rules/visual_moveable_cursor_example")()
    require("maf_example_rules/rules/visual_sprite_props_example")()
    SafeLogger.log("[MAF] Example Rules (Client Visual) initialized.", 30)
end

---@param playerIndex integer
---@param context ISContextMenu
---@param worldObject IsoObject
local function DoContextMenu(playerIndex, context, worldObject)
    local playerObj = getSpecificPlayer(playerIndex)
    local isAdmin = KUtilities.IsPlayerAdmin(playerObj)

    local modData = worldObject:getModData()
    local indestructible = modData.indestructible or false
    local immovable = modData.immovable or false

    ---@type ItemContainer|nil
    local containerObj = worldObject:getContainer()

    -- used for disable zed target hit
    local thumpable = (containerObj and containerObj:getSquare():getThumpable(false)) or nil
    local thumpableN = (containerObj and containerObj:getSquare():getThumpable(true)) or nil

    local entityFullTypeDebug = worldObject:getEntityFullTypeDebug()
    if not entityFullTypeDebug then
        return
    end

    local objName = worldObject:getObjectName()

    -- guard again non thumpable objects
    -- if objName ~= "Thumpable" then
    --     return
    -- end

    -- Submenu (Registration/NPC/Management)
    local jOption = context:addOption("[SP] MAF Example Rules", worldObject, nil)
    local jMenu = ISContextMenu:getNew(context)
    context:addSubMenu(jOption, jMenu)

    jMenu:addOption(entityFullTypeDebug, worldObject, function() end)

    jMenu:addOption("indestructible [" .. tostring(indestructible) .. "]", worldObject, function()
        modData.indestructible = not indestructible
    end)
    jMenu:addOption("immovable [" .. tostring(immovable) .. "]", worldObject, function()
        modData.immovable = not immovable
    end)
    if thumpable then
        jMenu:addOption(
            "thumpable [" .. tostring(thumpable:isThumpable()) .. "]",
            worldObject,
            function()
                thumpable:setIsThumpable(not thumpable:isThumpable())
            end
        )
    end
    if thumpableN then
        jMenu:addOption(
            "thumpableN [" .. tostring(thumpableN:isThumpable()) .. "]",
            worldObject,
            function()
                thumpableN:setIsThumpable(not thumpableN)
            end
        )
    end

    -- Submenu (Admin Only)
    if isAdmin then
    end
end

local function onFillWorldObjectContextMenu(playerIndex, context, worldObjects)
    if worldObjects and #worldObjects > 0 then
        ---@type IsoObject
        local wObj = worldObjects and worldObjects[1] or nil
        ---@diagnostic disable-next-line: unnecessary-if
        if wObj and wObj:getContainer() then
            DoContextMenu(playerIndex, context, wObj)
        end
    end
end

Events.OnFillWorldObjectContextMenu.Add(onFillWorldObjectContextMenu)

Events.OnGameStart.Add(init)
