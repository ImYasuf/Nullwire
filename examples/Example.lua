local Nullwire = require(path.to.Nullwire)

local Window = Nullwire:CreateWindow({
    Title = "Nullwire / Operations",
    Subtitle = "Premium runtime UI",
    Theme = "Black",
    Width = 760,
    Height = 500,
})

local Main = Window:CreateTab({ Name = "Overview", Icon = "home" })
local Controls = Main:CreateSection({ Name = "Live controls" })

Controls:CreateParagraph({
    Name = "Welcome",
    Content = "This example exercises the complete public component surface without relying on Studio-only tooling.",
})
Controls:CreateButton({
    Name = "Run diagnostics",
    ButtonText = "RUN",
    Callback = function()
        Window:Notify({ Title = "Diagnostics complete", Content = "All available runtime checks passed.", Type = "Success", Duration = 4 })
    end,
})
Controls:CreateToggle({
    Name = "Enable feature",
    CurrentValue = true,
    Flag = "FeatureEnabled",
    Callback = function(value) print("Feature enabled:", value) end,
})
Controls:CreateSlider({
    Name = "Signal strength",
    Range = { 0, 100 },
    Increment = 10,
    CurrentValue = 40,
    Flag = "SignalStrength",
    Callback = function(value) print("Signal strength:", value) end,
})
Controls:CreateInput({
    Name = "Operator name",
    PlaceholderText = "Enter a display name...",
    Flag = "OperatorName",
    Callback = function(text) print("Operator:", text) end,
})
Controls:CreateDropdown({
    Name = "Operating mode",
    Options = { "Monitor", "Audit", "Maintenance" },
    Flag = "OperatingMode",
    Callback = function(value) print("Mode:", value) end,
})
Controls:CreateKeybind({
    Name = "Console key",
    CurrentKeybind = "F4",
    Flag = "ConsoleKey",
    Callback = function(key) print("Console key:", key.Name) end,
})
Controls:CreateDivider()
Controls:CreateColorPicker({
    Name = "Highlight color",
    Color = Color3.fromRGB(0, 220, 185),
    Callback = function(color) print("Color changed:", color) end,
})

local Settings = Window:CreateTab({ Name = "Settings", Icon = "gear" })
local Appearance = Settings:CreateSection({ Name = "Appearance" })
Appearance:CreateButton({ Name = "Use cyber theme", ButtonText = "APPLY", Callback = function() Window:SetTheme("Cyber"); Window:Notify({ Title = "Theme selected", Content = "Cyber palette queued for the next render.", Duration = 3 }) end })
Appearance:CreateLabel({ Name = "Search the header to filter controls." })

Window:Notify({ Title = "Nullwire online", Content = "Welcome to the operations console.", Icon = "radio", Type = "Success", Duration = 4 })

-- Persistence is intentionally adapter-neutral. Store this string using your host's approved mechanism.
local saved = Window:SaveConfig()
print("Serialized configuration:", saved)
