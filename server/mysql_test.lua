class "MySQLTest"
local devmode = false
function MySQLTest:__init()
	self.vehicles               = {}
	self.vid					= {}
	self.vowner					= {}
	self.vlocked				= {}
	self.sellable				= {}
	self.prize					= {}
	-- Initialize LuaSQL Module
	local luaSql = require('luasql.mysql')
	
	-- Initialize MySQL connector
	local connector = luaSql.mysql()
	
	-- Connect to the MySQL server, and grab the connection, and the error.
	-- (database[, username[, password[, hostname[, port]]]]), [] = optional
	local connection, err = connector:connect("", "", "", "", 3306)
	
	-- There is an error, print it and exit module
	if err ~= nil then
		print("Failed to connect to MySQL: " .. tostring(err))
		return
	end
	
	-- Save connection for later use
	self.sqlConnection = connection
	
	-- Call SetUpSql function. If it returns false, stop initializing
	if not self:SetUpSql() then return end

	-- Subscribe to unload event, so we can close the MySQL connection
	Events:Subscribe("ModuleUnload", self, self.ModuleUnload)
	Events:Subscribe("PlayerEnterVehicle", self, self.EnterVehicle)
	Events:Subscribe( "PlayerChat", self, self.PlayerChat )
end

function MySQLTest:SetUpSql()
	local result = self.sqlConnection:execute("SELECT * FROM `jc2mp_vehicle` WHERE 1")
	if result == nil then
		print("VO: Could not get vehicle information.")
		return
	end
	if result:numrows() <= 0 then
		print("VO: Vehicle information not found.")
		return
	end
	
	local row = result:fetch({})
	
	while row != nil do
		-- print("VEH: ", row[1], row[2],row[3], row[4],row[5], row[6], row[7], row[8], row[9], row[10], row[11], row[12])
		local model_id  = row[2]
		local pos       = { row[3], row[4], row[5] }
		local ang       = { row[6], row[7], row[8], row[9] }
		
		local args = {} 
		 args.model_id       = tonumber( model_id )
		 args.position       = Vector3(   tonumber( pos[1] ), 
                                    tonumber( pos[2] ),
                                    tonumber( pos[3] ) )

		args.angle          = Angle(    tonumber( ang[1] ),
                                    tonumber( ang[2] ),
                                    tonumber( ang[3] ),
                                    tonumber( ang[4] ) )
		
		if row[10] ~= "NULL" then
			args.template = row[10]
		end

		if row[11] ~= "NULL" then
			args.decal = row[11]
		end
		
		args.enabled = true
		local v = Vehicle.Create( args )
		self.vehicles[ v:GetId() ] = v
		self.vid[tonumber(row[1])] = v:GetId()
		self.vowner[tonumber(row[1])] = row[12]
		self.vlocked[tonumber(row[1])] = row[13]
		self.sellable[tonumber(row[1])] = row[14]
		self.prize[tonumber(row[1])] = row[15]
		print (self.vid[1])
		row = result:fetch({})
	end
	return true
end

function MySQLTest:ModuleUnload()
	-- Connection was never initialized
	if self.sqlConnection == nil then return end
	
	-- Close connection
	self.sqlConnection:close()
	
	for k,v in pairs(self.vehicles) do
        if IsValid(v) then
            v:Remove()
        end
    end
end

function MySQLTest:EnterVehicle(args)
	if args.player:GetState() == PlayerState.InVehiclePassenger then
		return
	end
	for k,v in pairs(self.vid) do
		if (args.vehicle:GetId() == self.vid[k])
		then
			local locked;
			if (tonumber(self.vlocked[k]) == 1) then
				locked = "Yes"
			else
				locked = "No"
			end
			args.player:SendChatMessage("* Owner: " .. self.vowner[k] .. " | " ..  "Locked: " .. locked, Color(0xfff0b010) )
			if (tostring(args.player:GetSteamId().id) == tostring(self.vowner[k])) then
				args.player:SendChatMessage("* Welcome back to your car!", Color(0,255,0) )
				if (tonumber(self.sellable[k]) == 1) then
					args.player:SendChatMessage("* Your car is now selling with $" .. self.prize[k] .. ".", Color(0,255,0) )
				end
			else
				if (tonumber(self.sellable[k]) == 1) then
					args.player:SendChatMessage("* This vehicle is on sale, take it by cost $" .. self.prize[k] .. " (/buyvehicle)",Color(0,255,0))
				end
			end
			if (tonumber(self.vlocked[k]) == 1 and tonumber(self.sellable[k]) ~= 1) then
				if (tostring(args.player:GetSteamId().id) ~= tostring(self.vowner[k])) then
					args.player:SendChatMessage("* You do not have key of this vehicle!", Color(255,0,0) )
					args.player:SetPosition(args.player:GetPosition())	
				end
			end
		end
    end
end

function MySQLTest:PlayerChat( args )
    local msg = args.text
	local veh = args.player:GetVehicle()
	
	if msg == "/buyvehicle" then
		if (devmode==true)then
			args.player:SendChatMessage("In Development!", Color(255,0,0) )
		return end
		if (args.player:InVehicle()==false)then
			args.player:SendChatMessage("You do not in car!", Color(255,0,0) )
		return end
		for k,v in pairs(self.vid) do
			if (veh:GetId() == self.vid[k]) then
				if (self.vowner[k] == tostring(args.player:GetSteamId().id)) then
					args.player:SendChatMessage("* You are the owner already!", Color(255,0,0) )
					return
				end
				if (self.sellable[k] == tostring(1)) then
					if (args.player:GetMoney() >= tonumber(self.prize[k])) then
						args.player:SendChatMessage("* Succeed bought this vehicle! This vehicle is belong to you now!", Color(0,255,0) )
						args.player:SetMoney(args.player:GetMoney()  - tonumber(self.prize[k]))
						self.vowner[k] = tostring(args.player:GetSteamId().id)
						self.sellable[k] = 0
						local result = self.sqlConnection:execute("UPDATE `jc2mp_vehicle` SET  `owner` =  '" .. self.vowner[k] .. "',`sellable` = '0' WHERE  `ID` = " .. k)
						if result == nil then
							args.player:SendChatMessage("System Error! Please contact admin!", Color(255,0,0) )
							return
						end
					else
						args.player:SendChatMessage("* You do not have enough money to buy this vehicle! ($" .. self.prize[k] .. ")", Color(255,0,0) )
					end
				else
					args.player:SendChatMessage("* This vehicle is not for sale!", Color(255,0,0) )
				end
			end
		end
	end
    if msg == "/lock" then
		if (devmode==true)then
			args.player:SendChatMessage("In Development!", Color(255,0,0) )
		return end
		if (args.player:InVehicle()==false)then
			args.player:SendChatMessage("You do not in car!", Color(255,0,0) )
		return end
		for k,v in pairs(self.vid) do
			if (veh:GetId() == self.vid[k])
			then
				if (tostring(args.player:GetSteamId().id) ~= tostring(self.vowner[k])) then
					args.player:SendChatMessage("You do not have key of this vehicle!", Color(255,0,0) )
				else
					if (tonumber(self.vlocked[k]) == 1) then
						self.vlocked[k] = 0
						args.player:SendChatMessage("Vehicle has been unlocked!", Color(0,255,0) )
						local result = self.sqlConnection:execute("UPDATE `jc2mp_vehicle` SET  `locked` =  '0' WHERE  `ID` = " .. k)
						if result == nil then
							args.player:SendChatMessage("System Error! Please contact admin!", Color(255,0,0) )
							return
						end
					else
						self.vlocked[k] = 1
						args.player:SendChatMessage("Vehicle has been locked!", Color(0,255,0) )
						local result = self.sqlConnection:execute("UPDATE `jc2mp_vehicle` SET  `locked` =  '1' WHERE  `ID` = " .. k)
						if result == nil then
							args.player:SendChatMessage("System Error! Please contact admin!", Color(255,0,0) )
							return
						end
					end
				end
			end
		end
	end
	
	if msg == "/park" then
		if (devmode==true)then
			args.player:SendChatMessage("In Development!", Color(255,0,0) )
		return end
		if (args.player:InVehicle()==false)then
			args.player:SendChatMessage("You do not in car!", Color(255,0,0) )
		return end
		for k,v in pairs(self.vid) do
			if (veh:GetId() == self.vid[k])
			then
				if (tostring(args.player:GetSteamId().id) ~= tostring(self.vowner[k])) then
					args.player:SendChatMessage("You do not have key of this vehicle!", Color(255,0,0) )
				else
					local pos = veh:GetPosition()
					local ang = veh:GetAngle()
					local query = "UPDATE `jc2mp_vehicle` SET  `pos1` =  '" .. pos.x .. "',`pos2` =  '" .. pos.y .. "',`pos3` =  '" .. pos.z .. "',`ang1` =  '" .. ang.x .. "',`ang2` =  '" .. ang.y .. "',`ang3` =  '" .. ang.z .. "',`ang4` =  '" .. ang.w .. "' WHERE  `jc2mp_vehicle`.`ID` =" .. k
					
					local result = self.sqlConnection:execute(query)
					if result == nil then
						args.player:SendChatMessage("System Error! Please contact admin!", Color(255,0,0) )
						return
					end
					args.player:SendChatMessage("Vehicle has been parked, it will be aliveable when the database refresh!", Color(0,255,0) )
				end
			end
		end
	end
end
-- Initialize class/module
MySQLTest()