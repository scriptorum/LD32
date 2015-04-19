package game.system;

import ash.core.Entity;
import ash.core.Node;
import flaxen.common.Easing;
import flaxen.component.ActionQueue;
import flaxen.component.Alpha;
import flaxen.component.Image;
import flaxen.component.Offset;
import flaxen.component.Position;
import flaxen.component.Scale;
import flaxen.component.Size;
import flaxen.component.Text;
import flaxen.common.TextAlign;
import flaxen.core.Flaxen;
import flaxen.core.FlaxenSystem;
import flaxen.util.MathUtil;
import game.component.Demand;
import game.component.DemandQueue;
import game.Naming;

class RecruitSystem extends FlaxenSystem
{
	public function new(f:Flaxen)
	{
		super(f);
	}

	override public function update(ms:Float)
	{
		
	}
}