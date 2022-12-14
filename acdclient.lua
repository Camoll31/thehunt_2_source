	if (CLIENT) then
		timer.Create("ClearDecals", 500, 0, function()
		RunConsoleCommand("r_cleardecals", "")
		end)
	end