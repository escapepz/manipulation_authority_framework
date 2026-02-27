---@meta
local pz_utils = require("pz_utils_shared")
local pz_commons = require("pz_lua_commons_shared")
local ZUL = require("zul")

local pcall = pcall
local tostring = tostring
local pairs = pairs
local table_insert = table.insert

local middleclass = pz_commons.kikito.middleclass
local EventManager = pz_utils.escape.EventManager
local SandboxVarsModule = pz_utils.escape.SandboxVarsModule

local logger = ZUL.new("manipulation_authority_framework_visual")

local VISUAL_EV = "MAF:Visual"

---@class ManipulationAuthorityVisual
local ManipulationAuthorityVisual = middleclass("ManipulationAuthorityVisual")

function ManipulationAuthorityVisual:initialize()
    self.VisualEvent = VISUAL_EV
    self.isReady = false
    self.pendingRules = {}

    -- Shared context table for high-frequency hooks to prevent GC stutters
    self.sharedVisualContext = {
        actionType = "",
        action = nil,
        object = nil,
        character = nil,
        flags = { rejected = false, reason = nil, adminOverride = false },
        metadata = {},
    }
end

---Loads configuration for visual limits.
function ManipulationAuthorityVisual:loadConfig()
    local visualMax = 25
    if SandboxVarsModule then
        local mafSandbox = SandboxVarsModule.Create("ManipulationAuthorityFramework", {
            VisualEventListenersMax = 25,
        })
        if mafSandbox then
            visualMax = mafSandbox.Get("VisualEventListenersMax", 25)
        end
    end

    EventManager.setMaxListeners(VISUAL_EV, visualMax)
    self.isReady = true
    self:_processPendingRules()
    logger:info("MAF Visual Infrastructure initialized.")
end

function ManipulationAuthorityVisual:_processPendingRules()
    for _, rule in pairs(self.pendingRules) do
        EventManager.on(VISUAL_EV, rule.callback, rule.priority)
        logger:info("Registered visual rule", { id = tostring(rule.id) })
    end
    self.pendingRules = {}
end

---Recycles the shared visual context object for per-frame hooks.
---@return table context The shared visual context object.
function ManipulationAuthorityVisual:getVisualContext(actionType, object, character, square, data)
    local ctx = self.sharedVisualContext
    ctx.actionType = actionType
    ctx.object = object
    ctx.character = character
    ctx.square = square
    ctx.data = data -- mode or additional tool data
    ctx.flags.rejected = false
    ctx.flags.reason = nil
    -- Reset metadata table if needed, but usually kept empty for visual checks
    for k in pairs(ctx.metadata) do ctx.metadata[k] = nil end
    return ctx
end

local function protectedTrigger(eventName, context)
    EventManager.trigger(eventName, context)
end

---Fires the visual phase event.
function ManipulationAuthorityVisual:processAction(context)
    local success, err = pcall(protectedTrigger, VISUAL_EV, context)
    if not success then
        logger:error("Error executing Visual listeners", { error = tostring(err) })
        return false
    end
    return true
end

---Dumps diagnostic information about the visual framework status.
function ManipulationAuthorityVisual:dumpDiagnostics()
    logger:info("--- MAF Visual Diagnostics ---")
    logger:info("Status: " .. (self.isReady and "Ready" or "Initializing"))
    logger:info("Listeners: ", {
        visual = EventManager.getListenerCount(VISUAL_EV),
    })
    logger:info("------------------------------")
end

---Registers a rule for the visual phase.
function ManipulationAuthorityVisual:registerRule(id, callback, priority)
    if self.isReady then
        EventManager.on(VISUAL_EV, callback, priority)
        logger:info("Registered visual rule", { id = tostring(id) })
    else
        table_insert(self.pendingRules, {
            id = id,
            callback = callback,
            priority = priority,
        })
    end
end

---Visual Singleton Initialization
local function init()
    if not _G.ManipulationAuthorityFrameworkVisual then
        _G.ManipulationAuthorityFrameworkVisual = ManipulationAuthorityVisual()

        -- In client env, we use OnGameStart to ensure SandboxVars are loaded
        Events.OnGameStart.Add(function()
            if _G.ManipulationAuthorityFrameworkVisual then
                _G.ManipulationAuthorityFrameworkVisual:loadConfig()
            end
        end)
    end
    return _G.ManipulationAuthorityFrameworkVisual
end

return init
