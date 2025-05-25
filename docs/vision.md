# Vision

## Problem

The current common way of configuring MCP servers is not very user-friendly:

- It requires editing a JSON file in some hard to access directory on the
  user's system.
- Each MCP client has its own configuration file so it's annoying to reuse
  and sync the configuration between different MCP clients.
- The configuration file format is very rudimentary and lacks basic
  conveniences like working directory specifications, env file support.
- The situation just worsens if you want to have several different sets of
  MCP servers for different use cases.

## Solution Overview

- A MCP server which reads a YAML configuration file inspired by Docker
  Compose which allows to declare a set of MCP servers which should be
  aggregated and served via its interface.
- MCP-server-config-as-code

## Target Users

- MCP server power users familiar with the power of configuration-as-code
  workflows

## Core Design Principles

- Declarative configuration
- Sensible defaults but highly configurable when needed
- Portability between different MCP clients

## Planned Key Features

- Forwarding of MCP server tools, resources and prompts
- All transports supported by the newest protocol version (Priority: Stdio,
  Stateless HTTP, Streamable HTTP)
- .env file support

## Possible Future Features

- mise integration
- Local settings web interface
- Full support of past MCP versions (SSE transport)

## Non-Goals

- Discovery and/or installation of MCP servers
