Data = {}
Data._index = Data

local HttpService = game:GetService("HttpService")

function Data.Convert(Table)
    return HttpService:JSONEncode(Table)
end

function Data.Pull(str)
    return HttpService:JSONDecode(str)
end

function Data.Add(Table,Index,Item)
    table.insert(Table[Index],Item)
    return Table
end

function Data.Change(Table,Index,Val)
    Table[Index] = Val
    return Table
end

return Data