local AddOn = ...
local vUI, GUI, Language, Media, Settings = vUIGlobal:get()

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
	
	if (self.HasWhirlwind and(not HasWhirlwind)) then
		for i = 1, 2 do
			self.Whirlwind[i]:SetValue(0)
		end
		
		self.HasWhirlwind = false
	end
end

function Fury:CreateBars()
	-- Enrage bar
	self.EnrageBar = CreateFrame("StatusBar", nil, UIParent)
	self.EnrageBar:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	self.EnrageBar:SetStatusBarColorHex("E0392B")
	self.EnrageBar:SetScaledSize(Settings["unitframes-player-width"] - 2, 10)
	self.EnrageBar:SetScaledPoint("BOTTOM", vUI.UnitFrames["player"], "TOP", 0, 0)
	self.EnrageBar:SetMinMaxValues(0, 1)
	self.EnrageBar:SetValue(0)
	
	self.EnrageBar.BG = self.EnrageBar:CreateTexture(nil, "ARTWORK")
	self.EnrageBar.BG:SetAllPoints(self.EnrageBar)
	self.EnrageBar.BG:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	self.EnrageBar.BG:SetVertexColorHex("E0392B")
	self.EnrageBar.BG:SetAlpha(0.2)
	
	self.EnrageBar.BG2 = self.EnrageBar:CreateTexture(nil, "BORDER")
	self.EnrageBar.BG2:SetScaledPoint("TOPLEFT", self.EnrageBar, -1, 1)
	self.EnrageBar.BG2:SetScaledPoint("BOTTOMRIGHT", self.EnrageBar, 1, -1)
	self.EnrageBar.BG2:SetTexture(Media:GetTexture("Blank"))
	self.EnrageBar.BG2:SetVertexColor(0, 0, 0)
	
	-- Whirlwind bars
	self.Whirlwind = CreateFrame("Frame", nil, self)
	self.Whirlwind:SetScaledPoint("BOTTOMLEFT", self.EnrageBar, "TOPLEFT", -1, 0)
	self.Whirlwind:SetScaledSize(Settings["unitframes-player-width"], 12)
	self.Whirlwind:SetBackdrop(vUI.Backdrop)
	self.Whirlwind:SetBackdropColor(0, 0, 0)
	self.Whirlwind:SetBackdropBorderColor(0, 0, 0)
	
	local Width = ((Settings["unitframes-player-width"] - 2) / 2)
	
	for i = 1, 2 do
		self.Whirlwind[i] = CreateFrame("StatusBar", nil, self.Whirlwind)
		self.Whirlwind[i]:SetScaledSize(Width, 10)
		self.Whirlwind[i]:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
		self.Whirlwind[i]:SetStatusBarColorHex("dcb266")
		self.Whirlwind[i]:SetMinMaxValues(0, 1)
		self.Whirlwind[i]:SetValue(0)
		
		self.Whirlwind[i].bg = self.Whirlwind:CreateTexture(nil, "BORDER")
		self.Whirlwind[i].bg:SetAllPoints(self.Whirlwind[i])
		self.Whirlwind[i].bg:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
		self.Whirlwind[i].bg:SetVertexColorHex("dcb266")
		self.Whirlwind[i].bg:SetAlpha(0.3)
		
		if (i == 1) then
			self.Whirlwind[i]:SetScaledPoint("LEFT", self.Whirlwind, 1, 0)
			self.Whirlwind[i]:SetScaledWidth(Width)
		else
			self.Whirlwind[i]:SetScaledPoint("TOPLEFT", self.Whirlwind[i-1], "TOPRIGHT", 1, 0)
			self.Whirlwind[i]:SetScaledWidth(Width  - 1)
		end
	end
end

function Fury:Load()
	self:CreateBars()
	self:RegisterUnitEvent("UNIT_AURA", "player")
	self:SetScript("OnEvent", self.OnEvent)
end