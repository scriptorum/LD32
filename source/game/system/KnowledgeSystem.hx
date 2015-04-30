package game.system;

import ash.core.Entity;
import flaxen.component.Text;
import flaxen.Flaxen;
import game.system.GameSystem;
import game.component.Knowledge;
import game.Naming;
import game.node.KnowledgeNode;

class KnowledgeSystem extends GameSystem
{
	public function new(f:Flaxen)
	{
		super(f);
	}

	override public function update(ms:Float)
	{
		for(node in f.ash.getNodeList(KnowledgeNode))
		{
			// Update visual knowledge
			node.text.message = Std.string(Std.int(Math.floor(node.knowledge.amount)));
		}
	}
}