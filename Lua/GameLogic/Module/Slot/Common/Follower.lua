--------------------------------------------------------------------------------
--     作者:yhj
--     文件描述:用来执行追随者
--     创建时间:2023/09/20  
--------------------------------------------------------------------------------
local Follower = BaseClass("Follower", UIItem)


function Follower:__ctor(parent, baseView, master)
	self:InitItem(parent, nil, baseView)
	self.master = master
end

function Follower:DoFollowPos()
	self.transform.position = self.master.transform.position
end

function Follower:DoFollowScale()
	self.transform.localScale = self.master.transform.localScale
end

function Follower:Push(objectName, object, siblingIndex)
	if self.objectName == objectName then
		Globals.poolMgr:Push(objectName, object)
		return self.object
	end
	
	self:Clear()
	object.transform:SetParent(self.transform)
	TransformUtils.NormalizeTrans(object)
	ComUtils.ResetAnim(object)
	--避免打断合批
	if siblingIndex then
		self.transform:SetSiblingIndex(siblingIndex) -- 设置显示的位置
	end
	
	self.objectName = objectName
	self.object = object
	
	return self.object
end

function Follower:Clear()
	if not self.objectName or not self.object then
		return
	end
	
	Globals.poolMgr:Push(self.objectName, self.object)
	self.objectName = nil
	self.object = nil
end


return Follower