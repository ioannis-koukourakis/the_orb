# Hook up the Detis engine MCP

`detis_mcp` sits next to the engine executable in `bin`. On Windows the file is `detis_mcp.exe`. It answers Lua API, component, settings, and script template questions for any editor that speaks MCP. There is no install step.

Open the folder that contains `bin`, `engine`, and `content`. These files in that folder already point at `bin/detis_mcp`:

- `.cursor/mcp.json` for Cursor
- `.vscode/mcp.json` for VS Code
- `.mcp.json` for Claude Code

Claude Code asks you to approve the server the first time you open the folder.

Apps that keep their settings outside the project still need a paste. From the `bin` directory, run one of these:

- `detis_mcp --print-config cursor`
- `detis_mcp --print-config claude`
- `detis_mcp --print-config vscode`
- `detis_mcp --print-config generic`

Paste the printed JSON into that app's config. Cursor and Claude use `mcpServers`. VS Code uses `servers` in `.vscode/mcp.json`.

Those configs launch `bin/detis_mcp` on Windows and Linux. The Linux build writes that file. The Windows build writes `detis_mcp.exe` and copies it to `detis_mcp`, so the same path works.

Copy `AGENTS.md` from this folder to the root of the game project when that project is a different folder. Agents that only read project instructions then still see the scripting rules.

The server reads `engine_api.json` here, plus the templates and the default settings ini. It finds them from the executable path. The executable is expected in `bin`, with `engine` and `content` next to that folder. If the layout moves, start the server with `--root` set to the directory that contains `bin`, `engine`, and `content`.

Starting the engine rewrites `engine_api.json` when the C++ script API sources are available. A shipped drop keeps the catalog from that run.
