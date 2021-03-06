local uetorch = require 'uetorch'
local block = {}

local sphere = uetorch.GetActor("Sphere_4")
local wall = uetorch.GetActor("Wall_400x200_8")
block.actors = {sphere=sphere, wall=wall}
local possible = true

local camera = uetorch.GetActor("MainMap_CameraActor_Blueprint_C_1")

local function InitSphere()
	local forceX = math.random(800000, 1100000)
	local forceY = 0
	local forceZ = math.random(800000, 1000000)
	local signZ = 2 * math.random(2) - 3
	local left = math.random(0,1)

	if left == 1 then
		uetorch.SetActorLocation(sphere, -400, -550, 70 + math.random(200))
	else
		uetorch.SetActorLocation(sphere, 500, -550, 70 + math.random(200))
		forceX = -forceX
	end

	uetorch.AddForce(sphere, forceX, forceY, signZ * forceZ)
end

local t_rotation = 0
local t_rotation_change = 0
local framesStartDown
local framesRemainUp

local function WallRotationDown(dt)
	local angle = (t_rotation - t_rotation_change) * 20
	uetorch.SetActorRotation(wall, 0, 0, angle)
	if angle >= 90 then
		uetorch.RemoveTickHook(WallRotationDown)
		t_rotation_change = t_rotation
	end
	t_rotation = t_rotation + dt
end

local function RemainUp(dt)
	framesRemainUp = framesRemainUp - 1
	if framesRemainUp == 0 then
		uetorch.RemoveTickHook(RemainUp)
		uetorch.AddTickHook(WallRotationDown)
	end
end

local function WallRotationUp(dt)
	local angle = (t_rotation - t_rotation_change) * 20
	uetorch.SetActorRotation(wall, 0, 0, 90 - angle)
	if angle >= 90 then
		uetorch.RemoveTickHook(WallRotationUp)
		uetorch.AddTickHook(RemainUp)
		t_rotation_change = t_rotation

		if math.random(2) == 1 then
			sphere_visible = true
		else
			sphere_visible = false
			possible = false
		end
		uetorch.SetActorVisible(sphere, sphere_visible)
	end
	t_rotation = t_rotation + dt
end

local function StartDown(dt)
	framesStartDown = framesStartDown - 1
	if framesStartDown == 0 then
		uetorch.RemoveTickHook(StartDown)
		uetorch.AddTickHook(WallRotationUp)
	end
end

function block.SetBlock()
	framesStartDown = math.random(5)
	framesRemainUp = math.random(5)
	uetorch.AddTickHook(WallRotationUp)
	uetorch.SetActorLocation(camera, 100, 30, 80)
	uetorch.SetActorLocation(wall, -100, -350, 20)
	uetorch.SetActorRotation(wall, 0, 0, 90)
	InitSphere()
end

function block.IsPossible()
	return possible
end

return block