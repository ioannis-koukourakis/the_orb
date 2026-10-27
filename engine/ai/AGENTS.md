# Detis Engine scripting

This drop is scripted in Lua. The C++ source is not included. Use the names that belong to this build.

## Before you call an API

If the detis-engine MCP server is connected, call `lookup_lua` before using a function you have not already confirmed. A miss means that function is not in this build. Do not invent a nearby name.

`lookup_component` lists the component type strings stored in world files. `lookup_setting` reads the shipped default settings. `get_template` returns the world, entity, or module script template. `where` searches all of those.

If the server is not connected, read `engine/ai/engine_api.json` in this drop and the templates under `content/scripts/_templates/`.

## Script shape

Copy the matching template and keep its section order. Remove unused callbacks. Entity `@PARAMETER` lines are how the editor exposes fields.

World sections are DEPENDENCIES, HANDLERS, SETTINGS, PROPERTIES, HELPERS, CALLBACKS, LIFECYCLE.

Entity sections are DEPENDENCIES, HANDLERS, SETTINGS, PARAMETERS, PROPERTIES, HELPERS, INTERFACE, CALLBACKS, LIFECYCLE.

Module sections are DEPENDENCIES, HANDLERS, SETTINGS, PROPERTIES, INTERFACE, HELPERS, LIFECYCLE.

## Calls

`entity_get_is_valid` is the check for an entity id. A function you write returns one value, or none. A point or size is `vec2`. A rectangle is `vec4` (x, y, w, h).

Call another module with `module_get_is_valid` and `module_call_function`.
