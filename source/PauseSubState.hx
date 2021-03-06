package;

import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;
	var menuItems:Array<String> = ['Resume', 'Restart Song', 'Exit to menu'];

	var curSelected:Int = 0;

	var pauseMusic:FlxSound;

	public function new(x:Float, y:Float)
	{
		super();

		if (PlayState.isStoryMode)
			menuItems = ['Resume', 'Restart Song', 'Skip Song', 'Practice', 'Autoplay', 'Exit to menu'];
		else
			menuItems = ['Resume', 'Restart Song', 'Practice', 'Autoplay', 'Exit to menu'];

		pauseMusic = new FlxSound();
		pauseMusic.loadEmbedded('assetss/music/breakfast' + TitleState.soundExt, true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.text += '\n' + CoolUtil.difficultyString();
		levelInfo.text += '\n' + 'Deaths:' + TitleState.deathCounter;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat('assetss/fonts/vcr.ttf', 32, FlxColor.WHITE, RIGHT);
		levelInfo.updateHitbox();
		add(levelInfo);
		levelInfo.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		var pixelText:Bool = false;

		if (PlayState.curStage == 'school')
			pixelText = true;
		if (PlayState.curStage == 'schoolEvil')
			pixelText = true;
		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false, pixelText);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

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
				case "Resume":
					close();
				case "Restart Song":
					FlxG.resetState();
				case "Skip Song":
					PlayState.skippedSong = true;
					close();
				case "Practice":
					if (!PlayState.practiceMode)
					{
						FlxG.sound.play('assetss/sounds/confirmMenu' + TitleState.soundExt);
						PlayState.practiceMode = true;
					}
					else
					{
						FlxG.sound.play('assetss/sounds/cancelMenu' + TitleState.soundExt);
						PlayState.practiceMode = false;
					}
				case "Autoplay":
					if (!PlayState.autoMode)
					{
						FlxG.sound.play('assetss/sounds/confirmMenu' + TitleState.soundExt);
						PlayState.autoMode = true;
					}
					else
					{
						FlxG.sound.play('assetss/sounds/cancelMenu' + TitleState.soundExt);
						PlayState.autoMode = false;
					}
				case "Exit to menu":
					TitleState.deathCounter = 0;
					if (PlayState.isStoryMode)
						FlxG.switchState(new StoryMenuState());
					else if (PlayState.isCreditsMode)
					{
						trace('WENT BACK TO OPTION MENU??');
						FlxG.switchState(new OptionsMenu());
					}
					else if (PlayState.isBSidesMode)
					{
							trace('Cringe B Mode ');
							FlxG.switchState(new BSidesState());
					}
					else if (PlayState.isShitpostMode)
					{
							trace('Cringe Shitpost Mode');
							FlxG.switchState(new CustomSongState());
					}
					else if (PlayState.isCreditsMode)
					{
							trace('Cringe Shitpost Mode');
							FlxG.switchState(new OptionsMenu());
					}
					else if (!PlayState.isStoryMode)
					{
						trace('WENT BACK TO FREEPLAY??');
						FlxG.switchState(new FreeplayState());
					}
			}
		}

		if (FlxG.keys.justPressed.J)
		{
			// for reference later!
			// PlayerSettings.player1.controls.replaceBinding(Control.LEFT, Keys, FlxKey.J, null);
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
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
	}
}
