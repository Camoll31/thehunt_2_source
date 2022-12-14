GM.Name = "TheHunt"
GM.Author = "Camoll"
GM.Email = ""
GM.Website = ""

net.Receive( "Scoreboard", function( length, client )
	local DermaPanel = vgui.Create( "DFrame" )
	DermaPanel:SetPos( ScrW() * 0.1, ScrH() * 0.1 )
	DermaPanel:SetSize( ScrW() * 0.7, ScrH() * 0.5 )
	DermaPanel:SetTitle( "Scoreboard" )
	DermaPanel:SetVisible( true )
	DermaPanel:SetDraggable( true )
	DermaPanel:ShowCloseButton( true )
	DermaPanel:SetMouseInputEnabled(false)
	DermaPanel:SetKeyboardInputEnabled(false)
	DermaPanel:MakePopup()
	
	local DermaListView = vgui.Create("DListView")
	DermaListView:SetParent(DermaPanel)
	DermaListView:SetPos(25, 50)
	DermaListView:SetSize(ScrW() * 0.65, ScrH() * 0.4)
	DermaListView:SetMultiSelect(false)
	DermaListView:AddColumn("Player")
	DermaListView:AddColumn("Total Kills")
	DermaListView:AddColumn("Silent Kills")
	DermaListView:AddColumn("% of Team Kills")
	DermaListView:AddColumn("Deaths")
	DermaListView:AddColumn("% of Team Deaths")
	DermaListView:AddColumn("Score")	
	for k,v in pairs(player.GetAll()) do
		DermaListView:AddLine(v:Nick(),v:Frags(),v:GetNWString("SilentKills"),""..v:GetNWString("Killpercent").."%",v:Deaths(),""..v:GetNWString("Deathpercent").."%",v:GetNWInt("Score"))
	end
	DermaListView:AddLine("Team",team_kills+team_silent_kills,team_silent_kills,"-",team_deaths,"-",teamscore)
	DermaListView:AddLine("Last Best team",BEST_TEAM_KILLS+BEST_TEAM_SILENT_KILLS,BEST_TEAM_SILENT_KILLS,"-",BEST_TEAM_DEATHS,"-",BEST_TEAM_SCORE)
	DermaListView:AddLine(""..BEST_PLAYER_ALL_TIME_NAME.." (Last Best Player)",BEST_PLAYER_ALL_TIME_KILLS,BEST_PLAYER_ALL_TIME_SILENT_KILLS,"-",BEST_PLAYER_ALL_TIME_DEATHS,"-",BEST_PLAYER_ALL_TIME_SCORE)
end )

function CalculatePlayerScore(ply)
	teamscore = (team_kills+(team_silent_kills*3))-(team_deaths*(PLAYERSINMAP+1))
	local killpercent = ((ply.Kills+ply.SilentKills)/(team_kills+team_silent_kills))*100
	local deathpercent = (ply.deaths/team_deaths)*100
	local player_points = ((ply.Kills+(ply.SilentKills*3)-ply.deaths*2))

	ply:SetNWString("Killpercent", ""..math.Round(killpercent).."")
	ply:SetNWString("SilentKills", ""..ply.SilentKills.."")
	ply:SetNWString("Deathpercent", ""..math.Round(deathpercent).."")
	ply:SetNWInt("Kills", ply.Kills+ply.SilentKills)
	ply:SetNWInt("Deaths", ""..ply.deaths.."")
	ply:SetNWInt("Score", ""..player_points.."")

	ply:SendLua("team_kills="..team_kills.."" )
	ply:SendLua("team_silent_kills="..team_silent_kills.."" )
	ply:SendLua("team_deaths="..team_deaths.."" )
	ply:SendLua("teamscore="..teamscore.."" )
	
	local score=tonumber(ply:GetNWInt("Score"),10)
	local referencescore=tonumber(ply:GetNWInt("ReferentScore"),10)

	if score < referencescore then
		ply:SendLua("score_color=Color(255,179,0)" )
	end
	
	if score < referencescore - 4 then
		ply:SendLua("score_color=Color(255,8,8)" )
	end
	
	if score == referencescore then
		ply:SendLua("score_color=Color(200,200,200)" )
	end
	
	if score > referencescore then
		ply:SendLua("score_color=Color(156,255,120)" )
	end
	
	if score > referencescore + 4 then
		ply:SendLua("score_color=Color(0,255,0)" )
	end
end

function ComparePlayerScore(ply)
	teamscore = (team_kills+(team_silent_kills*3))-(team_deaths*(PLAYERSINMAP+1))
	local killpercent = ((ply.Kills+ply.SilentKills)/(team_kills+team_silent_kills))*100
	local deathpercent = (ply.deaths/team_deaths)*100
	local player_points = ((ply.Kills+(ply.SilentKills*3)-ply.deaths*2))
	ply:SetNWString("Killpercent", ""..math.Round(killpercent).."")
	ply:SetNWString("SilentKills", ""..ply.SilentKills.."")
	ply:SetNWString("Deathpercent", ""..math.Round(deathpercent).."")
	ply:SetNWInt("Kills", ply.Kills+ply.SilentKills)
	ply:SetNWInt("Deaths", ""..ply.deaths.."")
	ply:SetNWInt("Score", ""..player_points.."")

	ply:SendLua("team_kills="..team_kills.."" )
	ply:SendLua("team_silent_kills="..team_silent_kills.."" )
	ply:SendLua("team_deaths="..team_deaths.."" )
	ply:SendLua("teamscore="..teamscore.."" )

	local score=tonumber(ply:GetNWInt("Score"),10)
	return score
end

function ISaid( ply, text, public )
local GlobalRemaining = GetConVarNumber("h_combine_killed_to_win")-COMBINE_KILLED
    if text == "!listmaps" or text == "!LISTMAPS" then
		MapVoteThing(ply)
		return false
	end
    if text == "!taunt" or text == "taunt"  then
		if ply.sex=="female" then 
		ply:EmitSound(table.Random(femaletaunts), 100, 100)
		else
		ply:EmitSound(table.Random(maletaunts), 100, 100)
		end
		nearbycombinecomesilent(ply)
		return false
	end
    if text == "!remain" or text == "!REMAIN" then
		PrintMessage(HUD_PRINTTALK, "[Наблюдатель]: Номер отряда "..Wave.." у вас осталось "..EnemiesRemainining.." единиц.")
		timer.Simple(3, function() PrintMessage(HUD_PRINTTALK, "[Наблюдение]: Альянс потерпит пораженине, если убьете "..GlobalRemaining.." наземных юнитов") end)
		return false
    end
	if text == "!remove" or text == "!REMOVE" then
		ply:PrintMessage(HUD_PRINTTALK, ""..ply:GetActiveWeapon():GetClass().." удалены из вашего инвентаря.")
		ply:StripWeapon(ply:GetActiveWeapon():GetClass())
		return false
	end
	
	if text == "!drop" or text == "!DROP" then
		ManualWeaponDrop(ply)
		if GetConVarString("h_weight_system") == "1" or GetConVarString("h_hardcore_mode") == "1" then
			timer.Simple(1, function() AdjustWeight(ply) end)
		end
		return false
	end

	if text == "!myscore" or text == "!MYSCORE" then
		PlayerStats(ply)
		return false
    end

	if text == "!teamscore" or text == "!TEAMSCORE" then
		teamscore = (team_kills+(team_silent_kills*3))-(team_deaths*(PLAYERSINMAP+1))
		for k,player in pairs(player.GetAll()) do
			local killpercent = ((player.Kills+player.SilentKills)/(team_kills+team_silent_kills))*100
			local deathpercent = (player.deaths/team_deaths)*100
			local player_points = ((player.Kills+(player.SilentKills*3)-player.deaths*2))
		
			player:SetNWString("Killpercent", ""..math.Round(killpercent).."")
			player:SetNWString("SilentKills", ""..player.SilentKills.."")
			player:SetNWString("Deathpercent", ""..math.Round(deathpercent).."")
			player:SetNWInt("Score", ""..player_points.."")
			ply:SendLua("team_kills="..team_kills.."" )
			ply:SendLua("team_silent_kills="..team_silent_kills.."" )
			ply:SendLua("team_deaths="..team_deaths.."" )
			ply:SendLua("teamscore="..teamscore.."" )
			ply:SendLua("BEST_TEAM_KILLS="..BEST_TEAM_KILLS.."" )
			ply:SendLua("BEST_TEAM_SILENT_KILLS="..BEST_TEAM_SILENT_KILLS.."" )
			ply:SendLua("BEST_TEAM_SCORE="..BEST_TEAM_SCORE.."" )
			ply:SendLua("BEST_TEAM_DEATHS="..BEST_TEAM_DEATHS.."" )
			ply:SendLua("BEST_PLAYER_ALL_TIME_SCORE="..BEST_PLAYER_ALL_TIME_SCORE.."" )
			ply:SendLua("BEST_PLAYER_ALL_TIME_KILLS="..BEST_PLAYER_ALL_TIME_KILLS.."" )
			ply:SendLua("BEST_PLAYER_ALL_TIME_SILENT_KILLS="..BEST_PLAYER_ALL_TIME_SILENT_KILLS.."" )
			ply:SendLua("BEST_PLAYER_ALL_TIME_DEATHS="..BEST_PLAYER_ALL_TIME_DEATHS.."" )
			ply:SendLua("BEST_PLAYER_ALL_TIME_NAME='"..BEST_PLAYER_ALL_TIME_NAME.."'" )
		end
		timer.Simple(1, function() 
			net.Start( "Scoreboard" )
			net.Send(ply)
		end)
		return false
    end

	if text == "!disguisereveal" then
		CombineDisguiseReveal(ply)
		return false
	end
		if text == "!gohere" then
		if ply.disguised==1 then
		CombineDisguisedCommandGo(ply:GetEyeTraceNoCursor().HitPos,2)
		ply:EmitSound(table.Random(ContactConfirmed), 100, 100)
		end
		return false
	end
		if text == "!patrolhere" then
		if ply.disguised==1 then
		CombineDisguisedCommandPatrol(ply:GetEyeTraceNoCursor().HitPos,2)
		ply:EmitSound(table.Random(ContactConfirmed), 100, 100)
		end
		return false
	end	

		if text == "!patrolzones" or text == "!PATROLZONES" then
			revealzonestemp()
			return false
		end

		if text == "!requesthelp" then
		if ply:GetNWInt("canrequestrebels")	== 1 then
		ply:SetNWInt("canrequestrebels",1)
		SpawnRebel(table.Random(combinespawnzones),ply)
		ply:PrintMessage(HUD_PRINTTALK, "[Повстанческое радио]: Хорошо, помощь уже в пути!")

		end
			return false
		end
	end	

hook.Add( "PlayerSay", "ISaid", ISaid )

function revealzonestemp()
	table.foreach(zonescovered, function(key,value)
		local sprite = ents.Create( "env_sprite" )
		sprite:SetPos(value)
		sprite:SetColor( Color( 255, 0, 0 ) )
		sprite:SetKeyValue( "model", "sprites/light_glow01.vmt" )
		sprite:SetKeyValue( "scale", 0.50 )
		sprite:SetKeyValue( "rendermode", 5 )
		sprite:SetKeyValue( "renderfx", 7 )
		sprite:Spawn()
		sprite:Activate()
		sprite:SetName("ZoneReveal")
	end)
	timer.Simple(4, hidezones)
end


function PlayerHighlightItem(player)

	if table.Count(noticeable_server) < 3 and table.Count(ents.FindByName("ZoneHighlight")) < 3 then
			local can = 1
			if player:GetEyeTraceNoCursor().Entity:IsWorld() then
			local sprite = ents.Create( "env_sprite" )
			sprite:SetPos(player:GetEyeTraceNoCursor().HitPos+Vector(0,0,30))
			sprite:SetColor( Color( 0,0,255 ) )
			sprite:SetKeyValue( "model", "sprites/light_glow01.vmt" )
			sprite:SetKeyValue( "scale", 0.50 )
			sprite:SetKeyValue( "rendermode", 5 )
			sprite:SetKeyValue( "renderfx", 7 )
			sprite:Spawn()
			sprite:Activate()
			sprite:SetName("ZoneHighlight")
			sprite:EmitSound("garrysmod/balloon_pop_cute.wav", 100, 100)
/*					
	else
				table.foreach(noticeable_server, function(key,value)
					if value == player:GetEyeTraceNoCursor().Entity:EntIndex() then
						can = 0
					end
				end)
				if can == 1 then
				for k, player in pairs( ents.GetAll() ) do
				if player:IsPlayer() then
				player:SendLua("table.insert(noticeable,LocalPlayer():GetEyeTraceNoCursor().Entity:EntIndex())" )
				end
				end			
				table.insert(noticeable_server,player:GetEyeTraceNoCursor().Entity:EntIndex())
				player:GetEyeTraceNoCursor().Entity:EmitSound("garrysmod/balloon_pop_cute.wav", 100, 100)
				end
*/				
			end		
			
	if timer.Exists("HighlightTimer") then
		timer.Destroy( "HighlightTimer")
	end
	
timer.Create( "HighlightTimer", 5, 1,	function()
			for k, player in pairs( ents.GetAll() ) do
			if player:IsPlayer() then
			player:SendLua("table.Empty(noticeable)" )
			end
			end	
			table.Empty(noticeable_server)
			
			for k, v in pairs(ents.FindByName("ZoneHighlight") ) do
			v:Remove()
			end
			
	end)		
	end
end

function GM:Initialize()
	self.BaseClass.Initialize( self )
end

function ManualWeaponDrop(ply)
			local weapon = ply:GetActiveWeapon()


if ply:GetActiveWeapon() != NULL then

if ply:GetActiveWeapon():GetClass() == "weapon_frag" then

	if ply:GetAmmoCount(ply:GetActiveWeapon():GetPrimaryAmmoType()) > 0 then
	ammo = ply:GetAmmoCount(ply:GetActiveWeapon():GetPrimaryAmmoType())
	ply:GetActiveWeapon():SetClip1(1)
	ply:DropWeapon(ply:GetActiveWeapon())
	ply:StripWeapon("weapon_frag")
	end

else

ply:DropWeapon(ply:GetActiveWeapon())
end
			timer.Create( "PlayerDropWeaponSound", 2, 1, function() 
			nearbycombinecomecasual(weapon)
			end)
end
/*
	local wep = ply:GetActiveWeapon():GetClass()
	local candrop = 1
	if ply:GetActiveWeapon():GetClass() == "weapon_physcannon" then
		candrop = 0
	end
	if ply:GetActiveWeapon():Clip1() < 0 or ply:GetActiveWeapon():GetClass() == "weapon_slam" then
		candrop = 0
	end	
	if candrop == 1 then
		if ply:GetActiveWeapon():Clip1() == 0 then
			ply:GetActiveWeapon():Remove()
			ply:PrintMessage(HUD_PRINTTALK, "Removed "..ply:GetActiveWeapon():GetClass()..".")
			else
			local weapon = ply:GetActiveWeapon()
			ply:PrintMessage(HUD_PRINTTALK, "Dropped "..ply:GetActiveWeapon():GetClass()..".")
			ply:DropWeapon(ply:GetActiveWeapon())
			timer.Create( "PlayerDropWeaponSound", 1, 1, function() 
			nearbycombinecomecasual(weapon)
			end)
		end
	else
		ply:PrintMessage(HUD_PRINTTALK, "ты не можешь бросить "..ply:GetActiveWeapon():GetClass()..". Прости.")
	end
	*/
end

function nearbycombinecome(suspect)
	for k, v in pairs(ents.FindInSphere(suspect:GetPos(),1024)) do
		if v:GetClass() == "npc_metropolice" or v:GetClass() == "npc_combine_s" then 
			if !v:GetEnemy() then
				if !v:IsCurrentSchedule(SCHED_FORCED_GO_RUN) then
					print(""..v:GetName().." [обнаружил противника в ближайшей позиции]")
					v:SetLastPosition(suspect:GetPos())
					v:SetSchedule(SCHED_FORCED_GO_RUN)
				end
			end
		end
	end
end

function nearbycombinecomeheli(spotter,suspect)
	for k, v in pairs(ents.FindInSphere(spotter:GetPos(),2024)) do
		if (v:GetClass() == "npc_metropolice" || v:GetClass() == "npc_combine_s") then 
			if !v:GetEnemy() then
				if !v:IsCurrentSchedule(SCHED_FORCED_GO_RUN) then
					print(""..v:GetName().." [управляется вертолетом]")
					v:SetLastPosition(suspect:GetPos())
					v:SetSchedule(SCHED_FORCED_GO_RUN)
				end
			end
		end
	end
end



function nearbycombinecomecasual(suspect)
	local come = 0
	if suspect:GetPos() then
		for k, v in pairs(ents.FindInSphere(suspect:GetPos(),1024)) do
			if v:GetClass() == "npc_metropolice" or v:GetClass() == "npc_combine_s" then 
				if v:GetPos():Distance(suspect:GetPos()) > 10 then
					if come < 1 then 
						if !v:GetEnemy() then
							if !v:IsCurrentSchedule(SCHED_FORCED_GO_RUN) then
								--print(""..v:GetName().." investigates.")
								if GetConVarNumber("h_combine_chat") == 1 and CAN_HEAR_BREAK == 1 then
								PrintMessage(HUD_PRINTTALK, ""..v:GetName()..": "..table.Random(CombineHearBreak).."")
								CAN_HEAR_BREAK = 0
								timer.Simple(5, function() CAN_HEAR_BREAK = 1 end)
								end
								v:SetLastPosition(suspect:GetPos())
								v:SetSchedule(SCHED_FORCED_GO)
								come=come+1
							end
						end
					end
				end
			end
		end
	end
end

function nearbycombinecomesilent(suspect)

	if suspect:GetPos() then
		for k, v in pairs(ents.FindInSphere(suspect:GetPos(),812)) do
			if v:GetClass() == "npc_metropolice" or v:GetClass() == "npc_combine_s" then 
				if v:GetPos():Distance(suspect:GetPos()) > 10 then
					if !v:GetEnemy() then
						if !v:IsCurrentSchedule(SCHED_FORCED_GO_RUN) then
							v:SetLastPosition(suspect:GetPos())
							v:SetSchedule(SCHED_FORCED_GO_RUN)
						end
					end
				end
			end
		end
	end
end



function CombineDisguisedCommandGo(area,MAXCOMBINERUSH)
local coming=0
	for k, v in pairs(ents.FindInSphere(area,1024)) do
		if v:GetClass() == "npc_metropolice" or v:GetClass() == "npc_combine_s" or v:GetClass() == "npc_hunter" then 
			if !v:GetEnemy() then
				if coming < MAXCOMBINERUSH then
					print(""..v:GetName().." слышал, что.")
					v:SetLastPosition(area)
					v:SetSchedule(SCHED_FORCED_GO_RUN)
					coming=coming+1
				end
			end
		end
	end
	for k, v in pairs(ents.GetAll()) do
		if v:GetClass() == "npc_metropolice" or v:GetClass() == "npc_combine_s" or v:GetClass() == "npc_hunter" then 
			if !v:GetEnemy() then
				if coming < MAXCOMBINERUSH then
					print(""..v:GetName().." слышал, что.")
					v:SetLastPosition(area)
					v:SetSchedule(SCHED_FORCED_GO_RUN)
					coming=coming+1
				end
			end
		end
	end
end



function CombineDisguisedCommandPatrol(area)
table.insert(zonescovered, area+Vector(0,0,10))
ClearPatrolzones()
end


function allthecombinecome(suspect,MAXCOMBINERUSH)
local coming=0
	for k, v in pairs(ents.FindInSphere(suspect:GetPos(),1024)) do
		if v:GetClass() == "npc_metropolice" or v:GetClass() == "npc_combine_s" or v:GetClass() == "npc_hunter" then 
			if !v:GetEnemy() then
				if coming < MAXCOMBINERUSH then
					print(""..v:GetName().." слышал, что.")
					v:SetLastPosition(suspect:GetPos())
					v:SetSchedule(SCHED_FORCED_GO_RUN)
					coming=coming+1
				end
			end
		end
	end
	for k, v in pairs(ents.GetAll()) do
		if v:GetClass() == "npc_metropolice" or v:GetClass() == "npc_combine_s" or v:GetClass() == "npc_hunter" then 
			if !v:GetEnemy() then
				if coming < MAXCOMBINERUSH then
					print(""..v:GetName().." слышал, что.")
					v:SetLastPosition(suspect:GetPos())
					v:SetSchedule(SCHED_FORCED_GO_RUN)
					coming=coming+1
				end
			end
		end
	end
end

function GM:PlayerCanPickupWeapon(ply, wep)
	--print(""..ply:GetName().." trying to get " ..wep:GetClass().."")
	local CANPICKUP = 1
	--table.foreach(ONLY_PICKUP_ONCE, function(key,value)
		if table.HasValue(ONLY_PICKUP_ONCE, wep:GetClass()) then
		--PrintTable(ONLY_PICKUP_ONCE)
		--PrintTable(ply:GetWeapons())
		--if table.HasValue(ply:GetWeapons(), wep:GetClass()) then
			for k,v in pairs (ply:GetWeapons()) do
			if v:GetClass() == wep:GetClass() then
				--print(""..ply:GetName().." already has " ..v:GetClass().."")
				CANPICKUP = 0
				end
			--end
		end
		end
	--end)
	
	if GetConVarString("h_weight_system") == "1" then timer.Simple(1, function() AdjustWeight(ply) end) end
	
	if GetConVarNumber("h_selective_weapon_pickup") == 1 then
		if wep:GetClass() != "weapon_crowbar" then 
			if !ply:KeyDown(IN_USE) then
				CANPICKUP = 0
			end
		end
	end
	
	if CANPICKUP == 0 then 
		return false 
	end
	
	CANPICKUP = nil
	nearbycombinecomecasual(ply)
	return true 
end

function AdjustWeight(ply)
	local weight = 1
	table.foreach(ply:GetWeapons(), function(key,value)
		if value:GetClass() != "weapon_frag" and value:GetClass() != "weapon_crowbar"  and value:GetClass() != "weapon_slam" and value:GetClass() != "weapon_pistol" and value:GetClass() != "weapon_smg" then
			weight=weight*0.95
		end
	end)
	ply:SetWalkSpeed(150*weight)
	ply:SetRunSpeed(250*weight)
	if ply:GetWalkSpeed() < 80 then
	ply:PrintMessage(HUD_PRINTTALK, "Вас инвентарь полон. Бросьте оружие, переключившись на него сказав !drop")
	end
end


function ItemRespawnSystem()
		local PLAYERS = 0
	timer.Create( "Item Respawn System", 10, 1, ItemRespawnSystem )
	if GetConVarNumber("h_item_respawn_system") == 1 then
		local CAN = 1
		local NUMBER = 0
		for k,weapon in pairs(ents.FindByClass("player")) do 
			PLAYERS = PLAYERS + 1
		end
		if PLAYERS > 3 then
			PLAYERS = PLAYERS/2 
		end
		table.foreach(MEDIUMWEAPONS, function(key,value)
			for k,weapon in pairs(ents.FindByClass(value)) do 
				NUMBER=NUMBER+1
			end
			--print("[The Hunt]: There are "..NUMBER.." "..value.."")
			while NUMBER < PLAYERS do
				print("[RespawnSystem]: Spawning 1 "..value.."")
				SpawnItem(value, ItemSelectSpawn(ITEMPLACES), Angle(0,0,math.random(-180,180)) )
				NUMBER = NUMBER+1
			end
			NUMBER=0
		end)
		for k,v in pairs(ents.FindByClass("item_healthcharger")) do 
			local canrespawn = 1
			local chargerpos = v:GetPos()
			local chargerangles = v:GetAngles()
			for k, player in pairs(ents.FindInSphere(v:GetPos(),100)) do
				if player:IsPlayer() then
					canrespawn = 0
					--print("[The Hunt]: player found, wont respawn charger")
				end
			end
			if canrespawn == 1 then
				--print("[The Hunt]: player not found, will respawn charger")
				v:Remove()
				SpawnItem("item_healthcharger", chargerpos, chargerangles )
			end
		end

		for k,v in pairs(ents.FindByClass("item_suitcharger")) do 
			local canrespawn = 1
			local chargerpos = v:GetPos()
			local chargerangles = v:GetAngles()
			for k, player in pairs(ents.FindInSphere(v:GetPos(),100)) do
				if player:IsPlayer() then
					canrespawn = 0
					--print("[The Hunt]: player found, wont respawn charger")
				end
			end
			if canrespawn == 1 then
					--print("[The Hunt]: player not found, will respawn charger")
					v:Remove()
					SpawnSuitCharger(chargerpos, chargerangles )
			end
		end
	end
	
	if RPGCANSPAWN == 1 then
		RPG_IN_MAP = 0
		for k,weapon in pairs(ents.FindByClass("weapon_rpg")) do 
			RPG_IN_MAP = RPG_IN_MAP + 1
		end
		--print("[The Hunt]: RPG's on map: "..RPG_IN_MAP.."")
		RPGSPAWN = GetConVarNumber("h_rpgmax") - RPG_IN_MAP
		while RPGSPAWN > 0 && RPGCANSPAWN == 1 do
			--print("[The Hunt]: RPG's that will spawn: "..RPGSPAWN.."")
			SpawnItem("weapon_rpg", table.Random(ITEMPLACES), Angle(90, 90, 0) )
			RPGSPAWN=RPGSPAWN - 1
		end
	end

	if GetConVarNumber("h_combine_bouncers") > 0 then	
		local bouncers=0
			
		for k,bouncer in pairs(ents.FindByClass("combine_bouncer")) do 
		bouncers=bouncers+1
		end
		
		if  bouncers < GetConVarNumber("h_combine_bouncers") then	
			if team_kills > team_silent_kills+(bouncers*2) or bouncers < 1 then
				local pos = ItemSelectSpawn(zonescovered)
				SpawnCombineBouncer(pos)
			end
		end
		--print("Kills: "..team_kills+team_silent_kills.." -  Silent Kills+Bouncers*1.5: "..((team_silent_kills + bouncers) * 1.5).." - Bouncers: "..bouncers.."")
	end
	if haszombies or GetConVarNumber("h_zombie_mode") == 1 then zombiesmap() end
end

function zombiesmap()
	if math.random(1,10) == 2 then	
		local zombies=0		
		for k,zombi in pairs(ents.GetAll()) do 
		if table.HasValue(zombietable, zombi:GetClass()) then
		zombies=zombies+1
		--print("Zombie found")
		end
		end
		
		if zombies < ORIGINAL_ZONES_NUMBER then	
					table.foreach(zombietable, function(key,value)
					SpawnItem(value,ItemSelectSpawn(zonescovered),Angle(0,0,0))
					--print(""..value.."")
					end)
		end
	end

end

function ItemSelectSpawn(spawntable)
	local availablespawns = {}
	local random_entry = math.random( #spawntable )
	local spawn = false
	table.foreach(spawntable, function(key,value)
		local can = 1
		for k, v in pairs(ents.FindInSphere(value+Vector(0,0,70),9000)) do
			if v:IsPlayer() or v:IsNPC() or v:IsWeapon() then
				if v:VisibleVec(value) then
				--print(v:Nick())
					can = 0
				end
			end
		end
		if can == 1 then
		--print("Bouncer can spawn there")
		table.insert(availablespawns, value)
		end
	end)

if table.Count(availablespawns) < 1 then
--PrintMessage(HUD_PRINTTALK, "WARNING: There are players on ALL the combine spawnpoints.")
return table.Random(spawntable)
else
return table.Random(availablespawns)
end
end

CantHideInPlainSight={"npc_zombie","npc_fastzombie","npc_poisonzombie","npc_combine_s","npc_metropolice","npc_helicopter","npc_gunship"}

zombietable={"npc_headcrab_fast","npc_zombie","npc_zombie","npc_zombie","npc_fastzombie","npc_fastzombie","npc_headcrab_black","npc_headcrab_black","npc_poisonzombie"}

Player_Hints = {"Потолочные турели можно отключить в панели управления альянса или взорвав её.",
"Выстрелы с глушителем не потревожат комбайнов.",
"Если вы здесь впервые, то вам срочно нужно ознакомиться с правилами, введите !rules!",
"Помните, что шум будет привлекать внимание комбайнов.",
"Некоторые ящики содержат ценные предметы.",
"Убийство ничего не подозревающего комбайна принесет вам больше очков.",
"Убивать и бежать - лучшая тактика. Используй её",
"Вы можете спрятаться в темных местах. Там они вас не заметят.",
"Всегда идите параллельно стене, а не посреди улицы/коридора.",
"Попробуйте использовать оружие с глушителем или оружие ближнего боя. Они производят гораздо меньше шума.",
"Вы можете бросить свое оружие, сказав !drop."}

Disguise_Hints = {"Вы замаскированы под комбайна. Альянс не будет атаковать вас сейчас.",
"Не убивайте их на глазах у других солдат.",
"Если вы нанесете урон комбайну, не убив его, он раскроет вас.",
"Избегайте элитных солдат Альянса, они раскроют вас."}

noticeable_server = {}

HL2Beta_Weapons = {""}

SPAWNPOINTS_TO_DELETE = {
"info_player_terrorist",
"info_player_counterterrorist",
"info_player_start",
"info_player_deathmatch",
}

RebelsGiveAmmo = {
"item_ammo_357",
"item_ammo_ar2",
"item_ammo_ar2_altfire",
"item_ammo_crossbow",
"item_ammo_pistol",
"item_box_buckshot",
"item_ammo_smg1",

"bp_shotgun_ammo",
"bp_flare_ammo",
"bp_small_ammo",
"bp_sniper_ammo"
}

function start()
player.GetByID(1):StripWeapons()
player.GetByID(1):Give("weapon_shotgun")
player.GetByID(1):SetNWString("canusemenu", "no")
otherfunction()
end

TOO_BRIGHT_WEAPONS = {
"weapon_bp_shotgun",
"weapon_bp_annabelle",
"weapon_rpg",
"weapon_bp_smg2",
"weapon_bp_smg3"
}

-- Weapons that make you more visible. It's harder to hide while carrying them.
DARK_WEAPONS = { 
"weapon_bp_shotgun",
"weapon_bp_annabelle",
"weapon_rpg",
"weapon_bp_smg2",
"weapon_bp_smg3"
}

-- Weapons that don't have any bright items on them.
SILENCED_WEAPONS = {
""
}

-- Using them will attract nearby combine.
SILENT_WEAPONS = { 
"weapon_bp_shotgun",
"weapon_bp_annabelle",
"weapon_slam",
"weapon_rpg",
"weapon_bp_smg2",
"weapon_physcannon",
"weapon_bp_smg3",
"weapon_frag",
"weapon_crossbow",
"weapon_pistolй",
"weapon_bp_alyxgun",

"weapon_medkit",

"weapon_hl2hook",
}

-- Using them wont atract anyone.
SECONDARY_FIRE_WEAPONS = {
"weapon_pistol"
}

-- Weapons that have a loud secondary fire.
ONLY_PICKUP_ONCE = { 
"weapon_bp_annabelle",
"weapon_bp_smg3",
"weapon_physcannon",
"weapon_rpg",
"weapon_frag",
"weapon_bp_alyxgun"
}

-- The game will prevent people from picking up this weapons if they already have them. Useful for weapons with infinite uses, preventing the player from picking up a weapon he doesn't need to, leaving the weapon for others.
VanillaWeapons = {
"weapon_bp_shotgun",
"weapon_bp_annabelle",
"weapon_slam",
"weapon_rpg",
"weapon_bp_smg2",
"weapon_physcannon",
"weapon_bp_smg3",
"weapon_frag",
"weapon_crossbow",
"weapon_pistolй",
"weapon_bp_alyxgun",

"weapon_bp_oicw",
"weapon_bp_hopwire",
"weapon_bp_hmg1",
"weapon_bp_guardgun",

"weapon_medkit",

"weapon_hl2hook"
}

AirEnemies = { "npc_helicopter", "npc_combinegunship"}
MainEnemiesGround = { "npc_combine_s", "npc_metropolice","npc_hunter","npc_fassassin"}
MainEnemies = { "npc_combine_s", "npc_metropolice", "npc_helicopter", "npc_combinegunship","npc_hunter","npc_fassassin"}
MainEnemiesCoop = { "npc_combine_s", "npc_metropolice", "npc_helicopter", "npc_combinegunship", "npc_turret_ceiling","npc_hunter",}
MainEnemiesDamage = { "npc_combine_s", "npc_metropolice", "npc_manhack"}
AffectedByDisguise = {"npc_combine_s", "npc_metropolice", "npc_manhack", "npc_helicopter", "npc_combinegunship","npc_hunter","npc_fassassin", "npc_sniper", "npc_cremator","npc_rollermine","npc_turret_ceiling","npc_turret_floor"}
AffectedByDisguiseCanReveal = {"npc_combine_s", "npc_metropolice", "npc_helicopter", "npc_combinegunship","npc_hunter","npc_fassassin", "npc_sniper", "npc_cremator"}

ChatEnemyLost = {
"Черт, мы их потеряли.",
"Штаб, враг потерян.",
"Потерял видимость.",
"Команда стабилизации на позициях",
"Контакт потерян.",
"...перебои в связи, запрашиваю патруль в блок C...",
"Статус неопознан",
}

CombineHearBreak = {
"Неопознанная теплоактивность. Возможно, иная форма жизни.",
"Возможна активность иной формы жизни, приступить к очистке.",
"Рядом неопознанная теплоактивность.",
"Неопознанная теплоактивность, возможно наподенине на потрошитель.",
"Пост 'Качевник' обеспечьте работу ограничителя периметра и доложите.",
"Пост 'Тень' доложите о неисправностях...",
"Зафиксирована теплоактивность.",
"...пост 139 начинаю разведку сектора.",
"Ближайшие подразделения, активность в секторе! Срочно провести разведку и доложить в пост 'Стингер'",
"Пост сдан. Начать перегруппировку!"
}

ChatEnemySpotted = {
"Пост 'Стингер' это лидер 9 Зафиксировано продвижение противника.",
"Цель №1 переместилась в зону сдерживания, всем подразделениям направляться в дельта 8. Выполняйте.",
"... Сектор 'Черный 4'. Центр сообщает о подходе патруля с воздуха.",
"Внимание цель №1 осуществляет вторжение! Повторяю, цель №1 осуществляет вторжение!"
}

OVERWATCH_TAUNTS = { 
"Я бы подготовился, если бы я был тобой. ",
"Надеюсь, вам нравятся... ",
"Давай покончим с этим." ,
"Я подсчитал, кто победит с вероятностью 99,93%, если вам интересно. ",
"Так что, по крайней мере, ваши товарищи по команде знают, что они делают. ",
"Ваши товарищи по команде делают действительно большую работу. ",
"Это, вероятно, самый героический поступок, который кто-либо когда-либо совершал, сидя неподвижно в родительской комнате отдыха. ",
"Вы были почти полезны на этот раз. ",
"Это хорошее чувство, не так ли? я бы не привыкла. ",
"Забавно, я даже не видел, как ты обманываешь. ",
"Это должно немного отсрочить неизбежное. ",
"Отличная командная работа, вы злобные головорезы. ",
"Вся твоя жизнь была математической ошибкой. Математическая ошибка, которую я собираюсь исправить.",
"Кто-то сильно пострадает», «Я так тебя ненавижу», «Что-нибудь случилось, пока меня не было дома?",
"Просто прекрати это уже.",
"Ты испытываешь меня?" , 
"Ты действительно не устаешь от этого, не так ли?" , 
"Я задолбался." ,
"Вам нужно настоящее поощрение? Посмотрим, поможет ли это." ,
"Теперь ты просто тратишь мое время." ,
"Если вам интересно, что это за запах, то это запах человеческого страха." 
}

OverwatchAmbientSoundsOne = {
"npc/overwatch/cityvoice/f_anticivil1_5_spkr.wav",
"npc/overwatch/cityvoice/f_anticivilevidence_3_spkr.wav",
"npc/overwatch/cityvoice/f_evasionbehavior_2_spkr.wav",
"npc/overwatch/cityvoice/f_innactionisconspiracy_spkr.wav",
"npc/overwatch/cityvoice/f_protectionresponse_1_spkr.wav",
"npc/overwatch/cityvoice/f_anticitizenreport_spkr.wav",
"npc/overwatch/cityvoice/f_protectionresponse_4_spkr.wav",
"npc/overwatch/cityvoice/fprison_airwatchdispatched.wav",
"npc/overwatch/cityvoice/f_trainstation_offworldrelocation_spkr.wav",
"npc/overwatch/cityvoice/f_trainstation_assemble_spkr.wav",
"npc/overwatch/cityvoice/f_unrestprocedure1_spkr.wav",
"npc/overwatch/cityvoice/fprison_restrictorsdisengaged.wav","npc/overwatch/cityvoice/f_protectionresponse_5_spkr.wav",
}

ContactConfirmed = {
"npc/metropolice/vo/confirmpriority1sighted.wav",
"npc/metropolice/vo/allunitscode2.wav",
"npc/combine_soldier/vo/contact.wav",
"npc/combine_soldier/vo/contactconfim.wav",
"npc/combine_soldier/vo/contactconfirmprosecuting.wav",
"npc/combine_soldier/vo/goactiveintercept.wav",
"npc/combine_soldier/vo/overwatchreportspossiblehostiles.wav",
}

CombineKillSounds = {
"npc/combine_soldier/vo/onecontained.wav",
"npc/combine_soldier/vo/onedown.wav",
"npc/combine_soldier/vo/thatsitwrapitup.wav",
"npc/metropolice/vo/clearandcode100.wav",
"npc/metropolice/vo/finalverdictadministered.wav",
"npc/combine_soldier/vo/readyweapons.wav",
}

CombineCombatSounds = {
"npc/combine_soldier/vo/overwatchrequestreinforcement.wav",
"npc/combine_soldier/vo/flush.wav",
"npc/combine_soldier/vo/containmentproceeding.wav",
"npc/combine_soldier/vo/coverhurt.wav",
"npc/combine_soldier/vo/displace2.wav",
"npc/combine_soldier/vo/gosharpgosharp.wav",
"npc/combine_soldier/vo/heavyresistance.wav",
"npc/combine_soldier/vo/requestmedical.wav",
"npc/combine_soldier/vo/executingfullresponse.wav",
"npc/combine_soldier/vo/unitisclosing.wav",
"npc/metropolice/vo/holdthisposition.wav",
}

CombineIdleSounds = {
"npc/combine_soldier/vo/teamdeployedandscanning.wav",
"npc/overwatch/radiovoice/accomplicesoperating.wav",
"npc/overwatch/radiovoice/controlsection.wav",
"npc/overwatch/radiovoice/completesentencingatwill.wav",
"npc/overwatch/radiovoice/disengaged647e.wav",
"npc/overwatch/radiovoice/engagingteamisnoncohesive.wav",
"npc/overwatch/radiovoice/investigateandreport.wav",
"npc/overwatch/radiovoice/leadersreportratios.wav",
"npc/combine_soldier/vo/motioncheckallradials.wav",
"npc/combine_soldier/vo/standingby].wav",
"npc/combine_soldier/vo/isfieldpromoted.wav",
"npc/combine_soldier/vo/isfinalteamunitbackup.wav",
"npc/combine_soldier/vo/lostcontact.wav",
"npc/combine_soldier/vo/prepforcontact.wav",
"npc/combine_soldier/vo/copythat.wav",
"npc/combine_soldier/vo/copy.wav",
"npc/combine_soldier/vo/overwatchconfirmhvtcontained.wav",
"npc/combine_soldier/vo/overwatchtargetcontained.wav",
"npc/metropolice/vo/lockyourposition.wav",
"npc/metropolice/vo/rodgerthat.wav",
"npc/overwatch/radiovoice/airwatchcopiesnoactivity.wav",
"npc/overwatch/radiovoice/lostbiosignalforunit.wav",
"npc/overwatch/radiovoice/preparevisualdownload.wav",
"npc/overwatch/radiovoice/recalibratesocioscan.wav",
"npc/overwatch/radiovoice/rewardnotice.wav",
}

CombineKilledSounds = {
"npc/metropolice/vo/officerneedshelp.wav",
"npc/metropolice/vo/officerunderfiretakingcover.wav",
"npc/metropolice/vo/officerneedsassistance.wav",
"npc/metropolice/vo/officerdowncode3tomy10-20.wav",
"npc/metropolice/vo/officerdowniam10-99.wav",
"npc/metropolice/vo/reinforcementteamscode3.wav",
}

CombineKillCombine = {
"Черт...",
"У меня дефект оружия.",
"Вот что происходит.",
"Дефектные новобранцы.",
"Он был дефектным.",
"Не судите меня, он был с бронёй.",
"Черт, юните #758 требуется строчная эвакуация!",
"Твой выбор был ошибкой...",
"Кто-нибудь еще хочет встать у меня на пути, пока я стреляю?",
"Правило номер один: никогда не пересекайте линию огня товарища по команде."
}

malecomments={
"vo/npc/male01/yeah02.wav",
"vo/npc/male01/gotone02.wav",
"vo/npc/male01/likethat.wav",
"vo/npc/male01/gotone01.wav",
}
femalecomments={
"vo/npc/female01/gotone01.wav",
"vo/npc/female01/gotone02.wav",
"vo/npc/female01/likethat.wav",
"vo/npc/female01/yeah02.wav",
}

femaletaunts={
"vo/npc/female01/gethellout.wav",
"vo/npc/female01/watchout.wav",
"vo/npc/female01/combine01.wav",
"vo/npc/female01/combine02.wav",
"vo/npc/female01/headsup01.wav",
"vo/npc/female01/headsup02.wav",
"vo/npc/female01/overhere01.wav",
}

maletaunts={
"vo/npc/male01/gethellout.wav",
"vo/npc/male01/hacks01.wav",
"vo/npc/male01/incoming02.wav",
"vo/npc/male01/letsgo02.wav",
"vo/npc/male01/squad_approach04.wav",
"vo/npc/male01/upthere01.wav",
"vo/npc/male01/thehacks01.wav",
"vo/npc/male01/watchout.wav",
}

malewin={
"vo/npc/male01/yeah02.wav",
"vo/npc/male01/likethat.wav",
"vo/npc/male01/fantastic01.wav",
"vo/npc/male01/ohno.wav",
"vo/npc/male01/oneforme.wav",
"vo/npc/male01/whoops01.wav",
}
femalewin={
"vo/npc/female01/likethat.wav",
"vo/npc/female01/yeah02.wav",
"vo/npc/female01/fantastic01.wav",
"vo/npc/female01/ohno.wav",
"vo/npc/female01/oneforme.wav",
"vo/npc/female01/whoops01.wav",
}

playermodelsmale = {
"models/humans/personalrebels/pm_suitmale_01.mdl",
"models/humans/personalrebels/pm_suitmale_02.mdl",
"models/humans/personalrebels/pm_suitmale_03.mdl",
"models/humans/personalrebels/pm_suitmale_04.mdl",
"models/humans/personalrebels/pm_suitmale_05.mdl",
"models/humans/personalrebels/pm_suitmale_06.mdl",
"models/humans/personalrebels/pm_suitmale_07.mdl",
}

playermodelsfemale = {
"models/humans/personalrebels/pm_suitfemale_01.mdl",
"models/humans/personalrebels/pm_suitfemale_02.mdl",
"models/humans/personalrebels/pm_suitfemale_04.mdl",
}

function IsThatWeaponInstalled(weapon)
		local can=false
		table.foreach(weapons.GetList(), function(key,value)
		if value.ClassName == weapon then 
		can = true
		end
		end)
if can == true then
return true
end
end

-- Weapons mix
STALKER_SWEPS ={ "" }

MR_PYROUS_SWEPS ={ "" }

MAD_COWS_SWEPS ={ "" }

M9K_SPECIALITIES={ "" }

M9K_ASSAULT_RIFLES={ "" }

FAS={ "" }

Customizable_Weaponry={ "" }

Extra_Customizable_Weaponry={ "" }

Unoficial_Extra_Customizable_Weaponry={ "" }

Murder_friendly_Assault={ "" }

Murder_friendly_Handguns={ "" }

VANILLA_WEAPONS = { 
"weapon_slam",
"weapon_physcannon",
"weapon_frag",
"weapon_crossbow",
"weapon_357",

"weapon_medkit",

"weapon_bp_alyxgun",
"weapon_bp_smg3",
"weapon_bp_smg2",
"weapon_bp_annabelle",
"weapon_bp_shotgun",

"weapon_hl2hook",
}

REBEL_WEAPONS = { "" }

Combine_Approved_Weapons = { "weapon_pistol", "weapon_frag", "weapon_ar2", "weapon_shotgun", "weapon_smg1" }
CombineWeaponNotice = { "That's not your assigned weapon.","Only use assigned weapons, soldier.","We are not allowed to use Rebel weapons, soldier." }

MHs_Super_Battle_Pack_PART_II ={ "acid_sprayer_minds","acidball_minds","alienblasterx_minds","sniperrifle_minds","autoshot_lua","handcannon_minds","crazygbombgun_minds","crazyheligun_minds","crazymelongun_minds","cutter_minds","demoniccarsg_minds","fireball_minds","flamethrower_minds","frostball_minds","gbomb_minds","grapplinggun_minds","grapplinghook_minds","grenader_minds","heligrenade_minds","airboatgun_minds","laser_minds","ln2_sprayer_minds","melongrenade_minds","mrproper_minds","physautomat_minds","rifle_minds","nrocket_launcher_minds" }

spastiks_toybox={ "bakker's blaster","gabriel","gretchen","henderson","lil' jim","murphy's law","the aerosol ar","the anti-rifle","the backscratcher","the bfhmg","the camper's choice","the coiled snake","the commander's compact","the doorman","the eleventh hour","the fire hazard","the fodder buster","the gambler","the grand prize","the greaser","the guerilla","the hammerhead","the hide n' seek advanced","the hometown slugger","the junkmaster","the kilroy warhammer","the lawnmower","the lobotomizer","the morning hail","the night light","the panther fist","the pea shooter","the penguinade","the pepper grinder","the quadruple agent","the rainmaker","the reanimated rocket rifle","the rusted bangstick","the salvaged sidearm","the secret carbine","the segundo pocket pistol","the sleeping pill","the spastik special","the special delivery","the straight razor","the swiss hellbringer","the trash compactor","the turbo lover","the waiting game" }

NPC_WEAPON_PACK_2_RAPID_FIRE={ "" }

NPC_WEAPON_PACK_2_PISTOLS={ "" }

NPC_WEAPON_PACK_2_RPGS={ "" }

NPC_WEAPON_PACK_2_SHOTGUNS={ "" }

NPC_WEAPON_PACK_2_SNIPERS={ "" }