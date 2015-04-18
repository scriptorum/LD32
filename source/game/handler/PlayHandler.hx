package game.handler; 

import com.haxepunk.utils.Key;
import flaxen.component.Image;
import flaxen.component.Layer;
import flaxen.component.Offset;
import flaxen.component.Position;
import flaxen.component.Size;
import flaxen.component.Text;
import flaxen.core.Flaxen;
import flaxen.core.FlaxenHandler;
import flaxen.core.Log;
import flaxen.common.TextAlign;
import flaxen.service.InputService;
import game.component.Timer;

class PlayHandler extends FlaxenHandler
{
	public var f:Flaxen;

	public function new(f:Flaxen)
	{
		super();
		this.f = f;
	}

	override public function start(_)
	{
		initSystems();
		initEntities();
	}

	private function initSystems()
	{
		f.addSystem(new game.system.TimerSystem(f));
	}

	private function initEntities()
	{
		var bgLayer = new Layer(100);
		f.newEntity().add(new Image("art/main.png")).add(Position.zero()).add(bgLayer);
		f.newEntity().add(new Image("art/timer.png")).add(new Position(0, 480)).add(bgLayer);


		f.newComponentSet("timer")
			.add(new Image("art/font-digits.png"))
			.add(TextStyle.createBitmap(false, Right, Center, 0, 0, 0, 23, true, "0123456789:"))
			.add(new Layer(20));
		for(val in [
			{text:"2", x:50, id:"timer-min" }, 
			{text:"00", x:100, id:"timer-sec" },
			{text:":", x:69, id:"timer-colon"} ])
				f.newSetSingleton("timer", val.id)
					.add(new Text(val.text))
					.add(new Position(val.x, 540));
		f.newSingleton("timer")
			.add(new Timer(120));

		for(i in 0...30)
			trace(game.Naming.getName());
	}

	override public function update(_)
	{
		var key = InputService.lastKey();

		#if (debug && desktop)
		if(key == Key.D)
		{
			trace("Dumping log(s)");
			flaxen.util.LogUtil.dumpLog(f, Sys.getCwd() + "entities.txt");
			for(setName in f.getComponentSetKeys())
				trace(setName + ":{" + f.getComponentSet(setName) + "}");
		}
		#end

		InputService.clearLastKey();
	}
}
