--[[
    MeteorHub UI Library — Matcha Style
    Roblox executor UI library inspired by Matcha.
    Parented to CoreGui. No UICorners used.
]]

local Meteor = {}
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

if CoreGui:FindFirstChild("MeteorLib") then
    CoreGui:FindFirstChild("MeteorLib"):Destroy()
end

local T = {
    Bg        = Color3.fromRGB(16, 16, 18),
    Bar       = Color3.fromRGB(22, 22, 25),
    Elem      = Color3.fromRGB(26, 26, 30),
    ElemHov   = Color3.fromRGB(32, 32, 36),
    Input     = Color3.fromRGB(20, 20, 23),
    Border    = Color3.fromRGB(42, 42, 48),
    Accent    = Color3.fromRGB(217, 68, 129),
    AccDim    = Color3.fromRGB(160, 50, 95),
    TabAct    = Color3.fromRGB(240, 240, 240),
    TabActBg  = Color3.fromRGB(50, 50, 55),
    Text      = Color3.fromRGB(190, 190, 195),
    TextDim   = Color3.fromRGB(100, 100, 110),
    TextBr    = Color3.fromRGB(240, 240, 245),
    White     = Color3.fromRGB(255, 255, 255),
    Green     = Color3.fromRGB(80, 200, 120),
    SliderBg  = Color3.fromRGB(35, 35, 40),
    SliderDot = Color3.fromRGB(200, 200, 210),
    CheckBord = Color3.fromRGB(60, 60, 68),
    Font      = Enum.Font.Gotham,
    FontM     = Enum.Font.GothamMedium,
    FontB     = Enum.Font.GothamBold,
}

local function C(cls, props, ch)
    local i = Instance.new(cls)
    for k, v in pairs(props or {}) do i[k] = v end
    for _, c in ipairs(ch or {}) do c.Parent = i end
    return i
end

local function Tw(o, p, d, s) 
    local t = TS:Create(o, TweenInfo.new(d or 0.2, s or Enum.EasingStyle.Quad), p)
    t:Play()
    return t
end

local function doCallback(el, v, delay)
    if v == el.LastValue and tick() - el.LastTime < (delay or 0.05) then return end
    el.LastValue = v; el.LastTime = tick()
    el.Callback(v)
end

-- HSV Color Picker Builder
local function buildHSVPicker(overlayParent, onChange)
    local h, s, v = 0, 1, 1
    local svDragging, hueDragging = false, false

    local popup = C("Frame", {
        Size = UDim2.new(0, 185, 0, 155),
        BackgroundColor3 = T.Input, BorderSizePixel = 1, BorderColor3 = T.Border,
        Visible = false, ZIndex = 5005, Active = true, Parent = overlayParent,
    })

    -- SV square
    local svFrame = C("Frame", {
        Size = UDim2.new(0, 150, 0, 140), Position = UDim2.new(0, 5, 0, 5),
        BackgroundColor3 = Color3.fromHSV(0, 1, 1),
        BorderSizePixel = 1, BorderColor3 = T.Border, ZIndex = 5006, Parent = popup,
    })
    local whiteLayer = C("Frame", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0, ZIndex = 5007, Parent = svFrame,
    })
    C("UIGradient", { Transparency = NumberSequence.new(0, 1), Parent = whiteLayer })
    local blackLayer = C("Frame", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0, 0, 0),
        BorderSizePixel = 0, ZIndex = 5008, Parent = svFrame,
    })
    C("UIGradient", { Transparency = NumberSequence.new(1, 0), Rotation = 90, Parent = blackLayer })
    local svCursor = C("Frame", {
        Size = UDim2.new(0, 8, 0, 8), BackgroundColor3 = T.White,
        BorderSizePixel = 1, BorderColor3 = Color3.new(0, 0, 0),
        ZIndex = 5009, Parent = svFrame,
    })
    local svBtn = C("TextButton", {
        Text = "", Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1, ZIndex = 5010, Parent = svFrame,
    })

    -- Hue bar
    local hueBar = C("Frame", {
        Size = UDim2.new(0, 16, 0, 140), Position = UDim2.new(0, 160, 0, 5),
        BorderSizePixel = 1, BorderColor3 = T.Border, ZIndex = 5006, Parent = popup,
    })
    C("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
            ColorSequenceKeypoint.new(0.167, Color3.fromHSV(0.167, 1, 1)),
            ColorSequenceKeypoint.new(0.333, Color3.fromHSV(0.333, 1, 1)),
            ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
            ColorSequenceKeypoint.new(0.667, Color3.fromHSV(0.667, 1, 1)),
            ColorSequenceKeypoint.new(0.833, Color3.fromHSV(0.833, 1, 1)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1)),
        }),
        Rotation = 90, Parent = hueBar,
    })
    local hueCursor = C("Frame", {
        Size = UDim2.new(1, 2, 0, 3), Position = UDim2.new(0, -1, 0, 0),
        BackgroundColor3 = T.White, BorderSizePixel = 1, BorderColor3 = Color3.new(0, 0, 0),
        ZIndex = 5007, Parent = hueBar,
    })
    local hueBtn = C("TextButton", {
        Text = "", Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1, ZIndex = 5008, Parent = hueBar,
    })

    local function refresh()
        svFrame.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        svCursor.Position = UDim2.new(s, -4, 1 - v, -4)
        hueCursor.Position = UDim2.new(0, -1, h, -1)
        if onChange then onChange(Color3.fromHSV(h, s, v)) end
    end

    svBtn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            svDragging = true
            s = math.clamp((i.Position.X - svFrame.AbsolutePosition.X) / svFrame.AbsoluteSize.X, 0, 1)
            v = 1 - math.clamp((i.Position.Y - svFrame.AbsolutePosition.Y) / svFrame.AbsoluteSize.Y, 0, 1)
            refresh()
        end
    end)
    svBtn.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then svDragging = false end
    end)
    hueBtn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            hueDragging = true
            h = math.clamp((i.Position.Y - hueBar.AbsolutePosition.Y) / hueBar.AbsoluteSize.Y, 0, 0.999)
            refresh()
        end
    end)
    hueBtn.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then hueDragging = false end
    end)
    UIS.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
            if svDragging then
                s = math.clamp((i.Position.X - svFrame.AbsolutePosition.X) / svFrame.AbsoluteSize.X, 0, 1)
                v = 1 - math.clamp((i.Position.Y - svFrame.AbsolutePosition.Y) / svFrame.AbsoluteSize.Y, 0, 1)
                refresh()
            elseif hueDragging then
                h = math.clamp((i.Position.Y - hueBar.AbsolutePosition.Y) / hueBar.AbsoluteSize.Y, 0, 0.999)
                refresh()
            end
        end
    end)

    local function setColor(col)
        h, s, v = Color3.toHSV(col)
        svFrame.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        svCursor.Position = UDim2.new(s, -4, 1 - v, -4)
        hueCursor.Position = UDim2.new(0, -1, h, -1)
    end

    return popup, setColor
end
function Meteor:CreateWindow(cfg)
    cfg = cfg or {}

    local function purge(p)
        if not p then return end
        for _, v in ipairs(p:GetDescendants()) do
            if v.Name == "MeteorLib" or v.Name == "MeteorHud" then
                pcall(function() v:Destroy() end)
            end
        end
    end
    purge(game:GetService("CoreGui"))
    if gethui then purge(gethui()) end

    local title = cfg.Title or "Meteor"
    local subtitle = cfg.Subtitle or "Hub"
    local sx = cfg.SizeX or 580
    local sy = cfg.SizeY or 720
    local toggleKey = cfg.ToggleKey or Enum.KeyCode.RightShift
    local configFolder = cfg.ConfigFolder or "Meteor"
    local includeSettings = cfg.IncludeSettingsTab == nil and true or cfg.IncludeSettingsTab

    local win = { Tabs = {}, ActiveTab = nil, _keybindEntries = {}, _saveableElements = {} }

    win.Gui = C("ScreenGui", {
        Name = "MeteorLib", ZIndexBehavior = Enum.ZIndexBehavior.Global,
        ResetOnSpawn = false, Parent = CoreGui,
    })
    win.HudGui = C("ScreenGui", {
        Name = "MeteorHud", ZIndexBehavior = Enum.ZIndexBehavior.Global,
        ResetOnSpawn = false, Parent = CoreGui,
    })

    -- Scaling system
    local globalScale = cfg.Scale or 1
    local uiScale = C("UIScale", { Scale = globalScale, Parent = win.Gui })
    local hudScale = C("UIScale", { Scale = globalScale, Parent = win.HudGui })

    -- Mobile adaptation: screen size check
    local viewportSize = workspace.CurrentCamera.ViewportSize
    if viewportSize.X < sx * globalScale or viewportSize.Y < sy * globalScale then
        -- Scale down if screen is too small
        local scaleX = viewportSize.X / (sx + 20)
        local scaleY = viewportSize.Y / (sy + 20)
        local autoScale = math.min(scaleX, scaleY, globalScale)
        uiScale.Scale = autoScale
        hudScale.Scale = autoScale
    end

    win.Overlay = C("Frame", {
        Name = "Overlays", Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1, ZIndex = 5000, Parent = win.Gui,
    })
    win.OverlayClicker = C("TextButton", {
        Name = "ClosePopups", Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1, Text = "", Visible = false, ZIndex = 5001, Parent = win.Overlay,
    })

    local activePopups = {}
    local popupCloseCallbacks = {}
    function win:ClosePopups()
        win.OverlayClicker.Visible = false
        for _, p in ipairs(activePopups) do p.Visible = false end
        for _, fn in ipairs(popupCloseCallbacks) do pcall(fn) end
        table.clear(activePopups)
        table.clear(popupCloseCallbacks)
    end
    win.OverlayClicker.MouseButton1Click:Connect(function() win:ClosePopups() end)

    function win:OpenPopup(popup, x, y, onClose)
        self:ClosePopups()
        local scaleFactor = uiScale.Scale
        popup.Position = UDim2.new(0, x / scaleFactor, 0, y / scaleFactor)
        popup.Visible = true
        win.OverlayClicker.Visible = true
        table.insert(activePopups, popup)
        if onClose then table.insert(popupCloseCallbacks, onClose) end
    end

    -- Main frame
    win.Main = C("Frame", {
        Name = "Main",
        Size = UDim2.new(0, sx, 0, sy),
        Position = UDim2.new(0.5, -sx/2, 0.5, -sy/2),
        BackgroundColor3 = T.Bg,
        BorderSizePixel = 1,
        BorderColor3 = T.Border,
        Parent = win.Gui,
    })

    -- Top bar (title area, 30px)
    win.TopBar = C("Frame", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = T.Bar,
        BorderSizePixel = 0,
        Parent = win.Main,
    })
    -- Bottom line
    C("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = T.Border, BorderSizePixel = 0, Parent = win.TopBar })

    -- Title: "Matcha · Comfort  beta"
    C("TextLabel", {
        Text = title, Font = T.FontB, TextSize = 13,
        TextColor3 = T.Accent, BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 0), Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = win.TopBar,
    })
    C("TextLabel", {
        Text = subtitle, Font = T.FontB, TextSize = 13,
        TextColor3 = T.Text, BackgroundTransparency = 1,
        Position = UDim2.new(0, 14 + #title * 7.4, 0, 0), Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = win.TopBar,
    })
    -- Right side label
    if cfg.RightLabel then
        C("TextLabel", {
            Text = cfg.RightLabel, Font = T.Font, TextSize = 11,
            TextColor3 = T.TextDim, BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, -12, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Right,
            Parent = win.TopBar,
        })
    end

    win.TabBar = C("Frame", {
        Size = UDim2.new(1, 0, 0, 32),
        Position = UDim2.new(0, 0, 0, 38),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = win.Main,
    })
    win.TabLayout = C("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6),
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Parent = win.TabBar,
    })
    C("UIPadding", { PaddingLeft = UDim.new(0, 14), Parent = win.TabBar })

    -- Content
    win.Content = C("Frame", {
        Size = UDim2.new(1, 0, 1, -88),
        Position = UDim2.new(0, 0, 0, 65),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = win.Main,
    })

    -- Footer (24px)
    win.Footer = C("Frame", {
        Size = UDim2.new(1, 0, 0, 24),
        Position = UDim2.new(0, 0, 1, -24),
        BackgroundColor3 = T.Bar,
        BorderSizePixel = 0,
        Parent = win.Main,
    })
    C("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = T.Border, BorderSizePixel = 0, Parent = win.Footer })

    -- Footer: green dot + online count
    local footLeft = C("Frame", {
        Size = UDim2.new(0, 8, 0, 8), Position = UDim2.new(0, 10, 0.5, -4),
        BackgroundColor3 = T.Green, BorderSizePixel = 0, Parent = win.Footer,
    })
    C("TextLabel", {
        Text = cfg.FooterLeft or "online", Font = T.Font, TextSize = 10,
        TextColor3 = T.Green, BackgroundTransparency = 1,
        Position = UDim2.new(0, 22, 0, 0), Size = UDim2.new(0.3, 0, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left, Parent = win.Footer,
    })
    C("TextLabel", {
        Text = cfg.FooterCenter or "", Font = T.Font, TextSize = 10,
        TextColor3 = T.TextDim, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Center, Parent = win.Footer,
    })
    C("TextLabel", {
        Text = cfg.FooterRight or "" .. identifyexecutor(), Font = T.Font, TextSize = 10,
        TextColor3 = T.Accent, BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Right, Parent = win.Footer,
    })

    -- Drag Logic (Universal: Mouse + Touch)
    local function makeDraggable(frame, dragHandle)
        dragHandle = dragHandle or frame
        local dragging, dragInput, dragStart, startPos
        
        local function update(input)
            local delta = input.Position - dragStart
            local scaleFactor = uiScale.Scale -- Adjust for UIScale
            local newPos = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + (delta.X / scaleFactor),
                startPos.Y.Scale, startPos.Y.Offset + (delta.Y / scaleFactor)
            )
            
            -- Bounds check for HUD elements (Watermark, Radar, KL)
            if frame ~= win.Main then
                local vs = workspace.CurrentCamera.ViewportSize / scaleFactor
                local fs = frame.AbsoluteSize / scaleFactor
                local ox = math.clamp(newPos.X.Offset, 0, vs.X - fs.X)
                local oy = math.clamp(newPos.Y.Offset, 0, vs.Y - fs.Y)
                newPos = UDim2.new(0, ox, 0, oy)
            end

            frame.Position = newPos
        end

        dragHandle.InputBegan:Connect(function(input)
            if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position
                
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)

        dragHandle.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)

        UIS.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                update(input)
            end
        end)
    end

    makeDraggable(win.Main, win.TopBar)

    -- Toggle
    UIS.InputBegan:Connect(function(inp, gpe)
        if not gpe and inp.KeyCode == toggleKey then win.Gui.Enabled = not win.Gui.Enabled end
    end)

    -- Watermark
    do
        local Players = game:GetService("Players")
        local lp = Players.LocalPlayer
        local cGreen = Color3.fromRGB(80, 200, 120)
        local cOrange = Color3.fromRGB(230, 160, 50)
        local cRed = Color3.fromRGB(220, 60, 60)

        local wmFrame = C("Frame", {
            Size = UDim2.new(0, 0, 0, 28),
            AutomaticSize = Enum.AutomaticSize.X,
            Position = UDim2.new(0, 12, 0, 12),
            BackgroundColor3 = T.Bar,
            BorderSizePixel = 1, BorderColor3 = T.Border,
            Active = true, Parent = win.HudGui,
        })
        C("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 0),
            Parent = wmFrame,
        })
        C("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), Parent = wmFrame })

        local function wmLabel(text, color, font, order)
            return C("TextLabel", {
                Text = text, Font = font or T.FontM, TextSize = 12,
                TextColor3 = color, BackgroundTransparency = 1,
                Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X,
                LayoutOrder = order, Parent = wmFrame,
            })
        end
        local function wmDiv(order)
            return C("TextLabel", {
                Text = "  |  ", Font = T.Font, TextSize = 12,
                TextColor3 = T.TextDim, BackgroundTransparency = 1,
                Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X,
                LayoutOrder = order, Parent = wmFrame,
            })
        end

        wmLabel(title, T.Accent, T.FontB, 1)
        wmLabel(subtitle, T.Text, T.FontB, 2)
        wmDiv(3)
        wmLabel(lp and lp.Name or "Player", T.Text, T.FontM, 4)
        win._fpsDiv = wmDiv(5)
        win._fpsLabel = wmLabel("0 fps", cGreen, T.FontM, 6)
        win._pingDiv = wmDiv(7)
        win._pingLabel = wmLabel("0 ms", cGreen, T.FontM, 8)

        -- Watermark drag
        makeDraggable(wmFrame)

        -- FPS + Ping updater
        local frameCount = 0
        local lastUpdate = tick()
        local RS = game:GetService("RunService")
        local wmConn; wmConn = RS.RenderStepped:Connect(function()
            if not win.HudGui or not win.HudGui.Parent then wmConn:Disconnect(); return end
            frameCount = frameCount + 1
            local now = tick()
            if now - lastUpdate >= 0.5 then
                local fps = math.floor(frameCount / (now - lastUpdate))
                win._fpsLabel.Text = fps .. " fps"
                win._fpsLabel.TextColor3 = fps >= 60 and cGreen or fps >= 30 and cOrange or cRed
                frameCount = 0; lastUpdate = now
                local ping = lp and math.floor(lp:GetNetworkPing() * 1000) or 0
                win._pingLabel.Text = ping .. " ms"
                win._pingLabel.TextColor3 = ping < 80 and cGreen or ping <= 150 and cOrange or cRed
            end
        end)

        win.Watermark = wmFrame
    end

    -- Keybind List
    do
        win._keybindEntries = {}

        local klFrame = C("Frame", {
            Size = UDim2.new(0, 170, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Position = UDim2.new(0, 12, 0, 208),
            BackgroundColor3 = T.Bar, BorderSizePixel = 1, BorderColor3 = T.Border,
            Active = true, Parent = win.HudGui,
        })
        local klTitle = C("Frame", {
            Size = UDim2.new(1, 0, 0, 22), BackgroundColor3 = T.Bg,
            BorderSizePixel = 0, LayoutOrder = 0, Parent = klFrame,
        })
        C("TextLabel", {
            Text = "  Keybinds", Font = T.FontM, TextSize = 11,
            TextColor3 = T.Accent, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, Parent = klTitle,
        })
        C("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, 0),
            BackgroundColor3 = T.Border, BorderSizePixel = 0, Parent = klTitle })
        local klList = C("Frame", {
            Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1, LayoutOrder = 1, Parent = klFrame,
        })
        C("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = klFrame })
        C("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = klList })
        C("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6),
            PaddingTop = UDim.new(0, 3), PaddingBottom = UDim.new(0, 3), Parent = klList })

        -- KL Drag
        makeDraggable(klFrame, klTitle)

        function win:RefreshKeybindList()
            for _, c in ipairs(klList:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
            for _, entry in ipairs(self._keybindEntries) do
                if entry.el.Keybind and entry.el.Value then
                    local contextName = entry.context or ""
                    
                    local row = C("Frame", {
                        Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, Parent = klList,
                    })
                    C("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, Parent = row })

                    -- Feature Name (Text)
                    if contextName ~= "" then
                        local ctxLabel = C("TextLabel", {
                            Text = contextName .. "  ", Font = T.FontM, TextSize = 10,
                            TextColor3 = T.Accent, BackgroundTransparency = 1,
                            Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X,
                            LayoutOrder = 1, Parent = row,
                        })
                    end

                    -- Feature Name (Text)
                    local nameLabel = C("TextLabel", {
                        Text = entry.name, Font = T.Font, TextSize = 10,
                        TextColor3 = T.Text, BackgroundTransparency = 1,
                        Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X,
                        LayoutOrder = 2, Parent = row,
                    })
                    
                    -- No spacer needed, dynamic width handles the layout

                    local kn = entry.el.Keybind
                    local keyText = typeof(kn) == "EnumItem" and ((kn.EnumType == Enum.KeyCode) and kn.Name or (kn == Enum.UserInputType.MouseButton1 and "MB1" or "MB2")) or "?"
                    
                    -- Keybind (Accent)
                    local keyLabel = C("TextLabel", {
                        Text = "[" .. keyText .. "]", Font = T.FontM, TextSize = 10,
                        TextColor3 = T.Accent, BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 1, 0),
                        TextXAlignment = Enum.TextXAlignment.Right,
                        LayoutOrder = 4, Parent = row,
                    })
                    
                    -- Fix spacer width after row is built
                    task.spawn(function()
                        local used = 0
                        local scaleFactor = hudScale.Scale
                        for _, c in ipairs(row:GetChildren()) do
                            if c:IsA("TextLabel") and c ~= keyLabel then
                                used = used + (c.AbsoluteSize.X / scaleFactor)
                            end
                        end
                        keyLabel.Size = UDim2.new(1, -used, 1, 0)
                    end)
                end
            end
        end

        win.KeybindList = klFrame
    end

    -- Radar
    do
        local Players = game:GetService("Players")
        local lp = Players.LocalPlayer
        local radarRange = 200

        local radarFrame = C("Frame", {
            Size = UDim2.new(0, 130, 0, 152),
            Position = UDim2.new(0, 12, 0, 48),
            BackgroundColor3 = T.Bar, BorderSizePixel = 1, BorderColor3 = T.Border,
            Active = true, Parent = win.HudGui,
        })
        local radarTitle = C("Frame", {
            Size = UDim2.new(1, 0, 0, 22), BackgroundColor3 = T.Bg,
            BorderSizePixel = 0, Parent = radarFrame,
        })
        C("TextLabel", {
            Text = "  Radar", Font = T.FontM, TextSize = 11,
            TextColor3 = T.Accent, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, Parent = radarTitle,
        })
        C("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, 0),
            BackgroundColor3 = T.Border, BorderSizePixel = 0, Parent = radarTitle })

        local radarCanvas = C("Frame", {
            Size = UDim2.new(1, -8, 1, -30), Position = UDim2.new(0, 4, 0, 26),
            BackgroundColor3 = T.Bg, BorderSizePixel = 1, BorderColor3 = T.Border,
            ClipsDescendants = true, Parent = radarFrame,
        })
        -- Crosshairs
        C("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 0.5, 0),
            BackgroundColor3 = T.Border, BorderSizePixel = 0, Parent = radarCanvas })
        C("Frame", { Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(0.5, 0, 0, 0),
            BackgroundColor3 = T.Border, BorderSizePixel = 0, Parent = radarCanvas })
        -- Center dot (local player)
        C("Frame", { Size = UDim2.new(0, 4, 0, 4), Position = UDim2.new(0.5, -2, 0.5, -2),
            BackgroundColor3 = T.Accent, BorderSizePixel = 0, ZIndex = 3, Parent = radarCanvas })

        local dots = {}

            -- Radar Drag
            makeDraggable(radarFrame, radarTitle)
            -- Update player dots
            local char = lp and lp.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            local myPos = root.Position
            local myLook = root.CFrame.LookVector
            local angle = math.atan2(myLook.X, myLook.Z)

            local i = 0
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= lp then
                    local pChar = p.Character
                    local pRoot = pChar and pChar:FindFirstChild("HumanoidRootPart")
                    if pRoot then
                        local diff = pRoot.Position - myPos
                        local dist = diff.Magnitude
                        if dist <= radarRange then
                            i = i + 1
                            local rx = (diff.X * math.cos(angle) - diff.Z * math.sin(angle)) / radarRange
                            local ry = (diff.X * math.sin(angle) + diff.Z * math.cos(angle)) / radarRange
                            local px = 0.5 - rx * 0.5
                            local py = 0.5 - ry * 0.5
                            if not dots[i] then
                                dots[i] = C("Frame", {
                                    Size = UDim2.new(0, 4, 0, 4),
                                    BackgroundColor3 = Color3.fromRGB(80, 200, 120), BorderSizePixel = 0,
                                    ZIndex = 2, Parent = radarCanvas,
                                })
                            end
                            dots[i].Position = UDim2.new(px, -2, py, -2)
                            dots[i].Visible = true
                        end
                    end
                end
            end
            for j = i + 1, #dots do dots[j].Visible = false end
        end)

        win.Radar = radarFrame
        radarFrame.Visible = false
    end

    function win:SetRadar(v) if self.Radar then self.Radar.Visible = v end end
    function win:SetKeybindList(v) if self.KeybindList then self.KeybindList.Visible = v end end
    function win:AddKeybind(name, toggle)
        table.insert(self._keybindEntries, { name = name, el = toggle })
        if self.RefreshKeybindList then self:RefreshKeybindList() end
    end

    function win:SelectTab(tab)
        if self.ActiveTab == tab then return end
        if self.ActiveTab then
            Tw(self.ActiveTab.Btn, { BackgroundColor3 = T.Bg, TextColor3 = T.TextDim })
            self.ActiveTab.Page.Visible = false
        end
        self.ActiveTab = tab
        Tw(tab.Btn, { BackgroundColor3 = T.Bar, TextColor3 = T.TextBr })
        tab.Page.Visible = true
    end

    function win:Destroy() 
        if renderConn then renderConn:Disconnect() end
        self.Gui:Destroy() 
        if self.HudGui then self.HudGui:Destroy() end
        self.Watermark = nil
        self.Radar = nil
        self.KeybindList = nil
    end

    ----------------------------------------------------------------
    -- TAB (main top-level tabs)
    ----------------------------------------------------------------
    function win:CreateTab(name)
        local tab = { Name = name }

        tab.Btn = C("TextButton", {
            Text = name, Font = T.FontM, TextSize = 12,
            TextColor3 = T.TextDim, BackgroundColor3 = T.Bg,
            BorderSizePixel = 1, BorderColor3 = T.Border, AutoButtonColor = false,
            Size = UDim2.new(0, 85, 0, 24),
            LayoutOrder = (name == "Settings") and 999 or #self.Tabs,
            Parent = self.TabBar,
        })
        tab.Btn.MouseEnter:Connect(function() if self.ActiveTab ~= tab then Tw(tab.Btn, { BackgroundColor3 = T.Elem }) end end)
        tab.Btn.MouseLeave:Connect(function() if self.ActiveTab ~= tab then Tw(tab.Btn, { BackgroundColor3 = T.Bg }) end end)

        -- Page (full content area for this tab)
        tab.Page = C("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1, Visible = false,
            Parent = self.Content,
        })

        -- Left column
        tab.LeftCol = C("Frame", { Size = UDim2.new(0.5, -18, 1, -16), Position = UDim2.new(0, 12, 0, 8), BackgroundTransparency=1, Parent = tab.Page })
        tab.Left = C("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1, BorderSizePixel = 0,
            ScrollBarThickness = 2, ScrollBarImageColor3 = T.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Parent = tab.LeftCol,
        })
        C("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = tab.Left })
        C("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 2), Parent = tab.Left })

        -- Right column
        tab.RightCol = C("Frame", { Size = UDim2.new(0.5, -18, 1, -16), Position = UDim2.new(0.5, 6, 0, 8), BackgroundTransparency=1, Parent = tab.Page })
        tab.Right = C("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1, BorderSizePixel = 0,
            ScrollBarThickness = 2, ScrollBarImageColor3 = T.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Parent = tab.RightCol,
        })
        C("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = tab.Right })
        C("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 2), Parent = tab.Right })

        table.insert(self.Tabs, tab)
        tab.Btn.MouseButton1Click:Connect(function() self:SelectTab(tab) end)
        if #self.Tabs == 1 then self:SelectTab(tab) end

        --------------------------------------------------------
        -- GROUPBOX (sits inside a column; can have sub-tabs)
        --------------------------------------------------------
        function tab:CreateGroupbox(gbName, side)
            side = side or "Left"
            local gb = { Name = gbName, SubTabs = {}, Elements = {} }
            local col = side == "Left" and self.Left or self.Right

            -- Main frame for this groupbox
            gb.Frame = C("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = T.Bar,
                BorderMode = Enum.BorderMode.Inset,
                BorderSizePixel = 1, BorderColor3 = T.Border,
                Parent = col,
            })
            C("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = gb.Frame })

            -- Sub-tab bar (only shown if sub-tabs are created)
            gb.SubBar = C("Frame", {
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundTransparency = 1,
                Visible = false,
                Parent = gb.Frame,
            })
            
            gb.SubTabList = C("Frame", {
                Size = UDim2.new(1, 0, 1, -1),
                BackgroundTransparency = 1, Parent = gb.SubBar,
            })
            C("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDim.new(0, 6),
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Parent = gb.SubTabList,
            })
            C("UIPadding", { PaddingLeft = UDim.new(0, 8), Parent = gb.SubTabList })
            
            -- Underline
            C("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1),
                BackgroundColor3 = T.Border, BorderSizePixel = 0, Parent = gb.SubBar })

            -- Content area (holds sub-tab pages + shared elements)
            gb.Container = C("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                ClipsDescendants = true,
                BackgroundTransparency = 1, Parent = gb.Frame,
            })
            local gbLayout = C("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = gb.Container })
            C("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6), Parent = gb.Container })

            gbLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Tw(gb.Container, { Size = UDim2.new(1, 0, 0, gbLayout.AbsoluteContentSize.Y + 12) }, 0.15)
            end)

            ------------------------------------------------
            -- CREATE SUB-TAB within this groupbox
            ------------------------------------------------
            function gb:CreateSubTab(subName)
                local sub = { Name = subName }

                self.SubBar.Visible = true

                local TS = game:GetService("TextService")
                local exactWidth = TS:GetTextSize(subName, 11, T.FontM, Vector2.new(9999, 9999)).X

                sub.Btn = C("TextButton", {
                    Text = subName, Font = T.FontM, TextSize = 11,
                    TextColor3 = T.TextDim, BackgroundTransparency = 1,
                    AutoButtonColor = false,
                    Size = UDim2.new(0, exactWidth + 2, 1, 0),
                    Parent = self.SubTabList,
                })
                sub.Btn.MouseEnter:Connect(function() if not sub.Page.Visible then Tw(sub.Btn, { TextColor3 = T.Text }) end end)
                sub.Btn.MouseLeave:Connect(function() if not sub.Page.Visible then Tw(sub.Btn, { TextColor3 = T.TextDim }) end end)

                sub.Page = C("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1, Visible = false,
                    LayoutOrder = 0, Parent = gb.Container,
                })
                C("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = sub.Page })

                table.insert(self.SubTabs, sub)

                sub.Btn.MouseButton1Click:Connect(function()
                    for _, s in ipairs(self.SubTabs) do
                        if s ~= sub then
                            Tw(s.Btn, { TextColor3 = T.TextDim })
                            s.Btn.Font = T.FontM
                            s.Page.Visible = false
                        end
                    end
                    local col = T.Accent
                    Tw(sub.Btn, { TextColor3 = col })
                    sub.Btn.Font = T.FontB
                    gb.ActiveSub = sub
                    sub.Page.Visible = true
                end)

                -- Auto-select first sub-tab
                if #self.SubTabs == 1 then
                    gb.ActiveSub = sub; sub.Btn.TextColor3 = T.Accent; sub.Btn.Font = T.FontB; sub.Page.Visible = true
                else
                    if self.SubTabs[1].Page.Visible then
                        self.SubTabs[1].Btn.TextColor3 = T.Accent
                    end
                end

                attachElements(sub, sub.Page, win, tab.Name .. "||" .. gbName .. "||" .. subName)
                return sub
            end

            -- Shared elements (always-visible, below sub-tabs)
            gb.SharedContainer = C("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                LayoutOrder = 999,
                Parent = gb.Container,
            })
            C("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = gb.SharedContainer })

            -- Attach element methods directly to groupbox (for shared content)
            attachElements(gb, gb.SharedContainer, win, tab.Name .. "||" .. gbName)

            return gb
        end



        return tab
    end

    if includeSettings then
        local stTab = win:CreateTab("Settings")

        -- Config Directory
        local dir = "Meteor"
        local subDir = "Meteor\\" .. configFolder
        local autoLoadFile = "Meteor\\autoload_" .. configFolder .. ".txt"
        if makefolder and isfolder then
            if not isfolder(dir) then makefolder(dir) end
            if not isfolder(subDir) then makefolder(subDir) end
        end

        local currentAutoLoad = ""
        if readfile and isfile and isfile(autoLoadFile) then
            local s, res = pcall(function() return readfile(autoLoadFile) end)
            if s and res and res ~= "" then currentAutoLoad = res end
        end

        -- Configs
        local cfGb = stTab:CreateGroupbox("", "Left")
        local cfSub = cfGb:CreateSubTab("Configuration")
        
        local HS = game:GetService("HttpService")
        local cfgInput = cfSub:AddTextbox("Config Name", { Default = "default" })
        
        local cfgList = cfSub:AddDropdown("Configs", { Options = {} })
        
        local function getConfigs()
            local list = {}
            if listfiles and isfolder and isfolder(subDir) then
                for _, file in ipairs(listfiles(subDir)) do
                    if file:sub(-5) == ".json" then
                        local name = file:match("([^/\\]+)%.json$")
                        if name then table.insert(list, name) end
                    end
                end
            end
            return list
        end

        local function refreshList()
            local cls = getConfigs()
            cfgList:SetOptions(cls)
        end

        local function saveConfig(name)
            if name == "" or name == "None" then name = cfgInput.Value end
            if name == "" then return end

            local data = {}
            for _, obj in ipairs(win._saveableElements) do
                local el = obj.el
                if el.Value ~= nil then
                    local val = el.Value
                    if typeof(val) == "Color3" then
                        val = { R = val.R, G = val.G, B = val.B }
                    end
                    data[obj.id] = { Value = val, Mode = el.Mode }
                    if el.Keybind then
                        local k = el.Keybind
                        if typeof(k) == "EnumItem" then
                            data[obj.id].Key = { Type = k.EnumType == Enum.KeyCode and "Key" or "Mouse", Name = k.Name }
                        end
                    end
                    if el.Color then
                        data[obj.id].Color = { R = el.Color.R, G = el.Color.G, B = el.Color.B }
                    end
                end
            end

            if writefile then
                writefile(subDir .. "\\" .. name .. ".json", HS:JSONEncode(data))
                refreshList()
            end
        end

        cfSub:AddButton("Create Config", {
            Callback = function()
                local name = cfgInput.Value
                if name == "" then return end
                saveConfig(name)
                cfgList:SetValue(name)
            end
        })

        cfSub:AddButton("Save Config", {
            Callback = function()
                saveConfig(cfgList.Value)
            end
        })

        local function loadConfig(name)
            if name == "" or name == "None" then return end
            if readfile and isfile and isfile(subDir .. "\\" .. name .. ".json") then
                local s, data = pcall(function() return HS:JSONDecode(readfile(subDir .. "\\" .. name .. ".json")) end)
                if s and type(data) == "table" then
                    for _, obj in ipairs(win._saveableElements) do
                        local el = obj.el
                        local st = data[obj.id]
                        if st then
                            if st.Value ~= nil and el.SetValue then 
                                local val = st.Value
                                if type(val) == "table" and val.R then val = Color3.new(val.R, val.G, val.B) end
                                el:SetValue(val) 
                            end
                            if st.Mode and el.Mode then el.Mode = st.Mode end
                            if st.Key and el.BindBtn then
                                if st.Key.Type == "Key" then el.Keybind = Enum.KeyCode[st.Key.Name]
                                else el.Keybind = Enum.UserInputType[st.Key.Name] end
                                local kn = el.Keybind
                                el.BindBtn.Text = typeof(kn) == "EnumItem" and ((kn.EnumType == Enum.KeyCode) and kn.Name or (kn == Enum.UserInputType.MouseButton1 and "MB1" or "MB2")) or "?"
                            end
                            if st.Color and el.SetColor then
                                el:SetColor(Color3.new(st.Color.R, st.Color.G, st.Color.B))
                            end
                        end
                    end
                end
            end
        end

        cfSub:AddButton("Load Config", {
            Callback = function() loadConfig(cfgList.Value) end
        })

        cfSub:AddButton("Delete Config", {
            Callback = function()
                local name = cfgList.Value
                if name == "" or name == "None" then return end
                if delfile and isfile and isfile(subDir .. "\\" .. name .. ".json") then
                    delfile(subDir .. "\\" .. name .. ".json")
                    refreshList()
                    cfgList:SetValue("")
                end
            end
        })

        cfSub:AddToggle("Autoload Selected Config", {
            Default = (currentAutoLoad ~= ""),
            Callback = function(v)
                if not writefile then return end
                if v and cfgList.Value and cfgList.Value ~= "None" then
                    writefile(autoLoadFile, cfgList.Value)
                    currentAutoLoad = cfgList.Value
                else
                    writefile(autoLoadFile, "")
                    currentAutoLoad = ""
                end
            end
        })

        -- Auto-refresh loop
        task.spawn(function()
            while task.wait(2) do
                if win.Gui and win.Gui.Parent then
                    refreshList()
                else
                    break
                end
            end
        end)
        refreshList()

        if currentAutoLoad ~= "" then
            cfgList:SetValue(currentAutoLoad)
            task.delay(0.5, function() loadConfig(currentAutoLoad) end)
        end

        -- Watermark Controls
        local wmGb = stTab:CreateGroupbox("", "Right")
        local wmSub = wmGb:CreateSubTab("Watermark Settings")

        wmSub:AddToggle("Show Watermark", {
            Default = true,
            Callback = function(v)
                if win.Watermark then
                    win.Watermark.Visible = v
                end
            end
        })

        wmSub:AddToggle("Show FPS", {
            Default = true,
            Callback = function(v)
                if win._fpsLabel then win._fpsLabel.Visible = v end
                if win._fpsDiv then win._fpsDiv.Visible = v end
            end
        })

        wmSub:AddToggle("Show Ping", {
            Default = true,
            Callback = function(v)
                if win._pingLabel then win._pingLabel.Visible = v end
                if win._pingDiv then win._pingDiv.Visible = v end
            end
        })
    end

    return win
end

----------------------------------------------------------------
-- ELEMENT FACTORY (attached to sub-tabs and groupboxes)
----------------------------------------------------------------
function attachElements(obj, container, win, contextName)

    -- SECTION HEADER
    function obj:AddSection(text)
        C("TextLabel", {
            Text = text, Font = T.FontB, TextSize = 12,
            TextColor3 = T.TextBr, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 24),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = container,
        })
    end

    -- LABEL
    function obj:AddLabel(text)
        local el = {}
        el.Frame = C("TextLabel", {
            Text = text, Font = T.Font, TextSize = 11,
            TextColor3 = T.Text, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = container,
        })
        function el:SetText(t) self.Frame.Text = t end
        return el
    end

    -- TOGGLE
    function obj:AddToggle(tName, cfg)
        cfg = cfg or {}
        local el = { 
            Value = cfg.Default or false, 
            Callback = cfg.Callback or function() end,
            LastValue = nil, LastTime = 0
        }

        el.Frame = C("Frame", {
            Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Parent = container,
        })
        el.Box = C("Frame", {
            Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(0, 0, 0.5, -6),
            BackgroundColor3 = el.Value and T.Accent or T.Bg,
            BorderMode = Enum.BorderMode.Inset,
            BorderSizePixel = 1, BorderColor3 = el.Value and T.Accent or T.CheckBord,
            Parent = el.Frame,
        })
        C("TextLabel", {
            Text = tName, Font = T.Font, TextSize = 11,
            TextColor3 = T.Text, BackgroundTransparency = 1,
            Position = UDim2.new(0, 18, 0, 0), Size = UDim2.new(1, -68, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Left, Parent = el.Frame,
        })

        el.Keybind = cfg.Keybind or nil; el.Listening = false
        el.Mode = cfg.Mode or "Toggle"
        if cfg.Keybind then
            local kname = "None"
            if typeof(el.Keybind) == "EnumItem" then
                kname = (el.Keybind.EnumType == Enum.KeyCode) and el.Keybind.Name or (el.Keybind == Enum.UserInputType.MouseButton1 and "MB1" or "MB2")
            end
            el.BindBtn = C("TextButton", {
                Text = kname,
                Font = T.Font, TextSize = 10, TextColor3 = T.TextDim,
                BackgroundColor3 = T.Input, BorderMode = Enum.BorderMode.Inset, BorderSizePixel = 1, BorderColor3 = T.Border,
                AutoButtonColor = false,
                Size = UDim2.new(0, 40, 0, 14), Position = UDim2.new(1, -40, 0.5, -7),
                Parent = el.Frame,
            })
            el.BindBtn.MouseEnter:Connect(function() if not el.Listening then Tw(el.BindBtn, { TextColor3 = T.White }) end end)
            el.BindBtn.MouseLeave:Connect(function() if not el.Listening then Tw(el.BindBtn, { TextColor3 = T.TextDim }) end end)
            
            local listenTick = 0

            el.ModePopup = C("Frame", {
                Size = UDim2.new(0, 40, 0, 56),
                BackgroundColor3 = T.Input, BorderMode = Enum.BorderMode.Inset, BorderSizePixel = 1, BorderColor3 = T.Border,
                Visible = false, ZIndex = 5005, Active = true, Parent = win.Overlay,
            })
            C("UIPadding", { PaddingTop = UDim.new(0, 1), PaddingBottom = UDim.new(0, 1), Parent = el.ModePopup })
            C("UIListLayout", { Parent = el.ModePopup })
            for _, mode in ipairs({"Toggle", "Hold", "Always"}) do
                local mBtn = C("TextButton", {
                    Text = "  " .. mode, Font = T.FontM, TextSize = 10,
                    TextColor3 = el.Mode == mode and T.Accent or T.TextDim,
                    BackgroundColor3 = T.Input, BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 18), TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 5006, Parent = el.ModePopup,
                })
                mBtn.MouseEnter:Connect(function() Tw(mBtn, { BackgroundColor3 = T.Elem, TextColor3 = T.White }, 0.12) end)
                mBtn.MouseLeave:Connect(function()
                    Tw(mBtn, { BackgroundColor3 = T.Input, TextColor3 = el.Mode == mode and T.Accent or T.TextDim }, 0.12)
                end)
                mBtn.MouseButton1Click:Connect(function()
                    el.Mode = mode
                    for _, c in ipairs(el.ModePopup:GetChildren()) do if c:IsA("TextButton") then c.TextColor3 = T.TextDim end end
                    mBtn.TextColor3 = T.Accent
                    win:ClosePopups()
                    if mode == "Always" and not el.Value then
                        el.Value = true
                        Tw(el.Box, { BackgroundColor3 = T.Accent, BorderColor3 = T.Accent })
                        doCallback(el, true)
                    elseif mode ~= "Always" and el.Value then
                        el.Value = false
                        Tw(el.Box, { BackgroundColor3 = T.Bg, BorderColor3 = T.CheckBord })
                        doCallback(el, false)
                    end
                end)
            end

            el.BindBtn.InputBegan:Connect(function(inp)
                if (inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch) and not el.Listening then
                    listenTick = tick() + 0.2
                    el.Listening = true; el.BindBtn.Text = "..."; Tw(el.BindBtn, { TextColor3 = T.Accent })
                elseif (inp.UserInputType == Enum.UserInputType.MouseButton2) and not el.Listening then
                    local pos = el.BindBtn.AbsolutePosition
                    win:OpenPopup(el.ModePopup, pos.X, pos.Y + 16)
                end
            end)
            
            -- Mobile: long press to open mode popup
            local touchStart = 0
            el.BindBtn.TouchLongPress:Connect(function()
                if not el.Listening then
                    local pos = el.BindBtn.AbsolutePosition
                    win:OpenPopup(el.ModePopup, pos.X, pos.Y + 16)
                end
            end)

            local function isMatch(input, bind)
                if not bind then return false end
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    return input.KeyCode == bind
                end
                return input.UserInputType == bind
            end

            UIS.InputBegan:Connect(function(input, gpe)
                if el.Listening then
                    if tick() < listenTick then return end
                    local name = nil
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        if input.KeyCode == Enum.KeyCode.Escape then
                            el.Keybind = nil; name = "None"
                        else
                            el.Keybind = input.KeyCode; name = input.KeyCode.Name
                        end
                    elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                        el.Keybind = Enum.UserInputType.MouseButton1; name = "MB1"
                    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                        el.Keybind = Enum.UserInputType.MouseButton2; name = "MB2"
                    end
                    if name then
                        el.BindBtn.Text = name
                        Tw(el.BindBtn, { TextColor3 = T.TextDim }); el.Listening = false
                        win:ClosePopups()
                    end
                    return
                end
                
                if el.Mode ~= "Always" then
                    if isMatch(input, el.Keybind) then
                        if input.UserInputType.Name:find("Mouse") and gpe then
                            local g = win.Gui:GetGuiObjectsAtPosition(input.Position.X, input.Position.Y)
                            for _, v in ipairs(g) do if v:IsDescendantOf(win.Main) then return end end
                        elseif gpe then return end

                        if el.Mode == "Toggle" then
                            el.Value = not el.Value
                            Tw(el.Box, { BackgroundColor3 = el.Value and T.Accent or T.Bg, BorderColor3 = el.Value and T.Accent or T.CheckBord })
                            doCallback(el, el.Value)
                            if win.RefreshKeybindList then win:RefreshKeybindList() end
                        elseif el.Mode == "Hold" and not el.Value then
                            el.Value = true
                            Tw(el.Box, { BackgroundColor3 = T.Accent, BorderColor3 = T.Accent })
                            doCallback(el, true)
                            if win.RefreshKeybindList then win:RefreshKeybindList() end
                        end
                    end
                end
            end)
            
            UIS.InputEnded:Connect(function(input, gpe)
                if not el.Listening and el.Mode == "Hold" and el.Value then
                    if isMatch(input, el.Keybind) then
                        el.Value = false
                        Tw(el.Box, { BackgroundColor3 = T.Bg, BorderColor3 = T.CheckBord })
                        doCallback(el, false)
                        if win.RefreshKeybindList then win:RefreshKeybindList() end
                    end
                end
            end)
        end

        local btn = C("TextButton", {
            Text = "", Size = UDim2.new(0, 80, 1, 0), BackgroundTransparency = 1, Parent = el.Frame,
        })
        btn.MouseEnter:Connect(function() if el.Mode ~= "Always" then Tw(el.Box, { BorderColor3 = T.Accent }) end end)
        btn.MouseLeave:Connect(function() if el.Mode ~= "Always" then Tw(el.Box, { BorderColor3 = el.Value and T.Accent or T.CheckBord }) end end)
        btn.MouseButton1Click:Connect(function()
            if el.Mode == "Always" then
                el.Mode = "Toggle"
                if el.ModePopup then
                    for _, c in ipairs(el.ModePopup:GetChildren()) do
                        if c:IsA("TextButton") then c.TextColor3 = (c.Text:find("Toggle")) and T.Accent or T.TextDim end
                    end
                end
            end
            el.Value = not el.Value
            Tw(el.Box, { BackgroundColor3 = el.Value and T.Accent or T.Bg, BorderColor3 = el.Value and T.Accent or T.CheckBord })
            doCallback(el, el.Value)
            if win.RefreshKeybindList then win:RefreshKeybindList() end
        end)

        function el:SetValue(v)
            self.Value = v
            Tw(self.Box, { BackgroundColor3 = v and T.Accent or T.Bg, BorderColor3 = v and T.Accent or T.CheckBord })
            doCallback(el, v)
        end

        -- COLOR PICKER ADDON
        if cfg.Color then
            el.Color = cfg.Color
            el.ColorCallback = cfg.ColorCallback or function() end
            local cpOffset = cfg.Keybind and -44 or 0
            el.ColorPreview = C("TextButton", {
                Text = "", Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(1, -14 + cpOffset, 0.5, -7),
                BackgroundColor3 = el.Color, BorderSizePixel = 1, BorderColor3 = T.Border,
                AutoButtonColor = false, Parent = el.Frame,
            })
            el.ColorOpen = false
            el.ColorPopup, el._cpSetColor = buildHSVPicker(win.Overlay, function(col)
                el.Color = col; el.ColorPreview.BackgroundColor3 = col
                el.ColorCallback(col)
            end)
            el._cpSetColor(el.Color)
            el.ColorPreview.MouseEnter:Connect(function() Tw(el.ColorPreview, { BorderColor3 = T.Accent }, 0.12) end)
            el.ColorPreview.MouseLeave:Connect(function() Tw(el.ColorPreview, { BorderColor3 = T.Border }, 0.12) end)
            el.ColorPreview.MouseButton1Click:Connect(function()
                if el.ColorOpen then
                    el.ColorOpen = false; win:ClosePopups()
                else
                    el.ColorOpen = true
                    el._cpSetColor(el.Color)
                    local p, s = el.ColorPreview.AbsolutePosition, el.ColorPreview.AbsoluteSize
                    win:OpenPopup(el.ColorPopup, p.X - (170 * uiScale.Scale), p.Y + s.Y, function()
                        el.ColorOpen = false
                    end)
                end
            end)
            function el:SetColor(c) self.Color = c; self.ColorPreview.BackgroundColor3 = c; self._cpSetColor(c); self.ColorCallback(c) end
        end

        -- Register keybind entry
        if cfg.Keybind then
            table.insert(win._keybindEntries, { name = tName, context = contextName, el = el })
        end

        if win._saveableElements then
            table.insert(win._saveableElements, { id = (contextName or "") .. "||" .. tName, el = el })
        end

        return el
    end

    -- SLIDER
    function obj:AddSlider(sName, cfg)
        cfg = cfg or {}
        local el = {
            Value = cfg.Default or cfg.Min or 0,
            Min = cfg.Min or 0, Max = cfg.Max or 100,
            Decimals = cfg.Decimals or 0,
            Suffix = cfg.Suffix or "",
            Callback = cfg.Callback or function() end,
            Dragging = false,
            LastValue = nil, LastTime = 0
        }
        el.Frame = C("Frame", {
            Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, Parent = container,
        })

        local function fmtVal(v)
            if el.Decimals > 0 then return string.format("%." .. el.Decimals .. "f", v) .. el.Suffix end
            return tostring(math.floor(v)) .. el.Suffix
        end

        C("TextLabel", {
            Text = sName, Font = T.Font, TextSize = 11,
            TextColor3 = T.Text, BackgroundTransparency = 1,
            Size = UDim2.new(0.55, 0, 0, 14),
            TextXAlignment = Enum.TextXAlignment.Left, Parent = el.Frame,
        })
        el.ValText = C("TextLabel", {
            Text = fmtVal(el.Value), Font = T.FontM, TextSize = 11,
            TextColor3 = T.TextBr, BackgroundTransparency = 1,
            Size = UDim2.new(0.45, 0, 0, 14), Position = UDim2.new(0.55, 0, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Right, Parent = el.Frame,
        })

        el.Track = C("Frame", {
            Size = UDim2.new(1, 0, 0, 4), Position = UDim2.new(0, 0, 0, 20),
            BackgroundColor3 = T.SliderBg, BorderSizePixel = 0, Parent = el.Frame,
        })
        local pct = (el.Value - el.Min) / math.max(el.Max - el.Min, 0.001)
        el.Fill = C("Frame", {
            Size = UDim2.new(pct, 0, 1, 0),
            BackgroundColor3 = T.Accent, BorderSizePixel = 0, Parent = el.Track,
        })
        el.Dot = C("Frame", {
            Size = UDim2.new(0, 8, 0, 8), Position = UDim2.new(pct, -4, 0.5, -4),
            BackgroundColor3 = T.SliderDot, BorderSizePixel = 0, ZIndex = 3, Parent = el.Track,
        })

        local sBtn = C("TextButton", {
            Text = "", Size = UDim2.new(1, 0, 1, 12), Position = UDim2.new(0, 0, 0, -6),
            BackgroundTransparency = 1, Parent = el.Track,
        })

        local function upd(input)
            local rel = math.clamp((input.Position.X - el.Track.AbsolutePosition.X) / el.Track.AbsoluteSize.X, 0, 1)
            local raw = el.Min + rel * (el.Max - el.Min)
            if el.Decimals > 0 then local m = 10 ^ el.Decimals; raw = math.floor(raw * m + 0.5) / m
            else raw = math.floor(raw + 0.5) end
            el.Value = raw
            el.Fill.Size = UDim2.new(rel, 0, 1, 0)
            el.Dot.Position = UDim2.new(rel, -4, 0.5, -4)
            el.ValText.Text = fmtVal(raw); doCallback(el, raw)
        end

        sBtn.MouseEnter:Connect(function() Tw(el.Dot, { BackgroundColor3 = T.White }) end)
        sBtn.MouseLeave:Connect(function() Tw(el.Dot, { BackgroundColor3 = T.SliderDot }) end)
        sBtn.InputBegan:Connect(function(i) 
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then 
                el.Dragging = true; upd(i) 
            end 
        end)
        sBtn.InputEnded:Connect(function(i) 
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then 
                el.Dragging = false 
            end 
        end)
        UIS.InputChanged:Connect(function(i) 
            if el.Dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then 
                upd(i) 
            end 
        end)

        function el:SetValue(v)
            v = math.clamp(v, self.Min, self.Max); self.Value = v
            local r = (v - self.Min) / math.max(self.Max - self.Min, 0.001)
            Tw(self.Fill, { Size = UDim2.new(r, 0, 1, 0) })
            Tw(self.Dot, { Position = UDim2.new(r, -4, 0.5, -4) })
            self.ValText.Text = fmtVal(v); doCallback(el, v)
        end
        if win._saveableElements then
            table.insert(win._saveableElements, { id = (contextName or "") .. "||" .. sName, el = el })
        end
        return el
    end

    -- DROPDOWN
    function obj:AddDropdown(dName, cfg)
        cfg = cfg or {}
        local el = {
            Options = cfg.Options or {}, Open = false,
            Value = cfg.Default or (cfg.Options and cfg.Options[1]) or "None",
            Callback = cfg.Callback or function() end,
            LastValue = nil, LastTime = 0
        }
        el.Frame = C("Frame", {
            Size = UDim2.new(1, 0, 0, 38), BackgroundTransparency = 1,
            ClipsDescendants = false, Parent = container,
        })
        C("TextLabel", {
            Text = dName, Font = T.Font, TextSize = 11,
            TextColor3 = T.Text, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 16),
            TextXAlignment = Enum.TextXAlignment.Left, Parent = el.Frame,
        })
        el.Btn = C("TextButton", {
            Text = "  " .. tostring(el.Value), Font = T.Font, TextSize = 11,
            TextColor3 = T.Text, BackgroundColor3 = T.Input,
            BorderSizePixel = 1, BorderColor3 = T.Border,
            AutoButtonColor = false,
            Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 0, 17),
            TextXAlignment = Enum.TextXAlignment.Left, Parent = el.Frame,
        })
        el.Arrow = C("TextLabel", {
            Text = "+", Font = T.FontB, TextSize = 12, TextColor3 = T.TextDim,
            BackgroundTransparency = 1, Size = UDim2.new(0, 20, 1, 0),
            Position = UDim2.new(1, -20, 0, 0), Parent = el.Btn,
        })
        el.OptFrame = C("Frame", {
            BackgroundColor3 = T.Input, BorderSizePixel = 1, BorderColor3 = T.Border,
            Visible = false, ZIndex = 5005, Active = true, ClipsDescendants = true, Parent = win.Overlay,
        })
        C("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = el.OptFrame })

        local function build()
            for _, c in ipairs(el.OptFrame:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
            for _, opt in ipairs(el.Options) do
                local ob = C("TextButton", {
                    Text = "  " .. opt, Font = T.Font, TextSize = 11,
                    TextColor3 = opt == el.Value and T.White or T.TextDim,
                    BackgroundColor3 = T.Input, BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 18), AutoButtonColor = false,
                    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5006, Parent = el.OptFrame,
                })
                ob.MouseEnter:Connect(function() Tw(ob, { BackgroundColor3 = T.Elem, TextColor3 = T.White }, 0.12) end)
                ob.MouseLeave:Connect(function() 
                    Tw(ob, { BackgroundColor3 = T.Input, TextColor3 = opt == el.Value and T.White or T.TextDim }, 0.12) 
                end)
                ob.MouseButton1Click:Connect(function()
                    el.Value = opt; el.Btn.Text = "  " .. opt
                    el.Open = false; el.Arrow.Text = "+"; win:ClosePopups()
                    doCallback(el, opt)
                end)
            end
        end
        build()

        el.Btn.MouseEnter:Connect(function() Tw(el.Btn, { TextColor3 = T.White }, 0.12); Tw(el.Arrow, { TextColor3 = T.White }, 0.12) end)
        el.Btn.MouseLeave:Connect(function() Tw(el.Btn, { TextColor3 = T.Text }, 0.12); Tw(el.Arrow, { TextColor3 = T.TextDim }, 0.12) end)
        el.Btn.MouseButton1Click:Connect(function()
            if el.Open then
                el.Open = false
                el.Arrow.Text = "+"
                Tw(el.OptFrame, { Size = UDim2.new(0, el.OptFrame.Size.X.Offset, 0, 0) }, 0.15)
                task.delay(0.15, function() if not el.Open then win:ClosePopups() end end)
            else
                el.Open = true
                el.Arrow.Text = "-"
                build(); local p, s = el.Btn.AbsolutePosition, el.Btn.AbsoluteSize
                local sf = uiScale.Scale
                el.OptFrame.Size = UDim2.new(0, s.X / sf, 0, 0)
                win:OpenPopup(el.OptFrame, p.X, p.Y + s.Y, function()
                    el.Open = false; el.Arrow.Text = "+"
                end)
                Tw(el.OptFrame, { Size = UDim2.new(0, s.X / sf, 0, #el.Options * 18) }, 0.15)
            end
        end)

        function el:SetValue(v) self.Value = v; self.Btn.Text = "  " .. tostring(v); doCallback(el, v) end
        function el:SetOptions(o) self.Options = o; build() end
        if win._saveableElements then
            table.insert(win._saveableElements, { id = (contextName or "") .. "||" .. dName, el = el })
        end
        return el
    end

    -- TEXTBOX
    function obj:AddTextbox(tName, cfg)
        cfg = cfg or {}
        local el = { Value = cfg.Default or "", Callback = cfg.Callback or function() end }
        el.Frame = C("Frame", {
            Size = UDim2.new(1, 0, 0, 38), BackgroundTransparency = 1, Parent = container,
        })
        C("TextLabel", {
            Text = tName, Font = T.Font, TextSize = 11,
            TextColor3 = T.Text, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 16),
            TextXAlignment = Enum.TextXAlignment.Left, Parent = el.Frame,
        })
        el.Input = C("TextBox", {
            Text = el.Value, PlaceholderText = cfg.Placeholder or "",
            PlaceholderColor3 = T.TextDim, Font = T.Font, TextSize = 11,
            TextColor3 = T.Text, BackgroundColor3 = T.Input,
            BorderSizePixel = 1, BorderColor3 = T.Border,
            Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 0, 17),
            ClearTextOnFocus = false, Parent = el.Frame,
        })
        C("UIPadding", { PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4), Parent = el.Input })
        el.Input.MouseEnter:Connect(function() if not el.Input:IsFocused() then Tw(el.Input, { BorderColor3 = T.TextDim }) end end)
        el.Input.MouseLeave:Connect(function() if not el.Input:IsFocused() then Tw(el.Input, { BorderColor3 = T.Border }) end end)
        el.Input.Focused:Connect(function() Tw(el.Input, { BorderColor3 = T.Accent }) end)
        el.Input.FocusLost:Connect(function()
            Tw(el.Input, { BorderColor3 = T.Border })
            el.Value = el.Input.Text; el.Callback(el.Value)
        end)
        function el:SetValue(v) self.Value = v; self.Input.Text = v end
        if win._saveableElements then
            table.insert(win._saveableElements, { id = (contextName or "") .. "||" .. tName, el = el })
        end
        return el
    end

    -- BUTTON
    function obj:AddButton(bName, cfg)
        cfg = cfg or {}
        local el = { Callback = cfg.Callback or function() end }
        el.Frame = C("TextButton", {
            Text = bName, Font = T.Font, TextSize = 11,
            TextColor3 = T.Text, Size = UDim2.new(1, 0, 0, 22),
            BackgroundColor3 = T.Elem, BorderSizePixel = 1, BorderColor3 = T.Border,
            AutoButtonColor = false, Parent = container,
        })
        el.Frame.MouseEnter:Connect(function() Tw(el.Frame, { BackgroundColor3 = T.ElemHov }) end)
        el.Frame.MouseLeave:Connect(function() Tw(el.Frame, { BackgroundColor3 = T.Elem }) end)
        el.Frame.MouseButton1Click:Connect(function()
            Tw(el.Frame, { BackgroundColor3 = T.Accent }, 0.06)
            task.delay(0.12, function() Tw(el.Frame, { BackgroundColor3 = T.Elem }) end)
            el.Callback()
        end)
        return el
    end

    -- COLOR PICKER
    function obj:AddColorPicker(cName, cfg)
        cfg = cfg or {}
        local el = { 
            Value = cfg.Default or Color3.fromRGB(255,255,255), 
            Callback = cfg.Callback or function() end, 
            Open = false, LastValue = nil, LastTime = 0
        }
        el.Frame = C("Frame", {
            Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1,
            ClipsDescendants = false, Parent = container,
        })
        C("TextLabel", {
            Text = cName, Font = T.Font, TextSize = 11,
            TextColor3 = T.Text, BackgroundTransparency = 1,
            Size = UDim2.new(0.8, 0, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Left, Parent = el.Frame,
        })
        el.Preview = C("TextButton", {
            Text = "", Size = UDim2.new(0, 14, 0, 14),
            Position = UDim2.new(1, -14, 0.5, -7),
            BackgroundColor3 = el.Value, BorderSizePixel = 1, BorderColor3 = T.Border,
            AutoButtonColor = false, Parent = el.Frame,
        })
        el.Popup, el._setColor = buildHSVPicker(win.Overlay, function(col)
            el.Value = col; el.Preview.BackgroundColor3 = col
            doCallback(el, col)
        end)
        el._setColor(el.Value)
        el.Preview.MouseEnter:Connect(function() Tw(el.Preview, { BorderColor3 = T.Accent }, 0.12) end)
        el.Preview.MouseLeave:Connect(function() Tw(el.Preview, { BorderColor3 = T.Border }, 0.12) end)
        el.Preview.MouseButton1Click:Connect(function()
            if el.Open then
                el.Open = false; win:ClosePopups()
            else
                el.Open = true
                el._setColor(el.Value)
                local p, s = el.Preview.AbsolutePosition, el.Preview.AbsoluteSize
                win:OpenPopup(el.Popup, p.X - 170, p.Y + s.Y, function()
                    el.Open = false
                end)
            end
        end)
        function el:SetValue(c) self.Value = c; self.Preview.BackgroundColor3 = c; self._setColor(c); doCallback(el, c) end
        if win._saveableElements then
            table.insert(win._saveableElements, { id = (contextName or "") .. "||" .. cName, el = el })
        end
        return el
    end

    -- SEPARATOR
    function obj:AddSeparator()
        C("Frame", {
            Size = UDim2.new(1, 0, 0, 8), BackgroundTransparency = 1, Parent = container,
        }, { C("Frame", {
            Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 0.5, 0),
            BackgroundColor3 = T.Border, BorderSizePixel = 0,
        }) })
    end
end

return Meteor
