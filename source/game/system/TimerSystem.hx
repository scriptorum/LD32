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
			node.text.message = formatTime(node.timer.value);
			if(node.timer.value < 0)
				node.timer.value = 0; // TO DO Game over
		}
	}

	public function formatTime(t:Float): String
	{
		var sec:Int = Math.floor(t);
		var min:Int = 0;
		while(sec > 59)
		{
			sec -= 60;
			min++;
		}

		if(sec < 10)
			return '$min:0$sec';
		return '$min:$sec';
	}
}

class TimerNode extends Node<TimerNode>
{
	public var timer:Timer;
	public var text:Text;
}
