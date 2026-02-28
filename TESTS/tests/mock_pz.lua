---@diagnostic disable: global-in-non-module
-- mock_pz.lua - Minimal stubs for PZ APIs logic for MAF
local mock_pz = {}

-- 1. Global Tables Stubs
_G.ZomboidGlobals = {}
_G.Events = {
    OnInitGlobalModData = {
        Add = function(func)
            if not _G._initCallbacks then
                _G._initCallbacks = {}
            end
            table.insert(_G._initCallbacks, func)
        end,
    },
    OnGameStart = {
        Add = function(func)
            if not _G._initCallbacks then
                _G._initCallbacks = {}
            end
            table.insert(_G._initCallbacks, func)
        end,
    },
    OnGameBoot = {
        Add = function(func)
            if not _G._initCallbacks then
                _G._initCallbacks = {}
            end
            table.insert(_G._initCallbacks, func)
        end,
    },
}
_G.isServer = function()
    return true
end
_G.isClient = function()
    return false
end
_G.isMultiplayer = function()
    return false
end
_G.writeLog = function(category, message)
    if not _G._testLogs then
        _G._testLogs = {}
    end
    table.insert(_G._testLogs, { category = category, message = message })
end

-- 2. PZ Class Stubs
-- IsoPlayer (Character)
local IsoPlayer = {}
IsoPlayer.__index = IsoPlayer
function IsoPlayer.new(username)
    return setmetatable({ _username = username, _isAdmin = false }, IsoPlayer)
end
function IsoPlayer:getUsername()
    return self._username
end
function IsoPlayer:getAccessLevel()
    return self._isAdmin and "Admin" or "None"
end
mock_pz.IsoPlayer = IsoPlayer

-- IsoObject (Target object)
local IsoObject = {}
IsoObject.__index = IsoObject
function IsoObject.new(objectName)
    return setmetatable({ _objectName = objectName or "Object", _modData = {} }, IsoObject)
end
function IsoObject:getModData()
    return self._modData
end
function IsoObject:getObjectName()
    return self._objectName
end
mock_pz.IsoObject = IsoObject

-- IsoGridSquare
local IsoGridSquare = {}
IsoGridSquare.__index = IsoGridSquare
function IsoGridSquare.new(x, y, z)
    return setmetatable({ _x = x or 0, _y = y or 0, _z = z or 0 }, IsoGridSquare)
end
function IsoGridSquare:getX()
    return self._x
end
function IsoGridSquare:getY()
    return self._y
end
function IsoGridSquare:getZ()
    return self._z
end
mock_pz.IsoGridSquare = IsoGridSquare

-- 2.1 Action Mocks
_G.ISBaseTimedAction = {
    new = function(self, character)
        return setmetatable({ character = character }, { __index = self })
    end,
    stop = function() end,
}
_G.ISDestroyStuffAction = setmetatable({}, { __index = _G.ISBaseTimedAction })
_G.ISDismantleAction = setmetatable({}, { __index = _G.ISBaseTimedAction })
_G.ISMoveablesAction = setmetatable({}, { __index = _G.ISBaseTimedAction })
_G.ISMoveableSpriteProps = {}
_G.ISDestroyCursor = {}
_G.ISMoveableCursor = {}
_G.ISMoveableInfoWindow = {}
_G.ISMoveablesIconToolTip = {}

-- 3. Globals Injection
function mock_pz.setupGlobalEnvironment()
    _G.IsoPlayer = IsoPlayer
    _G.IsoObject = IsoObject
    _G.IsoGridSquare = IsoGridSquare

    -- Mock SandboxVars
    _G.SandboxVars = {
        ManipulationAuthorityFramework = {
            ValidateEventListenersMax = 25,
            PreActionEventListenersMax = 50,
            PostActionEventListenersMax = 100,
        },
    }

    -- Mock ManipulationAuthorityFramework singleton
    _G.ManipulationAuthorityFramework = nil

    -- Helper to trigger init events
    function mock_pz.triggerOnInit()
        ---@diagnostic disable-next-line: unnecessary-if
        if _G._initCallbacks then
            for _, func in ipairs(_G._initCallbacks) do
                func()
            end
        end
    end
end

return mock_pz
