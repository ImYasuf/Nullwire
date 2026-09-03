local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/ImYasuf/Nullwire/refs/heads/master/Library.lua"))()

local Window = Library:CreateWindow({
    Title = "Control Center",
    Subtitle = "Nullwire demo",
    Theme = "Black",
})

local Main = Window:CreateTab({
    Name = "Main",
    Icon = "home"
})

local Settings = Main:CreateSection({
    Name = "Settings"
})

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
            Title = "Diagnostics",
            Content = "All systems nominal.",
            Duration = 4
        })
    end,
})
