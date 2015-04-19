package game.system;

import ash.core.Entity;
import ash.core.Node;
import flaxen.common.Easing;
import flaxen.component.Rotation;
import flaxen.core.Flaxen;
import game.system.GameSystem;
import game.component.RotateWorkerIntent;
import game.component.Researcher;

class WorkSystem extends GameSystem
{
	public function new(f:Flaxen)
	{
		super(f);
	}

	override public function update(ms:Float)
	{
		for(node in f.ash.getNodeList(RotateWorkerNode))
		{
			// You clicked on the board, possibly on a researcher
			var intent = node.intent;
			f.ash.removeEntity(node.entity);

			var researchNode:ResearcherNode = null;
			for(innerNode in f.ash.getNodeList(ResearcherNode))
				if(innerNode.researcher.x == intent.x && innerNode.researcher.y == intent.y)
					researchNode = innerNode;

			// Nope, no worker there
			if(researchNode == null)
				continue;

			var worker = researchNode.researcher;
			if(++worker.rotation > 3)
				worker.rotation = 0;
			var target = worker.rotation * 90;
			if(target == 0)
				target = 360; // Hack to keep a clockwise rotation

			// Rotate worker
			var tween = f.newTween(researchNode.rotation, { angle:target }, 0.5, Easing.easeInQuad);

			// Hack to covert 360 back to 0 angle, so we continue clockwise
			if(target == 360)
				f.newActionQueue()
					.waitForProperty(tween, "complete", true)
					.setProperty(researchNode.rotation, "angle", 0);
		}
	}
}

class RotateWorkerNode extends Node<RotateWorkerNode>
{
	public var intent:RotateWorkerIntent;
}

class ResearcherNode extends Node<ResearcherNode>
{
	public var researcher:Researcher;
	public var rotation:Rotation;
}
