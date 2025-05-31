# MCP Compose

MCP Compose is a tool combining and customizing MCP servers using a declarative
yaml config file similar to how docker compose works.

[Project Vision](docs/vision.md)

## Usage

In a directory containing a `mcp-compose.yml` file, run:

```bash
mcp-compose
```

## Example `mcp-compose.yml`

<!-- examples/mcp-compose.yml begin -->
```yaml
name: My Tools

servers:
  hello_mcp:
    transport:
      type: stdio
      command: bundle exec main.rb
```
<!-- examples/mcp-compose.yml end -->
