--------------------------------------------------------------------------------
--     作者:yjp
--     文件描述:用来作为GM控制器
--     创建时间:2022/04/21 
--------------------------------------------------------------------------------
local GMController = Singleton("GMController")

function GMController:__ctor()

end

function GMController:__delete()
    LMessage:UnRegister(LuaEvent.Common.ApplicationStart, self.onApplicationStart)
	--平台事件
	Globals.pipeMgr:UnBind(EEvent.PipeMsg.DebugModel)
end
 
function GMController:Initialize()
    self.onApplicationStart = LMessage:Register(LuaEvent.Common.ApplicationStart, "OnApplicationStart", self)
	--平台事件
	Globals.pipeMgr:Bind(EEvent.PipeMsg.DebugModel, "OnDebugModel", self)
end

function GMController:OnApplicationStart()
    if(Globals.gameModel.platformArg.bDebugMode) then
        Globals.uiMgr:OpenView("GMView")
    end
end

function GMController:OnDebugModel(msg)
	if msg.id == "SetDebugModel" then
		Globals.uiMgr:FloatMsg("Set Mode Successfully")
		LMessage:Dispatch(LuaEvent.GM.HideGMPanel)
	end
	LMessage:Dispatch(LuaEvent.SmallGame.DebugModel, msg)
end

return GMController