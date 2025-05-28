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

## Decision

I will use JSON Schema Draft 7 since that's best supported in VS Code and I
don't really think I'll need any of the more recent features.

## Consequences

- 👍🏻 Best supported in VS Code.
- 👎🏻 Recent features of JSON Schema are not available.
