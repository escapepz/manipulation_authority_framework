-- Manipulation Authority Framework (MAF) Client Initialization
local ZUL = require("zul")
local logger = ZUL.new("manipulation_authority_framework_client")

-- Initialize Core Authority Framework (Shared)
require("manipulation_authority_framework/manipulation_authority")()

-- Initialize Visual Phase Infrastructure
local mafv = require("manipulation_authority_framework/manipulation_authority_visual")()

-- Initialize Client patches
local client_patches = require("manipulation_authority_framework/patches/client_patches_init")
client_patches()

logger:info("MAF Client Infrastructure initialized.")

return mafv
