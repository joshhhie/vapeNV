return function(Flipper)
	local motors = {}
	local opts = { frequency = 4, dampingRatio = 1 }

	local function round(n)
		return n >= 0 and math.floor(n + 0.5) or math.ceil(n - 0.5)
	end

	local function bindComplete(motor, on_complete)
		if motor._done then
			motor._done:disconnect()
			motor._done = nil
		end
		if on_complete then
			motor._done = motor:onComplete(on_complete)
		end
	end

	local spring = {}

	function spring:Stop(obj, prop)
		local key = tostring(obj) .. prop
		local motor = motors[key]
		if motor then
			motor:destroy()
			motors[key] = nil
		end
	end

	function spring:Prop(obj, prop, target, options, on_complete)
		local key = tostring(obj) .. prop
		local motor = motors[key]
		if not motor then
			motor = Flipper.SingleMotor.new(obj[prop], true)
			motor:onStep(function(v)
				obj[prop] = v
			end)
			motors[key] = motor
		end
		bindComplete(motor, on_complete)
		motor:setGoal(Flipper.Spring.new(target, options or opts))
	end

	function spring:Height(obj, target, width, options, on_complete)
		local key = tostring(obj) .. 'h'
		local motor = motors[key]
		if not motor then
			motor = Flipper.SingleMotor.new(obj.Size.Y.Offset, true)
			motor:onStep(function(y)
				y = round(y)
				if width then
					obj.Size = UDim2.fromOffset(width, y)
				else
					obj.Size = UDim2.new(obj.Size.X.Scale, obj.Size.X.Offset, 0, y)
				end
			end)
			motors[key] = motor
		end
		bindComplete(motor, on_complete)
		motor:setGoal(Flipper.Spring.new(target, options or opts))
	end

	function spring:HeightInstant(obj, target, width)
		self:Stop(obj, 'h')
		local y = round(target)
		if width then
			obj.Size = UDim2.fromOffset(width, y)
		else
			obj.Size = UDim2.new(obj.Size.X.Scale, obj.Size.X.Offset, 0, y)
		end
	end

	function spring:Rotation(obj, target, options, on_complete)
		local key = tostring(obj) .. 'r'
		local motor = motors[key]
		if not motor then
			motor = Flipper.SingleMotor.new(obj.Rotation, true)
			motor:onStep(function(r)
				obj.Rotation = r
			end)
			motors[key] = motor
		end
		bindComplete(motor, on_complete)
		motor:setGoal(Flipper.Spring.new(target, options or opts))
	end

	function spring:SlideX(obj, target, options, on_complete)
		local key = tostring(obj) .. 'x'
		local motor = motors[key]
		if not motor then
			motor = Flipper.SingleMotor.new(obj.Position.X.Offset, true)
			motor:onStep(function(x)
				obj.Position = UDim2.new(obj.Position.X.Scale, round(x), obj.Position.Y.Scale, obj.Position.Y.Offset)
			end)
			motors[key] = motor
		end
		bindComplete(motor, on_complete)
		motor:setGoal(Flipper.Spring.new(target, options or opts))
	end

	return spring
end
