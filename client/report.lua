localReportsTable, reportCount, take = {},0,0

function generateReportDisplay()
    return "~s~Reports actifs: ~o~"..reportCount.."~s~ | Pris en charge: ~y~"..take
end

RegisterNetEvent("adminmenu:cbReportTable")
AddEventHandler("adminmenu:cbReportTable", function(table)
    -- TODO -> Add a sound when report taken
    reportCount = 0
    take = 0
    for source,report in pairs(table) do
        reportCount = reportCount + 1
        if report.taken then take = take + 1 end
    end
    localReportsTable = table
end)