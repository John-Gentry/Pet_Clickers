--This script animates the egg after every click

EggProperties = {}
local R = game:GetService("ReplicatedStorage")
local ClientObjects = game.Workspace.ClientObjects
local TweenService = game:GetService("TweenService")
local Database = require(R.Modules.Data)

function randomdirection(Egg)
    local Player = game.Players.LocalPlayer
    local Data = Player:FindFirstChild("Data")
    local JSON = Database.Pull(Data:FindFirstChild("PlayerData").Value)
    local SpawnEggLocation = game.Workspace:WaitForChild("DebugObjects"):WaitForChild(JSON[15].."_EGGPOS").Position
    local MainX = SpawnEggLocation.X
    local MainZ = SpawnEggLocation.Z
    local Up = TweenInfo.new(0.2,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false, 0)
    local Down = TweenInfo.new(1,Enum.EasingStyle.Bounce,Enum.EasingDirection.Out,0,false, 0)
    local DownRotate = TweenInfo.new(2,Enum.EasingStyle.Elastic,Enum.EasingDirection.Out,0,false, 0)
    local number = math.random(1,100)
    if number > 70 then
        x=TweenService:Create(Egg,Up,{CFrame = CFrame.new(MainX, math.random(SpawnEggLocation.Y,SpawnEggLocation.Y+5), MainZ)*CFrame.Angles(math.random(5,20), math.random(5,20), math.random(5,20))})
        x:Play()
        x.Completed:Wait()
        x=TweenService:Create(Egg,Down,{CFrame = CFrame.new(MainX, SpawnEggLocation.Y, MainZ)})
        x:Play()
        x.Completed:Wait()
    else
        x=TweenService:Create(Egg,Up,{CFrame = Egg.CFrame*CFrame.Angles(math.random(5,20), math.random(SpawnEggLocation.Y,SpawnEggLocation.Y+10), math.random(5,20))})
        x:Play()
        x.Completed:Wait()
        x=TweenService:Create(Egg,DownRotate,{CFrame = CFrame.new(MainX, SpawnEggLocation.Y, MainZ)})
        x:Play()
        x.Completed:Wait()
    end
end

function EggProperties.HitEgg()
    local Player = game.Players.LocalPlayer
    local Data = Player:FindFirstChild("Data")
    local JSON = Database.Pull(Data:FindFirstChild("PlayerData").Value)
    local SpawnEggLocation = game.Workspace:WaitForChild("DebugObjects"):WaitForChild(JSON[15].."_EGGPOS").CFrame

    if game.Players.LocalPlayer.Data.Toggle.Value == false then
        game.Players.LocalPlayer.Data.Toggle.Value = true
        local Egg = ClientObjects:WaitForChild(game.Players.LocalPlayer.Data.CurrentEgg.Value)
        if Egg ~= nil then
            Egg.CFrame = SpawnEggLocation
            local Pos = Egg.CFrame
            randomdirection(Egg)
            game.Players.LocalPlayer.Data.Toggle.Value = false
        end
    end
end

--[[ function EggProperties.DetermineXPClicked()
    local PlayerDataString = game.Players.LocalPlayer:FindFirstChild("Data").PlayerData
    local ExtractedData = Data.Pull(PlayerDataString.Value)
    local XP = 
    return XP
end
 ]]
return EggProperties