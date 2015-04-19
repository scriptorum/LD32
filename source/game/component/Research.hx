package game.component;

import flaxen.util.ArrayUtil; 

class Research
{
	public var type:String;
	public var queued:Bool = true;
	public var x:Int;
	public var y:Int;

	public function new(type:String)
	{
		this.type = type;
	}

	public static function random(): Research
	{
		return new Research(ArrayUtil.anyOneOf(["red", "green", "blue"]));
	}
}
