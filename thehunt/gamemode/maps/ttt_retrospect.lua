include( "basewaves.lua" )
CombineFirstWave = 7
CombineSecondWave = 10
CombineThirdWave = 10
CombineFourthWave = 10
CombineFifthWave = 10
CombineInfiniteWave = 20

MAP_PROPS = {"models/props_combine/breendesk.mdl","models/fallout3/dinertable01.mdl","models/props_c17/furnituretable001a.mdl","models/props_c17/bench01a.mdl","models/props_c17/furnituretable002a.mdl","models/props_wasteland/controlroom_desk001b.mdl","models/props_interiors/furniture_desk01a.mdl"}

zonescovered ={
Vector(-728.273376, 812.751465, -557.888794),
Vector(-178.006393, -151.472153, -555.091736),
Vector(-520.256042, 416.150116, -374.874756),
Vector(2.626604, 658.901306, -120.968750),
Vector(800.008545, -164.743271, -120.968750),
Vector(574.142639, -217.282227, -120.968750),
}

ITEMPLACES ={
Vector(-114.795677, 536.869995, -562.824768),
Vector(-950.040100, 801.052551, -545.57428),
Vector(-769.884766, -10.406260, -568.583557),
Vector(-640.742432, 454.084381, -339.968750),

Vector(475.189453125, -346.87750244141, -619.96875),
Vector(449.66748046875, -260.70391845703, -619.96875),
Vector(627.93310546875, 173.72430419922, -581.43133544922),
Vector(866.60028076172, 179.15438842773, -581.43133544922),
Vector(875.70111083984, 55.697563171387, -582.45562744141),
Vector(767.89398193359, 370.03942871094, -585.54504394531),
Vector(219.64804077148, 349.90539550781, -597.90826416016),
Vector(245.08772277832, 326.13284301758, -597.75421142578),
Vector(-122.66744232178, 558.53137207031, -575.96875),
Vector(-163.65632629395, 642.787109375, -575.96875),
Vector(-255.2762298584, 683.27276611328, -575.96875),
Vector(-236.38638305664, 565.77899169922, -582.64935302734),
Vector(-92.002044677734, 832.02124023438, -605.22259521484),
Vector(223.48573303223, 919.64404296875, -605.10052490234),
Vector(347.18194580078, 727.73956298828, -605.15051269531),
Vector(294.12869262695, 641.50866699219, -605.10528564453),
Vector(-497.71520996094, 257.90194702148, -587.24127197266),
Vector(-689.26910400391, -275.64227294922, -586.84515380859),
Vector(-690.24462890625, -215.40525817871, -588.23583984375),
Vector(-822.10571289063, -225.6403503418, -588.25048828125),
Vector(-820.00842285156, -291.82464599609, -588.26910400391),
Vector(-621.59887695313, -406.71725463867, -585.06201171875),
Vector(-503.67575073242, -424.02914428711, -585.06201171875),
Vector(-685.70611572266, 641.38452148438, -581.54644775391),
Vector(-578.240234375, 775.45440673828, -589.41357421875),
Vector(-418.63775634766, 573.27954101563, -581.54644775391),
Vector(-570.75933837891, 896.32379150391, -566.97955322266),
Vector(-595.03582763672, 871.27294921875, -565.03442382813),
Vector(-975.38439941406, 900.009765625, -565.88330078125),
Vector(-973.42120361328, 941.05773925781, -566.17358398438),
Vector(-670.15197753906, 438.85061645508, -403.96875),
Vector(-685.59802246094, 321.34820556641, -403.96875),
Vector(-726.56622314453, 387.78283691406, -403.96875),
Vector(-413.66162109375, 237.43989562988, -401.70190429688),
Vector(-439.63177490234, 180.68461608887, -401.63836669922),
Vector(700.48345947266, -340.42037963867, -184.96875),
Vector(657.75103759766, -336.00469970703, -184.96875),
Vector(611.93298339844, -346.43472290039, -184.96875),
Vector(511.18023681641, -355.96038818359, -184.96875),
Vector(933.62640380859, -73.342094421387, -184.96875),
Vector(926.33154296875, -120.60691070557, -184.96875),
Vector(924.86566162109, -170.14166259766, -184.96875),
Vector(-0.72772026062012, 861.60748291016, -152.95140075684),
Vector(314.56234741211, 814.12139892578, -144.91987609863),
Vector(389.66876220703, 773.32135009766, -184.96875),
Vector(399.05859375, 819.90606689453, -184.96875)
}


combinespawnzones = {
Vector(2.105979, 954.821899, -557.968750),
Vector(177.139481, 619.624573, -562.051392)
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


SpawnItem("info_player_start", Vector(-526.477661, 953.719666, -557.888794)+Vector(0,0,-45), Angle(0,-166,0))
SpawnItem("info_player_start", Vector(476.141205, -351.726013, -575.968750)+Vector(0,0,-45), Angle(18,128,0))


/*
SpawnTurret(Vector(-491.003052, -1442.955566, -239.262634),Angle(0.397, 167.418, 0.522))
SpawnTurret(Vector(556.156494, 2330.056641, 128.705292),Angle(0.331, 22.378, 0.497))
SpawnTurret(Vector(-709.125061, 169.305756, 8.702634),Angle(0.201, 51.508, 0.738))
SpawnProp(Vector(490.964935, 2385.634766, 0.909191),Angle(0,0,0),"models/props_junk/sawblade001a.mdl")
SpawnProp(Vector(490.964935, 2385.634766, 2.909191),Angle(0,0,0),"models/props_junk/sawblade001a.mdl")
SpawnProp(Vector(490.964935, 2385.634766, 4.909191),Angle(0,0,0),"models/props_junk/sawblade001a.mdl")
SpawnItem("monster_apc", Vector(-512.362732, -1917.421143, -175.968750)+Vector(0,0,0), Angle(0,0,0))


SpawnProp(Vector(941.523132, 184.121384, -131.631363),Angle(0,0,0),"models/props_junk/wood_crate001a.mdl")
SpawnProp(Vector(941.523132, 184.121384, -101.631363),Angle(0,0,0),"models/props_junk/wood_crate001a.mdl")
SpawnProp(Vector(941.523132, 184.121384, 21.631363),Angle(0,0,0),"models/props_junk/wood_crate001a.mdl")
SpawnProp(Vector(941.523132, 184.121384, 51.631363),Angle(0,0,0),"models/props_junk/wood_crate001a.mdl")

SpawnProp(Vector(941.523132, 184.121384, 51.631363),Angle(0,0,0),"models/props_junk/wood_crate001a.mdl")
SpawnProp(Vector(941.523132, 184.121384, 51.631363),Angle(0,0,0),"models/props_junk/wood_crate001a.mdl")
SpawnProp(Vector(941.523132, 184.121384, 51.631363),Angle(0,0,0),"models/props_junk/wood_crate001a.mdl")
SpawnProp(Vector(941.523132, 184.121384, 51.631363),Angle(0,0,0),"models/props_junk/wood_crate001a.mdl")


SpawnProp(Vector(983.913452, -794.092651, -151.607880),Angle(0,0,0),"models/props_c17/oildrum001_explosive.mdl")
SpawnProp(Vector(1008.994324, -780.184509, -151.532333),Angle(0,0,0),"models/props_c17/oildrum001_explosive.mdl")
SpawnProp(Vector(1062.439209, -714.620239, -151.612885),Angle(0,0,0),"models/props_c17/oildrum001_explosive.mdl")
SpawnProp(Vector(1042.702026, -686.063293, -151.616333),Angle(0,0,0),"models/props_c17/oildrum001_explosive.mdl")
SpawnProp(Vector(1057.852783, -654.657043, -151.643707),Angle(0,0,0),"models/props_c17/oildrum001_explosive.mdl")
*/
end



