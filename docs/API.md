# Nullwire API

## Construction

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/ImYasuf/Nullwire/refs/heads/master/Library.lua"))()
local Window = Library:CreateWindow({
    Title = "My Window",
    Subtitle = "My Script",
    Theme = "Dark",
    Width = 700,
    Height = 460,
    LoadingDuration = 0.65,
})
```

`CreateWindow` returns a window object. The loading screen is created immediately and the main window is built after the configured loading duration.

## Hierarchy

A window creates tabs. A tab can create components directly or create sections. Sections provide the same component methods in a visually grouped container.

```lua
local tab = Window:CreateTab({ Name = "Main", Icon = "home" })
local section = tab:CreateSection({ Name = "Settings" })
section:CreateButton({ Name = "Apply", Callback = function() end })
```

## Component signatures

| Constructor | Important options | Callback value |
|---|---|---|
| `CreateButton` | `Name`, `ButtonText`, `Callback` | None |
| `CreateToggle` | `Name`, `CurrentValue`, `Flag`, `Callback` | Boolean |
| `CreateSlider` | `Name`, `Range`, `Increment`, `CurrentValue`, `Flag`, `Callback` | Number |
| `CreateInput` | `Name`, `PlaceholderText`, `Flag`, `Callback` | String on focus loss |
| `CreateDropdown` | `Name`, `Options`, `CurrentOption`, `Flag`, `Callback` | Selected option |
| `CreateKeybind` | `Name`, `CurrentKeybind`, `Flag`, `Callback` | `Enum.KeyCode` |
| `CreateLabel` | `Name`, `TextSize` | None |
| `CreateParagraph` | `Name`, `Content` | None |
| `CreateDivider` | None | None |
| `CreateColorPicker` | `Name`, `Color`, `Callback` | `Color3` |

## Window methods

`Notify(options)` accepts `Title`, `Content`, `Icon`, `Duration`, and `Type`. `SetTheme(theme)` accepts a preset name or a table. `Search(query)` performs case-insensitive filtering across registered component names. `SetFlag`, `GetFlag`, `ResetConfig`, `SaveConfig`, and `LoadConfig` provide a small persistence-neutral state API. `Destroy()` removes the interface.

## Runtime contract

The host must provide Roblox-compatible constructors and services. The single file avoids Studio plugins, asset pipelines, filesystem calls, and third-party modules. Fetching the raw file and evaluating it returns the Library object directly; no `require`, ModuleScript, or project file path is involved. Persistence is deliberately left to the host so the library can run in environments with different storage policies.
