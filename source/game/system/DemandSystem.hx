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
import flaxen.component.Tween;
import flaxen.Flaxen;
import game.system.GameSystem;
import flaxen.util.MathUtil;
import game.component.Demand;
import game.component.DemandQueue;
import game.Naming;

class DemandSystem extends GameSystem
{
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
			demands.push(addDemand(demands.length).name);
	}

	// TODO This needs to process new demands similar to the ResearchQueueSystem
	public function addDemand(ordinal:Int): Entity
	{
		// Create demand
		var total:Int = Math.ceil(getLevel(getProgress().value));
		var distrib:Array<Int> = getDistrib(total);
		var demand = new Demand(Naming.getWeaponName(), distrib[0], distrib[1], distrib[2]);

		// Create card, visual representation of demand
		var pos = new Position(610, 495);
		var scale = new Scale(0.1, 0.1);
		var demandEnt = f.newSetEntity("demand", "demand#").add(demand).add(pos).add(scale);
		demand.holder = demandEnt.name;

		// Add description to card 
		var descEnt = f.newSetEntity("frontLayer", demandEnt.name + "-description")
			.add(new Image("art/font-card.png"))
			.add(TextStyle.createBitmap(true, Left, Top))
			.add(new Text(demand.name))
			.add(pos)
			.add(scale)
			.add(new Size(130, 77))
			.add(new Offset(5, 5));
		f.addDependent(demandEnt, descEnt);

		// Add research icons to card
		var x = 2; var y = 30; var tx = x + 27; var ty = y + 24;
		addResearchIcon(demandEnt, "red", distrib[0], [pos, scale], [new Offset(x, y)], [new Offset(tx, ty)]);  
		addResearchIcon(demandEnt, "green", distrib[1], [pos, scale], [new Offset(x+41, y)], [new Offset(tx+41, ty)]);
		addResearchIcon(demandEnt, "blue", distrib[2], [pos, scale], [new Offset(x+82, y)], [new Offset(tx+82, ty)]);

		// Move card into position 
		moveDemandToPosition(demandEnt, ordinal);

		return demandEnt;
	}

	// Moves the demand card to the visual position of the queue (ordinal 0 is far left)
	public function moveDemandToPosition(demandEnt:Entity, ordinal:Int)
	{
		var speed = 0.6;
		var pos = demandEnt.get(Position);
		var scale = demandEnt.get(Scale);
		f.newTween(pos, {x:123 + 155 * ordinal, y:495}, speed, Easing.easeInOutQuad);
		f.newTween(scale, { x:1, y:1 }, speed, Easing.easeInOutQuad);
	}

	public function addResearchIcon(parent:Entity, type:String, amount:Int, shared:Array<Dynamic>, image:Array<Dynamic>,
		text:Array<Dynamic>)
	{
		if(amount <= 0)
			return;

		// Add research icon
		var e1 = f.newSetEntity("frontLayer", parent.name + "-icon-" + type)
			.add(new Image('art/research-$type.png'));
		f.addDependent(parent, e1);

		// Add text
		var e2 = f.newSetEntity("moreFrontLayer", parent.name + "-text-" + type)
			.add(new Image("art/font-digits-small.png"))
			.add(new Text(Std.string(amount)))
			.add(new Data(amount))
			.add(TextStyle.createBitmap(false, Center, Center, 0, 0, 0, "0", false, "0123456789"));
		f.addDependent(parent, e2);

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
		if(total > 27)
			return [9, 9, 9];
		else if(total < 1)
			throw 'Unexpected distribution total: $total';

		var max = (total > 9 ? 9 : total);
		var min = (total > 18 ? total - 18 : 0);
		var r = MathUtil.rndInt(min, max);
		total -= r;

		max = (total > 9 ? 9 : total);
		min = (total > 9 ? total - 9 : 0);
		var g = MathUtil.rndInt(min, max);
		total -= g;

		var b = (total > 9 ? 9 : total);

		return [r, g, b];
	}

	public function updateDemands()
	{
		for(node in f.ash.getNodeList(DemandNode))
		{
			var d = node.demand;

			// Check for demand completed
			if(d.red + d.green + d.blue <= 0)
			{
				setStatus('You\'ve invented ${d.name}!');
				removeDemand(d);
				// TODO Effects
				continue;
			}

			// Check for demand closer to completion
			for(type in ["red", "green", "blue"])
			{
				var ent = f.getEntity(node.entity.name + "-text-" + type, false);
				if(ent == null) 
					continue;

				var data:Data = ent.get(Data);
				var current:Int = cast data.value;
				var actual:Int = Std.int(Math.ceil(d.getValueFor(type)));
				if(current != actual)
				{
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

	public function removeDemand(d:Demand)
	{
		// Find demand's position in queue
		var demands:Array<String> = getDemandQueue();
		var pos = demands.indexOf(d.holder);
		if(pos == -1)
			throw "Cannot find demand in queue";

		// Remove card from list
		demands.remove(d.holder);		

		// Slide removed card to difficulty icon
		var speed = 0.7;
		var e = f.getEntity(d.holder);
		e.remove(Demand);
		f.newTween(e.get(Position), { x:88, y:292 }, speed);
		f.newTween(e.get(Scale), { x:0.1, y:0.1 }, speed);
		f.newActionQueue()
			.wait(speed)
			.removeEntity(e)
			.call(function() { getProgress().value++; });

		// Slide right most cards to the left
		for(i in pos...demands.length)
			moveDemandToPosition(f.getEntity(demands[i]), i);
	}
}

class DemandNode extends Node<DemandNode>
{
	public var demand:Demand;
}
