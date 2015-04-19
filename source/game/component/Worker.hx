package game.component; 

class Worker
{
	public var name:String;
	public var type:WorkerType;
	public var x:Int;
	public var y:Int;
	public var rotation:Int; // 0-3
	public var level:Int = 1;
	public var research:Research = null;

	public function new(name:String, type:WorkerType)
	{
		this.name = name;
		this.type = type;
		this.rotation = 0;
	}
}

enum WorkerType { Researcher; RedSpecialist; GreenSpecialist; BlueSpecialist; Assistant; }
