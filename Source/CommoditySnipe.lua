local addonName, addon = ...

local mode = 0
-- mode 0: not intialised yet
-- mode 1: waiting for initial click
-- mode 2: has sent request for results, waiting for COMMODITY_SEARCH_RESULTS_UPDATED
-- mode 3: COMMODITY_SEARCH_RESULTS_UPDATED received, waiting for click
-- mode 4: has clicked, waiting for COMMODITY_PRICE_UPDATED
-- mode 5: COMMODITY_PRICE_UPDATED received, waiting for     COMMODITY_PURCHASE_FAILED or COMMODITY_PURCHASE_SUCCEEDED

local quantity = 1

local function debug(...)
    --print(...)
end

local btn = CommoditySnipeButton

btn:RegisterEvent("COMMODITY_PRICE_UPDATED")
btn:RegisterEvent("COMMODITY_SEARCH_RESULTS_UPDATED")
btn:RegisterEvent("COMMODITY_PURCHASE_FAILED")
btn:RegisterEvent("COMMODITY_PURCHASE_SUCCEEDED")
btn:SetScript("OnEvent", function(self, event, ...)
    local maxPrice = CommoditySnipeFlyoutFrame.MoneyInputFrame:GetAmount()
    if maxPrice == 0 then return end
    
    local itemID = AuctionHouseFrame.CommoditiesBuyFrame.BuyDisplay.ItemDisplay.item
    if not itemID then return end
    
    if event == "COMMODITY_PRICE_UPDATED" then
        if mode ~= 4 then return end
        local updatedUnitPrice, updatedTotalPrice = ...
        if updatedUnitPrice < maxPrice then
            if (updatedUnitPrice * quantity) == updatedTotalPrice then
                C_AuctionHouse.ConfirmCommoditiesPurchase(itemID, quantity)
            else
                debug(1, "uup * q ~= utp")
                mode = 1
                return
            end
        else
            mode = 1
            return
        end
        debug(5)
        mode = 5
    elseif event == "COMMODITY_SEARCH_RESULTS_UPDATED" then
        if mode ~= 2 then return end
        local resultItemID = ...
        if resultItemID ~= itemID then return end
        local info = C_AuctionHouse.GetCommoditySearchResultInfo(itemID, 1)
        if not info then return end
        quantity = info.quantity
        if info.unitPrice < maxPrice then
            debug(3, "up < mp")
            mode = 3
        else
            debug(1, "up > mp")
            mode = 1
        end
    elseif (event == "COMMODITY_PURCHASE_FAILED") or (event == "COMMODITY_PURCHASE_SUCCEEDED") then
        if mode ~= 5 then return end
        btn:SetAttribute("clickbutton", AuctionHouseFrame.CommoditiesBuyFrame.ItemList.RefreshFrame.RefreshButton)
        debug(1, "f/s", event)
        mode = 1
    end
end)

btn:HookScript("OnClick", function()
    local maxPrice = CommoditySnipeFlyoutFrame.MoneyInputFrame:GetAmount()
    if maxPrice == 0 then return end
    
    local itemID = AuctionHouseFrame.CommoditiesBuyFrame.BuyDisplay.ItemDisplay.item
    if not itemID then return end
    
    debug("current", mode)
    if mode == 0 then
        mode = 1
	elseif mode == 1 then
        C_AuctionHouse.RefreshCommoditySearchResults(itemID)
        debug(2)
        mode = 2
    elseif mode == 2 then
        return
    elseif mode == 3 then
        C_AuctionHouse.StartCommoditiesPurchase(itemID, quantity)
        debug(4)
        mode = 4
    elseif mode == 4 then
        return
    elseif mode == 5 then
        return
    end
end)