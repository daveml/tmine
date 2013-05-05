-- tbuild
--local tposLib = assert(loadfile('/rom/apis/tpos'))
local tposLib = assert(loadfile('/downloads/tbuild/tpos.lua'))
tposLib()

local args = {...}

function usage()
	print("--tmine")
	print("usage: tmine z x y [zr xr yr]")

end

function clearBlock()
	turtle.turnLeft()
	turtle.turnLeft()
	turtle.dig()
	turtle.turnLeft()
	turtle.turnLeft()
end

function buildYHollow(jQ, tpos, z, x, y)
	cz = tpos.z
	cx = tpos.x
	cy = tpos.y
	h=1
	if y < 0 then
		y = -y
		h=-1
	end
	for height=1, y do
		jobQueue.pushright(jQ, {Q_tposMoveRel, {tpos, z, x, 0}})
		jobQueue.pushright(jQ, {Q_tposMoveRel, {tpos, -z, -x, 0}})
		jobQueue.pushright(jQ, {Q_tposMoveRel, {tpos, 0, 0, h}})
	end
	return ((z+1)*(x+1)*(y))
end

function buildZFill(jQ, tpos, z, x, y)
	jobQueue.pushright(jQ, { Q_tposSavePosition, {tpos, 1}})
	local h=1
	if y < 0 then
		y = -y
		h=-1
	end
	local moves=0
	local dir = 1
	for height=1, y do
		for width=1, x+1 do
			jobQueue.pushright(jQ, {Q_tposMoveRel, {tpos, (z-1)*dir, 0, 0}})
			moves = moves+z
			if dir==1 then 
				dir = -1 
			else
				dir = 1
			end

			if width == x then break end
			
			jobQueue.pushright(jQ, {Q_tposMoveRel, {tpos, 0, 1, 0}})
			moves = moves+1

		end
		height=height+1
		if heighty>y then break end

		jobQueue.pushright(jQ, {Q_tposMoveRel, {tpos, 0, 0, 1*h}})
		moves=moves+1

		for width=1, x+1 do
			jobQueue.pushright(jQ, {Q_tposMoveRel, {tpos, (z-1)*dir, 0, 0}})
			moves = moves+z
			if dir==1 then 
				dir = -1 
			else
				dir = 1
			end
			
			if width == x then break end

			jobQueue.pushright(jQ, {Q_tposMoveRel, {tpos, 0, -1, 0}})
			moves = moves+1
			
		end
	
		jobQueue.pushright(jQ, {Q_tposMoveRel, {tpos, 0, 0, 1*h}})
		moves=moves+1
	end
	jobQueue.pushright(jQ, {Q_tposPlaceModeDisable, {tpos}})
	jobQueue.pushright(jQ, {Q_tposRecallMoveRel, {tpos, 1, 0,0,1}})
	moves = moves + z + x + y
	return moves
end

function buildReturn(jQ, tpos, CanBreak)
	jobQueue.pushright(jQ, {Q_tposPlaceModeDisable, {tpos}})
	if CanBreak == false then
		jobQueue.pushright(jQ, {Q_tposBreakOnMoveDisable, {tpos}} )
	end
	jobQueue.pushright(jQ, {Q_tposMoveAbs, {tpos, 0, 0, 0}} )
	if CanBreak == false then
		jobQueue.pushright(jQ, {Q_tposBreakOnMoveEnable, {tpos}} )
	end
--	return tposGetDistance(tpos,0,0,0)
end

function buildBegin(jQ, tpos)
	jobQueue.pushright(jQ, {Q_tposBreakOnMoveEnable, {tpos}} )
	jobQueue.pushright(jQ, {Q_tposPlaceModeDisable, {tpos}} )
	jobQueue.pushright(jQ, {Q_tposMoveRel, {tpos, 1, 0, 0}} )
--	jobQueue.pushright(jQ, {Q_tposPlaceModeEnable, {tpos}} )
	return 1
end

function main(args)
	
	local zm = tonumber(args[1])
	local xm = tonumber(args[2])
	local ym = tonumber(args[3])

	local zr = tonumber(args[4])
	local xr = tonumber(args[5])
	local yr = tonumber(args[6])

	if zm == nil or xm == nil or ym == nil then
		usage()
		return
	end

	if zr ~= nil then
		if xr == nil or yr == nil then
			usage()
			return
		end
		print("Move to rel coord: "..zr.." "..xr.." "..yr)
	end

    if myTpos == nil then
		myTpos = tposInit()
	end
	
	tposShow(myTpos)
	
 	tposSetPlaceSlot(myTpos,2)

	jQ = jobQueue.new()

	fuelReq1 = buildBegin(jQ, myTpos)
	fuelReqR = 0
	if zr ~= nil then
		jobQueue.pushright(jQ, {Q_tposMoveRel, {myTpos, zr, xr, yr}})
		fuelReqR = math.abs(zr) + math.abs(xr) + math.abs(yr)
	end
	fuelReq2 = buildZFill(jQ, myTpos, zm, xm, ym)
--	fuelReq3 = buildYHollow(jQ, myTpos, zm, xm, ym)
--	fuelReq4 = buildZFill(jQ, myTpos, zm, xm, 1)
	fuelReq3 = buildReturn(jQ, myTpos, true)

	if Refuel(1,(fuelReq1+fuelReq2+fuelReqR)) == false then
		return
	end

	tposSetPlaceSlot(myTpos, 2)

	jobQueue.run(jQ)

end

main(args)

return