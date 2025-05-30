local item, super = Class(HealItem, "lampoil")

function item:init()
    super.init(self)

    -- Display name
    self.name = "Lamp Oil"
    -- Name displayed when used in battle (optional)
    self.use_name = "Lamp Oil"

    -- Item type (item, key, weapon, armor)
    self.type = "item"
    -- Item icon (for equipment)
    self.icon = nil

    -- Battle description
    self.effect = "Healing\ngreatly\nvaries"
    -- Shop description
    self.shop = "Is this\nreally food?\nHealing\nvaries."
    -- Menu description
    self.description = "It's pretty tasty, and all things considered,\nnot the WORST way to go out. Heals +??HP"

    -- Amount this item heals for specific characters
    self.heal_amounts = {
        ["kris"] = 20,
        ["susie"] = 80,
        ["ralsei"] = -50,
        ["noelle"] = nil,
		["dess"] = 90,
        ["brenda"] = nil,
		["jamm"] = -50,
        ["noel"] = -100,
        ["ceroba"] = nil,
        ["hero"] = 50
	}

    -- Default shop price (sell price is halved)
    self.price = 40
    -- Whether the item can be sold
    self.can_sell = true

    -- Consumable target mode (party, enemy, noselect, or none/nil)
    self.target = "ally"
    -- Where this item can be used (world, battle, all, or none/nil)
    self.usable_in = "all"
    -- Item this item will get turned into when consumed
    self.result_item = nil
    -- Will this item be instantly consumed in battles?
    self.instant = false

    -- Character reactions (key = party member id)

    self.reactions = {
        susie = "Cough! Cough! It's tasty?!",
        ralsei = "Cough! Cough! How is this edible?!",
        noelle = "Isn't this poisonous!?",
		dess = "yummy",
        brenda = "No.",
		jamm = "Not the first time I drank oil. Ow, though...",
		noel = "[color:red]kill me...",
        ceroba = "I'm NOT drinking OIL!",
        hero = "Not the worst thing I've consumed."
	}
end

-- Function overrides go here

function item:onWorldUse(target)
	if target.id == "noelle" or target.id == "brenda" or target.id == "ceroba" then
		return false
    else
        return super.onWorldUse(self, target)
	end
end

return item