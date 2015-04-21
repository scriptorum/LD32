package game.system;

import ash.core.Entity;
import flaxen.component.Text;
import flaxen.core.Flaxen;
import game.system.GameSystem;
import game.component.Progress;
import game.Naming;
import game.node.ProgressNode;

class ProgressSystem extends GameSystem
{
	public function new(f:Flaxen)
	{
		super(f);
	}

	override public function update(ms:Float)
	{		
		for(node in f.ash.getNodeList(ProgressNode))
		{
			// Update visual progress
			node.text.message = Std.string(getLevel(node.progress.value));
		}
	}
}