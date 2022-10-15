local maximum_multiplier = 200
local maximum_dmg = 200000
local acc_multipliers = {}
local maxDmgs = {}

return {
    -- this get called 30 times per secs
    onDamage = function (unitID, unitDefID, unitTeam, damage, paralyzer, weaponID, projectileID, attackerID, attackerDefID, attackerTeam)
        Spring.Echo("registering god saves you")
        GG.PerkRegisterOnTick(attackerID, "godSavesU")
    end,
    onTick = function (unitID)
        local multiplier = 1
        if acc_multipliers[unitID] ~= nil then
            multiplier = acc_multipliers[unitID]            
        else
            acc_multipliers[unitID] = multiplier
        end

        multiplier = multiplier * 1.0003
        if multiplier < maximum_multiplier then
            acc_multipliers[unitID] = multiplier

            local health = math.floor(Spring.GetUnitHealth(unitID) * multiplier)
            Spring.SetUnitMaxHealth(unitID, health)
        end

    end
}