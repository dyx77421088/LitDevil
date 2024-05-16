--------------------------------------------------------------------------------
--     作者:yhj
--     文件描述:Slot视图主逻辑
--     创建时间:2023/09/20  
--------------------------------------------------------------------------------
local SlotView = BaseClass("SlotView", UIViewBase)
local ClassData = Globals.configMgr:GetConfig("ClassData")
local PlatSimulate = require (ClassData.PlatSimulate)
local SceneView = require (ClassData.SceneView)
local RollView = require (ClassData.RollView)
local MenuView = require (ClassData.MenuView)
local EffectView = require (ClassData.EffectView)

function SlotView:__ctor()
	self.weight = Const.GUIWeight.Main
end

function SlotView:Initialize()
	LMessage:Dispatch(LuaEvent.Loading.AddNeedLoad, 4)
	--加载大厅模拟器
	if Globals.gameModel.platformArg.bLocalMode then
		self.simulate = PlatSimulate.getInstance()
		self.simulate:Initialize()
	end
	self.sceneView = SceneView.New(self:GetChild("scene"), self)
	self.rollView = RollView.New(self:GetChild("scroll"), self)
	self.menuView = MenuView.New(self:GetChild("menu"), self)
	self.effectView = EffectView.New(self:GetChild("effect"), self)
end

function SlotView:ShowSelf()
	-- 订阅LuaEvent.Common.ApplicationUpdate, 在每一帧都会执行 Update 方法
	self:BindEvent(LuaEvent.Common.ApplicationUpdate, "Update")
	self:BindEvent(LuaEvent.Common.ApplicationLateUpdate, "LateUpdate")
	self:BindEvent(LuaEvent.SmallGame.IncreaseCover, "OnIncreaseCover")
	self:BindEvent(LuaEvent.SmallGame.DecreaseCover, "OnDecreaseCover")
	self:BindEvent(LuaEvent.SmallGame.Prepare, "OnPrepare")
	self:BindEvent(LuaEvent.SmallGame.OneRound, "OnOneRound")
	self:BindEvent(LuaEvent.SmallGame.BetResult, "OnBetResult")
	self:BindEvent(LuaEvent.SmallGame.StopRound, "OnStopRound")
	self:BindEvent(LuaEvent.SmallGame.FinishRound, "OnFinishRound")
	self:BindEvent(LuaEvent.SmallGame.Reveal, "OnReveal")
	self:BindEvent(LuaEvent.SmallGame.Numerical, "OnNumerical")
	self:BindEvent(LuaEvent.SmallGame.KeyEvent, "OnKeyEvent")
	self:BindEvent(LuaEvent.SmallGame.GameEvent, "OnGameEvent")
	self:BindEvent(LuaEvent.SmallGame.UIEvent, "OnUIEvent")
end

function SlotView:HideSelf()
	self:UnBindAllEvent()
	if self.simulate then
		self.simulate:Dispose()
	end
end

function SlotView:Update()
	self.rollView:Update()
end

function SlotView:LateUpdate()
	self.menuView:LateUpdate()
	self.rollView:LateUpdate()
end

function SlotView:OnIncreaseCover(...)
	self.sceneView:OnIncreaseCover(...)
end

function SlotView:OnDecreaseCover(...)
	self.sceneView:OnDecreaseCover(...)
end

--准备游戏
function SlotView:OnPrepare(msg)
	self.sceneView:OnPrepare(msg)
	self.menuView:OnPrepare(msg)
	self.rollView:OnPrepare(msg)
end

--开始滚动
function SlotView:OnOneRound()
	G_printerror("开始一句后主界面开始滚动")
	self.sceneView:OnOneRound() -- 空的
	self.menuView:OnOneRound() -- 0.5秒把退出按钮显示出来
	self.rollView:OnOneRound()
	self.effectView:OnOneRound()
end

--获取结果
function SlotView:OnBetResult(msg)
	self.menuView:OnBetResult(msg) -- 把stop按钮显示为true
	self.rollView:OnBetResult(msg) -- 检测数据的合法性，并把矩阵反转
end

--停止滚动
function SlotView:OnStopRound(immediate, ...)
	G_printerror("OnStopRound中的immediate是", immediate)
	self.menuView:OnStopRound(immediate, ...) -- 当immeditate为true，stop按钮设置为true
	self.rollView:OnStopRound(immediate, ...) -- immeditate为true，选择显示focus
end

--完成滚动
function SlotView:OnFinishRound(immediate, column)
	-- 当immediate为true时，停止按钮设置false，并通知平台
	self.menuView:OnFinishRound(immediate, column)
	self.rollView:OnFinishRound(immediate, column)
end

--游戏表现
function SlotView:OnReveal(revealType, ...)
	G_printerror("进入表现了，表现的类型是", revealType)
	-- 所有类型都有
	self.sceneView:OnReveal(revealType, ...) -- 包括有npc的动画，钱的特效等
	-- Const.RevealType.Finish(Normal) 很多按钮设置为true
	self.menuView:OnReveal(revealType, ...)
	-- -- 所有type都有
	self.rollView:OnReveal(revealType, ...) 
	self.effectView:OnReveal(revealType, ...)
end

--分值表现
function SlotView:OnNumerical(...)
	self.sceneView:OnNumerical(...) -- 空函数
	self.menuView:OnNumerical(...) -- 第一个参数为 win, 获得赢到的钱，展示特效和动画
	self.rollView:OnNumerical(...) -- 第一个参数为 FreeTime 才会执行
end

--按键事件
function SlotView:OnKeyEvent(...)
	self.menuView:OnKeyEvent(...)
	self.rollView:OnKeyEvent(...)
end

--游戏事件
function SlotView:OnGameEvent(...)
	self.rollView:OnGameEvent(...)
end

--UI事件
function SlotView:OnUIEvent(...)
	self.sceneView:OnUIEvent(...)
	self.rollView:OnUIEvent(...)
end


return SlotView