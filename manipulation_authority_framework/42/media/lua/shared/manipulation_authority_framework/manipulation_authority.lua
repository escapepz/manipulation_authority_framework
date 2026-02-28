---@meta
local pz_utils = require("pz_utils_shared")
local pz_commons = require("pz_lua_commons_shared")
local ZUL = require("zul")

local pcall = pcall
local tostring = tostring
local tonumber = tonumber
local pairs = pairs
local table_insert = table.insert

local middleclass = pz_commons.kikito.middleclass
local EventManager = pz_utils.escape.EventManager
local SandboxVarsModule = pz_utils.escape.SandboxVarsModule

local logger = ZUL.new("manipulation_authority_framework")

-- Localize strings for hot-path performance
-- Localize strings for hot-path performance
local VALIDATE_EV = "MAF:Validate"
local PREACTION_EV = "MAF:PreAction"
local POSTACTION_EV = "MAF:PostAction"

---@class ManipulationAuthority
---@field private _rules table<string, table>
---@field public VisualEvent string
---@field public ValidateEvent string
---@field public PreActionEvent string
---@field public PostActionEvent string
local ManipulationAuthority = middleclass("ManipulationAuthority")

function ManipulationAuthority:initialize()
    self.ValidateEvent = VALIDATE_EV
    self.PreActionEvent = PREACTION_EV
    self.PostActionEvent = POSTACTION_EV
    self.isReady = false
    self.pendingRules = {} -- Queue for early registrations

    -- Patch protection toggles, updated during loadConfig()
    self.config = {
        ISDestroyCursorProtection = true,
        ISMoveableCursorProtection = true,
        ISDestroyStuffActionProtection = true,
        ISDismantleActionProtection = true,
        ISMoveablesActionProtection = true,
        ISMoveableSpritePropsProtection = true,
    }
end

---Loads configuration from SandboxVars and sets up EventManager limits.
---Should be called during OnInitGlobalModData (server) or OnGameStart (client).
function ManipulationAuthority:loadConfig()
    -- 1. Initialize SandboxVars Config using factory pattern
    local mafSandbox

    if SandboxVarsModule then
        mafSandbox = SandboxVarsModule.Create("ManipulationAuthorityFramework", {
            ValidateEventListenersMax = 25,
            PreActionEventListenersMax = 50,
            PostActionEventListenersMax = 100,
            ISDestroyCursorProtection = true,
            ISMoveableCursorProtection = true,
            ISDestroyStuffActionProtection = true,
            ISDismantleActionProtection = true,
            ISMoveablesActionProtection = true,
            ISMoveableSpritePropsProtection = true,
        })
    end

    -- 2. Retrieve values from sandbox or use defaults
    local validateMax = 25
    local preMax = 50
    local postMax = 100

    if mafSandbox then
        validateMax = mafSandbox.Get("ValidateEventListenersMax", 25)
        preMax = mafSandbox.Get("PreActionEventListenersMax", 50)
        postMax = mafSandbox.Get("PostActionEventListenersMax", 100)

        self.config.ISDestroyCursorProtection = mafSandbox.Get("ISDestroyCursorProtection", true)
        self.config.ISMoveableCursorProtection = mafSandbox.Get("ISMoveableCursorProtection", true)
        self.config.ISDestroyStuffActionProtection =
            mafSandbox.Get("ISDestroyStuffActionProtection", true)
        self.config.ISDismantleActionProtection =
            mafSandbox.Get("ISDismantleActionProtection", true)
        self.config.ISMoveablesActionProtection =
            mafSandbox.Get("ISMoveablesActionProtection", true)
        self.config.ISMoveableSpritePropsProtection =
            mafSandbox.Get("ISMoveableSpritePropsProtection", true)
    end

    -- 3. Apply Limits from Sandbox
    EventManager.setMaxListeners(VALIDATE_EV, validateMax)
    EventManager.setMaxListeners(PREACTION_EV, preMax)
    EventManager.setMaxListeners(POSTACTION_EV, postMax)

    self.isReady = true
    self:_processPendingRules()
    logger:info("ManipulationAuthority initialized and ready.")
end

---Internal: Registers all pending rules from the queue.
function ManipulationAuthority:_processPendingRules()
    for _, rule in pairs(self.pendingRules) do
        self:_registerEvent(rule.eventName, rule.id, rule.callback, rule.priority)
    end
    -- Clear queue to free memory
    self.pendingRules = {}
end

---Internal helper to actually register with EventManager
function ManipulationAuthority:_registerEvent(eventName, id, callback, priority)
    EventManager.on(eventName, callback, priority)
    logger:info("Registered rule", { id = tostring(id), priority = tostring(priority or 0) })
end

---Creates a standardized context object for firing events
---@param actionType string The type of action (e.g., "DestroyCursor", "Dismantle")
---@param action any|nil The ISBaseTimedAction instance, if applicable
---@param object IsoObject|nil The target object being manipulated
---@param character IsoPlayer|nil The player performing the manipulation
---@param square IsoGridSquare|nil The square being targeted
---@param data any|nil Additional data (e.g., mode, tool indices)
---@return table context The initialized context object
function ManipulationAuthority:createContext(actionType, action, object, character, square, data)
    return {
        actionType = actionType,
        action = action,
        object = object,
        character = character,
        square = square,
        data = data,
        flags = { rejected = false, reason = nil, adminOverride = false },
        metadata = {},
    }
end

local function protectedTrigger(eventName, context)
    EventManager.trigger(eventName, context)
end

---Fires a specific phase event with the provided context
---@param phase string The phase name ("visual", "validate", "pre", "post")
---@param context table The context object created by `createContext`
---@return boolean success Returns true if event fired without errors
function ManipulationAuthority:processAction(phase, context)
    local eventName
    if phase == "validate" then
        eventName = VALIDATE_EV
    elseif phase == "pre" then
        eventName = PREACTION_EV
    elseif phase == "post" then
        eventName = POSTACTION_EV
    else
        logger:error("Invalid MAF Server phase requested: " .. tostring(phase))
        return false
    end

    -- Wrap in protected call to isolate mod errors (using pre-allocated function)
    local success, err = pcall(protectedTrigger, eventName, context)

    if not success then
        logger:error(
            "Error executing listeners for phase: " .. eventName,
            { error = tostring(err) }
        )
        return false
    end

    if context.flags.rejected then
        logger:debug("Action rejected during phase: " .. phase, {
            actionType = context.actionType,
            reason = context.flags.reason or "Unknown reason",
        })
    end

    return true
end

---Dumps diagnostic information about the framework status and listener counts.
function ManipulationAuthority:dumpDiagnostics()
    logger:info("--- MAF Server Diagnostics ---")
    logger:info("Status: " .. (self.isReady and "Ready" or "Initializing"))
    logger:info("Listeners: ", {
        validate = EventManager.getListenerCount(VALIDATE_EV),
        pre = EventManager.getListenerCount(PREACTION_EV),
        post = EventManager.getListenerCount(POSTACTION_EV),
    })
    logger:info("------------------------------")
end

---Registers a rule for a specific phase.
---@param phase string The phase ("visual", "validate", "pre", "post").
---@param id string A unique identifier for the rule.
---@param callback function The rule logic.
---@param priority number The priority (lower = earlier).
function ManipulationAuthority:registerRule(phase, id, callback, priority)
    local eventName
    if phase == "validate" then
        eventName = VALIDATE_EV
    elseif phase == "pre" then
        eventName = PREACTION_EV
    elseif phase == "post" then
        eventName = POSTACTION_EV
    else
        error("Invalid MAF Server phase: " .. tostring(phase))
    end

    if self.isReady then
        self:_registerEvent(eventName, id, callback, priority)
    else
        table_insert(self.pendingRules, {
            eventName = eventName,
            id = id,
            callback = callback,
            priority = priority,
        })
        logger:info("Queued rule for registration", { id = tostring(id) })
    end
end

---Engine Singleton Initialization
local function init()
    if not _G.ManipulationAuthorityFramework then
        _G.ManipulationAuthorityFramework = ManipulationAuthority()

        -- Load config on game start or boot depending on env
        local loadConfigFn = function()
            if _G.ManipulationAuthorityFramework then
                _G.ManipulationAuthorityFramework:loadConfig()
            end
        end

        if isServer() or not isClient() then
            Events.OnInitGlobalModData.Add(loadConfigFn)
        else
            Events.OnGameStart.Add(loadConfigFn)
        end
    end

    return _G.ManipulationAuthorityFramework
end

return init
