--[[
    Custom tween
    Works with drawing objects
]]

local Signal = loadstring(game:HttpGet("https://raw.githubusercontent.com/vozoid/utility/main/Signal.lua"))()

--[[
    Easing styles math: https://www.desmos.com/calculator/m8myals511
    Add more EasingStyles by doing this:
    Convert the math (example: 1.001 · -2⁻¹⁰ˣ + 1 to something like
    {name} = function(delta)
        return 1.001 * (-2 ^ (-10 * delta)) + 1
    end
]]

local Tween = {}

do
    -- Localization
    local render_stepped = game:GetService("RunService").RenderStepped
    local tick = tick
    local math_min = math.min
    local task_defer = task.defer
    local task_wait = task.wait
    local next = next
    local math_sqrt = math.sqrt
    local math_sin = math.sin
    local pi = math.pi

    -- All the math for the different EasingStyles with the EasingDirection In
    Tween[Enum.EasingDirection.In] = {
        [Enum.EasingStyle.Linear] = function(delta)
            return delta
        end,

        [Enum.EasingStyle.Exponential] = function(delta)
            return (2 ^ (10 * delta - 10)) - 0.001
        end,

        [Enum.EasingStyle.Quad] = function(delta)
            return delta ^ 2
        end,

        [Enum.EasingStyle.Quart] = function(delta)
            return delta ^ 4
        end,

        [Enum.EasingStyle.Quint] = function(delta)
            return delta ^ 5
        end,

        [Enum.EasingStyle.Circular] = function(delta)
            return -math_sqrt(1 - (delta ^ 2)) + 1
        end,

        [Enum.EasingStyle.Sine] = function(delta)
            return math_sin(((pi / 2) * delta) - (pi / 2)) + 1
        end,

        [Enum.EasingStyle.Cubic] = function(delta)
            return delta ^ 3
        end
    }

    -- All the math for the different EasingStyles with the EasingDirection Out
    Tween[Enum.EasingDirection.Out] = {
        [Enum.EasingStyle.Linear] = function(delta)
            return delta
        end,

        [Enum.EasingStyle.Exponential] = function(delta)
            return 1.001 * (-2 ^ (-10 * delta)) + 1
        end,

        [Enum.EasingStyle.Quad] = function(delta)
            return -(delta - 1) ^ 2 + 1
        end,

        [Enum.EasingStyle.Quart] = function(delta)
            return -(delta - 1) ^ 4 + 1
        end,

        [Enum.EasingStyle.Quint] = function(delta)
            return (delta - 1) ^ 5 + 1
        end,

        [Enum.EasingStyle.Circular] = function(delta)
            return math_sqrt((-(delta - 1) ^ 2) + 1)
        end,

        [Enum.EasingStyle.Sine] = function(delta)
            return math_sin((pi / 2) * delta)
        end,

        [Enum.EasingStyle.Cubic] = function(delta)
            return ((delta - 1) ^ 3) + 1
        end
    }

    Tween.__index =  Tween

    -- Function to support number lerping
    local function lerp(value1, value2, alpha)
        if type(value1) == "number" then
            return value1 + ((value2 - value1) * alpha)
        end
            
        return value1:lerp(value2, alpha)
    end

    --[[
        Creates a new tween
        @return Tween (table)
    ]]

    function Tween.new(object, info, values)
        local self = setmetatable({}, Tween)

        self.Completed = Signal.new()
        self._object = object
        self._time = info.Time or 0.1
        self._easingDirection = info.EasingDirection
        self._easingStyle = Tween[self._easingDirection][info.EasingStyle]
        self._values = values

        return self
    end

    --[[
        Plays the tween
    ]]

    function Tween:Play()
        local loops = {}

        -- Loop through every property to edit
        for property, value in next, self._values do
            local start_time = tick()
            local start_value = self._object[property]
            local stopped = false

            loops[#loops + 1] = render_stepped:Connect(function()
                local delta = (tick() - start_time) / self._time

                -- Do the chosen EasingStyle's math
                local alpha = self._easingStyle(delta)

                task_defer(function()
                    self._object[property] = lerp(start_value, value, alpha)
                end)
            end)
        end

        task_defer(function()
            task_wait(self._time)

            -- Sets every property
            for property, value in next, self._values do
                self._object[property] = value
            end

            -- Disconnects every loop
            for _, connection in next, loops do
                connection:Disconnect()
            end

            self.Completed:Fire()
        end)
    end
end

return Tween
