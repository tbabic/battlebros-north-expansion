this.barbarian_wolf_marauder <- this.inherit("scripts/entity/tactical/humans/barbarian_marauder", {
	m = {},
	
	function create()
	{
		this.barbarian_marauder.create();
	}
	
	function assignRandomEquipment()
	{
		this.barbarian_marauder.assignRandomEquipment();
		
		local items = this.m.Items;
		local armor = items.getItemAtSlot(this.Const.ItemSlot.Body)
		local upgrade = this.new("scripts/items/armor_upgrades/direwolf_pelt_upgrade");
		armor.setUpgrade(upgrade);
		items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Head));
		items.equip(this.new("scripts/items/helmets/barbarians/bear_headpiece"));
	}
});

