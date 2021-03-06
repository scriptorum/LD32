/*
This class is a little hard to follow, possibly because of inconsistent practices. 
*/

package game.system;

import ash.core.Entity;
import ash.core.Node;
import flaxen.common.Easing;
import flaxen.component.Alpha;
import flaxen.component.Image;
import flaxen.component.Invisible;
import flaxen.component.Position;
import flaxen.component.Text;
import flaxen.Flaxen;
import game.node.WorkerNode;
import game.node.ResearchNode;
import game.system.GameSystem;
import flaxen.service.InputService;
import game.component.Knowledge;
import game.component.PlaceRecruitIntent;
import game.component.Worker;
import game.component.StatusBar;
import game.Naming;

class RecruitSystem extends GameSystem
{
	public static var EARN_KNOWLEDGE:String = "Earn Knowledge To Gain More Recruits!";

	public function new(f:Flaxen)
	{
		super(f);
	}

	override public function update(ms:Float)
	{
		var knowledge:Knowledge = getKnowledge();

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
			if(workerNode != null)
			{
				setStatus("<smooch>"); // TODO random "inappropriate messages"
				// SFX
				continue;
			}

			// Did you click on research?
			var researchNode:ResearchNode = null;
			for(innerNode in f.ash.getNodeList(ResearchNode))
				if(innerNode.research.x == intent.x && innerNode.research.y == intent.y && innerNode.research.queued == false)
					researchNode = innerNode;
			if(researchNode != null)
			{
				setStatus("Find an empty cubicle!");
				// SFX clink
				continue;
			}

			// Okay you found an empty space
			f.removeMarker("place-recruit");
			onDeployWorker(intent, knowledge);
		}

		if(f.hasMarker("recruiting"))
			recruitNow(knowledge);
		if(f.hasMarker("place-recruit"))
			updatePlacement(knowledge);
		else
			checkKnowledge(knowledge);
	}

	public function onDeployWorker(intent:PlaceRecruitIntent, knowledge:Knowledge)
	{
		var boardPos = f.getEntity("board").get(Position);
		var recruitEnt = f.getEntity("nextRecruit");
		recruitEnt.name = f.generateEntityName("worker#"); // They're no longer next recruit
		onRecruitEvent(knowledge);
		var x = intent.x * 55 + boardPos.x;
		var y = intent.y * 55 + boardPos.y;
		f.newTween(recruitEnt.get(Position), { x:x, y:y }, .4, Easing.easeOutQuad);

		// Mark Worker component as "deployed"
		var worker = recruitEnt.get(Worker);
		worker.x = intent.x;
		worker.y = intent.y;
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

		var worker = f.getEntity("nextRecruit").get(Worker);
		setStatus('Click on space to deploy ${worker.name}');
		f.removeMarker("recruiting");
		f.newMarker("place-recruit");

		setRecruitmentMessage(knowledge.amount >= 10 ? "Hiring worker": EARN_KNOWLEDGE);
	}

	// Updated the status bar, after placing a researcher, or aborting placement
	public function onRecruitEvent(knowledge:Knowledge)
	{
		var worker = f.getComponent("nextRecruit", Worker, false);
		setRecruitmentMessage(worker == null ? EARN_KNOWLEDGE : worker.name);

		var msg = "Place research next to your workers";
		if(knowledge.amount >= 10)
		{
			if(f.hasMarker("gameStart"))
				msg = "Recruit another researcher";
			else msg = "Another researcher is available";
		}

		else if(f.hasMarker("gameStart"))
		{
			f.newMarker("playing");		
			f.removeMarker("gameStart");
			msg = "GO GO GO! Click on empty spaces to place research!";
		}

		setStatus(msg);
	}

	public function updatePlacement(knowledge:Knowledge)
	{
		if(f.hasMarker("abort"))
		{
			f.removeMarker("abort");
			f.removeMarker("place-recruit");
			var recruit = f.getComponent("nextRecruit", Position);
			var model = f.getComponent("shadowRecruit", Position);
			f.newTween(recruit, {x:model.x, y:model.y}, 0.5);
			knowledge.amount += 10; // return knowledge
			onRecruitEvent(knowledge);
			// Abort sound
		}
		else recruitFollowsMouse();
	}

	public function recruitFollowsMouse()
	{
		var e = f.getEntity("nextRecruit", false);
		if(e == null)
			return;
			
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
			if(f.hasEntity("nextRecruit"))
				return;

			// // Hide shadow recruit
			// f.getEntity("shadowRecruit")
			// 	.add(Invisible.instance);

			// Show next worker
			var worker = new Worker(Naming.getWorkerName(), Researcher);
			f.newSetEntity("worker", "nextRecruit")
				.add(new Image("art/researcher.png"))
				.add(worker);
			setRecruitmentMessage(worker.name);
		}
	}

	public function enableRecruitButton(enabled:Bool)
	{
		var but = f.getEntity("button-recruit");
		var alpha = but.get(Alpha);
		alpha.value = (enabled ? 1.0 : 0.5);
		if(enabled)
			f.newMarker("recruitEnabled");
		else f.removeMarker("recruitEnabled");
	}
}

class PlaceRecruitIntentNode extends Node<PlaceRecruitIntentNode>
{
	public var placeRecruitIntent:PlaceRecruitIntent;
}