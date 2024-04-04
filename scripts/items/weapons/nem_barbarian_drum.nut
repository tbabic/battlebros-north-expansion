this.nem_barbarian_drum <- this.inherit("scripts/items/weapons/weapon", {
	m = {},
	function create()
	{
		this.weapon.create();
		this.m.ID = "weapon.nem_barbarian_drum";
		this.m.Name = "Drum";
		this.m.Description = "The rhythmic beats of the drum will have allies press on despite exhaustion.";
		this.m.SlotType = this.Const.ItemSlot.Mainhand;
		this.m.BlockedSlotType = this.Const.ItemSlot.Offhand;
		this.m.ItemType = this.Const.Items.ItemType.Weapon | this.Const.Items.ItemType.RangedWeapon | this.Const.Items.ItemType.TwoHanded | this.Const.Items.ItemType.Misc;
		this.m.IsDroppedAsLoot = true;
		this.m.IsIndestructible = true;
		this.m.AddGenericSkill = true;
		this.m.ShowQuiver = false;
		this.m.ShowArmamentIcon = true;
		this.m.ArmamentIcon = "icon_wildmen_10";
		this.m.RangeMin = 1;
		this.m.RangeMax = 6;
		this.m.RangeIdeal = 6;
		this.m.Value = 10;
		this.m.StaminaModifier = 5;
		this.m.RegularDamage = 0;
		this.m.RegularDamageMax = 0;
		this.m.ArmorDamageMult = 0.0;
		this.m.DirectDamageMult = 0.0;
	}

	function onEquip()
	{
		this.weapon.onEquip();
		this.addSkill(this.new("scripts/skills/actives/barbarian_drum_skill"));
	}

});

