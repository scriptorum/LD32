package game.system;

import ash.core.Entity;
import ash.core.Node;
import flaxen.common.Easing;
import flaxen.common.LoopType;
import flaxen.component.Scale;
import flaxen.component.Text;
import flaxen.core.Flaxen;
import flaxen.core.FlaxenSystem;
import game.component.StatusBar;

class StatusBarSystem extends FlaxenSystem
{
	public function new(f:Flaxen)
	{
		super(f);
	}

	override public function update(ms:Float)
	{
		for(node in f.ash.getNodeList(StatusBarNode))
		{
			if(!node.statusBar.changed)
				continue;

			node.statusBar.changed = false;
			var sb = f.demandEntity("statusBar");
			sb.get(Text).message = node.statusBar.message.toUpperCase();
			var tween = f.newTween(sb.get(Scale), { x:1.2, y:1.2}, 0.3, Easing.easeOutQuad, Both);
			tween.stopAfterLoops = 8;
		}
	}
}

class StatusBarNode extends Node<StatusBarNode>
{
	public var statusBar:StatusBar;
}
