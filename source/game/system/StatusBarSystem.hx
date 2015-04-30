package game.system;

import ash.core.Entity;
import ash.core.Node;
import flaxen.common.Easing;
import flaxen.common.LoopType;
import flaxen.component.Scale;
import flaxen.component.Text;
import flaxen.Flaxen;
import game.system.GameSystem;
import flaxen.util.ArrayUtil;
import game.component.StatusBar;
import game.component.Timer;

class StatusBarSystem extends GameSystem
{
	public var messages = [
		"Your people only work on adjacent research they are facing",
		"A level 2 research block requires twice the work as a level 1",
		"A level 2 researcher works twice as hard as a level 1"
	];

	public function new(f:Flaxen)
	{
		super(f);
	}

	override public function update(ms:Float)
	{
		for(node in f.ash.getNodeList(StatusBarNode))
		{
			var bar = node.statusBar;
			if(!bar.changed)
			{
				var msg = null;

				// Check for timer, offer warning
				var timer = f.getEntity("timer").get(Timer);
				if(timer.value < 8)
					msg = "Hurry up!";

				// Offer random message
				else if(bar.getElapsed() > 10)
					msg = ArrayUtil.anyOneOf(messages);

				if(msg == null)
					continue;

				bar.setMessage(msg);
			}

			bar.changed = false;
			node.text.message = bar.message.toUpperCase();
			node.scale.set(1, 1); // reset to initial scale if necessary
			var tween = f.newTween(node.scale, { x:1.2, y:1.2}, 0.3, Easing.easeOutQuad, Both);
			tween.stopAfterLoops = 8;
		}
	}
}

class StatusBarNode extends Node<StatusBarNode>
{
	public var statusBar:StatusBar;
	public var text:Text;
	public var scale:Scale;
}
