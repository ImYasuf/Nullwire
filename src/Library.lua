--[=[
    Nullwire UI Library
    A standalone Luau/Roblox-compatible interface toolkit.
    No Studio-only dependencies are required.
]=]

local Nullwire = {}
Nullwire.__index = Nullwire

local Services = setmetatable({}, { __index = function(t, name)
    local ok, service = pcall(function() return game:GetService(name) end)
    if ok then rawset(t, name, service); return service end
end })

local TweenService = Services.TweenService
local UserInputService = Services.UserInputService
local CoreGui = Services.CoreGui
local Players = Services.Players
local HttpService = Services.HttpService

local function merge(base, extra)
    local result = {}
    for key, value in pairs(base or {}) do result[key] = value end
    for key, value in pairs(extra or {}) do result[key] = value end
    return result
end

local Themes = {
    Dark = { Accent = Color3.fromRGB(122, 92, 255), Background = Color3.fromRGB(14, 15, 20), Surface = Color3.fromRGB(21, 22, 29), Surface2 = Color3.fromRGB(28, 29, 38), Text = Color3.fromRGB(242, 243, 250), Muted = Color3.fromRGB(146, 149, 166), Stroke = Color3.fromRGB(52, 54, 68), Danger = Color3.fromRGB(245, 92, 109), Success = Color3.fromRGB(77, 218, 151), Radius = 10, Transparency = 0 },
    Black = { Accent = Color3.fromRGB(0, 220, 185), Background = Color3.fromRGB(5, 6, 8), Surface = Color3.fromRGB(11, 13, 16), Surface2 = Color3.fromRGB(17, 20, 24), Text = Color3.fromRGB(235, 255, 251), Muted = Color3.fromRGB(120, 151, 147), Stroke = Color3.fromRGB(30, 64, 59), Danger = Color3.fromRGB(255, 91, 114), Success = Color3.fromRGB(62, 226, 159), Radius = 8, Transparency = 0 },
    Cyber = { Accent = Color3.fromRGB(255, 53, 170), Background = Color3.fromRGB(10, 8, 18), Surface = Color3.fromRGB(25, 12, 34), Surface2 = Color3.fromRGB(40, 16, 51), Text = Color3.fromRGB(255, 242, 253), Muted = Color3.fromRGB(180, 133, 174), Stroke = Color3.fromRGB(92, 39, 96), Danger = Color3.fromRGB(255, 90, 94), Success = Color3.fromRGB(100, 239, 173), Radius = 12, Transparency = 0 },
}

local function instance(className, properties, parent)
    local object = Instance.new(className)
    for key, value in pairs(properties or {}) do object[key] = value end
    object.Parent = parent
    return object
end

local function corner(parent, radius)
    return instance("UICorner", { CornerRadius = UDim.new(0, radius or 8) }, parent)
end

local function stroke(parent, color, transparency)
    return instance("UIStroke", { Color = color, Transparency = transparency or 0, Thickness = 1 }, parent)
end

local function tween(object, duration, properties)
    if not TweenService then for key, value in pairs(properties) do object[key] = value end; return end
    TweenService:Create(object, TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), properties):Play()
end

local function textLabel(parent, text, size, color, font)
    return instance("TextLabel", { BackgroundTransparency = 1, Text = text or "", TextColor3 = color, TextSize = size or 14, Font = font or Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center }, parent)
end

local function signal(callback, ...)
    if type(callback) == "function" then task.spawn(callback, ...) end
end

function Nullwire.new(options)
    options = options or {}
    local self = setmetatable({}, Nullwire)
    self.Name = options.Name or "Nullwire"
    self.Theme = merge(Themes[options.Theme or "Dark"] or Themes.Dark, options.ThemeData)
    self.Flags = {}
    self.Elements = {}
    self.Tabs = {}
    self._connections = {}
    self._config = {}
    self:_buildLoading()
    task.delay(options.LoadingDuration or 0.65, function() self:_buildWindow(options) end)
    return self
end

function Nullwire:_buildLoading()
    self._loading = instance("ScreenGui", { Name = self.Name .. "_Loading", IgnoreGuiInset = true, ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling }, CoreGui)
    local root = instance("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = self.Theme.Background, BackgroundTransparency = 1 }, self._loading)
    local panel = instance("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(250, 125), BackgroundColor3 = self.Theme.Surface, BackgroundTransparency = 1 }, root)
    corner(panel, self.Theme.Radius); stroke(panel, self.Theme.Stroke, 0.3)
    local title = textLabel(panel, self.Name:upper(), 22, self.Theme.Text, Enum.Font.GothamBold); title.Position = UDim2.fromOffset(22, 20); title.Size = UDim2.new(1, -44, 0, 28); title.TextXAlignment = Enum.TextXAlignment.Center
    local status = textLabel(panel, "INITIALIZING CORE", 10, self.Theme.Muted, Enum.Font.Code); status.Position = UDim2.fromOffset(22, 53); status.Size = UDim2.new(1, -44, 0, 20); status.TextXAlignment = Enum.TextXAlignment.Center
    local track = instance("Frame", { Position = UDim2.fromOffset(30, 88), Size = UDim2.new(1, -60, 0, 4), BackgroundColor3 = self.Theme.Surface2 }, panel); corner(track, 3)
    local fill = instance("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = self.Theme.Accent }, track); corner(fill, 3)
    tween(root, 0.25, { BackgroundTransparency = 0 }); tween(panel, 0.25, { BackgroundTransparency = 0 })
    task.spawn(function()
        for i = 1, 10 do task.wait(0.055); tween(fill, 0.1, { Size = UDim2.fromScale(i / 10, 1) }) end
        task.wait(0.1); tween(root, 0.25, { BackgroundTransparency = 1 }); tween(panel, 0.2, { BackgroundTransparency = 1 })
        task.wait(0.28); if self._loading then self._loading:Destroy(); self._loading = nil end
    end)
end

function Nullwire:_buildWindow(options)
    self._gui = instance("ScreenGui", { Name = self.Name, IgnoreGuiInset = true, ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling }, CoreGui)
    self._main = instance("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.53), Size = UDim2.fromOffset(options.Width or 700, options.Height or 460), BackgroundColor3 = self.Theme.Background, BackgroundTransparency = 0.04, ClipsDescendants = true }, self._gui)
    corner(self._main, self.Theme.Radius); stroke(self._main, self.Theme.Stroke, 0.1)
    local top = instance("Frame", { Size = UDim2.new(1, 0, 0, 58), BackgroundColor3 = self.Theme.Surface, BorderSizePixel = 0 }, self._main)
    local accent = instance("Frame", { Size = UDim2.new(0, 3, 1, 0), BackgroundColor3 = self.Theme.Accent }, top)
    self._title = textLabel(top, options.Title or self.Name, 16, self.Theme.Text, Enum.Font.GothamBold); self._title.Position = UDim2.fromOffset(22, 9); self._title.Size = UDim2.new(1, -220, 0, 23)
    local subtitle = textLabel(top, options.Subtitle or "Developer interface", 11, self.Theme.Muted, Enum.Font.Gotham); subtitle.Position = UDim2.fromOffset(23, 31); subtitle.Size = UDim2.new(1, -220, 0, 18)
    local search = instance("TextBox", { PlaceholderText = "Search", Text = "", ClearTextOnFocus = false, TextColor3 = self.Theme.Text, PlaceholderColor3 = self.Theme.Muted, TextSize = 12, Font = Enum.Font.Gotham, BackgroundColor3 = self.Theme.Surface2 }, top); search.Position = UDim2.new(1, -184, 0, 14); search.Size = UDim2.fromOffset(125, 30); corner(search, 7); stroke(search, self.Theme.Stroke, 0.4)
    search:GetPropertyChangedSignal("Text"):Connect(function() self:Search(search.Text) end)
    local close = instance("TextButton", { Text = "×", TextSize = 22, Font = Enum.Font.Gotham, TextColor3 = self.Theme.Muted, BackgroundTransparency = 1 }, top); close.Position = UDim2.new(1, -48, 0, 10); close.Size = UDim2.fromOffset(32, 32); close.MouseButton1Click:Connect(function() self:Destroy() end)
    self._nav = instance("ScrollingFrame", { Position = UDim2.fromOffset(0, 58), Size = UDim2.new(0, 170, 1, -58), BackgroundColor3 = self.Theme.Surface, BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = self.Theme.Accent, AutomaticCanvasSize = Enum.AutomaticSize.Y }, self._main)
    instance("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, self._nav); instance("UIPadding", { PaddingTop = UDim.new(0, 15), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) }, self._nav)
    self._content = instance("ScrollingFrame", { Position = UDim2.new(0, 170, 0, 58), Size = UDim2.new(1, -170, 1, -58), BackgroundColor3 = self.Theme.Background, BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = self.Theme.Accent, AutomaticCanvasSize = Enum.AutomaticSize.Y }, self._main)
    instance("UIPadding", { PaddingTop = UDim.new(0, 18), PaddingBottom = UDim.new(0, 24), PaddingLeft = UDim.new(0, 20), PaddingRight = UDim.new(0, 20) }, self._content)
    instance("UIListLayout", { Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder }, self._content)
    self:_makeDraggable(top)
    tween(self._main, 0.45, { Position = UDim2.fromScale(0.5, 0.5) })
end

function Nullwire:_makeDraggable(handle)
    local dragging, start, origin
    handle.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; start = input.Position; origin = self._main.Position end end)
    handle.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then local delta = input.Position - start; self._main.Position = UDim2.new(origin.X.Scale, origin.X.Offset + delta.X, origin.Y.Scale, origin.Y.Offset + delta.Y) end end)
end

function Nullwire:CreateTab(options)
    options = options or {}; local tab = { Library = self, Name = options.Name or "Tab", Items = {}, _sections = {} }; table.insert(self.Tabs, tab)
    local button = instance("TextButton", { Text = (options.Icon and "◇  " or "") .. tab.Name, TextColor3 = self.Theme.Muted, TextSize = 12, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, AutoButtonColor = false }, self._nav); button.Size = UDim2.new(1, 0, 0, 34); corner(button, 7); tab.Button = button
    button.MouseButton1Click:Connect(function() self:SelectTab(tab) end)
    tab.Page = instance("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Visible = false }, self._content); instance("UIListLayout", { Padding = UDim.new(0, 12) }, tab.Page)
    if #self.Tabs == 1 then self:SelectTab(tab) end
    function tab:CreateSection(config) return self.Library:_createSection(self, config or {}) end
    function tab:CreateButton(config) return self.Library:_createItem(self, "button", config or {}) end
    function tab:CreateToggle(config) return self.Library:_createItem(self, "toggle", config or {}) end
    function tab:CreateSlider(config) return self.Library:_createItem(self, "slider", config or {}) end
    function tab:CreateInput(config) return self.Library:_createItem(self, "input", config or {}) end
    function tab:CreateDropdown(config) return self.Library:_createItem(self, "dropdown", config or {}) end
    function tab:CreateKeybind(config) return self.Library:_createItem(self, "keybind", config or {}) end
    function tab:CreateLabel(config) return self.Library:_createItem(self, "label", config or {}) end
    function tab:CreateParagraph(config) return self.Library:_createItem(self, "paragraph", config or {}) end
    function tab:CreateDivider() return self.Library:_createItem(self, "divider", {}) end
    function tab:CreateColorPicker(config) return self.Library:_createItem(self, "color", config or {}) end
    return tab
end

function Nullwire:SelectTab(tab)
    for _, item in ipairs(self.Tabs) do item.Page.Visible = item == tab; tween(item.Button, 0.15, { BackgroundTransparency = item == tab and 0 or 1, TextColor3 = item == tab and self.Theme.Text or self.Theme.Muted }); if item == tab then item.Button.BackgroundColor3 = self.Theme.Accent end end
end

function Nullwire:_createSection(tab, config)
    local section = { Library = self, Tab = tab, Name = config.Name or "Section" }; table.insert(tab._sections, section)
    local frame = instance("Frame", { Size = UDim2.new(1, 0, 0, 32), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = self.Theme.Surface, BorderSizePixel = 0 }, tab.Page); corner(frame, self.Theme.Radius); stroke(frame, self.Theme.Stroke, 0.55)
    local label = textLabel(frame, section.Name:upper(), 10, self.Theme.Accent, Enum.Font.GothamBold); label.Position = UDim2.fromOffset(14, 8); label.Size = UDim2.new(1, -28, 0, 16)
    local body = instance("Frame", { Position = UDim2.fromOffset(14, 31), Size = UDim2.new(1, -28, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1 }, frame); instance("UIListLayout", { Padding = UDim.new(0, 8) }, body); instance("UIPadding", { PaddingBottom = UDim.new(0, 14) }, body); section.Container = body
    for key, method in pairs({ CreateButton="button", CreateToggle="toggle", CreateSlider="slider", CreateInput="input", CreateDropdown="dropdown", CreateKeybind="keybind", CreateLabel="label", CreateParagraph="paragraph", CreateDivider="divider", CreateColorPicker="color" }) do section[key] = function(s, opts) return self:_createItem(s, method, opts or {}) end end
    return section
end

function Nullwire:_createItem(parent, kind, config)
    local holder = parent.Container or parent.Page
    local item = { Library = self, Config = config, Kind = kind, Parent = parent }
    local row = instance("Frame", { Size = UDim2.new(1, 0, 0, kind == "paragraph" and 54 or 38), BackgroundTransparency = 1 }, holder); item.Frame = row
    local name = config.Name or config.Title or ""
    if kind == "divider" then row.Size = UDim2.new(1, 0, 0, 8); instance("Frame", { Position = UDim2.fromScale(0, 0.5), Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = self.Theme.Stroke, BorderSizePixel = 0 }, row); return item end
    if kind == "label" then local l = textLabel(row, name, config.TextSize or 13, self.Theme.Text); l.Size = UDim2.fromScale(1, 1); item.Label = l; return item end
    if kind == "paragraph" then local l = textLabel(row, name .. "\n" .. (config.Content or ""), 12, self.Theme.Muted); l.Size = UDim2.fromScale(1, 1); l.TextWrapped = true; l.TextYAlignment = Enum.TextYAlignment.Top; item.Label = l; return item end
    local l = textLabel(row, name, 13, self.Theme.Text); l.Size = UDim2.new(0.58, 0, 1, 0)
    if kind == "button" then local b = instance("TextButton", { Text = config.ButtonText or "RUN", TextColor3 = self.Theme.Text, TextSize = 11, Font = Enum.Font.GothamBold, BackgroundColor3 = self.Theme.Surface2, AutoButtonColor = false }, row); b.Position = UDim2.new(1, -92, 0, 3); b.Size = UDim2.fromOffset(92, 32); corner(b, 7); stroke(b, self.Theme.Stroke, 0.3); b.MouseButton1Click:Connect(function() signal(config.Callback) end); item.Control = b
    elseif kind == "toggle" then local b = instance("TextButton", { Text = "", BackgroundColor3 = config.CurrentValue and self.Theme.Accent or self.Theme.Surface2, AutoButtonColor = false }, row); b.Position = UDim2.new(1, -46, 0, 6); b.Size = UDim2.fromOffset(46, 26); corner(b, 13); local knob = instance("Frame", { Size = UDim2.fromOffset(20,20), Position = config.CurrentValue and UDim2.new(1,-23,0,3) or UDim2.fromOffset(3,3), BackgroundColor3 = self.Theme.Text }, b); corner(knob,10); item.Value = config.CurrentValue or false; b.MouseButton1Click:Connect(function() item.Value = not item.Value; tween(b, .18, { BackgroundColor3 = item.Value and self.Theme.Accent or self.Theme.Surface2 }); tween(knob,.18,{Position=item.Value and UDim2.new(1,-23,0,3) or UDim2.fromOffset(3,3)}); self.Flags[config.Flag or name] = item.Value; signal(config.Callback,item.Value) end); item.Control=b
    elseif kind == "slider" then local min,max=(config.Range or {0,100})[1],(config.Range or {0,100})[2]; local value=config.CurrentValue or min; local b=instance("TextButton",{Text=tostring(value),TextColor3=self.Theme.Accent,TextSize=12,Font=Enum.Font.Code,BackgroundTransparency=1,AutoButtonColor=false},row); b.Position=UDim2.new(1,-128,0,0); b.Size=UDim2.fromOffset(128,38); item.Value=value; b.MouseButton1Click:Connect(function() item.Value = item.Value >= max and min or math.min(max,item.Value+(config.Increment or 1)); b.Text=tostring(item.Value); self.Flags[config.Flag or name]=item.Value; signal(config.Callback,item.Value) end); item.Control=b
    elseif kind == "input" then local b=instance("TextBox",{Text="",PlaceholderText=config.PlaceholderText or "Type here",TextColor3=self.Theme.Text,PlaceholderColor3=self.Theme.Muted,TextSize=11,Font=Enum.Font.Gotham,BackgroundColor3=self.Theme.Surface2,ClearTextOnFocus=false},row); b.Position=UDim2.new(1,-175,0,3);b.Size=UDim2.fromOffset(175,32);corner(b,7);b.FocusLost:Connect(function() self.Flags[config.Flag or name]=b.Text;signal(config.Callback,b.Text) end);item.Control=b
    elseif kind == "dropdown" then local b=instance("TextButton",{Text=config.CurrentOption or "SELECT",TextColor3=self.Theme.Muted,TextSize=11,Font=Enum.Font.Gotham,BackgroundColor3=self.Theme.Surface2,AutoButtonColor=false},row);b.Position=UDim2.new(1,-160,0,3);b.Size=UDim2.fromOffset(160,32);corner(b,7);b.MouseButton1Click:Connect(function() local list=config.Options or {}; local current=table.find(list,b.Text) or 0; local value=list[current%#list+1];b.Text=tostring(value);self.Flags[config.Flag or name]=value;signal(config.Callback,value) end);item.Control=b
    elseif kind == "keybind" then local b=instance("TextButton",{Text=config.CurrentKeybind or "NONE",TextColor3=self.Theme.Accent,TextSize=11,Font=Enum.Font.Code,BackgroundColor3=self.Theme.Surface2,AutoButtonColor=false},row);b.Position=UDim2.new(1,-100,0,3);b.Size=UDim2.fromOffset(100,32);corner(b,7);b.MouseButton1Click:Connect(function()b.Text="PRESS KEY";local c;c=UserInputService.InputBegan:Connect(function(input)if input.UserInputType==Enum.UserInputType.Keyboard then b.Text=input.KeyCode.Name;c:Disconnect();self.Flags[config.Flag or name]=input.KeyCode;signal(config.Callback,input.KeyCode)end end)end);item.Control=b
    elseif kind == "color" then local b=instance("TextButton",{Text="●",TextColor3=config.Color or self.Theme.Accent,TextSize=24,BackgroundTransparency=1,AutoButtonColor=false},row);b.Position=UDim2.new(1,-44,0,0);b.Size=UDim2.fromOffset(44,38);b.MouseButton1Click:Connect(function()b.TextColor3=b.TextColor3==self.Theme.Accent and Color3.fromRGB(255,80,120) or self.Theme.Accent;signal(config.Callback,b.TextColor3)end);item.Control=b end
    table.insert(self.Elements,item); return item
end

function Nullwire:Notify(config)
    config=config or {}; if not self._notifications then self._notifications=instance("Frame",{Position=UDim2.new(1,-310,0,74),Size=UDim2.fromOffset(290,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1},self._gui);instance("UIListLayout",{Padding=UDim.new(0,8),VerticalAlignment=Enum.VerticalAlignment.Bottom},self._notifications) end
    local card=instance("Frame",{Size=UDim2.new(1,0,0,70),BackgroundColor3=self.Theme.Surface,BackgroundTransparency=1},self._notifications);corner(card,self.Theme.Radius);stroke(card,self.Theme.Stroke,.2);local t=textLabel(card,config.Title or "Notification",13,self.Theme.Text,Enum.Font.GothamBold);t.Position=UDim2.fromOffset(14,10);t.Size=UDim2.new(1,-28,0,20);local c=textLabel(card,config.Content or "",11,self.Theme.Muted);c.Position=UDim2.fromOffset(14,33);c.Size=UDim2.new(1,-28,0,24);c.TextWrapped=true;tween(card,.2,{BackgroundTransparency=0});task.delay(config.Duration or 4,function()tween(card,.2,{BackgroundTransparency=1});task.wait(.22);card:Destroy()end);return card
end

function Nullwire:SetTheme(theme)
    self.Theme=merge(self.Theme,type(theme)=="string" and (Themes[theme] or {}) or theme); return self
end
function Nullwire:Search(query)
    query=string.lower(query or ""); for _, item in ipairs(self.Elements) do item.Frame.Visible=query=="" or string.find(string.lower(item.Config.Name or item.Config.Title or ""),query,1,true)~=nil end
end
function Nullwire:SetFlag(flag,value) self.Flags[flag]=value end
function Nullwire:GetFlag(flag) return self.Flags[flag] end
function Nullwire:SaveConfig() local ok,result=pcall(function() return HttpService:JSONEncode(self.Flags) end); return ok and result or nil end
function Nullwire:LoadConfig(serialized) local ok,data=pcall(function() return HttpService:JSONDecode(serialized) end); if ok and type(data)=="table" then for k,v in pairs(data) do self.Flags[k]=v end end; return ok end
function Nullwire:ResetConfig() self.Flags={} end
function Nullwire:Destroy() if self._gui then self._gui:Destroy() end; if self._loading then self._loading:Destroy() end; self._connections={} end

function Nullwire:CreateWindow(options) return Nullwire.new(options) end

return Nullwire

-- Convenience usage: require the ModuleScript and call Library:CreateWindow({...}).
