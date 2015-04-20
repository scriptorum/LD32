package game.system;

import ash.core.Entity;
import ash.core.Node;
import flaxen.common.Easing;
import flaxen.component.ActionQueue;
import flaxen.component.Alpha;
import flaxen.component.Data;
import flaxen.component.Image;
import flaxen.component.Offset;
import flaxen.component.Position;
import flaxen.component.Scale;
import flaxen.component.Size;
import flaxen.component.Text;
import flaxen.common.TextAlign;
import flaxen.core.Flaxen;
import game.system.GameSystem;
import flaxen.util.MathUtil;
import game.component.Demand;
import game.component.DemandQueue;
import game.Naming;

class DemandSystem extends GameSystem
{
	public var totalDemands:Int = 0;

	public function new(f:Flaxen)
	{
		super(f);
	}

	override public function update(ms:Float)
	{
		updateDemands();
		keepDemandsComing();
	}

	public function keepDemandsComing()
	{
		// TODO There should be a delay between issuing new demands
		var demands:Array<String> = getDemandQueue();
		while(demands.length < 3)
			demands.push(addDemand().name);
	}

	// TODO This needs to process new demands similar to the ResearchQueueSystem
	public function addDemand(): Entity
	{
		var id = totalDemands++;
		// TODO Check for reaching a large number of demands. Give victory!

		var total:Int = Math.ceil(totalDemands/5 + 1);
		var distrib:Array<Int> = getDistrib(total);
		var demand = new Demand(Naming.getWeaponName(), id, distrib[0], distrib[1], distrib[2]);
		// trace('Demand:${d.name} $distrib');

		var speed = 0.6;
		var pos = new Position(-140, 495);
		var scale = new Scale(0.1, 0.1);
		var demandEnt = f.newSetEntity("demand", "demand").add(demand).add(pos).add(scale);
		f.newTween(pos, {x:123 + 155 * id, y:495}, speed, Easing.easeInOutQuad);
		f.newTween(scale, { x:1, y:1 }, speed, Easing.easeInOutQuad);

		f.newSetSingleton("frontLayer", demandEnt.name + "-description")
			.add(new Image("art/font-card.png"))
			.add(TextStyle.createBitmap(true, Left, Top))
			.add(new Text(demand.name))
			.add(pos)
			.add(scale)
			.add(new Size(130, 77))
			.add(new Offset(5, 5));

		var x = 2; var y = 30; var tx = x + 27; var ty = y + 24;
		addResearchIcon(demandEnt.name, "red", distrib[0], [pos, scale], [new Offset(x, y)], [new Offset(tx, ty)]);  
		addResearchIcon(demandEnt.name, "green", distrib[1], [pos, scale], [new Offset(x+41, y)], [new Offset(tx+41, ty)]);
		addResearchIcon(demandEnt.name, "blue", distrib[2], [pos, scale], [new Offset(x+82, y)], [new Offset(tx+82, ty)]);

		return demandEnt;
	}

	public function addResearchIcon(parent:String, type:String, amount:Int, shared:Array<Dynamic>, image:Array<Dynamic>,
		text:Array<Dynamic>)
	{
		if(amount <= 0)
			return;

		// Add research icon
		var e1 = f.newSetSingleton("frontLayer", parent + "-icon-" + type)
			.add(new Image('art/research-$type.png'));

		// Add text
		var e2 = f.newSetSingleton("moreFrontLayer", parent + "-text-" + type)
			.add(new Image("art/font-digits-small.png"))
			.add(new Text(Std.string(amount)))
			.add(new Data(amount))
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

	public function updateDemands()
	{
		for(node in f.ash.getNodeList(DemandNode))
		{
			var d = node.demand;
			if(d.completed)
				continue; // temporary HACK

			// Check for demand completed
			if(d.red + d.green + d.blue <= 0)
			{
				trace('Completed ${node.entity.name}: ${d.name}');
				// TODO Remove demand
				setStatus('You\'ve invented ${d.name}!');
				d.completed = true; // temporary
				continue;
			}

			// Check for demand closer to completion
			for(type in ["red", "green", "blue"])
			{
				var ent = f.getEntity(node.entity.name + "-text-" + type);
				if(ent == null) 
					continue;

				var data:Data = ent.get(Data);
				var current:Int = cast data.value;
				var actual:Int = Std.int(Math.ceil(d.getValueFor(type)));
				if(current != actual)
				{
					trace('Updating icon number. Actual:$actual current:$current name:${ent.name}');
					if(actual == 0) // destroy research icon
					{						
						f.removeEntity(node.entity.name + "-icon-" + type); // remove flask
						f.ash.removeEntity(ent); // remove flask text
					}
					else // update icon
					{
						ent.get(Text).message = Std.string(actual);
						data.value = actual;
					}
					// TODO FX?
				}
			}
		}
	}
}

class DemandNode extends Node<DemandNode>
{
	public var demand:Demand;
}
