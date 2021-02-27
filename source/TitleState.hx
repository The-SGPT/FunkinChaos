package;

import flixel.addons.effects.chainable.FlxRainbowEffect;
import flixel.util.FlxSave;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.addons.effects.chainable.FlxGlitchEffect;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import io.newgrounds.NG;
import lime.app.Application;
import openfl.Assets;
import polymod.Polymod;
import openfl.Lib;
import flash.system.System;
import haxe.Json;
using StringTools;

class TitleState extends MusicBeatState
{
	static var initialized:Bool = false;
	static public var soundExt:String = ".mp3";

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;
	var shittySave:FlxSave;
	static public var vocalSave:Float = 0;
	static public var musicSave:Float = 0;
	static public var versionGhi:String = " DEBUG VERSION";
	static public var shittyPieceofShitScreenDetectorCosImDumbLmao:Bool = false;
	public static var shittyFPS:Bool = false;
	public static var crazyBusUnlocked:Bool = false;

	var sinMod:Float = 0;
	var shittyBG:FlxSprite;
	var bg:FlxSprite;
	var ranbowTexto:FlxRainbowEffect;
	var shittyReminder:Alphabet;
	var txt:FlxText = new FlxText(0, 360, FlxG.width,
	"FNF: Chaos may potentially trigger seizures for people with photosensitive epilepsy. Viewer discretion is advised.\n\n"
	+ "FNF: Chaos is a non-profit modification, aimed for entertainment purposes, and wasn't meant to be an attack on Ninjamuffin99"
	+ " and/or any other modmakers out there. I was not aiming for replacing what Friday Night Funkin' was, won't be aiming for that and never"
	+ " will be aiming for that. It was made for fun and from the love for the game itself. All of the comparisons between this and other mods are purely coincidental, unless stated otherwise.\n\n"
	+ "Now with that out of the way, I hope you'll enjoy this FNF mod.\nFunk all the way.\n\nNow loading...",
	32);

	var doneTalking:Bool = false;

	override public function create():Void
	{
		shittyPieceofShitScreenDetectorCosImDumbLmao = false;
		Polymod.init({modRoot: "mods", dirs: ['introMod']});

		#if (!web)
		TitleState.soundExt = '.ogg';
		#end

		#if (!debug)
		TitleState.versionGhi = " BETA-1";
		#end

		PlayerSettings.init();

		curWacky = FlxG.random.getObject(getIntroTextShit());

		// DEBUG BULLSHIT

		super.create();
		shittyBG = new FlxSprite().loadGraphic('assets/images/menuLoading.png');
		add(shittyBG);
		ranbowTexto = new FlxRainbowEffect(1, 1, 0.5, 1);
		txt.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		add(txt);
		shittyReminder = new Alphabet(0, 50, "WARNING", true, false);
		shittyReminder.screenCenter(X);
		add(shittyReminder);

		// NGio.noLogin(APIStuff.API);

		// #if ng
		// var ng:NGio = new NGio(APIStuff.API, APIStuff.EncKey);
		// trace('NEWGROUNDS LOL');
		// #end

		var optionsJson = Json.parse(Assets.getText('assets/data/options.json'));
		FlxG.save.bind('funkin', 'ninjamuffin99');

		Highscore.load();

		if (FlxG.save.data.weekUnlocked != null)
		{
			// FIX LATER!!!
			// WEEK UNLOCK PROGRESSION!!
			// StoryMenuState.weekUnlocked = FlxG.save.data.weekUnlocked;

			if (StoryMenuState.weekUnlocked.length < 4)
				StoryMenuState.weekUnlocked.insert(0, true);

			// QUICK PATCH OOPS!
			if (!StoryMenuState.weekUnlocked[0])
				StoryMenuState.weekUnlocked[0] = true;
		}

		#if FREEPLAY
		FlxG.switchState(new FreeplayState());
		#elseif CHARTING
		FlxG.switchState(new ChartingState());
		#end

		new FlxTimer().start(0.5, function(tmr:FlxTimer)
		{
			txt.text = "FNF: Chaos may potentially trigger seizures for people with photosensitive epilepsy. Viewer discretion is advised.\n\n"
			+ "FNF: Chaos is a non-profit modification, aimed for entertainment purposes, and wasn't meant to be an attack on Ninjamuffin99"
			+ " and/or any other modmakers out there. I was not aiming for replacing what Friday Night Funkin' was, won't be aiming for that and never"
			+ " will be aiming for that. It was made for fun and from the love for the game itself. All of the comparisons between this and other mods are purely coincidental, unless stated otherwise.\n\n"
			+ "Now with that out of the way, I hope you'll enjoy this FNF mod.\nFunk all the way.\n\nPRESS ENTER TO CONTINUE";
		});
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;

	function startIntro()
	{
		if (!initialized)
		{
			var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;

			FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
				new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
			FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
				{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;

			// HAD TO MODIFY SOME BACKEND SHIT
			// IF THIS PR IS HERE IF ITS ACCEPTED UR GOOD TO GO
			// https://github.com/HaxeFlixel/flixel-addons/pull/348

			// var music:FlxSound = new FlxSound();
			// music.loadStream('assets/music/freakyMenu' + TitleState.soundExt);
			// FlxG.sound.list.add(music);
			// music.play();
			FlxG.sound.playMusic('assets/music/freakyMenu' + TitleState.soundExt, 70);
		}

		Conductor.changeBPM(102);
		persistentUpdate = true;

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		// bg.antialiasing = true;
		// bg.setGraphicSize(Std.int(bg.width * 0.6));
		// bg.updateHitbox();

		logoBl = new FlxSprite(-90, -60);
		logoBl.frames = FlxAtlasFrames.fromSparrow('assets/images/logoBumpin.png', 'assets/images/logoBumpin.xml');
		logoBl.antialiasing = true;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();
		// logoBl.screenCenter();
		// logoBl.color = FlxColor.BLACK;

		gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
		gfDance.frames = FlxAtlasFrames.fromSparrow('assets/images/gfDanceTitle.png', 'assets/images/gfDanceTitle.xml');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = true;
		add(gfDance);
		add(logoBl);

		titleText = new FlxSprite(100, FlxG.height * 0.8);
		titleText.frames = FlxAtlasFrames.fromSparrow('assets/images/titleEnter.png', 'assets/images/titleEnter.xml');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = true;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		// titleText.screenCenter(X);
		add(titleText);

		var logo:FlxSprite = new FlxSprite().loadGraphic('assets/images/logo.png');
		logo.screenCenter();
		logo.antialiasing = true;
		// add(logo);

		// FlxTween.tween(logoBl, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
		// FlxTween.tween(logo, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "ninjamuffin99\nPhantomArcade\nkawaisprite\nevilsk8er", true);
		credTextShit.screenCenter();

		// credTextShit.alignment = CENTER;

		credTextShit.visible = false;

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic('assets/images/newgrounds_logo.png');
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = true;

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		FlxG.mouse.visible = false;

		if (initialized)
			skipIntro();
		else
			initialized = true;

		// credGroup.add(credTextShit);
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText('assets/data/introText.txt');

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		sinMod += 0.007;
		txt.y = Math.sin(sinMod)*60+100;
		shittyReminder.y = Math.sin(sinMod)*60+30;
		if (FlxG.keys.justPressed.ESCAPE)
		{
			System.exit(0);
		}
			
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		if (FlxG.keys.justPressed.F)
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		}

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		if (pressedEnter && !transitioning && skippedIntro && doneTalking)
		{
			#if !switch
			NGio.unlockMedal(60960);

			// If it's Friday according to da clock
			if (Date.now().getDay() == 5)
				NGio.unlockMedal(61034);
			#end

			titleText.animation.play('press');

			FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play('assets/sounds/confirmMenu' + TitleState.soundExt, 0.7);

			transitioning = true;
			// FlxG.sound.music.stop();

			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				FlxG.switchState(new RealMainMenuState());
			});
			// FlxG.sound.play('assets/music/titleShoot' + TitleState.soundExt, 0.7);
		}

		if (pressedEnter && doneTalking == false)
		{
				remove(txt);
				remove(shittyReminder);
				remove(shittyBG);
				add(bg);
				doneTalking = true;
				startIntro();
		}
		else if (pressedEnter && !skippedIntro)
		{
			if (doneTalking == true)
				skipIntro();
			else
				trace('YOURE IMPATIENT, USER!');
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreText(text:String)
	{
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 200;
		credGroup.add(coolText);
		textGroup.add(coolText);
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	override function beatHit()
	{
		super.beatHit();

		logoBl.animation.play('bump');
		danceLeft = !danceLeft;

		if (danceLeft)
			gfDance.animation.play('danceRight');
		else
			gfDance.animation.play('danceLeft');

		FlxG.log.add(curBeat);

		switch (curBeat)
		{
			case 2:
				createCoolText(['haya', 'friedfrick', 'smokey', 'keaton']);
			// credTextShit.visible = true;
			case 3:
				addMoreText('present');
			// credTextShit.text += '\npresent...';
			// credTextShit.addText();
			case 4:
				deleteCoolText();
			// credTextShit.visible = false;
			// credTextShit.text = 'In association \nwith';
			// credTextShit.screenCenter();
			case 5:
				createCoolText(['In association', 'with']);
			case 7:
				addMoreText('newgrounds');
				ngSpr.visible = true;
			// credTextShit.text += '\nNewgrounds';
			case 8:
				deleteCoolText();
				ngSpr.visible = false;
			// credTextShit.visible = false;

			// credTextShit.text = 'Shoutouts Tom Fulp';
			// credTextShit.screenCenter();
			case 9:
				createCoolText([curWacky[0]]);
			// credTextShit.visible = true;
			case 10:
				addMoreText(curWacky[1]);
			// credTextShit.text += '\nlmao';
			case 11:
				deleteCoolText();
			// credTextShit.visible = false;
			// credTextShit.text = "Friday";
			// credTextShit.screenCenter();
			case 12:
				addMoreText('Friday');
			// credTextShit.visible = true;
			case 13:
				addMoreText('Night');
			// credTextShit.text += '\nNight';
			case 14:
				addMoreText('Funkin'); // credTextShit.text += '\nFunkin';
			case 15:
				addMoreText('Chaos'); // credTextShit.text += '\nFunkin';

			case 16:
				skipIntro();
		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			remove(ngSpr);

			FlxG.camera.flash(FlxColor.WHITE, 4);
			remove(credGroup);
			skippedIntro = true;
		}
	}
}
