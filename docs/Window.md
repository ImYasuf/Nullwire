# Window Guide

The **Window** is the top-level interface returned by `Library:CreateWindow(...)`. It owns the visual shell, navigation area, content area, notifications, theme state, search behavior, configuration flags, and cleanup lifecycle.

## Load the library

Nullwire is distributed as one raw Lua file. The loader returns the Library object directly.

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/ImYasuf/Nullwire/refs/heads/master/Library.lua"))()
```

## Create a window

```lua
local Window = Library:CreateWindow({
    Title = "Control Center",
    Subtitle = "Operations dashboard",
    Theme = "Black",
    Width = 760,
    Height = 500,
    LoadingDuration = 0.65,
})
```

The interactive window is built before `CreateWindow` returns. You can create the first tab on the next line without waiting for the loading animation:

```lua
local Main = Window:CreateTab({ Name = "Main", Icon = "home" })
```

### Window options

| Option | Type | Description |
|---|---|---|
| `Title` | string | Main heading displayed in the window header. |
| `Subtitle` | string | Smaller descriptive text below the title. |
| `Theme` | string | Preset theme: `Dark`, `Black`, or `Cyber`. |
| `ThemeData` | table | Custom colors and visual properties merged into the selected preset. |
| `Width` | number | Window width in pixels; defaults to `700`. |
| `Height` | number | Window height in pixels; defaults to `460`. |
| `LoadingDuration` | number | Reserved loading-screen timing option. The loading animation never blocks window or tab creation. |

## Add notifications

Notifications are displayed in a queued stack attached to the window. They animate into view and are removed after `Duration` seconds.

```lua
Window:Notify({
    Title = "Settings saved",
    Content = "Your preferences were stored successfully.",
    Icon = "check",
    Type = "Success",
    Duration = 5,
})
```

The returned Library object also exposes a convenience proxy to the active window:

```lua
Library:Notify({
    Title = "Ready",
    Content = "The dashboard is online.",
    Duration = 4,
})
```

## Change the theme

Select a preset during creation or merge custom values later.

```lua
local Window = Library:CreateWindow({ Theme = "Cyber" })

Window:SetTheme({
    Accent = Color3.fromRGB(0, 255, 210),
    Background = Color3.fromRGB(7, 10, 13),
    Text = Color3.fromRGB(240, 255, 252),
    Radius = 12,
    Transparency = 0.05,
})
```

Theme values affect controls created after the change. For a fully restyled interface, select the desired theme before creating the window.

## Search the window

The header includes a search field. It filters registered components by their `Name` value. You can also call the method directly:

```lua
Window:Search("telemetry")
Window:Search("") -- Clear the filter.
```

## Configuration and flags

Flags provide a persistence-neutral way to store control values. The host application decides how the serialized string is saved.

```lua
Window:SetFlag("Telemetry", true)
local enabled = Window:GetFlag("Telemetry")

local serialized = Window:SaveConfig()
-- Save `serialized` using your approved persistence adapter.

Window:ResetConfig()
Window:LoadConfig(serialized)
```

Pass `Flag = "Telemetry"` to a toggle, slider, input, or dropdown to associate the control with a flag.

## Close and destroy

Destroy the window when the host no longer needs it:

```lua
Window:Destroy()
```

This removes the main interface and any remaining loading screen. A new window can then be created with `Library:CreateWindow(...)`.

## Complete Window example

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/ImYasuf/Nullwire/refs/heads/master/Library.lua"))()

local Window = Library:CreateWindow({
    Title = "Control Center",
    Subtitle = "Window guide",
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

Library:Notify({
    Title = "Window ready",
    Content = "The first tab was created immediately.",
    Duration = 4,
})
```
