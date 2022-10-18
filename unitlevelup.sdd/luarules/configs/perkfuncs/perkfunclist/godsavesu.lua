return {
    -- this get called 30 times per secs
    onDamage = function (unitID, unitDefID, unitTeam, damage, paralyzer, weaponID, projectileID, attackerID, attackerDefID, attackerTeam)
        local hp = Spring.GetUnitHealth(attackerID)
        hp = hp + damage

        Spring.SetUnitHealth(attackerID, hp)
    end,
}