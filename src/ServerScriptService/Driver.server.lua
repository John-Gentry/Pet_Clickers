local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
ReplicatedStorage = game.ReplicatedStorage
CameraEvent = ReplicatedStorage:WaitForChild("CameraMode")
BackToPlayerCamera = ReplicatedStorage:WaitForChild("BackToPlayerCamera")
TriggerPlayerPet = ReplicatedStorage:WaitForChild("TriggerPlayerPet")

Players.PlayerAdded:Connect(function(Player)
    CameraEvent:FireClient(Player,true)
end)

BackToPlayerCamera.OnServerEvent:Connect(function(Player)
    BackToPlayerCamera:FireClient(Player)
end)

--[[ RunService.Heartbeat:Connect(function()
    if PlayerView.Value == true then
        if 
    end
end *]]

TriggerPlayerPet.OnServerEvent:Connect(function(Player,Pet)
    Pet = ReplicatedStorage.Pets:FindFirstChild("Dog"):Clone()
    Pet.Name = Pet.Name.."_"..Player.Name
    Pet.Parent = game.Workspace.PlayerPets
    spawn(function()
        local offset = Vector3.new(0,0.05,0.05)
        while Pet ~= nil do
            wait()
            PlayerPos = Player.Character:WaitForChild("HumanoidRootPart")
            PlayerHead = Player.Character:WaitForChild("Head")
            Pet:FindFirstChild("HitBox").Anchored = true
            --Pet:FindFirstChild("HitBox").CFrame = CFrame.new(PlayerPos.Position*offset,PlayerPos.Position)
            Pet:FindFirstChild("HitBox").CFrame = PlayerPos.CFrame*CFrame.new(5,-1.5,4) 
            Pet:FindFirstChild("HitBox").RotVelocity = Vector3.new(0,0,0)
            Pet:FindFirstChild("HitBox").Velocity = Vector3.new(0,0,0)
        end
    end)
end)