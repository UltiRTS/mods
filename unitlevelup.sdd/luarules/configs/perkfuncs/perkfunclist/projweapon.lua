local strCache = {}

return {
  onPick = function (unitID)
    local unitDef = UnitDefs[Spring.GetUnitDefID(unitID)]
    for _,wd in ipairs(unitDef.weapons) do
      local wdID = wd.weaponDef
      if not (WeaponDefs[wdID].type == [[BeamLaser]] or WeaponDefs[wdID].type == [[LightningCannon]]) then
        Script.SetWatchWeapon(wdID, true)
      end
    end
  end,

  onProjectileCreated = function (projectileID, projOwnerID, weaponDefID)
    if not (WeaponDefs[weaponDefID].type == [[BeamLaser]] or WeaponDefs[weaponDefID].type == [[LightningCannon]]) then
      local ud = UnitDefs[Spring.GetUnitDefID(projOwnerID)]
      if not strCache[weaponDefID] then
        strCache[weaponDefID] = string.gsub(WeaponDefs[weaponDefID].name, '_lvlwep', '')
      end

      if UnitDefNames["weapondummy_" .. strCache[weaponDefID]] then
        GG.CreateWeaponDummy({proj = projectileID}, strCache[weaponDefID])
      else
        Spring.Echo("Error: cannot create weapon dummy for " .. strCache[weaponDefID] .. " because the associated weapon dummy def does not exist")
      end
    end
  end
}