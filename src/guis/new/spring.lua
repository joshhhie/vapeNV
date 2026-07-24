return function(Flipper)
	local motors = {}
	local opts = { frequency = 4, dampingRatio = 1 }

	local function round(n)
		return n >= 0 and math.floor(n + 0.5) or math.ceil(n - 0.5)
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
			if on_complete then
				motor:onComplete(on_complete)
			end
			motors[key] = motor
		end
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
			if on_complete then
				motor:onComplete(on_complete)
			end
			motors[key] = motor
		end
		motor:setGoal(Flipper.Spring.new(target, options or opts))
	end

	return spring
end
