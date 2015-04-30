package game.system;

import ash.core.Entity;
import ash.core.Node;
import flaxen.common.Easing;
import flaxen.component.ActionQueue;
import flaxen.component.Image;
import flaxen.component.Offset;
import flaxen.component.Position;
import flaxen.component.Scale;
import flaxen.component.Rotation;
import flaxen.common.TextAlign;
import flaxen.component.Tween;
import flaxen.Flaxen;
import game.system.GameSystem;
import game.component.Research;
import game.component.ResearchQueue;

class ResearchQueueSystem extends GameSystem
{
	public static var flaskData = [{ x:16, y:282, angle:0, scale:0.8 }, 
		{ x:21, y:321, angle:15, scale:1.2 }, { x:27, y:360, angle:30, scale:1.75 }];

	public function new(f:Flaxen)
	{
		super(f);
	}

	override public function update(ms:Float)
	{		
		if(!f.hasMarker("playing") && !f.hasMarker("gameStart"))
			return;

		var queue:Array<String> = getResearchQueue();

		while(queue.length < 3)
			addResearch(queue);
	}

	public function addResearch(queue:Array<String>)
	{
		var research = Research.random();
		research.level = getLevel();

		var e1 = f.newSetEntity("research", "research#")
			.add(new Image('art/research-${research.type}.png'))
			.add(research)
			.add(new ActionQueue(f));
		queue.unshift(e1.name);
		tweenToFlask(e1, 0);
	
		// If other flasks ahead in queue, push them to next flask position	
		if(queue.length > 1) for(i in 1...queue.length)
		{
			var flaskEnt = f.getEntity(queue[i]);
			tweenToFlask(flaskEnt, i);
		}
	}

	public function tweenToFlask(e:Entity, flask:Int)
	{
		if(flask > 2)
			throw 'Cannot tween to flask $flask';
		var speed = 0.2;
		var data = flaskData[flask];
		var aq = e.get(ActionQueue);
		var tween:Tween = null;
		aq.call(function()
		{
			tween = f.newTween(e.get(Position), { x:data.x, y:data.y }, speed);
			f.newTween(e.get(Scale), { x:data.scale, y:data.scale }, speed);
			f.newTween(e.get(Rotation), { angle:data.angle }, speed);
			aq.waitForProperty(tween, "complete", true, true); // make priority
		});
	}
}