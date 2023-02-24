this.barbarian_market_building <- this.inherit("scripts/entity/world/settlements/buildings/building", {
	m = {
		Stash = null
	},
	function getStash()
	{
		return this.m.Stash;
	}

	function create()
	{
		this.building.create();
		this.m.ID = "building.marketplace";
		this.m.Name = "Marketplace";
		this.m.Description = "A lively market offering all sorts of goods common in the region";
		this.m.UIImage = "ui/settlements/building_06";
		this.m.UIImageNight = "ui/settlements/building_06_night";
		this.m.Tooltip = "world-town-screen.main-dialog-module.Marketplace";
		this.m.Stash = this.new("scripts/items/stash_container");
		this.m.Stash.setID("shop");
		this.m.Stash.setResizable(true);
		this.m.Sounds = [
			{
				File = "ambience/buildings/market_people_00.wav",
				Volume = 0.4,
				Pitch = 1.0
			},
			{
				File = "ambience/buildings/market_people_01.wav",
				Volume = 0.6,
				Pitch = 1.0
			},
			{
				File = "ambience/buildings/market_people_02.wav",
				Volume = 0.8,
				Pitch = 1.0
			},
			{
				File = "ambience/buildings/market_people_03.wav",
				Volume = 0.8,
				Pitch = 1.0
			},
			{
				File = "ambience/buildings/market_people_04.wav",
				Volume = 0.8,
				Pitch = 1.0
			},
			{
				File = "ambience/buildings/market_people_05.wav",
				Volume = 0.8,
				Pitch = 1.0
			},
			{
				File = "ambience/buildings/market_people_07.wav",
				Volume = 0.8,
				Pitch = 1.0
			},
			{
				File = "ambience/buildings/market_people_08.wav",
				Volume = 0.8,
				Pitch = 1.0
			},
			{
				File = "ambience/buildings/market_people_09.wav",
				Volume = 0.8,
				Pitch = 1.0
			},
			{
				File = "ambience/buildings/market_people_10.wav",
				Volume = 0.8,
				Pitch = 1.0
			},
			{
				File = "ambience/buildings/market_people_11.wav",
				Volume = 0.8,
				Pitch = 1.0
			},
			{
				File = "ambience/buildings/market_people_12.wav",
				Volume = 0.8,
				Pitch = 1.0
			},
			{
				File = "ambience/buildings/market_people_13.wav",
				Volume = 0.8,
				Pitch = 1.0
			},
			{
				File = "ambience/buildings/market_people_14.wav",
				Volume = 0.8,
				Pitch = 1.0
			},
			{
				File = "ambience/buildings/market_pig_00.wav",
				Volume = 0.9,
				Pitch = 1.0
			},
			{
				File = "ambience/buildings/market_pig_01.wav",
				Volume = 0.9,
				Pitch = 1.0
			},
			{
				File = "ambience/buildings/market_pig_02.wav",
				Volume = 0.9,
				Pitch = 1.0
			},
			{
				File = "ambience/buildings/market_pig_03.wav",
				Volume = 0.9,
				Pitch = 1.0
			},
			{
				File = "ambience/buildings/market_pig_04.wav",
				Volume = 0.9,
				Pitch = 1.0
			},
			{
				File = "ambience/buildings/market_chicken_00.wav",
				Volume = 0.9,
				Pitch = 1.0
			},
			{
				File = "ambience/buildings/market_chicken_01.wav",
				Volume = 0.9,
				Pitch = 1.0
			},
			{
				File = "ambience/buildings/market_chicken_02.wav",
				Volume = 0.9,
				Pitch = 1.0
			},
			{
				File = "ambience/buildings/market_chicken_03.wav",
				Volume = 0.9,
				Pitch = 1.0
			},
			{
				File = "ambience/buildings/market_chicken_04.wav",
				Volume = 0.9,
				Pitch = 1.0
			},
			{
				File = "ambience/buildings/market_chicken_05.wav",
				Volume = 0.9,
				Pitch = 1.0
			},
			{
				File = "ambience/buildings/market_bottles_00.wav",
				Volume = 1.0,
				Pitch = 1.0
			}
		];
		this.m.SoundsAtNight = [];
	}

	function onClicked( _townScreen )
	{
		_townScreen.getShopDialogModule().setShop(this);
		_townScreen.showShopDialog();
		this.pushUIMenuStack();
	}

	function onSettlementEntered()
	{
		foreach( item in this.m.Stash.getItems() )
		{
			if (item != null)
			{
				item.setSold(false);
			}
		}
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
		

		if (this.m.Settlement.getSize() >= 3)
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
		}

		if (this.m.Settlement.getSize() >= 2 && !this.m.Settlement.hasAttachedLocation("attached_location.fishing_huts"))
		{
			list.push({
				R = 50,
				P = 1.0,
				S = "supplies/dried_fish_item"
			});
		}

		if (this.m.Settlement.getSize() >= 3 && !this.m.Settlement.hasAttachedLocation("attached_location.beekeeper"))
		{
			list.push({
				R = 50,
				P = 1.0,
				S = "supplies/mead_item"
			});
		}

		if (this.m.Settlement.getSize() >= 1 && !this.m.Settlement.hasAttachedLocation("attached_location.pig_farm"))
		{
			list.push({
				R = 50,
				P = 1.0,
				S = "supplies/smoked_ham_item"
			});
		}

		if (this.m.Settlement.getSize() >= 2 && !this.m.Settlement.hasAttachedLocation("attached_location.hunters_cabin"))
		{
			list.push({
				R = 50,
				P = 1.0,
				S = "supplies/cured_venison_item"
			});
		}

		if (this.m.Settlement.getSize() >= 3 && !this.m.Settlement.hasAttachedLocation("attached_location.goat_herd"))
		{
			list.push({
				R = 50,
				P = 1.0,
				S = "supplies/goat_cheese_item"
			});
		}

		if (this.m.Settlement.getSize() >= 3 && !this.m.Settlement.hasAttachedLocation("attached_location.orchard"))
		{
			list.push({
				R = 50,
				P = 1.0,
				S = "supplies/dried_fruits_item"
			});
		}

		if (this.m.Settlement.getSize() >= 2 && !this.m.Settlement.hasAttachedLocation("attached_location.mushroom_grove"))
		{
			list.push({
				R = 50,
				P = 1.0,
				S = "supplies/pickled_mushrooms_item"
			});
		}

		if (!this.m.Settlement.hasAttachedLocation("attached_location.wheat_farm"))
		{
			list.push({
				R = 30,
				P = 1.0,
				S = "supplies/bread_item"
			});
		}

		if (this.m.Settlement.getSize() >= 2 && !this.m.Settlement.hasAttachedLocation("attached_location.gatherers_hut"))
		{
			list.push({
				R = 50,
				P = 1.0,
				S = "supplies/roots_and_berries_item"
			});
		}

		if (this.m.Settlement.getSize() >= 2 && !this.m.Settlement.hasAttachedLocation("attached_location.brewery"))
		{
			list.push({
				R = 50,
				P = 1.0,
				S = "supplies/beer_item"
			});
		}

		if (this.m.Settlement.getSize() >= 3 && !this.m.Settlement.hasAttachedLocation("attached_location.winery"))
		{
			list.push({
				R = 50,
				P = 1.0,
				S = "supplies/wine_item"
			});
		}

		if (this.m.Settlement.getSize() >= 3)
		{
			list.push({
				R = 60,
				P = 1.0,
				S = "supplies/cured_rations_item"
			});
		}

		if (this.m.Settlement.getSize() >= 3 || this.m.Settlement.isMilitary())
		{
			list.push({
				R = 90,
				P = 1.0,
				S = "accessory/falcon_item"
			});
		}

		
		this.m.Settlement.onUpdateShopList(this.m.ID, list);
		this.fillStash(list, this.m.Stash, 1.0, true);
	}

	function onSerialize( _out )
	{
		this.building.onSerialize(_out);
		this.m.Stash.onSerialize(_out);
	}

	function onDeserialize( _in )
	{
		this.building.onDeserialize(_in);
		this.m.Stash.onDeserialize(_in);
	}

});

