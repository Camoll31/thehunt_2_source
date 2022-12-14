SC = {}

SC.Title = GetHostName() -- The title at the top of the chatbox
SC.FontText = "Tahoma" -- What font you would like to use for the chatbox text
SC.FontHeader = "Tahoma" -- What font you would like to use for the chatbox header

SC.FadeTime = 5 -- How long should the chat messages stay before going away?

SC.W = 520 -- The width of the chatbox (probably best to avoid changing)
SC.H = 284 -- The height of the chatbox

SC.X = 30 -- How far away should the chatbox be from the left hand side of the screen
SC.Y = ScrH() - 210 - SC.H -- How far away should the chatbox be from the top of the screen

SC.Time = true -- Should we show timestamps? (set by the client)
SC.JoinLeave = false -- Should we show timestamps? (set by the client)

SC.Sound = true -- Should we play a chatsound? (set by the client)
SC.CustomSound = true -- If the above is true, should the sound be custom?
SC.SoundPath = "garrysmod/ui_return.wav" -- If the sound is to be custom, the filepath for the sound needs to go here

SC.Rank = false -- Should we show rank tags?
-- If the above is enabled these tags will show based on the user's usergroup
SC.Ranks = {}
SC.Ranks[1] = {"superadmin", 	"[SuperAdmin]", function(ply) return Color(184, 55, 255) end}
SC.Ranks[2] = {"admin", 		"[Admin]", 		function(ply) return Color(229, 105, 37) end}
SC.Ranks[3] = {"operator", 		"[Op]", 		function(ply) return Color(96, 143, 191) end}
SC.Ranks[4] = {"guest", 		"[Guest]", 		function(ply) return Color(232, 144, 44) end}