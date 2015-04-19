package game.component; 

class ResearcherCard
{
	public var name:String;
	public var type:ResearcherType;
	public var resolved:Bool = false;

	public function new(name:String, type:ResearcherType)
	{
		this.name = name;
		this.type = type;
	}
}

enum ResearcherType { Researcher; RedSpecialist; GreenSpecialist; BlueSpecialist; Assistant }
