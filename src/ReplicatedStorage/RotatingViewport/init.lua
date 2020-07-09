local RunService = game:GetService("RunService")

local EventConnection = require(script.Parent.EventConnection)
local Roact = require(script.Parent.Roact)
local t = require(script.Parent.t)

local RotatingViewport = Roact.Component:extend("RotatingViewport")
RotatingViewport.defaultProps = {
	AnchorPoint = Vector2.new(),
	Position = UDim2.new(),
	LayoutOrder = 0,
	Size = UDim2.fromScale(1, 1),
	ZIndex = 1,
	Visible = true,

	Ambient = Color3.fromRGB(194, 224, 255),
	LightColor = Color3.fromRGB(194, 224, 255),
	LightDirection = Vector3.new(0, 1, 0),

	AspectRatio = 1,
	FieldOfView = 5,
	IsRunning = false,
	CFrameOffset = CFrame.new(),
	DepthMultiplier = 1,
	RotationCFrame = CFrame.Angles(math.rad(-10), 0, 0),
	UpdateEvent = RunService.Heartbeat,
}

RotatingViewport.validateProps = t.interface({
	IsRunning = t.optional(t.boolean),
	CFrameOffset = t.optional(t.CFrame),
	RotationCFrame = t.optional(t.CFrame),
	DepthMultiplier = t.optional(t.number),
	AspectRatio = t.optional(t.number),

	ViewportModel = t.union(t.instanceIsA("Model"), t.instanceIsA("BasePart")),
})

local FAR_POSITION = Vector3.new(0, 10000, 0)

function RotatingViewport:init(props)
	self:setState({
		ViewportModel = props.ViewportModel,
		CFrame = props.CFrameOffset,
		Focus = props.CameraOffset,
	})

	self.cameraRef = Roact.createRef()
	self.viewportRef = Roact.createRef()

	self.updateCFrame = function()
		local currentProps = self.props
		if currentProps.IsRunning then
			local state = self.state
			local ViewportModel = state.ViewportModel

			if ViewportModel:IsA("Model") and state.CurrentCamera then
				local CurrentCamera = state.CurrentCamera:getValue()
				local BoundingCFrame, BoundingSize = ViewportModel:GetBoundingBox()
				local ModelCenter = BoundingCFrame.Position

				local MaxSize = math.max(BoundingSize.X, BoundingSize.Y, BoundingSize.Z)
				local DistanceBack = (MaxSize / math.tan(math.rad(CurrentCamera.FieldOfView))) * currentProps.DepthMultiplier
				local Center = CFrame.new(ModelCenter)

				self:setState({
					CFrame = Center * currentProps.CFrameOffset * CFrame.Angles(0, tick() % 6.2831853071796, 0) * currentProps.RotationCFrame * CFrame.new(0, 0, MaxSize / 2 + DistanceBack),
					Focus = Center,
				})
			end
		end
	end
end

function RotatingViewport:didMount()
	self:setState({
		CurrentCamera = self.cameraRef,
	})

	local ViewportModel = assert(self.props.ViewportModel, "No ViewportModel!"):Clone()
	if ViewportModel:IsA("BasePart") then
		local NewModel: Model = Instance.new("Model")
		NewModel.Name = "Model3D"
		ViewportModel.Parent = NewModel
		NewModel.PrimaryPart = ViewportModel

		ViewportModel = NewModel
	end

	local BasePrimaryPart: BasePart = ViewportModel.PrimaryPart
	if not BasePrimaryPart then
		ViewportModel.PrimaryPart = ViewportModel:FindFirstChildWhichIsA("BasePart", true)
	end

	if ViewportModel.PrimaryPart then
		local PrimaryPartCFrame: CFrame = ViewportModel:GetPrimaryPartCFrame()
		ViewportModel:SetPrimaryPartCFrame(CFrame.new(FAR_POSITION - PrimaryPartCFrame.Position) * PrimaryPartCFrame)
		ViewportModel.PrimaryPart = BasePrimaryPart
	end

	ViewportModel.Parent = self.viewportRef:getValue()
	self:setState({
		ViewportModel = ViewportModel,
	})
end

function RotatingViewport:render()
	return Roact.createElement("ViewportFrame", {
		AnchorPoint = self.props.AnchorPoint,
		Position = self.props.Position,
		LayoutOrder = self.props.LayoutOrder,
		Size = self.props.Size,
		BackgroundTransparency = 1,
		ZIndex = self.props.ZIndex,
		CurrentCamera = self.state.CurrentCamera,
		Ambient = self.props.Ambient,
		LightColor = self.props.LightColor,
		LightDirection = self.props.LightDirection,
		Visible = self.props.Visible,
		[Roact.Ref] = self.viewportRef,
	}, {
		UIAspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint", {
			AspectRatio = self.props.AspectRatio,
		}),

		CurrentCamera = Roact.createElement("Camera", {
			[Roact.Ref] = self.cameraRef,
			CFrame = self.state.CFrame,
			Focus = self.state.Focus,
			FieldOfView = self.props.FieldOfView,
		}),

		EventHandler = Roact.createElement(EventConnection, {
			Function = self.updateCFrame,
			Event = self.props.UpdateEvent,
		}),
	})
end

return RotatingViewport