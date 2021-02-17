package;

import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import flixel.util.FlxTimer;
import lime.utils.Assets;

class OptionsMenu extends MusicBeatState
{
	var menuItems:Array<String> = ['DEBUG MENU', 'OTHER OPTIONS', 'OFFSET MENU', 'CREDITS', 'LIMIT FPS', 'Exit to menu'];
	var curSelected:Int = 0;
	var txtDescription:FlxText;
	var shittyFPS:Bool = false;

	private var grpMenuShit:FlxTypedGroup<Alphabet>;

	var shittyNames:Array<String> = [
		"BROKEN MENU FT. SHIT CODE",
		"UNNEEDED SHITSHOWS",
		"THE PAIN ROOM",
		"CREDITS, DUH.",
		"bye bye"
	];

	var txtOptionTitle:FlxText;

	override function create()
	{
		var menuBG:FlxSprite = new FlxSprite().loadGraphic('assets/images/menuBGOptions.png');
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isOptionItem = true;
			songText.screenCenter(X);
			songText.x += 150;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		txtDescription = new FlxText(FlxG.width * 0.075, menuBG.y + 200, 0, "", 32);
		txtDescription.alignment = CENTER;
		txtDescription.setFormat("assets/fonts/vcr.ttf", 32);
		txtDescription.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1.5, 1);
		txtDescription.color = FlxColor.WHITE;
		add(txtDescription);

		var header:FlxSprite = new FlxSprite().loadGraphic('assets/images/menuBGOptionsHeader.png');
		header.screenCenter();
		header.antialiasing = true;
		add(header);

		txtOptionTitle = new FlxText(FlxG.width * 0.7, 10, 0, "dfgdfgdg", 32);
		txtOptionTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtOptionTitle.alpha = 0.7;
		add(txtOptionTitle);

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		super.create();
	}

	override function update(elapsed:Float)
	{
		txtOptionTitle.text = shittyNames[curSelected].toUpperCase();
		txtOptionTitle.x = FlxG.width - (txtOptionTitle.width + 10);

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (accepted)
		{
			var daSelected:String = menuItems[curSelected];

			switch (daSelected)
			{
				case "DEBUG MENU":
					FlxG.sound.play('assets/sounds/confirmMenu' + TitleState.soundExt);
					FlxFlicker.flicker(grpMenuShit.members[curSelected],0);
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						FlxG.switchState(new ChartingState());
					});
				case "OTHER OPTIONS":
					FlxG.sound.play('assets/sounds/confirmMenu' + TitleState.soundExt);
					FlxFlicker.flicker(grpMenuShit.members[curSelected],0);
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						FlxG.switchState(new MainMenuState());
					});
				case "OFFSET MENU":
					FlxG.sound.play('assets/sounds/confirmMenu' + TitleState.soundExt);
					FlxFlicker.flicker(grpMenuShit.members[curSelected],0);
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						FlxG.switchState(new AnimationDebug());
					});
				case "LIMIT FPS":
					FlxG.sound.play('assets/sounds/confirmMenu' + TitleState.soundExt);
					if (shittyFPS == false)
					{
						MusicBeatState.funkyFramerate = 60;
						FlxG.drawFramerate = 60;
						shittyFPS = true;
					}
					else
					{
						MusicBeatState.funkyFramerate = 160;
						FlxG.drawFramerate = 160;
						shittyFPS = false;
					}
				case "CREDITS":
					FlxG.sound.play('assets/sounds/confirmMenu' + TitleState.soundExt);
					FlxFlicker.flicker(grpMenuShit.members[curSelected],0);
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						PlayState.SONG = Song.loadFromJson('dadbattle-credits', 'dadbattle-credits');
						PlayState.isStoryMode = false;
						PlayState.isCreditsMode = true;
						FlxG.switchState(new ModifierState());
					});
				case "Exit to menu":
					FlxG.switchState(new MainMenuState());
				default:
					// so it doesnt crash lol
					trace('what the fuck');
			}
		}

		if (controls.BACK)
			FlxG.switchState(new MainMenuState());

		super.update(elapsed);
	}

	function changeSelection(change:Int = 0):Void
	{
		FlxG.sound.play('assets/sounds/scrollMenu' + TitleState.soundExt, 0.4);

		curSelected += change;
	
		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;
	
		var bullShit:Int = 0;
	
		for (item in grpMenuShit.members)
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

		optionDescription();
	}

	function optionDescription()
	{
		var daDescription:String = menuItems[curSelected];

		switch (daDescription)
		{
			case "DEBUG MENU":
				txtDescription.text = 'Access the\nchart editor.\n \nCurrently, it\nis broken, so\n I dont\nrecommend\nit for now.';
			case "OTHER OPTIONS":
				txtDescription.text = 'Change other\nsettings.\n \nMost options\nthat change\nsimple things\ngo here.';
			case "OFFSET MENU":
				txtDescription.text = 'Access the\noffset editor.\n \nMade specifically\nfor editing\n offsets\nand isnt meant\nfor the public.';
			case "FREEPLAY PLUS":
				txtDescription.text = 'Better freeplay\nmenu.';
			case "CREDITS":
				txtDescription.text = 'No use.';
			case "Exit to menu":
				txtDescription.text = 'Says it\nall.';
			default:
				txtDescription.text = 'No description\nprovided.';
		}
	}
}