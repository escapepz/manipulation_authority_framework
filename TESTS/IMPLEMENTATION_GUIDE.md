# How to Implement a Test Suite for MAF (Lua 5.1 / Kahlua2)

This guide explains how to build and run a plain-Lua test suite for the Manipulation Authority Framework.

## Directory Structure
```
TESTS/
├── tests/
│   ├── mock_pz.lua                 # PZ API stubs
│   ├── test_framework.lua          # Minimal test runner
│   ├── test_rules_pruner.lua       # Integration test for pruning
│   └── maf_example_rules/
│       └── test_shop_protection.lua # Unit test for example rules
└── IMPLEMENTATION_GUIDE.md         # This file
```

## Running Tests
You can run the tests using any Lua 5.1 interpreter (e.g., `lua5.1` or `lua` if it points to 5.1).

### Via Command Line
```bash
cd TESTS/tests
lua test_rules_pruner.lua
lua maf_example_rules/test_shop_protection.lua
```

### Via VS Code
- Press `Ctrl+Shift+B` to run the active test task.
- Press `F5` to debug the active test.

## Writing New Tests
1. Create a new file in `TESTS/tests/`.
2. Requirement `test_framework` and `mock_pz`.
3. Call `mock_pz.setupGlobalEnvironment()`.
4. Register tests using `TestRunner.register("Name", function() ... end)`.
5. Run all tests at the end with `TestRunner.run()`.
