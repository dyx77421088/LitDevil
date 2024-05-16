math.randomseed(tostring(os.time()):reverse():sub(1, 7))
------------------------------------------------------ 
--[[ 
	用的多的函数方法有：
	Common.Core.functions 的 callback 
	Common.Base.ClassType 的 ClassType
	Common.Base.BaseClass 的 BaseClass
	Common.Const 的 Const （放一些常量进去的，全局管理）
	Common.Base.Event.EventDispatcher 的 EventDispatcher 
			下的 Dispatch 方法，观察者设计模式
	Common.Globals 的 Globals  这个是方便c#调用的 全局类
 ]]
--主入口函数。从这里开始lua逻辑
-- 该注释是为了找到Main
function Main()
	require "GameLogic.GameInit"
	-- 处理一些周期函数的
	require "BaseLogic.GameMainUpdate"
	
	GameMainUpdate:Initialize()
	G_printerror(table.serialize(G_EmptyTable))
	
end
