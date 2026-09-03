# Nullwire

**Nullwire** is a premium, lightweight Luau UI library for Roblox-compatible runtimes. It provides a cyberpunk-inspired developer dashboard with a small, readable API, polished transitions, configuration helpers, search, notifications, and a set of practical controls. The implementation is original and does not copy source from other UI libraries.

> Nullwire is designed for legitimate interfaces and tools in runtimes that expose Roblox-compatible APIs. It does not provide exploit behavior, bypasses, or game automation.

## Name shortlist

The original shortlist considered for this project was **Nullwire**, **Blackglass**, **NeonKernel**, **Cipherline**, **Obsidian Relay**, **Ghostframe**, **Nightbyte**, **Signal Zero**, and **Hexloom**. **Nullwire** was selected because it is concise, distinctive, and communicates the library's dark developer-tool identity without tying the project to a particular game or runtime.

## Why Nullwire

Nullwire combines a focused black/charcoal visual system with restrained neon accents, responsive layout primitives, and a beginner-friendly component API. The library is delivered as one self-contained root-level `Library.lua` file and only relies on runtime-provided Roblox-compatible services such as `Instance`, `Color3`, `UDim2`, `TweenService`, `UserInputService`, `CoreGui`, and `HttpService`.

## Features

| Area | Included |
|---|---|
| Layout | Window, draggable header, tabs, sections, scrolling content |
| Controls | Buttons, toggles, sliders, inputs, dropdowns, keybinds, labels, paragraphs, dividers, color pickers |
| UX | Animated loading screen, hover-ready surfaces, tab transitions, search filtering, notification queue |
| Styling | Dark, Black, Cyber, and custom themes with accent, surfaces, text, stroke, radius, and transparency values |
| State | Flags, save/load/reset helpers, auto-load-friendly initialization pattern |
| Runtime | Standalone Luau module with no Studio-only workflow or third-party dependency |

## Installation

Fetch the root-level source from GitHub and execute it directly. The returned value is the Nullwire Library object; no ModuleScript, `require()`, project insertion, or internal file path is needed.

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/ImYasuf/Nullwire/master/Library.lua"))()
```

The `src/` directory contains the maintained source layout and preset reference for contributors. End users should use the root `Library.lua` distribution file.

## Quick start

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/ImYasuf/Nullwire/master/Library.lua"))()

local Window = Library:CreateWindow({
    Title = "Control Center",
    Subtitle = "Nullwire demo",
    Theme = "Black",
})

local Main = Window:CreateTab({ Name = "Main", Icon = "home" })
local Settings = Main:CreateSection({ Name = "Settings" })

Settings:CreateToggle({
    Name = "Enable telemetry",
    CurrentValue = true,
    Flag = "Telemetry",
    Callback = function(value)
        print("Telemetry:", value)
    end,
})

Settings:CreateButton({
    Name = "Run diagnostics",
    ButtonText = "RUN",
    Callback = function()
        Library:Notify({ Title = "Diagnostics", Content = "All systems nominal.", Duration = 4 })
    end,
})
```

## Components

Every component returns a small item object with `Frame`, `Control` where applicable, and `Value` for stateful controls. Callbacks are invoked asynchronously and receive the new value where appropriate.

### Button

```lua
Tab:CreateButton({
    Name = "Deploy",
    ButtonText = "RUN",
    Callback = function() print("Deploy requested") end,
})
```

### Toggle

```lua
Tab:CreateToggle({
    Name = "Enable feature",
    CurrentValue = false,
    Flag = "FeatureEnabled",
    Callback = function(value) print(value) end,
})
```

### Slider

The sample implementation advances by the configured increment when clicked. This predictable behavior is useful in keyboard- or touch-oriented runtimes; a custom drag control can be layered on top of the returned `Control` when the runtime exposes pointer gestures.

```lua
Tab:CreateSlider({
    Name = "Intensity",
    Range = { 0, 100 },
    Increment = 5,
    CurrentValue = 25,
    Callback = function(value) print(value) end,
})
```

### Input, dropdown, and keybind

```lua
Tab:CreateInput({ Name = "Username", PlaceholderText = "Enter username...", Callback = print })
Tab:CreateDropdown({ Name = "Mode", Options = { "Safe", "Fast", "Audit" }, Callback = print })
Tab:CreateKeybind({ Name = "Open console", CurrentKeybind = "F4", Callback = print })
```

### Labels, paragraphs, dividers, and color pickers

```lua
Tab:CreateLabel({ Name = "Connection: secure" })
Tab:CreateParagraph({ Name = "About", Content = "A compact explanation can live here." })
Tab:CreateDivider()
Tab:CreateColorPicker({ Name = "Highlight", Color = Color3.fromRGB(0, 220, 185), Callback = print })
```

## Notifications

Notifications stack in a dedicated queue and animate in and out.

```lua
Window:Notify({
    Title = "Saved",
    Content = "Your preferences were serialized.",
    Icon = "check",
    Duration = 5,
    Type = "Success",
})
```

## Themes

Choose `Dark`, `Black`, or `Cyber` at creation time. Custom values can be passed as `ThemeData`, or applied later with `SetTheme`.

```lua
local Window = Library:CreateWindow({ Theme = "Cyber" })
Window:SetTheme({
    Accent = Color3.fromRGB(0, 255, 210),
    Radius = 14,
    Transparency = 0.05,
})
```

The current implementation applies the theme to newly created UI elements. For a complete live restyle of already-created elements, recreate the window after changing the theme or extend the element registry with a project-specific restyle pass.

## Configuration

Nullwire exposes a persistence-neutral configuration layer. It serializes flags with the runtime's `HttpService`; your host decides where the returned string is stored.

```lua
local serialized = Window:SaveConfig()
-- Persist serialized using your approved storage adapter.
Window:ResetConfig()
Window:LoadConfig(serialized)

Window:SetFlag("Telemetry", true)
print(Window:GetFlag("Telemetry"))
```

This separation keeps the library independent from executor-specific filesystem APIs and from any particular persistence provider.

## API reference

| Method | Purpose |
|---|---|
| `Library:CreateWindow(options)` | Creates a window and animated loading screen. Options include `Title`, `Subtitle`, `Theme`, `ThemeData`, `Width`, `Height`, and `LoadingDuration`. |
| `Window:CreateTab(options)` | Adds a tab. Options include `Name` and optional `Icon`. |
| `Tab:CreateSection(options)` | Adds a section and returns a section-scoped component creator. |
| `Window:Notify(options)` | Adds an animated notification. Supports `Title`, `Content`, `Icon`, `Duration`, and `Type`. |
| `Window:SetTheme(theme)` | Merges a theme name or color/property table into the active theme. |
| `Window:Search(query)` | Filters registered components by name. |
| `Window:SetFlag(name, value)` / `GetFlag(name)` | Stores or reads configuration state. |
| `Window:SaveConfig()` / `LoadConfig(json)` / `ResetConfig()` | Serializes, restores, or clears flag state. |
| `Window:Destroy()` | Removes the UI and releases references. |

## Full example

See [`examples/Example.lua`](examples/Example.lua) for a runnable loadstring demonstration of all supported components and configuration hooks.

## Troubleshooting

If the window does not appear, verify that the host exposes `game:GetService`, `Instance.new`, `CoreGui` access, and the standard datatype constructors. If notifications or animations are static, verify that `TweenService` is available. If configuration serialization fails, use a host-provided JSON adapter or replace `SaveConfig` and `LoadConfig` with a persistence adapter appropriate to your environment.

## Credits

Created as an original open-source UI library concept by Manus AI. The visual language, API surface, and implementation are specific to Nullwire.

## License

Nullwire is released under the MIT License. See [`LICENSE`](LICENSE).
