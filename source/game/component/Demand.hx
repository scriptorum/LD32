package game.component; 

class Demand
{
	public var name:String; // not necessarily unique descriptor
	public var holder:String; // name of holding entity
	public var red:Float;
	public var green:Float;
	public var blue:Float;
	public var completed:Bool = false;

	public function new(name:String, red:Float, green:Float, blue:Float)
	{
		this.name = name;
		this.red = red;
		this.green = green;
		this.blue = blue;
	}

	public function getValueFor(type:String): Float
	{
		return switch(type)
		{
			case "red": red;
			case "blue": blue;
			case "green": green;
			default: throw 'Unknown type $type';
		}
	}

	public function setValueFor(type:String, value:Float)
	{
		switch(type)
		{
			case "red":   this.red = value;
			case "blue":  this.blue = value;
			case "green": this.green = value;
			default: throw 'Unknown type $type';
		}
	}
}
