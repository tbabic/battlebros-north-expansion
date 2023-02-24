this.longclaw <- this.inherit("scripts/items/weapons/named/named_weapon", {
	m = {},
	function create()
	{
		this.named_weapon.create();
		this.m.Variant = 1;
		this.updateVariant();
		this.m.ID = "weapon.longclaw";
		this.m.Name = "Long Claw";
		this.m.Description = "A bastard or hand and a half sword made out of dark metal with a wolf's head for a pommel. Sharper and more durable than any normal sword, it can cut through armor with ease.";
		this.m.Categories = "Sword, One-Handed";
		this.m.SlotType = this.Const.ItemSlot.Mainhand;
		this.m.ItemType = this.Const.Items.ItemType.Named | this.Const.Items.ItemType.Weapon | this.Const.Items.ItemType.MeleeWeapon | this.Const.Items.ItemType.OneHanded;
		this.m.IsDoubleGrippable = true;
		this.m.AddGenericSkill = true;
		this.m.ShowQuiver = false;
		this.m.ShowArmamentIcon = true;
		this.m.Condition = 100;
		this.m.ConditionMax = 100;
		this.m.StaminaModifier = -8;
		this.m.Value = 6200;
		this.m.RegularDamage = 45;
		this.m.RegularDamageMax = 50;
		this.m.ArmorDamageMult = 1;
		this.m.DirectDamageMult = 0.36;
	}

	function updateVariant()
	{
		this.m.IconLarge = "weapons/melee/longclaw.png";
		this.m.Icon = "weapons/melee/longclaw_70x70.png";
		this.m.ArmamentIcon = "icon_named_sword_01";
	}

	function onEquip()
	{
		this.named_weapon.onEquip();
		this.addSkill(this.new("scripts/skills/actives/slash"));
		this.addSkill(this.new("scripts/skills/actives/riposte"));
	}

});

