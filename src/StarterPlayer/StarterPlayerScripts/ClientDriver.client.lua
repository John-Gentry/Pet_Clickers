local Player = game.Players.LocalPlayer
Character = Player.CharacterAdded:Wait() or Player.Character

--[[ Services ]]
local UserInputService = game:GetService("UserInputService")
local R = game:GetService("ReplicatedStorage")

--[[ Required modules ]]
local Modules = R.Modules

local EggModule = require(Modules:WaitForChild("Egg"))
local PetModule = require(Modules:WaitForChild("Pet"))
local PlayerHandler = require(Modules:WaitForChild("PlayerHandler"))
local EggProperties = require(Modules:WaitForChild("EggProperties"))
local ChangeGui = require(Modules:WaitForChild("ChangeGui"))
local Database = require(R.Modules.Data)
local InventoryHandler = require(Modules:WaitForChild("InventoryHandler"))

--[[ Remote Events ]]
local GivePet = R.RemoteEvents:WaitForChild("GivePet")
local BackToPlayerCamera = R.RemoteEvents:WaitForChild("BackToPlayerCamera")
local TriggerPlayerPet = R.RemoteEvents:WaitForChild("TriggerPlayerPet")
local EraseData = R.RemoteEvents:WaitForChild("EraseData")

--[[ Remote Functions ]]
local GetAmount = R.RemoteFunctions:WaitForChild("GetAmount")

--[[ Gui variables ]]
local PlayerGui = Player.PlayerGui
local MainGui = PlayerGui:WaitForChild("MainGui")
local Equip = PlayerGui:WaitForChild("Inventory").InventoryFrame.PetHolder.Equip

local XPText = MainGui.Level.XPBarBackground.TextLabel
local LevelText = MainGui.Level.BoosterButton
local Bar = MainGui.Level.XPBar

--[[ Player data ]]
local Data = Player:FindFirstChild("Data")
local Playing = Data:WaitForChild("Playing")
local PlayerView = Data:WaitForChild("PlayerView")

--[[ Various Objects ]]
local ClientObjects = game.Workspace.ClientObjects
local EggPosition = EggModule.GetPosition()
local Egg = EggModule.new("StarterEgg",EggPosition)
local Pet = nil
local Mouse = Player:GetMouse()

--[[ Initial startup ]]
PlayerHandler.MakePlayerInvisible(Player)
Playing.Value = true

function OnPlayerClick()
    local PlayerData = Data:WaitForChild("PlayerData")
    local Playing = Data:WaitForChild("Playing")

    if Playing.Value == true and PlayerView.Value == false then
        local CallBackList = GetAmount:InvokeServer(Level,PlayerData.Value)
        Amount=CallBackList[1]
        PlayerData.Value = CallBackList[2]
        local PlayerTable = Database.Pull(PlayerData.Value)
        local XP = tonumber(PlayerTable[1])
        local GoalXP = tonumber(PlayerTable[2])
        local Level = tonumber(PlayerTable[3])
        PlayerTable[1] = XP + Amount
        PlayerData.Value = Database.Convert(PlayerTable)
        if CallBackList[3] == true then
            print("Called")
            spawn(function() ChangeGui.PetLevelUp() end)
        end
        if XP <= GoalXP then
            XPText.Text = tostring(XP).."/"..tostring(GoalXP)
        else
            XPText.Text = tostring(GoalXP).."/"..tostring(GoalXP)
        end
        LevelText.Text = "Level: "..tostring(Level)
        spawn(function()ChangeGui.AddXP(Amount)end) --change
        ChangeGui.DetermineLevel(XP,GoalXP,Level)
        ChangeGui.TweenLevelBar(Bar,XP,GoalXP,0.25)
        EggProperties.HitEgg()
    end
end

Mouse.Button1Down:Connect(OnPlayerClick)

if UserInputService.TouchEnabled then
    UserInputService.TouchTap:Connect(OnPlayerClick)
end

--[[ Equip pet *]]

Equip.MouseButton1Click:Connect(function()
    local CurrentPet = Player:WaitForChild("Data"):WaitForChild("CurrentPet")
    if Equip.Text == "Equip" then
        local PlayerTable = Database.Pull(Player:FindFirstChild("Data"):WaitForChild("PlayerData").Value)
        PlayerTable[6] = Equip.Parent.ViewportFrame:FindFirstChildOfClass("Model").Name
        CurrentPet.Value = Equip.Parent.ViewportFrame:FindFirstChildOfClass("Model").Name
        Player:FindFirstChild("Data"):WaitForChild("PlayerData").Value=Database.Convert(PlayerTable)
        Equip.Roundify.ImageColor3 = Color3.fromRGB(41, 41, 41)
        TriggerPlayerPet:FireServer(Equip.Parent.ViewportFrame:FindFirstChildOfClass("Model").Name)
        Equip.Text = "Equipped"
    end
end)

--[[ Below needs to be changed so that it's mainly handled by the PetHandler module *]]
GivePet.OnClientEvent:Connect(function(Pet)
    local Playing = Data:WaitForChild("Playing")
    local CurrentPet = Player:WaitForChild("Data"):WaitForChild("CurrentPet")
    if PlayerView.Value == false then
        CurrentPet.Value = Pet
        local Playing = Player:FindFirstChild("Data"):WaitForChild("Playing")
        Pet = PetModule.new(CurrentPet.Value,EggPosition)
        ChangeGui.PromptPet(Pet.Name)
        UserInputService.InputBegan:Connect(function(input)
            if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and Playing.Value == false and Pet ~= nil and PlayerView.Value == false and EggModule.Check("StarterEgg") then
                PetModule:DestroyPets()
                ChangeGui.CloseContinuePrompt()
                EggModule.new("StarterEgg",EggPosition)
                Playing.Value = true
            end
        end)
    end
end)

--[[ Activates when player clicks the "walk pet" button. Also when they click "hatch egg" *]]

MainGui.WalkPetButton.MouseButton1Click:Connect(function()
    local CurrentPet = Player:WaitForChild("Data"):WaitForChild("CurrentPet")
    if MainGui.WalkPetButton.Text == "Walk your pet!" and (Playing.Value == true or PlayerView.Value == false) then
        for _,v in ipairs(ClientObjects:GetChildren()) do v:Destroy() end
        PlayerHandler.MakePlayerVisible(Player)
        Playing.Value = false
        BackToPlayerCamera:FireServer()
        MainGui.WalkPetButton.Text = "Hatch an egg!"
        TriggerPlayerPet:FireServer(CurrentPet.Value)
    elseif MainGui.WalkPetButton.Text == "Hatch an egg!" and Playing.Value == false then
        R.RemoteEvents.RemovePetInGame:FireServer(CurrentPet.value.."_"..Player.Name)
        Playing.Value = true
        PlayerHandler.MakePlayerInvisible(Player)
        PlayerView.Value = false
        EggModule.new("StarterEgg",EggPosition)
        MainGui.WalkPetButton.Text = "Walk your pet!"
    end
end)

--[[ Activates the inventory screen ]]

MainGui.InventoryButton.MouseButton1Click:Connect(function()
    if PlayerGui.Shop.Enabled == false and PlayerGui.Inventory.Enabled == false then
        local PlayerTable = Database.Pull(Player:FindFirstChild("Data"):WaitForChild("PlayerData").Value)
        PlayerGui.Inventory.Enabled = true
        InventoryHandler.CheckChanges()
        local PetList = PlayerGui.Inventory.InventoryFrame.ScrollingFrame -- PlayerGui.Inventory.InventoryFrame.ScrollingFrame.PetFrame.PetInventory
        for _,c in pairs(PetList:GetChildren()) do if not c:IsA("UIGridLayout") then c:Destroy() end end
        if PlayerTable[4][1] ~= nil then
            for i=1,#PlayerTable[4] do
                print(PlayerTable[4][i])
                local Pet = R.Pets:FindFirstChild(PlayerTable[4][i]):Clone()
                local PetButton = R.PetButton:Clone()
                PetButton.PetTextName.Text = PlayerTable[4][i]
                PetButton.Parent = PetList

                Pet.Parent = PetButton.ViewportFrame
                a = Pet:FindFirstChild("Rotation").Value
                

                local viewportCamera = Instance.new("Camera")
                PetButton.ViewportFrame.CurrentCamera = viewportCamera
                viewportCamera.Parent = PetButton.ViewportFrame
                
                viewportCamera.CFrame = CFrame.new(Vector3.new(0, 2, 4), Pet.HitBox.Position)
               --[[  Pet.HitBox.CFrame = CFrame.new(Pet.HitBox.Position,viewportCamera.CFrame.p)*CFrame.Angles(math.rad(a.x), math.rad(a.y), math.rad(a.z)) ]]
            end
        end

        local viewportCamera = Instance.new("Camera")
        local CurrentPet = PlayerTable[6]
        print(CurrentPet)
        local Pet = R.Pets:FindFirstChild(CurrentPet):Clone()
        local PetHolder = PlayerGui.Inventory.InventoryFrame.PetHolder
        for _,v in ipairs(PetHolder.ViewportFrame:GetChildren()) do if v:IsA("Model") then v:Destroy() end end
        Pet.Parent = PetHolder.ViewportFrame
        PetHolder.ViewportFrame.CurrentCamera = viewportCamera
        PetHolder.PetName.Text = Pet.Name
        PetHolder.Equip.Roundify.ImageColor3 = Color3.fromRGB(41, 41, 41)
        PetHolder.Equip.Text = "Equipped"
        viewportCamera.Parent = PetHolder.ViewportFrame
        viewportCamera.CFrame = CFrame.new(Vector3.new(0, 2, 4), Pet.HitBox.Position)
    elseif PlayerGui.Inventory.Enabled == true then
        PlayerGui.Inventory.Enabled = false
    end
end)

MainGui.ShopButton.MouseButton1Click:Connect(function()
    if PlayerGui.Shop.Enabled == false and PlayerGui.Inventory.Enabled == false then
        PlayerGui.Shop.Enabled = true
    elseif PlayerGui.Shop.Enabled == true then
        PlayerGui.Shop.Enabled = false
    end
end)

--[[ debug button ]]

MainGui.ResetStatsButton.MouseButton1Click:Connect(function()
    EraseData:FireServer()
end)