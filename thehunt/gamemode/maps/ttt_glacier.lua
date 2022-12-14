include( "basewaves.lua" )
CombineFirstWave = 5
CombineSecondWave = 5
CombineThirdWave = 7
CombineFourthWave = 7
CombineFifthWave = 8
CombineInfiniteWave = 9

CUSTOMWAVESPAWN = 30

zonescovered ={
Vector(57.791965, 452.627563, -292.868225),
Vector(-476.973480, 366.857666, -319.968750),
Vector(245.742905, 286.338104, 64.031250),
Vector(846.063599, -109.995544, 64.031250),
Vector(581.763611, 731.464722, 70.784836),
Vector(204.127457, 1014.830994, 64.031250),
Vector(-205.777939, 987.058533, 64.031250),
Vector(-1125.929199, 787.080933, 64.031250),
Vector(-837.405396, 456.573456, 75.769165),
Vector(-496.465790, 0.806757, 64.031250),
Vector(-16.154320, 464.753571, 64.031250),
Vector(-657.451355, 879.217896, 68.937576),
Vector(273.822998, -198.415970, 64.031250),
Vector(192.427109, 631.149353, 64.031250),
Vector(-209.801208, 604.506836, 64.031250),
Vector(-0.762461, 211.799591, -291.968750),
}

MAP_PROPS = {}

SPECIALITEMPLACES = {Vector(3.602486, 456.569336, 64.031250),}

ITEMPLACES ={
Vector(773.413757, -199.495712, 2.628300),
Vector(554.757324, 347.635803, 41.027058),
Vector(-163.225311, 440.898315, -3.501307),
Vector(180.391022, 217.402237, 60.095245),
Vector(-174.373856, 274.715851, 23.514084),
Vector(-1012.973206, 923.218262, 2.425853),
Vector(312.262726, 384.127197, -339.184387),
Vector(-636.495361, 763.914246, 64.738464),

Vector(-1185.1970214844, 559.41510009766, 0.031253814697266),
Vector(-864.44995117188, 611.26416015625, 0.03125),
Vector(-474.22555541992, 875.01635742188, 0.03125),
Vector(213.21377563477, 857.72973632813, -251.96875),
Vector(-206.0074005127, 767.11950683594, -251.96875),
Vector(-206.33261108398, 1109.2996826172, -251.96875),
Vector(207.51731872559, 1108.3819580078, -251.96875),
Vector(207.9196472168, 248.5233001709, -383.96875),
Vector(215.61839294434, 494.45248413086, -383.96875),
Vector(-235.79663085938, 575.68634033203, -339.67358398438),
Vector(-478.29995727539, 608.03051757813, -383.96875),
Vector(187.53875732422, 267.95709228516, 0.03125),
Vector(170.32125854492, -67.777786254883, 0.03125),
Vector(401.92987060547, -208.68215942383, 0.03125),
Vector(829.01538085938, -203.03573608398, 0.03125),
Vector(414.09884643555, 542.26586914063, 0.03125),
Vector(-1227.318359375, 964.26446533203, 0.03125),
Vector(-1219.9915771484, 594.88586425781, 0.03125),
Vector(-952.30212402344, 887.81622314453, 0.031253814697266),
Vector(-763.00817871094, 392.29559326172, 7.5297622680664),
Vector(-715.65637207031, 553.57489013672, 64.510452270508),
Vector(-478.01104736328, 869.10076904297, 0.03125),
Vector(-688.79400634766, 981.35028076172, 0.03125),
Vector(-170.79879760742, 598.59759521484, 0.03125),
Vector(-197.25761413574, 686.7080078125, -251.96875),
Vector(-587.51928710938, -25.598556518555, 0.03125),
Vector(-172.28424072266, -5.769700050354, 0.03125),
Vector(-228.466796875, 269.42980957031, 0.03125),
Vector(-173.51498413086, 272.60385131836, 21.961807250977),
Vector(173.87072753906, 605.07580566406, 0.03125),
Vector(107.16693115234, 571.13293457031, 2.2728881835938),
Vector(179.32791137695, 610.01892089844, 0.03125),
Vector(725.42425537109, 969.41510009766, 0.03125),
Vector(730.44714355469, 897.61083984375, 40.613952636719),
Vector(688.54425048828, 901.80487060547, 0.031253814697266),
Vector(578.64013671875, 449.80108642578, 0.031253814697266),
Vector(775.05090332031, 442.33752441406, 0.03125),
Vector(912.20233154297, 54.831001281738, 0.031253814697266),
Vector(878.69439697266, -166.83901977539, 0.03125),
Vector(563.1435546875, -41.579448699951, 0.031253814697266),
Vector(264.26983642578, 334.65563964844, 0.03125),
Vector(186.97177124023, 253.95907592773, 0.03125),
Vector(175.73031616211, -74.908218383789, 0.03125),
Vector(-227.14912414551, 209.89025878906, -383.96875),
Vector(-216.82681274414, 524.61840820313, -383.96875),
Vector(227.17530822754, 450.1061706543, -383.96875),
Vector(231.59019470215, 239.16516113281, -383.96875),
Vector(291.52612304688, 247.00941467285, -383.96875),
Vector(555.76385498047, 344.3600769043, 40.613956451416),
Vector(558.49249267578, 392.23275756836, 64.510452270508),
}

combinespawnzones = {
Vector(261.247437, 281.490997, -319.968750),
Vector(215.115677, 420.200775, -319.968750),
Vector(-45.083946, 518.354919, -291.968750),
Vector(-13.638227, 234.005829, -291.968750),
}

function GM:PlayerInitialSpawn(ply)
timer.Simple(2, function() ply:PrintMessage(HUD_PRINTTALK, "[Альянс]: Всем автономным отрядам: Начать принудительную ассимиляцию сектора.") end )
timer.Simple(4, function() ply:PrintMessage(HUD_PRINTTALK, "[Альянс]: Произвести контролированное изменение численности. Выделить и идентифицировать объекты") end )
timer.Simple(12, function() ply:PrintMessage(HUD_PRINTTALK, "Подсказка: !taunt - крик, который привлекает комбайнов поблизости.") end )
timer.Simple(14, function() ply:PrintMessage(HUD_PRINTTALK, "Подсказка: !remain - показывает кол-во комбайнов на карте.") end )
end

function MapSetup()
table.foreach(SPAWNPOINTS_TO_DELETE, function(key,value)
for k, v in pairs(ents.FindByClass(value)) do
print(v:GetClass())
v:Remove()
end
end)

for k, v in pairs(ents.FindByClass("func_door_rotating")) do
print(v:GetClass())
v:Remove()
end

if math.random (1,2) == 1 then 
		SpawnItem("item_healthcharger", Vector(-1263.469360, 980.469299, 52.896736), Angle(-0.000, 0.000, 0.262) )
	elseif math.random (1,2) == 1 then 
		SpawnItem("item_healthcharger", Vector(-308.005432, -111.539223, 50.918354), Angle(-0.011, 89.982, -0.240) )
	else
		SpawnItem("item_healthcharger", Vector(436.787933, -223.473618, 53.046143), Angle(0.040, 89.945, 0.069) )
end
if math.random (1,2) == 1 then 
		SpawnItem("item_healthcharger", Vector(169.260956, 160.497589, -300.695007), Angle(-0.012, 90.214, 0.079) )
	elseif math.random (1,2) == 1 then 
		SpawnItem("item_healthcharger", Vector(144.524307, 686.092163, 53.791191), Angle(0.059, -0.083, -0.513) )
	else
		SpawnItem("item_healthcharger", Vector(-144.485352, 945.574463, 51.353291), Angle(0.020, 179.760, 0.061) )
end

SpawnStaticProp(Vector(-1313.221558, -1243.587769, -310.317780),Angle(0,0,0),"models/props_junk/trashdumpster01a.mdl")
SpawnStaticProp(Vector(-1313.120972, -1328.330322, -310.333618),Angle(0,0,0),"models/props_junk/trashdumpster01a.mdl")

SpawnItem("info_player_start", Vector(673.911682, 913.317749, 64.031250)+Vector(0,0,-45), Angle(2.568265, 97.122978, 0.000000))
SpawnItem("info_player_start", Vector(-200.129471, 903.875977, -187.968750)+Vector(0,0,-60), Angle(5.334162, -90.968132, 0.000000))
SpawnItem("info_player_start", Vector(202.746460, 911.122314, -187.968750)+Vector(0,0,-60), Angle(6.124406, -90.770561, 0.000000))
SpawnItem("info_player_start", Vector(-1174.205566, 569.520752, 64.031250)+Vector(0,0,-45), Angle(2.863851, 34.701748, 0.000000))

if math.random(1,2) == 1 then
		SpawnTurret(Vector(155.560608, 491.270966, -3.226768),Angle(0.388, -137.187, 0.589))
		else
		SpawnTurret(Vector(155.815308, 407.620697, -3.198815),Angle(0.290, 130.551, 0.128))
end
if math.random(1,2) == 1 then
		SpawnTurret(Vector(-447.199890, 606.718506, -383.271118),Angle(0.217, -91.696, 0.621))
		else
		SpawnTurret(Vector(-256.225464, 530.781555, -255.236130),Angle(0.285, 0.298, 0.570))
end
if math.random(1,2) == 1 then
		SpawnTurret(Vector(556.707336, 64.687462, 1.050992),Angle(0.999, 43.454, 0.226))
		else
		SpawnTurret(Vector(835.171753, -211.621002, 0.754106),Angle(0.252, 160.858, 0.130))
end
if math.random(1,2) == 1 then
		SpawnTurret(Vector(-161.314407, 1031.797729, 0.751246),Angle(0.354, -108.420, 0.411))
		else
		SpawnTurret(Vector(154.867493, 1035.699341, 0.719017),Angle(0.342, -81.083, 0.236))
end
end