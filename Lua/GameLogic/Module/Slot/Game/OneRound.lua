--------------------------------------------------------------------------------
--     作者:yhj
--     文件描述:用来执行一局结果
--     创建时间:2023/09/20  
--------------------------------------------------------------------------------
local OneRound = BaseClass("OneRound")
local ClassData = Globals.configMgr:GetConfig("ClassData")
local OneLine = require (ClassData.OneLine)

Const.OpenType = {
	Normal = 0, --普通开奖
	Give = 1, --赠送开奖
}

Const.ResultType = {
	Lose = 0,
	Win = 1,
	Free = 2,
	Bonus = 3,
	Link = 4,
}


function OneRound:__ctor(rows, columns, lines, chessOdds)
	self.rows = rows
	self.columns = columns
	self.lines = lines
	self.chessOdds = chessOdds
	self.result = {}
end

--获取到结果
function OneRound:SetResult(data)
	self:AlgorithmValid(data) -- 检测数据合法性
	self.algorithm = data
	self.resultType = data.ResultType
	self.openType = data.OpenType
	self.baseBet = data.TotalBet or 0
	self.freeBet = data.TotalFreeBet or 0
	self.bonusBet = data.BonusBet or 0
	self.linkBet = data.LinkBet or 0
	self:ProcessResult(data.Matrix)

end

--转换阵列,由【左-右,下-上】转换【下-上,左-右】
--[[ 
	1 2 3		2 5 8
	4 5 6  =>   3 6 9 
	7 8 9       4 7 10
 ]]
function OneRound:ProcessResult(matrix)
	self.matrix = {}
	for i = 1, self.columns do
		if not self.matrix[i] then
			self.matrix[i] = {}
		end
		for m = 1, self.rows do
			self.matrix[i][m] = matrix[(m-1)*self.columns+i] + 1
		end
	end
end

--检查数据合法性
function OneRound:AlgorithmValid(data)
	if not data then
		printerror("获取游戏结果为空")
		if _ErrorPause then
			ComUtils.SetTimeScale(0) -- 暂停
		end
		return
	end
	
	--按开奖类型检查
	if data.OpenType == Const.OpenType.Normal then
		if Globals.gameModel.remainGiveTime > 0 then
			printerror("赠送局还未完成！")
			if _ErrorPause then
				ComUtils.SetTimeScale(0)
			end
		end
		Globals.gameModel.roundOdds = (data.TotalBet or 0) + (data.TotalFreeBet or 0) + (data.BonusBet or 0) + (data.LinkBet or 0)
	elseif data.OpenType == Const.OpenType.Give then
		if Globals.gameModel.rule ~= Const.GameRule.Free then
			printerror("非免费玩法不能有赠送局！")
			if _ErrorPause then
				ComUtils.SetTimeScale(0)
			end
		end
		--因玩法不同,会增加免费次数
		Globals.gameModel.totalGiveTime = Globals.gameModel.totalGiveTime + (data.AddFreeTime or 0)
		Globals.gameModel.remainGiveTime = Globals.gameModel.remainGiveTime + (data.AddFreeTime or 0)
		self.freeOdds = self.freeOdds + (data.TotalBet or 0)
	end
	
	--按结果类型检查
	if data.ResultType == Const.ResultType.Free then
		if Globals.gameModel.rule ~= Const.GameRule.Normal then
			printerror("非普通玩法不能进入免费游戏！")
			if _ErrorPause then
				ComUtils.SetTimeScale(0)
			end
		end
		Globals.gameModel.totalGiveTime = data.TotalFreeTime or 0
		Globals.gameModel.remainGiveTime = data.TotalFreeTime or 0
		self.freeOdds = data.TotalBet
	elseif data.ResultType == Const.ResultType.Bonus then
		if Globals.gameModel.rule ~= Const.GameRule.Normal then
			printerror("非普通玩法不能进入小游戏！")
			if _ErrorPause then
				ComUtils.SetTimeScale(0)
			end
		end
	elseif data.ResultType == Const.ResultType.Link then
		if Globals.gameModel.rule ~= Const.GameRule.Normal then
			printerror("非普通玩法不能进入公共游戏！")
			if _ErrorPause then
				ComUtils.SetTimeScale(0)
			end
		end
	end
end

function OneRound:GetAlgorithm()
	return self.algorithm
end

--计算结果(获得中奖的倍率)
function OneRound:Calculate()
	--更改阵列
	self:AlterMatrix()
	
	--依赖中奖线
	self.result.totalOdds = 0
	self.result.winning = false
	self.result.arrays = false
	for i = 1, #self.lines do
		local oneLine = OneLine.New()
		oneLine:CheckInLine(i, self.matrix, self.lines[i], self.chessOdds)
		if oneLine.resultType >= Const.ResultType.Win then
			if not self.result.arrays then
				self.result.arrays = {}
			end
			table.insert(self.result.arrays, oneLine)
			self.result.winning = true
			self.result.totalOdds = self.result.totalOdds + oneLine.odds
		end
	end
	if self.result.arrays then
	end
	--不依赖中奖线
	local oneLine = OneLine.New()
	oneLine:CheckOutLine(self.matrix, self.chessOdds)
	if oneLine.resultType > Const.ResultType.Win then
		if not self.result.arrays then
			self.result.arrays = {}
		end
		table.insert(self.result.arrays, oneLine)
		self.result.winning = true
		self.result.totalOdds = self.result.totalOdds + oneLine.odds
	end
	--整理中奖线
	if self.result.arrays then
		local arrays = {}
		for k, v in ipairs(self.result.arrays) do
			if not arrays[v.resultType] then
				arrays[v.resultType] = {}
			end
			table.insert(arrays[v.resultType], v)
		end
		self.result.arrays = arrays
	end
	
	--更改赔率
	self:AlterOdds()
	
	--核对算法
	if not Globals.gameModel.platformArg.bLocalMode then
		if self.result.totalOdds ~= self.baseBet then
			printerror(string.format("赔率出错! 前端赔率: %d, 算法赔率: %d", self.result.totalOdds, self.baseBet))
			if _ErrorPause then
				ComUtils.SetTimeScale(0)
			end
		end
		if Globals.gameModel.rule == Const.GameRule.Free and Globals.gameModel.remainGiveTime == 0 and self.freeOdds ~= Globals.gameModel.roundOdds then
			printerror(string.format("免费总赔率出错! 前端赔率: %d, 算法赔率: %d", self.freeOdds, Globals.gameModel.roundOdds))
			if _ErrorPause then
				ComUtils.SetTimeScale(0)
			end
		end
	end
end

--改变阵列
function OneRound:AlterMatrix()
	--todo 阵列因玩法不同会变动
	
end

--改变赔率
function OneRound:AlterOdds()
	--todo 赔率因玩法不同会变动
	
end

return OneRound