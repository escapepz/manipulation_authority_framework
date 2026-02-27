-- Manipulation Authority Framework (MAF) Client Initialization
local ZUL = require("zul")
local logger = ZUL.new("manipulation_authority_framework_client")

-- Initialize Visual Phase Infrastructure
require("manipulation_authority_framework/manipulation_authority_visual")()

-- Initialize Client-side UI Patches
local client_patches = require("manipulation_authority_framework/patches/client_patches_init")
client_patches()

Events.OnGameStart.Add(function()
    logger:info("MAF Client visual phase infrastructure ready.")
end)
