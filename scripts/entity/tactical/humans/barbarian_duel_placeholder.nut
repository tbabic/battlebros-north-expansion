this.barbarian_duel_placeholder <- this.inherit("scripts/entity/tactical/human", {
	m = {},
	function create()
	{
		this.m.Type = this.Const.EntityType.BarbarianThrall;
		this.m.BloodType = this.Const.BloodType.Red;
		this.m.XP = this.Const.Tactical.Actor.BarbarianThrall.XP;
		this.human.create();
		this.m.Body = 1;
		this.m.Bodies = this.Const.Bodies.AllMale;
		this.m.Faces = ["bust_head_02"];
		this.m.Hairs = ["03"];
		this.m.HairColors = ["blonde"];
		this.m.Beards = ["12"];
		//this.m.SoundPitch = 0.95;
		//this.m.AIAgent = this.new("scripts/ai/tactical/agents/barbarian_melee_agent");
		//this.m.AIAgent.setActor(this);
	}

	function onInit()
	{
		this.human.onInit();
		local tattoos = [
			3
		];

		
		local tattoo_body = this.actor.getSprite("tattoo_body");
		local body = this.actor.getSprite("body");
		tattoo_body.setBrush("tattoo_03" + "_" + body.getBrush().Name);
		tattoo_body.Visible = true;
		
		local tattoo_head = this.actor.getSprite("tattoo_head");
		tattoo_head.setBrush("tattoo_03" + "_head");
		tattoo_head.Visible = true;
		
		this.setAppearance();
		this.getSprite("socket").setBrush("bust_base_wildmen_01");
	}
	
	function setAppearance()
	{
		if (this.m.HairColors == null)
		{
			return;
		}

		local hairColor = this.m.HairColors[this.Math.rand(0, this.m.HairColors.len() - 1)];

		if (this.m.Faces != null)
		{
			local sprite = this.getSprite("head");
			sprite.setBrush(this.m.Faces[this.Math.rand(0, this.m.Faces.len() - 1)]);
		}

		if (this.m.Hairs != null)
		{
			local sprite = this.getSprite("hair");
			sprite.setBrush("hair_" + hairColor + "_" + this.m.Hairs[this.Math.rand(0, this.m.Hairs.len() - 1)]);
		}
		else
		{
			this.getSprite("hair").Visible = false;
		}

		if (this.m.Beards != null)
		{
			local beard = this.getSprite("beard");
			beard.setBrush("beard_" + hairColor + "_" + this.m.Beards[this.Math.rand(0, this.m.Beards.len() - 1)]);
			beard.Color = this.getSprite("hair").Color;

			if (this.doesBrushExist(beard.getBrush().Name + "_top"))
			{
				local sprite = this.getSprite("beard_top");
				sprite.setBrush(beard.getBrush().Name + "_top");
				sprite.Color = this.getSprite("hair").Color;
			}
		}
		else
		{
			this.getSprite("beard").Visible = false;
		}
	}

	function assignEquipment(_level)
	{
		this.m.Items.clear();
		if(_level == 1)
		{
			this.m.Items.equip(this.new("scripts/items/weapons/barbarians/claw_club"));
			this.m.Items.equip(this.new("scripts/items/armor/barbarians/thick_furs_armor"));
		}
		
		if(_level == 2)
		{
			this.m.Items.equip(this.new("scripts/items/weapons/barbarians/blunt_cleaver"));
			this.m.Items.equip(this.new("scripts/items/armor/barbarians/hide_and_bone_armor"));
			this.m.Items.equip(this.new("scripts/items/helmets/barbarians/crude_metal_helmet"));
		}
		
		if(_level == 3)
		{
			this.m.Items.equip(this.new("scripts/items/weapons/barbarians/rusty_warblade"));
			this.m.Items.equip(this.new("scripts/items/armor/barbarians/heavy_iron_armor"));
			this.m.Items.equip(this.new("scripts/items/helmets/barbarians/crude_faceguard_helmet"));
		}
		if(_level == 4)
		{
			this.m.Items.equip(this.new("scripts/items/weapons/named/named_skullhammer"));
			this.m.Items.equip(this.new("scripts/items/armor/named/named_skull_and_chain_armor"));
			this.m.Items.equip(this.new("scripts/items/helmets/named/named_metal_bull_helmet"));
		}
		
	}
	
	function assignRandomEquipment()
	{
		
	}

});

