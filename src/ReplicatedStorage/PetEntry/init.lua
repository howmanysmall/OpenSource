local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")

local Constants = require(script.Parent.Constants)
local Promise = require(script.Parent.Promise)
local PromiseRemoteFunction = require(script.Parent.PromiseRemoteFunction) -- This is the same as Quenty's but uses evaera's Promise library.

local Roact = require(script.Parent.Roact)
local RoactMaterial = require(script.Parent.RoactMaterial)
local RotatingViewport = require(script.Parent.RotatingViewport)

local PetEntry = Roact.Component:extend("PetEntry")
PetEntry.defaultProps = {
	LayoutOrder = 0,
	EntryName = "CatPet",
	TopText = "Cat Pet",
	BottomText = "",
	ItemPrice = 4000,
	Visible = true,
	Theme = RoactMaterial.Themes.Dark,

	HasPurchased = false,
	IsEquipped = false,
	CannotBePurchased = false,
	IsLimited = false,
	OnSelected = function(PetName: string)
		print(PetName)
	end,
}

function PetEntry:init(props)
	self:setState({
		HasPurchased = props.HasPurchased,
		IsEquipped = props.IsEquipped,
	})

	PromiseRemoteFunction("GameFunction"):AndThen(function(GameFunction: RemoteFunction)
		self.gameFunction = GameFunction
	end):Catch(warn)

	if Players.LocalPlayer then
		local Promises = table.create(2)
		Promises[1], Promises[2] = Promise.Defer(function(Resolve)
			Resolve(Players.LocalPlayer:WaitForChild("leaderstats"))
		end), Promise.Defer(function(Resolve)
			Resolve(Players.LocalPlayer:WaitForChild("Cash"))
		end)

		Promise.All(Promises):AndThen(function(Objects)
			self.leaderstats = Objects[1]
			self.cash = Objects[2]
		end)
	end

	self.invokeServer = function(...)
		local Arguments = {...}
		return Promise.Defer(function(Resolve)
			Resolve(self.gameFunction:InvokeServer(table.unpack(Arguments)))
		end)
	end

	self.invokeServerPcall = function(...)
		local Arguments = {...}
		return Promise.Defer(function(Resolve, Reject)
			local Success, Error = self.gameFunction:InvokeServer(table.unpack(Arguments))
			if Success then
				Resolve()
			else
				Reject(Error)
			end
		end)
	end

	self.tryPurchase = function()
		local LocalPlayer: Player = Players.LocalPlayer
		if LocalPlayer then
			if self.state.IsEquipped then
				return
			end

			if self.state.HasPurchased then
				self.invokeServer(Constants.CHECK_PET_OWNERSHIP, self.props.EntryName):AndThen(function(Value: boolean)
					if Value then
						self.invokeServerPcall(Constants.CHANGE_CURRENT_PET, self.props.EntryName):AndThen(function()
							self.props.OnSelected(self.props.EntryName)
							self:setState({
								IsEquipped = true,
							})
						end):Catch(warn)
					else
						self:setState({
							HasPurchased = false,
							IsEquipped = false,
						})
					end
				end)
			else
				if not self.props.CannotBePurchased then
					local PetPrice = Constants.PET_PRICES[self.props.EntryName]
					if self.cash.Value >= PetPrice then
						self.invokeServerPcall(Constants.TRY_FOR_PET_PURCHASE, self.props.EntryName):AndThen(function()
							self:setState({
								HasPurchased = true,
							})

							self.invokeServerPcall(Constants.CHANGE_CURRENT_PET, self.props.EntryName):AndThen(function()
								self.props.OnSelected(self.props.EntryName)
								self:setState({
									IsEquipped = true,
								})
							end):Catch(warn)
						end):Catch(warn)
					end
				end
			end
		end
	end
end

function PetEntry:render()
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
					OnClicked = self.tryPurchase,
				}),

				ContainerFrame = Roact.createElement("Frame", {
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
				}, {
					UIListLayout = Roact.createElement("UIListLayout", {
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),

					UIPadding = Roact.createElement("UIPadding", {
						PaddingBottom = UDim.new(0.05, 0),
						PaddingLeft = UDim.new(0.143, 0),
						PaddingRight = UDim.new(0.143, 0),
						PaddingTop = UDim.new(0.05, 0),
					}),

					PetIcon = Roact.createElement("Frame", {
						Size = UDim2.fromScale(0.95, 0.95),
						BackgroundTransparency = 1,
						ZIndex = 6,
					}, {
						UIAspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint"),
						LimitedEdition = Roact.createElement("TextLabel", {
							AnchorPoint = Vector2.new(0, 1),
							BackgroundTransparency = 1,
							Position = UDim2.fromScale(0, 1),
							Size = UDim2.fromScale(1, 0.15),
							Visible = self.props.IsLimited,
							ZIndex = 8,
							Font = Enum.Font.GothamBlack,
							Text = "LIMITED EDITION",
							TextColor3 = Color3.fromRGB(0, 150, 136),
							TextScaled = true,
							TextXAlignment = Enum.TextXAlignment.Left,
						}),

						PetViewport = Roact.createElement(RotatingViewport, {
							ZIndex = 7,
							FieldOfView = 5,
							DepthMultiplier = 1.2,
							IsRunning = self.props.Visible,
							UpdateEvent = RunService.RenderStepped,
							ViewportModel = self.props.ViewportModel,
						}),
					}),

					ItemTitle = Roact.createElement("Frame", {
						BackgroundTransparency = 1,
						LayoutOrder = 1,
						Size = UDim2.fromScale(1, 0.2),
						ZIndex = 6,
					}, {
						UIListLayout = Roact.createElement("UIListLayout", {
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

					ItemPrice = Roact.createElement("TextLabel", {
						BackgroundTransparency = 1,
						LayoutOrder = 2,
						Size = UDim2.fromScale(1, 1),
						ZIndex = 6,
						Font = Enum.Font.SourceSansSemibold,
						Text = string.format("%d Cash", self.props.ItemPrice),
						TextColor3 = Color3.fromRGB(0, 150, 136),
						TextScaled = true,
						TextXAlignment = Enum.TextXAlignment.Right,
					}),
				}),
			}),
		}),
	})
end

return PetEntry