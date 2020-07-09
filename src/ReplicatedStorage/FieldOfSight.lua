--[[**
	Determines if the target is withing the player's field of sight.

	@param [t:union<t:instanceIsA<BasePart>, t:CFrame>] Head The player's head.
	@param [t:union<t:instanceIsA<BasePart>, t:Vector3>] Target The target BasePart or position.
	@param [t:number] MaxDistance The max distance.
	@param [t:number] FieldOfView The range.
	@returns [t:boolean] Whether the target is withing the player's field of sight.
**--]]
local function FieldOfSight(HeadCFrame: CFrame, Target: BasePart | Vector3, MaxDistance: number, Range: number): boolean
	local RelativeTo: Vector3 = (typeof(Target) == "Instance" and Target.Position or Target) - HeadCFrame.Position
	return RelativeTo.Magnitude < MaxDistance and math.deg(math.cos(HeadCFrame.LookVector:Dot(RelativeTo.Unit))) <= Range
end

return FieldOfSight