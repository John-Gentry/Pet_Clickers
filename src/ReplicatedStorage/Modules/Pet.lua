Pet = {}
Pet._index = Pet

local Data = require(game.ReplicatedStorage.Modules.Data)

function Pet.new(Type,PetPosition)
    NewPet = {}
    Pets = game.ReplicatedStorage.Pets
    local ClientObjects = game.Workspace.ClientObjects
    local Camera = game.Workspace.CurrentCamera
    NewPet.Model = Pets:FindFirstChild(Type):Clone()
    a = NewPet.Model:FindFirstChild("Rotation").Value
    --[[ print(PetPosition) ]]
    NewPet.Model.Parent = ClientObjects
    NewPet.Model.HitBox.CFrame = CFrame.new(PetPosition) 
    NewPet.Model.HitBox.CFrame = CFrame.new(PetPosition,Camera.CFrame.p)*CFrame.Angles(math.rad(a.x), math.rad(a.y), math.rad(a.z))
    return NewPet.Model
end

function Pet:DestroyPets()
    for _,v in pairs(game.Workspace.ClientObjects:GetChildren()) do v:Destroy() end
end

function Pet.GainXP(Pet,Amount)
    local Player = game.Players.LocalPlayer
    local PlayerDataString = Player:FindFirstChild("Data").PlayerData
    local PlayerTable = Data.Pull(PlayerDataString.Value)
    for i,v in pairs(PlayerTable[4]) do
		if v == Pet then
			if PlayerTable[5][i] == nil then
				table.insert(PlayerTable[5],{1,0,10})
			end
			local PetLevel = PlayerTable[5][i][1]
			local PetXP = PlayerTable[5][i][2]
			local PetGoalXP = PlayerTable[5][i][3]
			PlayerTable[5][i][2] = PlayerTable[5][i][2]+Amount
			print(PlayerTable[5][i][2])
		end
    end
    PlayerDataString.Value = Data.Convert(PlayerTable)
end


return Pet