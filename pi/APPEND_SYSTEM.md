## Multi-model / second-opinion (Cursor)

Fusion (`fusion_*`, `/fusion`) is disabled on this host: Fusion children run with `--no-extensions`, so provider `cursor` (from `@rahularya01/pi-cursor`) is unknown there.

For a background second opinion or read-only investigation under Cursor, use `bg_delegate` with:

- `extensionMode: "ambient"` (required so `cursor` loads)
- `route: { provider: "cursor", model: "auto" }` or omit `route` to inherit the parent model
- `capability: "inspect"` (read/search/list only)
- then `bg_result` after the terminal notification

Do not call `fusion_reason`, `fusion_investigate`, `fusion_research`, or `fusion_validate`.
Do not use `bg_delegate` with default `isolated` mode when the route is `cursor/*`.

For multi-advisor debate, prefer `council-mode` / `subagent` with Cursor models instead of Fusion.
