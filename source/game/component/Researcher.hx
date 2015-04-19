package game.component; 

class Researcher
{
	public var name:String;
	public var type:ResearcherType;

	public function new(name:String, type:ResearcherType)
	{
		this.name = name;
		this.type = type;
	}
}

enum ResearcherType { Researcher; RedSpecialist; GreenSpecialist; BlueSpecialist; Assistant }
