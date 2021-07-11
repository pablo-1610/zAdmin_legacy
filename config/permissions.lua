Permissions = {
    ranksPrefix = {
        ["user"] = { power = 0, prefix = "" },
        ["mod"] = { power = 1, prefix = "~y~[Mod] " },
        ["admin"] = { power = 2, prefix = "~o~[Admin] " },
        ["superadmin"] = { power = 3, prefix = "~r~[S.Admin] " }
    },

    hasPermission = function(index, group)
        local list = Permissions.list
        if not list[index] then
            return true
        end
        for _, v in pairs(list[index]) do
            if v == group then
                return true
            end
        end
        return false
    end,

    list = {
        ["open_menu"] = { "superadmin", "admin", "mod" }
    }
}