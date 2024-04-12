this.nem_defend_settlement_greenskins_contract <- this.inherit("scripts/contracts/barbarian_contract", {
	m = {
		
	},
	function create()
	{
		this.contract.create();
		this.m.Type = "contract.nem_defend_settlement_greenskins";
		this.m.Name = "Defend Settlement";
		this.m.TimeOut = this.Time.getVirtualTimeF() + this.World.getTime().SecondsPerDay * 5.0;
		this.m.MakeAllSpawnsResetOrdersOnContractEnd = false;
		this.m.MakeAllSpawnsAttackableByAIOnceDiscovered = true;
	}

	function onImportIntro()
	{
		this.importSettlementIntro();
	}

	function start()
	{
		this.m.Payment.Pool = 900 * this.getPaymentMult() * this.Math.pow(this.getDifficultyMult(), this.Const.World.Assets.ContractRewardPOW) * this.getReputationToPaymentMult();

		if (this.Math.rand(1, 100) <= 33)
		{
			this.m.Payment.Completion = 0.75;
			this.m.Payment.Advance = 0.25;
		}
		else
		{
			this.m.Payment.Completion = 1.0;
		}

		this.contract.start();
	}
	
	function spawnParties(number)
	{
		
		local r = this.Math.rand(1, 100);
		local nearestOrcs = this.Contract.getNearestLocationTo(this.Contract.m.Home, this.World.FactionManager.getFactionOfType(this.Const.FactionType.Orcs).getSettlements());
		local nearestGoblins = this.Contract.getNearestLocationTo(this.Contract.m.Home, this.World.FactionManager.getFactionOfType(this.Const.FactionType.Goblins).getSettlements());

		if (nearestOrcs.getTile().getDistanceTo(this.Contract.m.Home.getTile()) + this.Math.rand(0, 6) <= nearestGoblins.getTile().getDistanceTo(this.Contract.m.Home.getTile()) + this.Math.rand(0, 6))
		{
			this.Flags.set("IsOrcs", true);
			this.m.Origin = nearestOrcs;
		}
		else
		{
			this.Flags.set("IsGoblins", true);
			this.m.Origin = nearestGoblins;
		}
		

		for( local i = 0; i < number; i++ )
		{
			local party;

			if (this.Flags.get("IsGoblins"))
			{
				party = this.Contract.spawnEnemyPartyAtBase(this.Const.FactionType.Goblins, this.Math.rand(80, 110) * this.Contract.getDifficultyMult() * this.Contract.getScaledDifficultyMult());
			}
			else
			{
				party = this.Contract.spawnEnemyPartyAtBase(this.Const.FactionType.Orcs, this.Math.rand(80, 110) * this.Contract.getDifficultyMult() * this.Contract.getScaledDifficultyMult());
			}
		}
	}
	
	function prepareFlags()
	{
		//greenskins are not interesting in raiding only
	}
	
	function getAttackScreen()
	{
		if (this.Flags.get("IsOrcs"))
		{
			return "OrcAttack";
		}
		else
		{
			return "GoblinAttack";
		}
	}
	

	
	function createScreens()
	{
		this.importScreens(::NorthMod.Const.Contracts.NegotiationDefault);
		this.importScreens(::NorthMod.Const.Contracts.Overview);
		this.getScreen("Task").Text = "[img]gfx/ui/events/event_20.png[/img]{When you see %employer% he\'s got sweat pouring down his face and dabbing it with a nicely embroidered cloth that seems to achieve nothing in stemming the tide.%SPEECH_ON%Warrior, it is oh so good  to see you! Please, please come in and listen to what I have to say.%SPEECH_OFF%You cautiously walk into the room and take a seat, glancing momentarily to make sure nobody was hiding behind the crook of the door or behind one of the bookshelves lining the walls. %employer% pushes a map across his table.%SPEECH_ON%See those green markings? Those are greenskin movements, tracked by my scouts. Sometimes they tell me by word, sometimes they don\'t tell me at all. Those scouts just... poof, disappear. It doesn\'t take a genius to know what really happened to them though, does it?%SPEECH_OFF%You ask what the man wants. He slams the map, his fist landing square on %townname%.%SPEECH_ON%Can you not see? They\'re coming this way and I need you to help defend us!%SPEECH_OFF% | %employer%\'s nervously picking his nails when you find him. He\'s got them down to nubs by this point, just flecks of skin and blood shaving away at this point.%SPEECH_ON%Thank you for coming, warrior. I\'ll be frank with you, the greenskins are coming.%SPEECH_OFF%Using a hand for height measurements, you ask what sort of greenskin, the ones yeigh big, or the ones about hmmm, big. %employer% shrugs.%SPEECH_ON%I\'ve no idea. My scouts keep disappearing and the folk that keep arriving aren\'t exactly the most accurate of witnesses to depend upon. All you need to know is that we need your help, because those greenskins are coming this way.%SPEECH_OFF% | %employer%\'s fighting off a crowd when you find him.%SPEECH_ON%Everyone calm down! Just calm down!%SPEECH_OFF%Someone throws an onion, battering the man upside the head with a tearjerking rap of sour vegetable. Someone else quickly scurries to pick it up and take a bite. %employer% points you out in the crowd.%SPEECH_ON%Warrior! I am so glad you came!%SPEECH_OFF%He fights through the crowd. He leans in close to your ear, yet still has to shout to be heard.%SPEECH_ON%We have money! We have what you need! Just help protect this camp from the greenskins!%SPEECH_OFF% | Clansmen have come to %employer%\'s abode. They\'re carrying armfuls of belongings, a litter of it trailing behind their every step, so urgent to flee they don\'t even bother picking up any of it. %employer% himself sees you through one of his window\'s and waves you to come in through a side door. When you sneak in, he simply plops down in his chair and pours you a drink.%SPEECH_ON%Greenskins are coming and I don\'t believe there are enough men on hand to defend %townname%. Obviously, I\'m willing to call on and pay for your services to help keep %townname% safe from this green menace.%SPEECH_OFF% | A man is standing outside %employer%\'s abode, two painted slabs of wood dressed over himself. On each board is written some prophetic doomsayer\'s tale. You ignore the man and enter the house. %employer% is standing there, laughing and shaking his head.%SPEECH_ON%That guy standing out there ain\'t wrong. My scouts have been reporting greenskins moving through the area for a while. I should have listened for how my scouts haven\'t said anything for a good week, presumably because those very same greenskins got their hands on them. Now I got the commonfolk coming to me with horror stories of what is going on out there, and how a large horde of those awful creatures are coming this way.%SPEECH_OFF%He turns to you, grinning, madness spinning in his grin.%SPEECH_ON%So what say you and I broker a deal and shut up that doomsayer\'s shrill crying? Will you help protect %townname%?%SPEECH_OFF%}";
		
		this.getScreen("Plea").Text = "[img]gfx/ui/events/event_43.png[/img]{Leaving %employer% with a rejection, you come across a man who laughs and shakes his head.%SPEECH_ON%Hey now, the greenskins ain\'t that way, unless, of course, that was in your plan you no good coward.%SPEECH_OFF%You draw out your sword, letting its steel scratch the scabbard good and long. The man laughs.%SPEECH_ON%Oh, and what are you going to do with that? Run me through? Alright. Go ahead. Do worse than the greenskins, I dare ya.%SPEECH_OFF%A woman rushes out, grabbing the man and dragging him back.%SPEECH_ON%Get the children, would ya? We need to leave, now!%SPEECH_OFF%The huddled pair shuffles off, but your head is still swimming with the clansman\'s accusation of cowardice. | The folk are already packing the road to get the hell out of %townname%. A few glance at you and one even steps forward, an old man with a stick of a cane.%SPEECH_ON%See, this is what it\'s like in today\'s world! All the good men are dead, and only those left are the cowards like this so called swordsman here.%SPEECH_OFF%%randombrother% steps forward, heaving his weapon out and looking ready to kill.%SPEECH_ON%You dare insult %companyname%? I\'ll have your tongue and then your head, old man!%SPEECH_OFF%You grab the warrior by the shoulder. The last thing these people need is violence, but the man spoke good and loud. Now you wonder who heard him and who will live to spread the weight behind his words. | A woman clutches onto you as you try and get back to the company.%SPEECH_ON%Please! You mustn\'t leave us to this fate! You know not what the greenskins will do to us!%SPEECH_OFF%You actually have a very strong notion, but keep it to yourself. The woman drops to her knees and clutches both your ankles. You manage to step out of her grasp. For a brief moment she scrambles after you, slopping through the mud, then stops and begins sobbing.%SPEECH_ON%You don\'t know what it\'s like. It don\'t ever seem to get better for us. For me.%SPEECH_OFF%By the gods that is pathetic, but you find a tiny bit of sympathy welling up within you. | A disheveled and very old man steps toward you.%SPEECH_ON%So, you decided not to help? I suppose I can\'t fault that.%SPEECH_OFF%He fans an arm out to a few clansmen standing nearby. They have crates of goods with them, stuffed belongings that range from moldy vegetables to a chicken or two, or maybe those two chickens are one just tiny and squawky lamb.%SPEECH_ON%Those people would like to you to stay and help. But I understand why you wouldn\'t. I was there at the Battle of Many Names. I know what it\'s like to fight those beasts. I won\'t fault you. It takes a man of great measure to take them on. So it is, so it is, yessir, and I won\'t fault ya, not one bit.%SPEECH_OFF%He slowly hobbles away and it is then that you notice that one of his legs is replaced by a wooden peg. A few children run to him and he speaks with the group of clansmen. He looks back at you, then back to them, and shakes his head. You can almost feel the sadness and disappointment wash over you.}";
		
		
		this.getScreen("Success1").Text = "[img]gfx/ui/events/event_04.png[/img]{%employer% welcomes your return with a chest of %reward% crowns.%SPEECH_ON%You\'ve earned this one, warrior, I\'ll say that much. Not a single part of this camp, well nothing important anyway, was touched.%SPEECH_OFF%He pauses as you stare at the chest. It was hard fought and hard earned. You just expected more of it. Sometimes the simplicity of being a warrior really bugs you. | You find %employer% feeding some of his dogs. He pets one over and over as it chows down.%SPEECH_ON%I really thought I\'d have to give this up.%SPEECH_OFF%He gives the mutt one final pat before turning his eyes to you.%SPEECH_ON%Thank you, warrior. You did more than just protect this camp, you protected a way of life. Without you, we either would have all died or, worse, lived to see the horridness that tomorrow surely would have brought.%SPEECH_OFF%You nod and step forward to give one of the dogs a pat, but it leers up at you and growls. %employer% laughs.%SPEECH_ON%Please forgive his ignorance.%SPEECH_OFF% | %employer%\'s got a gang of men and women surrounding him. When you enter the room they turn to you in almost creepy unison. They stare for a moment before breaking into celebrations and rushing to you, hugs and tears and all. Fighting them off, you find %employer% standing there with a satchel in hand.%SPEECH_ON%This is for saving %townname%, warrior. If I\'m being honest, it ain\'t as heavy as it should be, but it\'s all we got.%SPEECH_OFF% | %employer%\'s looking out his window when you return to him. Outside, folk are running about and hugging one another.%SPEECH_ON%Not a greenskin entered the camp commons.%SPEECH_OFF%He smiles as he hands over a satchel of goods.%SPEECH_ON%You went above and beyond this day, warrior.%SPEECH_OFF%}";
		
		
		this.m.Screens.push({
			ID = "OrcsAttack",
			Title = "Near %townname%",
			Text = "[img]gfx/ui/events/event_49.png[/img]The greenskins are in sight! Prepare for battle and protect the camp!",
			Image = "",
			List = [],
			Options = [
				{
					Text = "To arms!",
					function getResult()
					{
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "GoblinsAttack",
			Title = "Near %townname%",
			Text = "[img]gfx/ui/events/event_48.png[/img]The greenskins are in sight! Prepare for battle and protect the camp!",
			Image = "",
			List = [],
			Options = [
				{
					Text = "To arms!",
					function getResult()
					{
						return 0;
					}

				}
			]
		});
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"reward",
			this.m.Reward
		]);
	}

	function onHomeSet()
	{
		if (this.m.SituationID == 0)
		{
			this.m.SituationID = this.m.Home.addSituation(this.new("scripts/entity/world/settlements/situations/greenskins_situation"));
		}
	}

	function onClear()
	{
		if (this.m.IsActive)
		{
			this.m.Home.getSprite("selection").Visible = false;

			this.World.getGuestRoster().clear();
		}

		if (this.m.Home != null && !this.m.Home.isNull() && this.m.SituationID != 0)
		{
			local s = this.m.Home.getSituationByInstance(this.m.SituationID);

			if (s != null)
			{
				s.setValidForDays(4);
			}
		}
	}

	function onIsValid()
	{
		local nearestOrcs = this.getNearestLocationTo(this.m.Home, this.World.FactionManager.getFactionOfType(this.Const.FactionType.Orcs).getSettlements());
		local nearestGoblins = this.getNearestLocationTo(this.m.Home, this.World.FactionManager.getFactionOfType(this.Const.FactionType.Goblins).getSettlements());
		
		if (nearestOrcs.getTile().getDistanceTo(this.m.Home.getTile()) > 20 && nearestGoblins.getTile().getDistanceTo(this.m.Home.getTile()) > 20)
		{
			return true;
		}

		return true;
	}

	function onSerialize( _out )
	{
		this.contract.onSerialize(_out);
	}

	function onDeserialize( _in )
	{
		this.contract.onDeserialize(_in);
	}

});

