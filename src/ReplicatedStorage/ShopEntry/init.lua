local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local Roact = require(script.Parent.Roact)
local RoactMaterial = require(script.Parent.RoactMaterial)
local MarketPromise = require(script.Parent.MarketPromise)

local UI_CORNER_ENABLED = true

local ShopEntry = Roact.Component:extend("ShopEntry")
ShopEntry.defaultProps = {
	LayoutOrder = 0,
	EntryName = "Suite",
	TopText = "Suite",
	BottomText = "",
	AssetId = 5088135,
	InfoType = Enum.InfoType.GamePass,
	Theme = RoactMaterial.Themes.Dark,
}

function ShopEntry:init(props)
	self:setState({
		PriceText = "ERR_FAIL",
		ProductImage = "rbxasset://textures/ui/GuiImagePlaceholder.png",
	})

	self.position, self.setPosition = Roact.createBinding(-49)
	MarketPromise.PromiseProductInfo(props.AssetId, props.InfoType):AndThen(function(ProductInfo)
		if ProductInfo.PriceInRobux ~= 0 then
			self:setState({
				PriceText = tostring(ProductInfo.PriceInRobux),
			})
		end

		if ProductInfo.IconImageAssetId ~= 0 then
			self:setState({
				ProductImage = string.format("rbxassetid://%d", ProductInfo.IconImageAssetId),
			})
		end
	end):Catch(warn)
end

function ShopEntry:render()
	return Roact.createElement(RoactMaterial.ThemeProvider, {
		Theme = self.props.Theme,
	}, {
		[self.props.EntryName] = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			LayoutOrder = self.props.LayoutOrder,
			Size = UDim2.fromScale(0.75, 0.75),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			ClipsDescendants = true,
		}, {
			Roact.createElement(RoactMaterial.Shadow, {
				Elevation = 4,
			}),

			ShopMain = Roact.createElement("ImageLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				ZIndex = 6,
				ClipsDescendants = true,
				Image = "rbxassetid://1934624205",
				ImageColor3 = Color3.fromRGB(30, 30, 30),
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(4, 4, 252, 252),
			}, {
				PurchaseButton = Roact.createElement(RoactMaterial.TransparentButton, {
					ZIndex = 12,
					Size = UDim2.fromScale(1, 1),
					OnClicked = function()
						if self.props.InfoType == Enum.InfoType.GamePass then
							MarketplaceService:PromptGamePassPurchase(Players.LocalPlayer, self.props.AssetId)
						elseif self.props.InfoType == Enum.InfoType.Product then
							MarketplaceService:PromptProductPurchase(Players.LocalPlayer, self.props.AssetId)
						end
					end,
				}),

				ContainerFrame = Roact.createElement("Frame", {
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
				}, {
					Roact.createElement("UIListLayout", {
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),

					Roact.createElement("UIPadding", {
						PaddingBottom = UDim.new(0.05, 0),
						PaddingLeft = UDim.new(0.143, 0),
						PaddingRight = UDim.new(0.143, 0),
						PaddingTop = UDim.new(0.05, 0),
					}),

					GamePassIcon = Roact.createElement("ImageLabel", {
						Size = UDim2.fromScale(0.95, 0.95),
						BackgroundTransparency = 1,
						ZIndex = 6,
						Image = self.state.ProductImage,
					}, table.create(1, Roact.createElement("UIAspectRatioConstraint"))),

					ItemTitle = Roact.createElement("Frame", {
						BackgroundTransparency = 1,
						LayoutOrder = 1,
						Size = UDim2.fromScale(1, 0.2),
						ZIndex = 6,
					}, {
						Roact.createElement("UIListLayout", {
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							SortOrder = Enum.SortOrder.LayoutOrder,
						}),

						TopTitle = Roact.createElement("TextLabel", {
							BackgroundTransparency = 1,
							Size = UDim2.fromScale(1, 0.5),
							ZIndex = 6,
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
							ZIndex = 6,
							LayoutOrder = 1,
							Font = Enum.Font.SourceSans,
							Text = self.props.BottomText,
							TextColor3 = Color3.new(1, 1, 1),
							TextScaled = true,
							TextTransparency = 0.129,
							TextXAlignment = Enum.TextXAlignment.Left,
						}),
					}),

					PriceFrame = Roact.createElement("Frame", {
						LayoutOrder = 2,
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(1, 0.096),
						ZIndex = 6,
					}, {
						ItemPrice = Roact.createElement("TextLabel", {
							BackgroundTransparency = 1,
							Size = UDim2.fromScale(1, 1),
							ZIndex = 6,
							Font = Enum.Font.SourceSansSemibold,
							Text = self.state.PriceText,
							TextColor3 = Color3.fromRGB(0, 150, 136),
							TextScaled = true,
							TextXAlignment = Enum.TextXAlignment.Right,
							[Roact.Event.Changed] = function(rbx, property)
								if property == "TextBounds" or string.match(property, "Size$") then
									self.setPosition(-(rbx.TextBounds.X + 4))
								end
							end,
						}),

						RobuxIcon = Roact.createElement("ImageLabel", {
							AnchorPoint = Vector2.new(1, 0),
							BackgroundTransparency = 1,
							Position = self.position:map(function(value)
								return UDim2.new(1, value, 0, 0)
							end),

							Size = UDim2.fromScale(1, 1),
							ZIndex = 12,
							Image = "rbxassetid://4456265931",
							ImageColor3 = Color3.fromRGB(0, 150, 136),
							ImageRectOffset = Vector2.new(43, 47),
							ImageRectSize = Vector2.new(28, 32),
						}, table.create(1, Roact.createElement("UIAspectRatioConstraint"))),
					}),
				}),
			}),
		}),
	})
end

return ShopEntry