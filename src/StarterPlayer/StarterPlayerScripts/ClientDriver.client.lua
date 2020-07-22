InitialStart = script.Parent:WaitForChild("InitialStart")
EggProperties = script.Parent:WaitForChild("EggProperties")
ChangeGui = script.Parent:WaitForChild("ChangeGui")
local RunService = game:GetService("RunService")
GivePet = game.ReplicatedStorage.GivePet
ReplicatedStorage = game:GetService("ReplicatedStorage")

require(InitialStart).Egg("StarterEgg") --Starter Egg for the beginning

local RunService = game:GetService("RunService")
local Player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local MainGui = Player.PlayerGui:WaitForChild("MainGui")
local XPText = Player.PlayerGui:WaitForChild("MainGui").XPText
local LevelText = Player.PlayerGui:WaitForChild("MainGui").LevelText
local Bar = Player.PlayerGui:WaitForChild("MainGui").LevelBar
local PlayerView = Player:WaitForChild("Data"):WaitForChild("PlayerView")

UserInputService.InputBegan:Connect(function(input)
    local XP = Player:FindFirstChild("Data"):WaitForChild("XP")
    local GoalXP = Player:FindFirstChild("Data"):WaitForChild("GoalXP")
    local Level = Player:FindFirstChild("Data"):WaitForChild("Level")
    local Playing = Player:FindFirstChild("Data"):WaitForChild("Playing")
    
    
    if input.UserInputType == Enum.UserInputType.MouseButton1 and Playing.Value == true and PlayerView.Value == false then
        XP.Value = XP.Value + 1
        XPText.Text = tostring(XP.Value).."/"..tostring(GoalXP.Value)
        LevelText.Text = "Level: "..tostring(Level.Value)
        spawn(function()require(ChangeGui).AddGold(1)end)
        require(ChangeGui).DetermineLevel(XP,GoalXP,Level)
        require(ChangeGui).TweenLevelBar(Bar,XP,GoalXP)
        require(EggProperties).HitEgg()
    end
end)
GivePet.OnClientEvent:Connect(function(Pet)
    if PlayerView.Value == false then
        local Playing = Player:FindFirstChild("Data"):WaitForChild("Playing")
        local Camera = game.Workspace.CurrentCamera
        local Location = game.ReplicatedStorage:FindFirstChild("StarterEgg").Position
        local Pet = game.ReplicatedStorage:WaitForChild("Pets"):FindFirstChild(Pet):Clone()
        Pet.HitBox.Position = Location
        Pet.HitBox.CFrame = CFrame.new(Pet.HitBox.Position,Camera.CFrame.p)
        Pet.Parent = game.Workspace.Pets
        require(ChangeGui).PromptPet(Pet.Name)
        require(ChangeGui).OpenWalkPetGui()
        wait(2)
        require(ChangeGui).ClosePromptPet()
        UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and Playing.Value == false and Pet ~= nil and PlayerView.Value == false then
                Pet:Destroy()
                require(ChangeGui).CloseContinuePrompt()
                require(InitialStart).Egg("StarterEgg")
            end
        end)
        print(Pet)
    end
end)

MainGui.WalkPetButton.MouseButton1Click:Connect(function()
    print("Clicking")
    local CurrentPet = Player:WaitForChild("Data"):WaitForChild("CurrentEgg")
    local BackToPlayerCamera = game.ReplicatedStorage:WaitForChild("BackToPlayerCamera")
    TriggerPlayerPet = ReplicatedStorage:WaitForChild("TriggerPlayerPet")
    BackToPlayerCamera:FireServer()
    TriggerPlayerPet:FireServer(CurrentPet.Value)
end)
