local Initialize = {}
SpawnEggLocation = game.Workspace:WaitForChild("DebugObjects"):WaitForChild("EggPositionLocation").Position

local ReplicatedStorage = game.ReplicatedStorage
local Player = game.Players.LocalPlayer
local Playing = Player:WaitForChild("Data"):WaitForChild("Playing")
function Initialize.Egg(Type)
    if Playing.Value == false and game.Workspace.Pets:FindFirstChildOfClass("Model") == nil and game.Workspace:FindFirstChild(Type) == nil then
        Egg = ReplicatedStorage:FindFirstChild(Type):Clone()
        Egg.Parent = game.Workspace
        Egg.Position = SpawnEggLocation
        Playing.Value = true
        return "done"
    end
end

function Initialize.RemoveEgg(Type)
    local Egg = game.Workspace:FindFirstChild(Type)
    if Egg ~= nil then
        Egg:Destroy()
    end
end
return Initialize