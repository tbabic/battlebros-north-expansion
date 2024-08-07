this.threetrees_shield <- this.inherit("scripts/items/shields/named/named_shield", {
	m = {},
	function create()
	{
		this.named_shield.create();
		this.m.Variant = 1;
		this.updateVariant();
		this.m.ID = "shield.threetrees";
		this.m.Name = "Three Trees Shield";
		this.m.Description = "A large round wooden shield made of three different trees for extra durability";
		this.m.AddGenericSkill = true;
		this.m.ShowOnCharacter = true;
		this.m.Value = 600;
		this.m.MeleeDefense = 20;
		this.m.RangedDefense = 15;
		this.m.StaminaModifier = -10;
		this.m.Condition = 60;
		this.m.ConditionMax = 60;
	}

	function updateVariant()
	{
		this.m.Sprite = "icon_shield_threetrees";
		this.m.SpriteDamaged = "icon_shield_threetrees_damaged";
		this.m.ShieldDecal = "";
		this.m.IconLarge = "shields/shield_threetrees_equipped.png";
		this.m.Icon = "shields/shield_threetrees.png";
	}

	function onEquip()
	{
		this.named_shield.onEquip();
		this.addSkill(this.new("scripts/skills/actives/shieldwall"));
		this.addSkill(this.new("scripts/skills/actives/knock_back"));
	}
	
	function isDroppedAsLoot()
	{
		return true;
	}

});

