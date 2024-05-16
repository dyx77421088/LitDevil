--------------------------------------------------------------------------------
--     作者:yhj
--     文件描述:大厅模拟器,模拟游戏与大厅的交互
--     创建时间:2023/09/20  
--------------------------------------------------------------------------------
--[[ 
	因为这个lua中pipeType = plat 
	所以在执行send的时候只会执行P2G中的 在这里面找
 ]]
local json = require "cjson"
local PlatSimulate = Singleton("PlatSimulate")
local ClassData = Globals.configMgr:GetConfig("ClassData")
local PipeMgr = require "BaseLogic.Manager.PipeMgr"
local GameResult = require (ClassData.GameResult)

-- 这里面的是平台的值
function PlatSimulate:__ctor()
	self.pipeMgr = PipeMgr.New(Const.PipeType.Plat)
	self.gameResult = GameResult.New()
	self.credit = 0
	self.appointType = false
	self.appointId = false
end

function PlatSimulate:__delete()
	self.pipeMgr:UnBind(EEvent.PipeMsg.Setting)
	self.pipeMgr:UnBind(EEvent.PipeMsg.GameEvent)
	self.pipeMgr:UnBind(EEvent.PipeMsg.UIEvent)
	self.pipeMgr:UnBind(EEvent.PipeMsg.GameInfo)
	self.pipeMgr:UnBind(EEvent.PipeMsg.Prepare)
	self.pipeMgr:UnBind(EEvent.PipeMsg.OneRound)
	self.pipeMgr:UnBind(EEvent.PipeMsg.PreviewBet)
	self.pipeMgr:UnBind(EEvent.PipeMsg.DebugModel)
	self.pipeMgr:Dispose()
end

function PlatSimulate:Initialize()
	self.pipeMgr:Initialize()
	--监听游戏事件
	self.pipeMgr:Bind(EEvent.PipeMsg.Setting, "OnSetting", self)
	self.pipeMgr:Bind(EEvent.PipeMsg.GameEvent, "OnGameEvent", self)
	self.pipeMgr:Bind(EEvent.PipeMsg.UIEvent, "OnUIEvent", self)
	self.pipeMgr:Bind(EEvent.PipeMsg.GameInfo, "OnGameInfo", self)
	self.pipeMgr:Bind(EEvent.PipeMsg.Prepare, "OnPrepare", self)
	self.pipeMgr:Bind(EEvent.PipeMsg.OneRound, "OnOneRound", self)
	self.pipeMgr:Bind(EEvent.PipeMsg.PreviewBet, "OnPreviewBet", self)
	self.pipeMgr:Bind(EEvent.PipeMsg.DebugModel, "OnDebugModel", self)
end

--游戏信息
function PlatSimulate:OnGameInfo(msg)
	--分数
	if msg.credit then
		if msg.win then
			self.credit = self.credit + msg.win
		end
		self.pipeMgr:Send(EEvent.PipeMsg.GameInfo, {credit = self.credit, effect = msg.effect})
	--技巧游戏
	elseif msg.skillGameID then
		self.credit = self.credit + msg.winScore
		self.pipeMgr:Send(EEvent.PipeMsg.GameInfo, {credit = self.credit, effect = true})
	end
	G_printerror("这边有啥用哦！！！！！！！！！！！！", table.serialize(msg))
end

--游戏事件
function PlatSimulate:OnGameEvent(msg)
	--请求彩金
	if msg.id == "GetJackpot" then
		local score = math.random(25, 100) * 100
		self.pipeMgr:Send(EEvent.PipeMsg.GameEvent, {id = "GetJackpot", score = score})
	end
end

--UI事件
function PlatSimulate:OnUIEvent(msg)
	--加载界面
	if msg.id == "Loading" and not Globals.gameModel.platformArg.bHallLoading then
		if msg.step == 3 then
			Globals.timerMgr:AddTimer(function()
				self.pipeMgr:Send(EEvent.PipeMsg.UIEvent, {id = "Loading", step = 4})
			end, 0, 1)
		end
	end
end

--设置
function PlatSimulate:OnSetting()
	
end

--游戏准备
function PlatSimulate:OnPrepare()
	local jackpot = {minLocal = 25, minLink = 75}
	self.credit = math.random(5000, 10000)
	self.pipeMgr:Send(EEvent.PipeMsg.Prepare, {credit = self.credit, jackpot = jackpot})
	--屏幕旋转
	if _IsEditor then
		local flipAngle = tonumber(Util.GetPrefs('ScreenFlip', '0'));
		self.pipeMgr:Send(EEvent.PipeMsg.Setting, {id = "FlipScreen", value = flipAngle})
	end
end

--请求结果（根据获得的参数，得到一个矩阵）
function PlatSimulate:OnOneRound(msg)
	if msg.openType == Const.OpenType.Normal then
		self.credit = self.credit - msg.playBet
		if self.credit <= 0 then
			self.credit = math.random(5000, 10000)
		end
		self.pipeMgr:Send(EEvent.PipeMsg.GameInfo, {credit = self.credit})
		
		local result, appointType, appointId = false, false, false
		--调试指定
		if self.debugType then
			appointType = self.debugType
		--预览指定
		elseif self.previewType then
			appointType = self.previewType
			appointId = self.previewId
		--顺序出结果
		elseif _OrderPlay then
			if self.appointType then
				appointType = self.appointType
				appointId = self.appointId
			else
				appointType = Const.ResultType.Lose
				appointId = 1
			end
		end
		result, appointType, appointId = self.gameResult:Generate(appointType, appointId)
		G_printerror("这个个位置result是", result)
		while (not result) do
			appointType = appointType + 1
			if appointType > Const.ResultType.Link then
				appointType = Const.ResultType.Lose
			end
			appointId = 1
			result, appointType, appointId = self.gameResult:Generate(appointType, appointId)
		end
		--预览结束
		if self.previewType then
			self.previewType = false
			self.previewId = false
		--顺序更新
		elseif _OrderPlay then
			self.appointType = appointType
			self.appointId = appointId + 1
		end
		
		MyLog("本局结果：" .. result)
		G_printerror("当前获得的矩阵是", table.serialize(result))
		self.pipeMgr:Send(EEvent.PipeMsg.OneRound, result)
	elseif msg.openType == Const.OpenType.Give then
		-- 获得模拟的值
		local result = self.gameResult:GenerateForGive()
		self.pipeMgr:Send(EEvent.PipeMsg.OneRound, result)
	end
end

--预览
function PlatSimulate:OnPreviewBet(msg)
	local result, appointType, appointId = false, false, false
	--调试指定
	if self.debugType then
		appointType = self.debugType
	--预览指定
	elseif self.previewType then
		appointType = self.previewType
		appointId = self.previewId
	--顺序出结果
	elseif _OrderPlay and not self.appointType then
		appointType = Const.ResultType.Lose
		appointId = 1
	end
	result, appointType, appointId = self.gameResult:Generate(appointType, appointId)
	while (not result) do
		appointType = appointType + 1
		if appointType > Const.ResultType.Link then
			appointType = Const.ResultType.Lose
		end
		appointId = 1
		result, appointType, appointId = self.gameResult:Generate(appointType, appointId)
	end
	--预览更新
	self.previewType = appointType
	self.previewId = appointId
	
	local msg = json.decode(result)
	self.pipeMgr:Send(EEvent.PipeMsg.PreviewBet, {TotalBet = msg.TotalBet})
end

--调试
function PlatSimulate:OnDebugModel(msg)
	if msg.id == "SetDebugModel" then
		local data = msg.data
		--随机结果
		if data.Mode == 0 then
			self.debugType = false
		--指定结果
		else
			self.debugType = data.ResultType
		end
		self.pipeMgr:Send(EEvent.PipeMsg.DebugModel, {id = msg.id})
	elseif msg.id == "GetDebugModel" then
		self.pipeMgr:Send(EEvent.PipeMsg.DebugModel, {id = msg.id})
	end
end


return PlatSimulate