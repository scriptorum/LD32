package game.system;

import game.component.Demand;
import game.component.Research;
import game.component.Worker;
import game.node.WorkerNode;
import game.node.ResearchNode;
import game.system.GameSystem;
import flaxen.core.Flaxen;

class WorkSystem extends GameSystem
{
	public static inline var MS_RESEARCH:Float = 3; // 1 research unit = 3 ms of work

	public function new(f:Flaxen)
	{
		super(f);
	}

	override public function update(ms:Float)
	{
		getToWork(ms);
		inventStuff();
	}

	public function getToWork(ms:Float)
	{
		for(node in f.ash.getNodeList(WorkerNode))
		{
			var w = node.worker;

			// Make sure all researchers are working
			if(w.research == null)
			{
				var research = findNeighboringResearch(w);
				if(research == null)
					continue; // TODO at random intervals, spin in chair

				w.research = research;
				w.rotation = getRotation(w, research);
				alignWorker(node.entity, w);
			}

			// Worker needs new research
			else if(w.research.complete == true)
				w.research = null; 

			// Worker contributes to their research focus * worker level
			else if(!w.busy)
			{
				var amount = ms / MS_RESEARCH * w.level;
				w.research.amount += amount;
				if(w.research.amount > w.research.level)
					w.research.amount = w.research.level; // Cap at max
			}
		}
	}

	public function inventStuff()
	{
		// Check if any research is complete
		for(node in f.ash.getNodeList(ResearchNode))
		{
			var r = node.research;

			// This research is complete!
			var target = r.level;
			if(r.amount >= target)
			{
				trace('Completed work activity ${r.type} amount:${r.amount} target:$target');
				// Apply research to leftmost demand that needs it
				var excess = r.amount;
				for(demandName in getDemandQueue())
				{
					var demand = f.demandComponent(demandName, Demand);
					var val = demand.getValueFor(r.type);
					if(val > 0)
					{
						var newVal = (excess > val ? 0 : val - excess); // compete demand step or reduce it?
						excess = (excess > val ? excess - val : 0); // leave excess or consume all research?
						demand.setValueFor(r.type, newVal);
						trace('		Excess:$excess remainingDemand:$newVal');
						// TODO FX
						break;
					}
				}

				// Apply excess research to general knowledge
				if(excess > 0)
				{
					var knowledge = getKnowledge();
					knowledge.amount += excess;
				}

				// Remove research
				r.complete = true;
				ash.removeEntity(node.entity);

				// TODO break flask into little bits and send each bit to demand or to knowledge meter
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