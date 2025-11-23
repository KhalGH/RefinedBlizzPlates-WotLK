-- 兼容 WotLK 3.3.5a 的 C_Timer (Brothers_老高)
-- 1. C_Timer.After(seconds, func)                  --- 延迟执行一次
-- 2. C_Timer.NewTicker(seconds, func, iterations?) --- 定期执行，可指定次数，支持取消
-- 3. Cancel 功能                                   --- 可以停止计时器

-- 检查是否存在 Details 插件，如果存在则不运行此库
if not Details and not C_Timer then
    C_Timer = {}

    -- After: 延迟执行一次
    function C_Timer.After(t, func)
        local f = CreateFrame("Frame")
        local elapsed = 0
        f:SetScript("OnUpdate", function(self, e)
            elapsed = elapsed + e
            if elapsed >= t then
                self:SetScript("OnUpdate", nil)
                func()
            end
        end)
        return f
    end

    -- NewTicker: 定期执行，可选执行次数
    function C_Timer.NewTicker(interval, func, iterations)
        local f = CreateFrame("Frame")
        local elapsed = 0
        local count = 0
        local ticker = {}

        ticker._frame = f
        ticker._cancelled = false

        function ticker:Cancel()
            if f then
                f:SetScript("OnUpdate", nil)
                f = nil
            end
            self._cancelled = true
        end

        f:SetScript("OnUpdate", function(self, e)
            if ticker._cancelled then return end
            elapsed = elapsed + e
            while elapsed >= interval do
                elapsed = elapsed - interval
                count = count + 1
                func()
                if iterations and count >= iterations then
                    ticker:Cancel()
                    break
                end
            end
        end)

        return ticker
    end

    -- NewTimer: 返回类似官方 C_Timer.NewTimer 对象（封装 After）
    function C_Timer.NewTimer(t, func)
        local timer = {}
        local f = C_Timer.After(t, function()
            if timer._cancelled then return end
            func()
        end)
        timer._frame = f
        timer._cancelled = false
        function timer:Cancel()
            if f then
                f:SetScript("OnUpdate", nil)
                f = nil
            end
            self._cancelled = true
        end
        return timer
    end
end