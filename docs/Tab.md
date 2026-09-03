# Tab Guide

A **Tab** is a navigation destination inside a Nullwire Window. Each tab has a button in the left navigation area and a content page in the main scrolling area. The first tab created is selected automatically, so its content is visible immediately.

## Create a tab

```lua
local Main = Window:CreateTab({
    Name = "Main",
    Icon = "home",
})
```

`Name` is required for a useful navigation label. `Icon` is optional and currently acts as a compact visual marker in the navigation button.

## Add a section

Sections group related controls inside the active tab page:

```lua
local Settings = Main:CreateSection({
    Name = "Settings",
})
```

A section can create every supported control. The section itself owns the controls, while the tab owns the section's visual container.

```lua
Settings:CreateLabel({ Name = "Runtime status: online" })
Settings:CreateToggle({
    Name = "Enable telemetry",
    CurrentValue = true,
    Callback = function(value)
        print("Telemetry:", value)
    end,
})
```

## Add controls directly to a tab

Sections are recommended for organization, but controls can also be placed directly on a tab:

```lua
Main:CreateButton({
    Name = "Run diagnostics",
    ButtonText = "RUN",
    Callback = function()
        Library:Notify({
            Title = "Diagnostics",
            Content = "All systems nominal.",
            Duration = 4,
        })
    end,
})
```

The available tab methods are `CreateSection`, `CreateButton`, `CreateToggle`, `CreateSlider`, `CreateInput`, `CreateDropdown`, `CreateKeybind`, `CreateLabel`, `CreateParagraph`, `CreateDivider`, and `CreateColorPicker`.

## Create multiple tabs

Create each destination from the same Window object:

```lua
local Main = Window:CreateTab({ Name = "Main", Icon = "home" })
local Visuals = Window:CreateTab({ Name = "Visuals", Icon = "eye" })
local About = Window:CreateTab({ Name = "About", Icon = "info" })
```

The first tab, `Main`, is selected automatically. Additional tabs are represented in the left navigation area and can be selected by clicking their buttons. The Window's internal `SelectTab(tab)` method handles visibility and active styling.

## Organize a tab with sections

```lua
local Main = Window:CreateTab({ Name = "Main" })

local General = Main:CreateSection({ Name = "General" })
General:CreateToggle({ Name = "Enabled", CurrentValue = true, Flag = "Enabled" })
General:CreateSlider({
    Name = "Intensity",
    Range = { 0, 100 },
    Increment = 5,
    CurrentValue = 25,
    Flag = "Intensity",
})

local Identity = Main:CreateSection({ Name = "Identity" })
Identity:CreateInput({
    Name = "Operator",
    PlaceholderText = "Enter a name...",
    Flag = "Operator",
})
Identity:CreateDropdown({
    Name = "Mode",
    Options = { "Monitor", "Audit", "Maintenance" },
    Flag = "Mode",
})
```

## Complete Window and Tab example

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/ImYasuf/Nullwire/refs/heads/master/Library.lua"))()

local Window = Library:CreateWindow({
    Title = "Control Center",
    Subtitle = "Tab guide",
    Theme = "Black",
})

-- This tab is selected automatically and is safe immediately after CreateWindow.
local Main = Window:CreateTab({
    Name = "Main",
    Icon = "home",
})

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
        Library:Notify({
            Title = "Success",
            Content = "Button clicked!",
            Duration = 5,
        })
    end,
})

local About = Window:CreateTab({ Name = "About", Icon = "info" })
About:CreateParagraph({
    Name = "Nullwire",
    Content = "A lightweight cyberpunk-inspired UI library.",
})
```
