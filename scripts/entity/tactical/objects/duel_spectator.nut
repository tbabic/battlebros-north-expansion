this.duel_spectator <- this.inherit("scripts/entity/tactical/entity", {
	m = {},
	function getName()
	{
		return "Shielbearer";
	}

	function getDescription()
	{
		return "A man holding a shield for the duel.";
	}

	function setFlipped( _flip )
	{
		this.getSprite("body").setHorizontalFlipping(_flip);
		this.getSprite("head").setHorizontalFlipping(_flip);
		if (this.hasSprite("beard"))
		{
			this.getSprite("beard").setHorizontalFlipping(_flip);
		}
		
		if (this.hasSprite("armor"))
		{
			this.getSprite("armor").setHorizontalFlipping(_flip);
		}
		
		if (this.hasSprite("helmet"))
		{
			this.getSprite("helmet").setHorizontalFlipping(_flip);
		}
		this.getSprite("shield_icon").setHorizontalFlipping(_flip);
		
		if (this.hasSprite("hair"))
		{
			this.getSprite("hair").setHorizontalFlipping(_flip);
		}
		
		if (this.hasSprite("beard_top"))
		{
			this.getSprite("beard_top").setHorizontalFlipping(_flip);
		}
		
		
		if (this.hasSprite("tattoo_body"))
		{
			this.getSprite("tattoo_body").setHorizontalFlipping(_flip);
		}
		
		if (this.hasSprite("tattoo_head"))
		{
			this.getSprite("tattoo_head").setHorizontalFlipping(_flip);
		}
	}

	function onInit()
	{
		this.m.IsAttackable = false;
		local bodyBrush = this.Const.Bodies.AllMale[this.Math.rand(0, this.Const.Bodies.AllMale.len() - 1)];
		local body = this.addSprite("body");
		body.setBrush(bodyBrush);
		body.varyColor(0.05, 0.05, 0.05);
		body.varySaturation(0.1);
		
		local tattoos = [
			"tattoo_02",
			"tattoo_03",
			"tattoo_04",
			"tattoo_05",
			"tattoo_06",
			"warpaint_02",
			"warpaint_03"
		];
		local tattoo = tattoos[this.Math.rand(0, tattoos.len() - 1)];
		
		if (this.Math.rand(1, 100) <= 66)
		{
			local tattoo_body = this.addSprite("tattoo_body");
			tattoo_body.setBrush(tattoo + "_" + bodyBrush);
			tattoo_body.Visible = true;
		}
		
		
		local armors = [];
		local helmets = [];
		local r = this.Math.rand(1, 100);
		if (r < 60)
		{
			armors.push("");
			armors.push("bust_body_90");
			armors.push("bust_body_91");
			
			helmets.push("");
			helmets.push("bust_helmet_187");
			helmets.push("bust_helmet_188");
			helmets.push("bust_helmet_190");
			
		}
		else if(r < 95)
		{
			armors.push("bust_body_92");
			armors.push("bust_body_94");
			armors.push("bust_body_97");
			
			helmets.push("");
			helmets.push("bust_helmet_187");
			helmets.push("bust_helmet_188");
			helmets.push("bust_helmet_190");
			helmets.push("bust_helmet_189");
			helmets.push("bust_helmet_196");
		}
		else
		{
			armors.push("bust_body_93");
			armors.push("bust_body_95");
			armors.push("bust_body_96");
			
			helmets.push("bust_helmet_191");
			helmets.push("bust_helmet_192");
			helmets.push("bust_helmet_194");
			helmets.push("bust_helmet_197");
		}
		
		local armorBrush = armors[this.Math.rand(0, armors.len() - 1)];
		
		if (armorBrush != "")
		{
			local armor = this.addSprite("armor");
			armor.setBrush(armorBrush);
			armor.Visible = true;
		}
		
		
		
		
		local head = this.addSprite("head");
		head.setBrush(this.Const.Faces.WildMale[this.Math.rand(0, this.Const.Faces.WildMale.len() - 1)]);
		head.Color = body.Color;
		head.Saturation = body.Saturation;
		
		if (this.hasSprite("tattoo_body"))
		{
			local tattoo_head = this.addSprite("tattoo_head");
			tattoo_head.setBrush(tattoo + "_head");
			tattoo_head.Visible = true;
		}
		

		local hair = this.addSprite("hair");
		local hairColor = this.Const.HairColors.All[this.Math.rand(0,this.Const.HairColors.All.len()-1)];
		if (this.Math.rand(1, 100) <= 95)
		{
			hair.setBrush("hair_" + hairColor + "_" + this.Const.Hair.WildMale[this.Math.rand(0, this.Const.Hair.WildMale.len() - 1)]);
		}
		
		local beard = this.addSprite("beard");
		if (this.Math.rand(1, 100) <= 60)
		{
			beard.setBrush("beard_" + hairColor + "_" + this.Const.Beards.WildExtended[this.Math.rand(0, this.Const.Beards.WildExtended.len() - 1)]);
			local beard_top = this.addSprite("beard_top");

			if (beard.HasBrush && this.doesBrushExist(beard.getBrush().Name + "_top"))
			{
				beard_top.setBrush(beard.getBrush().Name + "_top");
			}
		}
		
		local helmetBrush = helmets[this.Math.rand(0, helmets.len() - 1)];
		if (helmetBrush != "")
		{
			local helmet = this.addSprite("helmet");
			helmet.setBrush(helmetBrush);
			helmet.Visible = true;			
		}
		local hideHair = ["bust_helmet_189","bust_helmet_190", "bust_helmet_191", "bust_helmet_192", "bust_helmet_194", "bust_helmet_196", "bust_helmet_197"];
		local hideBeard = ["bust_helmet_191", "bust_helmet_192", "bust_helmet_194", "bust_helmet_197"]
		if (hideHair.find(helmetBrush) != null && this.hasSprite("hair"))
		{
			this.removeSprite("hair");
		}
		if (hideBeard.find(helmetBrush) != null && this.hasSprite("beard"))
		{
			this.removeSprite("beard");
		}
		
		local shield = this.addSprite("shield_icon");
		shield.setBrush("shield_round_0" + this.Math.rand(0, 9));
		shield.Visible = true;
	}

});

