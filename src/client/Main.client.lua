local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local castEvent = remotes:WaitForChild("Cast")
local reelEvent = remotes:WaitForChild("Reel")
local sellEvent = remotes:WaitForChild("SellAll")
local stateEvent = remotes:WaitForChild("State")

local gui = Instance.new("ScreenGui")
gui.Name = "DeepwaterUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local status = Instance.new("TextLabel")
status.Size = UDim2.fromOffset(520, 70)
status.Position = UDim2.new(0.5, -260, 1, -100)
status.BackgroundTransparency = 0.2
status.TextScaled = true
status.Font = Enum.Font.GothamBold
status.Text = "Deepwater • F = cast"
status.Parent = gui

local coins = Instance.new("TextLabel")
coins.Size = UDim2.fromOffset(220, 45)
coins.Position = UDim2.fromOffset(20, 20)
coins.BackgroundTransparency = 0.2
coins.TextScaled = true
coins.Font = Enum.Font.GothamBold
coins.Text = "Coins: 0"
coins.Parent = gui

local function cast()
    local character = player.Character or player.CharacterAdded:Wait()
    local root = character:WaitForChild("HumanoidRootPart")
    local camera = workspace.CurrentCamera
    castEvent:FireServer(root.Position + camera.CFrame.LookVector * 70)
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.F then
        cast()
    elseif input.KeyCode == Enum.KeyCode.R then
        reelEvent:FireServer()
    elseif input.KeyCode == Enum.KeyCode.E then
        sellEvent:FireServer()
    end
end)

stateEvent.OnClientEvent:Connect(function(state)
    if state.type == "Ready" then
        coins.Text = "Coins: " .. state.coins
        status.Text = "F = cast   R = reel   E = sell"
    elseif state.type == "Cast" then
        status.Text = "Waiting for a bite..."
    elseif state.type == "Bite" then
        status.Text = "🐟 BITE! Press R!"
    elseif state.type == "Catch" then
        status.Text = string.format("Caught %s • %.2f kg • $%d", state.fish.Name, state.fish.Weight, state.fish.Value)
    elseif state.type == "Miss" then
        status.Text = "Missed! Press F to cast again."
    elseif state.type == "Full" then
        status.Text = "Inventory full! Press E to sell."
    elseif state.type == "Sold" then
        coins.Text = "Coins: " .. state.coins
        status.Text = "Sold fish for $" .. state.payout .. "!"
    end
end)
