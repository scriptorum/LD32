package game.component; 

class StatusBar
{
	public var message:String;
	public var changed:Bool;

	public function new(message:String)
	{
		setMessage(message);
	}

	public function setMessage(message:String)
	{
		this.message = message;
		this.changed = true;
	}
}

