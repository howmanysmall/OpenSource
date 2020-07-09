local Roact = require(script.Parent.Parent.Roact)
local SettingsEntry = require(script.Parent)

return function(Target)
	local Tree = Roact.mount(Roact.createElement("Frame", {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
	}, {
		UIGridLayout = Roact.createElement("UIGridLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirectionMaxCells = 4,
			CellSize = UDim2.fromScale(1, 0.1),
		}),

		SettingsEntry = Roact.createElement(SettingsEntry),
		ButtonEntry = Roact.createElement(SettingsEntry, {
			IsButton = true,
			OnClicked = function() end,
		}),
	}), Target)

	return function()
		Roact.unmount(Tree)
	end
end