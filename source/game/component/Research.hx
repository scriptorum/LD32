package game.component;

import flaxen.util.ArrayUtil; 

class Research
{
	public static var uniqueId:Int = 0;
	public var id:Int;
	public var queued:Bool = true;
	public var complete:Bool = false;
	public var type:String;
	public var x:Int;
	public var y:Int;
	public var level:Int = 1;
	public var amount:Float = 0;

	public function new(type:String)
	{
		this.id = uniqueId++;
		this.type = type;
	}

	public static function random(): Research
	{
		return new Research(ArrayUtil.anyOneOf(["red", "green", "blue"]));
	}
}
