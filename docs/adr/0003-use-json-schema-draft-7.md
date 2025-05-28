---
date: 2025-05-24
status: accepted
---
# 3. Use JSON Schema Draft 7

## Status

✅ Accepted

## Context

Having chosen JSON Schema for config file validation, there still remains the
question of which version to use.

- VS Code has good support for Draft 7
- The `json_schemer` gem supports Draft 7
- I don't really think I'll need any of the more recent features.

## Decision

I will use **JSON Schema Draft 7**.

## Alternatives Considered

- Using the latest version of JSON Schema (2020-12)

## Consequences

- 👍🏻 Easy to get editor integration
- 👎🏻 Recent features of JSON Schema are not available.
