--------------------------------------------------------------------------------
--     作者:yjp
--     文件描述:像管道一样，用来处理大厅和小游戏之间的消息通信
--     创建时间:2022/04/23 
--------------------------------------------------------------------------------
--[[ 

    1. PipeMgr:Send 传一个id 过去
    2. 在c# 中会调用PipeMgr:OnRecieve 方法（因为在PipeMgr:Initialize注册了）
    3. 在PipeMgr:OnRecieve方法中会执行key为id的方法（Game发送send 执行(type)Plat中的bind，， Plat发送send，执行Game中的bind）
       也就是Globals.pipeMgr:Send，会调用PlatSimulate中的bind方法（因为这个lua中的type为plat）
       而在PlatSimulate中调用send方法，会调用Globals.pipeMgr:Bind中的方法（type为game）
 ]]
local json = require "cjson"
local PipeMgr = BaseClass("PipeMgr")
Const.PipeType = {
    Plat = 1,
    Game = 2,
}
function PipeMgr:__ctor(type)
    self.pipeType = type or Const.PipeType.Game
    self.eventFuncDict = {}
end

function PipeMgr:__delete()
    self.eventFuncDict = nil
    if(not self.onRecieve) then
        return
    end
    if(self.pipeType == Const.PipeType.Plat) then
        EventManager.Inst:UnRegister(EEvent.Platform.G2P, self.onRecieve)
    else
        EventManager.Inst:UnRegister(EEvent.Platform.P2G, self.onRecieve)
    end
end

function PipeMgr:Initialize()
    if(not self.onRecieve) then
        self.onRecieve = ComUtils.Handler(self, self.OnRecieve)
    end
    -- 这边是反一头，当这个type是game时，处理P2G的方法
    if(self.pipeType == Const.PipeType.Plat) then
        EventManager.Inst:Register(EEvent.Platform.G2P, self.onRecieve)
    else
        EventManager.Inst:Register(EEvent.Platform.P2G, self.onRecieve)
    end
end

function PipeMgr:Send(id, msg)
    msg = msg or G_EmptyTable
    if(not id or not msg) then
        printerror("消息协议错误：", id, msg)
        printext("消息协议错误：", id, msg)
        return
    end
	local strMsg 
    if(type(msg) == "string") then
        strMsg = msg
    elseif msg == G_EmptyTable then
        strMsg = nil
    else
        strMsg = json.encode(msg)
    end
    if(self.pipeType == Const.PipeType.Plat) then
        -- 执行绑定了这个id的所有方法
        
        EventManager.Inst:Send(EEvent.Platform.P2G, id, strMsg)
    else
        EventManager.Inst:Send(EEvent.Platform.G2P, id, strMsg)
    end
end

function PipeMgr:OnRecieve(id, strMsg)
	local msg = json.decode(strMsg)
    local zfunc = self.eventFuncDict[id]
    if (not zfunc) then
        --printerror("此消息未作监听：", id)
        return
    end
    zfunc(msg)
end

--==============================--
--addby:yjp
--desc:绑定协议id，小游戏和大厅通信协议的id
--@id:协议事件id，evtId
--@funcName: 绑定的事件回调方法名称，用名称吧，后续热重载才能进行，否则如果绑定的是方法就无法热重载了
--@self_obj: 绑定事件的对象
--@return:
--time:2022-04-23 10:20:26
--==============================--
function PipeMgr:Bind(id, funcName, self_obj)
    if(type(id) ~= "number") then
        printerror("错误的id类型:", id, type(id))
        return
    end
    if(not funcName or not self_obj[funcName]) then
        printerror("绑定方法不能为空", id, self_obj, funcName)
    end
    if(self.eventFuncDict[id]) then
        printerror("不能重复绑定协议", id)
        return
    end
    self.eventFuncDict[id] = callback(self_obj, funcName)
end

function PipeMgr:UnBind(id)
    self.eventFuncDict[id] = nil
end

return PipeMgr
