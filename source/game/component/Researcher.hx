package game.component; 

class Researcher
{
	public var name:String;
	public var type:ResearcherType;
	public var x:Int;
	public var y:Int;
	public var rotation:Int; // 0-3

	public function new(name:String, type:ResearcherType)
	{
		this.name = name;
		this.type = type;
		this.rotation = 0;
	}
}

enum ResearcherType { Worker; RedSpecialist; GreenSpecialist; BlueSpecialist; Assistant; }
