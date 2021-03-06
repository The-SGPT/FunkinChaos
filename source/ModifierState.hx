package;

import Controls.Control;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.util.FlxTimer;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
#if sys
import sys.io.File;
#end
import haxe.Json;
using StringTools;
typedef TModifier = {
	var name:String;
	var value:Bool;
	var conflicts: Array<Int>;
	var multi: Float;
	var ?times:Null<Bool>;
}
class ModifierState extends MusicBeatState
{
	public static var modifiers:Array<TModifier>;
	public static var isBSidesMode:Bool = false;
	public static var isShitpostMode:Bool = false;
	var menuItem:FlxSprite;
	var menuItems:FlxTypedGroup<FlxSprite>;
	var menuItemSprite:Array<FlxSprite> = [];
	var grpAlphabet:FlxTypedGroup<Alphabet>;
	var curSelected:Int = 0;
	var checkmarks:Array<FlxSprite> = [];
	var multiTxt:FlxText;
	var camFollow:FlxObject;
	public static var scoreMultiplier:Float = 1;
	override function create()
	{
		var menuBG:FlxSprite = new FlxSprite().loadGraphic('assetss/images/menuDesat.png');
		menuBG.color = 0x379708;
		grpAlphabet = new FlxTypedGroup<Alphabet>();
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		multiTxt = new FlxText(800, 60, 0, "", 200);
		multiTxt.setFormat("assetss/fonts/vcr.ttf", 40, FlxColor.WHITE, RIGHT);
		multiTxt.text = "Multiplier: 1";
		multiTxt.scrollFactor.set();
		// save between files
		if (modifiers == null) {
			modifiers = [
				{name: "Sick Mode", value: false, conflicts: [1,2,3,4,5,6,7,8,9], multi: 3, times: true},
				{name:"FC Mode", value: false, conflicts: [0,2,3,4,5,6,7,8,9], multi: 2, times: true},
				{name: "Practice Mode", value: false, conflicts: [0,1,19], multi: 0, times:true},
				{name: "Health Gain Up", value: false, conflicts: [0,1,4], multi: -0.5},
				{name: "Health Gain Down", value: false, conflicts: [0,1,3], multi: 0.5},
			 	{name: "Health Loss Up", value: false, conflicts: [0,1,6], multi: 0.5},
			 	{name: "Health Loss Down", value: false, conflicts: [0,1,5], multi: -0.5},
				{name: "Sup Love", value: false, conflicts: [0,1,8], multi: -0.4},
				{name: "Poison Fright", value: false, conflicts: [0,1,7], multi: 0.4},
				{name: "Fragile Funkin", value: false, conflicts: [0,1], multi: 1},
				{name: "Flipped Notes", value: false, conflicts: [15], multi: 0.5},
				{name: "Slow Notes", value: false, conflicts: [12,13], multi: -0.3},
				{name: "Fast Notes", value: false, conflicts: [11,13], multi: 0.8},
				{name : "Accel Notes", value: false, conflicts: [11,12], multi: 0.4},
				{name : "Upside Down", value: false, conflicts: [], multi: 0.4},
				{name : "Earthquake", value: false, conflicts: [], multi: 0.4},
				{name: "z", value: false, conflicts: [], multi: 1, times:true}
			];
		}

		var tex = FlxAtlasFrames.fromSparrow('assetss/images/Modifiers.png', 'assetss/images/Modifiers.xml');

		for (modifier in 0...modifiers.length) {
			var swagModifier = new Alphabet(0, 0, "*     "+modifiers[modifier].name, true, false);
			swagModifier.isOptionItem = true;
			swagModifier.screenCenter(X);
			swagModifier.targetY = modifier;
			swagModifier.x += 250;
			var coolCheckmark:FlxSprite = new FlxSprite(-130, -10).loadGraphic('assetss/images/checkmark.png');
			coolCheckmark.visible = modifiers[modifier].value;
			menuItem = new FlxSprite(-140, -20);
			menuItem.frames = tex;
            menuItem.animation.addByPrefix('Idle', modifiers[modifier].name + " Idle", 24, true);
            menuItem.animation.addByPrefix('Select', modifiers[modifier].name + " Select", 24, true);
			menuItem.animation.play('Idle');
			menuItem.ID = modifier;
			menuItem.scrollFactor.set(50);
			menuItemSprite.push(menuItem);
			checkmarks.push(coolCheckmark);
			swagModifier.add(menuItem);
			swagModifier.add(coolCheckmark);
			grpAlphabet.add(swagModifier);
		}
		add(menuBG);
		add(grpAlphabet);
		add(multiTxt);

		super.create();
	}
	override function update(elapsed:Float) {
		super.update(elapsed);
		if (controls.BACK) {
		if (PlayState.isStoryMode)
				FlxG.switchState(new StoryMenuState());

		//Tell the menu to actually go back to the one you were before. Y'all lazy lol
		else if (PlayState.isBSidesMode)
				FlxG.switchState(new BSidesState());
		else if (PlayState.isShitpostMode)
				FlxG.switchState(new CustomSongState());

		else
			{
				if (PlayState.isCreditsMode)
					FlxG.switchState(new OptionsMenu());
				else
					FlxG.switchState(new FreeplayState());
			}
		}
		if (controls.UP_P)
		{
			changeSelection(-1);
		}
		if (controls.DOWN_P)
		{
			changeSelection(1);
		}

		if (controls.ACCEPT)
			toggleSelection();
	}
	function changeSelection(change:Int = 0)
	{

		FlxG.sound.play('assetss/sounds/scrollMenu' + TitleState.soundExt, 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = modifiers.length - 1;
		if (curSelected >= modifiers.length)
			curSelected = 0;
	
		var bullShit:Int = 0;

		for (item in grpAlphabet.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
	function calculateMultiplier() {
		scoreMultiplier = 1;
		var timesThings:Array<Float> = [];
		for (modifier in modifiers) {
			if (modifier.value) {
				if (modifier.times)
					timesThings.push(modifier.multi);
				else {
					scoreMultiplier += modifier.multi;
				}
			}
		}
		for (timesThing in timesThings) {
			scoreMultiplier *= timesThing;
		}
	}
	function toggleSelection() {
		FlxG.sound.play('assetss/sounds/confirmMenu' + TitleState.soundExt);
		if (modifiers[curSelected].name != 'z'){
			checkmarks[curSelected].visible = !checkmarks[curSelected].visible;
			modifiers[curSelected].value = checkmarks[curSelected].visible;
			for (conflicting in modifiers[curSelected].conflicts) {
				checkmarks[conflicting].visible = false;
				modifiers[conflicting].value = false;
			}
			calculateMultiplier();
			multiTxt.text = "Multiplier: "+scoreMultiplier;
		} else {
			FlxFlicker.flicker(grpAlphabet.members[curSelected],0);
			checkmarks[curSelected].visible = false;
			if (!PlayState.isStoryMode)
				PlayState.autoMode = modifiers[16].value;
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				if (PlayState.isStoryMode == true)
				{
					PlayState.hasPlayedOnce = true;
					FlxG.switchState(new PlayState());
				}
				else
					FlxG.switchState(new CharMenu());
			});
		}

	}
}