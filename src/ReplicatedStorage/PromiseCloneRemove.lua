local Players = game:GetService("Players")
local FieldOfSight = require(script.Parent.FieldOfSight)
local Promise = require(script.Parent.Promise)

local function PromiseClone(Parent: Instance, HeadCFrame: CFrame, MaxDistance: number, Range: number)
	return Promise.Defer(function(Resolve: (Model) -> any)
		local NewModel: Model = Instance.new("Model")
		for _, Descendant: Instance in ipairs(Parent:GetDescendants()) do
			if Descendant:IsA("BasePart") and not Descendant:IsA("Terrain") and Descendant.Archivable then
				local Model: Model = Descendant:FindFirstAncestorOfClass("Model")
				if Model then
					if Players:GetPlayerFromCharacter(Model) then
						continue
					end
				end

				if not FieldOfSight(HeadCFrame, Descendant, MaxDistance, Range) then
					continue
				end

				local Clone = Descendant:Clone()
				Clone.Anchored = true
				Clone.Parent = NewModel
			end
		end

		Resolve(NewModel)
	end)
end

return PromiseClone