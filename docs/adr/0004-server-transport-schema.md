---
date: 2025-05-29
status: accepted
---
# 4. Server Transport Schema

## Status

✅ Accepted

## Context

I want to represent the transport config of a server in a way that:

- Uses a single enum property to specify the transport type (for clear
  validation and good autocompletion)
- Keeps the top-level namespace clean of additional properties that only apply
  to a specific transport type (and if possible of any property that only
  relates to the "Transport" concern)
- Since we are using JSON Schema Draft 7 in
  [ADR 0003](./0003-use-json-schema-draft-7.md), we can't use the
  `discriminator` keyword

## Decision

I will use a nested structure under the common `transport` which contains the
`type` field and other transport-specific properties:

```yaml
servers:
  my_server:
    transport:
      type: stdio
      command: bundle exec my_server
      working_directory: /path/to/server
```

Validation will use a generic schema for `transport.type` with an enum of all
possible values combined via `allOf` and `oneOf` with one of the variants for
the specific transport type:

```json
{
  "allOf": [
    {
      "properties": {
        "type": { "enum": ["stdio", "streamable_http", "sse"] }
      }
    },
    {
      "oneOf": [
        {
          "properties": {
            "type": { "const": "stdio" }
            // stdio only fields
          }
        },
        // ...
      ]
    }
  ]
}
```

## Alternatives Considered

- All in top-level

  ```yaml
  servers:
    my_server:
      type: stdio
      command: bundle exec my_server
  ```

  - 👍🏻 Close in style to the Docker Compose config file (which is the
    inspiration for this format)
  - 👎🏻 Pollutes the top-level namespace with transport-specific properties

- One top-level property per transport type

  ```yaml
  servers:
    my_server:
      stdio:
        command: bundle exec my_server
  ```

  - 👍🏻 Seemed more DRY at first glance since the transport type is conveyed
    in the property name already
  - 👎🏻 JSON Schema does not easily allow for strict enum style choice between
    properties.
  - 👎🏻 The available options would not be obvious to the user.

## Consequences

- 👍🏻 Gives a good validation experience both before choosing a transport type
  and after
- 👎🏻 New transport types need to be added to two places (in the enum and in the
  schema for the specific transport type)
