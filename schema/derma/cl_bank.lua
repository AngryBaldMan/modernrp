local PANEL = {}
	function PANEL:Init()
		self:SetSize(350, 162)
		self:SetTitle(L"bankMenu")
		self:Center()
		self:MakePopup()
		nut.gui.bank = self

		local btn = self:Add("DLabel")
		btn:Dock(TOP)
		btn:DockMargin(5, 7, 5, 5)
		btn:SetText(L("bankReserve", nut.currency.get(LocalPlayer():getChar():getReserve())))
		btn:SetContentAlignment(2)
		btn:SetFont("nutMediumFont")

		local btn = self:Add("DButton")
		btn:Dock(TOP)
		btn:DockMargin(5, 5, 5, 5)
		btn:SetText(L"deposit")
		btn.DoClick = function()
			Derma_StringRequest(
				L("enterAmount"),
				L("enterAmount"),
				0,
				function(a)
					LocalPlayer():ConCommand(Format("say %s %s", "/bankdeposit", a))
					self:Close()
				end
			)
		end

		local btn = self:Add("DButton")
		btn:Dock(TOP)
		btn:DockMargin(5, 5, 5, 5)
		btn:SetText(L"withdraw")
		btn.DoClick = function()
			Derma_StringRequest(
				L("enterAmount"),
				L("enterAmount"),
				0,
				function(a)
					LocalPlayer():ConCommand(Format("say %s %s", "/bankwithdraw", a))
					self:Close()
				end
			)
		end

		local btn = self:Add("DButton")
		btn:Dock(TOP)
		btn:DockMargin(5, 5, 5, 5)
		btn:SetText(L"transfer")
		btn.DoClick = function()
			Derma_StringRequest(
				L("enterAmount"),
				L("enterAmount"),
				0,
				function(a)
					LocalPlayer():ConCommand(Format("say %s %s", "/bankdeposit", a))
					self:Close()
				end
			)
		end
	end
vgui.Register("nutBankMenu", PANEL, "DFrame")

netstream.Hook("nutBank", function()
	if (nut.gui.bank and nut.gui.bank:IsVisible()) then
		nut.gui.bank:Close()
		nut.gui.bank = nil
	end

	vgui.Create("nutBankMenu")
end)