--------------------------------------------------------------------------------
--     作者:yhj
--     文件描述:特效主逻辑
--     创建时间:2023/09/20  
--------------------------------------------------------------------------------
local EffectView = BaseClass("EffectView", UIItem)
local ClassData = Globals.configMgr:GetConfig("ClassData")
local EffectItem = require (ClassData.EffectItem)
local NormalEffect = require (ClassData.NormalEffect)
local BigWinEffect = require (ClassData.BigWinEffect)
local JackPotEffect = require (ClassData.JackPotEffect)
local ConfigData = Globals.configMgr:GetConfig("SlotData")

--赢分特效
Const.EffectType = {
	Normal = 1, --普通赢分
	BigWin = 2, --奖牌赢分
	JackPot = 3, --彩金赢分
}

function EffectView:__ctor(parent, baseView)
	self:InitItem(parent, nil, baseView)
end

function EffectView:Initialize()
	local process = function(tran, i, list)
		return NormalEffect.New(tran)
	end
	self.lose = EffectItem.New(nil, self.mBaseView)
	self.normals = TransformUtils.GetAllChilds(self:GetChild("normal"), process)
	self.bigwin = BigWinEffect.New(self:GetChild("bigwin"), self.mBaseView)
	self.jackpot = JackPotEffect.New(self:GetChild("jackpot"), self.mBaseView)
	--如果赢分等级多于普通赢分特效,则将BIG WIN加入到普通赢分特效里
	if #ConfigData.winPoints > #self.normals then
		table.insert(self.normals, self.bigwin) -- 所以self.normals的长度现在为3
	end
	
	LMessage:Dispatch(LuaEvent.Loading.AddLoaded, 1)
end

function EffectView:OnOneRound()
	for k, v in ipairs(self.normals) do
		v:Stop()
	end
	self.bigwin:Stop()
	self.jackpot:Stop()
end

function EffectView:OnReveal(revealType, ...)
	if revealType == Const.RevealType.Effect then
		local effectType = select(1, ...)
		local odds = select(2, ...)
		local callBack = select(3, ...)
		--普通赢分
		if effectType == Const.EffectType.Normal then
			if odds == 0 then
				self.lose:Play(odds, callBack)
			else
				local oddsScale = odds / 100
				local effectId = 0
				for i = #ConfigData.winPoints, 1, -1 do
					if oddsScale >= ConfigData.winPoints[i] then
						effectId = i
						break
					end
				end
				if effectId > 0 then
					self.normals[effectId]:Play(odds, callBack)
				else
					self.lose:Play(odds, callBack)
				end
			end
		--BIG WIN
		elseif effectType == Const.EffectType.BigWin then
			G_printerror("进来bigwin了，", odds)
			self.bigwin:Play(odds, callBack, true)
			Globals.pipeMgr:Send(EEvent.PipeMsg.GameInfo, {state = true, bigwin = true})
		--彩金赢分
		elseif effectType == Const.EffectType.JackPot then
			local jackpotId = select(4, ...)
			self.jackpot:Play(odds, callBack, jackpotId)
		end
	end
end


return EffectView