local Players = game:GetService("Players")
local Promise = require(script.Parent.Promise)

local function PromiseClone(Parent)
	return Promise.Defer(function(Resolve)
		local NewModel = Instance.new("Model")
		for _, Descendant in ipairs(Parent:GetDescendants()) do
			if Descendant:IsA("BasePart") and not Descendant:IsA("Terrain") and Descendant.Archivable then
				local Model = Descendant:FindFirstAncestorOfClass("Model")
				if Model then
					if Players:GetPlayerFromCharacter(Model) then
						continue
					end
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