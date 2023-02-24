this.fathers_sword <- this.inherit("scripts/items/weapons/named/named_weapon", {
	m = {
		StunChance = 0
	},
	function create()
	{
		this.named_weapon.create();
		this.m.Variant = 3;
		this.updateVariant();
		this.m.ID = "weapon.fathers_sword";
		this.m.Name="Father\'s sword";
		this.m.Description = "This was your father\'s sword, it has no particular name, because names are for men, so they are remembered by their great deeds.";
		this.m.Categories = "Sword, Two-Handed";
		this.m.SlotType = this.Const.ItemSlot.Mainhand;
		this.m.BlockedSlotType = this.Const.ItemSlot.Offhand;
		this.m.ItemType = this.Const.Items.ItemType.Named | this.Const.Items.ItemType.Weapon | this.Const.Items.ItemType.MeleeWeapon | this.Const.Items.ItemType.TwoHanded;
		//TODO: not a named type?
		this.m.IsAgainstShields = true;
		this.m.IsAoE = true;
		this.m.AddGenericSkill = true;
		this.m.ShowQuiver = false;
		this.m.ShowArmamentIcon = true;
		this.m.Value = 500;
		this.m.ShieldDamage = 16;
		this.m.Condition = 72.0;
		this.m.ConditionMax = 72.0;
		this.m.StaminaModifier = -12;
		this.m.RegularDamage = 65;
		this.m.RegularDamageMax = 85;
		this.m.ArmorDamageMult = 1.0;
		this.m.DirectDamageMult = 0.25;
		this.m.ChanceToHitHead = 5;

	}

	function updateVariant()
	{
		this.m.IconLarge = "weapons/melee/sword_two_hand_01_named_0" + this.m.Variant + ".png";
		this.m.Icon = "weapons/melee/sword_two_hand_01_named_0" + this.m.Variant + "_70x70.png";
		this.m.ArmamentIcon = "icon_named_greatsword_0" + this.m.Variant;
	}

	function onEquip()
	{
		this.named_weapon.onEquip();
		local skillToAdd = this.new("scripts/skills/actives/overhead_strike");
		skillToAdd.setStunChance(this.m.StunChance);
		this.addSkill(skillToAdd);
		this.addSkill(this.new("scripts/skills/actives/split"));
		this.addSkill(this.new("scripts/skills/actives/swing"));
		local skillToAdd = this.new("scripts/skills/actives/split_shield");
		skillToAdd.setFatigueCost(skillToAdd.getFatigueCostRaw() + 5);
		this.addSkill(skillToAdd);
		this.m.Name="Father\'s sword";
	}

});

