package;

import haxe.Json;
import lime.utils.Assets;
import flixel.FlxG;

using StringTools;

class CoolUtil
{
	public static var difficultyArray:Array<String> = ["HOW IN THE FUCK ARE YOU HERE", "NORMAL", "HARD", "HELL"];

	public static function difficultyString():String
	{
		if (PlayState.storyDifficulty == 0)
			FlxG.log.warn('bro how in the fuck did you get to easy');
		return difficultyArray[PlayState.storyDifficulty];
	}

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = Assets.getText(path).trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function coolStringFile(path:String):Array<String>
	{
		var daList:Array<String> = path.trim().split('\n');
	
		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}
	
		return daList;
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}

	public static function coolTextArray(path:String):Array<Array<String>>
	{
		var fullText:String = Assets.getText(path).trim();
	
		var firstArray:Array<String> = fullText.split('--');
		var swagGoodArray:Array<Array<String>> = [];
	
		for (i in firstArray)
		{
			swagGoodArray.push(i.split('\n'));
		}
	
		return swagGoodArray;
	}

	public static function coolStringifyJson(json:Dynamic):String {
		// use json to prettify it
		return Json.stringify(json, null, '    ');
	}
}
