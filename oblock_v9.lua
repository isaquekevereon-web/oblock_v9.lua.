
-- O-BLOCK V9 UNIVERSAL
-- Roblox Luau | R6 / R15

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

if _G.OBLOCK_V9_STOP then
    pcall(_G.OBLOCK_V9_STOP)
end

local old = PG:FindFirstChild("OBLOCK_V9")
if old then old:Destroy() end

local settings = {
    Aimbot = false,
    ESP = false,
    Health = false,
    FOV = true,
    Wall = true,
    Dead = true,
    Team = false,
    Radius = 150,
    Smooth = 0.2
}

local alive = true
local aiming = false
local connections = {}
local drawings = {}

local function connect(signal, fn)
    local c = signal:Connect(fn)
    table.insert(connections, c)
    return c
end

local function corner(obj, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r)
    c.Parent = obj
end

local gui = Instance.new("ScreenGui")
gui.Name = "OBLOCK_V9"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = PG

local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(310, 425)
panel.Position = UDim2.new(0.5, -155, 0.5, -212)
panel.BackgroundColor3 = Color3.fromRGB(16, 10, 28)
panel.BorderSizePixel = 0
panel.Active = true
panel.Parent = gui
corner(panel, 14)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(170, 65, 255)
stroke.Thickness = 2
stroke.Parent = panel

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -95, 0, 48)
title.Position = UDim2.fromOffset(12, 0)
title.BackgroundTransparency = 1
title.Text = "👺 O-BLOCK V9"
title.TextColor3 = Color3.fromRGB(205, 140, 255)
title.TextSize = 20
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Active = true
title.Parent = panel

local function topButton(text, x)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(32, 32)
    b.Position = UDim2.new(1, x, 0, 8)
    b.BackgroundColor3 = Color3.fromRGB(92, 36, 145)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Text = text
    b.TextSize = 19
    b.Font = Enum.Font.GothamBold
    b.Parent = panel
    corner(b, 8)
    return b
end

local minimize = topButton("-", -78)
local close = topButton("X", -40)

local scroll = Instance.new("ScrollingFrame")
scroll.Position = UDim2.fromOffset(12, 53)
scroll.Size = UDim2.new(1, -24, 1, -94)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 3
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.CanvasSize = UDim2.fromOffset(0, 0)
scroll.Parent = panel

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 7)
layout.Parent = scroll

local function makeButton(text, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -5, 0, 39)
    b.BackgroundColor3 = Color3.fromRGB(55, 27, 85)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    b.Text = text
    b.Parent = scroll
    corner(b, 9)
    connect(b.MouseButton1Click, function()
        callback(b)
    end)
    return b
end

local aimButton

local function toggle(label, key)
    local b
    local function refresh()
        b.Text = label .. ": " ..
            (settings[key] and "ON" or "OFF")
        b.BackgroundColor3 = settings[key]
            and Color3.fromRGB(110, 43, 170)
            or Color3.fromRGB(55, 27, 85)
    end

    b = makeButton(label, function()
        settings[key] = not settings[key]
        refresh()

        if key == "Aimbot" and aimButton then
            aimButton.Visible = settings.Aimbot
            if not settings.Aimbot then
                aiming = false
            end
        end
    end)
    refresh()
end

toggle("🎯 AIMBOT HEAD", "Aimbot")
toggle("📦 ESP BOX", "ESP")
toggle("❤️ HEALTH BAR", "Health")
toggle("⭕ FOV CIRCLE", "FOV")
toggle("🧱 WALL CHECK", "Wall")
toggle("💀 IGNORE DEAD", "Dead")
toggle("🛡️ TEAM CHECK", "Team")

makeButton("FOV: 150", function(b)
    settings.Radius = settings.Radius + 25
    if settings.Radius > 350 then
        settings.Radius = 75
    end
    b.Text = "FOV: " .. settings.Radius
end)

makeButton("SMOOTH: 0.20", function(b)
    settings.Smooth = settings.Smooth + 0.1
    if settings.Smooth > 0.9 then
        settings.Smooth = 0.1
    end
    b.Text = string.format(
        "SMOOTH: %.2f", settings.Smooth
    )
end)

local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1, 0, 0, 28)
footer.Position = UDim2.new(0, 0, 1, -31)
footer.BackgroundTransparency = 1
footer.Text = "UNIVERSAL | O-BLOCK SYSTEM"
footer.TextColor3 = Color3.fromRGB(185, 115, 245)
footer.TextSize = 11
footer.Font = Enum.Font.GothamBold
footer.Parent = panel

local floating = Instance.new("TextButton")
floating.Size = UDim2.fromOffset(55, 55)
floating.Position = UDim2.new(0, 15, 0.5, -27)
floating.BackgroundColor3 = Color3.fromRGB(75, 25, 115)
floating.Text = "👺"
floating.TextSize = 27
floating.Visible = false
floating.Active = true
floating.Parent = gui
corner(floating, 27)

connect(minimize.MouseButton1Click, function()
    panel.Visible = false
    floating.Visible = true
end)

connect(floating.MouseButton1Click, function()
    floating.Visible = false
    panel.Visible = true
end)

local function drag(handle, object)
    local dragging = false
    local start
    local original
    local activeInput

    connect(handle.InputBegan, function(input)
        if input.UserInputType ==
            Enum.UserInputType.Touch
        or input.UserInputType ==
            Enum.UserInputType.MouseButton1 then

            dragging = true
            start = input.Position
            original = object.Position
            activeInput = input

            connect(input.Changed, function()
                if input.UserInputState ==
                    Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    connect(UIS.InputChanged, function(input)
        if not dragging then return end

        if input == activeInput or
            (activeInput.UserInputType ==
                Enum.UserInputType.MouseButton1
            and input.UserInputType ==
                Enum.UserInputType.MouseMovement) then

            local delta = input.Position - start
            object.Position = UDim2.new(
                original.X.Scale,
                original.X.Offset + delta.X,
                original.Y.Scale,
                original.Y.Offset + delta.Y
            )
        end
    end)
end

drag(title, panel)
drag(floating, floating)

aimButton = Instance.new("TextButton")
aimButton.Size = UDim2.fromOffset(83, 52)
aimButton.Position = UDim2.new(1, -95, 0.65, 0)
aimButton.BackgroundColor3 = Color3.fromRGB(100, 35, 155)
aimButton.Text = "🎯 MIRAR"
aimButton.TextColor3 = Color3.new(1, 1, 1)
aimButton.Font = Enum.Font.GothamBold
aimButton.TextSize = 13
aimButton.Visible = false
aimButton.Parent = gui
corner(aimButton, 12)

connect(aimButton.InputBegan, function(input)
    if input.UserInputType ==
        Enum.UserInputType.Touch
    or input.UserInputType ==
        Enum.UserInputType.MouseButton1 then
        aiming = true
    end
end)

connect(aimButton.InputEnded, function(input)
    if input.UserInputType ==
        Enum.UserInputType.Touch
    or input.UserInputType ==
        Enum.UserInputType.MouseButton1 then
        aiming = false
    end
end)

local circle = Instance.new("Frame")
circle.AnchorPoint = Vector2.new(0.5, 0.5)
circle.BackgroundTransparency = 1
circle.Parent = gui
corner(circle, 999)

local circleStroke = Instance.new("UIStroke")
circleStroke.Color = Color3.fromRGB(185, 85, 255)
circleStroke.Thickness = 2
circleStroke.Parent = circle

local function getCharacter(p)
    if p == LP then return end

    if settings.Team and LP.Team
        and p.Team == LP.Team then
        return
    end

    local char = p.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    local head = char:FindFirstChild("Head")
    local root = char:FindFirstChild("HumanoidRootPart")

    if not hum or not head or not root then
        return
    end

    if settings.Dead and hum.Health <= 0 then
        return
    end

    return char, hum, head, root
end

local function canSee(camera, char, head)
    if not settings.Wall then return true end

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude

    local ignore = {camera}
    if LP.Character then
        table.insert(ignore, LP.Character)
    end
    params.FilterDescendantsInstances = ignore

    local origin = camera.CFrame.Position
    local result = workspace:Raycast(
        origin,
        head.Position - origin,
        params
    )

    return result ~= nil
        and result.Instance:IsDescendantOf(char)
end

local function targetHead(camera)
    local viewport = camera.ViewportSize
    local center = Vector2.new(
        viewport.X / 2,
        viewport.Y / 2
    )

    local nearest = nil
    local distance = settings.Radius

    for _, p in ipairs(Players:GetPlayers()) do
        local char, hum, head = getCharacter(p)

        if head then
            local pos, visible =
                camera:WorldToViewportPoint(head.Position)

            if visible and pos.Z > 0 then
                local d = (
                    Vector2.new(pos.X, pos.Y) - center
                ).Magnitude

                if d < distance
                    and canSee(camera, char, head) then
                    nearest = head
                    distance = d
                end
            end
        end
    end

    return nearest
end

local function clearESP(p)
    if drawings[p] then
        drawings[p]:Destroy()
        drawings[p] = nil
    end
end

local function updateESP(p, camera)
    if not settings.ESP and not settings.Health then
        clearESP(p)
        return
    end

    local char, hum, head, root = getCharacter(p)
    if not char then
        clearESP(p)
        return
    end

    local top, visible =
        camera:WorldToViewportPoint(
            head.Position + Vector3.new(0, 0.7, 0)
        )

    local bottom = camera:WorldToViewportPoint(
        root.Position - Vector3.new(0, 3, 0)
    )

    if not visible or top.Z <= 0 or bottom.Z <= 0 then
        clearESP(p)
        return
    end

    local height = math.abs(bottom.Y - top.Y)
    local width = height * 0.55

    if height < 3 then
        clearESP(p)
        return
    end

    if not drawings[p] then
        local box = Instance.new("Frame")
        box.BackgroundTransparency = 1
        box.Parent = gui

        local outline = Instance.new("UIStroke")
        outline.Color = Color3.fromRGB(190, 75, 255)
        outline.Thickness = 2
        outline.Parent = box

        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(0, 5, 1, 0)
        bar.Position = UDim2.fromOffset(-10, 0)
        bar.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
        bar.BorderSizePixel = 0
        bar.Parent = box

        local fill = Instance.new("Frame")
        fill.AnchorPoint = Vector2.new(0, 1)
        fill.Position = UDim2.fromScale(0, 1)
        fill.Size = UDim2.fromScale(1, 1)
        fill.BorderSizePixel = 0
        fill.Parent = bar

        drawings[p] = box
    end

    local box = drawings[p]
    box.Size = UDim2.fromOffset(width, height)
    box.Position = UDim2.fromOffset(
        top.X - width / 2,
        math.min(top.Y, bottom.Y)
    )

    box.UIStroke.Enabled = settings.ESP

    local bar = box:FindFirstChildOfClass("Frame")
    if bar then
        bar.Visible = settings.Health

        local fill = bar:FindFirstChildOfClass("Frame")
        if fill then
            local hp = math.clamp(
                hum.Health / math.max(hum.MaxHealth, 1),
                0, 1
            )

            fill.Size = UDim2.fromScale(1, hp)
            fill.BackgroundColor3 = Color3.fromRGB(
                math.floor(255 * (1 - hp)),
                math.floor(255 * hp),
                30
            )
        end
    end
end

local elapsed = 0

connect(RunService.RenderStepped, function(dt)
    if not alive then return end

    local camera = workspace.CurrentCamera
    if not camera then return end

    local viewport = camera.ViewportSize

    circle.Visible = settings.FOV
    circle.Size = UDim2.fromOffset(
        settings.Radius * 2,
        settings.Radius * 2
    )
    circle.Position = UDim2.fromOffset(
        viewport.X / 2,
        viewport.Y / 2
    )

    if settings.Aimbot and aiming then
        local head = targetHead(camera)

        if head and head.Parent then
            local desired = CFrame.lookAt(
                camera.CFrame.Position,
                head.Position
            )

            camera.CFrame = camera.CFrame:Lerp(
                desired,
                settings.Smooth
            )
        end
    end

    elapsed = elapsed + dt

    if elapsed >= 0.1 then
        elapsed = 0

        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP then
                updateESP(p, camera)
            end
        end
    end
end)

connect(Players.PlayerRemoving, clearESP)

local function stop()
    alive = false
    aiming = false

    for _, c in ipairs(connections) do
        pcall(function()
            c:Disconnect()
        end)
    end

    for p in pairs(drawings) do
        clearESP(p)
    end

    gui:Destroy()
end

_G.OBLOCK_V9_STOP = stop

connect(close.MouseButton1Click, stop)

print("O-BLOCK V9 UNIVERSAL LOADED")
