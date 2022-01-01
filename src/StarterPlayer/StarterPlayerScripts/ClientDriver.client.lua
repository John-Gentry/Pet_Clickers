local Player = game.Players.LocalPlayer
local Character = Player.CharacterAdded:Wait() or Player.Character

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
local RewardPrompt = R.RemoteEvents:WaitForChild("RewardPrompt")
local PlayerPayload = R.RemoteEvents:WaitForChild("Data")
local ProductPurchase = R.RemoteEvents:WaitForChild("ProductPurchase")

--[[ Remote Functions ]]
local GetAmount = R.RemoteFunctions:WaitForChild("GetAmount")
local CheckPurchase = R.RemoteFunctions:WaitForChild("CheckPurchase")

--[[ Gui variables ]]
local PlayerGui = Player.PlayerGui
local MainGui = PlayerGui:WaitForChild("MainGui")
local Shop = PlayerGui:WaitForChild("Shop")
local PetShop = PlayerGui:WaitForChild("PetShop")
local Equip = PlayerGui:WaitForChild("Inventory").InventoryFrame.PetHolder.Equip

local XPText = MainGui.Level.XPBarBackground.TextLabel
--local LevelText = MainGui.Level.BoosterButton
local Bar = MainGui.Level.XPBarBackground.XPBar

--[[ Player data ]]
local Data = Player:FindFirstChild("Data")
local Playing = Data:WaitForChild("Playing")
local PlayerView = Data:WaitForChild("PlayerView")

--[[ Various Objects ]]
local ClientObjects = game.Workspace.ClientObjects
local EggPosition = EggModule.GetPosition(Database.Pull(Data:FindFirstChild("PlayerData").Value))

local Pet = nil
local Mouse = Player:GetMouse()

--[[ Initial startup ]]
--PlayerHandler.MakePlayerInvisible(Player)
Playing.Value = false
game:GetService("StarterGui"):SetCore("ResetButtonCallback", false) -- turns off reset button

function SpawnToCurrentMap()
    local PlayerData = Data:WaitForChild("PlayerData")
    local JSON = Database.Pull(PlayerData.Value)
    Character:WaitForChild("HumanoidRootPart").CFrame = game.Workspace:FindFirstChild(JSON[15]).CFrame
    local CurrentPet = Player:WaitForChild("Data"):WaitForChild("CurrentPet")
    TriggerPlayerPet:FireServer(CurrentPet.Value)
end
SpawnToCurrentMap()
---292.799, -362.888, -334.824

local ClickCoolDown = false
spawn(function()ChangeGui.UpdateCoins()end)
spawn(function()ChangeGui.UpdateGems()end)


spawn(function() -- Detect around daily reward
    while wait(0.1) do

        local HRP = Character:WaitForChild("HumanoidRootPart")
        local a = (Vector3.new(-221.464, -359.67, -291.814) - HRP.Position).Magnitude
        local b = (Vector3.new(-264.543, -363.198, -239.735) - HRP.Position).Magnitude
        print(b)
        if a < 10 then
            print("true")
        elseif b < 10 then
            --print("true")
            PlayerGui:FindFirstChild("PetShop").Enabled = true
            --print(PlayerGui:FindFirstChild("PetShop").Enabled)
        else
            PlayerGui:FindFirstChild("PetShop").Enabled = false
        end
    end
end)



--ChangeGui.PromptRandomViewport(R:WaitForChild("GemDisplay"),R:WaitForChild("DropFrame"),10,1,1)

--[[ spawn(function()
    local Coin = R:WaitForChild("CoinDisplay"):Clone()
    InventoryHandler.ViewPet(Coin,MainGui.PromptCoins.CoinFrame)
end) ]]

RewardPrompt.OnClientEvent:Connect(function(Type,Amount)
    ChangeGui.PromptRandomViewport(R:WaitForChild(Type),R:WaitForChild("DropFrame"),Amount,1,0.3)
end)

function SetCoolDown()
    ClickCoolDown = true
    wait(0.2) --[[ Sets cooldown between clicks, not noticible unless using an auto clicker ]]
    ClickCoolDown = false
end

function ClickActions()
    --print("firing")
    Data = Player:FindFirstChild("Data")
    local PlayerData = Data:FindFirstChild("PlayerData")
    spawn(function()SetCoolDown()end)

    local CallBackList = GetAmount:InvokeServer(Level,PlayerData.Value)--[[ This here is causing problems ]]
    Amount=CallBackList[1]
    PlayerData.Value = CallBackList[2]
    --print(CallBackList[2])
    local PlayerTable = Database.Pull(PlayerData.Value)
    local XP,GoalXP,Level,Clicks = tonumber(PlayerTable[1]),tonumber(PlayerTable[2]),tonumber(PlayerTable[3]),tonumber(PlayerTable[7])
    PlayerTable[1] = XP + Amount
    PlayerTable[7] = PlayerTable[7] + PlayerTable[8]
    PlayerData.Value = Database.Convert(PlayerTable)
    ChangeGui.AddClick(tonumber(PlayerTable[7]))
    if CallBackList[3] == true then
        --print("Pet level up")
        spawn(function() ChangeGui.PetLevelUp() end)
    end
    if XP <= GoalXP then
        XPText.Text = tostring(XP).."/"..tostring(GoalXP)
    else
        XPText.Text = tostring(GoalXP).."/"..tostring(GoalXP)
    end
    --LevelText.Text = "Level: "..tostring(Level)
    PlayerPayload:FireServer(PlayerData.Value)
    spawn(function()ChangeGui.AddXP(Amount)end) --change
    ChangeGui.TweenLevelBar(Bar,XP,GoalXP,1)
    ChangeGui.DetermineLevel(Bar,XP,GoalXP,Level)
    EggProperties.HitEgg()
end

function OnPlayerClick()
    local Playing = Data:FindFirstChild("Playing")
    if Playing.Value == true and PlayerView.Value == false and ClickCoolDown == false then
        print("Playing value: "..tostring(Playing.Value))
        ClickActions()
    else
        --print("not firing")
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
    EggPosition = EggModule.GetPosition(Database.Pull(Data:FindFirstChild("PlayerData").Value))
    local Playing = Data:WaitForChild("Playing")
    local CurrentPet = Player:WaitForChild("Data"):WaitForChild("CurrentPet")
    if PlayerView.Value == false then
        CurrentPet.Value = Pet
        local Playing = Player:FindFirstChild("Data"):WaitForChild("Playing")
        Pet = PetModule.new(CurrentPet.Value,EggPosition)
        ChangeGui.PromptPet(Pet.Name)
        StartInput = UserInputService.InputBegan:Connect(function(input)
            if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and Playing.Value == false and Pet ~= nil and PlayerView.Value == false and EggModule.Check() then
                --print("this function fires")
                print("give pet function firing")
                PetModule:DestroyPets()
                ChangeGui.CloseContinuePrompt()
                EggModule.new(Database.Pull(Data:FindFirstChild("PlayerData").Value)[11],EggPosition)
                Playing.Value = true
                StartInput:Disconnect()
            end
        end)
    end
end)

--[[ Activates when player clicks the "walk pet" button. Also when they click "hatch egg" *]]

MainGui.WalkPetButton.MouseButton1Click:Connect(function()
    EggPosition = EggModule.GetPosition(Database.Pull(Data:FindFirstChild("PlayerData").Value))
    local CurrentPet = Player:WaitForChild("Data"):WaitForChild("CurrentPet")
    if (Playing.Value == true or PlayerView.Value == false) then
        for _,v in ipairs(ClientObjects:GetChildren()) do v:Destroy() end
        PlayerHandler.MakePlayerVisible(Player)
        Playing.Value = false
        BackToPlayerCamera:FireServer()
        --MainGui.WalkPetButton.Text = "Hatch an egg!"
        TriggerPlayerPet:FireServer(CurrentPet.Value)
    elseif Playing.Value == false then
        R.RemoteEvents.RemovePetInGame:FireServer(CurrentPet.value.."_"..Player.Name)
        Playing.Value = true
        PlayerHandler.MakePlayerInvisible(Player)
        PlayerView.Value = false
        EggModule.new(Database.Pull(Data:FindFirstChild("PlayerData").Value)[11],EggPosition)
        --MainGui.WalkPetButton.Text = "Walk your pet!"
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


                spawn(function() InventoryHandler.ViewPet(Pet,PetButton.ViewportFrame) end)

            end
        end

        local CurrentPet = PlayerTable[6]
        print(CurrentPet)
        local Pet = R.Pets:FindFirstChild(CurrentPet):Clone()
        local PetHolder = PlayerGui.Inventory.InventoryFrame.PetHolder
        for _,v in ipairs(PetHolder.ViewportFrame:GetChildren()) do if v:IsA("Model") then v:Destroy() end end
        PetHolder.PetName.Text = Pet.Name
        PetHolder.Equip.Roundify.ImageColor3 = Color3.fromRGB(41, 41, 41)
        PetHolder.Equip.Text = "Equipped"
        spawn(function() InventoryHandler.ViewPet(Pet,PetHolder.ViewportFrame) end)
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


--[[ Below is for the shop handling ]]
Shop.MainFrame.ScrollingFrame.Product1.BuyButton.MouseButton1Click:Connect(function() --[[ 100 coins, 50 robux, 1231214711]]
    ProductPurchase:FireServer(1231214711)
end)

Shop.MainFrame.ScrollingFrame.Product2.BuyButton.MouseButton1Click:Connect(function() --[[ 300 coins, 100 robux, 1231214864]]
    ProductPurchase:FireServer(1231214864)
end)

Shop.MainFrame.ScrollingFrame.Product3.BuyButton.MouseButton1Click:Connect(function() --[[ 1000 coins, 200 robux, 1231214865]]
    ProductPurchase:FireServer(1231214865)
end)

Shop.MainFrame.ScrollingFrame.Product4.BuyButton.MouseButton1Click:Connect(function() --[[ 100 gems, 100 robux, 1231215065]]
    ProductPurchase:FireServer(1231215065)
end)

Shop.MainFrame.ScrollingFrame.Product5.BuyButton.MouseButton1Click:Connect(function() --[[ 300 gems, 250 robux, 1231215064]]
    ProductPurchase:FireServer(1231215064)
end)

Shop.MainFrame.ScrollingFrame.Product6.BuyButton.MouseButton1Click:Connect(function() --[[ 500 gems, 450 robux, 1231215063]]
    ProductPurchase:FireServer(1231215063)
end)

--[[ Below is for pet shop handling ]]

local petframe = PetShop.MainFrame.ScrollingFrame

function PetShopPurchase(type,amount,gui)
    local PlayerData = Data:FindFirstChild("PlayerData")
    if CheckPurchase:InvokeServer(12,amount, true,4,type) then
        print("Purchased!")
        PlayerPayload:FireServer(PlayerData.Value)
        gui.Text = "Purchased!"
    end
end

petframe.Product1.BuyButton.MouseButton1Click:Connect(function() PetShopPurchase("Werewolf",50,petframe.Product1.BuyButton)end)
petframe.Product2.BuyButton.MouseButton1Click:Connect(function() PetShopPurchase("Manticore",100,petframe.Product2.BuyButton)end)
petframe.Product3.BuyButton.MouseButton1Click:Connect(function() PetShopPurchase("Angel",500,petframe.Product3.BuyButton)end)

--petframe.Product1.BuyButton.TouchTap:Connect(function() print("working") PetShopPurchase("Werewolf",50,petframe.Product1.BuyButton)end)

--[[ Below is for Portal and Egg shop handling ]]

spawn(function() -- Detect around Portals and Egg Shops
    while wait(0.1) do
        
        for i, v in pairs(game.Workspace:WaitForChild("PurchaseObjects"):GetChildren()) do
            local HRP = Character:WaitForChild("HumanoidRootPart")
            local a = (v.Position - HRP.Position).Magnitude
            local purchased = false
            if a < 10 then
                local PlayerData = Data:FindFirstChild("PlayerData")
                local JSON = Database.Pull(PlayerData.Value)
                for i,x in pairs(JSON[13]) do
                    if x == v:FindFirstChild("Export").Value then
                        v:FindFirstChild("BillboardGui").CoinText.Text = "Owned!"
                        purchased = true
                    end
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.E) then
                    print("pressed e")
                    if purchased then
                        JSON[15] = v:FindFirstChild("Export").Value
                        PlayerData.Value = Database.Convert(JSON)
                        Character:WaitForChild("HumanoidRootPart").CFrame = game.Workspace:FindFirstChild(v:FindFirstChild("Export").Value).CFrame
                        PlayerPayload:FireServer(PlayerData.Value)
                    else
                        if CheckPurchase:InvokeServer(9,300, true,13,v:FindFirstChild("Export").Value) then
                            print("purchased!")
                            PlayerPayload:FireServer(PlayerData.Value)
                            Character:WaitForChild("HumanoidRootPart").CFrame = game.Workspace:FindFirstChild(v:FindFirstChild("Export").Value).CFrame
                        end
                    end
                end
            end
        end
    end
end)