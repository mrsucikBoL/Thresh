--if myHero.charName ~= "Thresh" then return end

function OnLoad()
	require('FHPrediction')
 	DelayAction(function() Thresh() end,0.2)
end

class "Thresh"

function Thresh:__init()
	self:SendMessage("Sucessfully Loaded!")
	self:InitMenus()
	self:Variables()
	AddTickCallback(function() self:Tick() end)
	AddDrawCallback(function() self:Draw() end)
	--self:SkinChanger()
end

function Thresh:SendMessage(text)
	print("<b><font color=\"#ff0000\">Thresh: <font color=\"#ffffff\"><b>: "..text)
end

function Thresh:InitMenus()
	self:MainMenu()
end

function Thresh:MainMenu()
	self.Config = scriptConfig("Thresh", "Thresh")

	self.Config:addSubMenu("Combo", "combo")
	self.Config.combo:addParam("comboKey", "Combo Key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	self.Config.combo:addParam("useQ", "Use (Q) in Combo", SCRIPT_PARAM_ONOFF, true)
	self.Config.combo:addParam("useE", "Use (E) in Combo", SCRIPT_PARAM_ONOFF, false)


	self.Config:addSubMenu("Draws", "draws")
	self.Config.draws:addParam("drawQ", "Draw (Q) Range", SCRIPT_PARAM_ONOFF, true)
	self.Config.draws:addParam("drawE", "Draw (E) Range", SCRIPT_PARAM_ONOFF, true)

	self.Config:addSubMenu("Extra Hotkeys", "extra")
	self.Config.extra:addParam("pullE", "Pull (E) Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("T"))
	self.Config.extra:addParam("throwLantern", "Throw (W) to Lowest Ally", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("A"))

	--self.Config.Skin:addParam("Skin", "Thresh Skins", SCRIPT_PARAM_LIST, 1, {"Classic", "Deep Terror", "Blood Moon Thresh", "Dark Star Thresh", "Championship Thresh", "SSW Thresh"})
	--self.Config.Skin:setCallback("Skin", function() self:SkinChanger() end)
end

function Thresh:Variables()
	self.TS = TargetSelector(TARGET_LESS_CAST, 1500, DAMAGE_PHYSICAL, true)
	self.TS.name = "Target Selector"

	self.Q = { name = "ThreshQ", speed = 1825, delay = 0.5, range = 1050, width = 70, collision = true, aoe = false, type = "linear", dmgAP = function(source, target) return 35+45*source:GetSpellData(_Q).level+0.8*source.ap end}
	self.W = { range = 25000}
	self.E = { name = "ThreshE", speed = 2000, delay = 0.25, range = 450, width = 110, collision = false, aoe = false, type = "linear", dmgAP = function(source, target) return 9*source:GetSpellData(_E).level+0.3*source.ap end}
	self.R = { range = 450, width = 250}

	self.Q.IsReady = function() return myHero:CanUseSpell(_Q) == READY end
	self.W.IsReady = function() return myHero:CanUseSpell(_Q) == READY end
	self.E.IsReady = function() return myHero:CanUseSpell(_Q) == READY end
	self.R.IsReady = function() return myHero:CanUseSpell(_Q) == READY end
end

function Thresh:Tick()
	if myHero.dead then return end

	self.TS:update()
	self:TickCombo()
	self:TickPullE()
end


function Thresh:Draw()
	if myHero.dead then return end
	if self.Config.draws.drawQ and self.Q.IsReady then
		DrawCircle3D(myHero.x, myHero.y, myHero.z, self.Q.range, 2, 0x8000FFFF, 75)
	end

	if self.Config.draws.drawE and self.E.IsReady then
		DrawCircle3D(myHero.x, myHero.y, myHero.z, self.E.range, 2, 0x8000FFFF, 75)
	end	
end

function Thresh:TickCombo()
	--if _G.AutoCarry.Keys.AutoCarry then
	if self.Config.combo.comboKey then
		local target = self.TS.target
		if target == nil then return end
		self:CastQ(target, self.Config.combo.useQ)
		self:CastE(target, self.Config.combo.useE)
	end
end

function Thresh:TickPullE()
	if self.Config.extra.pullE then
		local target = self.TS.target
		if target == nil then return end
		self:CastE(target, self.Config.extra.pullE)
	end
end

function Thresh:CastQ(target, menu)
	if menu and self.Q.IsReady() and ValidTarget(target, self.Q.range) then
		local CastPosition, HitChance, Info = FHPrediction.GetPrediction(self.Q, target)
		if HitChance > 0 and not Info.collision then
			CastSpell(_Q, CastPosition.x, CastPosition.z)
		end
	end
end

function Thresh:CastW(target, menu)

end


function Thresh:CastE(target, menu)
	if menu and self.E.IsReady() and ValidTarget(target, self.E.range) then
		local CastPosition = Vector(target) + (Vector(myHero) - Vector(target)):normalized() * (GetDistance(target) + self.E.range) --Shulepin's Lucian helped me
		CastSpell(_W, CastPosition.x, CastPosition.z)
	end
end

function SkinChanger()
	SetSkin(myHero, self.Config.Skin - 1)
end

