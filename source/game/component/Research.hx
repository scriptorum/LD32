package game.component;

import flaxen.util.ArrayUtil; 

class Research
{
	public var queued:Bool = true;
	public var complete:Bool = false;
	public var type:String;
	public var x:Int;
	public var y:Int;
	public var level:Int = 1;
	public var amount:Float = 0;

	public function new(type:String)
	{
		this.type = type;
	}

	public static function random(): Research
	{
		return new Research(ArrayUtil.anyOneOf(["red", "green", "blue"]));
	}
}
