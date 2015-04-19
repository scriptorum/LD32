package game.system;

import ash.core.Entity;
import ash.core.Node;
import flaxen.component.Text;
import flaxen.core.Flaxen;
import flaxen.core.FlaxenSystem;
import game.component.Timer;

class TimerSystem extends FlaxenSystem
{
	public function new(f:Flaxen)
	{
		super(f);
	}

	override public function update(ms:Float)
	{
		for(node in f.ash.getNodeList(TimerNode))
		{
			node.timer.value -= ms;
			var t = Math.ceil(node.timer.value);
			var sec = t - Math.floor(t/60) * 60;
			var min = Math.floor((t - sec) / 60);
			f.demandComponent("timer-sec", Text).message = Std.string(sec < 10 ? '0$sec' : sec);
			f.demandComponent("timer-min", Text).message = Std.string(min);

			if(node.timer.value < 0)
				node.timer.value = 0; // TO DO Game over
		}
	}
}

class TimerNode extends Node<TimerNode>
{
	public var timer:Timer;
}
