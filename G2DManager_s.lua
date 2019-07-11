G2DActivation = false
G2D = {}
G2D.backup = true
G2D.select = {}
addCommandHandler("dgs",function(player,command,arg)
	local account = getPlayerAccount(player)
	if account then
		local accn = getAccountName(account)
		if accn == "Console" then
			if arg == "g2d" then
				G2DActivation = not G2DActivation
				if G2DActivation then
					outputDebugString("[DGS-G2D] Initializing ...")
					outputDebugString("[DGS-G2D] Scanning Resources ...")
					outputDebugString("[DGS-G2D] Welcome To G2D ( GUI To DGS Command Line )")
				else
					outputDebugString("[DGS-G2D] Stopping ... ")
					outputDebugString("[DGS-G2D] Good Bye! Have a good time with scripts!")
				end
			end
		end
	end
end)

G2DHelp = {
	--Options,Extra,Argument,Comment
	{"-add","Resource Name","Retain selections and select other resources (Support Pattern Match)"},
	{"-bk","	","Toggle backup (Be careful)"},
	{"-c","	","Clear selections"},
	{"-h","	","G2D Help"},
	{"-s","	","Start Convert"},
	{"-sel","Resource Name","Clear selections and select other resources (Support Pattern Match)"},
	{"-l","	","List all selected resources"},
}

function table.len(tab)
	local cnt = 0
	for k,v in pairs(tab) do
		cnt = cnt+1
	end
	return cnt
end

addCommandHandler("g2d",function(player,command,...)
	local account = getPlayerAccount(player)
	if account then
		local accn = getAccountName(account)
		if accn == "Console" then
			local args = {...}
			if args[1] == "-sel" then
				if args[2] and args[2] ~= "" then
					G2D.select = {}
					for k,v in ipairs(getResources()) do
						local resN = getResourceName(v)
						if string.match(resN,args[2]) then
							G2D.select[resN] = v
						end
					end
					outputDebugString("[DGS-G2D] Selected "..table.len(G2D.select).." resources, to see the selections, use -l")
				else
					outputDebugString("[DGS-G2D] Selected 0 resources, to see the selections, use -l")
				end
			elseif args[1] == "-add" then
				if args[2] and args[2] ~= "" then
					for k,v in ipairs(getResources()) do
						local resN = getResourceName(v)
						if string.match(resN,args[2]) then
							G2D.select[resN] = v
						end
					end
					outputDebugString("[DGS-G2D] Selected "..table.len(G2D.select).." resources, to see the selections, use -l")
				else
					outputDebugString("[DGS-G2D] Selected 0 resources, to see the selections, use -l")
				end
			elseif args[1] == "-l" then
				outputDebugString("[DGS-G2D] There are "..table.len(G2D.select).." resources selected:")
				for k,v in pairs(G2D.select) do
					outputDebugString(k)
				end
			elseif args[1] == "-c" then
				G2D.select = {}
				outputDebugString("[DGS-G2D] Selections cleared!")
			elseif args[1] == "-bk" then
				G2D.backup = not G2D.backup
				outputDebugString(G2D.backup and "[DGS-G2D] Backup is enabled" or "[DGS-G2D] Backup is disabled, all operations will be irreversible!")
				
			else
				outputDebugString("[DGS-G2D] Command help")
				outputDebugString("Option		Arguments		Comment")
				for i=1,#G2DHelp do
					local items = G2DHelp[i]
					outputDebugString(items[1].."		"..items[2].."		"..items[3])
				end
			end
		end
	end
end)

G2D.ConvertTable = {









}