function canUse(permission, playerRank)
    if playerRank == "user" then
        return false
    end
    if type(Config.authorizations[permission]) ~= "table" then
        return true
    end
    for k,rank in pairs(Config.authorizations[permission]) do
        if rank == playerRank then
            return true
        end
    end
    return false
end