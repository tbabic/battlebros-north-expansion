this.barbarian_market_building <- this.inherit("scripts/entity/world/settlements/buildings/marketplace_building", {
	m = {
	},
	function create()
	{
		this.marketplace_building.create();
		this.m.IsRepairOffered = true;
	}

	function onUpdateShopList()
	{
		local list = [
			//weapons
			{
				R = 10,
				P = 1.0,
				S = "weapons/barbarians/antler_cleaver"
			},
			{
				R = 20,
				P = 1.0,
				S = "weapons/militia_spear"
			},
			{
				R = 20,
				P = 1.0,
				S = "weapons/barbarians/blunt_cleaver"
			},
			{
				R = 10,
				P = 1.0,
				S = "weapons/knife"
			},
			{
				R = 10,
				P = 1.0,
				S = "weapons/barbarians/claw_club"
			},
			{
				R = 20,
				P = 1.0,
				S = "weapons/barbarians/crude_axe"
			},
			{
				R = 30,
				P = 1.0,
				S = "weapons/barbarians/heavy_javelin"
			},
			{
				R = 20,
				P = 1.0,
				S = "weapons/javelin"
			},
			{
				R = 30,
				P = 1.0,
				S = "weapons/barbarians/heavy_throwing_axe"
			},
			{
				R = 70,
				P = 1.0,
				S = "weapons/barbarians/heavy_rusty_axe"
			},
			{
				R = 70,
				P = 1.0,
				S = "weapons/barbarians/rusty_warblade"
			},
			{
				R = 70,
				P = 1.0,
				S = "weapons/barbarians/skull_hammer"
			},
			{
				R = 70,
				P = 1.0,
				S = "weapons/barbarians/two_handed_spiked_mace"
			},
			{
				R = 90,
				P = 1.0,
				S = "weapons/crude_polearm"
			},
			//armors
			{
				R = 10,
				P = 1.0,
				S = "armor/barbarians/thick_furs_armor"
			},
			{
				R = 10,
				P = 1.0,
				S = "armor/barbarians/animal_hide_armor"
			},
			{
				R = 20,
				P = 1.0,
				S = "armor/barbarians/reinforced_animal_hide_armor"
			},
			{
				R = 30,
				P = 1.0,
				S = "armor/barbarians/scrap_metal_armor"
			},
			{
				R = 30,
				P = 1.0,
				S = "armor/barbarians/hide_and_bone_armor"
			},
			{
				R = 50,
				P = 1.0,
				S = "armor/barbarians/rugged_scale_armor"
			},
			{
				R = 50,
				P = 1.0,
				S = "armor/barbarians/heavy_iron_armor"
			},
			
			{
				R = 70,
				P = 1.0,
				S = "armor/barbarians/thick_plated_barbarian_armor"
			},
			//helmets
			{
				R = 10,
				P = 1.0,
				S = "helmets/barbarians/bear_headpiece"
			},
			{
				R = 50,
				P = 1.0,
				S = "helmets/barbarians/beastmasters_headpiece"
			},
			{
				R = 50,
				P = 1.0,
				S = "helmets/barbarians/closed_scrap_metal_helmet"
			},
			{
				R = 50,
				P = 1.0,
				S = "helmets/barbarians/crude_faceguard_helmet"
			},
			{
				R = 30,
				P = 1.0,
				S = "helmets/barbarians/crude_metal_helmet"
			},
			{
				R = 70,
				P = 1.0,
				S = "helmets/barbarians/heavy_horned_plate_helmet"
			},
			{
				R = 10,
				P = 1.0,
				S = "helmets/barbarians/leather_headband"
			},
			{
				R = 30,
				P = 1.0,
				S = "helmets/barbarians/leather_helmet"
			},
			{
				R = 70,
				P = 1.0,
				S = "helmets/nordic_helmet"
			},
			{
				R = 80,
				P = 1.0,
				S = "helmets/nordic_helmet_with_closed_mail"
			},
			//other
			
			{
				R = 10,
				P = 1.0,
				S = "shields/wooden_shield_old"
			},
			{
				R = 10,
				P = 1.0,
				S = "supplies/medicine_item"
			},
			{
				R = 0,
				P = 1.0,
				S = "supplies/ammo_item"
			},
			{
				R = 10,
				P = 1.0,
				S = "supplies/armor_parts_item"
			},
			{
				R = 50,
				P = 1.0,
				S = "supplies/armor_parts_item"
			},
			{
				R = 10,
				P = 1.0,
				S = "accessory/bandage_item"
			}
		];
		
		foreach( i in this.Const.Items.NamedBarbarianArmors )
		{
			if (this.Math.rand(1, 100) <= 33)
			{
				list.push({
					R = 99,
					P = 2.0,
					S = i
				});
			}
		}

		foreach( i in this.Const.Items.NamedBarbarianHelmets )
		{
			if (this.Math.rand(1, 100) <= 33)
			{
				list.push({
					R = 99,
					P = 2.0,
					S = i
				});
			}
		}
		
		foreach( i in this.Const.Items.NamedBarbarianWeapons )
		{
			if (this.Math.rand(1, 100) <= 30)
			{
				list.push({
					R = 99,
					P = 2.0,
					S = i
				});
			}
		}
		
		if (this.Math.rand(1, 100) <= 30)
		{
			list.push({
				R = 99,
				P = 2.0,
				S = "weapons/named/named_crude_polearm"
			});
		}
		
		local norseNamedItems = [
			"helmets/named/wolf_helmet",
			"helmets/named/norse_helmet",
			"helmets/named/named_nordic_helmet_with_closed_mail"
			"weapons/named/named_javelin",
			"weapons/named/named_throwing_axe"
		];
		
		foreach( i in norseNamedItems )
		{
			if (this.Math.rand(1, 100) <= 33)
			{
				list.push({
					R = 99,
					P = 2.0,
					S = i
				});
			}
		}
		
		list.push({
			R = 10,
			P = 1.0,
			S = "supplies/roots_and_berries_item"
		});
		list.push({
			R = 10,
			P = 1.0,
			S = "supplies/roots_and_berries_item"
		});
		
		list.push({
			R = 70,
			P = 1.0,
			S = "supplies/ground_grains_item"
		});
		list.push({
			R = 50,
			P = 1.0,
			S = "supplies/bread_item"
		});
		
		list.push({
			R = 60,
			P = 1.0,
			S = "supplies/cured_venison_item"
		});
		
		list.push({
			R = 40,
			P = 1.0,
			S = "supplies/pickled_mushrooms_item"
		});
		
		list.push({
			R = 50,
			P = 1.0,
			S = "accessory/warhound_item"
		});

		if (this.m.Settlement.m.CampSize >= 2)
		{
			list.push({
				R = 50,
				P = 1.0,
				S = "supplies/medicine_item"
			});
			list.push({
				R = 50,
				P = 1.0,
				S = "supplies/armor_parts_item"
			});
			
			list.push({
				R = 50,
				P = 1.0,
				S = "supplies/cured_venison_item"
			});
			
			list.push({
				R = 50,
				P = 1.0,
				S = "supplies/goat_cheese_item"
			});
		}

		if (this.m.Settlement.m.CampSize >= 3)
		{
			list.push({
				R = 20,
				P = 1.0,
				S = "supplies/mead_item"
			});
			
			list.push({
				R = 50,
				P = 1.0,
				S = "supplies/beer_item"
			});
			
			list.push({
				R = 20,
				P = 1.0,
				S = "accessory/warhound_item"
			});
		}
		
		
		
		

		
		this.fillStash(list, this.m.Stash, 1.0, true);
		
		logInfo("stash list size:"  + list.len());
		logInfo("stash size:"  + this.m.Stash.getItems().len());
	}
	
	function onClicked( _townScreen )
	{
		this.logInfo("on click: " + this.m.Stash.getItems().len());
		foreach( item in this.m.Stash.getItems() )
		{
			if (item != null)
			{
				this.logInfo("item: " + item.getName());
			}
		}
		
		_townScreen.getShopDialogModule().setShop(this);
		_townScreen.showShopDialog();
		this.pushUIMenuStack();
	}

});

