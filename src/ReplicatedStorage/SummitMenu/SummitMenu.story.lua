local Roact = require(script.Parent.Parent.Roact)
local SummitMenu = require(script.Parent)

return function(Target)
	local Tree = Roact.mount(Roact.createElement(SummitMenu), Target)
	return function()
		Roact.unmount(Tree)
	end
end