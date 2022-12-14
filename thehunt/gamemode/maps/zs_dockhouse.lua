include( "basewaves.lua" )

-- Number of combine that will spawn on each wave.
CombineFirstWave = 4
CombineSecondWave = 7
CombineThirdWave = 10
CombineFourthWave = 10
CombineFifthWave = 10
CombineInfiniteWave = 15
DARKNESS = 3

-- Number of seconds the combine will be running around (going to the coverzones and so spreading around the map) a the start of each wave. If not set, will be always 30. Larger maps work better with higher values.
CUSTOMWAVESPAWN = 30

-- Where the combine will spawn.
combinespawnzones = {
Vector(1160.756592, 238.054413, -7.968750),
Vector(1151.879150, 153.612991, -7.968750),
}

-- Positions between the combine will patrol.
zonescovered ={
Vector(-782.666138, 31.267132, 64.025604),

Vector(-794.276611, 187.954407, 208.031250),
Vector(-288.535583, 218.652863, 208.031250),
Vector(-1000.467896, 725.782715, 40.782379),
Vector( -1053.290527, -126.651848, 11.906097),
Vector(-702.927246, -1351.087769, 64.031250),
Vector(-458.557800, 70.111580, -79.968750),
}

-- Special items will spawn only there. Not implemented yet.
SPECIALITEMPLACES = { Vector(-412.031769, 469.709656, -50.026352),}

-- If you provide this table, the game will search for these models upon loading and will make them weapon spawnpositions. The models found will become invulnerable and unmovable. In this demo, look for the tables in the middle of the map.
HeliCanSpotlight = 1

MAP_PROPS = {"models/props_c17/furnituredrawer001a.mdl", "models/props_wasteland/kitchen_shelf001a.mdl","models/props_c17/furnituretable003a.mdl","models/props_c17/shelfunit01a.mdl","models/props_wasteland/prison_bedframe001a.mdl"}

-- Predefined weapon spawnpositions.
ITEMPLACES ={
Vector(-526.981873, 230.435364, 352.031250),
}
-- Run revealweaponspawns on the console to higlight these places. Run hidezones to hide the sprite.

HELIPATHS = {
Vector(967.547241, 722.096069, 465.658081),
Vector(-332.053497, 1746.362427, 424.269958),
Vector(-1783.675171, 1147.882935, 356.491699),
Vector(-1636.565674, -651.372314, 291.651062),
Vector(-479.840240, -1300.036133, 301.770630),
Vector(662.463440, -884.775635, 301.770630),
Vector(-2341.910156, 232.876266, 414.789948),
}

ITEMPLACES = {
Vector(-609.556640625, -1364.6181640625, 31.016067504883),
Vector(-607.66040039063, -1395.5520019531, 31.003257751465),
Vector(-618.85528564453, -1447.6557617188, 31.058280944824),
Vector(-619.03997802734, -1477.7336425781, 31.055076599121),
Vector(-343.06072998047, 32.596210479736, 19.524223327637),
Vector(-272.44296264648, 742.34454345703, 32.03125),
Vector(-235.1162109375, 742.46081542969, 32.03125),
Vector(-202.60794067383, 740.80908203125, 32.03125),
Vector(-174.09729003906, 739.51922607422, 32.03125),
Vector(-267.57681274414, 529.38482666016, 33.065933227539),
Vector(-431.77746582031, 743.39031982422, 32.03125),
Vector(-856.52923583984, -65.011543273926, 4.8109436035156),
Vector(-670.17211914063, -63.563510894775, 33.072578430176),
Vector(-833.92657470703, 158.50054931641, 16.237922668457),
Vector(-855.759765625, 186.42633056641, 160.77420043945),
Vector(-673.63983154297, 28.182210922241, 184.30741882324),
Vector(-460.6862487793, 104.24044799805, 163.53012084961),
Vector(-516.82385253906, -80.15828704834, 181.32563781738),
Vector(-312.99572753906, 478.99081420898, 155.29147338867),
Vector(-387.94195556641, 100.38136291504, 177.71313476563),
Vector(-170.91436767578, 85.831649780273, 182.88404846191),
Vector(-845.94506835938, 176.14962768555, 288.03125),
Vector(-848.15417480469, 193.11140441895, 288.03125),
Vector(-165.61282348633, 192.6291809082, 288.03125),
Vector(-1264.8581542969, 858.16223144531, 44.17200088501),
Vector(-1241.3203125, 860.11444091797, 45.538677215576)
}

-- If defined, this table sets which items a normal crate can spawn upon break. 
CRATEITEMS = { "weapon_bp_alyxgun", "weapon_bp_annabelle", "weapon_bp_shotgun", "weapon_bp_smg2", "weapon_bp_smg3","weapon_bp_sniper" }

-- If defined, this table sets which items an ammo crate can spawn upon break. 
GOODCRATEITEMS = { "item_dynamic_resupply","weapon_frag", "weapon_slam","item_healthkit", "weapon_bp_smg2","item_box_buckshot","item_ammo_smg1_large","item_ammo_crossbow","item_ammo_ar2_large","item_ammo_ar2_altfire"}

-- Edit the text inside the "" to edit what the game will tell the players when they join.
function GM:PlayerInitialSpawn(ply)
ply:SendLua("CLDARKNESS="..DARKNESS.."" )
end

function MapSetup()
table.foreach(SPAWNPOINTS_TO_DELETE, function(key,value)
for k, v in pairs(ents.FindByClass(value)) do
print(v:GetClass())
v:Remove()
end
end)
table.foreach(HELIPATHS, function(key,value)
CreateHeliPath(value)
end)

SpawnEntranceInfoNode(Vector(-148.775467, 220.073654, 18.680799) )
SpawnItem("info_player_start", Vector(-183.192581, 331.952728, -79.968750)+Vector(0,0,-50), Angle(9,170,0))
SpawnItem("info_player_start", Vector(-753.331421, 308.122131, 352.031250)+Vector(0,0,-50), Angle(5,180,0))
SpawnAmmoCrate(Vector(-747.637146, -1551.606201, 16.411165),Angle(0,90,0),3)
end