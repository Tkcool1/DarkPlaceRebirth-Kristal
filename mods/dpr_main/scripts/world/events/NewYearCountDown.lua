local NewYearCountDown, super = Class(Event)
function NewYearCountDown:init(x, y)
    super.init(self, x or 80, y or 100, 60*2, 46*2)

    self.board = Sprite("world/events/new_years_board")
    self:addChild(self.board)

    self.board:setScale(2)

    self.text = Text("")
    self.text.y = 22
    self.text.x = 14
    self:addChild(self.text)
    self.text:setColor(0, 0.5, 1)

    self.text.debug_select = false
    self.board.debug_select = false

    --self:setHitbox(0, 0, 60*2, 46*2)
    --self.debug_select = true
end

function NewYearCountDown:update()
    super.update(self)

    local time = os.date("*t")

    if time.month ~= 12 then
        self:remove()
    elseif time.month == 1 and time.sec > 0 then
        self:explode()
    else
        --self.text:setText("00:00:00")
        local seconds = 60 - time.sec
	    if seconds == 60 then
            seconds = "00"
	    elseif seconds < 10 then
            seconds = "0".. seconds
	    end

        local minutes = 60 - time.min
	    if minutes == 60 then
            minutes = "00"
	    elseif minutes < 10 then
            minutes = "0".. minutes
	    end

        local hours = 24 - time.hour
	    if hours == 24 then
            hours = "00"
	    elseif hours < 10 then
            hours = "0".. hours 
	    end
	
        self.text:setText(hours ..":".. minutes ..":".. seconds)
    end
end

return NewYearCountDown
