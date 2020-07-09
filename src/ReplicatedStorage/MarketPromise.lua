local MarketplaceService = game:GetService("MarketplaceService")
local Promise = require(script.Parent.Promise)

local MarketPromise = {}

function MarketPromise.PromiseProductInfo(AssetId, InfoType)
	return Promise.Defer(function(Resolve, Reject)
		local Success, ProductInfo = pcall(MarketplaceService.GetProductInfo, MarketplaceService, AssetId, InfoType);
		(Success and Resolve or Reject)(ProductInfo)
	end)
end

return MarketPromise