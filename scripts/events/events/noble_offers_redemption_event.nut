this.noble_offers_redemption_event<- this.inherit("scripts/events/event", {
	m = {
		Faction = null,
		NobleBro = null,
	},
	//TODO: test this event
	function create()
	{
		this.m.ID = "event.noble_offers_redemption";
		this.m.Title = "Along the road...";
		this.m.Cooldown = 20.0 * this.World.getTime().SecondsPerDay;
		this.m.Faction = null;
		
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_58.png[/img]{%noblebro% has been with %companyname% for some time now. Traveling, fighting, killing without much complaints, until now at least. However, he has decided it is time to talk to you.%SPEECH_ON%Chief, I\'ve heard you want to make some headway with the nobles. Reckon, you think it would be better to have them as friends, rather then enemies. That\'s true, probably, although they can be more dangerous as friends. I believe I can help.%SPEECH_OFF%He explains, he still has friends and contacts among influential people, particularly in %noblehouse%. He could ask a favor, put in a good word, but ultimately, he says, words are cheap, money is not. At least %crowns% coins is not cheap.}",
			Banner = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "Make it happen.",
					function getResult( _event )
					{
						return "B";
					}

				},
				{
					Text = "We have no need for this.",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.NobleBro.getImagePath());
				this.Banner = _event.m.Faction.getUIBannerSmall();
			}

		});
		this.m.Screens.push({
			ID = "B",
			Text = "[img]gfx/ui/events/event_31.png[/img]{You agree to the %noblebro%\'s notions and he sets up a meeting. Together you meet with an intermediary and one of the nobles himself. He looks like a pampered fool which isn\'t to your liking, but it looks like the dislike is mutual. After the introductions he finally asks.%SPEECH_ON%Your kind has been raiding and pillaging our caravans, our homes. Our churches. Why should I listen to the likes of you.%SPEECH_OFF%Your first instinct is to take your sword and run it through the nobleman\'s mouth. However, you decide against it. Your second thought is to just turn around and leave, but you decide against that too. Instead, you decide to throw a bag of coins in front of him. He looks at it unimpressed. %SPEECH_ON%You steal from us, now you offer us back what you stole and you expect… What exactly? We\'ll be friends now? Not likely.%SPEECH_OFF%You look at your %noblebro% and give him your best expression of irritation and displeasure. He is calm though and slowly nods to you. You take another bag of gold and throw it at the nobleman. %noblebro% slowly takes a step forward.%SPEECH_ON%Yes, there has been raiding and pillaging, but if we are to dwell on such pasts we\'ll miss the opportunities of the future%SPEECH_OFF%.He continues on talking about all kinds of work %companyname% could do for the noble house. After he is finished, the noble takes the money.%SPEECH_ON%Fine, but no more raiding, at least not of %noblehouse%. I don\'t care about others. We will not be meeting like this again.%SPEECH_OFF%}",
			Banner = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "With friends like these, who needs enemies.",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.NobleBro.getImagePath());
				this.Banner = _event.m.Faction.getUIBannerSmall();
				this.World.Flags.set("NorthExpansionRedemptionAccepted", true);
				this.World.Assets.addBusinessReputation(50);
				this.World.Assets.addMoney(-2000);
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "You lose [color=" + this.Const.UI.Color.NegativeEventValue + "]-2000[/color] Crowns"
				});
				_event.m.Faction.addPlayerRelation(20.0, "Was bribed to have dealings with you");
				this.List.push({
					id = 10,
					icon = "ui/icons/relations.png",
					text = "Your relations to " + _event.m.Faction.getName() + " improve"
				});
			}

		});
		
		

	}

	function onUpdateScore()
	{
		this.logInfo("redemption update score");
		if (!this.Const.DLC.Wildmen)
		{
			this.logInfo("no wildmen");
			return;
		}
		
		if (!this.World.Flags.get("NorthExpansionActive") )
		{
			this.logInfo("not active");
			return;
		}
		
		
		if (!this.World.Ambitions.hasActiveAmbition() || this.World.Ambitions.getActiveAmbition().getID() != "ambition.make_civil_friends")
		{
			this.logInfo("no ambition");
			return;
		}
		
		if(this.World.Flags.get("NorthExpansionRedemptionAccepted"))
		{
			this.logInfo("already accepted");
			return;
		}
		
		if (this.World.Assets.getMoney() < 2000)
		{
			return;
		}
		
		this.logInfo("redemption update score2");
		
		
		local brothers = this.World.getPlayerRoster().getAll();
		local candidates = [];

		foreach( bro in brothers )
		{
			if (bro.getBackground().getID() == "background.bastard" && bro.getLevel() > 1)
			{
				candidates.push(bro);
			}
			
			if (bro.getBackground().getID() == "background.adventurous_noble" && bro.getLevel() > 1)
			{
				candidates.push(bro);
			}
			
			if (bro.getBackground().getID() == "background.disowned_noble" && bro.getLevel() > 1)
			{
				candidates.push(bro);
			}
		}

		if (candidates.len() == 0)
		{
			this.logInfo("no candidates for redemption");
			return;
		}
		
		this.m.NobleBro = candidates[this.Math.rand(0, candidates.len() - 1)];
		
		
		local nobles = this.World.FactionManager.getFactionsOfType(this.Const.FactionType.NobleHouse);
		local scores = [];
		foreach (n in nobles)
		{
			scores.push( 5 + n.getPlayerRelation());
		}
		
		local picked = ::NorthMod.Utils.scorePicker(scores);
		this.m.Faction = nobles[picked];
		
		this.m.Score = 100;
	}
	
	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		
		_vars.push([
			"noblebro",
			this.m.NobleBro.getName()
		]);
		_vars.push([
			"noblehouse",
			this.m.Faction.getName()
		]);
		_vars.push([
			"crowns",
			"2,000"
		]);
	}

	function onClear()
	{
		this.m.Faction = null;
		this.m.NobleBro = null;
	}

});

