local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Services = script.Parent.Services
local EconomyService = require(Services.EconomyService)
local InventoryService = require(Services.InventoryService)
local FishingService = require(Services.FishingService)
local WorldService = require(Services.WorldService)

local remotes = ReplicatedStorage:FindFirstChild("Remotes") or Instance.new("Folder")
remotes.Name = "Remotes"
remotes.Parent = ReplicatedStorage

local function remote(name)
    local existing = remotes:FindFirstChild(name)
    if existing then return existing end
    local event = Instance.new("RemoteEvent")
    event.Name = name
    event.Parent = remotes
    return event
end

local castEvent = remote("Cast")
local reelEvent = remote("Reel")
local sellEvent = remote("SellAll")
local stateEvent = remote("State")

EconomyService:Init()
InventoryService:Init()
FishingService:Init(castEvent, reelEvent, stateEvent)
WorldService:Build()

Players.PlayerAdded:Connect(function(player)
    EconomyService:LoadPlayer(player)
    InventoryService:LoadPlayer(player)
    task.defer(function()
        stateEvent:FireClient(player, {
            type = "Ready",
            coins = EconomyService:GetCoins(player),
            inventory = InventoryService:GetInventory(player),
        })
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    EconomyService:UnloadPlayer(player)
    InventoryService:UnloadPlayer(player)
end)

sellEvent.OnServerEvent:Connect(function(player)
    local payout = InventoryService:SellAll(player)
    if payout > 0 then EconomyService:AddCoins(player, payout) end
    stateEvent:FireClient(player, {
        type = "Sold",
        payout = payout,
        coins = EconomyService:GetCoins(player),
        inventory = InventoryService:GetInventory(player),
    })
end)
