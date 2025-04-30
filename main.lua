local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

-- Whitelist
local WHITELIST_URL = "https://raw.githubusercontent.com/zzzaycevich/GenEX/main/whitelist.json"
local localPlayer = Players.LocalPlayer
local whitelist = {}

-- Config
local SETTINGS = {
    ESP = {
        Enabled = true,
        BoxColor = Color3.fromRGB(0, 255, 0),
        TeamCheck = true,
        HealthBased = true
    },
    AimAssist = {
        Enabled = true,
        FOV = 100,
        Smoothness = 0.2
    },
    Noclip = {
        Enabled = false,
        Keybind = Enum.KeyCode.N
    },
    Speedhack = {
        Enabled = false,
        Speed = 30,
        Keybind = Enum.KeyCode.LeftShift
    },
    UI = {
        MainKey = Enum.KeyCode.Insert,
        Watermark = "GenEX Premium"
    }
}

local function checkWhitelist()
    -- local success, response = pcall(function()
    --    return HttpService:GetAsync(WHITELIST_URL)
    -- end)
    
    --if success then
    --    whitelist = HttpService:JSONDecode(response)
    --else
    --    warn("Cannot load whitelist: " .. tostring(response))
    --end
    
    --if not table.find(whitelist, localPlayer.UserId) then
    --    local blockGui = Instance.new("ScreenGui")
    --    blockGui.Name = math.random(-math.huge, math.huge)
    --    blockGui.Parent = CoreGui
    --    
    --    local frame = Instance.new("Frame")
    --    frame.Size = UDim2.new(1, 0, 1, 0)
    --    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    --    frame.Parent = blockGui
    --    
    --    local text = Instance.new("TextLabel")
    --    text.Text = "GenEX | Access Denied"
    --    text.Size = UDim2.new(1, 0, 0.5, 0)
    --    text.Position = UDim2.new(0, 0, 0.25, 0)
    --    text.TextColor3 = Color3.fromRGB(255, 50, 50)
    --    text.Font = Enum.Font.GothamBold
    --    text.TextSize = 24
    --    text.Parent = frame
        
    --    return false
    --end
    return true
end

if not checkWhitelist() then return end

local GenEXUI = Instance.new("ScreenGui")
GenEXUI.Name = math.random(-math.huge, math.huge)
GenEXUI.Parent = CoreGui

local watermark = Instance.new("TextLabel")
watermark.Text = SETTINGS.UI.Watermark
watermark.TextColor3 = Color3.fromRGB(0, 255, 255)
watermark.Font = Enum.Font.GothamBold
watermark.TextSize = 14
watermark.BackgroundTransparency = 1
watermark.Size = UDim2.new(0, 200, 0, 30)
watermark.Position = UDim2.new(1, -210, 0, 10)
watermark.TextXAlignment = Enum.TextXAlignment.Right
watermark.Parent = GenEXUI

local ESPContainer = Instance.new("Frame")
ESPContainer.Name = "ESP_Container"
ESPContainer.BackgroundTransparency = 1
ESPContainer.Size = UDim2.new(1, 0, 1, 0)
ESPContainer.Parent = GenEXUI

local function updateESP()
    ESPContainer:ClearAllChildren()
    if not SETTINGS.ESP.Enabled then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = player.Character:FindFirstChild("Humanoid")
            
            if root and humanoid then
                if SETTINGS.ESP.TeamCheck and player.Team == localPlayer.Team then continue end
                
                local screenPos, visible = workspace.CurrentCamera:WorldToViewportPoint(root.Position)
                if visible then
                    local boxSize = math.clamp(5000 / (workspace.CurrentCamera.CFrame.Position - root.Position).Magnitude, 10, 200)
                    local espFrame = Instance.new("Frame")
                    espFrame.Size = UDim2.new(0, boxSize, 0, boxSize * 1.8)
                    espFrame.Position = UDim2.new(0, screenPos.X, 0, screenPos.Y)
                    espFrame.AnchorPoint = Vector2.new(0.5, 0.5)
                    espFrame.BackgroundTransparency = 0.8
                    espFrame.BorderSizePixel = 2
                    
                    if SETTINGS.ESP.HealthBased then
                        local healthRatio = humanoid.Health / humanoid.MaxHealth
                        espFrame.BackgroundColor3 = Color3.new(1 - healthRatio, healthRatio, 0)
                    else
                        espFrame.BackgroundColor3 = SETTINGS.ESP.BoxColor
                    end
                    
                    local nameLabel = Instance.new("TextLabel")
                    nameLabel.Text = player.Name
                    nameLabel.TextColor3 = Color3.new(1, 1, 1)
                    nameLabel.TextSize = 12
                    nameLabel.Font = Enum.Font.GothamBold
                    nameLabel.BackgroundTransparency = 1
                    nameLabel.Size = UDim2.new(1, 0, 0, 20)
                    nameLabel.Position = UDim2.new(0, 0, 0, -20)
                    nameLabel.Parent = espFrame
                    
                    espFrame.Parent = ESPContainer
                end
            end
        end
    end
end

local noclipConn
local function toggleNoclip()
    SETTINGS.Noclip.Enabled = not SETTINGS.Noclip.Enabled
    if SETTINGS.Noclip.Enabled then
        noclipConn = RunService.Stepped:Connect(function()
            if localPlayer.Character then
                for _, part in ipairs(localPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    elseif noclipConn then
        noclipConn:Disconnect()
    end
end

local function applySpeedhack()
    if localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then
        localPlayer.Character.Humanoid.WalkSpeed = SETTINGS.Speedhack.Enabled and SETTINGS.Speedhack.Speed or 16
    end
end

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 0)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Visible = false
mainFrame.Parent = GenEXUI

local function toggleUI()
    mainFrame.Visible = not mainFrame.Visible
    TweenService:Create(mainFrame, TweenInfo.new(0.3), {
        Size = mainFrame.Visible and UDim2.new(0, 350, 0, 400) or UDim2.new(0, 350, 0, 0)
    }):Play()
end

local yOffset = 10
local function createControl(text, config, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 30)
    frame.Position = UDim2.new(0, 10, 0, yOffset)
    frame.BackgroundTransparency = 1
    frame.Parent = mainFrame
    
    local button = Instance.new("TextButton")
    button.Text = text
    button.Size = UDim2.new(0, 200, 1, 0)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.BackgroundColor3 = config.Enabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
    button.Parent = frame
    
    button.MouseButton1Click:Connect(function()
        config.Enabled = not config.Enabled
        button.BackgroundColor3 = config.Enabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
        if callback then callback() end
    end)
    
    yOffset += 35
end

createControl("ESP", SETTINGS.ESP, updateESP)
createControl("Aim Assist", SETTINGS.AimAssist)
createControl("Noclip (N)", SETTINGS.Noclip, toggleNoclip)
createControl("Speedhack (LShift)", SETTINGS.Speedhack, applySpeedhack)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == SETTINGS.UI.MainKey then
        toggleUI()
    elseif input.KeyCode == SETTINGS.Noclip.Keybind then
        toggleNoclip()
    elseif input.KeyCode == SETTINGS.Speedhack.Keybind then
        SETTINGS.Speedhack.Enabled = true
        applySpeedhack()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == SETTINGS.Speedhack.Keybind then
        SETTINGS.Speedhack.Enabled = false
        applySpeedhack()
    end
end)

RunService.Heartbeat:Connect(updateESP)

toggleUI()
task.delay(3, toggleUI)

print("GenEX loaded successfully.")
