local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local FishData = require(ReplicatedStorage.Shared.FishData)
local InventoryService = require(script.Parent.InventoryService)

local FishingService = {}
local states = {}

local function rollFish()
    local totalWeight = 0
    for _, data in pairs(FishData) do totalWeight += data.Weight end

    local roll = math.random() * totalWeight
    local running = 0

    for id, data in pairs(FishData) do
        running += data.Weight
        if roll <= running then
            local weight = data.MinWeight + math.random() * (data.MaxWeight - data.MinWeight)
            local value = math.max(1, math.floor(data.BaseValue * weight))
            return {
                Id = id,
                Name = data.DisplayName,
                Rarity = data.Rarity,
                Weight = math.floor(weight * 100) / 100,
                Value = value,
            }
        end
    end
end

function FishingService:Init(castEvent, reelEvent, stateEvent)
    castEvent.OnServerEvent:Connect(function(player, castPosition)
        local now = os.clock()
        local old = states[player]

        if old and now - old.LastCast < Config.Fishing.CastCooldown then return end
        if typeof(castPosition) ~= "Vector3" then return end

        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not root or (castPosition - root.Position).Magnitude > Config.Fishing.MaxCastDistance then return end

        states[player] = {
            LastCast = now,
            BiteReady = false,
            BiteTime = now + Config.Fishing.MinBiteTime + math.random() * (Config.Fishing.MaxBiteTime - Config.Fishing.MinBiteTime),
        }

        stateEvent:FireClient(player, {type = "Cast"})
    end)

    reelEvent.OnServerEvent:Connect(function(player)
        local state = states[player]
        if not state or not state.BiteReady then return end

        local fish = rollFish()
        if not fish then
            states[player] = nil
            stateEvent:FireClient(player, {type = "Miss"})
            return
        end

        if not InventoryService:AddFish(player, fish) then
            states[player] = nil
            stateEvent:FireClient(player, {type = "Full", inventory = InventoryService:GetInventory(player)})
            return
        end

        states[player] = nil
        stateEvent:FireClient(player, {type = "Catch", fish = fish, inventory = InventoryService:GetInventory(player)})
    end)

    task.spawn(function()
        while true do
            task.wait(0.2)
            local now = os.clock()
            for player, state in pairs(states) do
                if player.Parent and not state.BiteReady and now >= state.BiteTime then
                    state.BiteReady = true
                    state.ReelDeadline = now + Config.Fishing.ReelWindow
                    stateEvent:FireClient(player, {type = "Bite", window = Config.Fishing.ReelWindow})
                elseif player.Parent and state.BiteReady and state.ReelDeadline and now > state.ReelDeadline then
                    states[player] = nil
                    stateEvent:FireClient(player, {type = "Miss"})
                end
            end
        end
    end)

    Players.PlayerRemoving:Connect(function(player)
        states[player] = nil
    end)
end

return FishingService
