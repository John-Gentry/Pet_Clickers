--This script inserts a new egg by type into ClientObjects
Egg = {}
Egg._index = Egg

function Egg.GetPosition()
    return game.Workspace:WaitForChild("DebugObjects"):WaitForChild("EggPositionLocation").Position
end

function Egg.new(Type,EggPosition)
    local Eggs = game.ReplicatedStorage.Eggs
    local ClientObjects = game.Workspace.ClientObjects
    local NewEgg = {}
    setmetatable(NewEgg, Egg)
    NewEgg.Model = Eggs:WaitForChild("StarterEgg"):Clone()
    NewEgg.Model.Position = EggPosition
    NewEgg.Model.Parent = ClientObjects
    return NewEgg.Model
end

function Egg.Check(Type)
    return game.Workspace.ClientObjects:FindFirstChild(Type)==nil
end

return Egg