local item, super = Class(Item, "nazrin_fumo")

function item:init()
    super.init(self)

    -- Display name
    self.name = "Nazrin Fumo"
    -- Name displayed when used in battle (optional)
    self.use_name = nil

    -- Item type (item, key, weapon, armor)
    self.type = "key"
    -- Item icon (for equipment)
    self.icon = nil

    -- Battle description
    self.effect = ""
    -- Shop description
    self.shop = "This mice\nis CRIMINAL\nGet it away\nfrom me."
    -- Menu description
    self.description = "A plush despicting a cute mice.\nAllows you to fuse objects."

    -- Default shop price (sell price is halved)
    self.price = 0
    -- Whether the item can be sold
    self.can_sell = false

    -- Consumable target mode (ally, party, enemy, enemies, or none)
    self.target = "none"
    -- Where this item can be used (world, battle, all, or none)
    self.usable_in = "world"
    -- Item this item will get turned into when consumed
    self.result_item = nil
    -- Will this item be instantly consumed in battles?
    self.instant = false

    -- Equip bonuses (for weapons and armor)
    self.bonuses = {}
    -- Bonus name and icon (displayed in equip menu)
    self.bonus_name = nil
    self.bonus_icon = nil

    -- Equippable characters (default true for armors, false for weapons)
    self.can_equip = {}

    -- Character reactions (key = party member id)
    self.reactions = {}
end

function item:onWorldUse()
    -- Delay by one frame for compatibility with Suzy
    Game.world:startCutscene(function(cutscene)
        if not Game:getFlag("nazrinpissed") then
            Game.world.timer:after(0, function()
                Game.world:openMenu(FuseMenu())
            end)
        else
            cutscene:text("* Nazrin refuses.")
            cutscene:text("* Maybe you can redeem yourself at a Nazrin shrine?")
        end
    end)
    return false
end
function item:convertToLight(inventory)
    return "light/nazrin"
end

return item