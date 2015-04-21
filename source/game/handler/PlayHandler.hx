/*
 KNOWN:
 	- How do I track the research pool again?
 	    a) When a research box is complete it turns into a box. Click on the box to send it to the leftmost demand card
 	       that needs it. The necessary amounts are used by the card, and if there's any excess they go to the
 	       knowledge meter.
 	- How do I do promotions again?
 	    a) Workers should auto-promote after X research
 	    b) Promote button should be available after 5 knowledge
 	    c) Promote cost is relative to level of researcher
 	- Random luck: A worker may quit after a time?
	- I'm concerned that the current scheme of letting you choose where to put a block may be too generous.
	  Perhaps you need to place or move a dolly to and blocks are placed automatically. This could create
	  another consequence by having unplaced research destroyed, either dinging the timer, or leaving
	  a stack of papers which permanently blocks the board, or can only be removed by assigning workers to 
	  it "busy work."
	 - If you recruit while the prior worker is still tweening, the new recruit sticks and/or disappears.
*/


package game.handler; 

import ash.core.Entity;
import com.haxepunk.utils.Key;
import flaxen.common.TextAlign;
import flaxen.component.Alpha;
import flaxen.component.Image;
import flaxen.component.Layer;
import flaxen.component.Offset;
import flaxen.component.Origin;
import flaxen.component.Position;
import flaxen.component.Rotation;
import flaxen.component.Scale;
import flaxen.component.Size;
import flaxen.component.Text;
import flaxen.core.Flaxen;
import flaxen.core.FlaxenHandler;
import flaxen.core.Log;
import flaxen.service.InputService;
import game.component.DemandQueue;
import game.component.Progress;
import game.component.ResearchQueue;
import game.component.Knowledge;
import game.component.PlaceRecruitIntent;
import game.component.ActivateCellIntent;
import game.component.StatusBar;
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
		initSets();
		initSystems();
		initEntities();
	}

	private function initSets()
	{
		var bgLayer = f.newComponentSet("bgLayer")
			.add(new Layer(100));
			
		var backLayer = f.newComponentSet("backLayer")
			.add(new Layer(90));
			
		var midLayer = f.newComponentSet("midLayer")
			.add(new Layer(80));
			
		var frontLayer = f.newComponentSet("frontLayer")
			.add(new Layer(60));
			
		var moreFrontLayer = f.newComponentSet("moreFrontLayer")
			.add(new Layer(55));
			
		var fxLayer = f.newComponentSet("fxLayer")
			.add(new Layer(40));
			
		f.newComponentSet("demand")
			.add(new Image("art/demand.png"))
			.addSet(midLayer);

		f.newComponentSet("timer")
			.add(new Image("art/font-digits.png"))
			.add(TextStyle.createBitmap(false, Right, Center, 0, 0, 0, 23, true, "0123456789:"))
			.addSet(midLayer);

		f.newComponentSet("message")
			.add(new Image("art/font-message.png"))
			.add(TextStyle.createBitmap(true, Center, Center, -2, 0, 0, 4))
			.addSet(midLayer);

		f.newComponentSet("worker")
			.addSet(midLayer)
			.add(Origin.center())
			.addClass(Rotation, [0])
			.addClass(Position, [28, 130]);

		f.newComponentSet("research") // needs image and research, also shadow
			.add(Origin.center())
			.addClass(Rotation, [-15])
			.addClass(Position, [-55, 230])
			.addClass(Scale, [0.5, 0.5])
			.add(backLayer);

		f.newComponentSet("bookfont")
			.addSet(midLayer)
			.addClass(Text, ["0"])
			.add(new Image("art/font-book.png"))
			.add(TextStyle.createBitmap(false, Center, Center, 0, 0, 0, "0", false, "0123456789"));
	}

	private function initSystems()
	{
		f.addSystem(new game.system.RecruitSystem(f));
		f.addSystem(new game.system.ActivationSystem(f));
		f.addSystem(new game.system.ResearchQueueSystem(f));
		f.addSystem(new game.system.DemandSystem(f));
		f.addSystem(new game.system.TimerSystem(f));
		f.addSystem(new game.system.WorkSystem(f));
		f.addSystem(new game.system.KnowledgeSystem(f));
		f.addSystem(new game.system.ProgressSystem(f));
		f.addSystem(new game.system.StatusBarSystem(f));
	}

	private function initEntities()
	{
		// Background
		f.newSetEntity("bgLayer")
			.add(new Image("art/background.png"))
			.add(Position.zero());

		// Board
		f.newSetSingleton("backLayer", "board")
			.add(new Image("art/board.png"))
			.add(new Position(120, 20));

		// Timer
		f.newSetEntity("bgLayer").add(new Image("art/timer.png")).add(new Position(0, 480));
		for(val in [
			{text:"2", x:50, id:"timer-min" }, 
			{text:"00", x:100, id:"timer-sec" },
			{text:":", x:71, id:"timer-colon"} ])
				f.newSetSingleton("timer", val.id)
					.add(new Text(val.text))
					.add(new Position(val.x, 540));
		f.newSingleton("timer")
			.add(new Timer(120));

		// Queues
		f.newSingleton("demandQueue").add(new DemandQueue());
		f.newSingleton("researchQueue").add(new ResearchQueue());

		// Knowledge meter
		f.newSetSingleton("backLayer", "book")
			.add(new Image("art/book.png"))
			.add(new Position(22, 38));
		f.newSetSingleton("bookfont", "knowledge")
			.add(new Knowledge(30))
			.add(new Position(60, 57));

		// Progress Level
		f.newSetSingleton("backLayer", "atom")
			.add(new Image("art/atom.png"))
			.add(new Position(65, 269));
		f.newSetSingleton("bookfont", "progress")
			.add(new Progress(0))
			.add(new Position(88, 292));

		// Add recruit
		f.newSetSingleton("worker", "shadowRecruit")
			.add(new Image("art/recruit-shadow.png"));
		f.newSetSingleton("backLayer", "button-recruit")
			.add(new Image("art/button-recruit.png"))
			.add(new Alpha(0.5))
			.add(new Position(17, 219));
		f.newSetSingleton("message", "recruitMessage")
			.add(new Position(60, 200))
			.add(new Size(120, 36))
			.add(new Text("Go Go Go Go!"));

		// Add message bar
		f.newSetSingleton("message", "statusBar")
			.add(new Position(340, 475))
			.add(new Size(440, 36))
			.add(new Scale(1, 1))
			.add(new StatusBar("Recruit three researchers to begin!"))
			.add(new Text("Go Go Go Go!"));

		f.newMarker("gameStart"); // should pause timer for now
	}

	override public function update(_)
	{
		var key = InputService.lastKey();

		#if (debug && desktop)
		if(key == Key.D)
		{
			trace("Dumping log(s)");
			flaxen.util.LogUtil.dumpLog(f, Sys.getCwd() + "entities.txt");
			// trace("Component Sets:");
			// for(setName in f.getComponentSetKeys())
			// 	trace(setName + ":{" + f.getComponentSet(setName) + "}");

			trace(flaxen.util.LogUtil.dumpHaxePunk());
		}
		#end

		if(key == Key.C)
			f.demandComponent("knowledge", Knowledge).amount += 5;

		if(f.hasMarker("place-recruit") && InputService.clicked)
		{		
			var cell = f.getMouseCell("board", 8, 8);
			if(cell != null)
				f.newEntity().add(new PlaceRecruitIntent(cell.x, cell.y));
			else f.newMarker("abort");
		}

		else if(f.isPressed("button-recruit") || (f.hasMarker("recruitEnabled") && key == Key.R))
			f.newMarker("recruiting");

		else if(key == Key.X)
		{
			trace("Pulling demand.");
			var q = f.demandComponent("demandQueue", DemandQueue).queue;
			var d = f.demandComponent(q[0], game.component.Demand);
			d.red = d.blue = d.green = 0;
		}

		else if(InputService.clicked)
		{
			var cell = f.getMouseCell("board", 8, 8);
			if(cell != null) // rotate worker
				f.newEntity()
					.add(new ActivateCellIntent(cell.x, cell.y));
		}

		InputService.clearLastKey();
	}
}
