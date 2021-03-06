// Shared parent system
package game.system;

import flaxen.common.Easing;
import flaxen.component.ActionQueue;
import flaxen.component.Rotation;
import flaxen.component.Text;
import ash.core.Entity;
import flaxen.component.Tween;
import flaxen.Flaxen;
import flaxen.FlaxenSystem;
import flaxen.util.ArrayUtil;
import game.component.Progress;
import game.component.Research;
import game.component.ResearchQueue;
import game.component.StatusBar;
import game.component.DemandQueue;
import game.component.Worker;
import game.component.Knowledge;
import game.node.KnowledgeNode;
import game.node.ResearchNode;

class GameSystem extends FlaxenSystem
{
	public static inline var PROGRESS_PER_LEVEL:Int = 5;

	public function new(f:Flaxen)
	{
		super(f);
	}

	public function getLevel(?progress:Int): Int
	{
		if(progress == null) progress = getProgress().value;
		var level:Float = progress / 5 + 1;
		return Std.int(Math.floor(level));
	}

	public function setStatus(message:String)
	{
		f.getEntity("statusBar").get(StatusBar).setMessage(message);
	}

	public function setRecruitmentMessage(message:String)
	{
		f.getEntity("recruitMessage").get(Text).message = message;
	}

	public function getKnowledge(): Knowledge
	{
		for(node in f.ash.getNodeList(KnowledgeNode))
			return node.knowledge;
		return null;
	}

	public function getProgress(): Progress
	{
		return f.getComponent("progress", Progress);
	}

	public function getResearchQueue(): Array<String>
	{
		return f.getComponent("researchQueue", ResearchQueue).queue;	
	}

	public function getDemandQueue(): Array<String>
	{
		return f.getComponent("demandQueue", DemandQueue).queue;	
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
		worker.busy = true;
		var rotation = e.get(Rotation);
		var target = worker.rotation * 90;
		var current = rotation.angle;

		var actualTarget = target;
		if(current == 0 && target == 270)
			target = -90;
		else if (current == 270 && target == 0)
			target = 360;

		// Rotate worker
		var tween = new Tween(rotation, { angle:target }, 0.5, Easing.easeInQuad);
		var aq = new ActionQueue(f).waitForProperty(tween, "complete", true);
		if(actualTarget != target)
			aq.setProperty(rotation, "angle", actualTarget);
		aq.setProperty(worker, "busy", false);
		aq.onComplete = DestroyEntity;

		// Ensure there is only one aq/tween going on for this worker, replace components
		f.resolveEntity(e.name + "_alignWorker").add(tween).add(aq);
	}
}
