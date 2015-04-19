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

class DemandSystem extends FlaxenSystem
{
	public var totalDemands:Int = 0;

	public function new(f:Flaxen)
	{
		super(f);
	}

	override public function update(ms:Float)
	{
		var demands:Array<String> = f.demandComponent("demandQueue", DemandQueue).demands;

		// TODO check for recruit rewards, add them to queue regardless of demands length

		while(demands.length < 3)
			addDemand(demands);
	}

	public function addDemand(demands:Array<String>)
	{
		var order = totalDemands++;
		// if(order > 99)
		// 	throw "TODO: Victory! Here, your prize is an unhandled exception";

		var total:Int = Math.ceil(totalDemands/5 + 1);
		var distrib:Array<Int> = getDistrib(total);
		var demand = new Demand(Naming.getWeaponName(), order, distrib[0], distrib[1], distrib[2]);
		// trace('Demand:${d.name} $distrib');

		var speed = 0.6;
		var pos = new Position(-140, 495);
		var scale = new Scale(0.1, 0.1);
		var demandEnt = f.newSetEntity("demand", "demand").add(demand).add(pos).add(scale);
		f.newTween(pos, {x:123 + 155 * order, y:495}, speed, Easing.easeInOutQuad);
		f.newTween(scale, { x:1, y:1 }, speed, Easing.easeInOutQuad);
		demands.push(demandEnt.name);
		// demands.unshift(demandEnt.name);

		f.newSetEntity("frontLayer", "demand-text")
			.add(new Image("art/font-card.png"))
			.add(TextStyle.createBitmap(true, Left, Top))
			.add(new Text(demand.name))
			.add(pos)
			.add(scale)
			.add(new Size(130, 77))
			.add(new Offset(5, 5));

		var x = 2; var y = 30; var tx = x + 27; var ty = y + 24;
		addResearch("red", distrib[0], [pos, scale], [new Offset(x, y)], [new Offset(tx, ty)]);  
		addResearch("green", distrib[1], [pos, scale], [new Offset(x+41, y)], [new Offset(tx+41, ty)]);
		addResearch("blue", distrib[2], [pos, scale], [new Offset(x+82, y)], [new Offset(tx+82, ty)]);
	}

	public function addResearch(type:String, amount:Int, shared:Array<Dynamic>, image:Array<Dynamic>,
		text:Array<Dynamic>)
	{
		if(amount <= 0)
			return;

		// Add research icon
		var e1 = f.newSetEntity("frontLayer", "demand-research")
			.add(new Image('art/research-$type.png'));

		// Add text
		var e2 = f.newSetEntity("moreFrontLayer", "demand-research-text")
			.add(new Image("art/font-digits-small.png"))
			.add(new Text(Std.string(amount)))
			.add(TextStyle.createBitmap(false, Center, Center, 0, 0, 0, "0", false, "0123456789"));

		// Add additional components supplied
		for(c in shared)
		{
			e1.add(c);
			e2.add(c);
		}
		for(c in image)
			e1.add(c);
		for(c in text)
			e2.add(c);
	}

	public function getDistrib(total:Int): Array<Int>
	{
		var r = MathUtil.rndInt(0,total);
		var g = MathUtil.rndInt(0,total - r);
		var b = total - r - g;
		return [r, g, b];
	}
}

class DemandNode extends Node<DemandNode>
{
	public var demand:Demand;
}
