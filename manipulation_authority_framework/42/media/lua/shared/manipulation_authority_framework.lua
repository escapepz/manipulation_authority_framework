-- Manipulation Authority Framework (MAF) Shared Initialization
local maf = require("manipulation_authority_framework/manipulation_authority")()

-- Shared Patches (Loaded in all environments)
local shared_patches = require("manipulation_authority_framework/patches/shared_patches_init")
shared_patches()

return maf
