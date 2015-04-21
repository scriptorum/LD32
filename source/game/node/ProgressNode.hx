package game.node;

import ash.core.Node;
import flaxen.component.Text;
import game.component.Progress;

class ProgressNode extends Node<ProgressNode>
{
	public var progress:Progress;
	public var text:Text;
}