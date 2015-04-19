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
import game.node.WorkerNode;
import game.system.GameSystem;
import flaxen.service.InputService;
import game.component.Knowledge;
import game.component.PlaceRecruitIntent;
import game.component.Worker;
import game.component.StatusBar;
import game.Naming;
import game.node.KnowledgeNode;

class RecruitSystem extends GameSystem
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

		// Clicked on an empty space while holding a worker
		for(node in f.ash.getNodeList(PlaceRecruitIntentNode))
		{
			f.ash.removeEntity(node.entity); // remove intent entity holder
			var intent = node.placeRecruitIntent;

			// Is there a worker already there?
			var workerNode:WorkerNode = null;
			for(innerNode in f.ash.getNodeList(WorkerNode))
				if(innerNode.worker.x == intent.x && innerNode.worker.y == intent.y)
					workerNode = innerNode;
			if(workerNode == null)
			{
				f.removeMarker("place-recruit");
				onDeployWorker(intent, knowledge);
				continue;
			}
			else
			{
				// SFX
			}
		}
	}

	public function onDeployWorker(intent:PlaceRecruitIntent, knowledge:Knowledge)
	{
		var boardPos = f.demandEntity("board").get(Position);
		var recruitEnt = f.demandEntity("nextRecruit");
		recruitEnt.name = f.getEntityName("worker"); // They're no longer next recruit
		onRecruitEvent(knowledge);
		var x = intent.x * 55 + boardPos.x;
		var y = intent.y * 55 + boardPos.y;
		var tween = f.newTween(recruitEnt.get(Position), { x:x, y:y }, 0.6, Easing.easeOutQuad);
		f.newActionQueue()
			.waitForProperty(tween, "complete", true)
			.addCallback(function() { 
				f.removeMarker("place-recruit");
			});

		// Mark Worker component as "deployed"
		var worker = recruitEnt.get(Worker);
		worker.x = intent.x;
		worker.y = intent.y;

		// TODO auto rotate to face some research	
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

		var worker = f.demandEntity("nextRecruit").get(Worker);
		setStatus('Click on space to deploy ${worker.name}');
		f.removeMarker("recruiting");
		f.newMarker("place-recruit");

		setRecruitmentMessage(knowledge.amount >= 10 ? "Hiring worker": EARN_KNOWLEDGE);
	}

	// Updated the status bar, after placing a researcher, or aborting placement
	public function onRecruitEvent(knowledge:Knowledge)
	{
		var msg = "Remember you can click on a worker to rotate them";
		if(knowledge.amount >= 10)
		{
			if(f.hasMarker("gameStart"))
				msg = "Recruit another researcher";
			else msg = "Another  is available";
		}
		setStatus(msg);

		var worker = f.getComponent("nextRecruit", Worker);
		setRecruitmentMessage(worker == null ? EARN_KNOWLEDGE : worker.name);
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

			// Show next worker
			var worker = new Worker(Naming.getWorkerName(), Researcher);
			f.newSetSingleton("worker", "nextRecruit")
				.add(new Image("art/researcher.png"))
				.add(worker);
			setRecruitmentMessage(worker.name);
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