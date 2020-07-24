local Initialize = {}


local ReplicatedStorage = game.ReplicatedStorage
local Player = game.Players.LocalPlayer
local Playing = Player:WaitForChild("Data"):WaitForChild("Playing")
function Initialize.Egg(Type)
    if Playing.Value == false and game.Workspace.Pets:FindFirstChildOfClass("Model") == nil and game.Workspace:FindFirstChild(Type) == nil then
        Egg = ReplicatedStorage:FindFirstChild(Type):Clone()
        Egg.Parent = game.Workspace
        Egg.Position = Vector3.new(164.975, 37.54, -428.711)
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