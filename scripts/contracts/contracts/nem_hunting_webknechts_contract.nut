this.nem_hunting_webknechts_contract <- this.inherit("scripts/contracts/contracts/hunting_webknechts_contract", {
	m = {
	},
	function create()
	{
		this.hunting_webknechts_contract.create();
		this.m.Type = "contract.nem_hunting_webknechts";
	}

	function start()
	{
		this.m.Payment.Completion = 1.0;

		this.contract.start(); //TODO: test this or this.hunting_webknechts_contract.contract.start();
	}

	function createScreens()
	{
		this.hunting_webknechts_contract.createScreens();
		::NorthMod.ContractUtils.setScreenText(this, "Task", 
		"[img]gfx/ui/events/event_43.png[/img]{You find %employer% stretching a cobweb between two forks. He turns one of the utensils and wraps the webbing around a twine. Sighing, he finally looks at you.%SPEECH_ON%I must admit, I\'m at my wit\'s end here. Enormous spiders are afoot, stealing livestock, pets. One woman reported her infant taken from the crib, all there being a pit of webbing where it slept. I need these horrid creatures taken care of, their nest destroyed. With proper reward, would you be interested?%SPEECH_OFF%");
		
		::NorthMod.ContractUtils.setScreenText(this, "Survivor", 
		"[img]gfx/ui/events/event_123.png[/img]{The battle over, you find a man dangling by webbing attached to his feet. Half of his body is bound in the filaments and more dangle from his hip like a shredded dress. Seems the spiders deserted him upon the %companyname%\'s arrival. He smiles at the sight of you.%SPEECH_ON%Hey there. Warriors ain\'t ya? Yeah I see it. But it looks like you are from the north, them barbarians, And you fought like that too. Absolute savages.%SPEECH_OFF%You ask the man what you should cut him down. He turns his head up, his whole body then starting to swing about and at times twist him away from you entirely. He speaks, either to you or to whichever direction he\'s facing.%SPEECH_ON%Aye, good question! Well, you may not see it here and now, but I\'m a sellsword and wouldn\'t you know that my company and its captain all been done stringed up and consumed whole by them spiders! Cut me down and I\'ve nowhere else better to go then your company. That is, if you\'d have me.%SPEECH_OFF%You have the man cut free and debate what to do before returning to %employer%.}");
		
		::NorthMod.ContractUtils.setScreenText(this, "Success",
		"[img]gfx/ui/events/event_85.png[/img]{%employer% meets you at the %townname% entrance and there\'s a crowd of folks beside him. He welcomes you warmly, stating he had a scout following you who saw the whole battle unfold. After he hands you your reward, the clansmen come forward one by one. They offer a few gifts as thanks for relieving them of the webknecht horrors.")
	}
	

});

