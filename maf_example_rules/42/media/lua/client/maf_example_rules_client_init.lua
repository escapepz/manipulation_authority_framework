local maf_utils = require("maf_example_rules")

local SafeLogger = maf_utils.SafeLogger
local KUtilities = maf_utils.KUtilities

local function init()
    -- redundant
    -- SafeLogger.log("[MAF] Initializing Example Rules (Client Visual)...", 30)
    -- MAF Example Rules Client Initialization
    -- require("maf_example_rules/rules/visual_cursor_example")()
    -- require("maf_example_rules/rules/visual_moveable_cursor_example")()
    -- require("maf_example_rules/rules/visual_sprite_props_example")()
    -- SafeLogger.log("[MAF] Example Rules (Client Visual) initialized.", 30)
end

-- ### 1. The "Soft-Block" Methods (`IsoObject`)

-- Apply these directly to an `IsoObject`. They are efficient because the game's Java core handles them after they are set once.

-- | Method                                            | Category        | Primary Purpose                                                                           |
-- | ------------------------------------------------- | --------------- | ----------------------------------------------------------------------------------------- |
-- | **`__IsoThumpable:setIsDismantable(false)`**      | **Scrap**       | Disables the "Dismantle" option (Hammer/Saw).                                             |
-- | **`__IsoThumpable:setIsThumpable(false)`**        | **Zombies**     | **Stops Zombie AI** from targeting or damaging the object.                                |
-- | **`__IsoThumpable:setHealth(999999)`**            | **Health**      | Makes the object practically indestructible against manual weapon hits.                   |
-- | **`__IsoObject:setOutlineOnMouseover(false)`**    | **Visual**      | Stops the object from glowing when the player looks at it.                                |
-- | **`__IsoObject:setSpecialTooltip(false)`**        | **Visual**      | Hides any hover-text or info popups.                                                      |
-- | ------------------------------------------------- | --------------- | ----------------------------------------------------------------------------------------- |

local function protectCrate(obj)
    ---@cast obj IsoObject|IsoThumpable
    local modData = obj:getModData()
    modData.isProtected = not modData.isProtected
    local protect = modData.isProtected
    local props = obj:getSprite():getProperties()

    if protect then
        -- 1. Strip Removal Permissions
        props:unset("IsMoveAble")
        props:unset("CanScrap")
        props:set("PickUpWeight", "999999")

        ---@diagnostic disable-next-line: unnecessary-if
        -- 2. Apply the Java Field Blocks
        if obj.setNoPicking then
            obj:setNoPicking(true)
        end
        ---@diagnostic disable-next-line: unnecessary-if
        if obj.setOutlineOnMouseover then
            obj:setOutlineOnMouseover(false)
        end

        ---@diagnostic disable-next-line: unnecessary-if
        -- 3. Health & AI
        if obj.setIsThumpable then
            obj:setIsThumpable(false)
        end
        ---@diagnostic disable-next-line: unnecessary-if
        if obj.setHealth then
            obj:setHealth(999999)
        end
    else
        -- REVERT
        props:set("IsMoveAble", "")
        props:set("CanScrap", "")
        props:unset("PickUpWeight")

        ---@diagnostic disable-next-line: unnecessary-if
        if obj.setNoPicking then
            obj:setNoPicking(false)
        end
        ---@diagnostic disable-next-line: unnecessary-if
        if obj.setOutlineOnMouseover then
            obj:setOutlineOnMouseover(true)
        end

        ---@diagnostic disable-next-line: unnecessary-if
        if obj.setIsThumpable then
            obj:setIsThumpable(true)
        end
        ---@diagnostic disable-next-line: unnecessary-if
        if obj.setHealth then
            obj:setHealth(100)
        end
    end
end

local function dumpObjectProperties(obj)
    if not obj or not obj:getSprite() then
        print("MAF: Cannot dump - Object or Sprite is nil.")
        return
    end

    local sprite = obj:getSprite()
    local props = sprite:getProperties()
    local propertyList = props:getPropertyNames() -- Returns a Java ArrayList<String>

    print("--- MAF PROPERTY DUMP: " .. tostring(sprite:getName()) .. " ---")

    -- Iterate through the Java ArrayList (0-indexed)
    for i = 0, propertyList:size() - 1 do
        local key = propertyList:get(i)
        local value = props:get(key) -- Use get() instead of Val()
        print("Property: [" .. tostring(key) .. "] | Value: [" .. tostring(value) .. "]")
    end

    -- Also check for standard Engine Flags (IsoFlagType)
    print("Checking Common Engine Flags:")
    local flags = { "CanBeRemoved", "NoSelect", "CantBePickedUp", "solidfloor", "exterior" }
    for _, flagName in ipairs(flags) do
        if props:has(flagName) then -- Use has() instead of Is()
            print("Flag Active: " .. flagName)
        end
    end

    print("--- END DUMP ---")
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
    local shopOwner = modData.shopOwner or nil
    local isShop = modData.isShop or false

    ---@type ItemContainer|nil
    local containerObj = worldObject:getContainer()

    local sq = (containerObj and containerObj:getSquare()) or nil

    -- used for disable zed target hit
    local thumpable = (sq and sq:getThumpable(false)) or nil
    local thumpableN = (sq and sq:getThumpable(true)) or nil

    -- local entityFullTypeDebug = worldObject:getEntityFullTypeDebug()
    -- if not entityFullTypeDebug then
    --     return
    -- end

    local objName = worldObject:getObjectName()

    -- guard again non thumpable objects
    -- if objName ~= "Thumpable" then
    --     return
    -- end

    -- Submenu (Registration/NPC/Management)
    local jOption = context:addOption("[SP] MAF Example Rules", worldObject, nil)
    local jMenu = ISContextMenu:getNew(context)
    context:addSubMenu(jOption, jMenu)

    -- jMenu:addOption(entityFullTypeDebug, worldObject, function() end)

    jMenu:addOption("indestructible [" .. tostring(indestructible) .. "]", worldObject, function()
        modData.indestructible = not indestructible
    end)
    jMenu:addOption("immovable [" .. tostring(immovable) .. "]", worldObject, function()
        modData.immovable = not immovable
    end)
    jMenu:addOption("isShop [" .. tostring(isShop) .. "]", worldObject, function()
        modData.isShop = not isShop
    end)
    jMenu:addOption("shopOwner [" .. tostring(shopOwner) .. "]", worldObject, function()
        modData.shopOwner = shopOwner
    end)
    jMenu:addOption("shopOwner ZombRand [" .. tostring(shopOwner) .. "]", worldObject, function()
        modData.shopOwner = "ZombRand(" .. tostring(ZombRand(1000)) .. ")"
    end)
    jMenu:addOption("shopOwner nil [" .. tostring(shopOwner) .. "]", worldObject, function()
        modData.shopOwner = nil
    end)
    if thumpable then
        jMenu:addOption(
            "thumpable:isThumpable [" .. tostring(thumpable:isThumpable()) .. "]",
            worldObject,
            function()
                thumpable:setIsThumpable(not thumpable:isThumpable())
            end
        )
        jMenu:addOption(
            "thumpable:isDismantable [" .. tostring(thumpable:isDismantable()) .. "]",
            worldObject,
            function()
                thumpable:setIsDismantable(not thumpable:isDismantable())
            end
        )
    end
    if thumpableN then
        jMenu:addOption(
            "thumpableN:isThumpable [" .. tostring(thumpableN:isThumpable()) .. "]",
            worldObject,
            function()
                thumpableN:setIsThumpable(not thumpableN:isThumpable())
            end
        )
        jMenu:addOption(
            "thumpableN:isDismantable [" .. tostring(thumpableN:isDismantable()) .. "]",
            worldObject,
            function()
                thumpableN:setIsDismantable(not thumpableN:isDismantable())
            end
        )
    end

    -- Soft-Block Toggle
    local isSoftBlocked = modData.softBlock or false
    jMenu:addOption("Soft-Block Toggle [" .. tostring(isSoftBlocked) .. "]", worldObject, function()
        isSoftBlocked = not isSoftBlocked
        modData.softBlock = isSoftBlocked

        local function apply(obj, state)
            if not obj then
                return
            end
            if obj.setIsDismantable then
                obj:setIsDismantable(not state)
            end
            if obj.setIsThumpable then
                obj:setIsThumpable(not state)
            end
            if obj.setHealth then
                obj:setHealth(state and 999999 or 100)
            end
            if obj.setOutlineOnMouseover then
                obj:setOutlineOnMouseover(not state)
            end
            if obj.setSpecialTooltip then
                obj:setSpecialTooltip(not state)
            end
        end

        apply(worldObject, isSoftBlocked)
        apply(thumpable, isSoftBlocked)
        apply(thumpableN, isSoftBlocked)
    end)

    jMenu:addOption("Dump Sprite Properties", worldObject, dumpObjectProperties)

    jMenu:addOption("Protect Crate", worldObject, protectCrate)

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

Events.OnGameStart.Add(init)
