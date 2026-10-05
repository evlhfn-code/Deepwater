local Workspace = game:GetService("Workspace")

local WorldService = {}

function WorldService:Build()
    if Workspace:FindFirstChild("DeepwaterWorld") then return end

    local world = Instance.new("Folder")
    world.Name = "DeepwaterWorld"
    world.Parent = Workspace

    local function part(name, size, position, material)
        local p = Instance.new("Part")
        p.Name = name
        p.Size = size
        p.Position = position
        p.Anchored = true
        p.Material = material or Enum.Material.SmoothPlastic
        p.Parent = world
        return p
    end

    local water = part("Ocean", Vector3.new(600, 4, 600), Vector3.new(0, 0, 0), Enum.Material.Water)
    water.Transparency = 0.25
    water.CanCollide = false

    part("StarterIsland", Vector3.new(140, 8, 140), Vector3.new(0, 2, 0), Enum.Material.Grass)
    part("Dock", Vector3.new(80, 3, 18), Vector3.new(0, 7, 70), Enum.Material.WoodPlanks)

    local sellPad = part("SellPad", Vector3.new(18, 1, 18), Vector3.new(-35, 8, 20), Enum.Material.Neon)
    sellPad:SetAttribute("Purpose", "SellFish")

    local sign = Instance.new("BillboardGui")
    sign.Size = UDim2.fromOffset(240, 70)
    sign.StudsOffset = Vector3.new(0, 5, 0)
    sign.AlwaysOnTop = true
    sign.Parent = sellPad

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = "SELL FISH"
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = sign
end

return WorldService
