--[[ Initial game objects added *]]
local UserInputService = game:GetService("UserInputService")
local Player = game.Players.LocalPlayer
Character = Player.CharacterAdded:Wait() or Player.Character
local Data = Player:FindFirstChild("Data")
local Playing = Data:WaitForChild("Playing")

Playing.Value = true
InitialStart = script.Parent:WaitForChild("InitialStart")


local PlayerHandler = require(script.Parent.PlayerHandler)
require(InitialStart).Egg("StarterEgg") --Starter Egg for the beginning
SpawnEggLocation = game.Workspace:WaitForChild("DebugObjects"):WaitForChild("EggPositionLocation").Position
PlayerHandler.MakePlayerInvisible(Player)

EggProperties = script.Parent:WaitForChild("EggProperties")
ChangeGui = script.Parent:WaitForChild("ChangeGui")
GivePet = game.ReplicatedStorage.GivePet
ReplicatedStorage = game:GetService("ReplicatedStorage")



local MainGui = Player.PlayerGui:WaitForChild("MainGui")
local XPText = Player.PlayerGui:WaitForChild("MainGui").Level.XPBarBackground.TextLabel
local LevelText = Player.PlayerGui:WaitForChild("MainGui").Level.BoosterButton
local Bar = Player.PlayerGui:WaitForChild("MainGui").Level.XPBar


local PlayerView = Data:WaitForChild("PlayerView")

local GetAmount = ReplicatedStorage:WaitForChild("GetAmount")

UserInputService.InputBegan:Connect(function(input)
    local XP = Data:WaitForChild("XP")
    local GoalXP = Data:WaitForChild("GoalXP")
    local Level = Data:WaitForChild("Level")
    local Playing = Data:WaitForChild("Playing")
    

    if input.UserInputType == Enum.UserInputType.MouseButton1 and Playing.Value == true and PlayerView.Value == false then
        print("Clicking")
        Amount=GetAmount:InvokeServer(Level.Value)
        XP.Value = XP.Value + Amount
        XPText.Text = tostring(XP.Value).."/"..tostring(GoalXP.Value)
        LevelText.Text = "Level: "..tostring(Level.Value)
        spawn(function()require(ChangeGui).AddXP(Amount)end) --change
        require(ChangeGui).DetermineLevel(XP,GoalXP,Level)
        require(ChangeGui).TweenLevelBar(Bar,XP,GoalXP)
        require(EggProperties).HitEgg()

    end
end)

--[[ Below needs to be changed so that it's mainly handled by the PetHandler module *]]
GivePet.OnClientEvent:Connect(function(Pet)
    local CurrentPet = Player:WaitForChild("Data"):WaitForChild("CurrentPet")
    if PlayerView.Value == false then
        CurrentPet.Value = Pet
        local Playing = Player:FindFirstChild("Data"):WaitForChild("Playing")
        local Camera = game.Workspace.CurrentCamera
        local Location = SpawnEggLocation --[[ Needs to be changed to a global position value *]]
        local Pet = game.ReplicatedStorage:WaitForChild("Pets"):FindFirstChild(Pet):Clone()
        a = Pet:FindFirstChild("Rotation").Value
        Pet.HitBox.Position = Location
        Pet.HitBox.CFrame = CFrame.new(Pet.HitBox.Position,Camera.CFrame.p)*CFrame.Angles(math.rad(a.x), math.rad(a.y), math.rad(a.z))
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
    end
end)

--[[ Activates when player clicks the "walk pet" button. Also when they click "hatch egg" *]]

MainGui.WalkPetButton.MouseButton1Click:Connect(function()
    local CurrentPet = Player:WaitForChild("Data"):WaitForChild("CurrentPet")
    if MainGui.WalkPetButton.Text == "Walk your pet!" and (Playing.Value == true or PlayerView.Value == false) then
        PlayerHandler.MakePlayerVisible(Player)
        local BackToPlayerCamera = game.ReplicatedStorage:WaitForChild("BackToPlayerCamera")
        Playing.Value = false
        BackToPlayerCamera:FireServer()
        TriggerPlayerPet = ReplicatedStorage:WaitForChild("TriggerPlayerPet")
        MainGui.WalkPetButton.Text = "Hatch an egg!"
        TriggerPlayerPet:FireServer(CurrentPet.Value)
        require(InitialStart).RemoveEgg("StarterEgg")
    elseif MainGui.WalkPetButton.Text == "Hatch an egg!" and Playing.Value == false then
        ReplicatedStorage.RemovePetInGame:FireServer(CurrentPet.value.."_"..Player.Name)
        Playing.Value = true
        PlayerHandler.MakePlayerInvisible(Player)
        PlayerView.Value = false
        require(InitialStart).Egg("StarterEgg")
        MainGui.WalkPetButton.Text = "Walk your pet!"

    end
end)
