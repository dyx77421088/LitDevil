--------------------------------------------------------------------------------
--     作者:yhj
--     文件描述:用来执行滚动遮罩，， 让滚动的不item不那么亮
--     创建时间:2023/09/20  
--------------------------------------------------------------------------------
-- 定义的是 reel/shade
local ScrollShade = BaseClass("ScrollShade", UIItem)
local _MaxNumber = _MaxNumber


function ScrollShade:__ctor(parent, baseView)
	self:InitItem(parent, nil, baseView)
end

function ScrollShade:Initialize()
	local process = function(transform)
		local component = transform:GetComponent(ClassType.Image)
		if ObjectUtils.IsNil(component) then
			component = transform:GetComponent(ClassType.RawImage)
		end
		return {gameObject = transform.gameObject, component = component}
	end
	
	self.items = TransformUtils.GetAllChilds(self.transform, process)
	self:Hide(_MaxNumber)
end

function ScrollShade:Show(index)
	if index == _MaxNumber then
		-- 第一次执行的时候  循环self.items 分别执行Show(i)
		for k, item in ipairs(self.items) do
			self:Show(k)
		end
	elseif self.items[index] then
		local item = self.items[index]
		-- 之前的tween停止
		if item.tweener then
			DOTween.Kill(item.tweener)
			item.tweener = nil
		end
		item.tweener = item.component:DOFade(0.4, 0.5):SetEase(EaseType.InSine):OnStart(function()
			item.gameObject:SetActive(true)
		end):OnComplete(function()
			item.tweener = nil
		end)
	end
end

function ScrollShade:Hide(index)
	if index == _MaxNumber then
		for k, item in ipairs(self.items) do
			self:Hide(k)
		end
	elseif self.items[index] then
		local item = self.items[index]
		if item.tweener then
			DOTween.Kill(item.tweener)
			item.tweener = nil
		end
		item.tweener = item.component:DOFade(0, 0.2):OnComplete(function()
			item.gameObject:SetActive(false)
			item.tweener = nil
		end)
	end
end


return ScrollShade