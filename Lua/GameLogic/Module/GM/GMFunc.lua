--------------------------------------------------------------------------------
--     作者:yjp
--     文件描述:进行GM方法配置的地方,如果时小游戏变种的项目不要放在这里，放在GMFunExt文件
--     创建时间:2022/05/06 
--------------------------------------------------------------------------------
LuaEvent.GM = {
    HideGMPanel = "HideGMPanel",
}

local GMFunc = {
    ClickRunGM = {
        {
            --大类名称
            {"name", "常用"} ,
            --具体方法 
            --函数名/显示名/是否需要输入参数/提示/默认设置
            {"SetSpeed", "游戏加速", false},
            --{"TestSound", "测试音效", false},
            {"TestTransfer", "测试传闻", true, "参数格式:TestTransfer 文本内容 传闻滚动类型(1从右到左/2从下到上)", "TestTransfer 这是一条测试传闻信息！！！"},
			{"TestMessage", "测试飘字", true, "参数格式:TestMessage 文本内容", "TestMessage 这是一条测试飘字信息！！！"},
        },
        {
            --大类名称
            {"name", "小游戏"} ,
            --具体方法 
            --函数名/显示名/是否需要输入参数/提示/默认设置
            {"SetDebugModel", "设置开奖", true, "参数格式:SetDebugModel 模式(0正常/1指定) 结果(0输/1赢/2免费奖/3Bonus奖/4Link奖)", "SetDebugModel 1 1"},
            {"GetDebugModel", "显示调试数据", false},
        }
    }
}

function GMFunc.SetSpeed()
    local speed = Time.timeScale
    speed = speed + 1
    if(speed > 3) then
        speed = 1
    end
    Time.timeScale = speed
end

--对应于SetSpeed的设置按钮文本
function GMFunc.SetSpeed_Text()
    local speed = Time.timeScale
    return string.format("加速×%d", speed)
end

function GMFunc.TestSound()
    if(not ComUtils.IsTestSound()) then
        Globals.uiMgr:FloatMsg("不在测试音效平台，当前功能无效")
        return
    end
    Globals.uiMgr:OpenView("SoundView")
    LMessage:Dispatch(LuaEvent.GM.HideGMPanel)
end

function GMFunc.TestTransfer(content, moveType)
    if(not content) then
        return
    end
    Globals.uiMgr:ShowTransfer({content = content, pause = true, moveType = moveType and tonumber(moveType) or nil})
    LMessage:Dispatch(LuaEvent.GM.HideGMPanel)
end

function GMFunc.TestMessage(content)
	if(not content) then
        return
    end
	Globals.uiMgr:FloatMsg(content)
	LMessage:Dispatch(LuaEvent.GM.HideGMPanel)
end

function GMFunc.SetDebugModel(model, resultType)
	Globals.pipeMgr:Send(EEvent.PipeMsg.DebugModel, {id = "SetDebugModel", data = {Mode = model, ResultType = resultType}})
end

function GMFunc.GetDebugModel()
	Globals.uiMgr:OpenView("GMAlgorithmView")
    LMessage:Dispatch(LuaEvent.GM.HideGMPanel)
end

local ClassData = Globals.configMgr:GetConfig("ClassData")
local GMFuncExt = require (ClassData.GMFuncExt)
local quickOverride = false
local clickRunDictExt = {}
local addCache = {}
local clickRunDict = {}
local function Override()
    if(not GMFuncExt.ClickRunGM or #GMFuncExt.ClickRunGM <= 0) then
        return
    end
    --把GMFuncExt.ClickRunGM创建映射
    for i, funcList in ipairs(GMFuncExt.ClickRunGM) do
        local name = funcList[1][2]
        clickRunDictExt[name] = {}
        addCache[name] = funcList
        for j = 2, #funcList do
            local funcKey = funcList[j][1]
            clickRunDictExt[name][funcKey] = funcList[j]
        end
    end
    --看看GMfunc.ClickRunGM中有没有需要覆盖的
    for i, funcList in ipairs(GMFunc.ClickRunGM) do
        local name = funcList[1][2]
        for j = 2, #funcList do
            local funcKey = funcList[j][1]
            if(clickRunDictExt[name] and clickRunDictExt[name][funcKey]) then
                GMFunc.ClickRunGM[i][j] = clickRunDictExt[name][funcKey]
            end
        end
        clickRunDict[name] = true
    end
    --完整的没有的模块直接append到GMFunc.ClickRunGM
    for name, funcList in pairs(addCache) do
        if(not clickRunDict[name]) then
            table.insert(GMFunc.ClickRunGM, funcList)
        end
    end
end
if(quickOverride) then
    GMFunc.ClickRunGM = table.extend(GMFunc.ClickRunGM, GMFuncExt.ClickRunGM)
else
    Override()
end
for key, value in pairs(GMFuncExt) do
    if(key ~= "ClickRunGM") then
        GMFunc[key] = GMFuncExt[key]
    end
end


return GMFunc