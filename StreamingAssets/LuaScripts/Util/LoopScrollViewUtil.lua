------------------- LoopScrollViewUtil
--[[
		-- Author : suncle
		-- 使用说明 index从1开始
		-- 多行多列在单行单列的基础上扩展，多行多列的单个元素需要设置对象的名字为cell_1、cell_2、cell_3 ...
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data, -- 显示的数据
			one_line_count = 4, -- 行或列的数量
			loop_scroll_object = loopscroll,
			init_cell = function(index, cell_object) -- 初始化方法，主要用于初始化固定文本
				
			end,
			update_cell = function(index, cell_object, cell_data) -- 更新方法

			end,
			pull_refresh = function() -- 下拉刷新
				
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name) -- 点击回调
				
			end
		}
		self.m_loop = LoopScrollViewUtil.new(params)
]]
local M = class("LoopScrollViewUtil")

M.m_loop_scroll_view = nil

function M:ctor(params)
	self.m_loop_scroll_object = params.loop_scroll_object
	self.m_init_cell = params.init_cell or function() end
	self.m_update_cell = params.update_cell
	self.m_pull_refresh = params.pull_refresh
	self.m_click_func = params.click_func
	self.m_prefab_name = params.prefab_name
	self.m_show_data = params.show_data or {}
	self.m_one_line_count = params.one_line_count or 1
	self.m_all_cell_size = params.all_cell_size
	self.m_ui_name = params.ui_name
	self.m_pos_center = params.pos_center
	self.m_cache_cells = {}
	self:init()
end

function M:init()
	self.m_scroll_rect = self.m_loop_scroll_object:GetComponent("ScrollRect")
	self.m_loop_scroll_view = self.m_loop_scroll_object:GetComponent("LoopScrollView")
	if self.m_all_cell_size then
		self.m_loop_scroll_view:SetCellSizeForIndexDelegate(function(index)
			return self.m_all_cell_size[index + 1]
		end)
	end
	self:updateCellCount()
	local prefab = nil
	if self.m_prefab_name then
		prefab = GameUtil:createPrefab(self.m_prefab_name)
	end
	self:setPosCenterPadding()
	self.m_loop_scroll_view:Initialize(handler(self, self.actionFunc), prefab)
end

function M:setPosCenterPadding()
	if self.m_pos_center then
		if self.m_loop_scroll_view.direction ==  CS.wt.framework.LoopScrollView.EDirection.HORIZONTAL then
			local view_rt = self.m_scroll_rect.viewport.rect
			local cellSize = self.m_loop_scroll_view.cellSize
			local spacing = self.m_loop_scroll_view.spacing
			local padding = self.m_loop_scroll_view.padding
			padding.left = math.floor(math.max(0, view_rt.width - cellSize.x*self.m_count - (self.m_count - 1)*spacing)/2)
		end
	end
end

function M:updateCellCount()
	self.m_count = #self.m_show_data
	self.m_line_count = math.ceil(self.m_count/self.m_one_line_count)
	self.m_loop_scroll_view.cellsCount = self.m_line_count
end

--[[
	@scroll_view : 列表对象
	@hander_type : 处理类型
	@index : 下标 0 开始
	@cell_object : 列表单个对象
]]
function M:actionFunc(scroll_view, hander_type, index, cell_object)
	local a = 1;
	if hander_type == 1 then -- INIT_CELL
		if self.m_init_cell then
			if self.m_one_line_count > 1 then
				local transform = cell_object.transform
				for i = 1, self.m_one_line_count do
					local trans = transform:Find("cell_" .. i)
					if trans then
						local idx = index*self.m_one_line_count+i
						local luaBehaviour = UIUtil.findLuaBehaviour(trans)
						if luaBehaviour then
							luaBehaviour:RegistButtonClick(handler(self, self.itemClick))
						end
						self.m_init_cell(idx, trans.gameObject)
					end
				end
			else
				local luaBehaviour = UIUtil.findLuaBehaviour(cell_object.transform)
				if luaBehaviour then
					luaBehaviour:RegistButtonClick(handler(self, self.itemClick))
				end
				self.m_init_cell(index+1, cell_object)
			end
		end
	elseif hander_type == 2 then -- UPDATE_CELL
		if self.m_update_cell then
			if self.m_one_line_count > 1 then
				local transform = cell_object.transform
				for i = 1, self.m_one_line_count do
					local trans = transform:Find("cell_" .. i)
					if trans then
						local go = trans.gameObject
						local idx = index*self.m_one_line_count+i
						if idx <= self.m_count then
							go:SetActive(true)
							local luaBehaviour = UIUtil.findLuaBehaviour(trans)
							if luaBehaviour then
								luaBehaviour.itag = idx
							end
							self.m_cache_cells[idx] = go
							self.m_update_cell(idx, go, self.m_show_data[idx])
						else
							go:SetActive(false)
						end
					end
				end
			else
				local idx = index+1
				local luaBehaviour = UIUtil.findLuaBehaviour(cell_object.transform)
				if luaBehaviour then
					luaBehaviour.itag = idx
				end
				self.m_cache_cells[idx] = cell_object
				self.m_update_cell(idx, cell_object, self.m_show_data[idx])
			end
		end
	elseif hander_type == 3 then -- PULL_REFRESH
		if self.m_pull_refresh then
			self.m_pull_refresh()
		end
	end
end

--[[
	@click_object : 点击的对象
	@click_name : 点击的对象的名字
	@idx : 点击的下标 1 开始
]]
function M:itemClick(click_object, click_name, idx)
	local cell_object = self.m_cache_cells[idx]
	if self.m_click_func and cell_object then
		self.m_click_func(idx, cell_object, self.m_show_data[idx], click_object, click_name)
	end
	if self.m_ui_name and click_name then
		local full_btn_name = self.m_ui_name .. "/" .. click_name
		GameUtil:playBtnSound(full_btn_name)
	end
end
--[[
	@data : 新的数据
	@keep_offset : 是否保持偏移 可省略
	@all_cell_size : 所有的cell的大小表 可省略
]]
function M:reloadData(data, keep_offset, all_cell_size)
	self.m_show_data = data or {}
	self:updateCellCount()
	if all_cell_size then
		self.m_all_cell_size = all_cell_size
	end
	if keep_offset == nil then
		keep_offset = false
	end
	self.m_loop_scroll_view:ReloadData(self.m_line_count, keep_offset)
end

--[[
	获取当前偏移量
]]
function M:getContentOffset()
	return self.m_loop_scroll_view:GetContentOffset()
end

--[[
	@offset : 偏移量
]]
function M:setContentOffset(offset)
	self.m_loop_scroll_view:SetContentOffset(offset)
end

--[[
	@index : 定位的位置
	@offset : 偏移量
]]
function M:moveToCellIndex(index, offset)
	local real_index = math.ceil(index/self.m_one_line_count)
	self.m_loop_scroll_view:MoveToCellIndex(real_index - 1, offset or 0)
end

function M:setHorizontalNormalizedPosition(value)
	self.m_scroll_rect.horizontalNormalizedPosition = value or 0
end

function M:getHorizontalNormalizedPosition()
	return self.m_scroll_rect.horizontalNormalizedPosition
end

function M:setVerticalNormalizedPosition(value)
	self.m_scroll_rect.verticalNormalizedPosition = value or 0
end

function M:getVerticalNormalizedPosition(value)
	return self.m_scroll_rect.verticalNormalizedPosition
end

-- add_value -1 左按钮  1 右按钮
function M:moveHorizontalPage(add_value)
	local pos = self:getHorizontalNormalizedPosition()
	local cur_page = 0
	local offset = pos
	local max_index = self.m_line_count - 1
	for i = 0, max_index, 1 do
		local temp_offset = math.abs(pos - i/max_index)
		if temp_offset < offset then
			cur_page = i
			offset = temp_offset
		end
	end
	self:setHorizontalNormalizedPosition((cur_page + add_value)/max_index)
end


return M
