---
date: 2025-05-24
status: accepted
---
# 2. Use JSON Schema for config file validation

## Status

✅ Accepted

## Context

The `mcp-compose.yml` will have a fixed YAML format that should be validated
and I don't want to hand-write the validation logic.

## Decision

I will use JSON Schema to validate the config file and limit myself to simple
YAML features that will cleanly reduce to JSON.

## Consequences

- 👍🏻 I can use existing validation libraries to handle the validation for me as
  long as I have an up-to-date schema.
- 👍🏻 It's a well established format and thus other tools can easily re-use
  the schema (like editors).
- 👎🏻 There are advanced YAML features I cannot use.
