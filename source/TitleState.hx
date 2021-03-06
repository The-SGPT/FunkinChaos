package;

#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
import sys.FileSystem;
import polymod.Polymod.Framework;
import polymod.Polymod.PolymodError;
import openfl.display.BitmapData;
#end
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
import flixel.ui.FlxBar;
import io.newgrounds.NG;
import lime.app.Application;
import lime.utils.Assets;
import openfl.Assets;
import polymod.Polymod;
import openfl.Lib;
import flash.system.System;
import haxe.Json;
using StringTools;

class TitleState extends MusicBeatState
{
	static var initialized:Bool =  false;
	public static var nof:Bool = false;
	public static var thefunny:Array<String> = [];
	static public var soundExt:String = ".mp3";

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var shittyReminder:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;
	var credSpr:FlxSprite;

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;
	var shittySave:FlxSave;
	private var health:Float = 0;
	static public var vocalSave:Float = 0;
	static public var musicSave:Float = 0;
	static public var versionGhi:String = " DEBUG VERSION";
	static public var shittyPieceofShitScreenDetectorCosImDumbLmao:Bool = false;
	public static var shittyFPS:Bool;
	public static var fuckshit:Bool;
	public static var crazyBusUnlocked:Bool = false;
	public static var deathCounter:Int = 0;
	public static var noteStrumShit:Bool;
	public static var boldText:Bool;
	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	var doneTalking:Bool = false;
	public static var modListOn:Bool = false;
	public static var bModdin:String = "";

	public static var charMod:Bool = false;

	override public function create():Void
	{
		OptionsMenu.onshit = 'off';
		OptionsMenu.onshit2 = 'off';
		OptionsMenu.onshit3 = 'off';
		shittyPieceofShitScreenDetectorCosImDumbLmao = false;
		#if (polymod && sys)

		// Get all directories in the mod folder
		var modDirectory:Array<String> = [];
		var mods = sys.FileSystem.readDirectory("mods");
		

		for (fileText in mods) {
			if (sys.FileSystem.isDirectory("mods/"+fileText)) {
				modDirectory.push(fileText);
			}
		}
		trace(modDirectory);

		// Handle mod errors
		var errors = (error:PolymodError) -> {
			FlxG.log.add(error.severity+": "+error.code+" - "+ error.message + " ORIGIN: "+error.origin);
		};

		//Initialize polymod
		var modMetadata = polymod.Polymod.init({
			modRoot: "mods",
			dirs: modDirectory,
			errorCallback: errors,
		});

		//Display active mods
		var loadedMods = "";
		for (modData in modMetadata) {
			loadedMods += modData.title+", ";
		}

		var flxText = new FlxText(5, 5, 0, "", 16);
		flxText.text = "Loaded Mods: "+loadedMods;
		flxText.color = FlxColor.WHITE;
		add(flxText);
		
		#end

		if (modListOn)
		{
			thefunny = FlxG.random.getObject(CoolUtil.coolTextArray('mods/modList.txt'));
		}
		else
		{
			trace('WONT LOAD MODS COS MOD LOADING IS OFF');
			thefunny = [
				"off",
				"assetss/"
			];
		}

		#if (!web)
		TitleState.soundExt = '.ogg';
		#end

		#if (!debug)
		TitleState.versionGhi = "";
		#end

		PlayerSettings.init();

		curWacky = FlxG.random.getObject(getIntroTextShit());

		// DEBUG BULLSHIT

		super.create();
		if (OptionsHandler.options.fpsLimit)
		{
			MusicBeatState.funkyFramerate = 60;
			FlxG.drawFramerate = 60;
		}
		else if (!OptionsHandler.options.fpsLimit)
		{
			MusicBeatState.funkyFramerate = 160;
			FlxG.drawFramerate = 160;
		}

		if (OptionsHandler.options.bSidesIGuess)
		{
			bModdin = "B";
			FlxG.switchState(new TitleStateB());
		}

		shittyFPS = OptionsHandler.options.fpsLimit;
		noteStrumShit = OptionsHandler.options.p2noteStrums;


		// shittyBG = new FlxSprite().loadGraphic(Paths.image('menuLoading'));
		// // add(shittyBG);
		// ranbowTexto = new FlxRainbowEffect(1, 1, 0.5, 1);
		// txt.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		// // add(txt);
		shittyReminder = new Alphabet(0, 0, "LOADING", OptionsHandler.options.boldText, false);
		shittyReminder.color = FlxColor.WHITE;
		shittyReminder.screenCenter(XY);
		add(shittyReminder);

		var levelInfo:FlxText = new FlxText(0, 550, 0, "", 16);
		levelInfo.text = "A reminder that chaos is still in very early beta!"
		 + "\nPlease report all bugs to the github repo.";
		levelInfo.scrollFactor.set();
		levelInfo.setFormat('assetss/fonts/vcr.ttf', 32, FlxColor.WHITE, CENTER);
		levelInfo.updateHitbox();
		levelInfo.screenCenter(X);
		add(levelInfo);
		levelInfo.alpha = 0;

		healthBarBG = new FlxSprite(0, 40).loadGraphic(Paths.image('loadingBar'));
		/*
		if (OptionsHandler.options.downScroll)
			healthBarBG.y = 50;
		*/
		healthBarBG.screenCenter(XY);
		healthBarBG.y += 40;
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, LEFT_TO_RIGHT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFFFFFF, 0xFF66FF33);
		// healthBar
		add(healthBar);

		// NGio.noLogin(APIStuff.API);

		// #if ng
		// var ng:NGio = new NGio(APIStuff.API, APIStuff.EncKey);
		// trace('NEWGROUNDS LOL'));
		// #end

		FlxG.save.bind("preferredSave", "ninjamuffin99");
		var preferredSave:Int = 0;
		if (Reflect.hasField(FlxG.save.data, "preferredSave")) {
			preferredSave = FlxG.save.data.preferredSave;
		} else {
			FlxG.save.data.preferredSave = 0;
		}

		FlxG.save.close();
		FlxG.save.bind("save"+preferredSave, 'ninjamuffin99');

		Saves.initSave();

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
			
			remove(healthBarBG);
			remove(healthBar);
			remove(shittyReminder);
			shittyReminder = new Alphabet(0, 0, "PLEASE WAIT", true, false);
			shittyReminder.color = FlxColor.WHITE;
			shittyReminder.screenCenter(XY);
			add(shittyReminder);
			FlxTween.tween(levelInfo, {alpha: 1, y: 600}, 0.2, {ease: FlxEase.quartInOut});
			new FlxTimer().start(0.5, function(tmr:FlxTimer)
			{
				remove(levelInfo);
				remove(shittyReminder);
				// preload menu music cos lag
				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					#if desktop
					DiscordClient.initialize();
					Application.current.onExit.add (function (exitCode) {
						DiscordClient.shutdown();
					 });
					#end
					startIntro();
				});
			});
		});
	}

	var logoBl2:FlxSprite;
	var logoBl:FlxSprite;
	var bg:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var colorChanger:Bool = false;
	var titleText:FlxSprite;

	function startIntro()
	{
		if (!initialized)
		{
			nof = true;
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
			// music.loadStream('assetss/music/freakyMenu' + TitleState.soundExt);
			// FlxG.sound.list.add(music);
			// music.play();
			FlxG.sound.playMusic('assetss/music/freakyMenu.ogg', 0.7);
		}

		Conductor.changeBPM(102);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Title Screen", null);
		#end
		
		persistentUpdate = true;

		bg = new FlxSprite().loadGraphic(Paths.image('funneBG'));
		bg.antialiasing = true;
		bg.setGraphicSize(Std.int(bg.width * 1));
		bg.updateHitbox();
		add(bg);

		logoBl2 = new FlxSprite(-90, -60);
		logoBl2.frames = Paths.getSparrowAtlas('logoBumpin');
		logoBl2.antialiasing = true;
		logoBl2.animation.addByPrefix('bump', 'logo bumpin', 24);
		logoBl2.animation.play('bump');
		logoBl2.updateHitbox();
		logoBl2.color = FlxColor.BLACK;

		logoBl = new FlxSprite(-90, -60);
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		logoBl.antialiasing = true;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();
		// logoBl.screenCenter();
		// logoBl.color = FlxColor.BLACK;

		gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
		gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = true;
		add(gfDance);
		add(logoBl2);
		add(logoBl);

		titleText = new FlxSprite(100, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = true;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		// titleText.screenCenter(X);
		add(titleText);

		var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logo'));
		logo.screenCenter();
		logo.antialiasing = true;
		// add(logo);

		FlxTween.tween(logoBl2, {y: logoBl.y + 10}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
		FlxTween.tween(logoBl, {y: logoBl.y + 10}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});

		credGroup = new FlxGroup(); 
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "ninjamuffin99\nPhantomArcade\nkawaisprite\nevilsk8er", true, false);
		credTextShit.screenCenter();

		// credTextShit.alignment = CENTER;

		credTextShit.visible = false;

		ngSpr = new FlxSprite(0, FlxG.height * 0.6).loadGraphic(Paths.image('poweredby'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(XY);
		ngSpr.y += 70;
		ngSpr.antialiasing = true;

		credSpr = new FlxSprite(0, FlxG.height * 0.6).loadGraphic(Paths.image('creds'));
		add(credSpr);
		credSpr.visible = false;
		credSpr.screenCenter(XY);
		credSpr.y += 170;
		credSpr.antialiasing = true;

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		if (initialized)
			skipIntro();
		else
			initialized = true;
		FlxG.mouse.visible = true;

		// credGroup.add(credTextShit);
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText('assetss/data/introText.txt');

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
		FlxG.watch.addQuick("curBeat", curBeat);
		FlxG.watch.addQuick("curStep", curStep);
		health += 0.08;
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

		if (pressedEnter && !transitioning && skippedIntro)
		{
			#if !switch
			NGio.unlockMedal(60960);

			// If it's Friday according to da clock
			if (Date.now().getDay() == 5)
				NGio.unlockMedal(61034);
			#end

			titleText.animation.play('press');

			FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play('assetss/music/titleShoot' + TitleState.soundExt, 0.7);

			transitioning = true;
			// FlxG.sound.music.stop();

			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				// warning
				FlxG.switchState(new OutdatedSubState());
			});
			
		}
		else if (pressedEnter && !skippedIntro && nof)
		{
			skipIntro();
		}

		// if (pressedEnter && doneTalking == false)
		// {
		// 		remove(txt);
		// 		remove(shittyReminder);
		// 		remove(shittyBG);
		// 		add(bg);
		// 		doneTalking = true;
		// 		startIntro();
		// }

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

	function createProductionText(textArray:Array<String>)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 80;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreProductionText(text:String)
	{
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 80;
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
		logoBl2.animation.play('bump');
		danceLeft = !danceLeft;

		if (danceLeft)
			gfDance.animation.play('danceRight');
		else
			gfDance.animation.play('danceLeft');

		FlxG.log.add(curBeat);

		switch (curBeat)
		{
			// this sucks so much i hate it
			// thanks lag
			case 1:
				createProductionText(['haya', 'friedfrick', 'smokey555', 'keaton']);
				credSpr.visible = true;
			// credTextShit.visible = true;
			case 3:
				credSpr.visible = false;
				addMoreProductionText('oh and many others');
				addMoreProductionText('present');
			// credTextShit.visible = false;
			// credTextShit.text = 'In association \nwith';
			// credTextShit.screenCenter();
			case 4:
				deleteCoolText();
				
			case 5:
				createProductionText(['Powered', 'by']);
			case 7:
				addMoreProductionText('TWTEI Engine');
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
			case 11:
				// 9 more rows of custom intro text!
				addMoreText(curWacky[1]);
				addMoreText(curWacky[2]);
				addMoreText(curWacky[3]);
				addMoreText(curWacky[4]);
				addMoreText(curWacky[5]);
				addMoreText(curWacky[6]);
				addMoreText(curWacky[7]);
				addMoreText(curWacky[8]);
				addMoreText(curWacky[9]);
			// credTextShit.text += '\nlmao';		
			// credTextShit.visible = false;
			// credTextShit.text = "Friday";
			// credTextShit.screenCenter();
			case 12:
				deleteCoolText();
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
			remove(credSpr);
			FlxG.camera.flash(FlxColor.WHITE, 4);
			remove(credGroup);
			skippedIntro = true;
		}
	}
}
