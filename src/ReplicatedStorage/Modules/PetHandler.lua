PetHandler = {}
local ReplicatedStorage = game.ReplicatedStorage

function PetHandler.AddPetToPlayer(pet)
    local pet = ReplicatedStorage.Pets:FindFirstChild(pet):Clone()
    
end

return PetHandler