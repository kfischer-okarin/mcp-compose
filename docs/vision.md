# Vision

## Motivation

The current common way of configuring MCP servers is not very user-friendly:

- It requires editing a JSON file in some hard to access directory on the
  user's system.
- Each MCP client has its own configuration file so it's annoying to reuse
  and sync the configuration between different MCP clients.
- The configuration file format is very rudimentary and lacks basic
  conveniences like working directory specifications, env file support.
- The situation just worsens if you want to have several different sets of
  MCP servers for different use cases.

Another limitation is that MCP servers provide their tools as-is and do not
allow to combine or add post-execution hooks to them to leave less room for
errors. Typical example would be to automatically run a code formatter after an
edit tool. If I just add this to the prompt or the tool description it is still
up to the model to remember to actually run it. Another example would be to
automatically return linter results after editing a file to make the feedback
loop tighter and more immediate.

## Solution Overview

- A MCP server which reads a YAML configuration file inspired by Docker
  Compose which allows to declare a set of MCP servers which should be
  aggregated, customized and served via its interface.
- MCP-server-config-as-code

## Target Users

- MCP server power users wanting to
  - use the power of configuration-as-code workflows
  - customize and optimize the tools they provide to their agents

## Core Design Principles

- Declarative configuration
- Sensible defaults but highly configurable when needed
- Portability between different MCP clients

## Features by Priority

- Forwarding of MCP server tools
- Stdio transport support
- .env file support
- Forwarding of MCP server resources
- Forwarding of MCP server prompts
- Stateless HTTP transport support
- Local Inspector web interface
- Disabling tools
- Custom additional instructions for tools
- Adding/Overriding tool annotations
- Overriding tool descriptions
- Post-tool execution hooks (what kind of format? Ruby scripts?) like
  automatically run formatter after edit tool
- Enable adding a reason meta argument to all tools (similar to the think tool
  proposed by Anthropic)
- Namespacing of tools, resources and prompts to avoid name conflicts
- mise integration
- Streamable HTTP transport support
- Full support of past MCP versions (SSE transport)

## Non-Goals

- Discovery and/or installation of MCP servers
