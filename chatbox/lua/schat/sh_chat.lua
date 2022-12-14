if SERVER then
	AddCSLuaFile("autorun/schat.lua")
	AddCSLuaFile("schat/sh_chat.lua")
	AddCSLuaFile("schat/sh_config.lua")
	AddCSLuaFile("schat/vgui/panel.lua")
	resource.AddFile("resource/fonts/Lato-Regular.ttf")

	util.AddNetworkString("SChatMsg")
	local meta = FindMetaTable("Player")
	function meta:ChatPrint(str)
		net.Start("SChatMsg")
			net.WriteString(str)
		net.Send(self)
	end

	meta.OldPrintMessage = meta.PrintMessage
	function meta:PrintMessage(type, str)
		if type == HUD_PRINTTALK then
			net.Start("SChatMsg")
				net.WriteString(str)
			net.Send(self)
		else
			self:OldPrintMessage(type, str)
		end
	end

	local OldPrintMessage = PrintMessage
	function PrintMessage(type, str)
		if type == HUD_PRINTTALK then
			net.Start("SChatMsg")
				net.WriteString(str)
			net.Broadcast()
		else
			OldPrintMessage(type, str)
		end
	end

	util.AddNetworkString("SChatListen")
	gameevent.Listen("player_connect")
	hook.Add("player_connect", "SCJoin", function(data)
		net.Start("SChatListen")
			net.WriteBit(true)
			net.WriteString(data.name)
		net.Broadcast()
	end)

	gameevent.Listen("player_disconnect")
	hook.Add("player_disconnect", "SCLeave", function(data)
		net.Start("SChatListen")
			net.WriteBit(false)
			net.WriteString(data.name)
		net.Broadcast()
	end)
	return
end

include("sh_config.lua")

surface.CreateFont("SChatText", {font = SC.FontText, weight = 600, size = 18, blursize = 0, antialias = true, shadow = true})
surface.CreateFont("SChatTitle", {font = SC.FontHeader, weight = 200, size = 20, blursize = 0, antialias = true}) 

include("vgui/panel.lua")


local SChat

hook.Add("HUDShouldDraw", "SCHideHUD", function(v)
	if v == "CHudChat" then return false end
end)

hook.Add("PlayerBindPress", "SCBind", function(ply, bind, pressed)
	if ply == LocalPlayer() then
		if bind == "messagemode" and pressed then
			if not IsValid(SChat) then 
				SChat = vgui.Create("SCBox")
			end
			SChat.TeamBased = false
			SChat:DoOpen()
			return true
		elseif bind == "messagemode2" and pressed then
			if not IsValid(SChat) then 
				SChat = vgui.Create("SCBox")
			end
			SChat.TeamBased = true
			SChat:DoOpen()
			return true
		end
	end
end)

local chatAddText = chat.AddText
function chat.AddText(...)
	chatAddText(...)
	SChat = SChat or vgui.Create("SCBox")
	SChat:AddText(...)
	if SC.Sound then
		if SC.CustomSound then
			surface.PlaySound(SC.SoundPath)
		else
			chat.PlaySound()
		end		
	end
end

local meta = FindMetaTable("Player")
function meta.ChatPrint(str)
	return chat.AddText(str)
end

function chat.GetChatBoxPos() 
	return SC.X, SC.Y
end

function chat.GetChatBoxSize() 
	return SC.W, SC.H
end

hook.Add("OnPlayerChat", "SCTags", function(ply, msg, team, dead, prefixText, col1, col2)
	if GAMEMODE.FolderName == "darkrp" then
		if SC.Rank then
			for k, v in pairs(SC.Ranks) do
				if ply:GetNWString("usergroup") == v[1] then
					chat.AddText(v[3](ply), v[2] .. " ", col1, prefixText, col2, ": " .. msg)
					return true
				end
			end
		end
		chat.AddText(col1, prefixText, col2, ": " .. msg)
		return true
	end
end)

net.Receive("SChatListen", function()
	local j = net.ReadBit()
	j = tobool(j)

	local c
	if j then
		c = "присоединенный к"
	else
		c = "отключился от"
	end
	local n = net.ReadString()
	if SC.JoinLeave then
		chat.AddText(Color(118, 132, 191), "[SChat] ", Color(255, 255, 255, 255), n .. " is ".. c .. " the server.")
	end
end)

net.Receive("SChatMsg", function()
	local str = net.ReadString()
	chat.AddText(Color(151, 211, 255), str)
end)