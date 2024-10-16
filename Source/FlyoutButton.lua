local addonName, addon = ...

local flyout = CommoditySnipeFlyoutButton

flyout:SetParent(AuctionHouseFrame.CommoditiesBuyFrame.ItemList.RefreshFrame.RefreshButton)
flyout:SetPoint("TOPLEFT", AuctionHouseFrame.CommoditiesBuyFrame.ItemList.RefreshFrame.RefreshButton, "TOPRIGHT", 6, 0)
flyout:GetNormalTexture():SetTexCoord(0.15625, 0.5, 0.84375, 0.5, 0.15625, 0, 0.84375, 0)
flyout:GetHighlightTexture():SetTexCoord(0.15625, 1, 0.84375, 1, 0.15625, 0.5, 0.84375, 0.5)

flyout:HookScript("OnClick", function(self, button, isUserInput)
    CommoditySnipeFlyoutFrame:SetShown(self:GetChecked())
end)