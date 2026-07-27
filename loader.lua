-- ============================================================
--  Plalette Scripts · Knife Duels PRO (FINAL)
--  Silent Aim + Chams + Tracers + 1v1 + Speed + Jump
--  Passwort-UI NUR einmal pro Gerät (Datei-basiert)
--  FUNKTION DEFINIERT VOR DEM CHECK – immer ausführbar
-- ============================================================

-- ===== 1. HAUPTSKRIPT-FUNKTION (MUSS VOR DEM CHECK DEFINIERT WERDEN) =====
function LoadScript()
    local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local Lighting = game:GetService("Lighting")
    local UserInputService = game:GetService("UserInputService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer
    local Camera = Workspace.CurrentCamera

    -- ===== CONFIG =====
    local Config = {
        Enabled = true,
        HitPart = "Head",
        FOV = 450,
        Chams = false,
        Tracers = false,
        Speed = false,
        SpeedVal = 32,
        Jump = false,
        JumpVal = 60,
        FPSBoost = false,
        Fullbright = false,
    }

    -- ===== FOV CIRCLE + CROSSHAIR =====
    local FOVCircle = Drawing.new("Circle")
    FOVCircle.Filled = false
    FOVCircle.Thickness = 1.5
    FOVCircle.Color = Color3.fromRGB(140, 80, 255)
    FOVCircle.Visible = false

    local CrosshairH = Drawing.new("Line")
    CrosshairH.Color = Color3.fromRGB(255, 255, 255)
    CrosshairH.Thickness = 1
    CrosshairH.Visible = false

    local CrosshairV = Drawing.new("Line")
    CrosshairV.Color = Color3.fromRGB(255, 255, 255)
    CrosshairV.Thickness = 1
    CrosshairV.Visible = false

    task.spawn(function()
        while task.wait(0.03) do
            local center = Camera.ViewportSize / 2
            if Config.Enabled then
                FOVCircle.Visible = true
                FOVCircle.Radius = Config.FOV
                FOVCircle.Position = center
                CrosshairH.Visible = true
                CrosshairH.From = Vector2.new(center.X - 10, center.Y)
                CrosshairH.To = Vector2.new(center.X + 10, center.Y)
                CrosshairV.Visible = true
                CrosshairV.From = Vector2.new(center.X, center.Y - 10)
                CrosshairV.To = Vector2.new(center.X, center.Y + 10)
            else
                FOVCircle.Visible = false
                CrosshairH.Visible = false
                CrosshairV.Visible = false
            end
        end
    end)

    -- ===== SILENT AIM =====
    local KnifeController = require(LocalPlayer.PlayerScripts:WaitForChild("Controllers"):WaitForChild("Combat"):WaitForChild("KnifeController"))

    local function GetNearestPlayer()
        local nearest = nil
        local shortestDist = Config.FOV
        local center = Camera.ViewportSize / 2

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                local targetPart = player.Character:FindFirstChild(Config.HitPart)
                if targetPart then
                    local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                        if dist < shortestDist then
                            nearest = player
                            shortestDist = dist
                        end
                    end
                end
            end
        end
        return nearest
    end

    local originalGetThrowDirection = KnifeController._GetThrowDirection
    KnifeController._GetThrowDirection = function(self, character)
        if Config.Enabled then
            local target = GetNearestPlayer()
            if target and target.Character then
                local targetPart = target.Character:FindFirstChild(Config.HitPart)
                if targetPart then
                    return (targetPart.Position - character.Position).Unit
                end
            end
        end
        return originalGetThrowDirection(self, character)
    end

    -- ===== SPEED + JUMP =====
    local function ApplySpeedJump()
        if not LocalPlayer.Character then return end
        local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then
            if Config.Speed then h.WalkSpeed = Config.SpeedVal end
            if Config.Jump then h.JumpPower = Config.JumpVal end
        end
    end

    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.5)
        ApplySpeedJump()
    end)

    RunService.Stepped:Connect(function()
        if LocalPlayer.Character then
            local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if h then
                if Config.Speed and h.WalkSpeed ~= Config.SpeedVal then
                    h.WalkSpeed = Config.SpeedVal
                end
                if Config.Jump and h.JumpPower ~= Config.JumpVal then
                    h.JumpPower = Config.JumpVal
                end
            end
        end
    end)

    -- ===== CHAMS =====
    local function IsThrowFree(targetPart)
        if not targetPart then return false end
        local origin = Camera.CFrame.Position
        local direction = (targetPart.Position - origin).Unit
        local ray = Ray.new(origin, direction * 200)
        local hit = Workspace:FindPartOnRay(ray, LocalPlayer.Character)
        if hit then
            local distToTarget = (targetPart.Position - origin).Magnitude
            local distToHit = (hit.Position - origin).Magnitude
            if distToHit < distToTarget - 1 then
                return false
            end
        end
        return true
    end

    task.spawn(function()
        while task.wait(0.1) do
            if Config.Chams then
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local hl = player.Character:FindFirstChild("ChamsHL")
                        if not hl then
                            hl = Instance.new("Highlight")
                            hl.Name = "ChamsHL"
                            hl.FillTransparency = 0.6
                            hl.OutlineTransparency = 0.3
                            hl.Parent = player.Character
                        end
                        local targetPart = player.Character:FindFirstChild(Config.HitPart)
                        if IsThrowFree(targetPart) then
                            hl.OutlineColor = Color3.fromRGB(0, 255, 0)
                        else
                            hl.OutlineColor = Color3.fromRGB(255, 0, 0)
                        end
                    end
                end
            else
                for _, player in ipairs(Players:GetPlayers()) do
                    if player.Character then
                        local hl = player.Character:FindFirstChild("ChamsHL")
                        if hl then hl:Destroy() end
                    end
                end
            end
        end
    end)

    -- ===== TRACERS =====
    local Tracers = {}
    local function ClearTracers()
        for _, d in pairs(Tracers) do pcall(function() d:Remove() end) end
        Tracers = {}
    end

    local tracerUpdate = 0
    RunService.RenderStepped:Connect(function()
        tracerUpdate = tracerUpdate + 1
        if tracerUpdate < 2 then return end
        tracerUpdate = 0
        ClearTracers()
        if not Config.Tracers then return end
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local pos, on = Camera:WorldToViewportPoint(hrp.Position)
                    if on then
                        local tracer = Drawing.new("Line")
                        tracer.Color = Color3.fromRGB(180, 130, 255)
                        tracer.Thickness = 0.8
                        tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                        tracer.To = Vector2.new(pos.X, pos.Y)
                        tracer.Visible = true
                        table.insert(Tracers, tracer)
                    end
                end
            end
        end
    end)

    -- ===== 1v1 REQUEST ALL =====
    local function RequestAll()
        local remote = nil
        for _, v in ipairs(game:GetDescendants()) do
            if v:IsA("RemoteEvent") and (v.Name:lower():find("duel") or v.Name:lower():find("request") or v.Name:lower():find("1v1") or v.Name:lower():find("challenge") or v.Name:lower():find("invite")) then
                remote = v
                break
            end
        end

        if not remote then
            pcall(function()
                game:GetService("Chat"):Chat(LocalPlayer.Character, "/duelall")
            end)
            return 0
        end

        local count = 0
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                pcall(function()
                    remote:FireServer(player)
                    count = count + 1
                end)
            end
        end
        return count
    end

    -- ===== FPS BOOST =====
    task.spawn(function()
        while task.wait(1) do
            if Config.FPSBoost then
                Lighting.GlobalShadows = false
                Lighting.FogEnd = 0
                for _, v in ipairs(Workspace:GetDescendants()) do
                    if v:IsA("ParticleEmitter") then v.Enabled = false end
                end
            else
                Lighting.GlobalShadows = true
                Lighting.FogEnd = 10000
            end
        end
    end)

    -- ===== FULLBRIGHT =====
    task.spawn(function()
        while task.wait(1) do
            if Config.Fullbright then
                Lighting.Brightness = 2
            else
                Lighting.Brightness = 1
            end
        end
    end)

    -- ===== ANTI-AFK =====
    task.spawn(function()
        while task.wait(60) do
            pcall(function()
                local VIM = game:GetService("VirtualInputManager")
                VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, nil)
                task.wait(0.1)
                VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, nil)
            end)
        end
    end)

    -- ===== UI =====
    local Window = Rayfield:CreateWindow({
        name = "Knife Duels PRO",
        subtitle = "Plalette Scripts | Silent Aim",
    })

    local CombatTab = Window:CreateTab({ name = "Combat", icon = "crosshair" })
    local VisualTab = Window:CreateTab({ name = "Visuals", icon = "eye" })
    local MoveTab = Window:CreateTab({ name = "Movement", icon = "footprints" })
    local UtilityTab = Window:CreateTab({ name = "Utility", icon = "gear" })

    CombatTab:CreateSection("Silent Aim")
    CombatTab:CreateToggle({ name = "Silent Aim (100% Hit)", currentValue = true, callback = function(v) Config.Enabled = v end })
    CombatTab:CreateSlider({ name = "FOV Radius", range = {30, 600}, increment = 10, currentValue = 450, callback = function(v) Config.FOV = v end })
    CombatTab:CreateDropdown({ name = "Target Hitbox", options = {"Head", "HumanoidRootPart", "Torso"}, currentOption = "Head", callback = function(v) Config.HitPart = v end })

    CombatTab:CreateSection("1v1")
    CombatTab:CreateButton({ name = "📨 Request All (1v1)", callback = function()
        local count = RequestAll()
        if count > 0 then
            Window:Notify({ title = "1v1", content = "Sent to " .. count .. " players!" })
        else
            Window:Notify({ title = "1v1", content = "No RemoteEvent – tried /duelall" })
        end
    end })

    VisualTab:CreateSection("Visuals")
    VisualTab:CreateToggle({ name = "Chams (Green = free throw)", currentValue = false, callback = function(v) Config.Chams = v end })
    VisualTab:CreateToggle({ name = "Tracers (smooth)", currentValue = false, callback = function(v) Config.Tracers = v end })

    MoveTab:CreateSection("Speed")
    MoveTab:CreateToggle({ name = "Speed Hack", currentValue = false, callback = function(v) Config.Speed = v ApplySpeedJump() end })
    MoveTab:CreateSlider({ name = "Walk Speed", range = {16, 100}, increment = 2, currentValue = 32, callback = function(v) Config.SpeedVal = v ApplySpeedJump() end })

    MoveTab:CreateSection("Jump Power")
    MoveTab:CreateToggle({ name = "Jump Power Hack", currentValue = false, callback = function(v) Config.Jump = v ApplySpeedJump() end })
    MoveTab:CreateSlider({ name = "Jump Power", range = {50, 300}, increment = 10, currentValue = 60, callback = function(v) Config.JumpVal = v ApplySpeedJump() end })

    UtilityTab:CreateSection("Performance")
    UtilityTab:CreateToggle({ name = "FPS Boost", currentValue = false, callback = function(v) Config.FPSBoost = v end })
    UtilityTab:CreateToggle({ name = "Fullbright", currentValue = false, callback = function(v) Config.Fullbright = v end })
    UtilityTab:CreateLabel({ name = "💡 Silent Aim only active on throw – no lag" })

    Window:Notify({ title = "Plalette Scripts", content = "Knife Duels PRO loaded!" })
end

-- ===== 2. CHECK: PASSWORT-DATEI VORHANDEN? =====
local passwordUnlocked = false
if isfile and isfile("Plalette_Password.txt") then
    passwordUnlocked = true
end

if passwordUnlocked then
    LoadScript()
    return
end

-- ===== 3. PASSWORT-UI (nur wenn Datei NICHT existiert) =====
local PassScreen = Instance.new("ScreenGui")
PassScreen.Parent = game:GetService("CoreGui")

local PassFrame = Instance.new("Frame")
PassFrame.Size = UDim2.new(0, 280, 0, 170)
PassFrame.Position = UDim2.new(0.5, -140, 0.5, -85)
PassFrame.BackgroundColor3 = Color3.fromRGB(14, 12, 24)
PassFrame.BorderSizePixel = 0
PassFrame.Active = true
PassFrame.Draggable = true
PassFrame.Parent = PassScreen
Instance.new("UICorner", PassFrame).CornerRadius = UDim.new(0, 10)

local PGL = Instance.new("Frame")
PGL.Size = UDim2.new(1, 2, 1, 2)
PGL.Position = UDim2.new(0, -1, 0, -1)
PGL.BackgroundColor3 = Color3.fromRGB(140, 80, 255)
PGL.BackgroundTransparency = 0.5
PGL.BorderSizePixel = 0
PGL.Parent = PassFrame
Instance.new("UICorner", PGL).CornerRadius = UDim.new(0, 10)

local PT = Instance.new("TextLabel")
PT.Size = UDim2.new(1, 0, 0, 26)
PT.Position = UDim2.new(0, 0, 0, 18)
PT.BackgroundTransparency = 1
PT.TextColor3 = Color3.fromRGB(255, 255, 255)
PT.Text = "Knife Duels PRO"
PT.Font = Enum.Font.SourceSansBold
PT.TextSize = 20
PT.Parent = PassFrame

local PS = Instance.new("TextLabel")
PS.Size = UDim2.new(1, 0, 0, 16)
PS.Position = UDim2.new(0, 0, 0, 46)
PS.BackgroundTransparency = 1
PS.TextColor3 = Color3.fromRGB(180, 140, 200)
PS.Text = "Plalette Scripts"
PS.Font = Enum.Font.SourceSans
PS.TextSize = 13
PS.Parent = PassFrame

local PI = Instance.new("TextBox")
PI.Size = UDim2.new(1, -40, 0, 28)
PI.Position = UDim2.new(0, 20, 0, 70)
PI.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
PI.TextColor3 = Color3.fromRGB(255, 255, 255)
PI.PlaceholderText = "Password..."
PI.Text = ""
PI.Font = Enum.Font.SourceSans
PI.TextSize = 14
PI.Parent = PassFrame
Instance.new("UICorner", PI).CornerRadius = UDim.new(0, 8)

local PB = Instance.new("TextButton")
PB.Size = UDim2.new(1, -40, 0, 26)
PB.Position = UDim2.new(0, 20, 0, 105)
PB.BackgroundColor3 = Color3.fromRGB(140, 80, 255)
PB.TextColor3 = Color3.fromRGB(255, 255, 255)
PB.Text = "Unlock"
PB.Font = Enum.Font.SourceSansBold
PB.TextSize = 14
PB.Parent = PassFrame
Instance.new("UICorner", PB).CornerRadius = UDim.new(0, 8)

local DiscFrame = Instance.new("Frame")
DiscFrame.Size = UDim2.new(1, -40, 0, 20)
DiscFrame.Position = UDim2.new(0, 20, 0, 138)
DiscFrame.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
DiscFrame.BackgroundTransparency = 0.1
DiscFrame.Parent = PassFrame
Instance.new("UICorner", DiscFrame).CornerRadius = UDim.new(0, 5)

local DiscLabel = Instance.new("TextLabel")
DiscLabel.Size = UDim2.new(0.7, 0, 1, 0)
DiscLabel.Position = UDim2.new(0, 6, 0, 0)
DiscLabel.BackgroundTransparency = 1
DiscLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
DiscLabel.Text = "Get Password"
DiscLabel.Font = Enum.Font.SourceSans
DiscLabel.TextSize = 10
DiscLabel.TextXAlignment = Enum.TextXAlignment.Left
DiscLabel.Parent = DiscFrame

local CopyBtn = Instance.new("TextButton")
CopyBtn.Size = UDim2.new(0.25, 0, 0, 16)
CopyBtn.Position = UDim2.new(0.72, 0, 0, 2)
CopyBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
CopyBtn.BackgroundTransparency = 0.2
CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyBtn.Text = "Copy"
CopyBtn.Font = Enum.Font.SourceSansBold
CopyBtn.TextSize = 9
CopyBtn.Parent = DiscFrame
Instance.new("UICorner", CopyBtn).CornerRadius = UDim.new(0, 3)

CopyBtn.MouseButton1Click:Connect(function()
    setclipboard("https://discord.gg/duhxrB85tW")
    CopyBtn.Text = "OK"
    task.wait(2)
    CopyBtn.Text = "Copy"
end)

local function Try()
    if PI.Text == "plalettescripts3754356" then
        PassScreen:Destroy()
        if writefile then
            writefile("Plalette_Password.txt", "unlocked")
        end
        LoadScript()
    else
        PI.Text = ""
        PI.PlaceholderText = "Wrong!"
        task.wait(0.8)
        PI.PlaceholderText = "Password..."
    end
end
PB.MouseButton1Click:Connect(Try)
PI.FocusLost:Connect(function(ep) if ep then Try() end end)
