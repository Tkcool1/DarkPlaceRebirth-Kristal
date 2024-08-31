---@class MainMenuDLCHandler : StateClass
---
---@field menu MainMenu
---
---@overload fun(menu:MainMenu) : MainMenuDLCHandler
local MainMenuDLCHandler, super = Class(StateClass)

function MainMenuDLCHandler:init(menu)
    self.menu = menu

    self.list = nil

    self.dlcs = {}

    -- Networking stuff I guess??
    self.loading_dlcs = false
    self.loading_list = {}
    self.loading_type = "mod.json"
    self.loading_queue_index = 0
    self.send_request = false

    self.loading_errors = {}

    self.active = false
end

function MainMenuDLCHandler:registerEvents()
    self:registerEvent("enter", self.onEnter)
    self:registerEvent("leave", self.onLeave)
    self:registerEvent("keypressed", self.onKeyPressed)
    self:registerEvent("update", self.update)
    self:registerEvent("draw", self.draw)
end

function MainMenuDLCHandler:onEnter()
	print("onEnter")
	self.active = true

	self.menu.heart_target_x = -16
	self.menu.heart_target_y = -16

	if not self.list then
		print("Build the DLC list")
		self:buildDLCList()
	end
end

function MainMenuDLCHandler:onLeave()
	self.active = false

	if self.list then
        self.list.active = false
        self.list.visible = false
    end
end

function MainMenuDLCHandler:update()
	if self.loading_dlcs then
		if not self.send_request then
			if self.loading_queue_index > 0 then
				self.send_request = true
				print(self.loading_list[self.loading_queue_index].url, self.loading_queue_index)
				--[[Kristal.Stage.timer:after(2, function()
					print(200)
					self.send_request = false
					self.loading_queue_index = self.loading_queue_index - 1
				end)]]
				local ok = Kristal.fetch(self.loading_list[self.loading_queue_index].url, {
				callback=function(res, body, headers)
					-- Good
					print(res)
					if res == 200 then
						local data = JSON.decode(body)
						local content = JSON.decode(Utils.decodeBase64(data.content))
						Kristal.Mods.dlc_data_cached[content.id] = content
						Kristal.Mods.dlc_data_cached[content.id].repo_data = {
							owner=self.loading_list[self.loading_queue_index].owner,
							repo=self.loading_list[self.loading_queue_index].repo
						}
					else -- fuck | TODO: retry a few times if the response isn't 404
						table.insert(self.loading_errors, {
							owner=self.loading_list[self.loading_queue_index].owner,
							repo=self.loading_list[self.loading_queue_index].repo,
							response=res,
							message=JSON.decode(body).message
						})
					end
					self.send_request = false
					self.loading_queue_index = self.loading_queue_index - 1
				end})
				if not ok then
					table.insert(self.loading_errors, {
						owner=self.loading_list[self.loading_queue_index].owner,
						repo=self.loading_list[self.loading_queue_index].repo,
						response=nil,
						message="HTTPS failed. Is it available?"
					})
					self.send_request = false
					self.loading_queue_index = self.loading_queue_index - 1
				end
			else
				if #self.loading_errors > 0 then
    				for i,msg in ipairs(self.loading_errors) do
	    				print("An error occured with "..msg.owner.."'s repo \""..msg.repo.."\".\nResponse code: "..msg.response.."\nMessage: "..msg.message)
    				end
    			end
    			self.loading_dlcs = false
    			love.filesystem.write("dlc_data.json", JSON.encode(Kristal.Mods.dlc_data_cached))
			end
		end
	end
end

function MainMenuDLCHandler:onKeyPressed(key, is_repeat)
	if self.loading_dlcs then return end
	if Input.isConfirm(key) and not is_repeat then
		Assets.stopAndPlaySound("ui_select")
		love.system.openURL("file://"..love.filesystem.getSaveDirectory().."/mods")
	elseif Input.isCancel(key) then
		Assets.stopAndPlaySound("ui_move")

        self.menu:setState("TITLE")
        self.menu.title_screen:selectOption("dlc")
        return true
    elseif Input.ctrl() and key == "f5" then
    	local force = Input.alt()
    	self:buildDLCList(force)
    end
end

function MainMenuDLCHandler:draw()
	Draw.setColor(COLORS.silver)
    Draw.printShadow("( DLC HANDLER )", 0, 0, 2, "center", 640)

    if self.loading_dlcs then
    	Draw.setColor(COLORS.white)
    	Draw.printShadow("Downloading data... "..Utils.round(100-(self.loading_queue_index*100/#self.loading_list)).."%", 0, (SCREEN_HEIGHT/2)-15, 2, "center", 640)

    	Draw.setColor(COLORS.silver)
    	Draw.rectangle("fill", 150, (SCREEN_HEIGHT/2)+15, 250, 20)
    	Draw.setColor(COLORS.green)
    	Draw.rectangle("fill", 150, (SCREEN_HEIGHT/2)+15, 250-(250*self.loading_queue_index/#self.loading_list), 20)
    	return
    end

    Draw.setColor(COLORS.white)
	Draw.printShadow("Work In Progress!", 0, 115 + 30, 2, "center", 640)
	Draw.printShadow("Come back later!", 0, 115 + 30*2, 2, "center", 640)

	Draw.printShadow("Press "..Input.getText("confirm").." to open the DLC folder.", 0, 115 + 30*4, 2, "center", 640)
	Draw.printShadow("Press "..Input.getText("cancel").." to return", 0, 115 + 30*5, 2, "center", 640)

	local r, g, b = COLORS.silver
	Draw.setColor(r, g, b, 0.5)
	Draw.rectangle("fill", 20, 48, 280, SCREEN_HEIGHT-48-10)

	Draw.rectangle("fill", 310, 48, 320, 240)

	Draw.rectangle("fill", 310, 240+48+10, 320, SCREEN_HEIGHT-(240+48+10)-10)
end

function MainMenuDLCHandler:checkForNewDLCs()

	local function inGitList(owner, repo)
		if not GITHUB_REPOS[owner] then return false end

		for i,v in ipairs(GITHUB_REPOS[owner]) do
			if v == repo then
				return true
			end
		end
		return false
	end

	local new_dlcs = {}

	for id,data in pairs(Kristal.Mods.dlc_data_cached) do
		if not inGitList(data.repo_data.owner, data.repo_data.repo) then
			if not new_dlcs[data.repo_data.owner] then
				new_dlcs[data.repo_data.owner] = {}
			end
			table.insert(new_dlcs[data.repo_data.owner], data.repo_data.repo)
		end
	end
	return #new_dlcs>0, new_dlcs
end

function MainMenuDLCHandler:buildDLCList(reset_cache)
	self.loading_list = {}
	self.loading_type = "mod.json"

	local url_list = GITHUB_REPOS

	if not self.list then
		print("Creating List")
		self.list = ModList(20, 48, 280, SCREEN_HEIGHT-48-10)
		self.list.layer = 50
    	self.menu.stage:addChild(self.list)
    else
    	print("Clearing List")
    	self.list:clearMods()
    end

    if reset_cache then
    	print("Reset cache")
    	love.filesystem.remove("dlc_data.json")
    	Kristal.Mods.dlc_data_cached = {}
    else
    	print("Try to load cache")
    	if love.filesystem.getInfo("dlc_data.json") then
    		print("Cache found, loading...")
    		Kristal.Mods.dlc_data_cached = JSON.decode(love.filesystem.read("dlc_data.json"))
    		local new, list = self:checkForNewDLCs()
    		if not new then return end
    		print("New DLCs found")
    		url_list = list
    	end
    end

    -- Put all the repos we're gonna get data from in a list for update
    for owner,repos in pairs(url_list) do
    	for i,repo in ipairs(repos) do
    		print("Add repo "..repo)
    		table.insert(self.loading_list, {
    			owner=owner,
    			repo=repo,
    			url="https://api.github.com/repos/"..owner.."/"..repo.."/contents/mod.json"
    		})
    		self.loading_queue_index = self.loading_queue_index + 1
    	end
    end

    self.loading_dlcs = true

	--[[Kristal.fetch(
		"https://api.github.com/repos/Simbel0/Dark-Place/contents/mod.json",
	{
		callback=function(a, b, c)
			print("response:"..a)
			print("body:"..b)
			BODY=b
			print("headers:"..c)
		end
	}
	)]]
end

return MainMenuDLCHandler