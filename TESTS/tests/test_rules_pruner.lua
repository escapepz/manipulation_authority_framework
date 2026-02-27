-- tests/test_rules_pruner.lua
local testFilePath = debug.getinfo(1).source:match("@?(.*/)")
package.path = testFilePath .. "?.lua;" .. package.path
package.path = testFilePath .. "../../manipulation_authority_framework/42/media/lua/server/?.lua;" .. package.path

-- Related project paths
package.path = testFilePath .. "../../../zul/zul/42/media/lua/shared/?.lua;" .. package.path

local TestRunner = require("test_framework")
local mock_pz = require("mock_pz")
mock_pz.setupGlobalEnvironment()

-- Mock dependencies deeply for standalone test
local MockEventManager = {
    events = {},
}

function MockEventManager.getOrCreateEvent(name)
    if not MockEventManager.events[name] then
        MockEventManager.events[name] = {
            listeners = {},
            maxListeners = nil,
            Add = function(self, callback, priority)
                table.insert(self.listeners, { f = callback, p = priority })
                table.sort(self.listeners, function(a, b)
                    return a.p > b.p
                end)
                self:_prune()
            end,
            SetMaxListeners = function(self, max)
                self.maxListeners = max
                self:_prune()
            end,
            _prune = function(self)
                if self.maxListeners and #self.listeners > self.maxListeners then
                    table.remove(self.listeners)
                end
            end,
            GetListenerCount = function(self)
                return #self.listeners
            end,
        }
    end
    return MockEventManager.events[name]
end

function MockEventManager.setMaxListeners(name, max)
    local event = MockEventManager.getOrCreateEvent(name)
    event:SetMaxListeners(max)
end

function MockEventManager.on(name, callback, priority)
    local event = MockEventManager.getOrCreateEvent(name)
    event:Add(callback, priority)
end

function MockEventManager.getListenerCount(name)
    local event = MockEventManager.getOrCreateEvent(name)
    return event:GetListenerCount()
end

_G.pz_utils_shared = {
    escape = {
        EventManager = MockEventManager,
        SandboxVarsModule = {
            Create = function(name, defaults)
                return {
                    Get = function(key, def) return def end
                }
            end
        }
    }
}
_G.pz_lua_commons_shared = {
    kikito = {
        middleclass = function(name)
            local class = { name = name }
            class.__index = class
            setmetatable(class, {
                __call = function(c, ...)
                    local inst = setmetatable({}, c)
                    if inst.initialize then inst:initialize(...) end
                    return inst
                end
            })
            return class
        end
    }
}
_G.zul = {
    new = function()
        return {
            info = function() end,
            error = function() end,
            debug = function() end
        }
    end
}

package.loaded["pz_utils_shared"] = _G.pz_utils_shared
package.loaded["pz_lua_commons_shared"] = _G.pz_lua_commons_shared
package.loaded["zul"] = _G.zul

-- Load MAF
local MAF_Init = require("manipulation_authority_framework/manipulation_authority")
local MAF = MAF_Init()

TestRunner.register("Pruner: Enforces limit of 10 listeners", function()
    -- Initialize MAF manually with custom limit
    MAF.config = {} -- Reset config
    
    -- Mock loadConfig to set specific low limit
    local real_loadConfig = MAF.loadConfig
    MAF.loadConfig = function(self)
        MockEventManager.setMaxListeners(self.ValidateEvent, 10)
        self.isReady = true
    end
    MAF:loadConfig()
    MAF.loadConfig = real_loadConfig -- Restore

    -- Flood with 20 rules
    for i = 1, 20 do
        MAF:registerRule("validate", "rule_" .. i, function() end, i * 10)
    end

    local count = MockEventManager.getListenerCount(MAF.ValidateEvent)
    TestRunner.assert_equals(count, 10, "Should have exactly 10 listeners")
    
    local event = MockEventManager.events[MAF.ValidateEvent]
    ---@diagnostic disable-next-line: unnecessary-if
    if event then
        TestRunner.assert_equals(event.listeners[1].p, 200, "Highest priority should remain")
        TestRunner.assert_equals(event.listeners[10].p, 110, "Lowest kept priority should be 110")
    end
end)

TestRunner.run()
