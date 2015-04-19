package game.system;

import game.component.Research;
import game.component.Worker;
import game.node.WorkerNode;
import game.system.GameSystem;
import flaxen.core.Flaxen;

class WorkSystem extends GameSystem
{
	public function new(f:Flaxen)
	{
		super(f);
	}

	override public function update(ms:Float)
	{
		// Make sure all researchers are working
		for(node in f.ash.getNodeList(WorkerNode))
		{
			if(node.worker.research == null)
			{
				var research = findNeighboringResearch(node.worker);
				if(research == null)
					continue; // TODO at random intervals, spin in chair

				node.worker.research = research;
				node.worker.rotation = getRotation(node.worker, research);
				alignWorker(node.entity, node.worker);
			}
		}
	}

	public function getRotation(worker:Worker, research:Research): Int
	{
		if(research.y > worker.y) 
			return 0;
		else if(research.x < worker.x) 
			return 1;
		else if(research.y < worker.y) 
			return 2;
		else return 3;
	}
}