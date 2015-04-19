package game.system;

import ash.core.Entity;
import ash.core.Node;
import flaxen.common.Easing;
import flaxen.component.Alpha;
import flaxen.component.Image;
import flaxen.component.Invisible;
import flaxen.component.Position;
import flaxen.core.Flaxen;
import flaxen.core.FlaxenSystem;
import game.component.Knowledge;
import game.component.PlaceRecruitIntent;
import game.component.Researcher;
import game.Naming;
import game.node.KnowledgeNode;

class RecruitSystem extends FlaxenSystem
{
	public function new(f:Flaxen)
	{
		super(f);
	}

	override public function update(ms:Float)
	{
		for(node in f.ash.getNodeList(KnowledgeNode))
		{
			if(f.hasMarker("recruiting"))
				recruitNow(node.knowledge);
			else checkKnowledge(node.knowledge);
		}

		for(node in f.ash.getNodeList(PlaceRecruitIntentNode))
		{
			var intent = node.placeRecruitIntent;
			f.ash.removeEntity(node.entity);
			var boardPos = f.demandEntity("board").get(Position);
			var recruitEnt = f.demandEntity("nextRecruit");
			recruitEnt.name = f.getEntityName("researcher");
			var x = intent.x * 55 + boardPos.x;
			var y = intent.y * 55 + boardPos.y;
			var tween = f.newTween(recruitEnt.get(Position), { x:x, y:y }, 0.6, Easing.easeOutQuad);
			f.newActionQueue()
				.waitForProperty(tween, "complete", true)
				.removeComponent(f.demandEntity("shadowRecruit"), Invisible);

				// Mark Researcher component as "deployed"
		}
	}

	public function recruitNow(knowledge:Knowledge)
	{
		enableRecruitButton(false);
		knowledge.amount -= 10;
		#if debug
			if(knowledge.amount < 0)
				throw "Knowledge dropped below 0!";
		#end

		// Set "CLICK ON SPACE TO PLACE RESEARCHER" message
		f.removeMarker("recruiting");
		f.newMarker("place-recruit");
		// TODO Move recruit image along with cursor
	}

	public function checkKnowledge(knowledge:Knowledge)
	{
		if(knowledge.amount >= 10)
		{
			enableRecruitButton(true);
			if(f.entityExists("nextRecruit"))
				return;

			// Hide shadow recruit
			f.demandEntity("shadowRecruit")
				.add(Invisible.instance);

			// Show next researcher
			var researcher = new Researcher(Naming.getResearcherName(), Researcher);
			f.newSetSingleton("researcher", "nextRecruit")
				.add(new Image("art/researcher.png"))
				.add(researcher);
		}
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