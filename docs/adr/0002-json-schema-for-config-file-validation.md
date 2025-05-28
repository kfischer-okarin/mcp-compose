---
date: 2025-05-24
status: accepted
---
# 2. Use JSON Schema for config file validation

## Status

✅ Accepted

## Context

The `mcp-compose.yml` will have a fixed YAML format that should be validated

- I don't want to hand-write the validation logic
- JSON Schema is a well established format for validation and there are
  validation libraries (`json_schemer` for Ruby) that can be used

## Decision

I will use **JSON Schema** to validate the config file and limit myself to
simple YAML features that will cleanly reduce to JSON.

## Consequences

- 👍🏻 I can delegate the validation to existing validation libraries
- 👍🏻 It should be easy to get editor integration
- 👎🏻 There are advanced YAML features I cannot use.
- 👎🏻 The schema is now another artifact that needs to be maintained along with
  the code.
