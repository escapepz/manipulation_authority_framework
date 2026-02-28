-- tests/maf_example_rules/test_shop_protection.lua
local testFilePath = debug.getinfo(1).source:match("@?(.*/)")
package.path = testFilePath .. "../?.lua;" .. package.path
package.path = testFilePath
    .. "../../../manipulation_authority_framework/42/media/lua/shared/?.lua;"
    .. testFilePath
    .. "../../../manipulation_authority_framework/42/media/lua/server/?.lua;"
    .. package.path
package.path = testFilePath
    .. "../../../maf_example_rules/42/media/lua/server/?.lua;"
    .. package.path

-- Related project paths
package.path = testFilePath .. "../../../../zul/zul/42/media/lua/shared/?.lua;" .. package.path

local TestRunner = require("test_framework")
local mock_pz = require("mock_pz")
mock_pz.setupGlobalEnvironment()

-- Mock dependencies for MAF
local MockEventManager =
    { on = function() end, trigger = function() end, setMaxListeners = function() end }
_G.pz_utils_shared = {
    escape = {
        EventManager = MockEventManager,
        SafeLogger = {
            init = function() end,
            log = function() end,
            shouldLog = function()
                return true
            end,
        },
        SandboxVarsModule = {
            Create = function()
                return {
                    Get = function(_, _, def)
                        return def
                    end,
                }
            end,
        },
    },
}
_G.pz_lua_commons_shared = {
    kikito = {
        middleclass = function(name)
            local class = { name = name }
            class.__index = class
            setmetatable(class, {
                __call = function(c, ...)
                    local inst = setmetatable({}, c)
                    if inst.initialize then
                        inst:initialize(...)
                    end
                    return inst
                end,
            })
            return class
        end,
    },
}
_G.zul = {
    new = function()
        return { info = function() end, error = function() end, debug = function() end }
    end,
}

package.loaded["pz_utils_shared"] = _G.pz_utils_shared
package.loaded["pz_lua_commons_shared"] = _G.pz_lua_commons_shared
package.loaded["zul"] = _G.zul

-- Load MAF
_G.ManipulationAuthorityFramework = nil
local MAF = require("manipulation_authority_framework")

-- Spy on MAF.registerRule
local registeredSpy = {}
local real_registerRule = MAF.registerRule
function MAF:registerRule(phase, id, callback, priority)
    table.insert(
        registeredSpy,
        { phase = phase, id = id, callback = callback, priority = priority }
    )
    real_registerRule(self, phase, id, callback, priority)
end

-- Load the rule file
local shop_protection_rule = require("manipulation_authority_framework/rules/shop_protection_rule")

TestRunner.register("ShopProtection: Registers correctly", function()
    registeredSpy = {}
    MAF.isReady = false
    MAF.pendingRules = {}

    shop_protection_rule()
    mock_pz.triggerOnInit()

    local found = false
    for _, rule in ipairs(registeredSpy) do
        if rule.id == "shop_protection" and rule.phase == "validate" then
            found = true
            break
        end
    end
    TestRunner.assert_true(found, "Shop protection rule should be registered")
end)

TestRunner.register("ShopProtection: Blocks unauthorized access", function()
    local thief = mock_pz.IsoPlayer.new("Thief")
    local obj = mock_pz.IsoObject.new("Crate")
    obj:getModData().shopOwner = "ShopOwner"

    local context = {
        character = thief,
        object = obj,
        flags = { rejected = false, reason = nil },
    }

    shop_protection_rule()
    mock_pz.triggerOnInit()

    local callback = nil
    for _, rule in ipairs(registeredSpy) do
        if rule.id == "shop_protection" then
            callback = rule.callback
        end
    end

    TestRunner.assert_not_nil(callback, "Callback captured")
    ---@diagnostic disable-next-line: unnecessary-if
    if callback then
        callback(context)
    end

    TestRunner.assert_true(context.flags.rejected, "Should reject thief")
    TestRunner.assert_equals(context.flags.reason, "This object belongs to ShopOwner's shop.")
end)

TestRunner.register("ShopProtection: Allows owner access", function()
    local owner = mock_pz.IsoPlayer.new("ShopOwner")
    local obj = mock_pz.IsoObject.new("Crate")
    obj:getModData().shopOwner = "ShopOwner"

    local context = {
        character = owner,
        object = obj,
        flags = { rejected = false },
    }

    local callback = nil
    for _, rule in ipairs(registeredSpy) do
        if rule.id == "shop_protection" then
            callback = rule.callback
        end
    end

    ---@diagnostic disable-next-line: unnecessary-if
    if callback then
        callback(context)
    end
    TestRunner.assert_true(not context.flags.rejected, "Should allow owner")
end)

TestRunner.run()
