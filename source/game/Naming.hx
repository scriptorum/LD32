// TODO Add choice probabilities, so we can tweak the appearance of certain name forms

package game;

import flaxen.util.ArrayUtil;
import flaxen.util.StringUtil; 

class Naming
{
	public static function getWeaponName(): String
	{
		var result = resolve("weapon");
		return StringUtil.toInitCase(result);		
	}

	public static function getWorkerName(): String
	{
		var result = resolve("researcher");
		return StringUtil.toInitCase(result);		
	}

	private static function resolve(section:String): String
	{
		// Pick one from section
		var choices:Array<String> = Reflect.field(Naming.data, section);
		if(choices == null) throw 'Cannot resolve name section $section';
		var result = ArrayUtil.anyOneOf(choices);

		// Replace "/..." for now
		result = ~/\/.*/.replace(result, "");

		// Perform substitutions
		var findSub:EReg = ~/\[(\w+)\]/g;
		result = findSub.map(result, Naming.regExpResolve);

		return result;
	}

	public static function regExpResolve(re:EReg): String
	{
		return resolve(re.matched(1));
	}


	public static var data:Dynamic = {
		weapon: [
			"[adjective] [item]"
		],

		food: [
			"tomato/tomatoes",
			"banana",
			"milk/-",
			"pork chop",
			"peanut butter/-",
			"watermelon",
			"oatmeal/-",
			"coffee/-",
			"asparagus",
			"burger"
		],

		bodypart: [
			"mind",
			"brain",
			"foot",
			"arm",
			"leg",
			"hand",
			"hair",
			"genital",
			"soul",
			"essence"
		],

		good: [
			"chair",
			"sofa",
			"toaster",
			"microwave",
			"bucket",
			"sink",
			"umbrella",
			"spoon",
			"pencil",
			"toilet"
		],

		element: [
			"acid",
			"fire",
			"lava",
			"poison",
			"smoke",
			"ice",
			"poop"
		],

		item: [
			"[good]",
			"[asset]",
			"[food]"
		],

		adjective: [
			"[bodypart]-controlling", 
			"[bodypart]-controlled", 
			"[bodypart]-stealing", 
			"[bodypart]-breaking", 
			"[bodypart]-crushing", 
			"[element]-filled", 
			"[element]-breathing", 
			"[element]-spitting", 
			"[element]-forming", 
			"acidic", 
			"flammable", 
			"burning", 
			"sabotaged", 
			"biting", 
			"suicidal", 
			"self-aware", 
			"burning", 
			"exploding", 
			"melting", 
			"vaporizing", 
			"flying", 
			"blasting", 
			"biting", 
			"[food]-spitting", 
			"[food]-filled"
		],

		asset: [
			"tank",
			"plane",
			"jet",
			"machine gun",
			"assault rifle",
			"rifle",
			"sidearm",
			"pistol",
			"bayonet",
			"artillery",
			"mortar",
			"battleship",
			"satellite",
			"launcher",
			"bomb",
			"missile",
			"balloon",
			"zeppelin",
			"bullet",
			"dart",
			"car"	
		],	

		researcher: [
			"[title] [name]",
			"[title] [surname]",
			"[name]",
			"[name]"
		],

		name: [
			"[firstname] [surname]",
			"[firstname] [initial] [surname]",
			"[initial] [surname]",
		],

		title: [
			"Doctor",
			"Doctor",
			"Dr.",
			"Dr.",
			"Professor",
			"Professor",
			"Mr.",
			"Mr.",
			"Sir"
		],

		firstname: [
			"Joseph", "Franz", "Karl", "Isaac", "Albert", "Maxwell", "Charles", "Alfred", 
			"Michael", "Eric", "Marie", "Rosalind", "Ada", "Lise", "Barbara", "Gertrude", "Jocelyn"
		],

		surname: [
			"Curie", "Franklin", "Lovelace", "Meitner", "McClintock", "Carson", "Lund",
			"Einstein", "Newton", "Born", "Nobel", "Kepler", "Faraday", "[superlative]"
		],

		superlative: [
			"Amazing", "Fantastic", "Incredible", "Jazzpants"
		],

		initial: [ 
			"A.", "B.", "C.", "D.", "E.", "J.", "G.", "H.", "I.", "J.", "K.", "L.", "M.", "N.", 
			"O.", "P.", "Q.", "R.", "S.", "T.", "U.", "V.", "W.", "X.", "Y.", "Z.", 		
		]
	};	
}
