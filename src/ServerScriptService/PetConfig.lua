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
        [0.15] = "Chicken"
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

return PetConfig