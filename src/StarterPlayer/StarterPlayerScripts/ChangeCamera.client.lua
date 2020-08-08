ReplicatedStorage = game.ReplicatedStorage
CameraEvent = ReplicatedStorage.RemoteEvents:WaitForChild("CameraMode")
BackToPlayerCamera = ReplicatedStorage.RemoteEvents:WaitForChild("BackToPlayerCamera")
SpawnEggLocation = game.Workspace:WaitForChild("DebugObjects"):WaitForChild("EggPositionLocation").Position
local Player = game.Players.LocalPlayer
local PlayerView = Player:WaitForChild("Data"):WaitForChild("PlayerView")
local Point = CFrame.new(SpawnEggLocation.X,SpawnEggLocation.Y,SpawnEggLocation.Z)
local Offset = CFrame.new(0,0,10)
local active = true
local ClientObjects = game.Workspace.ClientObjects

CameraEvent.OnClientEvent:Connect(function(bool)
    local Camera = Workspace.CurrentCamera
    Camera.CameraType = "Scriptable"
    Camera.Focus = Point
    Camera.CFrame = Point
    Camera.CameraSubject = game.Workspace:WaitForChild("DebugObjects"):WaitForChild("EggPositionLocation")
    active = bool
    while active do
        for i = 1,3600 do
            if not active then break end
            Camera.CFrame = Point * CFrame.Angles(0,math.rad(i/10),0) * Offset
            wait()
        end
    end
end)

BackToPlayerCamera.OnClientEvent:Connect(function()
    if PlayerView.Value == false then
        active = false
        PlayerView.Value = true
        if game.Workspace.Pets:FindFirstChildOfClass("Model") ~= nil then
            game.Workspace.Pets:FindFirstChildOfClass("Model"):Destroy()
        end
        local Camera = game.Workspace.CurrentCamera
        Camera.CameraType = "Track"
        Camera.CameraSubject = Player.Character:WaitForChild("HumanoidRootPart")
        Camera.CFrame = Player.Character:WaitForChild("HumanoidRootPart").CFrame
    end
end)
