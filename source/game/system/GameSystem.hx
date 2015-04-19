package game.system;

import flaxen.common.Easing;
import flaxen.component.Rotation;
import flaxen.component.Text;
import ash.core.Entity;
import flaxen.core.Flaxen;
import flaxen.core.FlaxenSystem;
import flaxen.util.ArrayUtil;
import game.component.Research;
import game.component.ResearchQueue;
import game.component.StatusBar;
import game.component.Worker;
import game.node.KnowledgeNode;
import game.node.ResearchNode;

class GameSystem extends FlaxenSystem
{
	public function new(f:Flaxen)
	{
		super(f);
	}

	public function setStatus(message:String)
	{
		f.demandEntity("statusBar").get(StatusBar).setMessage(message);
	}

	public function setRecruitmentMessage(message:String)
	{
		f.demandEntity("recruitMessage").get(Text).message = message;
	}

	public function getResearchQueue(): Array<String>
	{
		return f.demandComponent("researchQueue", ResearchQueue).queue;	
	}

	public function findNeighboringResearch(worker:Worker): Research
	{
		var offsets = [ {x:0, y:1}, {x:-1, y:0}, {x:0, y:-1}, {x:1, y:0} ]; // Sort neighbors clockwise
		var i = 0;
		while(i++ < worker.rotation)
			offsets.push(offsets.shift()); // Rotate values until we reach worker's facing

		for(offset in offsets)
		{
			var x = worker.x + offset.x;
			if(x < 0 || x > 8) continue;
			var y = worker.y + offset.y;
			if(y < 0 || y > 8) continue;

			var researchNode:ResearchNode = null;
			for(innerNode in f.ash.getNodeList(ResearchNode))
				if(innerNode.research.x == x && innerNode.research.y == y && innerNode.research.queued == false)
					return innerNode.research;
		}

		return null;
	}

	public function alignWorker(e:Entity, worker:Worker)
	{
		var rotation = e.get(Rotation);
		var target = worker.rotation * 90;
		var current = rotation.angle;

		var actualTarget = target;
		if(current == 0 && target == 270)
			target = -90;
		else if (current == 270 && target == 0)
			target = 360;

		var tweenName = e.name + "_alignWorker";

		// Rotate worker
		if(f.entityExists(tweenName))
			f.removeEntity(tweenName);
		var tween = f.newTween(rotation, { angle:target }, 0.5, Easing.easeInQuad, null, true, tweenName);

		if(actualTarget != target)
			f.newActionQueue()
				.waitForProperty(tween, "complete", true)
				.setProperty(rotation, "angle", actualTarget);
	}
}
