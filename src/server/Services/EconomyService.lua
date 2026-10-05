local Players = game:GetService("Players")
local Config = require(game.ReplicatedStorage.Shared.Config)

local EconomyService = {}
local coins = {}

function EconomyService:Init()
    Players.PlayerRemoving:Connect(function(player)
        coins[player] = nil
    end)
end

function EconomyService:LoadPlayer(player)
    coins[player] = Config.Economy.StartingCoins
end

function EconomyService:UnloadPlayer(player)
    coins[player] = nil
end

function EconomyService:GetCoins(player)
    return coins[player] or 0
end

function EconomyService:AddCoins(player, amount)
    if amount <= 0 then return end
    coins[player] = self:GetCoins(player) + math.floor(amount)
end

return EconomyService
