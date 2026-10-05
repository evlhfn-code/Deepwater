local Config = require(game.ReplicatedStorage.Shared.Config)

local InventoryService = {}

local inventories = {}

function InventoryService:Init() end

function InventoryService:LoadPlayer(player)
    inventories[player] = {}
end

function InventoryService:UnloadPlayer(player)
    inventories[player] = nil
end

function InventoryService:GetInventory(player)
    return inventories[player] or {}
end

function InventoryService:AddFish(player, fish)
    local inventory = inventories[player]
    if not inventory or #inventory >= Config.Inventory.MaxFish then return false end
    table.insert(inventory, fish)
    return true
end

function InventoryService:SellAll(player)
    local inventory = inventories[player]
    if not inventory then return 0 end
    local payout = 0
    for _, fish in ipairs(inventory) do payout += fish.Value end
    table.clear(inventory)
    return payout
end

return InventoryService
