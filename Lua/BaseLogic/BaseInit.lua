--------------------------------------------------------------------------------
--     作者:yjp
--     文件描述:require BaseLogic目录下的文件
--     创建时间:2022/04/21 
--------------------------------------------------------------------------------
require "Common.Init"--初始化Common目录文件
require "BaseLogic.Event.EEvent" -- 一些事件的枚举
require "BaseLogic.Event.LuaEvent" -- lua 事件的枚举
require "BaseLogic.BaseConst" -- 一些全局常量
UIItem = require "BaseLogic.UI.UIItem" -- ui的基础类
UIViewBase = require "BaseLogic.UI.UIViewBase" -- 也是ui的类
require "Common.Core.strict" -- 不知道是啥玩意
require "GameExtend.Debug" -- 一些定义

local define ={
	poolMgr = "BaseLogic.Manager.PoolMgr",
    ioMgr = "BaseLogic.Manager.IOMgr",
    timerMgr = "BaseLogic.Manager.TimerMgr",
    resMgr = "BaseLogic.Manager.ResMgr",
    uiMgr = "BaseLogic.Manager.UIMgr",
	cameraMgr = "BaseLogic.Manager.CameraMgr",
    soundMgr = "BaseLogic.Manager.SoundMgr",
    pipeMgr = "BaseLogic.Manager.PipeMgr",
    touchMgr = "BaseLogic.Manager.TouchMgr",
    configMgr = "BaseLogic.Manager.ConfigMgr",
	processMgr = "BaseLogic.Manager.ProcessMgr",
}
Globals.InitMgrs(define)
 
