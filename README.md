# Manipulation Authority Framework (MAF)

**Manipulation Authority Framework** is a Project Zomboid modding toolkit that allows creators to build custom rules, restrictions, and side effects for moving, dismantling, or destroying world objects.

It provides a centralized, event-driven pipeline that intercepts world interactions (like sledgehammering, picking up furniture, or dismantling structures) and allows multiple mods to register their own logic without conflicts.

## Key Features

- **Three-Phase Manipulation Pipeline**: Hooks for `validate`, `pre`, and `post` stages to control every part of a world interaction.
- **Priority-Based Rule Registration**: Multiple mods can add protection or logic rules, ordered by priority to ensure consistent behavior.
- **Comprehensive Action Support**: Provides global control over sledgehammer destruction, furniture relocation (moveables), and structure disassembly.
- **Sandbox Security Controls**: Server admins can easily toggle framework protections and configure performance limits through the sandbox menu.
- **Automatic Multi-Action Validation**: Rules trigger instantly whenever a player attempts to modify the environment, protecting bases and infrastructure.

## How It Works

The framework wraps core Project Zomboid actions (`ISDestroyStuffAction`, `ISDismantleAction`, `ISMoveablesAction`) and injects a standard processing pipeline:

1.  **Validate**: Lightweight check to decide if the action is allowed. If any rule sets `context.flags.rejected = true`, the action is blocked before it starts.
2.  **Pre-Action**: Fires just before the action completes successfully. Used for final validation or to record audits.
3.  **Post-Action**: Fires after the action has finished. Used for side effects, custom item drops, or logging.

### Supported Action Types

- `DestroyStuff`: Sledgehammering or destroying objects.
- `Dismantle`: Disassembling structures and furniture using tools.
- `Moveables`: Picking up, placing, rotating, or scrapping world objects.

---

## Usage for Modders

To use MAF, you simply require the framework and register your rule during initialization.

### Example: Shop Protection Rule

This rule prevents players from destroying or moving objects that belong to a "shop" (defined in modData).

```lua
local MAF = require("manipulation_authority_framework")

local function validateShopProtection(context)
    local object = context.object
    local character = context.character

    -- Check if object belongs to a shop owner in modData
    if object and object:getModData().shopOwner then
        local owner = object:getModData().shopOwner
        if owner ~= character:getUsername() then
            -- Block the action
            context.flags.rejected = true
            context.flags.reason = "This object belongs to " .. tostring(owner) .. "'s shop."
        end
    end
end

-- Register the rule: (phase, unique_id, callback, priority)
MAF:registerRule("validate", "my_mod:shop_protection", validateShopProtection, 100)
```

## Context Object

Every rule receives a `context` object containing:

- `actionType`: `DestroyStuff`, `Dismantle`, or `Moveables`.
- `character`: The `IsoPlayer` performing the action.
- `object`: The `IsoObject` being targeted.
- `square`: The `IsoGridSquare` where the object is located.
- `flags`: A table where you can set `rejected = true` or provide a `reason`.
- `data`: Additional data (e.g., `mode` for Moveables: "pickup", "place", etc.).

---

## Best For

- **Roleplay Servers**: Create complex property ownership and zoning laws.
- **Economy Mods**: Protect storefronts and public infrastructure.
- **Hardcore Survival**: Add wear-and-tear or weight restrictions to moving furniture.
- **Admin Tools**: Build robust auditing and logging systems for world changes.

---

## Technical Details (Performance)

MAF is designed to be extremely lightweight.

- Validation is cached per action instance to prevent redundant checks.
- Event listener limits can be configured in Sandbox options to prevent "laggy" server-side event storms.
- Errors in mod-provided rules are isolated using protected calls (`pcall`) to ensure server stability.
