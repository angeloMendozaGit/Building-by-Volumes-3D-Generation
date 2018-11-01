--initializing some important variables
--testing y axis rotation seems to not be functional beware but everything else is fine
local blocks = 0;

local rate = 12; -- divisor of 360 of volume rotations
local interval = 0.02; -- this is going to be the interval of each block generated
local boundLimit = 0.05;
local distance = -workspace.GraphProperties.lineOfRevolution.Value; -- temporary
local distanceAdjustment = 1;

if distance > 1 then
	distanceAdjustment = math.abs(distance);
end

local gp = workspace.GraphProperties;
local win = gp.Window
local xBounded = gp.boundedXAxis.Value;
local yBounded = gp.boundedYAxis.Value;
local area = game.Workspace.area

--check if x or y bounded
if xBounded then
	win.yMin.Value = 0;
	gp.f2.Value = "";
end

if yBounded then
	win.xMin.Value = 0;
end

local revx = gp.RevolveXAxis.Value;
local revy = gp.RevolveYAxis.Value;
local cs = gp.CrossSection;
local cross = gp.CrossSection.Value;
local xMin = win.xMin.Value;
local xMax = win.xMax.Value;
local yMin = win.yMin.Value;
local yMax = win.yMax.Value;
local cpHeight = yMax - yMin;
local cpLength = xMax - xMin;
local f1 = gp.f1;
local f2 = gp.f2;
local lowerLimit = gp.lowerLimit.Value;
local upperLimit = gp.upperLimit.Value;
local regionBounded = false;

--alright we're gonna just have some error checkings over here

if (xMax <= xMin) or (yMax <= yMin) then
	assert(false, "ERROR: Dimensions of graph are not correct");
	do return end;
end

if (lowerLimit > upperLimit) then
	assert(false, "ERROR: The lower limit is greater than the upper limit");
	do return end;	
end
	
if (lowerLimit < xMin or upperLimit > xMax) then
	assert(false, "ERROR: Limits are out of bounds");
	do return end;
end	

if (not revx and not revy and not cross) then
		assert(false, "ERROR: MUST CHOOSE ONE: revolve around x-axis, y-axis, or a cross section.")
	do return end;
end

if ( (revx and revy) or (revx and cross) or (cross and revy) ) then
	assert(false, "ERROR: Choose one only: revolve around x-axis, y-axis, or a cross section.")
	do return end;
end

--------------------------------hold on this is a rounding function over here and others

function round(value,Place)
	if Place ~= nil then
		local Place = tostring(Place)
		Place = string.len(Place) 
	else
		Place = 1
	end
	local Increment = .5 * Place
	value = value + Increment
	value = value / Place
	value = math.floor(value)
	value = value * Place
	return value;
end

function inBounds(x1, x2)  -- essentially because we can only graph to increments of 2 hundredeths, there will always
	-- be some sort of rounding/accuracy error, once the functions get large we are no longer able to guarantee that
	-- the bounds will always be equal to each other
	-- this function will ensure that those larger graphs are still able to find bounds
	-- however this will come at a cost to the accuracy of the smaller graphs, but it is a good trade off
	x1 = round(x1,0.01);
	x2 = round(x2,0.01);
	
	if (math.abs(x1 - x2) <= boundLimit) then
		return true;
	end
end


------------------------------------------------------------Let's Create the Cartesian Plane 

local cp = game.ReplicatedStorage.cp:clone();
local Background = cp.Background;


Background.Size = Vector3.new(cpLength, cpHeight, 0);
Background.CFrame = CFrame.new((xMax + xMin) / 2, (yMax + yMin) / 2, -0.315);
cp.Parent = workspace;
	
for l = yMin, yMax, 1 do -- creating horiztonal lines
	local hLine = game.ReplicatedStorage.hLine:Clone();
	hLine.Size = Vector3.new(cpLength, 0.2, 0.2);
	hLine.CFrame = CFrame.new((xMax + xMin) / 2, l, -0.3);
	hLine.Parent = cp.Lines;
		
end
	
for h = xMin, xMax, 1 do -- creating vertical lines
	local vLine = game.ReplicatedStorage.vLine:Clone();
	vLine.Size = Vector3.new(0.2, cpHeight, 0.2);
	vLine.CFrame = CFrame.new(h, (yMax + yMin) / 2, -0.3);
	vLine.Parent = cp.Lines;
		
end
	
cp.xAxis.Size = Vector3.new(cpLength, 0.2, 0.2); -- changing the dimensions and position of the  axes as needed
cp.xAxis.CFrame = CFrame.new((xMax + xMin) / 2, -0, -0.3);
cp.yAxis.Size = Vector3.new(0.2, cpHeight, 0.2);
cp.yAxis.CFrame = CFrame.new(0, (yMax + yMin) / 2, -0.3);
	
if ((xMin <= 0 and xMax >= 0) == false) then -- if the dimensions of the graph do need need an axis delete the axis
	cp.yAxis:Destroy();	
end

if ((yMin <= 0 and yMax >= 0) == false) then
	cp.xAxis:Destroy();
end

------------------------------------------------------------Drawing the graph

--f1.Value = "y = "..f1.Value; -- adjusting string value of f1 to be loadstring compatible

local f1table = {}; -- we are going to store all the values in these tables now 
local f2table = {};

for i = lowerLimit, upperLimit, interval do -- we will actually just use these to graph the points and fill in the spaces later
	
	
	x = i; -- must declare global variable x as i is local, loadstring doesnt work with local variables
	loadstring(f1.Value)() -- have to use loadstring because can't directly edit scripts due to security concerns
	table.insert(f1table, y);
	
	if (y >= yMin and y <= yMax) and (x >= xMin and x <= xMax) then -- ignore y initialization error, will be intialized in loadstring

		local Point = game.ReplicatedStorage.Point:Clone();
		Point.Mesh.Scale = Vector3.new(0.1, 0.1, 0.1);
		Point.CFrame = CFrame.new(x, y - 0.05, -0.2);
		Point.Parent = workspace.points;
	
		
	end


end

if (f2.Value ~= "") then -- only if there is a second equation
	
	regionBounded = true -- enable activation of region bounding equations

	--f2.Value = "y = "..f2.Value; -- adjusting string value of f2 to be loadstring compatible
	
	for i = lowerLimit, upperLimit, interval do
		
		
		x = i; -- must declare global variable x as i is local, loadstring doesnt work with local variables
		loadstring(f2.Value)() -- have to use loadstring because can't directly edit scripts due to security concerns
		table.insert(f2table, y);
		
		if (y >= yMin and y <= yMax) and (x >= xMin and x <= xMax) then -- ignore y initialization error, will be intialized in loadstring
	
			local Point = game.ReplicatedStorage.Point:Clone();
			Point.Mesh.Scale = Vector3.new(0.1, 0.1, 0.1);
			Point.CFrame = CFrame.new(x, y - 0.05, -0.2);
			Point.Parent = workspace.points;
			
		end
	
	end

end
--filling in the area

startPos = 0;
endPos = #f1table; -- size of the table

--[[if regionBounded then -- temp fix

	startPos = nil;
	endPos = nil;
		
	for i,v in pairs (f1table) do -- this loop will determine the limits to which the area is bounded
		
	
		local f1value = round(f1table[i],0.01);
		local f2value = round(f2table[i], 0.01);
	
		if (inBounds(f1value,f2value) and startPos == nil) then
			startPos = i;
		elseif inBounds(f1value,f2value) then
			endPos = i;
		end
			
	end
	
	if (startPos == nil or endPos == nil) then
		assert(false, "ERROR: There is no region bounded.");
		do return end;	
	end

end]]

for i = startPos, endPos do -- this will fill in the area which is bounded as determined by the upper loop

		local f1value = f1table[i];
		local f2value;
		if regionBounded then -- if the region is not bounded then just default bounded by the x axis
			f2value = f2table[i];
		else
			f2value = 0;
		end
		
		if (f1value ~= nil and f2value ~= nil) and (f1value >= yMin and f1value <= yMax) and(f2value >= yMin and f2value <= yMax)  then
			local height = math.abs(f1value - f2value); -- calculates the differece between the two graphs
			local startPos = (f1value + f2value) / 2;
			local xpos = lowerLimit + (i * interval) - interval; -- extra - interval to account that i starts at 1 and not 0
			
	
			local Point = game.ReplicatedStorage.Point:Clone();
			Point.Mesh.Scale = Vector3.new(0.1, height, 0.1);
			Point.CFrame = CFrame.new(xpos, startPos, -0.2);
			Point.Parent = workspace.area;
		end
end



--okay lets rotate the objects

wait(2)



local totalVolume = 0;

function revolveXAxis()

	for _,v in pairs (workspace.area:getChildren()) do 
		
		local radius = v.Mesh.Scale.y; -- radius 
		local surfaceArea = math.pi * ((radius + distance)^2) * interval; -- surface area
		local washerAdjust = math.pi * (distance^2) * interval;
		totalVolume = totalVolume + surfaceArea - washerAdjust;
		
	
		for angle = 1, 360, rate do
			
			local vClone = v:clone();
			vClone.Parent = workspace.container
		
			local 	thisFrame = (CFrame.new(v.CFrame.x, v.CFrame.y - distance, v.CFrame.z)- Vector3.new(0, radius / 2, 0))	-- rotate from that position
			       				* CFrame.Angles(math.rad(angle), 0, 0) -- angle of revolution
					 			* CFrame.new(0, radius / 2,0) -- adjust for initial positions
								* CFrame.new(0, distance, 0); --  adjust for washer method
			                      
			vClone.CFrame = thisFrame;
			blocks = blocks + 1;
			vClone.Mesh.Scale = vClone.Mesh.Scale + Vector3.new(0,0, 2 * math.pi * (radius + math.abs(distance)) / ( 360 / rate) ); -- changing the width of the blocks
			-- okay so basically what we did here was find the circumference of each circle and divide that by the number of blocks we have
			-- this solved the problem of having overlap, or worse the circles not filling into completion that was a common bug earlier
	

		end
		
		wait(0.01)
	
	end

end

function revolveYAxis()
	
		for _,v in pairs (workspace.area:getChildren()) do 
		
			local radius = v.Mesh.Scale.y; -- radius 
			local surfaceArea = math.pi * ((radius + distance)^2) * interval; -- surface area
			local washerAdjust = math.pi * (distance^2) * interval;
			totalVolume = totalVolume + surfaceArea - washerAdjust;
			
		
			for angle = 1, 360, rate do
				
				local vClone = v:clone();
				vClone.Parent = workspace.container
		
				local 	thisFrame = (CFrame.new(v.CFrame.x, v.CFrame.y, v.CFrame.z)- Vector3.new(v.Position.X, v.Mesh.Scale.y / 2, 0)    	)	
			         * CFrame.Angles(0, math.rad(angle), 0)
					 * CFrame.new(0,v.Mesh.Scale.y / 2,0) -- this is the distance to revole from the axis
					 * CFrame.new(v.Position.X+2,0,0);
			                      
				vClone.CFrame = thisFrame;
				vClone.Mesh.Scale = vClone.Mesh.Scale + Vector3.new(0,0,2 * math.pi * (math.abs(v.CFrame.x) + distance) / ( 360 / rate));
				blocks = blocks + 1;
			
			end
			wait()	
	end
end

function crossSection() 
	
	totalVolume = 0; -- for non rectangular shapes we are only calculating volume for now, shapes are not available
	
	if cs.Squares.Value then
		
		for _,v in pairs (workspace.area:getChildren()) do
			local adjustment = v.Mesh.Scale.y
			totalVolume = totalVolume + (v.Mesh.Scale.y * adjustment * interval); -- volume function
			v.Mesh.Scale = v.Mesh.Scale + Vector3.new(0,0,adjustment)
			v.CFrame = v.CFrame + Vector3.new(0, 0,adjustment/2)
			wait()
		end

	elseif (cs.Rectangles.Value ~= "") then
		
		cs.Rectangles.Value = "adjustment = "..cs.Rectangles.Value..";";
		
		for _,v in pairs (workspace.area:getChildren()) do
			b = v.Mesh.Scale.y;
			loadstring(cs.Rectangles.Value)(); -- ignore blue adjustment error
			totalVolume = totalVolume + (v.Mesh.Scale.y * adjustment * interval); -- volume function
			v.Mesh.Scale = v.Mesh.Scale + Vector3.new(0,0,adjustment)
			v.CFrame = v.CFrame + Vector3.new(0, 0,adjustment/2)
			wait() 
		end
	elseif cs.Circles.Value then
		
		for _,v in pairs (workspace.area:getChildren()) do
			local r = v.Mesh.Scale.y / 2;		
			totalVolume = totalVolume + (r^2 * math.pi);
		end
		
		
	elseif cs.SemiCircles.Value then
		
		for _,v in pairs (workspace.area:getChildren()) do
			local r = v.Mesh.Scale.y / 2;		
			totalVolume = totalVolume + (r^2 * math.pi / 2);
		end
	
	elseif cs.EquilateralTriangle.Value then
		
		for _,v in pairs (workspace.area:getChildren()) do
			local a = v.Mesh.Scale.y;
			totalVolume = totalVolume + (math.sqrt(3)/4 * a^2);
		end
	end
end

if revx then -- this is going to run the actually revolving
	revolveXAxis();
elseif revy then
	revolveYAxis();
elseif cross then
	crossSection();
end



totalVolume = math.abs(totalVolume);
workspace.points:Destroy();
print("The approximate volume is around "..round(totalVolume, 0.001));
print(blocks.." is the number of objects generated.")
