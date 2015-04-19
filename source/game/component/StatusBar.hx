package game.component; 

class StatusBar
{
	public var message:String;
	public var changed:Bool;
	public var time:Float; // time message was updated

	public function new(message:String)
	{
		setMessage(message);
	}

	public function setMessage(message:String)
	{
		this.message = message;
		this.changed = true;
		this.time = haxe.Timer.stamp();
	}

	public function getElapsed(): Float
	{
		return haxe.Timer.stamp() - time;
	}
}

