local Player = game.Players.LocalPlayer
local R = game:GetService("ReplicatedStorage")

--Modules
local Data = require(R.Modules.Data)
local ChangeGui = require(R.Modules.ChangeGui)

local Pets = R.Pets


InventoryHandler = {}
--[[ Creates a new thread to handle any clicks to the pet inventory. Searches for changes to the "active" value within the script.
Don't mind the nesting ._. ]]
function InventoryHandler.CheckChanges()
    spawn(function()
        local Inventory = Player.PlayerGui:WaitForChild("Inventory")

        while Inventory.Enabled == true do
            local PlayerDataString = Player:FindFirstChild("Data").PlayerData
            local ExtractedData = Data.Pull(PlayerDataString.Value)
            local PetsInInventory = Inventory.InventoryFrame.ScrollingFrame:GetChildren()
            wait(0.1)
            for _,v in ipairs(PetsInInventory) do
                if v:IsA("TextButton") then
                    if v:FindFirstChild("Active").Value == true then
                        --print("Pet to change: "..tostring(v.ViewportFrame:FindFirstChildOfClass("Model").Name))
                        v:FindFirstChild("Active").Value=false
                        for i,c in pairs(ExtractedData[4]) do
                            if tostring(c) == tostring(v.ViewportFrame:FindFirstChildOfClass("Model").Name) then
                                local trash = Inventory.InventoryFrame.PetHolder.ViewportFrame:GetChildren()
                                for _,b in ipairs(trash) do if b:IsA("Model") then b:Destroy() end end
                                local pet = v.ViewportFrame:FindFirstChild(c):Clone()
                                pet.Parent = Inventory.InventoryFrame.PetHolder.ViewportFrame
                                Inventory.InventoryFrame.PetHolder.PetName.Text = c
                                if ExtractedData[5][i] == nil then
                                    ExtractedData[5][i] = {1,0,20}
                                    PlayerDataString.Value = Data.Convert(ExtractedData)
                                end
                                print("Level: "..tostring(ExtractedData[5][i][1]).." XP: "..tostring(ExtractedData[5][i][2]).." GoalXP: "..tostring(ExtractedData[5][i][3]))
                                ChangeGui.TweenLevelBar(Inventory.InventoryFrame.PetHolder.XPBar,ExtractedData[5][i][2],ExtractedData[5][i][3],1)
                                Inventory.InventoryFrame.PetHolder.PetLevel.Text = "Level "..tostring(ExtractedData[5][i][1])
                                Inventory.InventoryFrame.PetHolder.XPBarBackground.TextLabel.Text = tostring(ExtractedData[5][i][2]).."/"..tostring(ExtractedData[5][i][3])
                                if ExtractedData[6] == c then
                                    Inventory.InventoryFrame.PetHolder.Equip.Text = "Equipped"
                                    Inventory.InventoryFrame.PetHolder.Equip.Roundify.ImageColor3 = Color3.fromRGB(41, 41, 41)
                                else
                                    Inventory.InventoryFrame.PetHolder.Equip.Text = "Equip"
                                    Inventory.InventoryFrame.PetHolder.Equip.Roundify.ImageColor3 = Color3.fromRGB(0, 255, 127)           
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end

return InventoryHandler