--------------------------------------------------------------------------------
--     作者:yjp
--     文件描述:require和定义一些全局用到的变量
--     创建时间:2022/04/20 
--------------------------------------------------------------------------------

---定义全局空表和空函数，用作一个常量----------------
G_EmpytFunc = function () end  --有需要用到空函数的地方
G_EmptyTable = {} --用来作为全局空表，相当于一个常量，不要往里面插入数据
G_EmptyMetaTable = {
    __newindex = function(_, name, value)
        error("set value to G_EmptyTable", 0)
    end
}
setmetatable(G_EmptyTable, G_EmptyMetaTable)
local __tableinsert = table.insert
function Preprocessing()
    function table.insert(v, ...)
        if(getmetatable(v) == G_EmptyMetaTable) then
            error("不能往默认空表插入字段", 0)
            return
        end
        __tableinsert(v, ...)
    end
end
Preprocessing()
----------------------------------------------------

--desc:加载全局文件
GameObject = UnityEngine.GameObject
RenderMode = UnityEngine.RenderMode
Random = UnityEngine.Random
Space = UnityEngine.Space
Time = UnityEngine.Time
WWW = UnityEngine.WWW

Util = LuaFramework.Util
AppConst = LuaFramework.AppConst
LuaHelper = LuaFramework.LuaHelper
ByteBuffer = LuaFramework.ByteBuffer

Directory = System.IO.Directory

DOTween = DG.Tweening.DOTween
EaseType = DG.Tweening.Ease
PathType = DG.Tweening.PathType
PathMode = DG.Tweening.PathMode
RotateMode = DG.Tweening.RotateMode
LoopType = DG.Tweening.LoopType

require "Common.Core.table"
require "Common.Core.string"
require "Common.Core.functions" -- callback
require "Common.Core.math"
require "Common.Tool.MyLog"
ClassType = require "Common.Base.ClassType" -- cs中的类的
require "Common.Base.BaseClass" -- 封装类，定义一些基础的类
require "Common.Base.Singleton" -- 单例
LuaDelegate = require "Common.Tool.LuaDelegate" -- 委托

require "tolua.reflection"
require "System.Reflection.BindingFlags"

require "Common.Const" -- 常量
local EventDispatcher = require "Common.Base.Event.EventDispatcher" -- 事件，和我之前在c#中用的观察者设计模式类似
LMessage = EventDispatcher.New()
require "Common.Base.Event.EEvent"
require "Common.Base.Event.LuaEvent"
Globals = require "Common.Globals" -- 全局的 方便和c#交互

CastUtils = require "Common.Utils.CastUtils" -- 一些c#类中的一些数值的转换
TimeUtils = require "Common.Utils.TimeUtils" -- 时间的工具类
ComUtils = require "Common.Utils.ComUtils" -- 通用的一些工具
LayerUtils = require "Common.Utils.LayerUtils" -- layer相关的
ObjectUtils = require "Common.Utils.ObjectUtils" -- Unity.Object相关的工具函数
PathUtils = require "Common.Utils.PathUtils"
TransformUtils = require "Common.Utils.TransformUtils" -- transform的工具类
UIUtils = require "Common.Utils.UIUtils" -- 图片置灰等工具，引用不多
LanguageUtils = require "Common.Utils.LanguageUtils"