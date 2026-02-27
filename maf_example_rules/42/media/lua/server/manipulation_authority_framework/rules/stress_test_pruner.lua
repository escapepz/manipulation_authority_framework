local MAF = require("manipulation_authority_framework/manipulation_authority")()
local pz_utils = require("pz_utils_shared")
local SafeLogger = pz_utils.escape.SafeLogger
SafeLogger.init("maf_example_rules")

---Dummy validation rule for stress testing the pruner
local function createDummyValidator(ruleId)
	---@param context table
	return function(context)
		-- This is a no-op validator for testing purposes
		if SafeLogger.shouldLog and SafeLogger.shouldLog(10) then
			SafeLogger.log("[MAF] Stress test rule " .. ruleId .. " executed", 10)
		end
	end
end

return function()
	if not MAF then
		SafeLogger.log("[MAF] Error: MAF singleton missing during stress_test_pruner registration!", 50)
		return
	end

	-- Register 60 rules with priority numbers (1-60)
	-- Convention: LOWER numbers = HIGHER priority (0 is highest)
	-- The default ValidateEventListenersMax is 25
	for i = 1, 60 do
		local ruleId = "stress_test_" .. i
		local priority = i
		local validator = createDummyValidator(ruleId)

		MAF:registerRule("validate", ruleId, validator, priority)
	end

	SafeLogger.log("[MAF] Stress Test Pruner: Registered 60 rules (priorities 1-60)", 30)
	SafeLogger.log(
		"[MAF] Expected: With limit=25, keep LOWEST 25 priority numbers (stress_test_1 to stress_test_25), prune rest",
		30
	)
end
