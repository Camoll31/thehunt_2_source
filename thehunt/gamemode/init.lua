print("------ [Загрузка основный конфигов] ------")
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )
file.CreateDir("thehunt_maps")
util.AddNetworkString( "Spotted" )
util.AddNetworkString( "Hidden" )
util.AddNetworkString( "light_below_limit" )
util.AddNetworkString( "light_above_limit" )
util.AddNetworkString( "Visible" )
util.AddNetworkString( "NotVisible" )
util.AddNetworkString( "PlayerKillNotice" )
util.AddNetworkString( "Scoreboard" )
util.AddNetworkString( "ShowHUDScoreboard" )
util.AddNetworkString( "HideHUDScoreboard" )

util.PrecacheModel("models/Combine_Soldier.mdl")
util.PrecacheModel("models/Combine_Super_Soldier.mdl")
util.PrecacheModel("models/Police.mdl")

if file.Exists( "thehunt_maps/"..game.GetMap()..".lua", "DATA" ) then
include("/../../../data/thehunt_maps/"..game.GetMap()..".lua")
win = 1
print("Найден файл конфигурации карты, "..game.GetMap()..".lua")
else
print("Файл конфигурации карты не найден. Повторный поиск...")
win = 0
include("/maps/nomap.lua")
end

if win == 0 then
if file.Exists( "gamemodes/thehunt/gamemode/maps/"..game.GetMap()..".lua", "GAME" ) then
include("/maps/"..game.GetMap()..".lua")
win = 1
print("Найден файл конфигурации карты, "..game.GetMap()..".lua")
else
print("Файл конфигурации карты не найден. Повторный поиск...")
win = 0
include("/maps/nomap.lua")
end
end

include("thehunt/best_team.lua")

/*             notes
Get info from an entity typing this on the console while facing at it
lua_run print("Entity: ") print(player.GetByID(1):GetEyeTrace().Entity) print("Position: ") print(player.GetByID(1):GetEyeTrace().Entity:GetPos()) print("Angles: ") print(player.GetByID(1):GetEyeTrace().Entity:GetAngles()) print(player.GetByID(1):GetEyeTrace().Entity:EntIndex())

lua_run print("Model: ") print(player.GetByID(1):GetEyeTrace().Entity:GetModel())
*/


SUPPORTED_MAPS={"cs_assault","cs_compound","cs_italy","cs_militia","cs_office","de_aztec","de_chateau","de_dust","de_dust2","de_inferno","de_nuke","de_piranesi","de_port","de_prodigy","de_tides","de_train","de_wanda","dm_inevitableconflict","gmt_virus_facility202","gm_arena_submerge","gm_construct","gm_excess_island_night","gm_laboratory_alt","gm_ssewersv2","ph_islandhouse","ph_restaurant","rp_construct_v1","rp_fs_coast_07_003_pak","rp_nova_prospekt_v4","slender_infirmary","template config","ttt_amsterville","ttt_bb_outpost57_b5","ttt_casino_b2","ttt_fallout","ttt_glacier","ttt_retrospect","ttt_skyscraper","ttt_theship_v1","ttt_vessel","zs_dockhouse","zs_infirmary","zs_last_mansion_v3","zs_snowedin"}
SUPPORTED_MAPS_INSTALLED={}

function MapVoteThing(ply)
	ply:PrintMessage(HUD_PRINTTALK, "[Server_cmd]: Это карты, доступные на этом сервере")
	table.foreach(SUPPORTED_MAPS, function(key,value)
		if file.Exists( "maps/"..value..".bsp", "GAME" ) then
			table.insert(SUPPORTED_MAPS_INSTALLED, value)
			ply:PrintMessage(HUD_PRINTTALK, value)
		end
	end)
end

net.Receive( "light_above_limit", function( length, client )
	net.Start( "Visible" )
	net.Send(client)
	client:SetNoTarget(false)
	client:SendLua(	"light_above_limit = 1" )	
end )

net.Receive( "light_below_limit", function( length, client )
local hidden=1
	for k, v in pairs(ents.FindInSphere(client:GetPos(),5000)) do
			if table.HasValue(CantHideInPlainSight, v:GetClass())then
			if v:Health() > 0 then
				if v:Visible(client) and v:GetEnemy() then
					hidden=0
					client:PrintMessage(HUD_PRINTCENTER , ""..v:GetName().." видел, как ты пытаешься скрыться.")
					break
				end
			end
		end
	
	end
	if hidden==1 then client:SetNoTarget(true)
		client.spotted =  0
		net.Start( "Hidden" )
		net.Send(client)
		net.Start( "NotVisible" )
		net.Send(client)
		client:SendLua(	"light_above_limit = 0" )		
	end
end)

function util.QuickTrace( origin, dir, filter )

	local trace = {}
 
	trace.start = origin
	trace.endpos = origin + dir
	trace.filter = filter

	return util.TraceLine( trace )
end

function GM:Initialize()
	print("------ [GM:Инициализация успешна завершена] ------")
	print("TheHunt 2 версия: 8.6.2. Date: 10/10/2022")
	if !ConVarExists("h_npctrails") then
		CreateClientConVar( "h_npctrails", "0", true, false )
	end
	TEAMKILLERS={}
	STARTING_LOADOUT = {}
	MEDIUMWEAPONS = {}
	SILENTKILLREWARD = {"item_healthvial"}
	teamscore = 0
	HeliCanSpawn = true
	max_weapons_total = 50
	prevent_spotlight_lag = false
	RunConsoleCommand( "mp_falldamage", "1") 
	RunConsoleCommand( "g_ragdoll_maxcount", "6")
	RunConsoleCommand( "r_shadowdist", "200") 
	RunConsoleCommand( "r_shadowcolor", ('20 20 20')) 
	RunConsoleCommand( "sk_helicopter_health", "1500") 
	RunConsoleCommand( "g_helicopter_chargetime", "2") 
	RunConsoleCommand( "sk_helicopter_burstcount", "12") 
	RunConsoleCommand( "sk_helicopter_firingcone", "20") 
	RunConsoleCommand( "sk_helicopter_roundsperburst", "5") 
	RunConsoleCommand( "air_density", "0")
	RunConsoleCommand( "ai_norebuildgraph", "1")   
	VOTES_FOR_RESTART=0
	EnemiesRemainining = 0
	combinen = 0
	CombineAssisting = 0
	ManuallySpawnedEntity = 0
	HeliAangered = 0
	CAN_HEAR_BREAK = 1
	team_silent_kills=0
	team_deaths =0
	team_kills =0
	COMBINE_KILLED = 0
	GAME_ENDED = 0
	LastEnemyWasPlayer=0
	print("------ [Подгрузка основных модулей] ------")
	end

-- UTILITY COMMANDS v
concommand.Add( "h_addonweapons", function(player, command, arguments )
	print("В вашей игре установлено всё это оружие.")
		for k,v in pairs( weapons.GetList() ) do 
			print( v.ClassName )
		end 
	print("")
end)

concommand.Add( "h_gameweapons", function(player, command, arguments )
	print("Через некоторое время оружие будет доступно.")
	PrintTable(MEDIUMWEAPONS)
end)

concommand.Add( "h_dropweapon", function(ply, command, arguments )
	if GetConVarString("h_weight_system") == "1" then timer.Simple(1, function() AdjustWeight(ply) end) end
	ManualWeaponDrop(ply)
end )

concommand.Add( "h_revealcombinespawnpoints", function(player, command, arguments )
	if player:IsAdmin() then
		table.foreach(combinespawnzones, function(key,value)
			local sprite = ents.Create( "env_sprite" )
			sprite:SetPos(value)
			sprite:SetColor( Color( 0,255,255 ) )
			sprite:SetKeyValue( "model", "sprites/light_glow01.vmt" )
			sprite:SetKeyValue( "scale", 0.50 )
			sprite:SetKeyValue( "rendermode", 5 )
			sprite:SetKeyValue( "renderfx", 7 )
			sprite:Spawn()
			sprite:Activate()
			sprite:SetName("ZoneReveal")
		end)
	end
end)

concommand.Add( "h_revealplayerspawnpoints", function(player, command, arguments )
	if player:IsAdmin() then
		table.foreach(SPAWNPOINTS_TO_DELETE, function(key,value)
			for k, v in pairs(ents.FindByClass(value)) do
				print(v:GetClass())
				local sprite = ents.Create( "env_sprite" )
				sprite:SetPos(v:GetPos())
				sprite:SetColor( Color( 0, 255, 0 ) )
				sprite:SetKeyValue( "model", "sprites/light_glow01.vmt" )
				sprite:SetKeyValue( "scale", 0.50 )
				sprite:SetKeyValue( "rendermode", 5 )
				sprite:SetKeyValue( "renderfx", 7 )
				sprite:Spawn()
				sprite:Activate()
				sprite:SetName("ZoneReveal")
			end
		end)
	end
end )

concommand.Add( "h_revealpatrolzones", function(ply)
	if ply:IsAdmin() then
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
		print("Объедините выделенные зоны покрытия.")
	end
end)

concommand.Add( "h_revealweaponspawns", function(ply)
	if ply:IsAdmin() then
		table.foreach(ITEMPLACES, function(key,value)
			local sprite = ents.Create( "env_sprite" )
			sprite:SetPos(value)
			sprite:SetColor( Color( 247,255,3 ) )
			sprite:SetKeyValue( "model", "sprites/light_glow01.vmt" )
			sprite:SetKeyValue( "scale", 0.50 )
			sprite:SetKeyValue( "rendermode", 5 )
			sprite:SetKeyValue( "renderfx", 7 )
			sprite:Spawn()
			sprite:Activate()
			sprite:SetName("ZoneReveal")
		end)
		print("Выделены зоны появления оружия.")
	end
end)

concommand.Add( "h_revealhelipath", function(ply)
	if ply:IsAdmin() then
		for k, v in pairs(ents.FindByClass("path_track")) do 
			sprite = ents.Create( "env_sprite" )
			sprite:SetPos(v:GetPos())
			sprite:SetColor( Color( 255,0,230 ) )
			sprite:SetKeyValue( "model", "sprites/light_glow01.vmt" )
			sprite:SetKeyValue( "scale", 2 )
			sprite:SetKeyValue( "rendermode", 5 )
			sprite:SetKeyValue( "renderfx", 7 )
			sprite:Spawn()
			sprite:Activate()
			sprite:SetName("ZoneReveal")
			print("Путь вертолета выделен.")
		end
	end
end)

concommand.Add( "h_fixtimers", function(ply)

print("Rebooting: Item Respawn System")
timer.Create( "Item Respawn System", 10, 1, ItemRespawnSystem )

print("Rebooting: CombineIdleSpeech")
timer.Create( "CombineIdleSpeech", 20, 0, CombineIdleSpeech ) 

print("Rebooting: CicloUnSegundo")
timer.Create( "CicloUnSegundo", 1, 1, CicloUnSegundo ) 

print("Rebooting: coverzones")
timer.Create( "coverzones", 10, 0, coverzones )

print("Rebooting: wavefinishedchecker")
timer.Create( "wavefinishedchecker", 5, 1, wavefinishedchecker)

table.foreach(player.GetAll(), function(key,value)
value.canspawn = 1
end)

print("Пожалуйста, сообщите об ошибке в комментарий под аддоном.")
end)

concommand.Add( "Spotted", function(ply)
	if ply:IsAdmin() then
		net.Start( "Spotted" )
		net.Send(ply)
	end
end )

concommand.Add( "h_respawnweapons", function(ply)
	print("Респавн оружия "..ply:GetName().."")
	table.foreach(MEDIUMWEAPONS, function(key,value)
		for k,v in pairs(ents.FindByClass(value)) do 
			local canrespawn = 1
				for k, player in pairs(ents.FindInSphere(v:GetPos(),20)) do
					if player:IsPlayer() then
					canrespawn = 0
					print("Игрок имеет "..v:GetClass()..", право удалить.")
					end
				end
			if canrespawn == 1 then
			print("Игрок не найден рядом "..v:GetClass()..", с зоной ликвидацией.")
			v:Remove()
			end
		end
	end)
end )


concommand.Add( "h_version", function(ply)
	ply:PrintMessage(HUD_PRINTTALK, "TheHunt 2 версия: 8.6.2. Date: 10/10/2022")
	ply:PrintMessage(HUD_PRINTTALK, "Последнее изменение: косметические улучшения.")
end )


concommand.Add( "LaunchCanister", function(ply)
	if ply:IsAdmin() then
		SpawnCanister(ply:GetPos())
	end
end)

concommand.Add( "LaunchMortar", function(ply)
	if ply:IsAdmin() then
		LaunchMortarRound(ply)
	end
end)

function LaunchMortarWave()
	LaunchMortarRound(table.Random(player.GetAll()))
end

function LaunchMortarRound(ply)
	if ply:Alive() and ply.disguised==0 then
		local targetTrace = util.QuickTrace( ply:GetShootPos(), ply:GetUp(), ply )		
		if ( targetTrace.HitSky ) then return end
		
		local skyTrace = util.TraceLine( { start = targetTrace.HitPos, endpos = targetTrace.HitPos + Vector( 0, 0, 16383 ), filter = ply, mask = MASK_NPCWORLDSTATIC } )
		if ( !skyTrace.HitSky ) then return end
		if ( skyTrace.HitPos.z <= targetTrace.HitPos.z ) then return end
		
		
		local mortar = ents.Create( "func_tankmortar" )	
			mortar:SetPos( skyTrace.HitPos )
			mortar:SetAngles( Angle( 90, 0, 0 ) )
			mortar:SetKeyValue( "iMagnitude", 90000) // Damage.
			mortar:SetKeyValue( "firedelay", "2" ) // Time before hitting.
			mortar:SetKeyValue( "warningtime", "1" ) // Time to play incoming sound before hitting.
			mortar:SetKeyValue( "incomingsound", "Weapon_Mortar.Incomming" ) // Incoming sound.
		mortar:Spawn()
		
		local target = ents.Create( "info_target" )
			target:SetPos( targetTrace.HitPos )
			target:SetName( tostring( target ) )
		target:Spawn()
		mortar:DeleteOnRemove( target )
	
		mortar:Fire( "SetTargetEntity", target:GetName(), 0 )
		mortar:Fire( "Activate", "", 0 )
		mortar:Fire( "FireAtWill", "", 0 )
		mortar:Fire( "Deactivate", "", 2 )
		mortar:Fire( "kill", "", 1 )
	end
end

concommand.Add( "SpawnAPC", function(ply)
	if ply:IsAdmin() then
		print("Еще не реализовано.")
		local APC = ents.Create( "monster_apc" )
		APC:SetPos(ply:GetEyeTraceNoCursor().HitPos + Vector(0,0,40))
		APC:Spawn()
	end
end)

concommand.Add( "Hidden", function(ply)
	if ply:IsAdmin() then
		net.Start( "Hidden" )
		net.Send(ply)
	end
end )

concommand.Add( "h_nearbyentities", function(ply)
	NearbyEntities()
end)

concommand.Add( "h_killcombine", function(ply)
	if ply:IsAdmin() then
		KillCombine()
		print("Все солдаты альянса убиты.")
	end
end)

concommand.Add( "spawncombinetripmine", function(ply)
	if ply:IsAdmin() then
		print("Еще не реализовано.")
		SpawnItem("combine_tripmine_beam", ply:GetEyeTraceNoCursor().HitPos+Vector(0,0,20), Angle(math.random(-180,180),math.random(-180,180),0))
	end
end)

concommand.Add( "revealtargets", function(ply)
	if ply:IsAdmin() then
		print("Еще не реализовано.")
		for k, v in pairs(ents.FindByClass("info_target")) do 
			sprite = ents.Create( "env_sprite" )
			sprite:SetPos(v:GetPos())
			sprite:SetColor( Color( 0, 255, 255 ) )
			sprite:SetKeyValue( "model", "sprites/light_glow01.vmt" )
			sprite:SetKeyValue( "scale", 2 )
			sprite:SetKeyValue( "rendermode", 5 )
			sprite:SetKeyValue( "renderfx", 7 )
			sprite:Spawn()
			sprite:Activate()
			sprite:SetName("ZoneReveal")
		end
	end
end)

concommand.Add( "h_help", function(ply)
	print("Полезные команды")
	print("h_fixtimers: используйте его, если какая-либо функция перестает работать")
	print("h_version: информация о текущей версии The Hunt.")
	print("Обязательно проверьте эти ссылки, чтобы прочитать справку о том, как играть в этот игровой режим и что этот игровой режим может делать.")
end )

concommand.Add( "h_hidezones", function(ply)
	if ply:IsAdmin() then
		hidezones()
		print("Все спрайты удалены.")
	end
end)

concommand.Add( "assplode", function(ply)
	if ply:IsAdmin() then
		ent = ents.Create( "env_explosion" )
		ent:SetPos(ply:GetEyeTraceNoCursor().HitPos)
		ent:Spawn()
		ent:SetKeyValue( "iMagnitude", "100" )
		print("Assploded")
		ent:Fire("Explode",0,0)
	end
end )

concommand.Add( "assplodeinv", function(ply)
	if ply:IsAdmin() then
		ent = ents.Create( "env_physexplosion" )
		ent:SetPos(ply:GetEyeTraceNoCursor().HitPos)
		ent:SetKeyValue( "spawnflags", 1 )
		ent:SetKeyValue("radius", 300)
		ent:SetKeyValue( "magnitude", 100 )
		ent:Spawn()
		print("Assploded inv")
		ent:Fire("Explode",0,0)
	end
end )

concommand.Add( "beam", function(ply)
	if ply:IsAdmin() then
	print("Не реализовано")
	local laser = ents.Create( "env_beam" )
		laser:SetPos( ply:GetEyeTraceNoCursor().HitPos)
		laser:SetKeyValue( "StrikeTime", "0.2" )
		laser:SetKeyValue( "spawnflags", "5" )
		laser:SetKeyValue( "rendercolor", "200 200 255" )
		laser:SetKeyValue( "texture", "sprites/laserbeam.spr" )
		laser:SetKeyValue( "TextureScroll", "1" )
		laser:SetKeyValue( "Damage", "20" )
		laser:SetKeyValue( "NoiseAmplitude", ""..math.random(5,2) )
		laser:SetKeyValue( "BoltWidth", "1" )
		laser:SetKeyValue( "TouchType", "0" )
		laser:SetKeyValue("Radius", "1000")
		laser:SetKeyValue("life", "0.5")
	laser:Spawn()
	laser:Activate()
	end
end)

concommand.Add( "SpawnMetropolice", function(ply)
	if ply:IsAdmin() then
		SpawnMetropolice( ply:GetEyeTraceNoCursor().HitPos )
		print("Спавн.")
	end
end )
concommand.Add( "SpawnMetropoliceStunstick", function(ply)
	if ply:IsAdmin() then
		SpawnMetropoliceStunstick( ply:GetEyeTraceNoCursor().HitPos )
		print("Спавн.")
	end
end )

concommand.Add( "SpawnCombineSynth", function(ply)
	if ply:IsAdmin() then
		SpawnCombineSynth( ply:GetEyeTraceNoCursor().HitPos + Vector(0,0,20))
		print("Спавн.")
	end
end )
concommand.Add( "SpawnFastZombie", function(ply)
	if ply:IsAdmin() then
		SpawnFastZombie( ply:GetEyeTraceNoCursor().HitPos + Vector(0,0,20))
		print("Спавн.")
	end
end )
concommand.Add( "SpawnRebel", function(ply)
	if ply:IsAdmin() then
		SpawnRebel( ply:GetEyeTraceNoCursor().HitPos + Vector(0,0,20),ply:GetName())
		print("Спавн.")
	end
end)
concommand.Add( "SpawnRollermine", function(ply)
	if ply:IsAdmin() then
		SpawnRollermine( ply:GetEyeTraceNoCursor().HitPos + Vector(0,0,20))
		print("Спавн.")
	end
end )

concommand.Add( "SpawnCombineElite1", function(ply)
	if ply:IsAdmin() then
		SpawnCombineElite1( ply:GetEyeTraceNoCursor().HitPos)
		print("Спавн.")
	end
end)

concommand.Add( "SpawnCombineElite2", function(ply)
	if ply:IsAdmin() then
		SpawnCombineElite2( ply:GetEyeTraceNoCursor().HitPos)
		print("Спавн.")
	end
end )

concommand.Add( "SpawnTurret", function(ply)
	if ply:IsAdmin() then
		SpawnTurret( ply:GetEyeTraceNoCursor().HitPos + Vector(0,0,5), ply:EyeAngles())
		print("Спавн.")
	end
end )
concommand.Add( "SpawnCombineS1", function(ply)
	if ply:IsAdmin() then
		SpawnCombineS1( ply:GetEyeTraceNoCursor().HitPos)
		print("Спавн.")
	end
end )
concommand.Add( "SpawnCombineS2", function(ply)
	if ply:IsAdmin() then
		SpawnCombineS2( ply:GetEyeTraceNoCursor().HitPos)
		print("Спавн.")
	end
end )
concommand.Add( "SpawnScanner", function(ply)
	if ply:IsAdmin() then
		SpawnScanner( ply:GetEyeTraceNoCursor().HitPos)
		print("Спавн.")
	end
end )

concommand.Add( "SpawnAssasin", function(ply)
	if ply:IsAdmin() then
		SpawnAssasin( ply:GetEyeTraceNoCursor().HitPos)
		print("Спавн.")
	end
end )

concommand.Add( "SpawnCremator", function(ply)
	if ply:IsAdmin() then
		SpawnCremator( ply:GetEyeTraceNoCursor().HitPos)
		print("Спавн.")
	end
end )

concommand.Add( "SpawnCombineSFlashlight", function(ply)
	print("Не реализовано.")
	if ply:IsAdmin() then
		SpawnCombineSFlashlight( ply:GetEyeTraceNoCursor().HitPos)
		print("Спавн.")
	end
end )

concommand.Add( "firstwave", function(ply)
	if ply:IsAdmin() then
		--Wave = 1
		timer.Create( "firstwave", 1, CombineFirstWave, firstwave )
		--WAVESPAWN = 1
		--timer.Simple( 30, function() CanCheck = 1 print("[The Hunt]: Can check is 1, wave can be defeated now.") end )
		--timer.Simple( CUSTOMWAVESPAWN, function() WAVESPAWN = 0 print("[The Hunt]: wavespawn is now 0") end )	
	end
end)

concommand.Add( "secondwave", function(ply)
	if ply:IsAdmin() then
		--Wave = 2
		timer.Create( "secondwave", 1, CombineSecondWave, secondwave ) 
		--WAVESPAWN = 1
		--timer.Simple( 30, function() CanCheck = 1 print("[The Hunt]: Can check is 1, wave can be defeated now.") end )
		--timer.Simple( CUSTOMWAVESPAWN, function() WAVESPAWN = 0 print("[The Hunt]: wavespawn is now 0") end )	
	end
end )
concommand.Add( "thirdwave", function(ply)
	if ply:IsAdmin() then
		--Wave = 3
		timer.Create( "thirdwave", 1, CombineThirdWave, thirdwave ) 
		--WAVESPAWN = 1
		--timer.Simple( 30, function() CanCheck = 1 print("[The Hunt]: Can check is 1, wave can be defeated now.") end )
		--timer.Simple( CUSTOMWAVESPAWN, function() WAVESPAWN = 0 print("[The Hunt]: wavespawn is now 0") end )	
	end
end )
concommand.Add( "fourthwave", function(ply)
	if ply:IsAdmin() then
		--Wave = 4
		timer.Create( "fourthwave", 1, CombineFourthWave, fourthwave ) 
		--WAVESPAWN = 1
		--timer.Simple( 30, function() CanCheck = 1 print("[The Hunt]: Can check is 1, wave can be defeated now.") end )
		--timer.Simple( CUSTOMWAVESPAWN, function() WAVESPAWN = 0 print("[The Hunt]: wavespawn is now 0") end )	
	end
end )
concommand.Add( "fifthwave", function(ply)
	if ply:IsAdmin() then
		--Wave = 5
		timer.Create( "fifthwave", 1, CombineFifthWave, fifthwave ) 
		--WAVESPAWN = 1
		--timer.Simple( 30, function() CanCheck = 1 print("[The Hunt]: Can check is 1, wave can be defeated now.") end )
		--timer.Simple( CUSTOMWAVESPAWN, function() WAVESPAWN = 0 print("[The Hunt]: wavespawn is now 0") end )	
	end
end )

concommand.Add( "infinitewave", function()
	if player:IsAdmin() then
		Wave = 6
		infinitewavehandler()
	end
end )

-- Called by waves if the wave should spawn an helicopter.
function HelicopterWave(maxhelis)
	if HeliCanSpawn == true and HELIPATHS then
		RPGCANSPAWN = 1
		local NumHelis = 0
		for k, v in pairs(ents.FindByClass("npc_helicopter")) do
			NumHelis=NumHelis+1
		end
		for k, v in pairs(ents.FindByClass("npc_combinegunship")) do
			NumHelis=NumHelis+1
		end
	
		if NumHelis >= maxhelis then
			print("Уже слишком много вертолетов на карте")
		else
			SpawnHeliA(table.Random(HELIPATHS), ""..table.Random(AirEnemies).."" ,1,1)
		end
	end
end




-- Counts the players.
function NUMPLAYERS()
	PLAYERSINMAP=0
	for k, v in pairs(ents.FindByClass("player")) do
		PLAYERSINMAP=PLAYERSINMAP+1
	end
end

-- Counts whatever entity you want to count.
function CountEntity(ent)
--print(""..tostring(ent).."")
local entities=0
		for k, v in pairs(ents.GetAll()) do
		if v.HuntID == tostring(ent) then
			entities=entities+1
		end
		end

	--	print(""..entities.."")
		return(entities)
end

-- Plays a random Overwatch announcement sound on a random player.
function OverwatchAmbientOne()
		table.Random(player.GetAll()):EmitSound(table.Random(OverwatchAmbientSoundsOne), 100, 100)
end

-- What happens while a player is dead.
function GM:PlayerDeathThink(ply)
	if PLAYERSINMAP>1 then
		if ply:KeyPressed(IN_ATTACK2) then
		ply:UnSpectate()
		ply:Spectate(4)
		ply:SetMoveType(10)
		ply:SpectateEntity(table.Random(player.GetAll()))
		end
	else
		if ply:KeyPressed(IN_ATTACK2) then
		ply:UnSpectate()
		ply:Spectate(6)
		ply:SetMoveType(10)
		end
	end
	if ply:KeyPressed(IN_ATTACK) then
		if ply.canspawn == 1 then
			ply:UnSpectate()
			ply:Spawn()
		end
	end
end

-- Prints every entity that is near you, on the console.
function NearbyEntities()
print(player.GetByID(1):GetEyeTraceNoCursor().Entity:EntIndex())
/*
	print("Entities found:")
	for k, v in pairs(ents.FindInSphere(player.GetByID(1):GetPos(),256)) do
		print(""..v:GetClass()..", "..v:GetName()..", "..v:EntIndex().."")
	end
	print("Entities found:")
	*/
end

-- Utility function to kill every combine.
function KillCombine()
	for k, v in pairs(ents.FindByClass("npc_combine_s")) do
		v:Remove()
		COMBINE_KILLED = COMBINE_KILLED+1
	end
	for k, v in pairs(ents.FindByClass("npc_metropolice")) do
		v:Remove()
		COMBINE_KILLED = COMBINE_KILLED+1
	end
end

-- Function wich starts the first wave on every game automatically.
function autofirstwave()
	timer.Simple(1, firstwave)
	--timer.Create( "firstwave", 1, CombineFirstWave, firstwave )
	--timer.Create( "coverzonesall", 1, CUSTOMWAVESPAWN, coverzones)
	CombineSelectSpawn()
	Wave = 1
	combinen = 0
	CAN_HEAR_BREAK = 1
	team_silent_kills=0
	team_deaths =0
	team_kills =0
	COMBINE_KILLED = 0
	cansilentkillreward = 1
	--timer.Simple( 30, function() CanCheck = 1 print("[The Hunt]: Can check is 1, wave can be defeated now.") end )
	----timer.Simple( CUSTOMWAVESPAWN, function() WAVESPAWN = 0 print("[The Hunt]: wavespawn is now 0") end )		
end

function wavefinishedchecker()
	if teamscore > 99 and team_deaths < 10 then
	if math.random (1,4) == 1 then
	timer.Create("mortar_attacks", 4, math.random(1,4), LaunchMortarWave)
	end
	end

	if teamscore > 49  and teamscore < 100 and team_deaths < 5 then
	if math.random (1,6) == 1 then
	SpawnCanisterWave(table.Random(player.GetAll()))
	end
	end

	timer.Create( "wavefinishedchecker", 10, 1, wavefinishedchecker)
	EnemiesRemainining=0
	local BossHeliAlive=0
	
	table.foreach(MainEnemies, function(key,enemy)
		for k, npc in pairs(ents.FindByClass(enemy)) do
			EnemiesRemainining=EnemiesRemainining+1
		end
	end)

	for k, v in pairs(ents.FindByClass("npc_helicopter")) do
		if v.boss == 1 and v:Health() > 5 then
			BossHeliAlive = 1
		end
	end
	for k, v in pairs(ents.FindByClass("npc_combinegunship")) do
		if v.boss == 1 and v:Health() > 5 then
			BossHeliAlive = 1
		end
	end

	if BossHeliAlive == 0 or BossHeliAlive == nil then
		if CanCheck == 1 then 
			if EnemiesRemainining < GetConVarNumber("h_minenemies") then			
			table.foreach(player.GetAll(), function(key,value)
				net.Start( "Hidden" )
				net.Send(value)
				value.spotted = 0
				if value.lifes < 1 and value.teamkiller < 3 then 
				value.canspawn = 1
				value.lifes = GetConVarNumber("h_player_lifes")/2
				if !value:Alive() then
					value:PrintMessage(HUD_PRINTTALK, "Теперь вы можете возродиться. У вас есть "..value.lifes.." жизней.")
				end
				end
			end)
			
			-- This means combine defeat.
			if COMBINE_KILLED > GetConVarNumber("h_combine_killed_to_win") then
			GAME_ENDED = 1
				PrintMessage(HUD_PRINTTALK, "[Альянс]: Оповещение: провал миссии. Было потеряно "..GetConVarNumber("h_combine_killed_to_win").." сухопутных частей.")
				PrintMessage(HUD_PRINTTALK, "[Альянс]: Остальным юнитам прекратить наступление и вернуться в зону мобилизации и ожидать дальнейшую эвакуацию.")
				timer.Simple(13, function() PrintMessage(HUD_PRINTTALK, "Поздравляем, вы выиграли! Вы предотвратили аттаку альянса. Вот статистика:") end)
				timer.Simple(16, function()	TeamStats() end)
				CanCheck = 0
			else
				waveend()
				end

			end
		end
	end
end

-- This function is called when the game ends. It tries to show the players how well they did. Best player, worst player, etc.
function TeamStats()
	teamscore = (team_kills+(team_silent_kills*3))-(team_deaths*(PLAYERSINMAP+1))
	local TimeStr = os.date( "%d/%m/%Y - %X" )
	
	PrintMessage(HUD_PRINTTALK, "Вместе с "..PLAYERSINMAP.." участниками эта команда убила"..team_kills+team_silent_kills.." комбайн(ов) и умерло "..team_deaths.." раз(а).")
	
	-- Prepare all the variables...
	local MostKills = 0 
	local MostKiller
	local MostDeaths = 0
	local WorstPlayer
	local MostSilentKills = 0
	local MostSilentPlayer
	local BestScore = 0
	local BestScorePlayer
	local BestScorePlayerEntity

	-- Find player with most kills
	for k,v in pairs( player.GetAll() ) do  
		local Frags = v.Kills + v.SilentKills 
		if Frags > MostKills then  
			MostKills = Frags   
			MostKiller = v:Name() 
		end
	end

	-- Find player with most deaths
	for k,v in pairs( player.GetAll() ) do  	
		local Deaths = v.deaths    
		if Deaths > MostDeaths then
			MostDeaths = Deaths    
			WorstPlayer = v:Name() 
		end
	end

	-- Find player with most Silent Kills	
	for k,v in pairs( player.GetAll() ) do
		local SilentKills = v.SilentKills     // Getting a player's frags
		if SilentKills > MostSilentKills then     // If it's higher then the current MostKills then
			MostSilentKills = SilentKills     // Make it the new MostKills
			MostSilentPlayer = v:Name() // And make the player the new MostKiller
		end
	end

	-- Find player with most score
	for k,v in pairs( player.GetAll() ) do
		local score = ComparePlayerScore(v)    // Getting a player's frags
		if score > BestScore then     // If it's higher then the current MostKills then
			BestScore = score     // Make it the new MostKills
			BestScorePlayer = v:Name() // And make the player the new MostKiller
			BestScorePlayerEntity = v
		end
	end
	
	-- Show player with most kills
	if MostKills != 0 then
		PrintMessage(HUD_PRINTTALK, "" .. MostKiller .. " имеет наибольшее количество убийств,  " .. tostring(MostKills) .. " комбайн(ов) потерпел(о) поражение!") 
	else
		PrintMessage(HUD_PRINTTALK, "Пока никто никого не убил.") 
	end
	
	-- Show player with most Silent Kills
	if MostSilentKills != 0 then 
		PrintMessage(HUD_PRINTTALK, ""..MostSilentPlayer.." имеет самые бесшумные убийства, "..tostring(MostSilentKills)..".")
	else
		PrintMessage(HUD_PRINTTALK, "Ни одного бесшумного убийства за всю игру. Ничего себе, вы просто зверь!.") 
	end
	
	-- Show player with most deaths
	if MostDeaths != 0 then
		PrintMessage(HUD_PRINTTALK, "" .. WorstPlayer .. " больше всего умер, " .. tostring(MostDeaths) .. " раз.") 
	else
		PrintMessage(HUD_PRINTTALK, "Ни один из повстанцев не был убит в этой игре! Поздравляем!") 
	end
	
	-- Show player with most score
	if BestScore != 0 then
		PrintMessage(HUD_PRINTTALK, "" .. BestScorePlayer .. " имеет лучший результат, " .. tostring(BestScore) .. " баллы!") 
	end
	
	timer.Simple(20, function() PrintMessage(HUD_PRINTTALK, "Вы можете проверить табло, набрав !teamscore.") end)
	timer.Simple(40, function() PrintMessage(HUD_PRINTTALK, "Вы выполнили свою задачу!") end)
	
	include("thehunt/best_team.lua")
	local players_team={}
	table.foreach(player.GetAll(), function(key,ply)
		table.insert(players_team,ply:GetName())
	end)
	
	if teamscore > BEST_TEAM_SCORE then
		timer.Simple(6, function()
			PrintMessage(HUD_PRINTTALK, "Новая лучшая команда!") 
			PrintMessage(HUD_PRINTTALK, ""..teamscore.." очков ("..teamscore-BEST_TEAM_SCORE.." больше, чем у последней команды)") 
		end)		
	else
		timer.Simple(6, function()
			PrintMessage(HUD_PRINTTALK, "Командный счет: "..teamscore.."")
			PrintMessage(HUD_PRINTTALK, "Последняя лучшая команда:") 
			PrintMessage(HUD_PRINTTALK, ""..string.Implode( ", ", BEST_TEAM_NAMES ).."") 
			PrintMessage(HUD_PRINTTALK, ""..BEST_TEAM_SCORE.." очки ("..BEST_TEAM_DATE..")") 
		end)
	end
	
	if BestScore > BEST_PLAYER_ALL_TIME_SCORE then
		timer.Simple(6, function()
			PrintMessage(HUD_PRINTTALK, ""..BestScorePlayer.." новый лучший игрок с "..BestScore.." очками!") 
			PrintMessage(HUD_PRINTTALK, "("..BestScore-BEST_PLAYER_ALL_TIME_SCORE.." больше, чем последний лучший игрок, "..BEST_PLAYER_ALL_TIME_NAME.." )") 
		end)
	else
		timer.Simple(6, function()
			PrintMessage(HUD_PRINTTALK, ""..BEST_PLAYER_ALL_TIME_NAME.." по-прежнему удерживает звание лучшего игрока, с"..BEST_PLAYER_ALL_TIME_SCORE.." очками. ") 
			PrintMessage(HUD_PRINTTALK, ""..BEST_PLAYER_ALL_TIME_SCORE.." баллы (заработанные "..BEST_PLAYER_ALL_TIME_DATE..")") 
		end)
	end
end

function PlayerStats(ply)
	for k,ply in pairs( player.GetAll() ) do
		local killpercent = ((ply.Kills+ply.SilentKills)/(team_kills+team_silent_kills))*100
		local deathpercent = (ply.deaths/team_deaths)*100
		local ply_points = ((ply.Kills+(ply.SilentKills*3)-ply.deaths*2))
		
		ply:PrintMessage(HUD_PRINTTALK, "Ты убил "..ply.Kills+ply.SilentKills.." Комбайнов. ("..math.Round(killpercent).."% из команды убивает).")
		if ply.deaths == 0 then
			ply:PrintMessage(HUD_PRINTTALK, "Вы пережили всю игру!")
		else
			ply:PrintMessage(HUD_PRINTTALK, "Вы были убиты "..ply.deaths.." раз ("..math.Round(deathpercent).."% гибель команды)).")
		end
		ply:PrintMessage(HUD_PRINTTALK, "Твой счет: "..ply_points.." points.")
		if (ply.SilentKills/(ply.Kills+ply.SilentKills))*100 > 50 and(ply.SilentKills > 0 and ply.Kills > 0) then
			ply:PrintMessage(HUD_PRINTTALK, "Специальное упоминание: Бесшумные убийства ("..math.Round(((ply.SilentKills/(ply.Kills+ply.SilentKills))*100)) .."%)")
		end
	end
end

function waveend()
CanCheck = 0
	--WAVESPAWN = 1
	timer.Simple (1, OverwatchAmbientOne)
	if Wave < 5 then
		PrintMessage(HUD_PRINTTALK, "[Альянс]: Отряд Nº"..Wave.." подтвердил вторженине из вне, вызваны вспомогательные наземные силы. Ожидать поддержки!")
		
		for k,v in pairs( player.GetAll() ) do  
			if v.sex == "male" then v:EmitSound(table.Random(malewin), 100, 100) else
				v:EmitSound(table.Random(femalewin), 100, 100)
			end
		end

	end

		timer.Simple(GetConVarNumber("h_time_between_waves"), function()
		--timer.Simple( 30, function() CanCheck = 1 print("[The Hunt]: Can check is 1, wave can be defeated now.") end )
		----timer.Simple( CUSTOMWAVESPAWN, function() WAVESPAWN = 0 print("[The Hunt]: wavespawn is now 0") end )		
		if Wave == 1 then  secondwave() print("wave 2")
		PrintMessage(HUD_PRINTTALK, "[Альянс]: Отряд Nº"..(Wave+1).." доставлен. Директива №2 Задействовать резерв - Сдерживать вторженине")
		elseif Wave == 2 then thirdwave() print("wave 3")
		PrintMessage(HUD_PRINTTALK, "[Альянс]: Отряд Nº"..(Wave+1).." доставлен. Директива №2 Задействовать резерв - Сдерживать вторженине")
		elseif Wave == 3 then fourthwave() print("wave 4")
		PrintMessage(HUD_PRINTTALK, "[Альянс]: Отряд Nº"..(Wave+1).." доставлен. Директива №2 Задействовать резерв - Сдерживать вторженине")
		elseif Wave == 4 then fifthwave()  print("wave 5")
		PrintMessage(HUD_PRINTTALK, "[Альянс]: Отряд Nº"..(Wave+1).." доставлен. Директива №2 Задействовать резерв - Сдерживать вторженине")
		elseif Wave == 5  or Wave > 5 then print("wave 6")
		infinitewavehandler()
		end
			Wave = Wave+1
	end)

	table.foreach(player.GetAll(), function(key,ply)
		ply:SetNWInt("ReferentScore",ply:GetNWInt("Score"))
		CalculatePlayerScore(ply)
	end)
end

function infinitewavehandler()

		for k,v in pairs( player.GetAll() ) do  
			if v.sex == "male" then v:EmitSound(table.Random(malewin), 100, 100) else
				v:EmitSound(table.Random(femalewin), 100, 100)
			end
		end

	CanCheck = 0
	Wave = 6
	if INFINITE_ACHIEVED == 1 then
		PrintMessage(HUD_PRINTTALK, "[Повстанец]: "..table.Random(OVERWATCH_TAUNTS).."")
else
		INFINITE_ACHIEVED = 1
		PrintMessage(HUD_PRINTTALK, "[Альянс]: Штурмовик на подходе, обеспечьте поддержку.")
	end	
	timer.Simple(GetConVarNumber("h_time_between_waves"), function()
		--timer.Simple( CUSTOMWAVESPAWN, function() WAVESPAWN = 0 print("[The Hunt]: wavespawn is now 0") end )		
		infinitewave()
		--timer.Simple(20, function() CanCheck = 1 end)
	end)
end

function CreateHeliPath(pos)
	creating = ents.Create( "path_track" )
	creating:SetPos( pos )
	creating:Spawn()
end

function hidezones()
	for k, v in pairs(ents.FindByName("ZoneReveal") ) do
		v:Remove()
	end
end

function SpawnHeliA( pos,type,IsBoss,GunOnAtSpawn )
	RunConsoleCommand( "sk_helicopter_health", "1500")
	RunConsoleCommand( "g_helicopter_chargetime", "2") 
	RunConsoleCommand( "sk_helicopter_burstcount", "12") 
	RunConsoleCommand( "sk_helicopter_firingcone", "20") 
	RunConsoleCommand( "sk_helicopter_roundsperburst", "5") 
	timer.Simple( 3, helipath ) 
	HeliA = ents.Create( ""..type.."" )
	HeliA:SetKeyValue( "targetname", "Heli" )
	HeliA:SetKeyValue( "ignoreunseenenemies", 1 )
	HeliA:SetKeyValue( "spawnflags", "262144" )
	HeliA:SetKeyValue( "patrolspeed", "500" )
	HeliA:SetKeyValue("squadname", "heliaforce")
	HeliA:SetPos( pos )
	HeliA.boss = IsBoss
	if type == "npc_combinegunship" then
		RunConsoleCommand( "sk_gunship_health_increments", 8) 
		HeliA:Fire("SetPenetrationDepth ","24",0)
		HeliA:Fire("BlindfireOn","",0)
	end
	HeliA:SetCustomCollisionCheck(true)
	HeliA:Spawn()
	HeliA:Activate()
	HeliA:Fire("activate","",0)
	-- HeliA:Fire("missileon","",0)
	if type == "npc_helicopter" then
	HeliA:Fire("gunon","",1)
	HeliA.spotlight = ents.Create( "point_spotlight" )
	HeliA.spotlight:SetPos(HeliA:GetPos()+(HeliA:GetForward()*150+Vector(0,0,-50)))
	HeliA.spotlight:SetAngles(HeliA.spotlight:GetAngles()+Angle(30,0,0))
	HeliA.spotlight:SetParent(HeliA)
	HeliA.spotlight:SetKeyValue( "spawnflags", "1" )
	HeliA.spotlight:SetKeyValue( "SpotlightWidth", "50" )
	HeliA.spotlight:SetKeyValue( "SpotlightLength", "200" )
	HeliA.spotlight:SetKeyValue("rendercolor", "100 200 200")
	HeliA.spotlight:Spawn()
	HeliA.spotlight:Activate()

	if type == "npc_helicopter" then
		HeliA.light = ents.Create("env_projectedtexture");
		HeliA.light:SetPos(HeliA:GetPos());
		HeliA.light:SetAngles(HeliA:GetAngles()+Angle(30,0,0) );
		HeliA.light:SetParent(HeliA);
		HeliA.light:SetKeyValue("spawnflags", 2);
		HeliA.light:SetKeyValue("enableshadows", 1)
		HeliA.light:SetKeyValue("farz", 2000);
		HeliA.light:SetKeyValue("target", "");
		HeliA.light:SetKeyValue("nearz", 400);
		HeliA.light:SetKeyValue("lightfov", 20);
		HeliA.light:SetKeyValue("lightcolor", "0 255 255")
		HeliA.light:SetKeyValue("shadowquality", 1)
		HeliA.light:SetKeyValue("lightstrength", 5)
		HeliA.light:Spawn()
		HeliA.light:Activate()
	end
	end
	timer.Simple(10, function()
		HeliCanSpawn = false
		print("Вертолеты выведены из строя на 10 минут.")
		timer.Create( "HeliCoolDown", 600, 1, function() HeliCanSpawn = true print("Штурмовики могут появиться снова.") end )
	end)
end

function SpawnDynamicResuply( pos )
	NPC = ents.Create( "item_dynamic_resupply" )
	NPC:SetPos( pos )
	NPC:SetKeyValue("DesiredHealth", 0.3)
	NPC:SetKeyValue("DesiredArmor", 0.25)
	NPC:SetKeyValue("DesiredAmmoPistol", 0)
	NPC:SetKeyValue("DesiredAmmoSMG1", 0.1)
	NPC:SetKeyValue("DesiredAmmoSMG1_Grenade", 0.1)
	NPC:SetKeyValue("DesiredAmmoAR2", 00)
	NPC:SetKeyValue("DesiredAmmoBuckshot", 0.1)
	NPC:SetKeyValue("DesiredAmmoRPG_Round", 0)
	NPC:SetKeyValue("DesiredAmmoGrenade",0.1)
	NPC:SetKeyValue("DesiredAmmo357", 0.3)
	NPC:SetKeyValue("DesiredAmmoCrossbow", 0.2)
	NPC:Spawn()
end

function SpawnScanner ( pos )
	NPC = ents.Create( "npc_cscanner" )
	NPC:SetPos( pos )
	NPC:SetKeyValue("neverinspectplayers", 1)
	NPC:SetKeyValue("SetDistanceOverride", 2)
	NPC:Spawn()
	NPC:SetName("Scanner")
	NPC:Fire("SetFollowTarget","Combine",0)
	NPC:Fire("EquipMine","",0)
	NPC:Fire("DeployMine","",0)
	NPC:Activate()
end

function SpawnCombineSFlashlight ( pos )
	NPC = ents.Create( "npc_combine_s" )
	NPC:SetKeyValue("NumGrenades", ""..math.random(0,3).."") 
	NPC:SetPos( pos )
	NPC:SetKeyValue( "ignoreunseenenemies", 0 )
	NPC:Spawn()
	NPC:Give("ai_weapon_ar2")
	combinen = combinen + 1
	NPC:SetName("Combine nº"..combinen.."")
	NPC:SetCurrentWeaponProficiency( WEAPON_PROFICIENCY_GOOD )
	NPC:Fire("StartPatrolling","",0)
	NPCSpotlight = ents.Create("env_projectedtexture");
	NPCSpotlight:SetPos(NPC:GetShootPos()+(NPC:GetForward()*20)+Vector(0,0,-50))
	NPCSpotlight:SetName(""..NPC:GetName().."_flashlight");
	NPCSpotlight:SetAngles( Angle(20,0,0) );
	NPCSpotlight:SetParent(NPC);
	NPCSpotlight:SetKeyValue("spawnflags", 2);
	NPCSpotlight:SetKeyValue("enableshadows", 0);
	NPCSpotlight:SetKeyValue("farz", 700);
	NPCSpotlight:SetKeyValue("target", "");
	NPCSpotlight:SetKeyValue("nearz", 15);
	NPCSpotlight:SetKeyValue("lightfov", 70);
	NPCSpotlight:SetKeyValue("lightcolor", "100 200 200")
	NPCSpotlight:SetKeyValue("shadowquality", 1)
	NPCSpotlight:SetKeyValue("lightstrength", 2)
	for k,NPCWeapon in pairs (ents.FindInSphere(NPC:GetPos(),30)) do
		if NPCWeapon:IsWeapon() then
			NPCSpotlight:SetAngles(NPCWeapon:GetAngles())
			NPCSpotlight:SetParent(NPCWeapon)
		end
	end
	
	NPCSpotlight = ents.Create( "point_spotlight" )
	NPCSpotlight:SetPos(NPC:GetShootPos()+(NPC:GetForward()*20)+Vector(0,0,-50))
	-- NPCSpotlight:SetAngles( Angle(20,0,0) )
	for k,NPCWeapon in pairs (ents.FindInSphere(NPC:GetPos(),30)) do
		if NPCWeapon:IsWeapon() then
		NPCSpotlight:SetAngles(NPCWeapon:GetAngles())
		NPCSpotlight:SetParent(NPCWeapon)
	end
	end
	NPCSpotlight:SetKeyValue( "spawnflags", "1" )
	NPCSpotlight:SetKeyValue( "SpotlightWidth", "20" )
	NPCSpotlight:SetKeyValue( "SpotlightLength", "200" )
	NPCSpotlight:Spawn()
	NPCSpotlight:Activate()
end

function SpawnCanister( pos )
	traceRes = util.QuickTrace(pos, Vector(0,0,2000), player.GetAll())
	print(traceRes.Entity)
	if traceRes.Entity == NULL or traceRes.HitSky then 
		print("[The Hunt]: Место подходит для размещения канистры ")	
		local canister = ents.Create( "env_headcrabcanister" )
			canister:SetAngles(Angle(-70,math.random(180,-180),0))
			canister:SetPos(pos)
			canister:SetKeyValue( "HeadcrabType", math.random(0,2) )
			canister:SetKeyValue( "HeadcrabCount", math.random(3,6) )
			canister:SetKeyValue( "FlightSpeed", "8000" )
			canister:SetKeyValue( "FlightTime", "3" )
			canister:SetKeyValue( "StartingHeight", "0" )
			canister:SetKeyValue( "Damage", "200" )
			canister:SetKeyValue( "DamageRadius", "5" )
			canister:SetKeyValue( "SmokeLifetime", "5" )
			canister:SetKeyValue( "MaxSkyboxRefireTime", "5" )
			canister:SetKeyValue( "MinSkyboxRefireTime", "1" )
			canister:SetKeyValue( "SkyboxCannisterCount", "30" )
			canister:Fire("FireCanister","",0.7)
		canister:Spawn()	
		timer.Simple(100, function() canister:Remove() end)
	else
		print("[The Hunt]: Место НЕ подходит для размещения канистры. Игрок находится под низким потолком.")	
	end
end

function util.QuickTrace( origin, dir, filter )
	local trace = {}
	trace.start = origin
	trace.endpos = origin + dir
	trace.filter = filter
	return util.TraceLine( trace )
end

function SpawnCanisterWave(ply)
if ply.disguised==0 then 
	pos = ply:GetPos()
	traceRes = util.QuickTrace(pos, Vector(0,0,1000), player.GetAll())
	if traceRes.Entity == NULL then 
		print("[The Hunt]: Место подходит для размещения канистры.")
		local canister = ents.Create( "env_headcrabcanister" )
			canister:SetAngles(Angle(-70,math.random(180,-180),0))
			canister:SetPos(pos)
			canister:SetKeyValue( "HeadcrabType", math.random(0,2) )
			canister:SetKeyValue( "HeadcrabCount", math.random(3,8) )
			canister:SetKeyValue( "FlightSpeed", "9000" )
			canister:SetKeyValue( "FlightTime", "3" )
			canister:SetKeyValue( "StartingHeight", "0" )
			canister:SetKeyValue( "Damage", "200" )
			canister:SetKeyValue( "DamageRadius", "5" )
			canister:SetKeyValue( "SmokeLifetime", "5" )
			canister:SetKeyValue( "MaxSkyboxRefireTime", "5" )
			canister:SetKeyValue( "MinSkyboxRefireTime", "1" )
			canister:SetKeyValue( "SkyboxCannisterCount", "30" )
			canister:Fire("FireCanister","",0.7)
		canister:Spawn()	
		timer.Simple(60, function() canister:Remove() end)
	else
		print("[The Hunt]: Место НЕ подходит для размещения канистры.")
	end
	end
end

function SpawnRebel( pos,ply )
	NPC = ents.Create( "npc_citizen" )
	NPC:SetPos( pos )
	NPC.HuntID="Rebel"
	NPC:SetNWString("name", "Rebel")
	NPC:SetKeyValue("squadname", "Rebels")
	NPC:SetKeyValue("citizentype", "3")
	NPC:Give(table.Random(REBEL_WEAPONS))
	--NPC:SetKeyValue("ammosupply", ""..table.Random(RebelsGiveAmmo).."")
	NPC:SetKeyValue("spawnflags", "65536")
	NPC.owner=""..ply:GetName()..""
	NPC:SetKeyValue( "ignoreunseenenemies", 1 )
	NPC:Spawn()
	NPC:SetHealth("100")
	NPC:SetCurrentWeaponProficiency( WEAPON_PROFICIENCY_PERFECT )	
	--NPC:Fire("StartPatrolling","",0)
	NPC:SetCustomCollisionCheck(true)

	timer.Simple(1, function()
		NPC:SetLastPosition(ply:GetPos())
		NPC:SetSchedule(SCHED_FORCED_GO_RUN)	
		ply:SendLua("notification.AddLegacy('Используйте E, чтобы сообщить своим союзникам, куда вы хотите, чтобы они отправились.',   NOTIFY_HINT  , 6 )")
	end)
end

function SpawnFastZombie( pos )
	NPC = ents.Create( "npc_fastzombie" )
	NPC:SetPos( pos )
	NPC:Spawn()
	NPC:SetHealth("9000")
end

function spawnSNPC ( pos )
	NPC = ents.Create( "npc_megacombine" )
	NPC:SetKeyValue("NumGrenades", "0") 
	NPC:SetPos( pos )
	NPC:SetKeyValue( "ignoreunseenenemies", 1 )
	NPC:Spawn()
	combinen = combinen + 1
	NPC:SetName("Комбайн nº"..combinen.."")
end

function SpawnHunter(pos)
	NPC = ents.Create( "npc_hunter" )
	NPC:SetPos( pos )
	NPC.HuntID="Hunter"
	NPC:Spawn()
	combinen = combinen + 1
	NPC:SetName("Hunter")
end

function SpawnCombineBouncer(pos)
	NPC = ents.Create( "combine_bouncer" )
	NPC:SetPos( pos )
	NPC:Spawn()
end
function SpawnCombineS1 ( pos )
	NPC = ents.Create( "npc_combine_s" )
	NPC:SetKeyValue("NumGrenades", "0") 
	NPC:SetPos( pos )
	NPC:SetKeyValue( "ignoreunseenenemies", 1 )
	NPC:SetKeyValue( "spawnflags", 512 )
	NPC.HuntID="CombineS1"
	NPC:Spawn()
	if GetConVarNumber("h_combine_custom_weapons") == 1 then
		NPC:Give(""..table.Random(NPC_WEAPON_PACK_2_RAPID_FIRE).."")
	else
		NPC:Give("ai_weapon_ar2")
	end
	combinen = combinen + 1
	NPC:SetName("Комбайн nº"..combinen.."")
	NPC:SetCurrentWeaponProficiency( WEAPON_PROFICIENCY_GOOD )
	NPC:Fire("StartPatrolling","",0)
end

function SpawnCombineS2 ( pos )
	NPC = ents.Create( "npc_combine_s" )
	NPC:SetKeyValue("NumGrenades", ""..math.random(1,3).."") 
	NPC:SetPos( pos )
	NPC:SetKeyValue( "ignoreunseenenemies", 0 )
	NPC:SetKeyValue( "spawnflags", 512 )
	NPC.HuntID="CombineS2"
	NPC:Spawn()
	if GetConVarNumber("h_combine_custom_weapons") == 1 then
		NPC:Give(""..table.Random(NPC_WEAPON_PACK_2_RAPID_FIRE).."")
	else
		NPC:Give("ai_weapon_ar2")
	end
	combinen = combinen + 1
	NPC:SetName("Комбайн nº"..combinen.."")
	NPC:SetCurrentWeaponProficiency( WEAPON_PROFICIENCY_AVERAGE )	
	NPC:Fire("StartPatrolling","",0)
end

function SpawnCombineSynth ( pos )
	NPC = ents.Create( "npc_combine_s" )
	NPC:SetKeyValue("NumGrenades", ""..math.random(1,3).."") 
	NPC:SetPos( pos )
	NPC:SetKeyValue( "ignoreunseenenemies", 0 )
	NPC:SetKeyValue( "spawnflags", 512 )
	NPC:SetKeyValue( "model", "models/elite_synth/elite_synth.mdl" )
	NPC:SetSkin(0)
	NPC.HuntID="CombineSynth"
	NPC:Spawn()
	NPC:Give("NPC_Minigun")
	combinen = combinen + 1
	NPC:SetName("Комбайн nº"..combinen.."")
	NPC:SetCurrentWeaponProficiency( WEAPON_PROFICIENCY_PERFECT )	
	NPC:Fire("StartPatrolling","",0)
	NPC:SetHealth(500)
end

function SpawnCombineShotgunner ( pos )
	NPC = ents.Create( "npc_combine_s" )
	NPC:SetKeyValue("NumGrenades", "0") 
	NPC:SetPos( pos )
	NPC:SetKeyValue( "ignoreunseenenemies", 0 )
	NPC:SetKeyValue( "spawnflags", 512 )
	NPC:SetSkin(1)
	NPC.HuntID="CombineShotgunner"
	NPC:Spawn()
	NPC:Give("ai_weapon_shotgun")
	if GetConVarNumber("h_combine_custom_weapons") == 1 then
		NPC:Give(""..table.Random(NPC_WEAPON_PACK_2_SHOTGUNS).."")
	else
		NPC:Give("ai_weapon_shotgun")
	end
	combinen = combinen + 1
	NPC:SetName("Комбайн nº"..combinen.."")
	NPC:SetCurrentWeaponProficiency( WEAPON_PROFICIENCY_GOOD )	
	NPC:Fire("StartPatrolling","",0)
end
function SpawnCombineShotgunnerElite ( pos )
	NPC = ents.Create( "npc_combine_s" )
	NPC:SetKeyValue("NumGrenades", ""..math.random(2,3).."")
	NPC:SetPos( pos )
	NPC:SetKeyValue( "ignoreunseenenemies", 0 )
	NPC:SetKeyValue( "spawnflags", 512 )
	NPC:SetSkin(1)
	NPC.HuntID="CombineShotgunnerElite"

	NPC:Spawn()
	if GetConVarNumber("h_combine_custom_weapons") == 1 then
		NPC:Give(""..table.Random(NPC_WEAPON_PACK_2_SHOTGUNS).."")
	else
		NPC:Give("ai_weapon_shotgun")
	end
	combinen = combinen + 1
	NPC:SetName("Комбайн nº"..combinen.."")
	NPC:SetCurrentWeaponProficiency( WEAPON_PROFICIENCY_PERFECT )	
	NPC:Fire("StartPatrolling","",0)
end

function SpawnMetropoliceStunstick( pos )
	NPC = ents.Create( "npc_metropolice" )
	NPC:SetKeyValue("Manhacks", math.random(0,1)) 
	NPC:SetKeyValue( "model", "models/Police.mdl" )
	NPC:SetPos( pos )
	NPC:SetKeyValue( "ignoreunseenenemies", 0 )
	NPC:SetKeyValue( "spawnflags", "512" )
	NPC:SetKeyValue("squadname", "")
	NPC.HuntID="MetropoliceStunstick"
	NPC:Spawn()
	NPC:Give("ai_weapon_stunstick")
	combinen = combinen + 1
	NPC:SetName("Combine nº"..combinen.."")
	NPC:SetCurrentWeaponProficiency( WEAPON_PROFICIENCY_GOOD )	
	NPC:Fire("StartPatrolling","",0)
	NPC:Fire("ActivateBaton","",0)
end

function SpawnMetropolice( pos )
	NPC = ents.Create( "npc_metropolice" )
	NPC:SetKeyValue("Manhacks", math.random(0,1)) 
	NPC:SetKeyValue( "model", "models/Police.mdl" )
	NPC:SetPos( pos )
	NPC:SetKeyValue( "ignoreunseenenemies", 0 )
	NPC:SetKeyValue( "spawnflags", 512 )
	NPC:SetKeyValue("squadname", "")
	NPC.HuntID="Metropolice"
	NPC:Spawn()
	if GetConVarNumber("h_combine_custom_weapons") == 1 then
		NPC:Give(""..table.Random(NPC_WEAPON_PACK_2_PISTOLS).."")
	else
		NPC:Give("ai_weapon_pistol")
	end
	combinen = combinen + 1
	NPC:SetName("Комбайн nº"..combinen.."")
	NPC:SetCurrentWeaponProficiency( WEAPON_PROFICIENCY_GOOD )	
	NPC:Fire("StartPatrolling","",0)
end

function SpawnMetropoliceHard( pos )
	NPC = ents.Create( "npc_metropolice" )
	NPC:SetKeyValue("Manhacks", math.random(1,2)) 
	NPC:SetKeyValue( "model", "models/Police.mdl" )
	NPC:SetPos( pos )
	NPC:SetKeyValue( "ignoreunseenenemies", 0 )
	NPC:SetKeyValue( "spawnflags", 512 )
	NPC.HuntID="MetropoliceHard"
	NPC:Spawn()
	if GetConVarNumber("h_combine_custom_weapons") == 1 then
		NPC:Give(""..table.Random(NPC_WEAPON_PACK_2_PISTOLS).."")
	else
		NPC:Give("ai_weapon_smg1")
	end
	combinen = combinen + 1
	NPC:SetName("Комбайн nº"..combinen.."")
	NPC:SetCurrentWeaponProficiency( WEAPON_PROFICIENCY_GOOD )	
	NPC:Fire("StartPatrolling","",0)
end

function SpawnRollermine( pos )
	NPC = ents.Create( "npc_rollermine" )
	NPC:SetPos(pos)
	NPC:Spawn()
	NPC:SetName("Rollermine")
	NPC:SetKeyValue( "spawnflags", "1024" )
end

function SpawnFriendlyRollermine( pos )
	NPC = ents.Create( "npc_rollermine" )
	NPC:SetPos( pos )
	NPC:Spawn()
	NPC:SetName("Rollermine")
	NPC:AddRelationship("player D_LI 99")
	NPC:AddRelationship("npc_combine_s D_HT 99")
	NPC:AddRelationship("npc_metropolice D_HT 99")
	for k,v in pairs(ents.FindByClass("npc_*")) do
	if !v:IsNPC() then return end
	if v:GetClass() != NPC:GetClass() then 
		NPC:AddEntityRelationship( v, D_HT, 99 ) 
		v:AddEntityRelationship( NPC, D_HT, 99 ) 
	end
	end
end
function SpawnEntranceInfoNode( pos )
	node = ents.Create("info_node_hint")
	node:SetPos(pos)
	node:SetKeyValue("hinttype", 103)
	node:SetKeyValue("nodeFOV", 360)
	node:SetKeyValue("IgnoreFacing", 1)
end
function SpawnCombineElite1( pos )
	NPC = ents.Create( "npc_combine_s" )
	NPC:SetKeyValue("NumGrenades", "0") 
	NPC:SetKeyValue( "model", "models/Combine_Super_Soldier.mdl" )
	NPC:SetPos( pos )
	NPC:SetKeyValue( "spawnflags", 768 )
	NPC.HuntID="CombineElite1"
	NPC:Spawn()
	NPC:Give( "ai_weapon_ar2" )
	if GetConVarNumber("h_combine_custom_weapons") == 1 then
		NPC:Give(""..table.Random(NPC_WEAPON_PACK_2_RAPID_FIRE).."")
	else
		NPC:Give("ai_weapon_ar2")
	end
	combinen = combinen + 1
	NPC:SetName("Комбайн nº"..combinen.."")
	NPC:SetCurrentWeaponProficiency( WEAPON_PROFICIENCY_GOOD )
	NPC:Fire("StartPatrolling","",0)
end
function SpawnCombineElite2( pos )
	NPC = ents.Create( "npc_combine_s" )
	NPC:SetKeyValue("NumGrenades", ""..math.random(0,1).."") 
	NPC:SetKeyValue( "model", "models/Combine_Super_Soldier.mdl" )
	NPC:SetKeyValue( "spawnflags", "256" )
	NPC:SetPos( pos )
	NPC:SetKeyValue( "spawnflags", 768 )
	NPC.HuntID="CombineElite2"
	NPC:Spawn()
	if GetConVarNumber("h_combine_custom_weapons") == 1 then
		NPC:Give(""..table.Random(NPC_WEAPON_PACK_2_RAPID_FIRE).."")
	else
		NPC:Give("ai_weapon_ar2")
	end
	combinen = combinen + 1
	NPC:SetName("Combine nº"..combinen.."")
	NPC:SetCurrentWeaponProficiency( WEAPON_PROFICIENCY_PERFECT )
	NPC:Fire("StartPatrolling","",0) 
end

function SpawnAssassin( pos )
	NPC = ents.Create( "npc_fassassin" )
	--NPC:SetKeyValue( "spawnflags", "256" )
	NPC:SetPos( pos )
	--NPC:SetKeyValue( "spawnflags", 512 )
	NPC.HuntID="Assassin"

	NPC:Spawn()
	--NPC:Give( "ai_weapon_ar2" )
	--combinen = combinen + 1
	NPC:SetName("Assassin")
	NPC:SetCurrentWeaponProficiency( WEAPON_PROFICIENCY_PERFECT )
	NPC:Fire("StartPatrolling","",0) 
end

function SpawnCremator( pos )
	NPC = ents.Create( "npc_cremator" )
	--NPC:SetKeyValue( "spawnflags", "256" )
	NPC:SetPos( pos )
	--NPC:SetKeyValue( "spawnflags", 512 )
	NPC.HuntID="Cremator"
	NPC:Spawn()
	--NPC:Give( "ai_weapon_ar2" )
	--combinen = combinen + 1
	NPC:SetName("Cremator")
	--NPC:SetCurrentWeaponProficiency( WEAPON_PROFICIENCY_PERFECT )
	NPC:Fire("StartPatrolling","",0) 
end

function SpawnAirboat( pos, ang )
	spawnairboat = ents.Create("prop_vehicle_airboat")
	spawnairboat:SetModel("models/airboat.mdl")
	spawnairboat:SetKeyValue("vehiclescript", "scripts/vehicles/airboat.txt")
	spawnairboat:SetPos( pos )
	spawnairboat:SetAngles( ang ) 
	spawnairboat:Spawn()
	spawnairboat:Activate()
end


function SpawnCeilingTurretStrong( pos, ang )
	NPC = ents.Create( "npc_turret_ceiling" )
	NPC:SetPos( pos )
	NPC:SetAngles( ang ) 
	NPC:SetKeyValue( "spawnflags", "32" )
	NPC:Spawn()
	NPC:SetHealth(2)
end

function SpawnSuitCharger( pos, ang )
	NPC = ents.Create( "item_suitcharger" )
	NPC:SetPos( pos )
	NPC:SetAngles( ang ) 
	NPC:SetKeyValue( "spawnflags", 8192 )
	NPC:Spawn()
end

function SpawnDynamicAmmoCrate( pos, ang )
	NPC = ents.Create( "item_item_crate" )
	NPC:SetPos( pos )
	NPC:SetKeyValue( "ItemClass", ""..table.Random(GOODCRATEITEMS).."" )
	NPC:SetKeyValue( "ItemCount", math.random(1,2) ) 
	NPC:SetAngles( ang ) 
	NPC:Spawn()
end


function SpawnTurret( pos, ang )
	NPC = ents.Create( "npc_turret_floor" )
	NPC:SetPos( pos )
	NPC:SetAngles( ang ) 
	NPC:Spawn()
	NPC:SetName("Turret")
end

function SpawnFriendlyTurret( pos, ang )
	NPC = ents.Create( "npc_turret_floor" )
	NPC:SetPos( pos )
	NPC:SetAngles( ang ) 
	NPC:SetKeyValue("spawnflags", 512)
	NPC:Spawn()
	NPC:SetName("Turret")
end


function SpawnMine( pos )
	NPC = ents.Create( "combine_mine" )
	NPC:SetPos( pos )
	NPC:Spawn()
	NPC:SetName("Mine")
end

function SpawnFragCrate( pos, ang )
	NPC = ents.Create( "item_ammo_crate" )
	NPC:SetPos( pos )
	NPC:SetName("RPGAMMO")
	NPC:SetAngles( ang ) 
	NPC:SetKeyValue("AmmoType", 5)
	NPC:Spawn()
end

function SpawnTriplaser( pos, ang )
	NPC = ents.Create( "combine_tripmine" )
	NPC:SetPos( pos )
	NPC:SetName("Triplaser")
	NPC:SetAngles( ang ) 
	NPC:Spawn()
end

function SpawnAmmoCrate( pos, ang, ammotype )
	NPC = ents.Create( "item_ammo_crate" )
	NPC:SetPos( pos )
	NPC:SetName("RPGAMMO")
	NPC:SetAngles( ang ) 
	NPC:SetKeyValue("AmmoType", ammotype)
	NPC:Spawn()
end

function SpawnMineDisarmed( pos )
	NPC = ents.Create( "combine_mine" )
	NPC:SetPos( pos )
	NPC:SetKeyValue("StartDisarmed", 1)
	NPC:Spawn()
	NPC:SetName("Mine")
end

function SpawnItem (weapon, pos, ang)
	ITEM = ents.Create(weapon)
	ITEM:SetPos( pos )
	ITEM:SetAngles( ang )
	ITEM:Spawn()
end

function SpawnStaticProp( pos, ang, model )
	ITEM = ents.Create("prop_physics" )
	ITEM:SetPos( pos )
	ITEM:SetAngles(ang)
	ITEM:SetModel(model)
	ITEM:Spawn()
	ITEM:Fire("DisableMotion","",0)
end

function SpawnProp( pos, ang, model )
	ITEM = ents.Create("prop_physics" )
	ITEM:SetPos( pos )
	ITEM:SetAngles(ang)
	ITEM:SetModel(model)
	ITEM:Spawn()
end

function coverzones()
	timer.Create( "coverzones", 20, 1, coverzones ) 	
	table.foreach(MainEnemiesGround, function(key,value)
		for k, v in pairs(ents.FindByClass(value)) do
			if !v:IsCurrentSchedule(SCHED_FORCED_GO) && !v:IsCurrentSchedule(SCHED_FORCED_GO_RUN) then	
				if !v:GetEnemy() then 
					v:SetLastPosition(table.Random(zonescovered) + Vector(math.random(-20,20), math.random(-20,20), 10))
					if WAVESPAWN == 1 then
						v:SetSchedule(SCHED_FORCED_GO_RUN)
					else
						v:SetSchedule(SCHED_FORCED_GO)
					end
				end
			end
		end
	end)
end

function GM:ShouldCollide(ent1,ent2)
	if ent1:IsPlayer() then
		if ent2:GetClass() == "npc_combine_s" then
		if ent1:GetPos():Distance(ent2:GetPos()) < 50 then
		ent1:SetNoTarget(false)
		ent1:SendLua(	"light_above_limit=1" )		
		return true
		end
		end
	end
	
	if ent1:GetClass() == "npc_combine_s" then
	if ent2:GetClass():IsPlayer() then
	if ent1:GetPos():Distance(ent2:GetPos()) < 50 then
	ent2:SetNoTarget(false)
	ent2:SendLua(	"light_above_limit=1" )		
	return true
	end
	end
	end

if ent1:GetClass() == "npc_citizen" and ent2:GetClass() == "item_healthcharger" and ent1:GetPos():Distance(ent2:GetPos()) < 100 then
ent1:SetHealth(100) 
end

if ent1:GetClass() == "item_healthcharger" and ent2:GetClass() == "npc_citizen" and ent1:GetPos():Distance(ent2:GetPos()) < 100 then
ent2:SetHealth(100) 
end
	
	if ent1:GetClass()== "npc_helicopter" then
		if ent2:GetClass() =="npc_helicopter" or ent2:GetClass() =="npc_combinegunship" then
			return false
		end
	end
	if ent2:GetClass()== "npc_helicopter" then
		if ent1:GetClass() =="npc_helicopter" or ent1:GetClass() =="npc_combinegunship" then
			return false
		end
	end
	return true
end

function metropolicewander()
timer.Create( "metropolicewander", 9, 1, metropolicewander ) 

	
		for k, v in pairs(ents.GetAll()) do
			if table.HasValue(zombietable, v:GetClass()) and !v:GetEnemy() then
			print(""..v:GetClass().." wanders")
			--v:SetLastPosition(table.Random(zonescovered))
			v:SetSchedule(SCHED_IDLE_WANDER)
			end	
		end

	for k, v in pairs(ents.FindByClass("npc_metropolice")) do
		if !v:GetEnemy() then
			if !v:IsCurrentSchedule(SCHED_FORCED_GO) && !v:IsCurrentSchedule(SCHED_FORCED_GO_RUN) then
				v:SetSchedule(SCHED_IDLE_WANDER)
				print(""..v:GetName().." выбрал новую маршрутную карту.")
			end
		end
	end

for k, v in pairs(ents.FindByClass("npc_rollermine")) do
	if !v:GetEnemy() then
		if v:GetPhysicsObject():GetVelocity():Length() < 20 then
		print(""..v:GetName().." выбрал новую маршрутную карту.")		
			if math.random(1,3)==2 then
					v:SetSchedule(SCHED_IDLE_WANDER)
			else
					v:SetSchedule(SCHED_RUN_RANDOM)
			end
		end
	end
end

end

function CombineIdleSpeech()
	local NPCsFound = 0
	for _, player in pairs(ents.FindByClass("player")) do
		for k, npc in pairs(ents.FindInSphere(player:GetPos(),900)) do
			if npc:GetClass() == "npc_metropolice" || npc:GetClass() == "npc_combine_s" then
				NPCsFound= NPCsFound+1
				if NPCsFound < 2 && npc:Health() > 0 then
					if npc:GetEnemy() then
						npc:EmitSound(table.Random(CombineCombatSounds), 70,100) else npc:EmitSound(table.Random(CombineIdleSounds), 70,100)
					end
				end
			end
		end
	end
end

function npcforget()
	print("[The Hunt]: применен аргумент npcforget")
	CombineAssisting=0
	table.foreach(MainEnemiesGround, function(key,enemy)
		for k, v in pairs(ents.FindByClass(enemy)) do 
			v:SetKeyValue("squadname", "")
			v:ClearEnemyMemory()
			--v:SetSchedule(SCHED_MOVE_AWAY)
		end
	end)
	table.foreach(player.GetAll(), function(key,value)
		net.Start( "Hidden" )
		net.Send(value)
		value.spotted = 0
	end)
	if LastEnemyWasPlayer== 1 and GetConVarNumber("h_combine_chat") == 1 then
		LastEnemyWasPlayer=0
		for k, v in pairs(ents.FindByClass("npc_combine_s")) do 
			PrintMessage(HUD_PRINTTALK, ""..v:GetName()..": "..table.Random(ChatEnemyLost).."")
			break
		end
	end
end


function ClearCombineSpawnPoints()
table.foreach(combinespawnzones, function(key,zone)

		for k, v in pairs(ents.FindInSphere(zone,50)) do 
		if v:IsNPC() then print(""..v:GetName().." застрял на спавне, возрождаясь.") v:Remove()
		SpawnCombineS1(zone)
		end
		end
end)
end


function CicloUnSegundo()
	table.foreach(MainEnemiesCoop, function(key,enemy)
		for k, npc in pairs(ents.FindByClass(enemy)) do
			if npc:Health() > 0 then
				if npc:GetEnemy() then
					if npc:IsCurrentSchedule(SCHED_FORCED_GO) or npc:IsCurrentSchedule(SCHED_IDLE_WANDER) or npc:IsCurrentSchedule(SCHED_FORCED_GO_RUN)	then
						npc:ClearSchedule()
					end		
						if table.HasValue(MainEnemiesCoop, npc:GetClass()) then
							if npc:HasCondition(10) then
								npc:SetKeyValue("squadname", ""..npc:GetEnemy():GetClass().."")
								if timer.Exists("npcforgettimer") then
									timer.Destroy( "npcforgettimer")
								end
									if npc:GetEnemy().spotted != 1 then
									if npc:GetEnemy():IsPlayer() or npc:GetEnemy():GetClass() == "npc_citizen" then LastEnemyWasPlayer=1
											npc:EmitSound(table.Random(ContactConfirmed), 70, 100)
											if GetConVarNumber("h_combine_chat") == 1 then
											PrintMessage(HUD_PRINTTALK, ""..npc:GetName()..": "..table.Random(ChatEnemySpotted).."") end
											ClearPatrolzones()			
											table.insert(zonescovered, npc:GetEnemy():GetPos()+Vector(0,0,30)) print("Patrol zone added (Player spotted)")
											net.Start("Spotted")
											net.Send(npc:GetEnemy())
											npc:GetEnemy().spotted = 1
										end
									end
								for num, ThisEnt in pairs(ents.FindInSphere(npc:GetPos(),500)) do 						
									if table.HasValue(MainEnemiesCoop, ThisEnt:GetClass()) and !ThisEnt:IsCurrentSchedule(SCHED_FORCED_GO_RUN) then
										if ThisEnt:GetEnemy() == nil  then 
											ThisEnt:SetLastPosition(npc:GetEnemy():GetPos())
											ThisEnt:SetSchedule(SCHED_FORCED_GO_RUN)
										end
									end
								end
								
								for num, ThisEnt in pairs(ents.FindInSphere(npc:GetPos(),9000)) do 
									if table.HasValue(MainEnemiesCoop, ThisEnt:GetClass()) and !ThisEnt:IsCurrentSchedule(SCHED_FORCED_GO_RUN) then
											if ThisEnt:GetEnemy() == nil  then 
												if CombineAssisting < GetConVarNumber("h_maxhelp") then
												--print(ThisEnt:GetName().." is helping "..npc:GetName().."")
												ThisEnt:SetLastPosition(npc:GetEnemy():GetPos())
												ThisEnt:SetSchedule(SCHED_FORCED_GO_RUN)
												CombineAssisting = CombineAssisting+1
												--print("[The Hunt]: Combines helping: "..CombineAssisting.." of "..GetConVarNumber("h_maxhelp").."")
												end
											end
									end
								end
							else
								if !timer.Exists("npcforgettimer") then
									timer.Create( "npcforgettimer", GetConVarNumber("h_lostplayertimeout"), 1, npcforget ) 
								end
							end		
						end
				end
			end
		end
	end)
	timer.Create( "CicloUnSegundo", 1, 1, CicloUnSegundo ) 
end

function helibehavior()
	for num, Heli in pairs(ents.FindByClass("npc_helicopter")) do
		if Heli:GetEnemy() then
			--print ("heli has enemy: "..HeliA:GetEnemy():GetName().."")
			if Heli:GetEnemy():IsNPC() && Heli.light then
				Heli.light:Fire("Target", ""..Heli:GetEnemy():GetName().."", 0)
			end
			if Heli:GetEnemy():IsPlayer() && Heli.light  then
				Heli:GetEnemy():SetName(""..tostring(Heli:GetEnemy():GetName()).."focus")
				Heli.light:Fire("Target", ""..tostring(Heli:GetEnemy():GetName()).."focus", 0)
			end
			if Heli:HasCondition(10) then
				nearbycombinecomeheli(Heli,Heli:GetEnemy())
			end
		elseif Heli.light then
			Heli.light:Fire("Target", "", 0)
		end
	end
end

function ClearPatrolzones()
	if table.Count(zonescovered) > ORIGINAL_ZONES_NUMBER+10 then
	table.remove(zonescovered)
	table.remove(zonescovered)
	table.remove(zonescovered)
	table.remove(zonescovered)
	table.remove(zonescovered)
	table.remove(zonescovered)
	table.remove(zonescovered)
	table.remove(zonescovered)
	table.remove(zonescovered)
	table.remove(zonescovered)
	print("Зоны патрулирования возобновлены.")
	end		
end

-- Heli path guidance.
function helipath()
	helibehavior()
	timer.Simple( 5, helipath )
	--print("Helipath")
	local found = 0
	table.foreach(AirEnemies, function(key,enemy)
		for num, Heli in pairs(ents.FindByClass(enemy)) do
			if Heli:GetVelocity():Length() < 240 then
			--print("")
			--print("Heli "..Heli:EntIndex().." searching")
				if Heli:GetEnemy() then
					nearbycombinecome(Heli:GetEnemy())
					for num, HeliTrack in pairs(ents.FindInSphere(Heli:GetEnemy():GetPos(), 2000)) do
						if found == 0 or  found == 1 then
							if HeliTrack:GetClass() == "path_track" then
						--print("Found one,"..HeliTrack:EntIndex().."")
									if HeliTrack:GetName() == "used" then 
									found = 1 
									--print("Is NOT Empty")
									end
								if HeliTrack:GetName() != "used" then
									--print("Is Empty")
									if Heli:Visible(HeliTrack) and HeliTrack:Visible(Heli:GetEnemy()) then
										--print("Going to "..HeliTrack:EntIndex().."")
										HeliTrack:SetName("going")
										Heli:Fire("SetTrack", tostring(HeliTrack:GetName()))
										timer.Simple (0.5, function() HeliTrack:SetName("used") end)
										found = 2
									end
								end
							end 
						end
					end
				else
					for num, HeliTrack in pairs(ents.FindInSphere(Heli:GetPos(), 2000)) do
						if found == 0 or  found == 1 then
							if HeliTrack:GetClass() == "path_track" then
								--print("Found one,"..HeliTrack:EntIndex().."")
								if HeliTrack:GetName() == "used" then  found = 1
									--print("Is NOT Empty")
								end
								if HeliTrack:GetName() != "used" then
									--print("Is Empty")
									if Heli:Visible(HeliTrack) then
										--print("Going to "..HeliTrack:EntIndex().."")
										HeliTrack:SetName("going")
										Heli:Fire("SetTrack",tostring(HeliTrack:GetName()))
										timer.Simple (0.5, function() HeliTrack:SetName("used") end)
										found = 2
									end
								end
							end 
						end
					end
				end
				--print("Heli "..Heli:EntIndex().." status: "..found.."")
				if found == 0 or found == 1 then
					usedpaths()
				end
			end
		end
	end)
end

function usedpaths()
	if HeliA then
		for num, HeliTrack in pairs(ents.FindByClass("path_track")) do
			if HeliTrack:GetName() == "used" then
				HeliTrack:SetName("empty")
			end
		end
	end
end

function GM:InitPostEntity()
	print("------ [Загрузка GM:СпавнПозиции] ------")
	team.SetUp( 1, "Rebels", Color( 0, 255, 0 ) )
	if !CRATEITEMS then
		print("[The Hunt]: Не найдена пользовательсая маршрутная карта.")
		CRATEITEMS = { "weapon_bp_shotgun", "weapon_bp_annabelle", "weapon_bp_smg2", "weapon_bp_smg3", "weapon_bp_alyxgun","item_healthvial", "item_healthkit" } 
	else 
		print("[The Hunt]: Нет координатов для припасов")
	end
	
	if !GOODCRATEITEMS then
		print("[The Hunt]: Не найдена пользовательская маршрутная карта.")
		GOODCRATEITEMS = { "weapon_frag", "weapon_slam","item_healthkit", "weapon_bp_smg3","weapon_bp_smg2","weapon_bp_annabelle"} 
	else
		print("[The Hunt]: Нет координатов для припасов")
	end
	
	INFINITE_ACHIEVED = 0
	
	if !CUSTOMWAVESPAWN then 
		print("[The Hunt]: Конфигурация спавнов запущена!")
		CUSTOMWAVESPAWN=30
	else
		print("[The Hunt]: Заспавнено "..CUSTOMWAVESPAWN.." обьектов.")
	end
	
	if GetConVarString("h_autostart") == "1" then
		if win == 1 then
			timer.Simple(GetConVarNumber("h_time_between_waves"), autofirstwave)
		end
	end
	
	Wave=0
	timer.Create( "Item Respawn System", 10, 1, ItemRespawnSystem )
	timer.Create( "CombineIdleSpeech", math.random(5,15), 0, CombineIdleSpeech ) 
	timer.Create( "CicloUnSegundo", 1, 1, CicloUnSegundo ) 
	timer.Create( "coverzones", 20, 0, coverzones )
	timer.Create( "wavefinishedchecker", 5, 1, wavefinishedchecker)
	timer.Create( "metropolicewander", 8, 1, metropolicewander ) 

	CanCheck = 0
	print("[The Hunt]: Вызов функции настройки карты.")
	MapSetup()
	print("[The Hunt]: Завершенная функция настройки карты.")
	
	if HELIPATHS then
		table.foreach(HELIPATHS, function(key,value)
		CreateHeliPath(value)
		end)
	end
	
	timer.Simple(1, function() 
		if MAP_PROPS then
			print("[The Hunt]: Запуск спавна в точках координатов.")
			table.foreach(MAP_PROPS, function(key,propclass)
				for k, v in pairs(ents.GetAll()) do
					if v:GetModel() == propclass then
						table.insert(ITEMPLACES, v:GetPos()+Vector(0,0,v:BoundingRadius()-20))
						v:SetKeyValue("minhealthdmg", "9001")
						v:Fire("DisableMotion","",0)
						print("[The Hunt]: "..v:GetModel().." теперь это точка возрождения оружия.")
					end
				end
			end)
		else 
			print("[The Hunt]: добавлены динамические точки возрождения оружия.")
		end
	ORIGINAL_ZONES_NUMBER = table.Count(zonescovered)
	
	if GetConVarString("h_vanilla_weapons") == "1" then
		print("[The Hunt]: Добавлено стандартное оружие (в стандартных координатах)")
		table.foreach(VANILLA_WEAPONS, function(key,weapon)
			table.insert(MEDIUMWEAPONS,weapon)
		end)
	end
		
	for k, v in pairs(ents.GetAll()) do
		if v:GetClass() == path_track then
			table.insert(HELIPATHS, v:GetPos())
			print("[The Hunt]: Не обнаружены координаты спавна штурмовика.")
		end
	end
	
	if GetConVarString("h_STALKER_sweps") == "1" then
	if IsThatWeaponInstalled("stalker_ak74_u") == true then
	
		table.insert(MEDIUMWEAPONS, ""..table.Random(STALKER_SWEPS).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(STALKER_SWEPS).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(STALKER_SWEPS).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(STALKER_SWEPS).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(STALKER_SWEPS).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(STALKER_SWEPS).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(STALKER_SWEPS).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(STALKER_SWEPS).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(STALKER_SWEPS).."")
		while table.Count(MEDIUMWEAPONS) > 8 do table.remove(MEDIUMWEAPONS, math.random(1,table.Count(MEDIUMWEAPONS))) end
		print("[The Hunt]: Зачистки СТАЛКЕРА добавлены успешно.")
		else
		print("[The Hunt]: СТАЛКЕР НЕ установлен! Игра не добавит их.")
		end
	end
	
	if GetConVarString("h_MR_PYROUS_sweps") == "1" then
	if IsThatWeaponInstalled("pspak_benli_m4") == true then
		
		
		table.insert(MEDIUMWEAPONS, ""..table.Random(MR_PYROUS_SWEPS).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(MR_PYROUS_SWEPS).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(MR_PYROUS_SWEPS).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(MR_PYROUS_SWEPS).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(MR_PYROUS_SWEPS).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(MR_PYROUS_SWEPS).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(MR_PYROUS_SWEPS).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(MR_PYROUS_SWEPS).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(MR_PYROUS_SWEPS).."")
		while table.Count(MEDIUMWEAPONS) > 8 do table.remove(MEDIUMWEAPONS, math.random(1,table.Count(MEDIUMWEAPONS))) end
		print("[The Hunt]: успешно добавлено тактическое оружие.")
		else
		print("[The Hunt]: тактическое оружие НЕ установлено!")
		end
	end
	
	if GetConVarString("h_MAD_COWS_sweps") == "1" then
		if IsThatWeaponInstalled("weapon_mad_alyxgun") == true then

		table.insert(MEDIUMWEAPONS, ""..table.Random(MAD_COWS_SWEPS).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(MAD_COWS_SWEPS).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(MAD_COWS_SWEPS).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(MAD_COWS_SWEPS).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(MAD_COWS_SWEPS).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(MAD_COWS_SWEPS).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(MAD_COWS_SWEPS).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(MAD_COWS_SWEPS).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(MAD_COWS_SWEPS).."")
		while table.Count(MEDIUMWEAPONS) > 8 do table.remove(MEDIUMWEAPONS, math.random(1,table.Count(MEDIUMWEAPONS))) end
		print("[The Hunt]: Успешно добавлены подсечки.")
				else
		print("[The Hunt]: Подметальные машины. НЕ установлены! Игра не добавит их.")
		end
	end
		
	if GetConVarString("h_M9K_SPECIALITIES_sweps") == "1" then
			if IsThatWeaponInstalled("m9k_nerve_gas") == true then

		table.insert(MEDIUMWEAPONS, ""..table.Random(M9K_SPECIALITIES).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(M9K_SPECIALITIES).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(M9K_SPECIALITIES).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(M9K_SPECIALITIES).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(M9K_SPECIALITIES).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(M9K_SPECIALITIES).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(M9K_SPECIALITIES).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(M9K_SPECIALITIES).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(M9K_SPECIALITIES).."")	
		while table.Count(MEDIUMWEAPONS) > 8 do table.remove(MEDIUMWEAPONS, math.random(1,table.Count(MEDIUMWEAPONS))) end
		print("[The Hunt]: M9K Новые улучшения добавлены успешно.")
		else
		print("[The Hunt]: M9K Specialities Sweps НЕ установлены! Игра не добавит их.")
		end
	end
	
	if GetConVarString("h_FAS_sweps") == "1" then
		if IsThatWeaponInstalled("fas2_ak47") == true then

		table.insert(MEDIUMWEAPONS, ""..table.Random(FAS).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(FAS).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(FAS).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(FAS).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(FAS).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(FAS).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(FAS).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(FAS).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(FAS).."")
		while table.Count(MEDIUMWEAPONS) > 8 do table.remove(MEDIUMWEAPONS, math.random(1,table.Count(MEDIUMWEAPONS))) end
		table.insert(MEDIUMWEAPONS, "fas2_att_suppressor")
		print("[The Hunt]: FA:S оружие добавлено успешно.")
		else
		print("[The Hunt]: FA:S оружие НЕ установлено! Игра не добавит их.")
		end
	end
	
	if GetConVarString("h_M9K_ASSAULT_RIFLES_sweps") == "1" then
			if IsThatWeaponInstalled("m9k_winchester73") == true then

		table.insert(MEDIUMWEAPONS, ""..table.Random(M9K_ASSAULT_RIFLES).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(M9K_ASSAULT_RIFLES).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(M9K_ASSAULT_RIFLES).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(M9K_ASSAULT_RIFLES).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(M9K_ASSAULT_RIFLES).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(M9K_ASSAULT_RIFLES).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(M9K_ASSAULT_RIFLES).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(M9K_ASSAULT_RIFLES).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(M9K_ASSAULT_RIFLES).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(M9K_ASSAULT_RIFLES).."")
		while table.Count(MEDIUMWEAPONS) > 8 do table.remove(MEDIUMWEAPONS, math.random(1,table.Count(MEDIUMWEAPONS))) end
		print("[The Hunt]: M9K Assault Rifles добавлено успешно.")
			else
		print("[The Hunt]: M9K Assault Rifles НЕ установлены! Игра не добавит их.")
		end
	end	
	
	if GetConVarString("h_CUSTOMIZABLE_WEAPONRY_2_0_sweps") == "1" then
				if IsThatWeaponInstalled("cw_ak74") == true then

		table.foreach(Customizable_Weaponry, function(key,weapon)
			table.insert(MEDIUMWEAPONS,weapon)
		end)
		table.insert(MEDIUMWEAPONS, "cw_ammo_crate_small")
		table.insert(MEDIUMWEAPONS, "cw_ammo_40mm")

		print("[The Hunt]: CW 2.0 оружие добавлено успешно.")
		else
		print("[The Hunt]: CW 2.0 оружие НЕ установлено! Игра не добавит их.")
		end
	end
	
	if GetConVarString("h_EXTRA_CUSTOMIZABLE_WEAPONRY_2_0_sweps") == "1" then
					if IsThatWeaponInstalled("cw_scarh") == true then

		table.foreach(Extra_Customizable_Weaponry, function(key,weapon)
			table.insert(MEDIUMWEAPONS,weapon)
		end)
		if not table.HasValue( MEDIUMWEAPONS, "cw_ammo_crate_small" ) then
			table.insert(MEDIUMWEAPONS, "cw_ammo_crate_small")
			table.insert(MEDIUMWEAPONS, "cw_ammo_40mm")

		end
			print("[The Hunt]: Extra CW 2.0 оружие добавлено успешно.")
					else
			print("[The Hunt]: Extra CW 2.0 оружие НЕ установлено! Игра не добавит их.")
		end
	end
	
	if GetConVarString("h_UNOFICIAL_EXTRA_CUSTOMIZABLE_WEAPONRY_2_0_sweps") == "1" then
					if IsThatWeaponInstalled("cw_g4p_usp40") == true then

		table.foreach(Unoficial_Extra_Customizable_Weaponry, function(key,weapon)
			table.insert(MEDIUMWEAPONS,weapon)
		end)
		if not table.HasValue( MEDIUMWEAPONS, "cw_ammo_crate_small" ) then
			table.insert(MEDIUMWEAPONS, "cw_ammo_crate_small")
			table.insert(MEDIUMWEAPONS, "cw_ammo_40mm")

		end
			print("[The Hunt]: Unoficial Extra CW 2.0 оружие добавлено успешно.")
			else
			print("[The Hunt]: Unoficial Extra CW 2.0 оружие НЕ установлено! Игра не добавит их.")
		end
	end
	
	if GetConVarString("h_Murder_friendly_Assault_sweps") == "1" then
						if IsThatWeaponInstalled("ak47") == true then

		table.foreach(Murder_friendly_Assault, function(key,weapon)
			table.insert(MEDIUMWEAPONS,weapon)
		end)
		print("[The Hunt]: Murder friendly Assault оружие добавлено успешно.")
					else
			print("[The Hunt]: Murder friendly Assault оружие НЕ установлено! Игра не добавит их.")
		end
	end

	if GetConVarString("Murder_friendly_Handguns") == "1" then
		if IsThatWeaponInstalled("359") == true then

		table.foreach(Murder_friendly_Handguns, function(key,weapon)
			table.insert(MEDIUMWEAPONS,weapon)
		end)
		print("[The Hunt]: Murder friendly Handguns оружие добавлено успешно.")
		else
		print("[The Hunt]: Murder friendly Handguns оружие НЕ установлено! Игра не добавит их.")
		end
	end	
	
	if GetConVarString("h_MHs_Super_Battle_Pack_PART_II_sweps") == "1" then
			if IsThatWeaponInstalled("acid_sprayer_minds") == true then

		table.insert(MEDIUMWEAPONS, ""..table.Random(MHs_Super_Battle_Pack_PART_II).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(MHs_Super_Battle_Pack_PART_II).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(MHs_Super_Battle_Pack_PART_II).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(MHs_Super_Battle_Pack_PART_II).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(MHs_Super_Battle_Pack_PART_II).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(MHs_Super_Battle_Pack_PART_II).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(MHs_Super_Battle_Pack_PART_II).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(MHs_Super_Battle_Pack_PART_II).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(MHs_Super_Battle_Pack_PART_II).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(MHs_Super_Battle_Pack_PART_II).."")
		while table.Count(MEDIUMWEAPONS) > 8 do table.remove(MEDIUMWEAPONS, math.random(1,table.Count(MEDIUMWEAPONS))) end
		print("[The Hunt]:  MH Supper Battle Pack добавлено успешно.")
				else
		print("[The Hunt]: MH Supper Battle Pack оружие НЕ установлено! Игра не добавит их.")
		end
	end
	
	if GetConVarString("h_spastiks_toybox_sweps") == "1" then
				if IsThatWeaponInstalled("gabriel") == true then
		table.insert(MEDIUMWEAPONS, ""..table.Random(spastiks_toybox).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(spastiks_toybox).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(spastiks_toybox).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(spastiks_toybox).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(spastiks_toybox).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(spastiks_toybox).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(spastiks_toybox).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(spastiks_toybox).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(spastiks_toybox).."")
		table.insert(MEDIUMWEAPONS, ""..table.Random(spastiks_toybox).."")
		while table.Count(MEDIUMWEAPONS) > 8 do table.remove(MEDIUMWEAPONS, math.random(1,table.Count(MEDIUMWEAPONS))) end
		print("[The Hunt]:  Spastik's Toybox SWEPS добавлено успешно.")
						else
		print("[The Hunt]: Spastik's Toybox SWEPS НЕ установлены! Игра не добавит их.")
		end
	end
	
	if GetConVarString("h_HL2Beta_Weapons") == "1" then
		if IsThatWeaponInstalled("weapon_bp_alyxgun") == true then
		table.foreach(HL2Beta_Weapons, function(key,weapon)
			table.insert(MEDIUMWEAPONS,weapon)
		end)
		print("[The Hunt]: HL2Beta Weapons добавлено успешно.")
		else
		print("[The Hunt]: HL2Beta Weapons НЕ установлены! Игра не добавит их.")
		end
	end		
	
	if GetConVarString("h_default_loadout") == "" then else
			print("[The Hunt]: Начало загрузки "..GetConVarString("h_default_loadout").." для игроков на старте.")
			local sentence = ""..GetConVarString("h_default_loadout")..""
			local words = string.Explode( ",", sentence )
		table.foreach(words, function(key,value)
			table.insert(STARTING_LOADOUT, value)
		end)
	end

	if GetConVarString("h_personalized_sweps") == "" then else
		print("[The Hunt]: Начало загрузки "..GetConVarString("h_personalized_sweps").." в качестве дополнения.")
		local sentence = ""..GetConVarString("h_personalized_sweps")..""
		local words = string.Explode( ",", sentence )
		table.foreach(words, function(key,value)
			table.insert(MEDIUMWEAPONS, value)
		end)
	end
	
	if GetConVarString("h_silent_kill_rewards") == "" then else
		print("[The Hunt]: Загружен "..GetConVarString("h_silent_kill_rewards").." в качестве основного NPC.")
		local sentence = ""..GetConVarString("h_silent_kill_rewards")..""
		local words = string.Explode( ",", sentence )
		table.foreach(words, function(key,value)
			table.insert(SILENTKILLREWARD, value)
		end)
	end
	end)
	print(" ------ [Загрузка GM:InitPostEntity завершена] ------ ")

end

function GM:PlayerSpawn(ply)
	ply:SetTeam(1)
    ply:SetCustomCollisionCheck(true)
	ply:StripAmmo()
	ply:StripWeapons()
	ply:Give("weapon_hl2pipe")
	if GetConVarString("h_default_loadout") == "" then 	
	else
		table.foreach(STARTING_LOADOUT, function(key,value)
			ply:Give(""..value.."")
		end)
	end
	ply:SetupHands()
	ply:SetWalkSpeed(150)
	ply:SetRunSpeed(250)
	ply:SetCrouchedWalkSpeed(0.3)
	ply:AllowFlashlight(true)
	ply:SetNoCollideWithTeammates(1)
	
	if math.random(1,2) == 1 then
		ply:SetModel(table.Random(playermodelsmale) )
		ply.sex="male"
		print(""..ply:GetName().." заспавнен как повстанец.")
	else
		ply:SetModel(table.Random(playermodelsfemale) )
		ply.sex="female"
		print(""..ply:GetName().." заспавнен как повстанка.")
	end
end

function GM:OnNPCKilled(victim, killer, weapon)
	local victimpos = victim:GetPos()
	-- Uncomment to for-the-lulz explosion kills
	/*
	ent = ents.Create( "env_explosion" )
	ent:SetPos(victim:GetPos())
	ent:Spawn()
	ent:SetKeyValue( "iMagnitude", "100" )
	print("[The Hunt]: assploded")
	ent:Fire("Explode",0,0)
	*/

	
	if victim:GetClass() == "npc_turret_floor" then
		nearbycombinecome(victim)
		table.insert(zonescovered, victim:GetPos()+Vector(0,0,30)) print("Добавлены координаты зоны патрулирования.")
	end
	if victim:GetClass() == "npc_turret_ceiling" then
		nearbycombinecome(killer)
	end
	
	if killer:IsNPC() then
		if killer:GetClass() == "npc_citizen" then
			nearbycombinecome(killer)
		end
		if killer:Health() > 0 then
			if killer:GetClass() == "npc_combine_s" then
				killer:EmitSound(table.Random(CombineKillSounds), 100, 100)
			end
		end
		if table.HasValue( MainEnemiesCoop, killer:GetClass()) and table.HasValue( MainEnemiesCoop, victim:GetClass()) then 
			PrintMessage(HUD_PRINTTALK, ""..killer:GetName()..": "..table.Random(CombineKillCombine).."")
		end
		end
	
	if victim:GetClass() == "npc_metropolice" or victim:GetClass() == "npc_combine_s" or victim:GetClass() == "npc_citizen" then
		table.insert(zonescovered, victim:GetPos()+Vector(0,0,10)) print("Добавлена координаты зон патрулирования.")
		CombineAssisting =0
		COMBINE_KILLED = COMBINE_KILLED+1
		if killer:IsPlayer() or killer:IsNPC() then
			net.Start( "PlayerKillNotice" )
			net.WriteString( ""..killer:GetName().."" )
			if weapon:IsPlayer() then
				net.WriteString( ""..weapon:GetActiveWeapon():GetClass().."" )
			else
				net.WriteString( ""..weapon:GetClass().."" )
			end
			net.WriteString( ""..victim:GetName().."" )
			net.Broadcast()
		if killer:IsPlayer() then			
				if !victim:GetEnemy() then
					killer.SilentKills=killer.SilentKills+1 team_silent_kills=team_silent_kills+1
					for k, v in pairs(ents.FindInSphere(victim:GetPos(),512)) do
						if v:GetClass() == "npc_metropolice" or v:GetClass() == "npc_combine_s" then
							if v:Visible(victim) then
								v:SetLastPosition(killer:GetPos())
								v:SetSchedule(SCHED_FORCED_GO_RUN)
							else
								v:SetLastPosition(victim:GetPos())
								v:SetSchedule(SCHED_FORCED_GO_RUN)
							end
						end
					end
					if math.random(1,2) == 1 then 
						SpawnDynamicResuply(victim:GetPos())
					elseif cansilentkillreward != 0 then
						cansilentkillreward = 0
						timer.Simple(10, function() cansilentkillreward = 1 end)
						SpawnItem(table.Random(SILENTKILLREWARD), victim:GetPos(), Angle(0,0,0))
					end
			else
				if killer.sex == "male" then killer:EmitSound(table.Random(malecomments), 50, 100) else
					killer:EmitSound(table.Random(femalecomments), 50, 100)
				end
				allthecombinecome(victim,5)
				killer.Kills=killer.Kills+1
				team_kills=team_kills+1
			end
			killer:AddFrags(1)
			-- combine disguise
			if math.random(1,10) == 1 then
			if	killer.disguised == 0 and killer:GetPos():Distance(victim:GetPos()) < 120 then 
			if victim:GetModel() == "models/combine_soldier.mdl" then timer.Create( "PlayerDisguises", 2.2, 1, function() CombineDisguise(killer,"models/player/combine_soldier.mdl") end) end
			if victim:GetModel() == "models/combine_super_soldier.mdl" then timer.Create( "PlayerDisguises", 2.2, 1, function() CombineDisguise(killer,"models/player/combine_super_soldier.mdl") end) end
			if victim:GetModel() == "models/police.mdl" then timer.Create( "PlayerDisguises", 2.2, 1, function() CombineDisguise(killer,"models/player/police.mdl") end) end
			end
			end
			end
		end
		if !timer.Exists("npcforgettimer") then
			timer.Create( "npcforgettimer", GetConVarNumber("h_lostplayertimeout"), 1, npcforget ) 
		end
	end
	 
	if victim:GetClass() != "npc_turret_floor" and killer:IsPlayer() then
	CalculatePlayerScore(killer)
	end
	wavefinishedchecker()
	teamscore = (team_kills+(team_silent_kills*3))-(team_deaths*(PLAYERSINMAP+1))
end

function GM:PlayerSelectSpawn( pl )
	local availablespawns = {}
    local spawns = ents.FindByClass( "info_player_start" )
	local random_entry = math.random( #spawns )
	local spawn = false
	table.foreach(spawns, function(key,value)
		local can = 1
		for k, v in pairs(ents.FindInSphere(value:GetPos(),1000)) do
			if v:IsNPC() or v:GetClass() == "combine_bouncer" then
				if v:VisibleVec(value:GetPos()+Vector(0,0,60)) then
					can = 0
				end
			end
		end
		if can == 1 then
		table.insert(availablespawns, value)
		end
	end)
if table.Count(availablespawns) < 1 then
	PrintMessage(HUD_PRINTTALK, "ПРЕДУПРЕЖДЕНИЕ: Система не нашла ни одной безопасной координаты.ч")
	 return table.Random(spawns)
else
   return table.Random(availablespawns)
end

end


function CombineSelectSpawn()
CombineAvailableSpawns = {}
	--local random_entry = math.random( #combinespawnzones )
	--local spawn = false
	table.foreach(combinespawnzones, function(key,value)
		local can = 1
		for k, v in pairs(ents.FindInSphere(value,1000)) do
			if v:IsPlayer() then
				if v:VisibleVec(value) then
				print(v:Nick())
					can = 0
				end
			end
		end
		if can == 1 then
		print("Комбайн заспавнен в промежуточной координате.")
		table.insert(CombineAvailableSpawns, value)
		else
		print("Игрок, блокирует точку координата возрождения комбайна.")
		end
	end)

	
if table.Count(CombineAvailableSpawns) < 1 then
table.foreach(combinespawnzones, function(key,value)
table.insert(CombineAvailableSpawns, value)
end)
end
	
	/*
if table.Count(CombineAvailableSpawns) < 1 then
PrintMessage(HUD_PRINTTALK, "ВНИМАНИЕ: На ВСЕХ координатах возрождения комбайна есть игроки.")
return table.Random(combinespawnzones)
else
return table.Random(CombineAvailableSpawns)
end

*/
end

function ScalePlayerDamage(ply, hitgroup, dmginfo)
	dmginfo:ScaleDamage(1)
	if dmginfo:GetAttacker():IsPlayer() and !dmginfo:IsFallDamage() and !dmginfo:IsDamageType(64) then
		dmginfo:ScaleDamage(GetConVarNumber("h_playerscaledamage")*0.1)
	end
	if !dmginfo:GetAttacker():IsPlayer() then
		dmginfo:ScaleDamage(GetConVarNumber("h_playerscaledamage"))
	end
	if dmginfo:GetAttacker():IsPlayer() and !dmginfo:IsDamageType(64) then
		dmginfo:ScaleDamage(0)
	end
end
hook.Add("ScalePlayerDamage","ScalePlayerDamage", ScalePlayerDamage)

function ScaleNPCDamage( damaged, hitgroup, damage )
end
hook.Add("ScaleNPCDamage","ScaleNPCDamage",ScaleNPCDamage)

function GM:EntityTakeDamage(damaged,damage)
	damage:ScaleDamage(1)

	if table.HasValue(MainEnemiesDamage, damaged:GetClass()) then
		if damage:IsDamageType(8) or damage:GetAttacker():GetClass() == damaged:GetClass() then damaged:SetSchedule(SCHED_MOVE_AWAY) damage:ScaleDamage(2) end -- flee from fire and friendly fire
			if damaged:GetEnemy() == nil then
				damage:ScaleDamage(GetConVarNumber("h_npcscaledamage")*1.5)
				damaged:ClearSchedule() 
			else
				damage:ScaleDamage(GetConVarNumber("h_npcscaledamage"))
				if damage:IsDamageType(DMG_CLUB) then damage:ScaleDamage(0.5) end
			end
			if damaged:Health() > damage:GetDamage() then
				damaged:SetEnemy(damage:GetAttacker())
			end
		end

	/*
	if damaged:GetClass() == damage:GetAttacker():GetClass() then
		damage:ScaleDamage(0)
	end
	*/
	
if damaged:GetClass() == "npc_gunship" then
	if damaged:Health() <= damage:GetDamage() then
		HeliCanSpawn = false
		print("Вертолеты выведены из строя на 500 секунд.")
		timer.Create( "HeliCoolDown", 500, 1, function() HeliCanSpawn = true print("Штурмовик могут появиться снова.") end )
		damaged.spotlight:Fire("LightOff","",0)
		PrintMessage(HUD_PRINTTALK, "[Overwatch]: Состояние всех блоков, "..damaged:GetName().." изменено на: неработоспособно.")
	end
end

if damaged:GetClass() == "npc_helicopter" then
	if damaged:Health() < 800 and damaged:Health() > 650 then
		PrintMessage(HUD_PRINTTALK, "[Наблюдатель]: Подразделение по охране воздушного пространства, теперь вы можете свободно применять агрессивную тактику сдерживания.")
		RunConsoleCommand( "g_helicopter_chargetime", "1") 
		RunConsoleCommand( "g_helicopter_chargetime", "1") 
		RunConsoleCommand( "sk_helicopter_burstcount", "10") 
		RunConsoleCommand( "sk_helicopter_firingcone", "2") 
		RunConsoleCommand( "sk_helicopter_roundsperburst", "5") 
		damaged:SetKeyValue( "patrolspeed", "5000" )
		damaged.spotlight:Fire("LightOff","",0)
		if damaged.light then
			damaged.light:SetKeyValue("lightcolor", "0 0 0") 
		end	
		/* -- Original "Heli tries to crash on you" code. Doesn't work for now.
		if damaged:Health() < 151 then
		timer.Simple(3, function() PrintMessage(HUD_PRINTTALK, "[Наблюдатель]: Все устройства, "..damaged:GetName().." состояние изменено на: неработоспособное.") end)
		timer.Simple(1 , helideath(damaged))
		creating = ents.Create( "info_target_helicopter_crash" )
		creating:SetPos(damage:GetAttacker():GetPos() + Vector(0, 0, 500))
		creating:Spawn()
		creating:SetParent(damage:GetAttacker())
		end
		*/	
		if damaged:Health() <= damage:GetDamage() then	
			HeliCanSpawn = false
			print("Штурмовик выведен из строя на 500 секунд.")
			timer.Create( "HeliCoolDown", 500, 1, function() HeliCanSpawn = true print("Штурмовик могут появляться снова.") end )		
			damaged.spotlight:Fire("LightOff","",0)
			PrintMessage(HUD_PRINTTALK, "[Наблюдатель]: Все устройства, "..damaged:GetName().." состояние изменено на: не работает.")
			--print("dead")
		end
	end
end

if damaged:GetClass() == "npc_sniper" then
	if damage:GetInflictor():GetClass() == "crossbow_bolt" or damage:IsDamageType(64) or damage:IsDamageType(67108864) or damage:GetDamage() > 50 then
		damaged:SetHealth(0)
		PrintMessage(HUD_PRINTTALK, ""..damage:GetAttacker():GetName().." убрал снайпера. ")
	elseif math.random(1,5) == 3 then
		damaged:SetHealth(0)
		PrintMessage(HUD_PRINTTALK, ""..damage:GetAttacker():GetName().." убрал снайпера. ")
	end
end

if damaged:GetClass() == "npc_turret_ceiling" then
	if damage:IsDamageType(64) then
		damaged:SetHealth(0)
		PrintMessage(HUD_PRINTTALK, ""..damage:GetAttacker():GetName().." разрушена потолочная турель. ")
	else
		damage:ScaleDamage(0)
	end
end
	if damage:GetAttacker():GetClass() == "monster_apc" then
		damage:ScaleDamage(GetConVarNumber("h_npcscaledamage"))
	end
	if damaged:IsNPC() and (damage:GetDamage() < damaged:Health()) then
	damaged:SetEnemy(damage:GetAttacker())
	end

	if damage:IsDamageType(64) then 
		table.insert(zonescovered, damaged:GetPos()+Vector(math.random(-200,200),math.random(-200,200),0)) print("Добавлены координаты зон патрулирования.")
		allthecombinecome(damaged,GetConVarNumber("h_maxgunshotinvestigate"))
		ClearPatrolzones()
	elseif !damaged:IsNPC() and !damaged:IsPlayer() then
	if game.GetMap() == "zs_subway_v8" then
	if !damaged:GetClass() == "prop_dynamic" or !damaged:GetClass() == "keyframe_rope" then nearbycombinecomecasual(damaged) end
	else
	nearbycombinecomecasual(damaged)
	end
end

if damage:GetAttacker():IsPlayer() and table.HasValue(AffectedByDisguise,damaged:GetClass()) and damage:GetInflictor():GetClass() != "npc_tripmine" then
if damage:GetAttacker().disguised==1 then
if damage:GetDamage() < damaged:Health() then CombineDisguiseReveal(damage:GetAttacker()) else
for k, v in pairs(ents.FindInSphere(damaged:GetPos(),3000)) do
if table.HasValue(AffectedByDisguiseCanReveal, v:GetClass()) and v:Visible(damage:GetAttacker()) and v:EntIndex() != damaged:EntIndex() then
PrintMessage(HUD_PRINTCENTER, ""..v:GetName().." saw that")
v:SetEnemy(damage:GetAttacker())
CombineDisguiseReveal(damage:GetAttacker())
end
end
end
end
end

end
function PropBreak(breaker,prop)
if math.random(1,3) == 1 then
	if prop:IsValid() then
		if prop:GetModel() == "models/props_junk/wood_crate002a.mdl"
		or prop:GetModel() == "models/props_junk/wood_crate001a_damaged.mdl" 
		or prop:GetModel() == "models/props_junk/wood_crate001a_damagedmax.mdl" 
		or prop:GetModel() == "models/props_junk/wood_crate001a_damagedmax.mdl" 
		or prop:GetModel() == "models/props_junk/wood_crate001a.mdl" 
		or prop:GetModel() == "models/props_junk/cardboard_box003a.mdl"
		or prop:GetModel() == "models/props_junk/cardboard_box002a.mdl"
		or prop:GetModel() == "models/props_junk/cardboard_box004a.mdl"
		or prop:GetModel() == "models/props_c17/woodbarrel001.mdl"
		then
		SpawnItem(""..table.Random(CRATEITEMS).."", prop:GetPos(), Angle(0,0,0))
		end
	end
end
	nearbycombinecomecasual(prop)
end
hook.Add("PropBreak","OnPropBreak",PropBreak)

function GM:KeyPress(player,key)
	if player:Alive() and player:GetActiveWeapon() != NULL then
		local clip = player:GetActiveWeapon():Clip1()
		local loud = 1
		if key == IN_ATTACK then
			if player:Alive() and player.disguised==0 then
					if player:GetActiveWeapon():GetClass() == "weapon_crowbar" then
							--local traceRes = 2
							if util.QuickTrace(player:GetPos(), player:GetForward()*75, player).HitWorld then
							print("игрок ударил ломом")
							nearbycombinecomecasual(player)
							end
					end
				if table.HasValue(SILENT_WEAPONS, player:GetActiveWeapon():GetClass()) then
					loud = 0
					end
				if loud > 0 then 
					timer.Simple(0.1, function()
					--if 1==1 /* player:Alive() */ then
						if player:GetActiveWeapon():Clip1() then
							if player:GetActiveWeapon():Clip1() < clip then
								if player:GetActiveWeapon():Clip1() > -1 then
									local silenced = 0
										if player:GetActiveWeapon().Silenced == true then
										--print("Silenced 1")
										silenced = 1 end
									if table.HasValue(SILENCED_WEAPONS, player:GetActiveWeapon():GetClass()) then silenced = 1 end
--									table.foreach(SILENCED_WEAPONS, function(key,value)
--										if player:GetActiveWeapon():GetClass() == value then
--											--print("Silenced 2")
--											silenced = 1
--										end
--									end)
									if player:GetActiveWeapon().Primary then 
										if player:GetActiveWeapon().Primary.Sound == "Weapon_USP.SilencedShot" or player:GetActiveWeapon().Primary.Sound == "Weapon_M4A1.Silenced" or player:GetActiveWeapon().Primary.Sound == "Weapon_M4A1.Silenced" then
											--print("Silenced 3")
											silenced = 1
										end 
									end
									if player:GetActiveWeapon().dt then
										if player:GetActiveWeapon().dt.Suppressed == true then
											--print("Silenced 4")
											silenced = 1
										end
									end
									if silenced == 0 /* and player.spotted == 0 */ then
										print("NOT Silenced")
										allthecombinecome(player,GetConVarNumber("h_maxgunshotinvestigate"))
										--table.insert(zonescovered, player:GetPos()+Vector(0,0,30)) print("Patrol zone added")
									end
									if silenced == 1 then
										nearbycombinecomecasual(player)
									end
								end	
							end
						end
						--end
					end)
				end
			end
		end
		if key == IN_ATTACK2 then
			if player:GetAmmoCount(player:GetActiveWeapon():GetSecondaryAmmoType()) > 0 or (player:GetActiveWeapon():GetClass() == "weapon_shotgun") then
				if table.HasValue(SECONDARY_FIRE_WEAPONS, player:GetActiveWeapon():GetClass()) then allthecombinecome(player,GetConVarNumber("h_maxgunshotinvestigate")) end
			end
		end	
		if key == IN_ATTACK2 or key == IN_ATTACK then
			if player:GetActiveWeapon():GetClass() == "weapon_frag" then
				if player:GetAmmoCount(player:GetActiveWeapon():GetPrimaryAmmoType()) < 2 then
					timer.Simple(1, function() player:StripWeapon("weapon_frag") end)
				end
			end
		end
		if key == IN_SCORE then
			net.Start( "ShowHUDScoreboard" )	
			net.Send(player)
		end	
		if key == IN_WALK then
				PlayerHighlightItem(player)
		end	
		if key == IN_USE then
		print(player:GetEyeTraceNoCursor().Entity:GetModel())
			if player:GetEyeTraceNoCursor().Entity:GetClass() == "func_door_rotating" or player:GetEyeTraceNoCursor().Entity:GetClass() == "prop_door_rotating" then
			print(player:GetPos():Distance(player:GetEyeTraceNoCursor().Entity:GetPos()))
			if player:GetPos():Distance(player:GetEyeTraceNoCursor().Entity:GetPos()) < 99 then
					nearbycombinecomecasual(player)
			end
			end
			if player:GetEyeTraceNoCursor().HitWorld  then
			for k, v in pairs(ents.GetAll()) do
				if v:GetClass() == "npc_citizen" and v.owner == player:GetName() then 
					v:SetLastPosition(player:GetEyeTraceNoCursor().HitPos)
					v:SetSchedule(SCHED_FORCED_GO_RUN)
					--player:PrintMessage(HUD_PRINTTALK, "Rebel: Here I go.")
				end
			end
			end
		end	
	end
end

hook.Add( "PlayerUse", "PlayerPickUpProp", function( ply, ent )
if ent.holding !=1 then
-- /* and ent:GetClass() == "prop_physics" or  ent:GetClass() == "prop_physics_multiplayer" */
ent.holding=1

if timer.Exists("PlayerHoldProp") then
	timer.Destroy( "PlayerHoldProp")
end

timer.Create( "PlayerHoldProp", 2, 1, function()
if IsValid(ent) then
nearbycombinecomecasual(ent)
ent.holding=0
end
end)
end
end)

function GM:PhysgunDrop(ply, ent)
timer.Simple(2, function()
if IsValid(ent) then

nearbycombinecomecasual(ent)
end
end)
end

function GM:PlayerSetHandsModel( ply, ent )
	local simplemodel = player_manager.TranslateToPlayerModelName( ply:GetModel() )
	local info = player_manager.TranslatePlayerHands( simplemodel )
	if ( info ) then
		ent:SetModel( info.model )
		ent:SetSkin( info.skin )
		ent:SetBodyGroups( info.body )
	end
end

function GM:GetFallDamage( ply, speed )
	nearbycombinecomecasual(ply)
	return ( speed / 8 )
end

function GM:OnEntityCreated(entity)
	if entity:IsNPC() && entity:GetClass() != "npc_helicopter" && entity:GetClass() != "npc_combinegunship"  && entity:GetClass() != "npc_combine_s" && entity:GetClass() != "npc_metropolice" && entity:GetName() == "" then
		ManuallySpawnedEntity = ManuallySpawnedEntity + 1
		entity:SetName(""..entity:GetClass().." ("..entity:EntIndex()..")")
		print("[The Hunt]: "..entity:GetName().." создан.")
	end
if entity:IsNPC() then 
	entity:SetCollisionGroup(3)
	if GetConVarNumber("h_npctrails") == 1 then
		timer.Simple( 1, function()
			util.SpriteTrail(NPC, 1, Color(255,0,0), false, 15, 15, 50, 1/(15+1)*0.5, "trails/laser.vmt")
		end)
	end
end
end

function GM:DoPlayerDeath( ply, attacker, dmginfo )
	--timer.Simple(1, npcforget)
	ply:CreateRagdoll()
	ply:AddDeaths(1)
	NUMPLAYERS()
	ply.canspawn = 0
	ply.lifes=ply.lifes-1
	ply.deaths=ply.deaths+1
	team_deaths=team_deaths+1
	if ply.disguised==1 then
	CombineDisguiseReveal(ply)	
	end
	if attacker:IsNPC() then
		attacker:EmitSound(table.Random(CombineKillSounds), 70, 100)
		attacker:ClearEnemyMemory()
	end

	if attacker:GetClass() == "npc_sniper" then
		local pos = attacker:GetPos()
		local ang = attacker:GetAngles()
		attacker:Remove()
		SpawnItem("npc_sniper", pos, ang)
	end

	table.foreach( ply:GetWeapons(), function(key,value)
		if key > 1 then
			if value:Clip1() then
				if value:Clip1() == 0 and !table.HasValue(ONLY_PICKUP_ONCE, value)  then
					value:Remove()
					else
					ply:DropWeapon(value)
				end
			end
		end
	end)

	timer.Simple(1, function()
		if attacker:IsNPC() then
			ply:Spectate(5)
			ply:SetMoveType(10)
			ply:SpectateEntity(attacker)
		end
		
		if PLAYERSINMAP > 1 then
			if ply.lifes == 0  then
				ply:PrintMessage(HUD_PRINTTALK, "У тебя не осталось жизней.")
				ply:PrintMessage(HUD_PRINTTALK, "Вы можете увидеть своих товарищей по команде, щелкнув правой кнопкой мыши.")
				ply:PrintMessage(HUD_PRINTTALK, "Проверьте свой счет, набрав !myscore или !teamscore.")
			else
				ply:PrintMessage(HUD_PRINTTALK, "У вас остались "..ply.lifes.." жизней.")
				ply.canspawn = 1
		end
		elseif ply.teamkiller < 3 then
			ply.canspawn = 1
		end
	end)

/*
if PLAYERSINMAP > 1 then
	local players_defeated = 1
	table.foreach(player.GetAll(), function(key,value)
	if value:Alive() or value.lifes > 0 then players_defeated = 0 end
	end)
	if players_defeated == 1  then 
	PlayerDefeat()
	--CanCheck = 0
	end
end
*/

	if table.Count(zonescovered) > ORIGINAL_ZONES_NUMBER+10 then
		table.remove(zonescovered)
		table.remove(zonescovered)
		table.remove(zonescovered)
		table.remove(zonescovered)
		table.remove(zonescovered)
		table.remove(zonescovered)
		table.remove(zonescovered)
		table.remove(zonescovered)
		table.remove(zonescovered)
		table.remove(zonescovered)
		print("[The Hunt]: Зоны патрулирования очищены.")
	end
	
	table.insert(zonescovered, ply:GetPos()+Vector(0,0,30)) print("[The Hunt]: Добавлены координаты патрулирования.")
	
	if attacker:IsPlayer() and dmginfo:GetInflictor():GetClass() == "prop_physics_multiplayer" or dmginfo:GetInflictor():GetClass() == "prop_physics" or dmginfo:GetInflictor():GetClass() == "cw_ammo_crate_small" or dmginfo:GetInflictor():GetClass() == "npc_satchel"  or dmginfo:GetInflictor():GetClass() == "npc_grenade_frag" 
then
		if attacker:GetName() != ply:GetName() then
			attacker.teamkiller=attacker.teamkiller+1
			dmginfo:GetAttacker():PrintMessage(HUD_PRINTCENTER, "Старайтесь избегать убийства товарищей по команде.")
			if dmginfo:GetAttacker().teamkiller > 2 then
				dmginfo:GetAttacker():PrintMessage(HUD_PRINTCENTER, "Перестаньте убивать товарищей по команде.")
				dmginfo:GetAttacker():Kill()
				dmginfo:GetAttacker().lifes=0
				dmginfo:GetAttacker().canspawn = 0
			end
		end
	else
		print(""..ply:GetName().." умер от "..dmginfo:GetInflictor():GetClass().."")
	end
	CalculatePlayerScore(ply)
end
function CombineDisguise(ply,model)
CanNotice = 1
local CanDisguise=1
for k, v in pairs(ents.FindInSphere(ply:GetPos(),1500)) do
if table.HasValue(AffectedByDisguise, v:GetClass()) and v:IsLineOfSightClear(ply) then
	ply:PrintMessage(HUD_PRINTTALK, "маскировка не завершена")
CanDisguise=0
end
end
if CanDisguise==1 then
	ply:SetWalkSpeed(70)
	ply:SetRunSpeed(150)
	ply:SetCrouchedWalkSpeed(0.3)
	ply:SendLua("disguised=1")		
	ply.disguised=1
	--ply:PrintMessage(HUD_PRINTTALK, "Disguised!")
	ply:SetModel(model)
	for k, npc in pairs(ents.GetAll()) do
		if table.HasValue(AffectedByDisguiseCanReveal, npc:GetClass()) then
			npc:AddEntityRelationship( ply, D_LI, 99 )
		end
	end
	CombineDisguiseDistanceCheck()
	ply:SetupHands()
end
end
function CombineDisguiseDistanceCheck()
for k, player in pairs(player.GetAll()) do
if player.disguised==1 then
for k, npc in pairs(ents.GetAll()) do
 if table.HasValue(AffectedByDisguise, npc:GetClass()) then
		npc:AddEntityRelationship( player, D_LI, 99 )
	 end
end
	for k, npc in pairs(ents.FindInSphere(player:GetPos(),200)) do
	if table.HasValue(AffectedByDisguiseCanReveal, npc:GetClass()) and npc:IsLineOfSightClear(player) then
	if npc.HuntID == "CombineElite1" or npc.HuntID == "CombineElite2" and npc:Health() > 1 then CombineDisguiseReveal(player) elseif CanNotice == 1  and !table.HasValue(Combine_Approved_Weapons, player:GetActiveWeapon():GetClass()) then CanNotice = 0 PrintMessage(HUD_PRINTTALK, ""..npc:GetName()..": "..table.Random(CombineWeaponNotice).."") end
	if !player:IsOnGround() then CombineDisguiseReveal(player) end
	break
	end
	end
	end
end
timer.Simple(2, CombineDisguiseDistanceCheck)
end
function CombineDisguiseReveal(ply)
ply:SendLua("disguised=0")		
--ply:PrintMessage(HUD_PRINTTALK, "Revealed!")
if ply:Alive() then
if ply.sex == "male" then
ply:SetModel(table.Random(playermodelsmale))
else
ply:SetModel(table.Random(playermodelsfemale))
end
end
for k, npc in pairs(ents.GetAll()) do
 if npc:IsNPC() then -- if found entity is not self entity then continue
 if table.HasValue(AffectedByDisguise, npc:GetClass()) then
		npc:AddEntityRelationship( ply, D_HT, 99 )
 end
	 end
end
ply:SetWalkSpeed(150)
ply:SetRunSpeed(250)
ply:SetCrouchedWalkSpeed(0.3)
ply.disguised=0
end
function FirstSpawn(ply)
	ply:SetNWInt("canrequestrebels",1)
	ply.lifes=GetConVarNumber("h_player_lifes")
	ply.deaths=0
	ply.Kills=0
	ply.SilentKills=0
	ply.teamkiller=0
	ply.spotted = 0
	ply.disguised=0
	NUMPLAYERS()
	ply:SetNWInt("ReferentScore", 0)
	timer.Simple(5, function() ply:SendLua("light()") end)
	if GetConVarString("h_hints") == "1" then
	ply:SendLua("Hints()")
	end
	if DARKNESS then
		ply:SendLua("CLDARKNESS="..DARKNESS.."" )		
	end
end
hook.Add( "PlayerInitialSpawn", "playerInitialSpawn", FirstSpawn )
print(" -----[Загрузка init.lua завершена ----- ")
