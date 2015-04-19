package game.system;

import ash.core.Entity;
import ash.core.Node;
import flaxen.common.Easing;
import flaxen.component.Alpha;
import flaxen.component.Image;
import flaxen.component.Invisible;
import flaxen.component.Position;
import flaxen.component.Text;
import flaxen.core.Flaxen;
import flaxen.core.FlaxenSystem;
import flaxen.service.InputService;
import game.component.Knowledge;
import game.component.PlaceRecruitIntent;
import game.component.Researcher;
import game.component.StatusBar;
import game.Naming;
import game.node.KnowledgeNode;

class RecruitSystem extends FlaxenSystem
{
	public static var EARN_KNOWLEDGE:String = "Earn Knowledge To Gain More Recruits!";

	public function new(f:Flaxen)
	{
		super(f);
	}

	override public function update(ms:Float)
	{
		var knowledge:Knowledge;
		for(node in f.ash.getNodeList(KnowledgeNode))
		{
			knowledge = node.knowledge;
			if(f.hasMarker("recruiting"))
				recruitNow(node.knowledge);
			if(f.hasMarker("place-recruit"))
				updatePlacement(node.knowledge);
			else
				checkKnowledge(node.knowledge);
		}

		for(node in f.ash.getNodeList(PlaceRecruitIntentNode))
		{
			var intent = node.placeRecruitIntent;
			f.ash.removeEntity(node.entity);
			var boardPos = f.demandEntity("board").get(Position);
			var recruitEnt = f.demandEntity("nextRecruit");
			recruitEnt.name = f.getEntityName("researcher"); // They're no longer next recruit
			onRecruitEvent(knowledge);
			var x = intent.x * 55 + boardPos.x;
			var y = intent.y * 55 + boardPos.y;
			var tween = f.newTween(recruitEnt.get(Position), { x:x, y:y }, 0.6, Easing.easeOutQuad);
			f.newActionQueue()
				.waitForProperty(tween, "complete", true)
				.addCallback(function() { 
					f.removeMarker("place-recruit");
				});
				// .removeComponent(f.demandEntity("shadowRecruit"), Invisible);

				// Mark Researcher component as "deployed"
		}
	}

	// Recruit button clicked on
	public function recruitNow(knowledge:Knowledge)
	{
		enableRecruitButton(false);
		knowledge.amount -= 10;
		#if debug
			if(knowledge.amount < 0)
				throw "Knowledge dropped below 0!";
		#end

		var researcher = f.demandEntity("nextRecruit").get(Researcher);
		setStatus('Click on space to deploy ${researcher.name}');
		f.removeMarker("recruiting");
		f.newMarker("place-recruit");

		setRecruitmentMessage(knowledge.amount >= 10
			? "Hiring researcher"
			: EARN_KNOWLEDGE); 
	}

	// Updated the status bar, after placing a researcher, or aborting placement
	public function onRecruitEvent(knowledge:Knowledge)
	{
		var msg = "Remember you can click on a researcher to rotate them";
		if(knowledge.amount >= 10)
		{
			if(f.hasMarker("gameStart"))
				msg = "Recruit another researcher";
			else msg = "Another researcher is available";
		}
		setStatus(msg);

		var researcher = f.getComponent("nextRecruit", Researcher);
		setRecruitmentMessage(researcher == null ? EARN_KNOWLEDGE : researcher.name);
	}

	public function setStatus(message:String)
	{
		f.demandEntity("statusBar").get(StatusBar).setMessage(message);
	}

	public function updatePlacement(knowledge:Knowledge)
	{
		if(f.hasMarker("abort"))
		{
			f.removeMarker("abort");
			f.removeMarker("place-recruit");
			var recruit = f.demandComponent("nextRecruit", Position);
			var model = f.demandComponent("shadowRecruit", Position);
			f.newTween(recruit, {x:model.x, y:model.y}, 0.5);
			knowledge.amount += 10; // return knowledge
			onRecruitEvent(knowledge);
			// Abort sound
		}
		else recruitFollowsMouse();
	}

	public function recruitFollowsMouse()
	{
		var e = f.demandEntity("nextRecruit");
		var pos = e.get(Position);
		var image = e.get(Image);
		pos.x = InputService.mouseX - image.width / 2;
		pos.y = InputService.mouseY - image.height / 2;
	}

	public function checkKnowledge(knowledge:Knowledge)
	{
		if(knowledge.amount >= 10)
		{
			enableRecruitButton(true);
			if(f.entityExists("nextRecruit"))
				return;

			// // Hide shadow recruit
			// f.demandEntity("shadowRecruit")
			// 	.add(Invisible.instance);

			// Show next researcher
			var researcher = new Researcher(Naming.getResearcherName(), Worker);
			f.newSetSingleton("researcher", "nextRecruit")
				.add(new Image("art/researcher.png"))
				.add(researcher);
			setRecruitmentMessage(researcher.name);
		}
	}

	public function setRecruitmentMessage(message:String)
	{
		f.demandEntity("recruitMessage").get(Text).message = message;
	}

	public function enableRecruitButton(enabled:Bool)
	{
		var but = f.demandEntity("button-recruit");
		var alpha = but.get(Alpha);
		alpha.value = (enabled ? 1.0 : 0.5);
	}
}

class PlaceRecruitIntentNode extends Node<PlaceRecruitIntentNode>
{
	public var placeRecruitIntent:PlaceRecruitIntent;
}