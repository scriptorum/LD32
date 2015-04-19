package game.system;

import ash.core.Entity;
import ash.core.Node;
import flaxen.common.Easing;
import flaxen.component.ActionQueue;
import flaxen.component.Position;
import flaxen.component.Rotation;
import flaxen.component.Scale;
import flaxen.core.Flaxen;
import game.component.Research;
import game.system.GameSystem;
import game.component.ActivateCellIntent;
import game.component.Worker;

class WorkSystem extends GameSystem
{
	public function new(f:Flaxen)
	{
		super(f);
	}

	override public function update(ms:Float)
	{
		for(node in f.ash.getNodeList(ActivateCellNode))
		{
			// You clicked on the board, possibly on a worker
			var intent = node.intent;
			f.ash.removeEntity(node.entity);

			// Did you click on a worker?
			var workerNode:WorkerNode = null;
			for(innerNode in f.ash.getNodeList(WorkerNode))
				if(innerNode.worker.x == intent.x && innerNode.worker.y == intent.y)
					workerNode = innerNode;
			if(workerNode != null)
			{
				onClickWorker(workerNode);
				continue;
			}

			// Did you click on research?
			var researchNode:ResearchNode = null;
			for(innerNode in f.ash.getNodeList(ResearchNode))
				if(innerNode.research.x == intent.x && innerNode.research.y == intent.y && innerNode.research.queued == false)
					researchNode = innerNode;
			if(researchNode != null)
			{
				onClickResearch(researchNode);
				continue;
			}


			// You must have clicked on an empty space!
			onClickEmpty(intent);
		}
	}


	// Send research there
	public function onClickEmpty(intent:ActivateCellIntent)
	{
		var queue:Array<String> = getResearchQueue();
		if(queue.length < 3)
			return; // TODO sfx

		var flaskEnt = f.getEntity(queue.pop());
		var aq = flaskEnt.get(ActionQueue);
		if(!aq.complete)
		{ 
			queue.push(flaskEnt.name); // put name back in queue, tsk tsk
			return; // TODO sfx
		}

		// Move flask to board
		var boardPos = f.demandComponent("board", Position);
		f.newTween(flaskEnt.get(Position), { x:intent.x * 55 + boardPos.x, y:intent.y * 55 + boardPos.y }, 0.4);
		f.newTween(flaskEnt.get(Scale), { x:1, y:1 }, 0.4);
		f.newTween(flaskEnt.get(Rotation), { angle: 0 }, 0.4);
		var research = flaskEnt.get(Research);
		research.queued = false;
		research.x = intent.x;
		research.y = intent.y;

		// TODO Splash
	}

	// Bubbles?
	public function onClickResearch(researchNode:Node<ResearchNode>)
	{
	}

	// Rotate the worker
	public function onClickWorker(workerNode:WorkerNode)
	{
		var worker = workerNode.worker;
		if(++worker.rotation > 3)
			worker.rotation = 0;
		var target = worker.rotation * 90;
		if(target == 0)
			target = 360; // Hack to keep a clockwise rotation

		// Rotate worker
		var tween = f.newTween(workerNode.rotation, { angle:target }, 0.5, Easing.easeInQuad);

		// Hack to covert 360 back to 0 angle, so we continue clockwise
		if(target == 360)
			f.newActionQueue()
				.waitForProperty(tween, "complete", true)
				.setProperty(workerNode.rotation, "angle", 0);
	}
}

class ActivateCellNode extends Node<ActivateCellNode>
{
	public var intent:ActivateCellIntent;
}

class WorkerNode extends Node<WorkerNode>
{
	public var worker:Worker;
	public var rotation:Rotation;
}

class ResearchNode extends Node<ResearchNode>
{
	public var research:Research;
}
