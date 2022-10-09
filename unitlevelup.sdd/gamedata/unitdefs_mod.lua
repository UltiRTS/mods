local levelWeaponImports = VFS.Include("LuaRules/Configs/levelweapondefs.lua")
local blacklist = VFS.Include("LuaRules/Configs/blacklistdefs.lua")
local levelWeaponList = levelWeaponImports.list
local levelWeaponListDefs = levelWeaponImports.defs

local system = VFS.Include('gamedata/system.lua')
local realSystem = VFS.Include('LuaGadgets/system.lua')
local lowerKeys = system.lowerkeys

VFS.Include("LuaRules/Utilities/tablefunctions.lua")
CopyTable = Spring.Utilities.CopyTable

local droneMap = {
	lowcost = { "dronemaxlvllow" },
	medcost = { "dronemaxlvlmed" },
	highcost = { "dronemaxlvlmed", "dronemaxlvlheavy" }
}

local function onlyMiscWeps(wds)
	local ret = true;
	for _,wd in pairs(wds) do
		ret = ret and (wd.weapontype == [[Shield]] or wd.interceptor)
	end

	return ret
end

local function hasBadDef(ud)
	return string.find(ud.name, "comm") or ud.customparams.unarmed or ud.customparams.dynamic_comm or string.find(ud.category, [[FAKEUNIT]])
end

local function findShield(ud)
	for wdn,wd in pairs(ud.weapondefs) do
		if wd.weapontype == [[Shield]] then
			for wk,_ in pairs(ud.weapons) do
				if wdn == wk then
					return { def = wd, widx = wk }
				end
			end
		end
	end
end

local function findWeapons(ud)
	local wepList = {}
	for wdn,wd in pairs(ud.weapondefs) do
		if not (wd.weapontype == [[Shield]]) then
			wepList[wdn] = true
		end
	end

	return wepList
end

local function isBuilding(ud)
	return (ud.maxVelocity and (ud.maxVelocity > 0.01)) or true
end

local function initMiniUnitDef(ud, costKey)
		local udMiniName = ud.unitname .. "_mini"
		UnitDefs[udMiniName] = CopyTable(ud, true)
		
		UnitDefs[udMiniName].unitname = ud.unitname .. "_mini"
		UnitDefs[udMiniName].maxdamage = ud.maxdamage * 0.2;
		UnitDefs[udMiniName].customparams.final_form = true

		UnitDefs[udMiniName].buildcostmetal = ud.buildcostmetal and ud.buildcostmetal * 0.25
		UnitDefs[udMiniName].buildcostenergy = ud.buildcostenergy and ud.buildcostenergy * 0.25
		UnitDefs[udMiniName].buildtime = ud.buildtime and ud.buildtime * 0.25
		local shield = findShield(UnitDefs[udMiniName])
		if shield then
			UnitDefs[udMiniName].def.shieldradius = shield.def.shieldradius * 0.25
			UnitDefs[udMiniName].def.shieldpower = shield.def.shieldpower + ud.maxdamage * 0.15
			UnitDefs[udMiniName].def.shieldpowerregen = ud.maxdamage * 0.015
			UnitDefs[udMiniName].def.shieldpowerregenenergy = ud.maxdamage / 2000.0

			UnitDefs[udMiniName].customparams.shield_radius = shield.def.shieldradius * 0.25
			UnitDefs[udMiniName].customparams.shield_power = shield.def.shieldpower
			UnitDefs[udMiniName].customparams.shield_recharge_delay = (ud.customparams.shield_recharge_delay or 0.0) or 0.25
			UnitDefs[udMiniName].customparams.shield_rate = shield.def.shieldpowerregen
		end

		for wdn,wd in pairs(UnitDefs[udMiniName].weapondefs) do
			for wdDamageType,wdDamage in pairs(wd.damage) do
				wd.damage[wdDamageType] = wdDamage * 0.25
			end

			UnitDefs[udMiniName].weapondefs[wdn].areaOfEffect = ud.weapondefs[wdn].areaOfEffect and ud.weapondefs[wdn].areaOfEffect * 0.5;
		end
end

local defaultDummyUnitDef = UnitDefs["standarddummy"]
local udParseList = {}
local numWeaponDummies = 0
local costKeys = { "lowcost", "medcost", "highcost", "veryhighcost" }

for udName,_ in pairs(UnitDefs) do
	udParseList[udName] = true
end

local function createDummyWeaponWeaponDef(wdName, wd)
	if not (wd.weaponType == [[BeamLaser]] or wd.weaponType == [[LightningCannon]] or wd.weaponType == [[Shield]]) then
		local newDefName = "weapondummy_" .. string.lower(wdName)
		local wdDummyName = "dummywep_" .. wdName
		numWeaponDummies = numWeaponDummies + 1
		UnitDefs[newDefName] = CopyTable(defaultDummyUnitDef, true)
		UnitDefs[newDefName].unitname = newDefName
		UnitDefs[newDefName].name = "Weapon dummy (" .. wdDummyName .. ")"
		UnitDefs[newDefName].weapons[1] = {
				def = string.upper(wdDummyName),
				badtargetcategory  = [[FIXEDWING]],
				onlytargetcategory = [[SWIM FIXEDWING HOVER LAND SINK TURRET FLOAT SHIP GUNSHIP]],
		}

		UnitDefs[newDefName].weapondefs[string.lower(wdDummyName)] = CopyTable(wd)
	end
end

local function createDummyWeaponUnitDef(ud)
	local cost = math.max (ud.buildcostenergy or 0, ud.buildcostmetal or 0, ud.buildtime or 0)
	if ud.weapons and (not hasBadDef(ud)) and (not onlyMiscWeps(ud.weapondefs)) and (cost > 100) then
		for wdName,wd in pairs(ud.weapondefs) do
			createDummyWeaponWeaponDef(wdName, wd)
		end
	end
end

local miniUnitWhitelist = {
	"amphcon",
	"hovercon",
	"jumpcon",
	"planecon",
	"shieldcon",
	"shipcon",
	"spidercon",
	"vehcon",
	"striderfunnelweb",
	"gunshipcon",
	"cloakcon",
	"tankcon"
}

local function isInWhitelist(unitName)
	for _,wlName in ipairs(miniUnitWhitelist) do
		if unitName == wlName then
			return true
		end
	end

	return false
end

for udName,_ in pairs(udParseList) do
	local ud = UnitDefs[udName]
	if not ud.customparams then
		ud.customparams = {} -- we need this now
	end

	local cost = math.max (ud.buildcostenergy or 0, ud.buildcostmetal or 0, ud.buildtime or 0)
	createDummyWeaponUnitDef(ud)

	if (not ud.weapons or #ud.weapons > 10 or hasBadDef(ud) or onlyMiscWeps(ud.weapondefs)) and
		(not isInWhitelist(ud.unitname))
	then
		ud.customparams.disable_level_weapon = true
	else
		local costKey = ""
		local maxRange = 0
		for _,wd in pairs(ud.weapondefs or {}) do
			maxRange = math.max(maxRange, wd.range or 0)
		end
		maxRange = (maxRange > 0 and maxRange) or 400
		
		if maxRange < 170 then
			costKey = "melee"
		else
			for i, kc in ipairs({ 150, 800, 2500 }) do
				if cost < kc then
					costKey = costKeys[i]
					break
				end

				costKey = costKeys[4]
			end

			if costKey == "medcost" then
				for _,subcat in pairs({"riot", "raid", "skirm", "assault"}) do
					costKey = costKey .. ((string.find(ud.unitname, subcat) and subcat) or "")
				end
			end
		end

		if not blacklist.noweapon[ud.unitname] then
			local levelWeapons = levelWeaponList[costKey]
			ud.weapons = ud.weapons or {}
			ud.weapondefs = ud.weapondefs or {}
			ud.customparams.num_normal_weapons = #ud.weapons
			ud.customparams.level_weapon_cat = costKey
			for k,levelWeaponDefName in pairs(levelWeapons) do
				local levelWeaponDefName = string.lower(levelWeaponDefName)
				local levelWeaponDef = CopyTable(levelWeaponListDefs[levelWeaponDefName])
				
				levelWeaponDef.range = math.min(levelWeaponDef.range, maxRange * 0.95)
				ud.weapondefs[levelWeaponDefName] = levelWeaponDef
				ud.weapons[#ud.weapons + 1] = {
					def = string.upper(levelWeaponDefName),
					badtargetcategory  = [[FIXEDWING]],
					onlytargetcategory = [[SWIM FIXEDWING HOVER LAND SINK TURRET FLOAT SHIP GUNSHIP]],
				}
			end
		else
			ud.customparams.disable_level_weapon = true
		end

		initMiniUnitDef(ud, costKey)
	end
end

for wdName, wd in pairs(levelWeaponListDefs) do
	createDummyWeaponWeaponDef(wdName, wd)
end