local root = piece "root"
local needed = piece "needed"

function script.Create()
	Spring.SetUnitNoDraw(unitID, true)
	Spring.SetUnitNoSelect(unitID, true)
	Spring.SetUnitNoMinimap(unitID, true)
	Spring.SetUnitRadiusAndHeight(unitID, 0, 0)
end

function script.AimFromWeapon()
	return root
end

function script.AimWeapon(num, heading, pitch)
	-- return true
	return needed
end

function script.QueryWeapon(num)
	if type(num) ~= 'number' then
		return root
	else
		return needed
	end
end