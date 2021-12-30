--This script inserts a new egg by type into ClientObjects
Egg = {}
Egg._index = Egg
local Player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
Database = require(ReplicatedStorage.Modules.Data)

function Egg.GetPosition(JSON)
    return game.Workspace:WaitForChild("DebugObjects"):WaitForChild(JSON[15].."_EGGPOS").Position
end

function Egg.new(Type,EggPosition)
    local Data = Player:WaitForChild("Data")
    local Eggs = game.ReplicatedStorage.Eggs
    local ClientObjects = game.Workspace.ClientObjects
    local NewEgg = {}
    setmetatable(NewEgg, Egg)
    NewEgg.Model = Eggs:WaitForChild(Database.Pull(Data:WaitForChild("PlayerData").Value)[11]):Clone()
    NewEgg.Model.Head.Position = EggPosition
    NewEgg.Model.Parent = ClientObjects
    return NewEgg.Model
end

function Egg.Check()
    local Data = Player:WaitForChild("Data")
    return #game.Workspace.ClientObjects:GetChildren()[1].Name ~= Database.Pull(Data:WaitForChild("PlayerData").Value)[11]
end

return Egg