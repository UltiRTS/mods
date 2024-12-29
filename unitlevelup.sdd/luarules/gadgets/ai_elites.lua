function gadget:GetInfo()
    return {
        name      = "AI Elites",
        desc      = "AI Elites",
        author    = "Presstabstart",
        date      = "now",
        license   = "GNU GPL v2 or later",
        layer     = 1,
        enabled   = true  --  loaded by default?
    }
end

if not gadgetHandler:IsSyncedCode() then
    return
end

local growthSettings = VFS.Include("LuaRules/Configs/levelupsettings.lua")

function gadget:UnitFinished(unitID, unitDefID, unitTeam)
    if growthSettings.aiElites > 0.0 and GG.GlobalAutoperkEnabled[unitTeam] then
        e = math.random(0, 100)

        if e < 20 then
            Spring.SetUnitExperience(unitID, 5.0)
        elseif e < 30 then
            Spring.SetUnitExperience(unitID, 10.0)
        elseif e < 33 then
            Spring.SetUnitExperience(unitID, 30.0)
        end
    end
end