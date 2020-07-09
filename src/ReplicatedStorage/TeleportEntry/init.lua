local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local CharacterUtils = require(script.Parent.CharacterUtils) -- From Quenty's
local Roact = require(script.Parent.Roact)
local RoactMaterial = require(script.Parent.RoactMaterial)
local PromiseCloneRemove = require(script.Parent.PromiseCloneRemove)
local t = require(script.Parent.t)

local TeleportEntry = Roact.PureComponent:extend("TeleportEntry")
TeleportEntry.defaultProps = {
	LayoutOrder = 0,
	EntryName = "Lobby",
	TopText = "Lobby",
	BottomText = "",
	MoveLocation = CFrame.new(0, 1, 0),
	ViewportLocation = CFrame.new(-18.400291442871, 23.821403503418, -25.157207489014, -0.82283520698547, 0.2685652077198, -0.50081425905228, -1.4901159417491e-08, 0.88128077983856, 0.47259312868118, 0.56827998161316, 0.38886627554893, -0.72514891624451),
	Theme = RoactMaterial.Themes.Dark,
	Visible = true,
}

TeleportEntry.validateProps = t.interface({
	LayoutOrder = t.optional(t.integer),
	EntryName = t.optional(t.string),
	TopText = t.optional(t.string),
	BottomText = t.optional(t.string),
	MoveLocation = t.optional(t.CFrame),
	ViewportLocation = t.optional(t.CFrame),
	ViewportModel = t.instanceIsA("Model"),
	Visible = t.optional(t.boolean),
})

function TeleportEntry:init()
	self.cameraRef = Roact.createRef()
	self.viewportRef = Roact.createRef()
end

local function GetCharacters()
	local Array = {}
	local Length = 0
	for _, Player: Player in ipairs(Players:GetPlayers()) do
		if Player.Character then
			Length += 1
			Array[Length] = Player.Character
		end
	end

	return Array
end

function TeleportEntry:didMount()
	self:setState({
		CurrentCamera = self.cameraRef,
	})

	local Params = RaycastParams.new()
	Params.FilterDescendantsInstances = GetCharacters()
	Params.FilterType = Enum.RaycastFilterType.Blacklist
	Params.IgnoreWater = true

	local ShouldAdd = Workspace:Raycast(self.props.ViewportLocation.Position, self.props.ViewportLocation.UpVector * 50, Params)

	PromiseCloneRemove(
		self.props.ViewportModel,
		self.props.ViewportLocation,
		130, 120
	):AndThen(ShouldAdd == nil and function(Model: Model)
		local ViewportFrame: ViewportFrame = self.viewportRef:getValue()
		if ViewportFrame then
			local FakeBox: Part = Instance.new("Part")
			FakeBox.BrickColor = BrickColor.new("Electric blue")
			FakeBox.CFrame = self.props.ViewportLocation
			FakeBox.Size = Vector3.new(0.05, 0.05, 0.05)
			FakeBox.Anchored = true

			local InverseMesh: SpecialMesh = Instance.new("SpecialMesh")
			InverseMesh.MeshId = "rbxassetid://1185246"
			InverseMesh.MeshType = Enum.MeshType.FileMesh
			InverseMesh.Scale = Vector3.new(-1500, -1500, -1500)
			InverseMesh.VertexColor = Vector3.new(1, 1, 0)
			InverseMesh.Parent = FakeBox

			FakeBox.Parent = Model
			Model.Parent = ViewportFrame
		end
	end or function(Model: Model)
		local ViewportFrame: ViewportFrame = self.viewportRef:getValue()
		if ViewportFrame then
			Model.Parent = ViewportFrame
		end
	end)
end

function TeleportEntry:render()
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
			Shadow = Roact.createElement(RoactMaterial.Shadow, {
				Elevation = 4,
			}),

			UIAspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint", {
				AspectRatio = 0.88,
			}),

			TeleportMain = Roact.createElement("ImageLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				ZIndex = 6,
				ClipsDescendants = true,
				Image = "rbxassetid://1934624205",
				ImageColor3 = Color3.fromRGB(30, 30, 30),
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(4, 4, 252, 252),
			}, {
				TeleportButton = Roact.createElement(RoactMaterial.TransparentButton, {
					ZIndex = 12,
					Size = UDim2.fromScale(1, 1),
					OnClicked = function()
						if not RunService:IsStudio() and Players.LocalPlayer and CharacterUtils.getAlivePlayerHumanoid(Players.LocalPlayer) then
							Players.LocalPlayer.Character:SetPrimaryPartCFrame(CFrame.new(self.props.ViewportLocation.Position))
						end
					end,
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

					LocationViewport = Roact.createElement("ViewportFrame", {
						Size = UDim2.fromScale(0.95, 0.95),
						BackgroundTransparency = 0,
						ZIndex = 6,
						CurrentCamera = self.state.CurrentCamera,
						Ambient = Color3.fromRGB(194, 224, 255),
						LightColor = Color3.fromRGB(194, 224, 255),
						LightDirection = Vector3.new(0, 1, 0),
						Visible = self.props.Visible,

						[Roact.Ref] = self.viewportRef,
					}, {
						UIAspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint"),
						CurrentCamera = Roact.createElement("Camera", {
							[Roact.Ref] = self.cameraRef,
							CFrame = self.props.ViewportLocation,
						}),
					}),

					TeleportTitle = Roact.createElement("Frame", {
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

					Frame = Roact.createElement("Frame", {
						LayoutOrder = 2,
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(1, 0.096),
					}),
				}),
			}),
		}),
	})
end

return TeleportEntry