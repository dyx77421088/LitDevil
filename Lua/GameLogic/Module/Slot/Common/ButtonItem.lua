local ButtonItem = BaseClass("ButtonItem", UIItem)

function ButtonItem:__defaultVar()
	return {
		interactable = true,
		relateHides = false,
		relateEnables = false,
	}
end

function ButtonItem:__ctor(parent, baseView)
	if not parent then return end
	self:InitItem(parent, nil, baseView)
end

function ButtonItem:Initialize()
	self.button = self:GetChild("", ClassType.Button) -- 找到button组件
	self.image = self:GetChild("", ClassType.Image)
	if not self.image then
		self.image = self:GetChild("title", ClassType.Image) -- 如果没有image组件就去找名字叫做title的
	end
end

function ButtonItem:SetEnable(enable)
	if self.interactable == enable then
		return
	end
	self.interactable = enable
	-- interactable设置它是否可以交互
	self.button.interactable = enable
end

function ButtonItem:ClickSelf()
	if self.interactable then
		self.button.onClick:Invoke()
	end
end

function ButtonItem:ShowSelf()
	if self.relateHides then
		for _, item in pairs(self.relateHides) do
			item:SetIsPop(false)
		end
	end
	if self.relateEnables then
		for _, item in pairs(self.relateEnables) do
			item:SetEnable(false)
		end
	end
end
-- 绑定，当一个按钮显示其他按钮得隐藏
function ButtonItem:AddRelate(item, hide)
	if self == item then return end

	if hide then
		if not self.relateHides then
			self.relateHides = {}
		end
		if table.indexof(self.relateHides, item) then
			return
		end
		table.insert(self.relateHides, item)
	else
		if not self.relateEnables then
			self.relateEnables = {}
		end
		if table.indexof(self.relateEnables, item) then
			return
		end
		table.insert(self.relateEnables, item)
	end
	item:AddRelate(self, hide)
end

function ButtonItem:GetEnable()
	return self.interactable
end


return ButtonItem