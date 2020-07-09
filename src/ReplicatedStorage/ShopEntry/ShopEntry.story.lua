local Roact = require(script.Parent.Parent.Roact)
local ShopEntry = require(script.Parent)

return function(Target)
	local Tree = Roact.mount(Roact.createElement(ShopEntry), Target)
	return function()
		Roact.unmount(Tree)
	end
end