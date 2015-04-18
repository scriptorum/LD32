package game.component; 

class Demand
{
	public var name:String;
	public var order:Int;
	public var red:Int;
	public var green:Int;
	public var blue:Int;

	public function new(name:String, order:Int, red:Int, green:Int, blue:Int)
	{
		this.name = name;
		this.order = order;
		this.red = red;
		this.green = green;
		this.blue = blue;
	}
}
