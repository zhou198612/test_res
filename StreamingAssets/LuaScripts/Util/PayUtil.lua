------------------- PayUtil
--[[
    支付使用方式  具体参数请参照具体方法
    PayUtil:rechargeByData(data, function (result)
        -- 支付结果处理
    end)
]]
local M = {
    m_callBack = nil, -- 支付结果回调
    m_ios_currency = "", -- ios返回的货币
    m_pay_test = GameVersionConfig.PAY_TEST -- 支付测试，不走sdk支付直接通知后端发奖励
}

local platform_channel = "unknow"

-- 需要向服务器获取支付sign的平台
local need_pay_sign = {}

-- 需要向服务器获取订单
local need_get_orderinfo = {}

function M:getChargeCfg(id)
    local charge = ConfigManager:getCfgByName("charge")
    return charge[tonumber(id)]
end

---获取通用商品信息
function M:getCommonGoodsInfo(cfg)
    local goodsId = cfg.buy_id
    local cost = cfg.cost
    local price_show = ConfigManager:getCfgByName("price_show")
    local price_cfg = price_show[cfg.price]
    local currency = ConfigManager:getCommonValueById(331, "usd")
    local price = price_cfg[currency] or 9999
    Logger.log(price, "price ========")

    local serverData = UserDataManager.server_data:getServerData()
    local serverTime = UserDataManager:getServerTime()

    local params = {}
    local serverId = serverData.server --服务器id
    local userData =UserDataManager.user_data
    local uid = userData:getUserStatusDataByKey("uid") --玩家uid

    local order_id =
    tostring(uid) .. "-" .. tostring(serverId) .. "-" .. tostring(goodsId) .. "-" .. tostring(os.time())
    params.uid = tostring(uid)
    params.name = userData:getUserStatusDataByKey("name")
    params.level = userData:getUserStatusDataByKey("level")
    params.vip = userData:getUserStatusDataByKey("vip")

    params.order_id = order_id
    params.cost_key = tostring(cost) --商品配置项标识

    -- android，ios都需要使用cost转换
    local charge_product = ConfigManager:getCfgByName("charge_product")
    local bundleid = SDKUtil.sdk_params.applicationId or ""
    local charge_product_item = charge_product[tostring(bundleid) .. "_" .. params.cost_key]
    Logger.log("charge_product key ====== " .. tostring(bundleid) .. "_" .. params.cost_key)
    params.cost = charge_product_item and charge_product_item.product_id or "nil" --商品真实项标识

    params.price = tostring(price) --商品价格
    params.goods_id = tostring(goodsId) -- 支付项id
    params.goods_name = Language:getTextByKey(cfg.name) -- 支付项名字
    params.goods_des = Language:getTextByKey(cfg.des) -- 支付项描述
    params.currency = string.upper(currency) -- 货币类型
    params.count = 1
    --params.diamond   = tostring(cfg.diamond)
    params.format_price = string.format("%.2f", price)
    --params.gift_diamond  = cfg.gift_diamond or 0
    --if cfg.is_double then
    --    params.gift_diamond  = cfg.diamond + params.gift_diamond   -- 赠送金币
    --end

    params.server_id = tostring(serverId)
    params.server_name = tostring(serverData.server_name) -- 服务器名
    params.guide_name = UserDataManager.user_data:getUserStatusDataByKey("guild_name") or "" -- 公会名
    params.role_level = UserDataManager.user_data:getUserStatusDataByKey("level") or 1
    params.user_own_coin = UserDataManager.user_data:getUserStatusDataByKey("diamond") or 0
    params.vip_level = UserDataManager.user_data:getUserStatusDataByKey("vip") or 0
    params.role_name = UserDataManager.user_data:getUserStatusDataByKey("name") or ""
    params.guide_id = UserDataManager.user_data:getUserStatusDataByKey("guild_id") or "" -- 公会id

    --params.get_order_url = tostring(BASEINFO_DIC.order_url) .. tostring(game_url.getExtUrlInfo())
    --params.notify_url = BASEINFO_DIC.notify_url

    params.openid = UserDataManager.client_data.openid -- sdk的唯一ID
    Logger.log(price, "price ========")
    params.serverTime = os.date("%Y%m%d%H%M%S", serverTime) -- 订单产生时间

    local charge_product_info = charge_product[cfg.cost]
    params.productId = cfg.cost
    params.productName = Language:getTextByKey(cfg.name)
    params.productDesc = Language:getTextByKey(charge_product_info.des)
    params.productPrice = tostring(charge_product_info.price)

    return params
end

function M:gsdkPayRst(payInfo, rstType, cbFuncName)
    if payInfo and payInfo.goods_id then
        GameUtil:sendPayment(payInfo.goods_id, rstType)
    end

    if type(self.m_callBack) == "function" then
        self.m_callBack({code = cbFuncName, payMsg = ""})
    end
end
--- 通用支付
function M:startPayCommon(goodsInfo)
    local function buyResult(data)
        local function delayFunc()
            local result = data["result"]
            local errmsg = data["errmsg"]
            self.m_hidePayTips = true
            if result then
                self:paySuccess(goodsInfo, errmsg)
            else
                self:payFailed(goodsInfo, errmsg)
                --if not errmsg:find("[gsdk]", 1, true) then
                --    --不使用GSDK支付失败提示
                --    if result == 1 then
                --        self:payCancel(goodsInfo, errmsg)
                --    elseif result == -1 then
                --        self:payFailed(goodsInfo, errmsg)
                --    else
                --        self:payFailed(goodsInfo, errmsg)
                --    end
                --else
                --    -- errmsg =  "[gsdk]PayMinorPayLimited"
                --    --gsdk失败会有错误内容
                --    if errmsg == "[gsdk]PayGuestCannotPay" then
                --        -- 游客不支持支付，提示用户错误原因
                --        self.m_hidePayTips = true
                --
                --        self:gsdkPayRst(goodsInfo, 4, "failed")
                --
                --        local params = {
                --            on_ok_call = function(msg)
                --                SDKUtil:handleGameEvent("show_bind_acount", {})
                --            end,
                --            no_close_btn = false,
                --            tow_close_btn = false,
                --            ok_text = Language:getTextByKey("sdk_txt_017"),
                --            text = data["extramsg"], --Language:getTextByKey("sdk_txt_019"),
                --            title = Language:getTextByKey("sdk_txt_002"),
                --            custom_text_height = 160
                --        }
                --
                --        static_rootControl:openView("Pops.CommonPop", params)
                --    elseif errmsg == "[gsdk]PayUserIsNotAuthenticated" then
                --        -- 用户未实名，不能支付
                --        self.m_hidePayTips = true
                --        self:gsdkPayRst(goodsInfo, 4, "failed")
                --
                --        local params = {
                --            on_ok_call = function(msg)
                --                SDKUtil.callbackMap["realname_end"] = function(param)
                --                    if param.success then
                --                        SDKUtil:antiAddiction(
                --                                0,
                --                                function(rst)
                --                                    if not rst then
                --                                        SDKUtil:logOut(
                --                                                function()
                --                                                    GameMain.reStart()
                --                                                end
                --                                        )
                --                                    end
                --                                end
                --                        )
                --                    end
                --                end
                --
                --                SDKUtil:handleGameEvent("show_realname", {})
                --            end,
                --            no_close_btn = false,
                --            tow_close_btn = false,
                --            ok_text = Language:getTextByKey("sdk_txt_003"),
                --            text = data["extramsg"], --Language:getTextByKey("sdk_txt_020"),
                --            title = Language:getTextByKey("sdk_txt_002"),
                --            custom_text_height = 160
                --        }
                --
                --        static_rootControl:openView("Pops.CommonPop", params)
                --        StatisticsUtil:doPoint("realNameTips")
                --    elseif errmsg == "[gsdk]PayMinorPayLimited" then
                --        --未成年人支付限制，提供防沉迷相关提示
                --        self.m_hidePayTips = true
                --        self:gsdkPayRst(goodsInfo, 4, "failed")
                --        local params = {
                --            no_close_btn = false,
                --            tow_close_btn = false,
                --            ok_text = Language:getTextByKey("sdk_txt_013"),
                --            text = data["extramsg"],
                --            --Language:getTextByKey("sdk_txt_021"),
                --            title = Language:getTextByKey("sdk_txt_002"),
                --            custom_text_height = 180
                --        }
                --
                --        static_rootControl:openView("Pops.CommonPop", params)
                --    elseif errmsg == "[gsdk]PayCounterPayCanceled" then
                --        --用户取消支付，可以提示用户已「取消支付」
                --        self:payCancel(goodsInfo, errmsg)
                --    elseif errmsg == "[gsdk]PayCounterPayProceeding" then
                --        --提示用户当前有正在处理的支付，请稍后重试
                --        self:payFailed(goodsInfo, Language:getTextByKey("sdk_txt_022"))
                --    elseif errmsg == "[gsdk]PayNetworkError" then
                --        self:payFailed(goodsInfo, Language:getTextByKey("sdk_txt_023"))
                --    elseif errmsg == "[gsdk]PayPayingError" then
                --        self:payFailed(goodsInfo, data["extramsg"])
                --    else
                --        --其他原因
                --        self:payFailed(goodsInfo, errmsg)
                --    end
                --end
            end
        end

        EventDispatcher:registerTimeEvent(
                "pay_delay_call_timer",
                function()
                    delayFunc()
                end,
                0.033,
                0.033
        )
    end

    -- local uid = UserDataManager.server_data.server_data.uid
    SDKUtil:pay(buyResult, goodsInfo)
end

---开始支付
--@params goodsId 商品id
--@act_id 活动id
--@act_item_id 活动中某一个id
function M:startPay(cfg, ext_id)
    local params = {}
    params.goods_id = cfg.buy_id
    params.ext_id = ext_id or 0
    local url = NetUrl.getUrlForKey("payment_pay_order")
    url = tostring(url) .. "&" .. NetUrl.getExtUrlParam()
    NetWork:httpRequest(
            function(data)
                local goodsInfo = self:getCommonGoodsInfo(cfg) -- 获取商品信息
                if data and data.order_id then
                    goodsInfo.order_id = data.order_id
                else
                    Logger.log("pay_order order id is nul")
                end
                self:payBegan(goodsInfo)
                self:startPayCommon(goodsInfo)
            end,
            url,
            GlobalConfig.POST,
            params,
            "payment_pay_order",
            0
    )
    
end

-- 虚拟充值
function M:testPay(cfg, ext_id)
    local params = {}
    params.idx = cfg.buy_id
    params.ext_id = ext_id or 0
    cfg.goods_id = tostring(cfg.buy_id)
    local url = NetUrl.getUrlForKey("mall_charge")
    url = tostring(url) .. "&" .. NetUrl.getExtUrlParam()
    NetWork:httpRequest(
            function(data)
                if data and data.status == true then
                    self:paySuccess(cfg)
                else
                    self:payFailed()
                end
            end,
            url,
            GlobalConfig.POST,
            params,
            "mall_charge",
            0,
            true
    )
end

---支付购买
--@params data 商品配置
--@params callback 购买回调
function M:rechargeByData(data, callback, ext_id)
    self.m_callBack = callback
    if (not data) then
        self:rechargeCallBack("no_item") --提示
    else
        if self.m_pay_test then
            self:testPay(data, ext_id)
        else
            if not SDKUtil.isHaveSDK then
                self:rechargeCallBack("invalid") --提示
            else
                self:startPay(data, ext_id) --开始购买
            end
        end
    end
end

---支付购买
--@params data 商品配置id
--@params callback 购买回调
function M:rechargeByChargeId(charge_id, callback, ext_id)
    --local function check_charge_over(data)
    --    if data then
            local cfg = self:getChargeCfg(charge_id)
            if cfg then
                static_rootControl:openView("Loading.SmallLoading", {delay_show = 0}, "pay_small_loading")
                self:autoCloseLoading()
                GameUtil:sendPayment(charge_id, 1)
                local function rechargeBack(params)
                    if not self.m_hidePayTips then
                        GameUtil:lookInfoTips(static_rootControl, {msg = params.payMsg, delay_close = 2})
                    end
                    EventDispatcher:registerTimeEvent(
                            "pay_delay_call_timer2",
                            function()
                                if callback then
                                    callback(params)
                                end
                                self:closeLoading()
                            end,
                            2,
                            2
                    )
                end
                PayUtil:rechargeByData(cfg, rechargeBack, ext_id)
            else
                GameUtil:lookInfoTips(static_rootControl, {msg = "new_str_0535", delay_close = 2})
            end
    --    end
    --end
    --local url = NetUrl.getUrlForKey("charge_check")
    --NetWork:httpRequest(check_charge_over,url,GlobalConfig.POST,nil,"charge_check",0)
end

--- 回调
function M:rechargeCallBack(payCode, payMsg, goodsId)
    self:autoCloseLoading(2)
    payMsg = payMsg or ""
    goodsId = goodsId or ""
    if payCode == "no_item" then -- 没有支付项配置
        payMsg = Language:getTextByKey("pay_invalid")
    elseif payCode == "invalid" then
        payMsg = Language:getTextByKey("pay_invalid")
    end
    if type(self.m_callBack) == "function" then
        self.m_callBack({code = payCode, payMsg = payMsg, goodsId = goodsId})
    end
    self:destory()
end

--- 开始支付
function M:payBegan(payInfo)
    self:payBeginToBi(payInfo)
end

--- 支付成功
function M:paySuccess(payInfo)
    local goods_id = ""

    if payInfo and payInfo.goods_id then
        GameUtil:sendPayment(payInfo.goods_id, 2)
        goods_id = payInfo.goods_id
    end
    
    self:rechargeCallBack("success", Language:getTextByKey("new_str_0533"), goods_id)
    if self.m_pay_test ~= true then
        self:paySuccessToBi(payInfo)
    end
    local money_type = "USD"

    local cfg = self:getChargeCfg(goods_id)

    local price_show = ConfigManager:getCfgByName("price_show")
    local payPrice = price_show[cfg.price][money_type]
    
    local val = 
    {
        payInfoPrice = payInfo.price,
        goods_id = goods_id,
        price = payPrice,
        currency = money_type
    }

    StatisticsUtil:doAppsFlyerPoint("af_purchase","Purchase", val)
end

--- 支付取消
function M:payCancel(payInfo)
    if payInfo and payInfo.goods_id then
        GameUtil:sendPayment(payInfo.goods_id, 3)
    end
    self:rechargeCallBack("cancel", Language:getTextByKey("new_str_0536"))
end

--- 支付失败
function M:payFailed(payInfo, errorMsg)
    if payInfo and payInfo.goods_id then
        GameUtil:sendPayment(payInfo.goods_id, 4)
    end
    self:rechargeCallBack("failed", errorMsg or Language:getTextByKey("new_str_0534"))
end

--- 自动关掉loading
function M:autoCloseLoading(delay_time)
    delay_time = delay_time or 10
    EventDispatcher:registerTimeEvent(
            "auto_close_loading_timer",
            function()
                self:closeLoading()
            end,
            delay_time,
            delay_time
    )
end

function M:closeLoading()
    if static_rootControl then
        static_rootControl:closeView("Loading.SmallLoading", "pay_small_loading")
    end
end

function M:payBeginToBi(payInfo)
end

function M:paySuccessToBi(payInfo)
end

--- 关闭支付
function M:close()
    self:destory()
end

function M:destory()
    self.m_callBack = nil
    self.m_ios_currency = nil
end

return M
