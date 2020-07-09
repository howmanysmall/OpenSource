local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local Constants = require(script.Parent.Constants)
local Promise = require(script.Parent.Promise)
local Janitor = require(script.Parent.Janitor) -- https://github.com/RoStrap/Events/blob/master/Janitor.lua, modified.
local PromiseRemoteEvent = require(script.Parent.PromiseRemoteEvent) -- This is the same as Quenty's but uses evaera's Promise library.
local PromiseRemoteFunction = require(script.Parent.PromiseRemoteFunction) -- So is this.

local Otter = require(script.Parent.Otter)
local Roact = require(script.Parent.Roact)
local RoactMaterial = require(script.Parent.RoactMaterial)

local Signal = require(script.Parent.Signal) -- This is just Quenty's from Nevermore.
local PetEntry = require(script.Parent.PetEntry)
local SettingsEntry = require(script.Parent.SettingsEntry)
local ShopEntry = require(script.Parent.ShopEntry)
local TeleportEntry = require(script.Parent.TeleportEntry)

local SummitMenu = Roact.PureComponent:extend("SummitMenu")
SummitMenu.defaultProps = {
	Theme = RoactMaterial.Themes.Light,
}

function SummitMenu:init()
	self:setState({
		Visible = false,
		Theme = "Dark",
		SelectedButton = 0,
		TeleportVisible = false,
		EquippedPet = "",

		Settings = {
			ShadowsEnabled = true,
			RainEnabled = false,
			MusicEnabled = true,
			PetsEnabled = true,
		},

		HasRan = {
			Shadows = false,
			Rain = false,
			Music = false,
			Pets = false,
		},
	})

	self.janitor = Janitor.new()
	self.positionMotor = self.janitor:Add(Otter.createSingleMotor(-1.5), "destroy")
	self.position, self.setPosition = Roact.createBinding(-1.5)
	self.janitor:Add(self.positionMotor:onStep(self.setPosition), true)
	self.selectionChanged = self.janitor:Add(Signal.new(), "Destroy")
	self.layoutRef = Roact.createRef()

	local Array = table.create(3)
	Array[1] = PromiseRemoteEvent("GameEvent")
	Array[2] = PromiseRemoteFunction("GameFunction")
	Array[3] = Promise.Defer(function(Resolve)
		Resolve(ReplicatedStorage:FindFirstChild("SettingsFunction")) -- BindableFunction
	end)

	Promise.All(Array):AndThen(function(Remotes)
		self.gameEvent = Remotes[1]
		self.gameFunction = Remotes[2]
		self.settingsFunction = Remotes[3]

		self.promiseInvoke = function(...)
			local Arguments = {...}
			return Promise.Defer(function(Resolve)
				Resolve(self.settingsFunction:Invoke(table.unpack(Arguments)))
			end)
		end

		if RunService:IsClient() then
			Promise.Defer(function(Resolve)
				Resolve(self.gameFunction:InvokeServer(Constants.GET_SERVER_SETTINGS))
			end):AndThen(function(Settings)
				self:setState({
					Settings = Settings,
				})
			end):Catch(warn)
		else
			self:setState({
				Settings = {
					ShadowsEnabled = true,
					RainEnabled = false,
					MusicEnabled = true,
					PetsEnabled = true,
				},
			})
		end
	end):Catch(warn)
end

function SummitMenu:didMount()
	self.janitor:Add(self.selectionChanged:Connect(function()
		self.layoutRef:getValue():JumpToIndex(self.state.SelectedButton)
	end), "Disconnect")
end

function SummitMenu:willUnmount()
	self.janitor = self.janitor:Destroy()
--	self.connection = self.connection:Disconnect()
--	self.positionMotor = self.positionMotor:destroy()
--	self.selectionChanged = self.selectionChanged:Destroy()
end

function SummitMenu:render()
	local BackgroundTextures = {}
	for X = 0, 6 do
		for Y = 0, 1 do
			BackgroundTextures[string.format("BackgroundTexture_%d_%d", X, Y)] = Roact.createElement("ImageLabel", {
				BackgroundColor3 = Color3.fromRGB(0, 150, 136),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(X * 0.165, Y * 0.165),
				Size = UDim2.fromScale(0.165, 0.165),
				SizeConstraint = Enum.SizeConstraint.RelativeXX,
				ZIndex = 3,
				Image = "rbxassetid://328099692",
				ImageColor3 = Color3.fromRGB(0, 150, 136),
			})
		end
	end

	return Roact.createElement(RoactMaterial.ThemeProvider, {
		Theme = self.props.Theme,
	}, {
		SummitFrame = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
		}, {
			ShowMenu = Roact.createElement("ImageButton", {
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 5, 0.5, 0),
				Rotation = self.state.Visible and 0 or 180,
				Size = UDim2.fromScale(0.1, 0.25),
				Image = "rbxassetid://4776838994",

				[Roact.Event.InputBegan] = function(_, InputObject)
					if InputObject.UserInputType == Enum.UserInputType.MouseButton1 then
						local NewVisible = not self.state.Visible
						self:setState({
							Visible = NewVisible,
							TeleportVisible = false,
						})

						if NewVisible then
							self.positionMotor:setGoal(Otter.spring(0.5, {
								frequency = 6,
							}))
						else
							self.positionMotor:setGoal(Otter.spring(-1.5, {
								frequency = 6,
							}))
						end
					end
				end,
			}, table.create(1, Roact.createElement("UIAspectRatioConstraint", {
				DominantAxis = Enum.DominantAxis.Height,
				AspectRatio = 0.218,
			}))),

			MainFrameHolder = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(0.75, 0.75),
				Position = self.position:map(function(value)
					return UDim2.fromScale(value, 0.5)
				end),
			}, {
				Shadow = Roact.createElement(RoactMaterial.Shadow, {
					Elevation = 4,
				}),

				UIAspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint", {
					AspectRatio = 1.778,
				}),

				MainFrame = Roact.createElement("Frame", {
					BackgroundColor3 = Color3.fromRGB(18, 18, 18),
					BorderSizePixel = 0,
					Size = UDim2.fromScale(1, 1),
					ZIndex = 2,
					ClipsDescendants = true,
				}, {
					TopFrameButtons = Roact.createElement("Frame", {
						AnchorPoint = Vector2.new(0.5, 0),
						BackgroundTransparency = 1,
						Position = UDim2.fromScale(0.5, 0),
						Size = UDim2.fromScale(1, 0.25),
						ZIndex = 6,
					}, {
						PseudoButtons = Roact.createElement("Frame", {
							AnchorPoint = Vector2.new(0, 1),
							BackgroundTransparency = 1,
							Position = UDim2.fromScale(0, 1),
							Size = UDim2.fromScale(1, 0.3),
							ZIndex = 6,
						}, {
							UIGridLayout = Roact.createElement("UIGridLayout", {
								CellPadding = UDim2.new(),
								CellSize = UDim2.fromScale(0.2, 1),
								SortOrder = Enum.SortOrder.LayoutOrder,
								VerticalAlignment = Enum.VerticalAlignment.Center,
							}),

							GamePassButton = Roact.createElement(RoactMaterial.TransparentButton, {
								LayoutOrder = 0,
								OnClicked = function()
									self:setState({
										SelectedButton = 0,
										TeleportVisible = false,
									})

									self.selectionChanged:Fire()
								end,
							}),

							TeleportButton = Roact.createElement(RoactMaterial.TransparentButton, {
								LayoutOrder = 1,
								OnClicked = function()
									self:setState({
--										SelectedButton = 1,
										TeleportVisible = true,
									})

									self.selectionChanged:Fire()
								end,
							}, {
								Menu = Roact.createElement(RoactMaterial.Menu, {
									Width = UDim.new(1, 0),
									Open = self.state.TeleportVisible,
									Options = {
										"Floors",
										RoactMaterial.Menu.Divider,
										"Activities",
									},

									ZIndex = 15,
									OnOptionSelected = function(Option: string): nil
										self:setState({
											TeleportVisible = false,
											SelectedButton = Option == "Floors" and 1 or 2,
										})

										self.selectionChanged:Fire()
									end,
								}),
							}),

							SettingsButton = Roact.createElement(RoactMaterial.TransparentButton, {
								LayoutOrder = 2,
								OnClicked = function()
									self:setState({
										SelectedButton = 3,
										TeleportVisible = false,
									})

									self.selectionChanged:Fire()
								end,
							}),

							ShopButton = Roact.createElement(RoactMaterial.TransparentButton, {
								LayoutOrder = 3,
								OnClicked = function()
									self:setState({
										SelectedButton = 4,
										TeleportVisible = false,
									})

									self.selectionChanged:Fire()
								end,
							}),

							MenuButton = Roact.createElement(RoactMaterial.TransparentButton, {
								LayoutOrder = 4,
								OnClicked = function()
									self:setState({
										SelectedButton = 5,
										TeleportVisible = false,
									})

									self.selectionChanged:Fire()
								end,
							}),
						}),
					}),

					TopFrame = Roact.createElement("Frame", {
						AnchorPoint = Vector2.new(0.5, 0),
						BackgroundTransparency = 1,
						Position = UDim2.fromScale(0.5, 0),
						Size = UDim2.fromScale(1, 0.25),
						ZIndex = 2,
						ClipsDescendants = false,
					}, {
						BackgroundTexture = Roact.createElement("Frame", {
							BackgroundTransparency = 1,
							Size = UDim2.fromScale(1, 1),
							ClipsDescendants = true,
						}, BackgroundTextures),

						ButtonHolder = Roact.createElement("Frame", {
							AnchorPoint = Vector2.new(0, 1),
							BackgroundTransparency = 1,
							Position = UDim2.fromScale(0, 1),
							Size = UDim2.fromScale(1, 0.3),
							ZIndex = 5,
						}, {
							UIGridLayout = Roact.createElement("UIGridLayout", {
								CellPadding = UDim2.new(),
								CellSize = UDim2.fromScale(0.2, 1),
								SortOrder = Enum.SortOrder.LayoutOrder,
								VerticalAlignment = Enum.VerticalAlignment.Center,
							}),

							GamePassesButton = Roact.createElement("TextButton", {
								BackgroundTransparency = 1,
								ZIndex = 5,
								Text = "",
								TextTransparency = 1,
								LayoutOrder = 0,
							}, {
								ButtonText = Roact.createElement("TextLabel", {
									AnchorPoint = Vector2.new(0.5, 0.5),
									BackgroundTransparency = 1,
									Position = UDim2.fromScale(0.5, 0.5),
									Size = UDim2.fromScale(0.8, 0.8),
									ZIndex = 6,
									Font = self.state.SelectedButton == 0 and Enum.Font.SourceSansSemibold or Enum.Font.SourceSansLight,
									Text = "GamePasses",
									TextColor3 = Color3.new(1, 1, 1),
									TextScaled = true,
								}),
							}),

							TeleportButton = Roact.createElement("TextButton", {
								BackgroundTransparency = 1,
								ZIndex = 5,
								Text = "",
								TextTransparency = 1,
								LayoutOrder = 1,
							}, {
								ButtonText = Roact.createElement("TextLabel", {
									AnchorPoint = Vector2.new(0.5, 0.5),
									BackgroundTransparency = 1,
									Position = UDim2.fromScale(0.5, 0.5),
									Size = UDim2.fromScale(0.8, 0.8),
									ZIndex = 6,
									Font = (self.state.SelectedButton == 1 or self.state.SelectedButton == 2) and Enum.Font.SourceSansSemibold or Enum.Font.SourceSansLight,
									Text = "Teleport",
									TextColor3 = Color3.new(1, 1, 1),
									TextScaled = true,
								}),
							}),

							SettingsButton = Roact.createElement("TextButton", {
								BackgroundTransparency = 1,
								ZIndex = 5,
								Text = "",
								TextTransparency = 1,
								LayoutOrder = 2,
							}, {
								ButtonText = Roact.createElement("TextLabel", {
									AnchorPoint = Vector2.new(0.5, 0.5),
									BackgroundTransparency = 1,
									Position = UDim2.fromScale(0.5, 0.5),
									Size = UDim2.fromScale(0.8, 0.8),
									ZIndex = 6,
									Font = self.state.SelectedButton == 3 and Enum.Font.SourceSansSemibold or Enum.Font.SourceSansLight,
									Text = "Settings",
									TextColor3 = Color3.new(1, 1, 1),
									TextScaled = true,
								}),
							}),

							ShopButton = Roact.createElement("TextButton", {
								BackgroundTransparency = 1,
								ZIndex = 5,
								Text = "",
								TextTransparency = 1,
								LayoutOrder = 3,
							}, {
								ButtonText = Roact.createElement("TextLabel", {
									AnchorPoint = Vector2.new(0.5, 0.5),
									BackgroundTransparency = 1,
									Position = UDim2.fromScale(0.5, 0.5),
									Size = UDim2.fromScale(0.8, 0.8),
									ZIndex = 6,
									Font = self.state.SelectedButton == 4 and Enum.Font.SourceSansSemibold or Enum.Font.SourceSansLight,
									Text = "Shop",
									TextColor3 = Color3.new(1, 1, 1),
									TextScaled = true,
								}),
							}),

							MenuButton = Roact.createElement("TextButton", {
								BackgroundTransparency = 1,
								ZIndex = 5,
								Text = "",
								TextTransparency = 1,
								LayoutOrder = 4,
							}, {
								ButtonText = Roact.createElement("TextLabel", {
									AnchorPoint = Vector2.new(0.5, 0.5),
									BackgroundTransparency = 1,
									Position = UDim2.fromScale(0.5, 0.5),
									Size = UDim2.fromScale(0.8, 0.8),
									ZIndex = 6,
									Font = self.state.SelectedButton == 5 and Enum.Font.SourceSansSemibold or Enum.Font.SourceSansLight,
									Text = "Menu",
									TextColor3 = Color3.new(1, 1, 1),
									TextScaled = true,
								}),
							}),
						}),

						TopTitle = Roact.createElement("TextLabel", {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							Position = UDim2.fromScale(0.5, 0.35),
							Size = UDim2.fromScale(0.8, 0.35),
							ZIndex = 5,
							Font = Enum.Font.GothamBlack,
							Text = "Summit Menu",
							TextColor3 = Color3.new(1, 1, 1),
							TextScaled = true,
						}),

						CloseButton = Roact.createElement("TextButton", {
							AnchorPoint = Vector2.new(1, 0),
							BackgroundTransparency = 1,
							Position = UDim2.new(1, -5, 0, 5),
							Size = UDim2.fromScale(0.2, 0.2),
							ZIndex = 11,
							Font = Enum.Font.GothamBlack,
							Text = "—",
							TextColor3 = Color3.new(1, 1, 1),
							TextScaled = true,
							ClipsDescendants = true,
						}, {
							UIAspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint"),
							ToggleButton = Roact.createElement(RoactMaterial.TransparentButton, {
								OnClicked = function()
									self:setState({
										Visible = false,
										TeleportVisible = false,
									})

									self.positionMotor:setGoal(Otter.spring(-1.5, {
										frequency = 6,
									}))
								end,
							}),
						}),
					}),

					BottomFrame = Roact.createElement("Frame", {
						AnchorPoint = Vector2.new(0, 1),
						BackgroundTransparency = 1,
						Position = UDim2.fromScale(0, 1),
						Size = UDim2.fromScale(1, 0.75),
						ZIndex = 2,
						ClipsDescendants = true,
					}, {
						UIPageLayout = Roact.createElement("UIPageLayout", {
							Circular = true,
							EasingStyle = Enum.EasingStyle.Circular,
							TweenTime = 0.25,
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							SortOrder = Enum.SortOrder.LayoutOrder,
							VerticalAlignment = Enum.VerticalAlignment.Center,
							GamepadInputEnabled = false,
							ScrollWheelInputEnabled = false,
							TouchInputEnabled = false,
							[Roact.Ref] = self.layoutRef,
						}),

						GamePasses = Roact.createElement("Frame", {
							BackgroundColor3 = Color3.fromRGB(18, 18, 18),
							Size = UDim2.fromScale(1, 1),
							ZIndex = 3,
						}, {
							UIPadding = Roact.createElement("UIPadding", {
								PaddingBottom = UDim.new(0.005, 0),
								PaddingLeft = UDim.new(0.005, 0),
								PaddingRight = UDim.new(0.005, 0),
								PaddingTop = UDim.new(0.005, 0),
							}),

							ShopObjects = Roact.createElement("ScrollingFrame", {
								BackgroundTransparency = 1,
								Size = UDim2.fromScale(1, 1),
								ZIndex = 4,
								BottomImage = "",
								CanvasSize = UDim2.fromScale(0, 6),
								ScrollBarImageColor3 = Color3.fromRGB(147, 148, 149),
								ScrollBarThickness = 6,
								TopImage = "",
							}, {
								UIPadding = Roact.createElement("UIPadding", {
									PaddingBottom = UDim.new(0.005, 0),
									PaddingLeft = UDim.new(0.005, 0),
									PaddingRight = UDim.new(0.005, 0),
									PaddingTop = UDim.new(0.005, 0),
								}),

								UIGridLayout = Roact.createElement("UIGridLayout", {
									CellSize = UDim2.fromScale(0.225, 0.1),
									FillDirectionMaxCells = 4,
									HorizontalAlignment = Enum.HorizontalAlignment.Center,
									SortOrder = Enum.SortOrder.LayoutOrder,
								}),

								Suite = Roact.createElement(ShopEntry, {
									Theme = self.props.Theme,
								}),

								SeniorReceptionist = Roact.createElement(ShopEntry, {
									LayoutOrder = 1,
									EntryName = "SeniorReceptionist",
									TopText = "Junior Receptionist",
									AssetId = 6277118,
									Theme = self.props.Theme,
								}),

								HeadOfStaff = Roact.createElement(ShopEntry, {
									LayoutOrder = 2,
									EntryName = "HeadOfStaff",
									TopText = "Supervisor",
									AssetId = 6277172,
									Theme = self.props.Theme,
								}),

								Management = Roact.createElement(ShopEntry, {
									LayoutOrder = 3,
									EntryName = "Management",
									TopText = "Assistant Manager",
									AssetId = 6277175,
									Theme = self.props.Theme,
								}),

								SeniorManagement = Roact.createElement(ShopEntry, {
									LayoutOrder = 4,
									EntryName = "SeniorManagement",
									TopText = "Manager",
									AssetId = 6277185,
									Theme = self.props.Theme,
								}),

								ShiftManager = Roact.createElement(ShopEntry, {
									LayoutOrder = 5,
									EntryName = "ShiftManager",
									TopText = "Shift Manager",
									AssetId = 6277195,
									Theme = self.props.Theme,
								}),

								HeadManagement = Roact.createElement(ShopEntry, {
									LayoutOrder = 6,
									EntryName = "HeadManagement",
									TopText = "Managing Director",
									AssetId = 6277256,
									Theme = self.props.Theme,
								}),

								BoardOfDirectors = Roact.createElement(ShopEntry, {
									LayoutOrder = 7,
									EntryName = "BoardOfDirectors",
									TopText = "Board of Directors",
									AssetId = 6277259,
									Theme = self.props.Theme,
								}),

								HumanResources = Roact.createElement(ShopEntry, {
									LayoutOrder = 8,
									EntryName = "HumanResources",
									TopText = "Head Of Staff",
									AssetId = 6277263,
									Theme = self.props.Theme,
								}),

								Premium = Roact.createElement(ShopEntry, {
									LayoutOrder = 9,
									EntryName = "Premium",
									TopText = "Summit Plus",
									AssetId = 6547079,
									Theme = self.props.Theme,
								}),

								AdministrationTeam = Roact.createElement(ShopEntry, {
									LayoutOrder = 10,
									EntryName = "AdministrationTeam",
									TopText = "Administration",
									BottomText = "Team",
									AssetId = 6656698,
									Theme = self.props.Theme,
								}),

								Penthouse = Roact.createElement(ShopEntry, {
									LayoutOrder = 11,
									EntryName = "Penthouse",
									TopText = "Penthouse",
									AssetId = 7118486,
									Theme = self.props.Theme,
								}),

								RainbowOverhead = Roact.createElement(ShopEntry, {
									LayoutOrder = 12,
									EntryName = "RainbowOverhead",
									TopText = "Rainbow Overhead",
									AssetId = 7415571,
									Theme = self.props.Theme,
								}),

								DoubleSpace = Roact.createElement(ShopEntry, {
									LayoutOrder = 13,
									EntryName = "DoubleSpace",
									TopText = "Double Vacuum",
									BottomText = "Space",
									AssetId = 7606431,
									Theme = self.props.Theme,
								}),

								-- Dev Products:
								Cash10 = Roact.createElement(ShopEntry, {
									LayoutOrder = 14,
									EntryName = "Cash10",
									TopText = "10 Cash",
									AssetId = 907906612,
									InfoType = Enum.InfoType.Product,
									Theme = self.props.Theme,
								}),

								Cash25 = Roact.createElement(ShopEntry, {
									LayoutOrder = 15,
									EntryName = "Cash25",
									TopText = "25 Cash",
									AssetId = 907918575,
									InfoType = Enum.InfoType.Product,
									Theme = self.props.Theme,
								}),

								Cash50 = Roact.createElement(ShopEntry, {
									LayoutOrder = 16,
									EntryName = "Cash50",
									TopText = "50 Cash",
									AssetId = 907918977,
									InfoType = Enum.InfoType.Product,
									Theme = self.props.Theme,
								}),

								Cash100 = Roact.createElement(ShopEntry, {
									LayoutOrder = 17,
									EntryName = "Cash100",
									TopText = "100 Cash",
									AssetId = 907921466,
									InfoType = Enum.InfoType.Product,
									Theme = self.props.Theme,
								}),

								Cash250 = Roact.createElement(ShopEntry, {
									LayoutOrder = 18,
									EntryName = "Cash250",
									TopText = "250 Cash",
									AssetId = 907922516,
									InfoType = Enum.InfoType.Product,
									Theme = self.props.Theme,
								}),

								Cash500 = Roact.createElement(ShopEntry, {
									LayoutOrder = 19,
									EntryName = "Cash500",
									TopText = "500 Cash",
									AssetId = 907923238,
									InfoType = Enum.InfoType.Product,
									Theme = self.props.Theme,
								}),

								Cash1000 = Roact.createElement(ShopEntry, {
									LayoutOrder = 19,
									EntryName = "Cash1000",
									TopText = "1000 Cash",
									AssetId = 907617230,
									InfoType = Enum.InfoType.Product,
									Theme = self.props.Theme,
								}),
							}),
						}),

						Teleport = Roact.createElement("Frame", {
							BackgroundColor3 = Color3.fromRGB(18, 18, 18),
							Size = UDim2.fromScale(1, 1),
							ZIndex = 3,
							LayoutOrder = 1,
						}, {
							UIPadding = Roact.createElement("UIPadding", {
								PaddingBottom = UDim.new(0.005, 0),
								PaddingLeft = UDim.new(0.005, 0),
								PaddingRight = UDim.new(0.005, 0),
								PaddingTop = UDim.new(0.005, 0),
							}),

							TeleportObjects = Roact.createElement("ScrollingFrame", {
								BackgroundTransparency = 1,
								Size = UDim2.fromScale(1, 1),
								ZIndex = 4,
								BottomImage = "",
								CanvasSize = UDim2.fromScale(0, 6),
								ScrollBarImageColor3 = Color3.fromRGB(147, 148, 149),
								ScrollBarThickness = 6,
								TopImage = "",
							}, {
								UIPadding = Roact.createElement("UIPadding", {
									PaddingBottom = UDim.new(0.005, 0),
									PaddingLeft = UDim.new(0.005, 0),
									PaddingRight = UDim.new(0.005, 0),
									PaddingTop = UDim.new(0.005, 0),
								}),

								UIGridLayout = Roact.createElement("UIGridLayout", {
									CellSize = UDim2.fromScale(0.225, 0.1),
									FillDirectionMaxCells = 4,
									HorizontalAlignment = Enum.HorizontalAlignment.Center,
									SortOrder = Enum.SortOrder.LayoutOrder,
								}),

								Lobby = Roact.createElement(TeleportEntry, {
									MoveLocation = CFrame.new(-146.1, 17.2, -8.7),
									ViewportLocation = CFrame.new(-182.76808166504, 12.46582698822, -9.9478778839111, 0.0060475533828139, 0.010516877286136, 0.99992644786835, 7.2759567468217e-12, 0.99994480609894, -0.010517069138587, -0.9999817609787, 6.3602543377783e-05, 0.0060472195036709),
									ViewportModel = ReplicatedStorage.WorldView,
									Theme = self.props.Theme,
									Visible = self.state.Visible and self.state.SelectedButton == 1,
								}),

								Floor1 = Roact.createElement(TeleportEntry, {
									MoveLocation = CFrame.new(-236.55, 38.85, -12.1),
									ViewportLocation = CFrame.new(-212.83647155762, 44.97891998291, 5.2349424362183, 0.94239383935928, -0.021217940375209, 0.33383178710938, -0, 0.99798625707626, 0.063430786132813, -0.3345054090023, -0.059776782989502, 0.94049608707428),
									ViewportModel = ReplicatedStorage.WorldView,
									Theme = self.props.Theme,
									LayoutOrder = 1,
									EntryName = "Floor1",
									TopText = "Floor One",
									BottomText = "",
									Visible = self.state.Visible and self.state.SelectedButton == 1,
								}),

								Floor2 = Roact.createElement(TeleportEntry, {
									MoveLocation = CFrame.new(-236.55, 69.25, -12.1),
									ViewportLocation = CFrame.new(-213.42532348633, 72.673027038574, 3.5761325359344, 0.94239383935928, -0.021217940375209, 0.33383178710938, -0, 0.99798625707626, 0.063430786132813, -0.3345054090023, -0.059776782989502, 0.94049608707428),
									ViewportModel = ReplicatedStorage.WorldView,
									Theme = self.props.Theme,
									LayoutOrder = 2,
									EntryName = "Floor2",
									TopText = "Floor Two",
									BottomText = "",
									Visible = self.state.Visible and self.state.SelectedButton == 1,
								}),

								Floor3 = Roact.createElement(TeleportEntry, {
									MoveLocation = CFrame.new(-236.55, 99.65, -12.1),
									ViewportLocation = CFrame.new(-213.92279052734, 104.12355804443, 2.1826419830322, 0.93666291236877, -0.019286938011646, 0.34970092773438, 1.862645149231e-09, 0.9984827041626, 0.055068969726563, -0.35023239254951, -0.051581062376499, 0.93524158000946),
									ViewportModel = ReplicatedStorage.WorldView,
									Theme = self.props.Theme,
									LayoutOrder = 3,
									EntryName = "Floor3",
									TopText = "Floor Three",
									BottomText = "",
									Visible = self.state.Visible and self.state.SelectedButton == 1,
								}),

								Floor4 = Roact.createElement(TeleportEntry, {
									MoveLocation = CFrame.new(-236.55, 130.45, -12.1),
									ViewportLocation = CFrame.new(-214.47247314453, 132.58030700684, 0.71258163452148, 0.93666291236877, -0.019286938011646, 0.34970092773438, 1.862645149231e-09, 0.9984827041626, 0.055068969726563, -0.35023239254951, -0.051581062376499, 0.93524158000946),
									ViewportModel = ReplicatedStorage.WorldView,
									Theme = self.props.Theme,
									LayoutOrder = 4,
									EntryName = "Floor4",
									TopText = "Floor Four",
									BottomText = "",
									Visible = self.state.Visible and self.state.SelectedButton == 1,
								}),

								Floor5 = Roact.createElement(TeleportEntry, {
									MoveLocation = CFrame.new(-236.55, 160.65, -12.1),
									ViewportLocation = CFrame.new(-214.47918701172, 163.36418151855, 0.54024243354797, 0.92597675323486, -0.020395439118147, 0.37702941894531, -0, 0.99854022264481, 0.05401611328125, -0.3775806427002, -0.050017666071653, 0.92462491989136),
									ViewportModel = ReplicatedStorage.WorldView,
									Theme = self.props.Theme,
									LayoutOrder = 5,
									EntryName = "Floor5",
									TopText = "Floor Five",
									BottomText = "",
									Visible = self.state.Visible and self.state.SelectedButton == 1,
								}),

								Floor5 = Roact.createElement(TeleportEntry, {
									MoveLocation = CFrame.new(-236.55, 160.65, -12.1),
									ViewportLocation = CFrame.new(-214.47918701172, 163.36418151855, 0.54024243354797, 0.92597675323486, -0.020395439118147, 0.37702941894531, -0, 0.99854022264481, 0.05401611328125, -0.3775806427002, -0.050017666071653, 0.92462491989136),
									ViewportModel = ReplicatedStorage.WorldView,
									Theme = self.props.Theme,
									LayoutOrder = 5,
									EntryName = "Floor5",
									TopText = "Floor Five",
									BottomText = "",
									Visible = self.state.Visible and self.state.SelectedButton == 1,
								}),

								Floor6 = Roact.createElement(TeleportEntry, {
									MoveLocation = CFrame.new(-243.6, 191.7, 93.7),
									ViewportLocation = CFrame.new(-237.06520080566, 197.6907043457, 77.330291748047, 0.99658536911011, 0.00074460118776187, 0.082565397024155, -5.8207653974574e-11, 0.99995946884155, -0.0090179536491632, -0.082568749785423, 0.0089871603995562, 0.99654495716095),
									ViewportModel = ReplicatedStorage.WorldView,
									Theme = self.props.Theme,
									LayoutOrder = 6,
									EntryName = "Floor6",
									TopText = "Floor Six",
									BottomText = "",
									Visible = self.state.Visible and self.state.SelectedButton == 1,
								}),

								Rooftop = Roact.createElement(TeleportEntry, {
									MoveLocation = CFrame.new(-173.95, 221.75, -12.7),
									ViewportLocation = CFrame.new(-187.57377624512, 229.7780456543, -45.418521881104, -0.44808197021484, -0.14218257367611, 0.88261348009109, -7.4505805969238e-09, 0.98727172613144, 0.15904223918915, -0.89399248361588, 0.071263954043388, -0.44237866997719),
									ViewportModel = ReplicatedStorage.WorldView,
									Theme = self.props.Theme,
									LayoutOrder = 7,
									EntryName = "Rooftop",
									TopText = "Rooftop",
									BottomText = "",
									Visible = self.state.Visible and self.state.SelectedButton == 1,
								}),
							}),
						}),

						TeleportActivities = Roact.createElement("Frame", {
							BackgroundColor3 = Color3.fromRGB(18, 18, 18),
							Size = UDim2.fromScale(1, 1),
							ZIndex = 3,
							LayoutOrder = 2,
						}, {
							UIPadding = Roact.createElement("UIPadding", {
								PaddingBottom = UDim.new(0.005, 0),
								PaddingLeft = UDim.new(0.005, 0),
								PaddingRight = UDim.new(0.005, 0),
								PaddingTop = UDim.new(0.005, 0),
							}),

							TeleportObjects = Roact.createElement("ScrollingFrame", {
								BackgroundTransparency = 1,
								Size = UDim2.fromScale(1, 1),
								ZIndex = 4,
								BottomImage = "",
								CanvasSize = UDim2.fromScale(0, 6),
								ScrollBarImageColor3 = Color3.fromRGB(147, 148, 149),
								ScrollBarThickness = 6,
								TopImage = "",
							}, {
								UIPadding = Roact.createElement("UIPadding", {
									PaddingBottom = UDim.new(0.005, 0),
									PaddingLeft = UDim.new(0.005, 0),
									PaddingRight = UDim.new(0.005, 0),
									PaddingTop = UDim.new(0.005, 0),
								}),

								UIGridLayout = Roact.createElement("UIGridLayout", {
									CellSize = UDim2.fromScale(0.225, 0.1),
									FillDirectionMaxCells = 4,
									HorizontalAlignment = Enum.HorizontalAlignment.Center,
									SortOrder = Enum.SortOrder.LayoutOrder,
								}),

								Lobby = Roact.createElement(TeleportEntry, {
									MoveLocation = CFrame.new(-146.1, 17.2, -8.7),
									ViewportLocation = CFrame.new(-182.76808166504, 12.46582698822, -9.9478778839111, 0.0060475533828139, 0.010516877286136, 0.99992644786835, 7.2759567468217e-12, 0.99994480609894, -0.010517069138587, -0.9999817609787, 6.3602543377783e-05, 0.0060472195036709),
									ViewportModel = ReplicatedStorage.WorldView,
									Theme = self.props.Theme,
									Visible = self.state.Visible and self.state.SelectedButton == 2,
								}),

								Camping = Roact.createElement(TeleportEntry, {
									MoveLocation = CFrame.new(-807.8, 7.4, -13.4),
									ViewportLocation = CFrame.new(-839.21948242188, 14.8707447052, 10.533660888672, 0.41510027647018, -0.20097042620182, 0.88730078935623, -0, 0.97529619932175, 0.22090108692646, -0.90977561473846, -0.091696105897427, 0.40484577417374),
									ViewportModel = ReplicatedStorage.WorldView,
									Theme = self.props.Theme,
									LayoutOrder = 1,
									EntryName = "Camping",
									TopText = "Camping",
									BottomText = "",
									Visible = self.state.Visible and self.state.SelectedButton == 2,
								}),

								Beach = Roact.createElement(TeleportEntry, {
									MoveLocation = CFrame.new(-51.368, 3.45, -237.873),
									ViewportLocation = CFrame.new(-17.093915939331, 20.511636734009, -306.22308349609, -0.85429686307907, -0.19157093763351, 0.48319506645203, -0, 0.92960488796234, 0.36855775117874, -0.51978540420532, 0.31485772132874, -0.79415857791901),
									ViewportModel = ReplicatedStorage.WorldView,
									Theme = self.props.Theme,
									LayoutOrder = 2,
									EntryName = "Beach",
									TopText = "Beach",
									BottomText = "",
									Visible = self.state.Visible and self.state.SelectedButton == 2,
								}),

								Cabanas = Roact.createElement(TeleportEntry, {
									MoveLocation = CFrame.new(-568.168, 5.65, -289.673),
									ViewportLocation = CFrame.new(-549.28851318359, 17.365652084351, -326.85369873047, -0.74079555273056, -0.064968556165695, 0.66858142614365, 3.7252902984619e-09, 0.99531185626984, 0.096718169748783, -0.67173063755035, 0.071648389101028, -0.73732250928879),
									ViewportModel = ReplicatedStorage.WorldView,
									Theme = self.props.Theme,
									LayoutOrder = 3,
									EntryName = "Cabanas",
									TopText = "Cabanas",
									BottomText = "",
									Visible = self.state.Visible and self.state.SelectedButton == 2,
								}),
							}),
						}),

						Settings = Roact.createElement("Frame", {
							BackgroundColor3 = Color3.fromRGB(18, 18, 18),
							Size = UDim2.fromScale(1, 1),
							ZIndex = 3,
							LayoutOrder = 3,
						}, {
							UIPadding = Roact.createElement("UIPadding", {
								PaddingBottom = UDim.new(0.005, 0),
								PaddingLeft = UDim.new(0.005, 0),
								PaddingRight = UDim.new(0.005, 0),
								PaddingTop = UDim.new(0.005, 0),
							}),

							SettingsObjects = Roact.createElement("ScrollingFrame", {
								BackgroundTransparency = 1,
								Size = UDim2.fromScale(1, 1),
								ZIndex = 4,
								BottomImage = "",
								CanvasSize = UDim2.fromScale(0, 3),
								ScrollBarImageColor3 = Color3.fromRGB(147, 148, 149),
								ScrollBarThickness = 6,
								TopImage = "",
							}, {
								-- TODO: UPDATE THIS
								UIPadding = Roact.createElement("UIPadding", {
									PaddingBottom = UDim.new(0.005, 0),
									PaddingLeft = UDim.new(0.005, 0),
									PaddingRight = UDim.new(0.005, 0),
									PaddingTop = UDim.new(0.005, 0),
								}),

								UIGridLayout = Roact.createElement("UIGridLayout", {
									CellSize = UDim2.fromScale(1, 0.05),
									FillDirectionMaxCells = 4,
									HorizontalAlignment = Enum.HorizontalAlignment.Center,
									SortOrder = Enum.SortOrder.LayoutOrder,
								}),

								Shadows = Roact.createElement(SettingsEntry, {
									LayoutOrder = 0,
									EntryName = "Shadows",
									TopText = "Shadows",
									BottomText = "Disables or enables shadows in the game.",
									Theme = self.props.Theme,
									Checked = self.state.Settings.ShadowsEnabled,
									OnChecked = function(Value)
										if not self.state.HasRan.Shadows then
											self:setState(function(previousState)
												previousState.HasRan.Shadows = true
												return previousState
											end)
										else
											self.promiseInvoke(Constants.SET_SETTING, "ShadowsEnabled", Value)
										end

										self:setState(function(previousState)
											previousState.Settings.ShadowsEnabled = Value
											return previousState
										end)

										coroutine.wrap(function()
											for _, BasePart in ipairs(CollectionService:GetTagged("CastShadow")) do
												BasePart.CastShadow = Value
											end
										end)()
									end,
								}),

								Rain = Roact.createElement(SettingsEntry, {
									LayoutOrder = 1,
									EntryName = "Rain",
									TopText = "Rain",
									BottomText = "Disables or enables rainy weather in the game.",
									Theme = self.props.Theme,
									Checked = self.state.Settings.RainEnabled,
									OnChecked = function(Value)
										if not self.state.HasRan.Rain then
											self:setState(function(previousState)
												previousState.HasRan.Rain = true
												return previousState
											end)
										else
											self.promiseInvoke(Constants.SET_SETTING, "RainEnabled", Value)
										end

										self:setState(function(previousState)
											previousState.Settings.RainEnabled = Value
											return previousState
										end)
									end,
								}),

								Music = Roact.createElement(SettingsEntry, {
									LayoutOrder = 2,
									EntryName = "Music",
									TopText = "Music",
									BottomText = "Disables or enables the music in-game.",
									Theme = self.props.Theme,
									Checked = self.state.Settings.MusicEnabled,
									OnChecked = function(Value)
										if not self.state.HasRan.Music then
											self:setState(function(previousState)
												previousState.HasRan.Music = true
												return previousState
											end)
										else
											self.promiseInvoke(Constants.SET_SETTING, "MusicEnabled", Value)
										end

										self:setState(function(previousState)
											previousState.Settings.MusicEnabled = Value
											return previousState
										end)
									end,
								}),

								Pets = Roact.createElement(SettingsEntry, {
									LayoutOrder = 3,
									EntryName = "Pets",
									TopText = "Pets",
									BottomText = "Disables or enables the pets in-game.",
									Theme = self.props.Theme,
									Checked = self.state.Settings.PetsEnabled,
									OnChecked = function(Value)
										if not self.state.HasRan.Pets then
											self:setState(function(previousState)
												previousState.HasRan.Pets = true
												return previousState
											end)
										else
											self.promiseInvoke(Constants.SET_SETTING, "PetsEnabled", Value)
										end

										self:setState(function(previousState)
											previousState.Settings.PetsEnabled = Value
											return previousState
										end)
									end,
								}),

								RemovePet = Roact.createElement(SettingsEntry, {
									LayoutOrder = 4,
									EntryName = "RemovePet",
									TopText = "Remove Pet",
									BottomText = "Removes your current pet if you have one.",
									Theme = self.props.Theme,
									IsButton = true,
									OnClicked = function()
										self.gameEvent:FireServer(Constants.REMOVE_PET)
										self:setState({
											EquippedPet = "",
										})
									end,
								}),
							}),
						}),

						Shop = Roact.createElement("Frame", {
							BackgroundColor3 = Color3.fromRGB(18, 18, 18),
							Size = UDim2.fromScale(1, 1),
							ZIndex = 4,
							LayoutOrder = 4,
						}, {
							UIPadding = Roact.createElement("UIPadding", {
								PaddingBottom = UDim.new(0.005, 0),
								PaddingLeft = UDim.new(0.005, 0),
								PaddingRight = UDim.new(0.005, 0),
								PaddingTop = UDim.new(0.005, 0),
							}),

							ShopObjects = Roact.createElement("ScrollingFrame", {
								BackgroundTransparency = 1,
								Size = UDim2.fromScale(1, 1),
								ZIndex = 4,
								BottomImage = "",
								CanvasSize = UDim2.fromScale(0, 6),
								ScrollBarImageColor3 = Color3.fromRGB(147, 148, 149),
								ScrollBarThickness = 6,
								TopImage = "",
							}, {
								UIPadding = Roact.createElement("UIPadding", {
									PaddingBottom = UDim.new(0.005, 0),
									PaddingLeft = UDim.new(0.005, 0),
									PaddingRight = UDim.new(0.005, 0),
									PaddingTop = UDim.new(0.005, 0),
								}),

								UIGridLayout = Roact.createElement("UIGridLayout", {
									CellSize = UDim2.fromScale(0.225, 0.1),
									FillDirectionMaxCells = 4,
									HorizontalAlignment = Enum.HorizontalAlignment.Center,
									SortOrder = Enum.SortOrder.LayoutOrder,
								}),

								CatPet = Roact.createElement(PetEntry, {
									LayoutOrder = 0,
									EntryName = "CatPet",
									TopText = "Cat Pet",
									BottomText = "",
									ItemPrice = 4000,
									Visible = self.state.Visible and self.state.SelectedButton == 4,
									Theme = self.props.Theme,

									HasPurchased = false,
									IsEquipped = self.state.EquippedPet == "CatPet",
									CannotBePurchased = false,
									IsLimited = false,
									ViewportModel = ReplicatedStorage.PetModels.CatPet,
									OnSelected = function(PetName)
										self:setState({
											EquippedPet = PetName,
										})
									end,
								}),
							}),
						}),

						Menus = Roact.createElement("Frame", {
							BackgroundColor3 = Color3.fromRGB(18, 18, 18),
							Size = UDim2.fromScale(1, 1),
							ZIndex = 4,
							LayoutOrder = 5,
						}, {
							PseudoText = Roact.createElement("TextLabel", {
								Text = "Menus",
								ZIndex = 5,
								BackgroundTransparency = 1,
								Font = Enum.Font.SourceSansSemibold,
								TextColor3 = Color3.new(1, 1, 1),
								Size = UDim2.fromScale(1, 1),
							}),
						}),
					}),
				}),
			}),
		}),
	})
end

return SummitMenu