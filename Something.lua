-- [[ STARZ HUB: THE DOW AHH SPECIAL ]] --
-- Features: Instant TP, Safe-Box Anchor, and Highest Value Tracer.

local S = {
    Players = game:GetService("Players"),
    UserInputService = game:GetService("UserInputService"),
    TweenService = game:GetService("TweenService"),
    RunService = game:GetService("RunService"),
    PPS = game:GetService("ProximityPromptService"),
}

local LP = S.Players.LocalPlayer
local CONFIG = {
    Enabled = false,
    SafePos = nil,
    Target = nil
}

-- // 1. VISUALS: SAFE-BOX & TRACER
local safeBox = Instance.new("Part", workspace)
safeBox.Name = "Starz_SafeBox"
safeBox.Size = Vector3.new(8, 2, 8)
safeBox.Transparency = 0.6
safeBox.Color = Color3.fromRGB(0, 255, 255)
safeBox.Material = Enum.Material.Neon
safeBox.Anchored = true
safeBox.CanCollide = false

local selection = Instance.new("SelectionBox", safeBox)
selection.Adornee = safeBox
selection.Color3 = Color3.fromRGB(0, 255, 255)
selection.LineThickness = 0.05

-- Tracer Beam to target
local attachment0 = Instance.new("Attachment", LP.Character:WaitForChild("HumanoidRootPart"))
local beam = Instance.new("Beam", LP.Character.HumanoidRootPart)
beam.Width0 = 0.2
beam.Width1 = 0.2
beam.Enabled = false
beam.Color = ColorSequence.new(Color3.fromRGB(255, 0, 255))
beam.Attachment0 = attachment0

-- // 2. SCANNER: FIND HIGHEST VALUE
local function updateTarget()
    local best = nil
    local maxVal = -1
    for _, prompt in pairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") and (prompt.ActionText:find("Steal") or prompt.ObjectText:find("Brainrot")) then
            local val = prompt.Parent:FindFirstChild("Value") or prompt.Parent:FindFirstChild("Price")
            local price = val and val.Value or 0
            if price > maxVal then
                maxVal = price
                best = prompt
            end
        end
    end
    CONFIG.Target = best
    if best and best.Parent:IsA("BasePart") then
        local att1 = best.Parent:FindFirstChild("StarzAtt") or Instance.new("Attachment", best.Parent)
        att1.Name = "StarzAtt"
        beam.Attachment1 = att1
        beam.Enabled = CONFIG.Enabled
    end
end

-- // 3. THE INSTANT TP BYPASS
local function doInstantTP()
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or not CONFIG.SafePos then return end

    -- Velocity Masking (Server-Side Bypass)
    hrp.AssemblyLinearVelocity = Vector3.new(0, -600, 0)
    task.wait(0.05) -- Wait for server acknowledgment
    
    -- Instant Snap to Safe-Box
    hrp.CFrame = CONFIG.SafePos + Vector3.new(0, 3, 0)
    
    task.wait(0.02)
    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
end

-- // 4. UI CONSTRUCTION
local screen = Instance.new("ScreenGui", LP.PlayerGui)
local main = Instance.new("Frame", screen)
main.Size = UDim2.new(0, 220, 0, 160)
main.Position = UDim2.new(0.5, -110, 0.2, 0)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
main.BorderSizePixel = 0
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "STARZ HUB V3"
title.TextColor3 = Color3.fromRGB(0, 255, 255)
title.Font = Enum.Font.GothamBold
title.BackgroundTransparency = 1

local function createBtn(text, pos, callback)
    local btn = Instance.new("TextButton", main)
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamMedium
    btn.AutoButtonColor = true
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local tpToggle = createBtn("INSTANT TP: OFF", UDim2.new(0.05, 0, 0, 50), function()
    CONFIG.Enabled = not CONFIG.Enabled
    main.TextButton.Text = CONFIG.Enabled and "INSTANT TP: ON" or "INSTANT TP: OFF"
    main.TextButton.TextColor3 = CONFIG.Enabled and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 255, 255)
    beam.Enabled = CONFIG.Enabled
    if CONFIG.Enabled then updateTarget() end
end)

local setPos = createBtn("SET POSITION", UDim2.new(0.05, 0, 0, 100), function()
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        CONFIG.SafePos = hrp.CFrame
        safeBox.CFrame = hrp.CFrame - Vector3.new(0, 3, 0)
        setPos.Text = "POS LOCKED"
        task.wait(0.5)
        setPos.Text = "SET POSITION"
    end
end)

-- // 5. HOOKS
S.PPS.PromptButtonHoldEnded:Connect(function(prompt, player)
    if player == LP and CONFIG.Enabled then
        doInstantTP()
        task.wait(1)
        updateTarget() -- Refresh tracer for the next item
    end
end)

-- Draggable
local d, ds, sp
main.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = true ds = i.Position sp = main.Position end end)
S.UserInputService.InputChanged:Connect(function(i) if d and i.UserInputType == Enum.UserInputType.MouseMovement then local delta = i.Position - ds main.Position = UDim2.new(sp.X.Scale, sp.X.Offset + delta.X, sp.Y.Scale, sp.Y.Offset + delta.Y) end end)
S.UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = false end end)

-- Keep the tracer updated
S.RunService.RenderStepped:Connect(function()
    if CONFIG.Enabled and math.random(1, 100) == 1 then updateTarget() end
end)
