package game.node;

import ash.core.Node;
import flaxen.component.Text;
import game.component.Knowledge;

class KnowledgeNode extends Node<KnowledgeNode>
{
	public var knowledge:Knowledge;
	public var text:Text;
}