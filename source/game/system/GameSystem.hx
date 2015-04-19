package game.system;

import flaxen.component.Text;
import flaxen.core.Flaxen;
import flaxen.core.FlaxenSystem;
import game.component.StatusBar;
import game.node.KnowledgeNode;

class GameSystem extends FlaxenSystem
{
	public function new(f:Flaxen)
	{
		super(f);
	}

	public function setStatus(message:String)
	{
		f.demandEntity("statusBar").get(StatusBar).setMessage(message);
	}

	public function setRecruitmentMessage(message:String)
	{
		f.demandEntity("recruitMessage").get(Text).message = message;
	}
}
