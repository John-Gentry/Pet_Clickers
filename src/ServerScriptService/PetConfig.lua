local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
PetConfig = {}

function selectpet(list)
	local totalweight = 0;
	for _, v in ipairs(list) do
	    totalweight = totalweight + v;
	end
	local at = math.random() * totalweight;
	local where = 0;
	for i, v in ipairs(list) do
	    if at < v then
	        where = i;
	        break;
	    end
	    at = at - v;
	end
	return where
end

--[[ Rarity ratios for each of the pets *]]
function PetConfig.DeterminePet()
    local RarityList={
        [0.5] = "Dog",
        [0.35] = "Cat",
        [0.10] = "Chicken",
        [0.05] = "Penguin"
    }
    local Keys = {}
    local index = 1
    for key, _ in next, RarityList do
        Keys[index] = key
        index = index + 1
    end
    selection = selectpet(Keys)
    return RarityList[Keys[selection]]
end
--[[ Puts pet movement into a thread, so it runs independently of the script itself.
This will be changed into some sort of tween very soon.*]]
function PetConfig.ThreadPet(Pet,Player)
    local MovingConfig = TweenInfo.new(0.5,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false, 0) --[[ Config for moving the pet in a linear direction (Better than updating every render) *]]
    spawn(function()
        local offset = Vector3.new(0,0.05,0.05)
        while Pet ~= nil and Player.Character ~= nil do
            wait(0.5)
            GameRotation = Pet:WaitForChild("GameRotation")
            PlayerPos = Player.Character:WaitForChild("HumanoidRootPart")
            Pet:FindFirstChild("HitBox").Anchored = true
            Distance = (PlayerPos.Position-Pet:FindFirstChild("HitBox").Position).Magnitude
--[[             print(Player.Character)
            print(Distance) ]]

            function notjumping()
                if Player.Character:FindFirstChild("Humanoid").Jump == true then
                    wait(1)
                    return false
                else
                    return true
                end
            end
            if Player.Character ~= nil and Distance > 8 and notjumping() then

                local HitBox = Pet:FindFirstChild("HitBox")
                local PlayerPosVector = Vector3.new(PlayerPos.Position.X/1.01,PlayerPos.Position.Y-2,PlayerPos.Position.Z/1.01)
                x,y,z=HitBox.CFrame:ToEulerAnglesYXZ()
                x=TweenService:Create(Pet:FindFirstChild("HitBox"),MovingConfig,{CFrame = CFrame.new(PlayerPosVector,HitBox.Position)*CFrame.Angles(math.rad(GameRotation.Value.X),math.rad(GameRotation.Value.Y),math.rad(GameRotation.Value.Z))})
                x:Play()
--[[                 spawn(function()
                    while x.Completed ~= Enum.PlaybackState.Completed do
                        RunService.Stepped:Wait()
                        HitBox.CFrame = CFrame.new(HitBox.Position,Vector3.new(PlayerPos.Position.X,PlayerPos.Position.Y,PlayerPos.Position.Z))
                    end
                end) *]]
            end
        end

        print(Pet)
    end)
end

return PetConfig