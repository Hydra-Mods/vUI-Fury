local AddOn = ...

if (not vUIGlobal) then
	return
end

local vUI, GUI, Language, Assets, Settings = vUIGlobal:get()

local Fury = vUI:NewPlugin(AddOn)

if (vUI.UserClass ~= "WARRIOR") then
	return
end

local EnrageName = GetSpellInfo(184361)
local WhirlwindName = GetSpellInfo(190411)

local GetTime = GetTime
local UnitAura = UnitAura
local Name, Count, Duration, Expiration, _

function Fury:OnUpdate(elapsed)
	self.Remaining = self.Remaining - elapsed
	
	self.EnrageBar:SetValue(self.Remaining)
	
	if (self.Remaining < 0) then
		self:SetScript("OnUpdate", nil)
	end
end

function Fury:OnEvent()
	local HasWhirlwind = false
	
	for i = 1, 40 do
		Name, _, Count, _, Duration, Expiration = UnitAura("player", i)
		
		if (not Name) then
			break
		end
		
		if ((Name == EnrageName) and Expiration) then
			self.Remaining = Expiration - GetTime()
			self.EnrageBar:SetMinMaxValues(0, Duration)
			self:SetScript("OnUpdate", self.OnUpdate)
		elseif ((Name == WhirlwindName) and Expiration) then
			for i = 1, 2 do
				if (i <= Count) then
					self.Whirlwind[i]:SetValue(1)
				else
					self.Whirlwind[i]:SetValue(0)
				end
			end
			
			self.HasWhirlwind = true
			HasWhirlwind = true
		end
	end
	
	if (self.HasWhirlwind and (not HasWhirlwind)) then
		for i = 1, 2 do
			self.Whirlwind[i]:SetValue(0)
		end
		
		self.HasWhirlwind = false
	end
end

function Fury:CreateBars()
	-- Enrage bar
	self.EnrageBar = CreateFrame("StatusBar", nil, UIParent)
	self.EnrageBar:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	self.EnrageBar:SetStatusBarColor(vUI:HexToRGB("E0392B"))
	self.EnrageBar:SetSize(Settings["unitframes-player-width"] - 2, 10)
	self.EnrageBar:SetPoint("BOTTOM", vUI.UnitFrames["player"], "TOP", 0, 0)
	self.EnrageBar:SetMinMaxValues(0, 1)
	self.EnrageBar:SetValue(0)
	
	self.EnrageBar.BG = self.EnrageBar:CreateTexture(nil, "ARTWORK")
	self.EnrageBar.BG:SetAllPoints(self.EnrageBar)
	self.EnrageBar.BG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	self.EnrageBar.BG:SetVertexColor(vUI:HexToRGB("E0392B"))
	self.EnrageBar.BG:SetAlpha(0.2)
	
	self.EnrageBar.BG2 = self.EnrageBar:CreateTexture(nil, "BORDER")
	self.EnrageBar.BG2:SetPoint("TOPLEFT", self.EnrageBar, -1, 1)
	self.EnrageBar.BG2:SetPoint("BOTTOMRIGHT", self.EnrageBar, 1, -1)
	self.EnrageBar.BG2:SetTexture(Assets:GetTexture("Blank"))
	self.EnrageBar.BG2:SetVertexColor(0, 0, 0)
	
	-- Whirlwind bars
	self.Whirlwind = CreateFrame("Frame", nil, self)
	self.Whirlwind:SetPoint("BOTTOMLEFT", self.EnrageBar, "TOPLEFT", -1, 0)
	self.Whirlwind:SetSize(Settings["unitframes-player-width"], 12)
	self.Whirlwind:SetBackdrop(vUI.Backdrop)
	self.Whirlwind:SetBackdropColor(0, 0, 0)
	self.Whirlwind:SetBackdropBorderColor(0, 0, 0)
	
	local Width = ((Settings["unitframes-player-width"] - 2) / 2)
	
	for i = 1, 2 do
		self.Whirlwind[i] = CreateFrame("StatusBar", nil, self.Whirlwind)
		self.Whirlwind[i]:SetSize(Width, 10)
		self.Whirlwind[i]:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
		self.Whirlwind[i]:SetStatusBarColor(vUI:HexToRGB("DCB266"))
		self.Whirlwind[i]:SetMinMaxValues(0, 1)
		self.Whirlwind[i]:SetValue(0)
		
		self.Whirlwind[i].bg = self.Whirlwind:CreateTexture(nil, "BORDER")
		self.Whirlwind[i].bg:SetAllPoints(self.Whirlwind[i])
		self.Whirlwind[i].bg:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
		self.Whirlwind[i].bg:SetVertexColor(vUI:HexToRGB("DCB266"))
		self.Whirlwind[i].bg:SetAlpha(0.3)
		
		if (i == 1) then
			self.Whirlwind[i]:SetPoint("LEFT", self.Whirlwind, 1, 0)
			self.Whirlwind[i]:SetWidth(Width)
		else
			self.Whirlwind[i]:SetPoint("TOPLEFT", self.Whirlwind[i-1], "TOPRIGHT", 1, 0)
			self.Whirlwind[i]:SetWidth(Width  - 1)
		end
	end
end

function Fury:Load()
	self:CreateBars()
	self:RegisterUnitEvent("UNIT_AURA", "player")
	self:SetScript("OnEvent", self.OnEvent)
end