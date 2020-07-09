local Roact = require(script.Parent.Roact)
local RoactMaterial = require(script.Parent.RoactMaterial)

local SettingsEntry = Roact.Component:extend("SettingsEntry")
SettingsEntry.defaultProps = {
	LayoutOrder = 0,
	EntryName = "Shadows",
	TopText = "Shadows",
	BottomText = "Disables or enables shadows in the game.",
	Theme = RoactMaterial.Themes.Dark,
	Checked = false,
	IsButton = false,
	OnChecked = function(Checked: boolean)
		print(Checked)
	end,

	OnClicked = function()
	end,
}

function SettingsEntry:init(props)
	self:setState({
		Checked = props.Checked,
	})
end

function SettingsEntry:render()
	if self.props.IsButton then
		local OnClicked = assert(self.props.OnClicked, "Missing OnClicked!")
		return Roact.createElement(RoactMaterial.ThemeProvider, {
			Theme = self.props.Theme,
		}, {
			[self.props.EntryName] = Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				LayoutOrder = self.props.LayoutOrder,
			}, {
				Shadow = Roact.createElement(RoactMaterial.Shadow, {
					Elevation = 4,
				}),

				TransparentButton = Roact.createElement(RoactMaterial.TransparentButton, {
					Size = UDim2.fromScale(1, 1),
					ZIndex = 9,
					OnClicked = OnClicked,
				}),

				[self.props.EntryName .. "Main"] = Roact.createElement("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 1),
					Position = UDim2.fromScale(0.5, 0.5),
					ZIndex = 6,
					ClipsDescendants = true,
					Image = "rbxassetid://1934624205",
					ImageColor3 = Color3.fromRGB(30, 30, 30),
					ScaleType = Enum.ScaleType.Slice,
					SliceCenter = Rect.new(4, 4, 252, 252),
				}, {
					UIPadding = Roact.createElement("UIPadding", {
						PaddingBottom = UDim.new(0.143, 0),
						PaddingLeft = UDim.new(0.025, 0),
						PaddingRight = UDim.new(0.025, 0),
						PaddingTop = UDim.new(0.143, 0),
					}),

					ItemTitle = Roact.createElement("Frame", {
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(0.85, 1),
						ZIndex = 6,
					}, {
						UIListLayout = Roact.createElement("UIListLayout", {
							FillDirection = Enum.FillDirection.Vertical,
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							SortOrder = Enum.SortOrder.LayoutOrder,
							VerticalAlignment = Enum.VerticalAlignment.Top,
						}),

						TopTitle = Roact.createElement("TextLabel", {
							BackgroundTransparency = 1,
							Size = UDim2.fromScale(1, 0.5),
							Font = Enum.Font.SourceSans,
							Text = self.props.TopText,
							TextColor3 = Color3.new(1, 1, 1),
							TextScaled = true,
							TextTransparency = 0.129,
							TextXAlignment = Enum.TextXAlignment.Left,
							TextYAlignment = Enum.TextYAlignment.Top,
						}),

						BottomTitle = Roact.createElement("TextLabel", {
							BackgroundTransparency = 1,
							Size = UDim2.fromScale(1, 0.5),
							LayoutOrder = 1,
							Font = Enum.Font.SourceSans,
							Text = self.props.BottomText,
							TextColor3 = Color3.new(1, 1, 1),
							TextScaled = true,
							TextTransparency = 0.4,
							TextXAlignment = Enum.TextXAlignment.Left,
						}),
					}),
				}),
			}),
		})
	else
		return Roact.createElement(RoactMaterial.ThemeProvider, {
			Theme = self.props.Theme,
		}, {
			[self.props.EntryName] = Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				LayoutOrder = self.props.LayoutOrder,
			}, {
				Shadow = Roact.createElement(RoactMaterial.Shadow, {
					Elevation = 4,
				}),

				[self.props.EntryName .. "Main"] = Roact.createElement("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 1),
					Position = UDim2.fromScale(0.5, 0.5),
					ZIndex = 6,
					ClipsDescendants = true,
					Image = "rbxassetid://1934624205",
					ImageColor3 = Color3.fromRGB(30, 30, 30),
					ScaleType = Enum.ScaleType.Slice,
					SliceCenter = Rect.new(4, 4, 252, 252),
				}, {
					UIPadding = Roact.createElement("UIPadding", {
						PaddingBottom = UDim.new(0.143, 0),
						PaddingLeft = UDim.new(0.025, 0),
						PaddingRight = UDim.new(0.025, 0),
						PaddingTop = UDim.new(0.143, 0),
					}),

					CheckArea = Roact.createElement("Frame", {
						AnchorPoint = Vector2.new(1, 0.5),
						BackgroundTransparency = 1,
						Position = UDim2.fromScale(1, 0.5),
						Size = UDim2.fromScale(1, 1),
						ZIndex = 6,
					}, {
						UIAspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint"),
						ToggleButton = Roact.createElement(RoactMaterial.Switch, {
							Checked = self.state.Checked,
							OnChecked = function(Checked)
								self.props.OnChecked(Checked)
								self:setState({
									Checked = Checked,
								})
							end,
						}),
					}),

					ItemTitle = Roact.createElement("Frame", {
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(0.85, 1),
						ZIndex = 6,
					}, {
						UIListLayout = Roact.createElement("UIListLayout", {
							FillDirection = Enum.FillDirection.Vertical,
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							SortOrder = Enum.SortOrder.LayoutOrder,
							VerticalAlignment = Enum.VerticalAlignment.Top,
						}),

						TopTitle = Roact.createElement("TextLabel", {
							BackgroundTransparency = 1,
							Size = UDim2.fromScale(1, 0.5),
							Font = Enum.Font.SourceSans,
							Text = self.props.TopText,
							TextColor3 = Color3.new(1, 1, 1),
							TextScaled = true,
							TextTransparency = 0.129,
							TextXAlignment = Enum.TextXAlignment.Left,
							TextYAlignment = Enum.TextYAlignment.Top,
						}),

						BottomTitle = Roact.createElement("TextLabel", {
							BackgroundTransparency = 1,
							Size = UDim2.fromScale(1, 0.5),
							LayoutOrder = 1,
							Font = Enum.Font.SourceSans,
							Text = self.props.BottomText,
							TextColor3 = Color3.new(1, 1, 1),
							TextScaled = true,
							TextTransparency = 0.4,
							TextXAlignment = Enum.TextXAlignment.Left,
						}),
					}),
				}),
			}),
		})
	end
end

return SettingsEntry