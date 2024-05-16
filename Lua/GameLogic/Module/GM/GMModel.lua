--------------------------------------------------------------------------------
--     作者:yjp
--     文件描述:用来的作为调试阶段用
--     创建时间:2022/04/21 
--------------------------------------------------------------------------------
local GMModel = Singleton("GMModel")


function GMModel:__defaultVar()
	return {
		totalPlay = 0,
		totalLose = 0,
		totalWin = 0,
	}
end


return GMModel