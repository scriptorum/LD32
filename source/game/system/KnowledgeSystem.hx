package game.system;

import ash.core.Entity;
import flaxen.component.Text;
import flaxen.core.Flaxen;
import flaxen.core.FlaxenSystem;
import game.component.Knowledge;
import game.Naming;
import game.node.KnowledgeNode;

class KnowledgeSystem extends FlaxenSystem
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
			node.text.message = Std.string(node.knowledge.amount);
		}
	}
}