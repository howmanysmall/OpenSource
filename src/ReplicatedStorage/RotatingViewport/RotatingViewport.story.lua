local RunService = game:GetService("RunService")
local Roact = require(script.Parent.Parent.Roact)
local RotatingViewport = require(script.Parent)

return function(Target)
	local Tree = Roact.mount(Roact.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
	}, {
		UIListLayout = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),

		RenderStepped = Roact.createElement(RotatingViewport, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromScale(0.25, 0.25),
			Position = UDim2.fromScale(0.5, 0.5),
			ViewportModel = script.Parent.Parent.Parent.PetModels.CatPet:Clone(),
			IsRunning = true,
			DepthMultiplier = 1.2,
			FieldOfView = 5,
			UpdateEvent = RunService.RenderStepped,
		}),

		Heartbeat = Roact.createElement(RotatingViewport, {
			Size = UDim2.fromScale(0.25, 0.25),
			LayoutOrder = 1,
			ViewportModel = script.Parent.Parent.Parent.PetModels.CatPet:Clone(),
			IsRunning = true,
			DepthMultiplier = 1.2,
			FieldOfView = 5,
			UpdateEvent = RunService.Heartbeat,
		}),
	}), Target)

	return function()
		Roact.unmount(Tree)
	end
end