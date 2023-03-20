::NorthMod.Const.Contracts <- {
};

::NorthMod.Const.Contracts.IntroSettlementNeutral <- {
	ID = "Intro",
	Title = "Negotiations",
	Text = "[img]gfx/ui/events/event_20.png[/img]{A cowl-shaded man hisses at you, his teeth and nose winking momentarily from the dark of his hood. You\'ve no time for lepers or jokers and demand the man to get out of your way. Instead, he starts talking.%SPEECH_ON%My master requires your services, he\'s heard of your exploits. Follow me and I shall take you to him.%SPEECH_OFF%You rest your hands on the handle of your sword and nod. | You sit alone, studying a map as a stiff breeze tries to take off with it. As you struggle to keep the sheet on the table, %randombrother%, one of your men, approaches and slams a mug on the paper\'s corner. You look up to see he\'s a bit slackjawed with drink on his breath. He explains that he shared stories with a with %employer% who has a proposal for you. The maps and the lands they detail aren\'t going anywhere, so you agree to meet with him and hear him out. | You enter %townname% and a man immediately approaches, trundling through the mud to get to you. He announces himself as someone working for %employer% and he has decided to seek your services. | A man approaches from the side of one of the jurts. He\'s dressed in a rich furs and is guarded by two well-armed men. He announces himself as a an advisor to %employer%, a local leader of %townname%. You are asked to take audience with the man. | While your men venture around town, you go to an inn and take a seat. As soon as you do, a strange man joins you.%SPEECH_ON%You with the %companyname%?%SPEECH_OFF%You nod. The man nods back then reaches into his pocket. You reach for your dagger. The stranger puts his hand out.%SPEECH_ON%Easy there. I\'m wearing a sword. If I wanted to kill ya, taking a seat probably wouldn\'t be the best route.%SPEECH_OFF%The man lifts the sheath and it bumps the underside of the table. He cocks his head as if to say, \'see?\' You nod and the man continues with his move, taking out a note and passing it to you.%SPEECH_ON%%employer% wishes to see you.%SPEECH_OFF% | You come across a man leaning against a yurt. He hails you down.%SPEECH_ON%%employer%\'s been looking for you, warrior. He\'s down yonder in the village communal.%SPEECH_OFF%The stranger nods towards a large yurt a little ways along the road.%SPEECH_ON%I hope you do good, warrior. The people of %townname% are wary of your sort, but that don\'t mean their hearts can\'t be won over.%SPEECH_OFF% | A man strums a stringed instrument as you walk by. He slashes an ear-piercing chord and you turn to find him laughing.%SPEECH_ON%Heh, I thought that mind fetch your attention. %employer% said we should keep a lookout for a man of your... vocation. If you\'re looking for work, he\'s the man to go to.%SPEECH_OFF%You ask if this figurehead pays well. The man nods.%SPEECH_ON%Yup. He gave me this here lute as payment once. Now I\'m just waiting for the old devils to come down and challenge me to a tune. %employer% said if you best one in a game of songs, then they\'ll give ya golden lute. Now that\'s what I call good payment, wouldn\'t you agree?%SPEECH_OFF%The man turns back to the instrument, drawing a mewling tune out from the strings. In the distance, dogs begin to howl. | As you take stock of your inventory, a rather well-to-do man spots you and heads your way. He announces himself as working for %employer% and that he wishes to talk you. You hand your duties over to %randombrother% and let the man lead the way. | %randombrother% comes along with a small boy racing at his side. When they get to you, the pair talk at the same time, stop, and then start again. You hold your hand up, and then point to the little boy who immediately says that %employer% wishes to see you. You then point to the battle brother who says a local bitch has birthed puppies and maybe the %companyname% could take one. Pursing your lips, you tell the boy to take you to his master who is found already waiting for you.}",
	Image = "",
	List = [],
	ShowEmployer = false,
	ShowDifficulty = true,
	Options = [
		{
			Text = "I\'m all ears.",
			function getResult()
			{
				return "Task";
			}

		}
	]
}
;
::NorthMod.Const.Contracts.IntroSettlementFriendly <- {
	ID = "Intro",
	Title = "Negotiations",
	Text = "[img]gfx/ui/events/event_20.png[/img]{A few peasants walk up to you and one even offers a hug. You decline.%SPEECH_ON%It\'s good to see you again, sellsword. %employer%\'s been looking for you.%SPEECH_OFF% | A woman offers you a flower when you walk into town. This is against the usual response which is shutter the windows and hide the kids. You take the flower and she sways her skirt a little before prancing away. A man comes up to you.%SPEECH_ON%Sorry for that bother, sir, the townsfolk seemed to have taken a liking to you. %employer% as well, seeing as how he\'s been looking for you since the moment he heard you were in town.%SPEECH_OFF% | A pack of dogs streams down the road, a few children in chase. They scatter past you one by one, the dogs howling and huffing with joy, the children screaming out greetings. A woman walks up, a metal skillet in one hand and a wash rag in the other.%SPEECH_ON%Hey there sellsword. I probably should let one of them messenger men find and tell you this, but I got the news so I\'ll tell you anyhow. %employer%\'s looking for you.%SPEECH_OFF%She flutters her eyes. You smile back and nod. %randombrother% smirks.%SPEECH_ON%See something you like, sir?%SPEECH_OFF%You tell the man to go fark a goat. | A couple of bleating goats are being lead down the road. They shuffle through the mud, prodding their noses through the muck and somehow finding things to chew up. Their shepherd plants his cane in the ground.%SPEECH_ON%Hey there mercenary. %employer%\'s been looking for ya.%SPEECH_OFF% | A man sitting on his porch leans forward at the very sight of you. He points a finger.%SPEECH_ON%Well if it ain\'t the sellsword everyone been talking of.%SPEECH_OFF%You look around before nodding. He grins and hoots and hollers.%SPEECH_ON%Hell, it\'s damned nice seeing you around again! And it\'d be short of me not to tell you that %employer%\'s been tryin\' to find ya. Go and see him. Tell him I sent ya, maybe he\'ll send me a reward. Probably just a bunch of flowers, that bastard. Or a cat. Who wants a cat? Why did he ever send me a cat? I told him I hate cats...%SPEECH_OFF%As the man rambles on, you quietly make your leave. | A woman runs up to you. She brings her children with, not exactly taking precautions with a sellsword. One of the kids swings their arms around your leg.%SPEECH_ON%He\'s back!%SPEECH_OFF%You look down and grin, subtly trying to shake the bastard off although he just takes it for play. The mother retrieves the spawn before pointing up the road.%SPEECH_ON%%employer%\'s been lookin\' for ya. Tell him I fetched ya, maybe he\'ll come and fix our well once he knows I done a favor.%SPEECH_OFF%She looks world weary, dragged to the hells by the cheeriness of her children. | You walk into %townname% and a man beckons you into his garden. He\'s tending the plants, using a steady hand to clip the vegetables or fruit or whatever it is, you\'re not a gardener.%SPEECH_ON%How are you doing, sellsword? If you\'re wondering, %employer% been talking of you. Suppose he\'s been wanting to see you, too, if yer interested in some more business. Here, catch.%SPEECH_OFF%He turns and tosses a {cabbage | onion | potato | tomato} at you.%SPEECH_ON%Nice catch.%SPEECH_OFF%You take a bite and nod back.%SPEECH_ON%Doesn\'t taste half bad.%SPEECH_OFF% | An old shopkeep waves at you.%SPEECH_ON%It\'s good seeing you again, sellsword. How often do you hear that?%SPEECH_OFF%He thumbs down the road.%SPEECH_ON%If you\'d like to do some more of that good work, then %employer% been looking for you.%SPEECH_OFF% | A man fleecing a sheep looks over to you, the runt wriggling around.%SPEECH_ON%I should just eat this lil\' bastard. Look at her go. Quit it, would ya?%SPEECH_OFF%He elbows the beast and it bleats, cursing back with as much sapience as a sheep can muster. The man looks up at you again.%SPEECH_ON%Say, yer that sellsword everyone\'s been talking about. I should probably tell you, and I guess I will, heh, that, uh, %employer% been looking for you.%SPEECH_OFF%The sheep jumps in an attempted escape, but the man slams her down.%SPEECH_ON%You little git, I\'mma milk yer tits dry if you try that again!%SPEECH_OFF%}",
	Image = "",
	List = [],
	ShowEmployer = false,
	ShowDifficulty = true,
	Options = [
		{
			Text = "I\'m all ears.",
			function getResult()
			{
				return "Task";
			}

		}
	]
}
;
::NorthMod.Const.Contracts.IntroSettlementCold <- {
	ID = "Intro",
	Title = "Negotiations",
	Text = "[img]gfx/ui/events/event_20.png[/img]{An old man\'s sitting out in front of a yurt when you enter the village. He spits at the very sight of you.%SPEECH_ON%Some balls on you showing your face around these parts, warrior.%SPEECH_OFF%He wipes his mouth on his sleeve.%SPEECH_ON%But I won\'t lie and say we don\'t need you, though I hate to all the hells that I have to admit it. Come on then, you know who to see if it\'s work yer after. %employer% be where he always be.%SPEECH_OFF% | You enter %townname% and a man barks out at you.%SPEECH_ON%Well shit, if it ain\'t the %companyname% and the snake in the grass it calls a leader.%SPEECH_OFF%You raise an eyebrow, and put a hand to your sword. The man laughs.%SPEECH_ON%We don\'t care for you, warrior, but we do need ya. Come on, slither this way so we can talk work. That\'s what you really care about, right? %employer% is the man you want to be seeing.%SPEECH_OFF% | %townname%\'s denizens duck out of sight as you enter. Many a shutter slam close, and children are hushed and hurried away. A man\'s standing in the middle of the road, his hands on his hips.%SPEECH_ON%Well, it\'s you.%SPEECH_OFF%You look around, making sure some ambush isn\'t about to fall down on your damn head. The man laughs.%SPEECH_ON%We ain\'t gonna kill ya, warrior. I\'m out here to broker a deal, that\'s all. If you\'re interested, come see %employer%.%SPEECH_OFF%He spits, turns, and walks off. You spend a second longer looking out for that ambush. | Frightened women and children run from the sight of you. A few men linger, clutching their pitchforks or sidearms as you pass. An elder steps forward, eyeing you up and down.%SPEECH_ON%%employer%\'s been looking for ya. I don\'t know why after all that you\'ve done, but I won\'t get between him and his business.%SPEECH_OFF% | Some of %townname%\'s clansmen give you the side-eye as you enter the village. One spits and yells out.%SPEECH_ON%%employer%\'s looking for you, warrior.%SPEECH_OFF%His voice trails off into what you thought sounded like obscenities. | A woman hurries across the road to pick up her child. She twirls the kid around, a protective hand clutching the back of its head.%SPEECH_ON%I don\'t know what you\'re doing here again, warrior, but %employer%\'s been looking for you anyhow.%SPEECH_OFF%She runs off, though occasionally looking behind her with furtive glances. | Kids cycle around your feet as you walk down the road. Their parents come out screaming, telling the kids to get away from you. A mother ushers her daughter away while mean mugging you.%SPEECH_ON%Don\'t ever touch my child. And if it\'s work you want, then go see %employer%.%SPEECH_OFF% | A man\'s repairing the roof of his home when he sees you.%SPEECH_ON%Ah hell, you again?%SPEECH_OFF%You look around then turn back to the man. He laughs.%SPEECH_ON%Most folks don\'t take kindly to yer being here. I suppose I\'m neutral on the matter, but then again it\'s easy to be on the fence when yer ten feet up in the air.%SPEECH_OFF%He grins, but his foot kicks out and he almost slides off his roof. He clutches onto the thatching.%SPEECH_ON%Whoa! Well, uh, anyway %employer%\'s looking for you. Don\'t mind the hate of the people. It\'s what comes natural to them.%SPEECH_OFF% | People scurry from the sight of the the %companyname%. One man yells out from his window.%SPEECH_ON%\'Ey warrior! %employer% been wanting to see you!%SPEECH_OFF%He quickly shutters his windows before you can respond.}",
	Image = "",
	List = [],
	ShowEmployer = false,
	ShowDifficulty = true,
	Options = [
		{
			Text = "Let\'s see what this is about.",
			function getResult()
			{
				return "Task";
			}

		}
	]
};

