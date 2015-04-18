package game.system;

import ash.core.Entity;
import ash.core.Node;
import flaxen.component.Text;
import flaxen.core.Flaxen;
import flaxen.core.FlaxenSystem;
import game.component.Timer;

class DemandQueueSystem extends FlaxenSystem
{
	public function new(f:Flaxen)
	{
		super(f);
	}

	override public function update(ms:Float)
	{
		// for(node in f.ash.getNodeList(TimerNode))
		// {
		// }
	}
}

// class TimerNode extends Node<TimerNode>
// {
// 	public var timer:Timer;
// }
