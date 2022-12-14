local cmdlist = {

	r_shadowrendertotexture = { 0, GetConVarNumber },

	r_shadowmaxrendered = { 0, GetConVarNumber },

	mat_shadowstate = { 0, GetConVarNumber },

	cl_phys_props_enable = { 0, GetConVarNumber },

	cl_phys_props_max = { 0, GetConVarNumber },

	props_break_max_pieces = { 0, GetConVarNumber },

	r_propsmaxdist = { 0, GetConVarNumber },

	r_drawmodeldecals = { 0, GetConVarNumber },

	cl_threaded_bone_setup = { 1, GetConVarNumber },

	cl_threaded_client_leaf_system = { 1, GetConVarNumber },

	r_threaded_client_shadow_manager = { 1, GetConVarNumber },

	r_threaded_particles = { 1, GetConVarNumber },

	r_threaded_renderables = { 1, GetConVarNumber },

	r_queued_ropes = { 1, GetConVarNumber },

	studio_queue_mode = { 1, GetConVarNumber },

	mat_queue_mode = { 2, GetConVarNumber },

	gmod_mcore_test = { 1, GetConVarNumber },
}

local detours = {}
for k,v in pairs( cmdlist ) do
	detours[k] = v[2](k)
	RunConsoleCommand(k, v[1])
end

hook.Add( 'ShutDown', 'roll back convars', function()
	for k,v in pairs(detours) do

		RunConsoleCommand(k,v)
	end
end)


hook.Add("MouthMoveAnimation", "Optimization", function() return nil end)
hook.Add("GrabEarAnimation", "Optimization", function() return nil end)
hook.Add("HandlePlayerVaulting", "Optimization", function() return nil end)
hook.Add("HandlePlayerNoClipping", "Optimization", function() return nil end)
hook.Add("PlayerDriveAnimate", "Optimization", function() return nil end)