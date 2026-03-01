local maf_utils = require("maf_example_rules")

local SafeLogger = maf_utils.SafeLogger

local pz_utils = require("pz_utils_shared")
local KUtilities = pz_utils.konijima.Utilities

local function init()
    SafeLogger.log("[MAF] Initializing Example Rules (Server Hooks)...", 30)

    -- MAF Example Rules Initialization
    require("maf_example_rules/rules/shop_protection_rule")()
    require("maf_example_rules/rules/audit_log_rule")()

    require("maf_example_rules/rules/destroy_stuff_example")()
    require("maf_example_rules/rules/dismantle_action_example")()
    require("maf_example_rules/rules/moveables_example")()

    require("maf_example_rules_server_commands")

    SafeLogger.log("[MAF] Example Rules (Server Hooks) initialized.", 30)
end

if KUtilities.IsServerOrSinglePlayer() then
    Events.OnGameBoot.Add(function()
        SafeLogger.log("[MAF] Applying server-side rules (Dedicated Server environment)...", 30)
        init()
    end)
end

if KUtilities.IsSinglePlayer() then
    Events.OnGameStart.Add(function()
        SafeLogger.log("[MAF] Applying server-side rules (SP/Local environment)...", 30)
        init()
    end)
end
