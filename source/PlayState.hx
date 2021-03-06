package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.system.FlxAssets.FlxBitmapFontGraphicAsset;
import Section.SwagSection;
import Song.SwagSong;
import MissType;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxRainbowEffect;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.frontEnds.LogFrontEnd;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import flixel.util.FlxTimer.FlxTimerManager;
import flixel.addons.display.FlxBackdrop;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
#if sys
import sys.io.File;
import haxe.io.Path;
import openfl.utils.ByteArray;
import lime.media.AudioBuffer;
import sys.FileSystem;
import flash.media.Sound;
#end

using StringTools;

class PlayState extends MusicBeatState
{
	var lastHealth:Float = 1;
	var startedSONG:Bool = false;
	public static var downScrollTime:Bool = false;
	public static var curStage:String = '';
	public static var curCharacter:String = '';
	public static var nextChar:String = 'bf';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var isBSidesMode:Bool = false;
	public static var isShitpostMode:Bool = false;
	public static var skippedSong:Bool = false;
	public static var isCreditsMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var hasModifier:Int = 0;
	public static var hasPlayedOnce:Bool = false;
	public static var lateNoteHit:Bool = false;

	var halloweenLevel:Bool = false;
	var songLength:Float = 0;

	var CameraSpin:Float = 0;

	private var vocals:FlxSound;
	private var cheering:FlxSound;

	private var dad:Character;
	private var gf:Character;
	private var boyfriend:Boyfriend;
	private var cutsceneDad:Character;

	private var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	private var strumLine:FlxSprite;
	private var curSection:Int = 0;

	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	private var strumLineNotes:FlxTypedGroup<FlxSprite>;
	private var playerStrums:FlxTypedGroup<FlxSprite>;
	private var player2Strums:FlxTypedGroup<FlxSprite>;

	private var strumming2:Array<Bool> = [false, false, false, false];

	private var camZooming:Bool = false;
	private var curSong:String = "";

	private var gfSpeed:Float = 1;
	private var health:Float = 1;
	private var combo:Int = 0;
	private var misses:Int = 0;
	private var accuracy:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalPlayed:Int = 0;
	private var ss:Bool = false;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;
	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];

	// stage shit
	var bgStage:FlxSprite;
	var stageCurtainsStage:FlxSprite;
	var stageFrontStage:FlxSprite;

	var halloweenBG:FlxSprite;
	var isHalloween:Bool = false;

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;

	var limo:FlxSprite;
	var limoNight:FlxSprite;
	var moonBG:FlxBackdrop;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var grpLemonDancers:FlxTypedGroup<LemonDancer>;
	var fastCar:FlxSprite;

	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var simpBoppers:FlxSprite;
	var cutsceneSprite:FlxSprite;
	var santa:FlxSprite;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();
	var sustainWiggle:WiggleEffect = new WiggleEffect();

	var mtc:FlxSprite;
	var beepbop:FlxSprite;

	var talking:Bool = true;
	var songScore:Int = 0;
	var etternaModeScore:Int = 0;
	var trueScore:Int = 0;
	var scoreTxt:FlxText;
	var accurTxt:FlxText;
	var fakeFramerate:Int = 0;
	var doof:DialogueBox;

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	// note input shit
	var successThisFrame:Array<Bool> = [false, false, false, false];
	var foundDirection:Array<Bool> = [false, false, false, false];
	var missQueue:MissType = new MissType(0, false, null);

	var inCutscene:Bool = false;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	var fullComboMode:Bool = false;
	var perfectMode:Bool = false;
	public static var practiceMode:Bool = false;
	var healthGainModifier:Float = 0;
	var healthLossModifier:Float = 0;
	var supLove:Bool = false;
	var poisonExr:Bool = false;
	var poisonPlus:Bool = false;
	var beingPoisioned:Bool = false;
	var poisonTimes:Int = 0;
	var flippedNotes:Bool = false;
	var noteSpeed:Float = 0.45;
	var sickFastTimer:FlxTimer;
	var accelNotes:Bool = false;
	public static var autoMode:Bool = false;
	public static var cpuMode:Bool = false;
	var cameraUpside:Bool = false;
	var earthDeath:Bool = false;
	private var regenTimer:FlxTimer;
	var autoTimer:FlxTimerManager;
	var songName:FlxText;

	// minigame hell
	// first game
	var clickButton:FlxSprite;
	var clickBG:FlxSprite;
	// second game
	var hardestPlayer:FlxSprite;
	var hardestBG:FlxSprite;
	var hardestWalls:FlxSprite;
	var hardestEnemies:FlxSprite;
	var hardestWinPoint:FlxSprite;

	 /**
	 * hello and welcome to code hell
	 */
	override public function create()
	{
		downScrollTime = false;
		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;
		if (OptionsHandler.options.modifierMenu) {
			fullComboMode = ModifierState.modifiers[1].value;
			perfectMode = ModifierState.modifiers[0].value;
			flippedNotes = ModifierState.modifiers[10].value;
			accelNotes= ModifierState.modifiers[13].value;
			if (ModifierState.modifiers[3].value) {
				healthGainModifier += 0.02;
			} else if (ModifierState.modifiers[4].value) {
				healthGainModifier -= 0.01;
			}
			if (ModifierState.modifiers[5].value) {
				healthLossModifier += 0.02;
			} else if (ModifierState.modifiers[6].value) {
				healthLossModifier -= 0.02;
			}
			if (ModifierState.modifiers[11].value)
				noteSpeed = 0.3;
			if (accelNotes) {
				noteSpeed = 0.45;
				trace("accel arrows");
			}
			if (ModifierState.modifiers[12].value)
				noteSpeed = 0.9;
			supLove = ModifierState.modifiers[7].value;
			poisonExr = ModifierState.modifiers[8].value;
			poisonPlus = ModifierState.modifiers[9].value;
			cameraUpside = ModifierState.modifiers[13].value;
			earthDeath = ModifierState.modifiers[14].value;
		}

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		switch (SONG.song.toLowerCase())
		{
			case 'tutorial':
				dialogue = CoolUtil.coolTextFile('assetss/data/tutorial/tutorialDialogue.txt');
			case 'bopeebo':
				dialogue = CoolUtil.coolTextFile('assetss/data/bopeebo/bopeeboDialogue.txt');
			case 'fresh':
				dialogue = CoolUtil.coolTextFile('assetss/data/fresh/freshDialogue.txt');
			case 'dadbattle':
				dialogue = CoolUtil.coolTextFile('assetss/data/dadbattle/dadbattleDialogue.txt');
			case 'senpai':
				dialogue = CoolUtil.coolTextFile('assetss/data/senpai/senpaiDialogue.txt');
			case 'roses':
				dialogue = CoolUtil.coolTextFile('assetss/data/roses/rosesDialogue.txt');
			case 'thorns':
				dialogue = CoolUtil.coolTextFile('assetss/data/thorns/thornsDialogue.txt');
			case 'b-sides-senpai':
				dialogue = CoolUtil.coolTextFile('assetss/data/b-sides-senpai/senpaiDialogue.txt');
			case 'b-sides-roses':
				dialogue = CoolUtil.coolTextFile('assetss/data/b-sides-roses/rosesDialogue.txt');
			case 'b-sides-thorns':
				dialogue = CoolUtil.coolTextFile('assetss/data/b-sides-thorns/thornsDialogue.txt');
			case 'philly':
				dialogue = CoolUtil.coolTextFile('assetss/data/philly/phillyDialogue.txt');
			case 'luci-moment':
				if (FlxG.random.bool(10))
				{
					dialogue = CoolUtil.coolTextFile('assetss/data/luci-moment/luci-momentDialogue-Alt.txt');
				}
				else
					dialogue = CoolUtil.coolTextFile('assetss/data/luci-moment/luci-momentDialogue.txt');
			case 'disappear':
				if (FlxG.random.bool(10))
				{
					dialogue = CoolUtil.coolTextFile('assetss/data/disappear/YOUTHOUGHTITWASEASY.txt');
				}
				else
					dialogue = CoolUtil.coolTextFile('assetss/data/disappear/GUESSWHATBUD.txt');
			case 'hell':
				if (FlxG.random.bool(10))
				{
					dialogue = CoolUtil.coolTextFile('assetss/data/hell/hellDialogue-Alt.txt');
				}
				else
					dialogue = CoolUtil.coolTextFile('assetss/data/hell/hellDialogue.txt');
		}

		#if desktop
		// Making difficulty text for Discord Rich Presence.
		switch (storyDifficulty)
		{
			case 0:
				storyDifficultyText = "Impossible";
			case 1:
				storyDifficultyText = "Normal";
			case 2:
				storyDifficultyText = "Hard";
			case 3:
				storyDifficultyText = "Hell";
		}

		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			switch (storyWeek)
			{
				case 0:
					detailsText = "Story Mode: Tutorial";
				case 7:
					detailsText = "Story Mode: Mod Week";
				case 8:
					detailsText = "Story Mode: Yakuza Week";
				case 9:
					detailsText = "Story Mode: Luci Moment";
				case 10:
					detailsText = "Story Mode: HELL";
				case 11:
					detailsText = "Story Mode: Week 7";
				case 12:
					detailsText = "Story Mode: Annie Week";
				default:
					detailsText = "Story Mode: Week " + storyWeek;
			}
		}
		else
		{
			switch (SONG.song.toLowerCase())
			{
				case 'mc-mental-at-his-best':
					detailsText = "Currently Dying to";
				default:
					detailsText = "Freeplay";
			}
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;

		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") ", iconRPC);
		#end

		if (SONG.song.toLowerCase() == 'spookeez' || SONG.song.toLowerCase() == 'monster' || SONG.song.toLowerCase() == 'south' || SONG.stage == 'spooky')
		{
			curStage = "spooky";
			halloweenLevel = true;

			var hallowTex = Paths.getSparrowAtlas('halloween_bg');

			halloweenBG = new FlxSprite(-200, -100);
			halloweenBG.frames = hallowTex;
			halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
			halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
			halloweenBG.animation.play('idle');
			halloweenBG.antialiasing = true;
			add(halloweenBG);

			isHalloween = true;
		}
		else if (SONG.song.toLowerCase() == 'pico' || SONG.song.toLowerCase() == 'blammed' || SONG.song.toLowerCase() == 'philly' || SONG.stage == 'philly')
		{
			curStage = 'philly';

			var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('philly/sky'));
			bg.scrollFactor.set(0.1, 0.1);
			add(bg);

			var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('philly/city'));
			city.scrollFactor.set(0.3, 0.3);
			city.setGraphicSize(Std.int(city.width * 0.85));
			city.updateHitbox();
			add(city);

			phillyCityLights = new FlxTypedGroup<FlxSprite>();
			add(phillyCityLights);

			for (i in 0...5)
			{
				var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('philly/win' + i + ''));
				light.scrollFactor.set(0.3, 0.3);
				light.visible = false;
				light.setGraphicSize(Std.int(light.width * 0.85));
				light.updateHitbox();
				light.antialiasing = true;
				phillyCityLights.add(light);
			}

			var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly/behindTrain'));
			add(streetBehind);

			phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train'));
			add(phillyTrain);

			trainSound = new FlxSound().loadEmbedded('assetss/sounds/train_passes' + TitleState.soundExt);
			FlxG.sound.list.add(trainSound);

			// var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

			var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('philly/street'));
			add(street);
		}
			else if (SONG.song.toLowerCase() == 'good-enough' || SONG.song.toLowerCase() == 'lover' || SONG.song.toLowerCase() == 'tug-of-war' || SONG.stage == 'annie')
		{
			curStage = 'annie';

			var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('annie/philly/sky'));
			bg.scrollFactor.set(0.1, 0.1);
			add(bg);

			var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('annie/philly/city'));
			city.scrollFactor.set(0.3, 0.3);
			city.setGraphicSize(Std.int(city.width * 0.85));
			city.updateHitbox();
			add(city);

			phillyCityLights = new FlxTypedGroup<FlxSprite>();
			add(phillyCityLights);

			for (i in 0...5)
			{
				var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('annie/philly/win' + i + ''));
				light.scrollFactor.set(0.3, 0.3);
				light.visible = false;
				light.setGraphicSize(Std.int(light.width * 0.85));
				light.updateHitbox();
				light.antialiasing = true;
				phillyCityLights.add(light);
			}

			var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('annie/philly/behindTrain'));
			add(streetBehind);

			phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('annie/philly/train'));
			add(phillyTrain);

			trainSound = new FlxSound().loadEmbedded('assetss/sounds/car_passes' + TitleState.soundExt);
			FlxG.sound.list.add(trainSound);

			// var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

			var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('annie/philly/street'));
			add(street);
		}
		else if (SONG.song.toLowerCase() == 'milf' || SONG.song.toLowerCase() == 'satin-panties' || SONG.song.toLowerCase() == 'high' || SONG.stage == 'limo')
		{
			curStage = 'limo';
			defaultCamZoom = 0.90;

			var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('limo/limoSunset'));
			skyBG.scrollFactor.set(0.1, 0.1);
			add(skyBG);

			var bgLimo:FlxSprite = new FlxSprite(-200, 480);
			bgLimo.frames = Paths.getSparrowAtlas('limo/bgLimo');
			bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
			bgLimo.animation.play('drive');
			bgLimo.scrollFactor.set(0.4, 0.4);
			add(bgLimo);

			grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
			add(grpLimoDancers);

			for (i in 0...5)
			{
				var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
				dancer.scrollFactor.set(0.4, 0.4);
				grpLimoDancers.add(dancer);
			}

			var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.image('limo/limoOverlay'));
			overlayShit.alpha = 0.5;
			// add(overlayShit);

			// var shaderBullshit = new BlendModeEffect(new OverlayShader(), FlxColor.RED);

			// FlxG.camera.setFilters([new ShaderFilter(cast shaderBullshit.shader)]);

			// overlayShit.shader = shaderBullshit;

			var limoTex = Paths.getSparrowAtlas('limo/limoDrive');

			limo = new FlxSprite(-120, 550);
			limo.frames = limoTex;
			limo.animation.addByPrefix('drive', "Limo stage", 24);
			limo.animation.play('drive');
			limo.antialiasing = true;

			fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('limo/fastCarLol'));
			// add(limo);
		}
		else if (SONG.song.toLowerCase() == 'mtc' || SONG.stage == 'mtc')
		{
			curStage = 'mtc';
			defaultCamZoom = 0.90;
	
			var glitchBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('weeb2/limoSunset'));
			glitchBG.scrollFactor.set(0.1, 0.1);
			add(glitchBG);

			beepbop = new FlxSprite(-240, -90);
			beepbop.frames = Paths.getSparrowAtlas('weeb2/upperBop');
			beepbop.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
			beepbop.antialiasing = true;
			beepbop.scrollFactor.set(0.33, 0.33);
			beepbop.setGraphicSize(Std.int(beepbop.width * 0.85));
			beepbop.updateHitbox();
			add(beepbop);
	
			var bgLimo2:FlxSprite = new FlxSprite(-200, 480);
			bgLimo2.frames = Paths.getSparrowAtlas('weeb2/bgLimo');
			bgLimo2.animation.addByPrefix('drive', "background limo pink", 24);
			bgLimo2.animation.play('drive');
			bgLimo2.scrollFactor.set(0.4, 0.4);
			add(bgLimo2);
	
			// add(overlayShit);
	
			// var shaderBullshit = new BlendModeEffect(new OverlayShader(), FlxColor.RED);
	
			// FlxG.camera.setFilters([new ShaderFilter(cast shaderBullshit.shader)]);
	
			// overlayShit.shader = shaderBullshit;

			var limoTex = Paths.getSparrowAtlas('weeb2/limoDrive');

			mtc = new FlxSprite(-120, 550);
			mtc.frames = limoTex;
			mtc.animation.addByPrefix('drive', "Limo stage", 24);
			mtc.animation.play('drive');
			mtc.antialiasing = true;

			// add(limo);
		}
		else if (SONG.song.toLowerCase() == 'cocoa' || SONG.song.toLowerCase() == 'eggnog' || SONG.song.toLowerCase() == 'b-sides-cocoa' || SONG.song.toLowerCase() == 'b-sides-eggnog' || SONG.stage == 'mall')
		{
			curStage = 'mall';

			defaultCamZoom = 0.80;

			var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('christmas/bgWalls'));
			bg.antialiasing = true;
			bg.scrollFactor.set(0.2, 0.2);
			bg.active = false;
			bg.setGraphicSize(Std.int(bg.width * 0.8));
			bg.updateHitbox();
			add(bg);

			upperBoppers = new FlxSprite(-240, -90);
			upperBoppers.frames = Paths.getSparrowAtlas('christmas/upperBop');
			upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
			upperBoppers.antialiasing = true;
			upperBoppers.scrollFactor.set(0.33, 0.33);
			upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
			upperBoppers.updateHitbox();
			add(upperBoppers);

			var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image('christmas/bgEscalator'));
			bgEscalator.antialiasing = true;
			bgEscalator.scrollFactor.set(0.3, 0.3);
			bgEscalator.active = false;
			bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
			bgEscalator.updateHitbox();
			add(bgEscalator);

			var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image('christmas/christmasTree'));
			tree.antialiasing = true;
			tree.scrollFactor.set(0.40, 0.40);
			add(tree);

			bottomBoppers = new FlxSprite(-300, 140);
			bottomBoppers.frames = Paths.getSparrowAtlas('christmas/bottomBop');
			bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
			bottomBoppers.antialiasing = true;
			bottomBoppers.scrollFactor.set(0.9, 0.9);
			bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
			bottomBoppers.updateHitbox();
			add(bottomBoppers);

			var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image('christmas/fgSnow'));
			fgSnow.active = false;
			fgSnow.antialiasing = true;
			add(fgSnow);

			santa = new FlxSprite(-840, 150);
			santa.frames = Paths.getSparrowAtlas('christmas/santa');
			santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
			santa.antialiasing = true;
			add(santa);
		}
		else if (SONG.song.toLowerCase() == 'winter-horrorland' || SONG.stage == 'mallEvil')
		{
			curStage = 'mallEvil';
			var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('christmas/evilBG'));
			bg.antialiasing = true;
			bg.scrollFactor.set(0.2, 0.2);
			bg.active = false;
			bg.setGraphicSize(Std.int(bg.width * 0.8));
			bg.updateHitbox();
			add(bg);

			var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('christmas/evilTree'));
			evilTree.antialiasing = true;
			evilTree.scrollFactor.set(0.2, 0.2);
			add(evilTree);

			var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic("assetss/images/christmas/evilSnow.png");
			evilSnow.antialiasing = true;
			add(evilSnow);
		}
		else if (SONG.song.toLowerCase() == 'animal' || SONG.stage == 'annieEvil')
		{
			curStage = 'annieEvil';
			var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('annie/christmas/evilBG'));
			bg.antialiasing = true;
			bg.scrollFactor.set(0.2, 0.2);
			bg.active = false;
			bg.setGraphicSize(Std.int(bg.width * 0.8));
			bg.updateHitbox();
			add(bg);

			var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('annie/christmas/evilTree'));
			evilTree.antialiasing = true;
			evilTree.scrollFactor.set(0.2, 0.2);
			add(evilTree);

			var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic("assetss/images/annie/christmas/evilSnow.png");
			evilSnow.antialiasing = true;
			add(evilSnow);
		}
		else if (SONG.song.toLowerCase() == 'senpai' || SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'b-sides-senpai' || SONG.song.toLowerCase() == 'b-sides-roses' || SONG.stage == 'school')
		{
			curStage = 'school';

			// defaultCamZoom = 0.9;

			var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb/weebSky'));
			bgSky.scrollFactor.set(0.1, 0.1);
			add(bgSky);

			var repositionShit = -200;

			var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('weeb/weebSchool'));
			bgSchool.scrollFactor.set(0.6, 0.90);
			add(bgSchool);

			var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebStreet'));
			bgStreet.scrollFactor.set(0.95, 0.95);
			add(bgStreet);

			var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('weeb/weebTreesBack'));
			fgTrees.scrollFactor.set(0.9, 0.9);
			add(fgTrees);

			var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
			var treetex = Paths.getPackerAtlas('weeb/weebTrees');
			bgTrees.frames = treetex;
			bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
			bgTrees.animation.play('treeLoop');
			bgTrees.scrollFactor.set(0.85, 0.85);
			add(bgTrees);

			var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
			treeLeaves.frames = Paths.getSparrowAtlas('weeb/petals');
			treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
			treeLeaves.animation.play('leaves');
			treeLeaves.scrollFactor.set(0.85, 0.85);
			add(treeLeaves);

			var widShit = Std.int(bgSky.width * 6);

			bgSky.setGraphicSize(widShit);
			bgSchool.setGraphicSize(widShit);
			bgStreet.setGraphicSize(widShit);
			bgTrees.setGraphicSize(Std.int(widShit * 1.4));
			fgTrees.setGraphicSize(Std.int(widShit * 0.8));
			treeLeaves.setGraphicSize(widShit);

			fgTrees.updateHitbox();
			bgSky.updateHitbox();
			bgSchool.updateHitbox();
			bgStreet.updateHitbox();
			bgTrees.updateHitbox();
			treeLeaves.updateHitbox();

			bgGirls = new BackgroundGirls(-100, 190);
			bgGirls.scrollFactor.set(0.9, 0.9);

			if (SONG.song.toLowerCase() == 'roses')
			{
				bgGirls.getScared();
				var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 1);
				
				wiggleShit.effectType = WiggleEffectType.DREAMY;
				wiggleShit.waveAmplitude = 0.0001;
				wiggleShit.waveFrequency = 60;
				wiggleShit.waveSpeed = 0.1;

				bgSky.shader = wiggleShit.shader;
				bgSchool.shader = wiggleShit.shader;
				fgTrees.shader = wiggleShit.shader;
				bgTrees.shader = wiggleShit.shader;
				bgStreet.shader = wiggleShit.shader;
				treeLeaves.shader = wiggleShit.shader;

				bgGirls.visible = false;
			}

			bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
			bgGirls.updateHitbox();
			add(bgGirls);
			if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'b-sides-roses')
			{
				var waveEffect = new FlxWaveEffect(FlxWaveMode.ALL, 1, 0.1, 3, 1);
				var waveSpriteGirls = new FlxEffectSprite(bgGirls, [waveEffect]);
				waveSpriteGirls.scale.set(6, 6);
				waveSpriteGirls.x = bgGirls.x + 60;
				waveSpriteGirls.y = bgGirls.y + 225;
				waveSpriteGirls.updateHitbox();
				waveSpriteGirls.scrollFactor.set(0.9, 0.9);
				add(waveSpriteGirls);
			}
		}
		else if (SONG.song.toLowerCase() == 'thorns' || SONG.song.toLowerCase() == 'b-sides-thorns' || SONG.stage == 'schoolEvil')
		{
			curStage = 'schoolEvil';

		    var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
		    var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);

		    var posX = 400;
	        var posY = 200;

		    var bg:FlxSprite = new FlxSprite(posX, posY);
		    bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool');
		    bg.animation.addByPrefix('idle', 'background 2', 24);
		    bg.animation.play('idle');
		    bg.scrollFactor.set(0.8, 0.9);
		    bg.scale.set(6, 6);
		    add(bg);
		}
		else if (SONG.stage == 'swiggly')
		{
			curStage = 'swiggly';

			var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
			var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);

			var posX = 400;
			var posY = 325;

			/*
			var bg:FlxSprite = new FlxSprite(posX, posY);
			bg.frames = Paths.getPackerAtlas(Paths.image('weeb/animatedEvilSchool'), Paths.image('weeb/animatedEvilSchool.xml');
			bg.animation.addByPrefix('idle', 'background 2', 24);
			bg.animation.play('idle');
			bg.scrollFactor.set(0.8, 0.9);
			bg.scale.set(6, 6);
			add(bg);
			*/

			var bg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('evilSchoolBG'));
			bg.scale.set(6, 6);
			// bg.setGraphicSize(Std.int(bg.width * 6));
			// bg.updateHitbox();
			add(bg);

			var fg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('evilSchoolFG'));
			fg.scale.set(6, 6);
			// fg.setGraphicSize(Std.int(fg.width * 6));
			// fg.updateHitbox();
			add(fg);

			wiggleShit.effectType = WiggleEffectType.DREAMY;
			wiggleShit.waveAmplitude = 0.10;
			wiggleShit.waveFrequency = 120;
			wiggleShit.waveSpeed = 2.8;

			bg.shader = wiggleShit.shader;
			fg.shader = wiggleShit.shader;

			var waveSprite = new FlxEffectSprite(bg, [waveEffectBG]);
			var waveSpriteFG = new FlxEffectSprite(fg, [waveEffectFG]);

			// Using scale since setGraphicSize() doesnt work???
			waveSprite.scale.set(6, 6);
			waveSpriteFG.scale.set(6, 6);
			waveSprite.setPosition(posX, posY);
			waveSpriteFG.setPosition(posX, posY);

			waveSprite.scrollFactor.set(0.7, 0.8);
			waveSpriteFG.scrollFactor.set(0.9, 0.8);

			add(waveSprite);
			add(waveSpriteFG);
		}
		else if (SONG.song.toLowerCase() == 'friday-night' || SONG.song.toLowerCase() == 'judgement' || SONG.song.toLowerCase() == 'machine-gun-kiss' || SONG.stage == 'yakuza')
		{
			defaultCamZoom = 0.9;
			curStage = 'yakuza';
			var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('yakuzaback'));
			bg.antialiasing = true;
			bg.scrollFactor.set(0.9, 0.9);
			bg.active = false;
			add(bg);
	
			var yakuzaFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('yakuzafront'));
			yakuzaFront.setGraphicSize(Std.int(yakuzaFront.width * 1.1));
			yakuzaFront.updateHitbox();
			yakuzaFront.antialiasing = true;
			yakuzaFront.scrollFactor.set(0.9, 0.9);
			yakuzaFront.active = false;
			add(yakuzaFront);
		}
		else if (SONG.stage == 'miku')
		{
			defaultCamZoom = 0.9;
			curStage = 'miku';

			var skyBG:FlxSprite = new FlxSprite(-120, -500).loadGraphic(Paths.image('miku/mikuSunset'));
			skyBG.scrollFactor.set(0.1, 0.1);
			skyBG.scale.set(1.5, 1.5);
			add(skyBG);

			var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('miku/mikuback'));
			bg.antialiasing = true;
			bg.scrollFactor.set(0.9, 0.9);
			bg.active = false;
			add(bg);
	
			var mikuFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('miku/mikufront'));
			mikuFront.setGraphicSize(Std.int(mikuFront.width * 1.1));
			mikuFront.updateHitbox();
			mikuFront.antialiasing = true;
			mikuFront.scrollFactor.set(0.9, 0.9);
			mikuFront.active = false;
			add(mikuFront);

			var mikuCurtains:FlxSprite = new FlxSprite(-500, -700).loadGraphic(Paths.image('miku/mikuroof'));
			mikuCurtains.setGraphicSize(Std.int(mikuCurtains.width * 0.9));
			mikuCurtains.updateHitbox();
			mikuCurtains.antialiasing = true;
			mikuCurtains.scrollFactor.set(1.3, 1.3);
			mikuCurtains.active = false;
			add(mikuCurtains);
		}
		else if (SONG.stage == 'mikuNew')
		{
			defaultCamZoom = 0.9;
			curStage = 'mikuNew';

			var skyBG:FlxSprite = new FlxSprite(-120, -500).loadGraphic(Paths.image('miku/mikuSunset'));
			skyBG.scrollFactor.set(0.1, 0.1);
			skyBG.scale.set(1.5, 1.5);
			add(skyBG);

			var bg:FlxSprite = new FlxSprite(-230, -200).loadGraphic(Paths.image('miku/neu/back'));
			bg.antialiasing = true;
			bg.scrollFactor.set(0.9, 0.9);
			bg.active = false;
			add(bg);
	
			var mikuFront:FlxSprite = new FlxSprite(-230, -200).loadGraphic(Paths.image('miku/neu/front'));
			mikuFront.antialiasing = true;
			mikuFront.scrollFactor.set(0.9, 0.9);
			mikuFront.active = false;
			add(mikuFront);

			simpBoppers = new FlxSprite(-230, 590);
			simpBoppers.frames = Paths.getSparrowAtlas('miku/neu/bunch_of_simps');
			simpBoppers.animation.addByPrefix('bop', 'Downer Crowd Bob', 24, false);
			simpBoppers.antialiasing = true;
			simpBoppers.scrollFactor.set(0.9, 0.9);
			simpBoppers.setGraphicSize(Std.int(simpBoppers.width * 1));
			simpBoppers.updateHitbox();
			add(simpBoppers);
		}
		else if (SONG.song.toLowerCase() == 'mc-mental-at-his-best' || SONG.stage == 'trick')
		{
			defaultCamZoom = 0.9;
			curStage = 'trick';
			var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
			bg.antialiasing = true;
			bg.scrollFactor.set(0.9, 0.9);
			bg.active = false;
			add(bg);
	
			var stageFront2:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
			stageFront2.setGraphicSize(Std.int(stageFront2.width * 1.1));
			stageFront2.updateHitbox();
			stageFront2.antialiasing = true;
			stageFront2.scrollFactor.set(0.9, 0.9);
			stageFront2.active = false;
			add(stageFront2);
	
			var stageCurtains2:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
			stageCurtains2.setGraphicSize(Std.int(stageCurtains2.width * 0.9));
			stageCurtains2.updateHitbox();
			stageCurtains2.antialiasing = true;
			stageCurtains2.scrollFactor.set(1.3, 1.3);
			stageCurtains2.active = false;
	
			add(stageCurtains2);
		}

//Carol R34 don't leak
		else if (SONG.song.toLowerCase() == 'Lemon-Hell' ||	SONG.song.toLowerCase() == 'Fefe' ||  SONG.stage == 'lemonhell')
			{
				curStage = 'lemonhell';
				defaultCamZoom = 0.9;
	
				var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('lemonhell/limoSunset'));
				skyBG.scrollFactor.set(0.1, 0.1);
				add(skyBG);

				var giantlemon:FlxSprite = new FlxSprite(40, 450);
				giantlemon.frames = Paths.getSparrowAtlas('christmas/monsterChristmas');
				giantlemon.animation.addByPrefix('smile', "Monster Right note", 24);
				giantlemon.animation.play('smile');
				giantlemon.scrollFactor.set(0.4, 0.4);
				giantlemon.scale.set (2.5,2.5);
				giantlemon.antialiasing = true;
				add(giantlemon);
//send me weed i'm empty again
				
				var bgLimo:FlxSprite = new FlxSprite(-200, 480);
				bgLimo.frames = Paths.getSparrowAtlas('lemonhell/bgLimo');
				bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
				bgLimo.animation.play('drive');
				bgLimo.scrollFactor.set(0.4, 0.4);
				add(bgLimo);
	
				grpLemonDancers = new FlxTypedGroup<LemonDancer>();
				add(grpLemonDancers);
	
				for (i in 0...5)
				{
					var dancer:LemonDancer = new LemonDancer((370 * i) + 130, bgLimo.y - 400);
					dancer.scrollFactor.set(0.4, 0.4);
					grpLemonDancers.add(dancer);
				}
	
				var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic('lemonhell/limoOverlay');
				overlayShit.alpha = 0.5;
				
				var limoTex = Paths.getSparrowAtlas('lemonhell/limoDrivelemon');
	
				limo = new FlxSprite(-120, 550);
				limo.frames = limoTex;
				limo.animation.addByPrefix('drive', "Limo stage", 24);
				limo.animation.play('drive');
				limo.antialiasing = true;
	
				fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('lemonhell/fastCarLol'));
				// add(limo);
			}
		else if (SONG.stage == 'pixelstreet')
		{
			curStage = 'pixelstreet';
				moonBG= new FlxBackdrop(Paths.image('pixelstreet/limoMoon'), 1, 1, true, false);
				moonBG.x = -150;
				moonBG.y = -1550;
				
				moonBG.scrollFactor.set(0.1, 0.1);
				moonBG.setGraphicSize(Std.int(moonBG.width * 3));
				moonBG.updateHitbox();
				
				add(moonBG);
				moonBG.velocity.x = 50;
			
				//Nighttime Street
				var road:FlxSprite = new FlxSprite(-650, 650);
				road.frames = Paths.getSparrowAtlas('pixelstreet/Mom_RoadNight');
				road.animation.addByPrefix('road', "ROAD", 24);
				road.animation.play('road');
				road.antialiasing = true;
				road.scrollFactor.set(0.3, 0.3);
				add(road);

				var bgLimo:FlxSprite = new FlxSprite(-200, 480);
				bgLimo.frames = Paths.getSparrowAtlas('limo/bgLimoNight');
				bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
				bgLimo.animation.play('drive');
				bgLimo.antialiasing = true;
				bgLimo.scrollFactor.set(0.4, 0.4);
	
				var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.image('limo/limoOverlayNight'));
				overlayShit.alpha = 0.5;
				
				var limoTex = Paths.getSparrowAtlas('pixelstreet/limoDrive');
	
				limoNight = new FlxSprite(-50, 550);
				limoNight.frames = limoTex;
				limoNight.animation.addByPrefix('driveNight', "Limo stage", 24);
				limoNight.animation.play('driveNight');
				
				fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('limo/fastCarNight'));
				add(limoNight);
			}
		else
		{
			defaultCamZoom = 0.9;
			curStage = 'stage';
			var bgStage:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
			bgStage.antialiasing = true;
			bgStage.scrollFactor.set(0.9, 0.9);
			bgStage.active = false;
			add(bgStage);

			var stageFrontStage:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
			stageFrontStage.setGraphicSize(Std.int(stageFrontStage.width * 1.1));
			stageFrontStage.updateHitbox();
			stageFrontStage.antialiasing = true;
			stageFrontStage.scrollFactor.set(0.9, 0.9);
			stageFrontStage.active = false;
			add(stageFrontStage);

			var stageCurtainsStage:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
			stageCurtainsStage.setGraphicSize(Std.int(stageCurtainsStage.width * 0.9));
			stageCurtainsStage.updateHitbox();
			stageCurtainsStage.antialiasing = true;
			stageCurtainsStage.scrollFactor.set(1.3, 1.3);
			stageCurtainsStage.active = false;

			add(stageCurtainsStage);
		}

		var gfVersion:String = 'gf';

		gfVersion = SONG.gf;

		gf = new Character(400, 130, gfVersion);
		gf.scrollFactor.set(0.95, 0.95);

		switch (SONG.gf)
		{
			case 'bf':
				gf.y += 300;
				gf.x += 100;
			case 'diva':
				gf.y += 300;
				gf.x += 100;
		}

		dad = new Character(100, 100, SONG.player2);

		cutsceneSprite = new FlxSprite(100, 100);
		cutsceneSprite.frames = Paths.getSparrowAtlas('miku/neu/mikuintro');
		cutsceneSprite.animation.addByPrefix('wave', 'miku intro instance', 24);
		cutsceneSprite.animation.addByPrefix('point', 'miku bro instance', 24, false);
		cutsceneSprite.antialiasing = true;
		cutsceneSprite.setGraphicSize(Std.int(cutsceneSprite.width * 1));
		cutsceneSprite.updateHitbox();

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}

			case "spooky":
				dad.y += 200;
			case "monster":
				dad.y += 100;
			case 'monster-christmas':
				dad.y += 130;
			case 'dad':
				camPos.x += 400;
			case 'pico':
				camPos.x += 600;
				dad.y += 300;
			case 'parents-christmas':
				dad.x -= 500;
			case 'senpai':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'senpai-angry':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'senpaidumb':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'spirit':
				dad.x -= 150;
				dad.y += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'diva':
				camPos.x += 700;
				dad.y += 400;
			case 'bf':
				camPos.x += 600;
				dad.y = 450;
			case 'bf-car':
				camPos.x += 600;
				dad.y = 450;
			case 'bf-christmas':
				camPos.x += 600;
				dad.y = 450;
			case 'bf-pixel':
				camPos.x += 600;
				dad.y = 450;
			case 'smile':
				camPos.x += 600;
				dad.y += 300;
			case 'annie':
				camPos.x += 600;
				dad.y += 300;
			case 'annietall':
				dad.y += 130;
			case 'gaming':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}
			default:
				dad.x += dad.enemyOffsetX;
				dad.y += dad.enemyOffsetY;
				camPos.x += dad.camOffsetX;
				camPos.y += dad.camOffsetY;
		}

		boyfriend = new Boyfriend(770, 450, SONG.player1);
		curCharacter = SONG.player1;

		switch (SONG.player1)
		{
			case 'gf':
				boyfriend.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}

			case 'dad':
				boyfriend.y = 100;
			case 'mom-car':
				boyfriend.y = 100;
			case 'miku':
				boyfriend.y = 100;
			case "spooky":
				boyfriend.y = 100;
				boyfriend.y += 200;
			case "monster":
				boyfriend.y = 100;
				boyfriend.y += 100;
			case 'monster-christmas':
				boyfriend.y = 100;
				boyfriend.y += 130;
			case 'pico':
				boyfriend.y = 100;
				camPos.x -= 100;
				boyfriend.y += 300;
			case 'annie':
					boyfriend.y = 100;
					camPos.x -= 100;
					boyfriend.y += 300;
			case 'parents-christmas':
				boyfriend.y = 100;
				boyfriend.x -= 500;
			case 'senpai':
				boyfriend.y = 100;
				boyfriend.x += 150;
				boyfriend.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'senpai-angry':
				boyfriend.y = 100;
				boyfriend.x += 150;
				boyfriend.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'spirit':
				boyfriend.y = 100;
				boyfriend.x -= 150;
				boyfriend.y += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'smile':
				boyfriend.y = 100;
				boyfriend.y += 300;
			case 'gaming':
				boyfriend.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}
			default:
				boyfriend.x += boyfriend.enemyOffsetX;
				boyfriend.y += boyfriend.enemyOffsetY;
				camPos.x += boyfriend.camOffsetX;
				camPos.y += boyfriend.camOffsetY;
		}

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'limo':
				boyfriend.y -= 220;
				boyfriend.x += 260;

				resetFastCar();
				add(fastCar);
			case 'lemonhell':
				boyfriend.y -= 220;
				boyfriend.x += 260;
	
				resetFastCar();
				add(fastCar);
			case 'pixelstreet':
				boyfriend.y -= 70;
				boyfriend.x += 460;
					
				dad.y -= 75;
				dad.x += 250;
	
				resetFastCar();
				add(fastCar);

			case 'mall':
				boyfriend.x += 200;

			case 'mallEvil':
				boyfriend.x += 320;
				dad.y -= 80;
			case 'school':
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'schoolEvil':
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'mtc':
				boyfriend.y -= 220;
				boyfriend.x += 260;
		}

		var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
		var evilTrail2 = new FlxTrail(boyfriend, null, 4, 24, 0.3, 0.069);
		var evilTrail3 = new FlxTrail(gf, null, 4, 24, 0.3, 0.069);

		var evilGlitchLMAO = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
		if (curStage == 'trick')
			add(evilTrail3);
		add(gf);
		if(curStage == 'pixelstreet')
			gf.visible = false;

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);
		if (curStage == 'lemonhell')
			add(limo);
		if (curStage == 'mtc')
			add(mtc);
		if (curStage == 'schoolEvil')
			add(evilTrail);
		if (curStage == 'trick')
			add(evilTrail);
		if (curStage == 'miku' && !OptionsHandler.options.momentEffect)
		{
			add(evilTrail);
			dad.velocity.set(1, 1);
		}

		
		// add(cutsceneDad);
		add(dad);
		add(cutsceneSprite);	
		cutsceneSprite.visible = false;
		if (curStage == 'mtc')
		{
			var waveSprite = new FlxEffectSprite(dad, [evilGlitchLMAO]);
			waveSprite.y = dad.y;
			waveSprite.x = dad.x;
			add(waveSprite);
		}
		if (curStage == 'trick')
			add(evilTrail2);
		add(boyfriend);

		doof = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		/*
		if (OptionsHandler.options.downScroll)
			strumLine.y = FlxG.height - 165;
		*/

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();
		player2Strums = new FlxTypedGroup<FlxSprite>();

		// startCountdown();

		generateSong(SONG.song);

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04 * (60.0 / MusicBeatState.funkyFramerate));
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		/*
		if (OptionsHandler.options.downScroll)
			healthBarBG.y = 50;
		*/
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.numDivisions = 1000;
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		// healthBar
		add(healthBar);

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		// haha funne kade engine watermark
		var kadeEngineWatermark = new FlxText(4,healthBarBG.y + 50,0,SONG.song + " " + (storyDifficulty == 2 ? "Hard" : storyDifficulty == 1 ? "Normal" : "Easy"), 16);
		kadeEngineWatermark.setFormat("assetss/fonts/vcr.ttf", 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		kadeEngineWatermark.scrollFactor.set();
		add(kadeEngineWatermark);

		scoreTxt = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 200, healthBarBG.y + 30, 0, "", 20);
		scoreTxt.setFormat("assetss/fonts/vcr.ttf", 22, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2, 1);
		scoreTxt.scrollFactor.set();
		add(scoreTxt);

		accurTxt = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 200, healthBarBG.y + 30, 0, "", 20);
		accurTxt.setFormat("assetss/fonts/vcr.ttf", 22, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		accurTxt.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2, 1);
		accurTxt.scrollFactor.set();
		add(accurTxt);

		clickBG = new FlxSprite();
		
		clickButton = new FlxSprite();
		
		// hardestPlayer = new FlxSprite(50, 50);
		// add(hardestPlayer);

		// hardestBG = new FlxSprite();
		// add(hardestBG);

		// hardestWalls = new FlxSprite();
		// add(hardestWalls);

		// hardestEnemies = new FlxSprite(400, 500);
		// add(hardestEnemies);

		if (curSong == 'Lootus')
		{
			healthBar.visible = false;
			healthBarBG.visible = false;
			iconP1.visible = false;
			iconP2.visible = false;
			scoreTxt.visible = false;
			accurTxt.visible = false;

			clickBG.loadGraphic(Paths.image('uk/clicer/bg'));
			clickBG.screenCenter(X);
			clickBG.scrollFactor.set();
			clickBG.visible = false;
			clickBG.cameras = [camHUD];
			add(clickBG);

			clickButton.loadGraphic(Paths.image('uk/clicer/buton'));
			clickButton.screenCenter(X);
			clickButton.scrollFactor.set();
			clickButton.visible = false;
			clickButton.cameras = [camHUD];
			add(clickButton);

			// hardestPlayer.loadGraphic(Paths.image('uk/hardest/player'));
			// hardestPlayer.scrollFactor.set();
			// hardestPlayer.visible = false;
			// hardestPlayer.cameras = [camHUD];

			// hardestBG.loadGraphic(Paths.image('uk/hardest/bgtiles'));
			// hardestBG.scrollFactor.set();
			// hardestBG.visible = false;
			// hardestBG.cameras = [camHUD];

			// hardestWalls.loadGraphic(Paths.image('uk/hardest/bgwalls'));
			// hardestWalls.scrollFactor.set();
			// hardestWalls.visible = false;
			// hardestWalls.cameras = [camHUD];

			// hardestEnemies.loadGraphic(Paths.image('uk/hardest/bgenemies'));
			// hardestEnemies.scrollFactor.set();
			// hardestEnemies.visible = false;
			// hardestEnemies.cameras = [camHUD];
		}

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		accurTxt.cameras = [camHUD];
		doof.cameras = [camHUD];

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		if (isStoryMode)
		{
			switch (curSong.toLowerCase())
			{
				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;

					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play('assetss/sounds/Lights_Turn_On' + TitleState.soundExt);
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									startCountdown();
								}
							});
						});
					});
				case "luci-moment":
					var blackScreen2:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen2);
					blackScreen2.scrollFactor.set();
					camHUD.visible = false;
					dad.visible = false;
	
					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						cheering = new FlxSound().loadEmbedded('assetss/sounds/cheer' + TitleState.soundExt, true);
						cheering.play();
						remove(blackScreen2);
						camFollow.y = -1050;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;
						FlxG.sound.playMusic('assetss/music/Luci-Moment_Inst' + TitleState.soundExt, 0);
						FlxG.sound.music.fadeIn(1, 0, 0.8);
	
						new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							remove(blackScreen2);
							FlxTween.tween(FlxG.camera, {zoom: 1.1}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y);
									if (!OptionsHandler.options.momentCutscene)
									{
										// help
										cutsceneSprite.visible = true;
										cutsceneSprite.animation.play('wave', true);
										new FlxTimer().start(2, function(tmr:FlxTimer)
										{
											cutsceneSprite.animation.play('point', true);
											new FlxTimer().start(0.2, function(tmr:FlxTimer)
											{
												camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
												boyfriend.playAnim('hey', true);
												new FlxTimer().start(1, function(tmr:FlxTimer)
												{
													boyfriend.playAnim('idle', true);
													camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
													remove(cutsceneSprite);
													dad.visible = true;
													FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.5, {
														ease: FlxEase.quadInOut,
														onComplete: function(twn:FlxTween)
														{
															camHUD.visible = true;
															healthBar.visible = false;
															healthBarBG.visible = false;
															iconP1.visible = false;
															iconP2.visible = false;
															scoreTxt.visible = false;
															accurTxt.visible = false;
															schoolIntro(doof);
														}
													});
												});
											});
										});
									}
									else
									{
										dad.visible = true;
										camHUD.visible = true;
										startCountdown();
									}	
								}
							});
						});
					});
				case 'senpai':
					schoolIntro(doof);
				case 'roses':
					FlxG.sound.play('assetss/sounds/ANGRY' + TitleState.soundExt);
					schoolIntro(doof);
				case 'thorns':
					schoolIntro(doof);
				case 'bopeebo':
					schoolIntro(doof);
				case 'fresh':
					schoolIntro(doof);
				case 'dadbattle':
					schoolIntro(doof);
				case 'tutorial':
					schoolIntro(doof);
				case 'philly':
					schoolIntro(doof);
				case 'disappear':
					schoolIntro(doof);
				default:
					startCountdown();
			}
		}
		else
		{
			switch (curSong.toLowerCase())
			{
				case "luci-moment":
					startCountdown();
				default:
					startCountdown();
			}
		}

		health = lastHealth;

		super.create();
	}

	 /**
	 * hi kade
	 */
	function updateAccuracy()
	{
		if (misses > 0 || accuracy < 96)
			ss = false;
		else
			ss = true;
		totalPlayed += 1;
		accuracy = Math.max(0,totalNotesHit / totalPlayed * 100);
	}

	 /**
	 * DIALOGUE INTRO SHIT
	 *
	 * @param	DialogueBox		Dialogue box, its fuking obvious.
	 *
	 */
	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns' || SONG.song.toLowerCase() == 'b-sides-roses' || SONG.song.toLowerCase() == 'b-sides-thorns' || SONG.song.toLowerCase() == 'luci-moment')
		{
			remove(black);

			if (SONG.song.toLowerCase() == 'thorns' || SONG.song.toLowerCase() == 'b-sides-thorns')
			{
				add(red);
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (SONG.song.toLowerCase() == 'thorns' || SONG.song.toLowerCase() == 'b-sides-thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play('assetss/sounds/Senpai_Dies' + TitleState.soundExt, 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
				{
					healthBar.visible = true;
					healthBarBG.visible = true;
					iconP1.visible = true;
					iconP2.visible = true;
					scoreTxt.visible = true;
					accurTxt.visible = true;
					startCountdown();
				}

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;

	 /**
	 * countdown shit
	 */
	function startCountdown():Void
	{
		if (SONG.song.toLowerCase() == 'luci-moment')
		{
			cheering.stop();
		}
		camHUD.visible = true;
		if (curSong != 'Lootus')
		{
			healthBar.visible = true;
			healthBarBG.visible = true;
			iconP1.visible = true;
			iconP2.visible = true;
			scoreTxt.visible = true;
			accurTxt.visible = true;
		}
		inCutscene = false;

		generateStaticArrows(0);
		generateStaticArrows(1);

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			dad.dance();
			gf.dance();
			if(boyfriend.curCharacter == 'bf-car' || boyfriend.curCharacter == 'mom-car')
				boyfriend.dance();
			else
				boyfriend.playAnim('idle');


			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('school', [
				'weeb/pixelUI/ready-pixel',
				'weeb/pixelUI/set-pixel',
				'weeb/pixelUI/date-pixel'
			]);
			introAssets.set('schoolEvil', [
				'weeb/pixelUI/ready-pixel',
				'weeb/pixelUI/set-pixel',
				'weeb/pixelUI/date-pixel'
			]);
			introAssets.set('pixelstreet', [
				'weeb/pixelUI/ready-pixel',
				'weeb/pixelUI/set-pixel',
				'weeb/pixelUI/date-pixel'
			]);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}

			switch (swagCounter)

			{
				case 0:
					FlxG.sound.playMusic('assetss/sounds/intro3' + altSuffix + TitleState.soundExt, 0.6, false);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image('' + introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (curStage.startsWith('school'))
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));
					if (curStage.startsWith('pixelstreet'))
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play('assetss/sounds/intro2' + altSuffix + TitleState.soundExt, 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image('' + introAlts[1]));
					set.scrollFactor.set();

					if (curStage.startsWith('school'))
						set.setGraphicSize(Std.int(set.width * daPixelZoom));
					if (curStage.startsWith('pixelstreet'))
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play('assetss/sounds/intro1' + altSuffix + TitleState.soundExt, 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image('' + introAlts[2]));
					go.scrollFactor.set();

					if (curStage.startsWith('school'))
						go.setGraphicSize(Std.int(go.width * daPixelZoom));
					if (curStage.startsWith('pixelstreet'))
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play('assetss/sounds/introGo' + altSuffix + TitleState.soundExt, 0.6);
				case 4:
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
		regenTimer = new FlxTimer().start(2, function (tmr:FlxTimer) {
			if (poisonExr)
				health -= 0.005;
			if (supLove)
				health +=  0.005;
		}, 0);
		sickFastTimer = new FlxTimer().start(2, function (tmr:FlxTimer) {
			if (accelNotes) {
				trace("tick:" + noteSpeed);
				noteSpeed += 0.01;
			}

		}, 0);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	 /**
	 * song start
	 */
	function startSong():Void
	{
		startingSong = false;
		startedSONG = true;
		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
			FlxG.sound.playMusic("assetss/music/" + SONG.song + "_Inst" + TitleState.soundExt, 1, false);
		FlxG.sound.music.onComplete = endSong;
		vocals.play();

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") ", iconRPC, true, songLength);
		#end
	}

	var debugNum:Int = 0;

	 /**
	 * song generation
	 *
	 * @param	dataPath	Path of the song, duh.
	 *
	 */
	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
		{
			if (SONG.song.toLowerCase() == 'blammed' && SONG.player1 == 'pico')
			{
				#if sys
				vocals = new FlxSound().loadEmbedded(Sound.fromFile("assetss/music/" + curSong + "_Voices_Pico" + TitleState.soundExt));
				#else
				vocals = new FlxSound().loadEmbedded("assetss/music/" + curSong + "_Voices_Pico" + TitleState.soundExt);
				#end
			}	
			else
			{
				#if sys
				vocals = new FlxSound().loadEmbedded(Sound.fromFile("assetss/music/" + curSong + "_Voices" + TitleState.soundExt));
				#else
				vocals = new FlxSound().loadEmbedded("assetss/music/" + curSong + "_Voices" + TitleState.soundExt);
				#end
			}
		}
		else
		{
			vocals = new FlxSound();
		}	

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 16);

				var gottaHitNote:Bool = section.mustHitSection;

				// ok
				switch (songNotes[1])
				{
					case 0:
						gottaHitNote = section.mustHitSection;
					case 1:
						gottaHitNote = section.mustHitSection;
					case 2:
						gottaHitNote = section.mustHitSection;
					case 3:
						gottaHitNote = section.mustHitSection;
					case 8:
						gottaHitNote = section.mustHitSection;
					case 9:
						gottaHitNote = section.mustHitSection;
					case 10:
						gottaHitNote = section.mustHitSection;	
					case 11:
						gottaHitNote = section.mustHitSection;
					default:
						gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				if (!swagNote.isSustainNote) {
					swagNote.flipX = flippedNotes;
					swagNote.flipY = flippedNotes;
				}
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress && curSong != 'Lootus')
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}
					else if (sustainNote.mustPress && curSong == 'Lootus' )
					{
						sustainNote.x += FlxG.width / 3;
						sustainNote.x -= 40;
					}

					if (!sustainNote.mustPress && curSong == 'Lootus')
						sustainNote.alpha = 0;
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress && curSong != 'Lootus')
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else if (swagNote.mustPress && curSong == 'Lootus')
				{
					swagNote.x += FlxG.width / 3;
					swagNote.x -= 40;
				}

				if (!swagNote.mustPress && curSong == 'Lootus')
					swagNote.alpha = 0;
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	var babyArrow:FlxSprite;

	 /**
	 * static arrow generation
	 *
	 * @param	Player		Which side of the arrows are generated.
	 *
	 */
	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			babyArrow = new FlxSprite(0, strumLine.y);
			babyArrow.flipX = flippedNotes;
			babyArrow.flipY = flippedNotes;
			switch (curStage)
			{
				case 'school' | 'schoolEvil':
					babyArrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
					}

				default:
					babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

					switch (Math.abs(i))
					{
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.addByPrefix('static', 'arrowUP');
							babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
							babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.addByPrefix('static', 'arrowDOWN');
							babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.addByPrefix('static', 'arrowLEFT');
							babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
					}
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			babyArrow.y -= 10;
			babyArrow.alpha = 0;
			if (!OptionsHandler.options.cinematicMode)
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			else
				babyArrow.alpha = 1;

			babyArrow.ID = i;

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			} else if (player == 2 && curSong != 'Lootus') {
				player2Strums.add(babyArrow);
			}

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			if (player == 2)
				babyArrow.alpha = 0;

			if (curSong == 'Lootus')
			{
				babyArrow.x += FlxG.width / 3;
				babyArrow.x -= 40;
			}
			else
				babyArrow.x += ((FlxG.width / 2) * player);

			strumLineNotes.add(babyArrow);
		}
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	 /**
	 * open substate
	 */
	override function openSubState(SubState:FlxSubState)
	{
		if (cameraUpside)
		{
			FlxG.camera.angle = 0;
			camHUD.angle = 0;
		}

		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	 /**
	 * pause close function
	 */
	override function closeSubState()
	{
		if (cameraUpside)
		{
			FlxG.camera.angle = 0;
			camHUD.angle = 0;
		}

		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if desktop
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ") ", iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ") ", iconRPC);
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ") ", iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ") ", iconRPC);
			}
		}
		#end

		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ") ", iconRPC);
		}
		#end

		super.onFocusLost();
	}

	 /**
	 * vocal resync
	 */
	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var no:Bool = false;

	 /**
	 * no idea what this does
	 */
	function truncateFloat( number : Float, precision : Int): Float {
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round( num ) / Math.pow(10, precision);
		return num;
		}

	var frameRateRatio:Float = MusicBeatState.funkyFramerate / 60;

	public static var songRate = 1.5;

	// stolen from exr lololololol
	var camShake:Bool = false;
	var noteSnake:Bool = false;
	var noteHyper:Bool = false;
	var inMiniGame1:Bool = false;
	var inMiniGame2:Bool = false;
	var won:Bool = false;
	var clicks:Int = 0;

	var fails:Int = 0;

	override public function update(elapsed:Float)
	{
		fakeFramerate = Math.round((1 / FlxG.elapsed) / 10);
		Conductor.timeScale = Conductor.safeZoneOffset / 166;

		if (songScore < 0)
			songScore = 0;

		var currentlyScaled = false;

		if (currentlyScaled)
		{
			camHUD.setScale(1, 2);
		}
		
		#if !debug
		perfectMode = false;
		#end

		if (autoMode)
		{
			// authenticity at its finest
			misses = 0;
			accuracy = 100.00;
		}

		if (!paused)
		{
			// actual fuck shit
			if (cameraUpside)
			{
				FlxG.camera.angle = 180;
				camHUD.angle = 180;
			}
		}

		if (earthDeath)
		{
			FlxG.camera.x = Math.sin(songTime)*40 * 1*2;
			camHUD.x = Math.sin(songTime)*97 * 1*2;
		}

		if (camShake)
		{
			camHUD.x = Math.sin(songTime)*40 * 1*2;
		}

		if (doof.cutsceneShitTest && inCutscene)
			dad.playAnim('singUP', true);
		else
			trace('gone');

		var changeIcon:Bool = false;

		if (health > 1 && !startedSONG)
			health -= 0.04;

		lastHealth = health;

		switch (curStage)
		{
			case 'philly', 'annie':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				// phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed;
		}

		wiggleShit.update(Conductor.crochet);
		sustainWiggle.update(Conductor.crochet);

		super.update(elapsed);

		if (!autoMode)
			scoreTxt.text = "Score:" + songScore + "                Misses:" + misses;
		else if (autoMode)
			scoreTxt.text = "AUTO IS ENABLED";
		if (!autoMode)
			accurTxt.text = "                                                          Health:" + Math.round(health * 50) + "%";
		
		if (OptionsHandler.options.cinematicMode)
			scoreTxt.text = "Score:" + songScore;
		scoreTxt.screenCenter(X);
		accurTxt.screenCenter(X);

		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;
			// actual fuck shit

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1))
			{
				// gitaroo man easter egg
				FlxG.switchState(new GitarooPause());
			}
			else
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			
			#if desktop
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			#end
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			if (SONG.song.toLowerCase() == 'luci-moment')
				cheering.stop();

			FlxG.switchState(new ChartingState());
			
			#if desktop
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
		}

		if (FlxG.keys.justPressed.NINE)
		{
			if (iconP1.animation.curAnim.name == 'old')
				iconP1.animation.play('icon');
			else if (iconP1.animation.curAnim.name != 'old')
				iconP1.animation.play('old');
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(iconP1.width, 150, 0.50 / frameRateRatio)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(iconP2.width, 150, 0.50 / frameRateRatio)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;
	
		// nice
		if (health < 0)
			health = 0;

		if (poisonTimes == 0) {
			if (healthBar.percent < 20)
				iconP1.animation.curAnim.curFrame = 1;
			else
				iconP1.animation.curAnim.curFrame = 0;
		} else {
			iconP1.animation.curAnim.curFrame = 2;
		}

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
		{
			iconP2.animation.curAnim.curFrame = 2;
		}
		else
		{
			iconP2.animation.curAnim.curFrame = 0;
		}

		if (FlxG.keys.justPressed.NINE)
		{
			if (SONG.song.toLowerCase() == 'luci-moment')
				cheering.stop();
			FlxG.switchState(new LatencyState());
			
			#if desktop
			DiscordClient.changePresence("Latency Editor", null, null, true);
			#end
		}

		if (FlxG.keys.pressed.SHIFT && FlxG.keys.pressed.EIGHT)
		{
			if (SONG.song.toLowerCase() == 'luci-moment')
				cheering.stop();
			FlxG.switchState(new AnimationDebug(SONG.player1, false));
			
			#if desktop
			DiscordClient.changePresence("Offset Editor (Player 1)", null, null, true);
			#end
		}
		else if (FlxG.keys.pressed.CONTROL && FlxG.keys.pressed.EIGHT)
		{
			if (SONG.song.toLowerCase() == 'luci-moment')
				cheering.stop();
			FlxG.switchState(new AnimationDebug(SONG.gf, true));
			
			#if desktop
			DiscordClient.changePresence("Offset Editor (Girlfriend)", null, null, true);
			#end
		}
		else if (FlxG.keys.justPressed.EIGHT)
		{
			if (SONG.song.toLowerCase() == 'luci-moment')
				cheering.stop();
			FlxG.switchState(new AnimationDebug(SONG.player2, true));

			#if desktop
			DiscordClient.changePresence("Offset Editor (Player 2)", null, null, true);
			#end
		}

		if (FlxG.keys.justPressed.F8)
		{
			autoMode = !autoMode;
			cpuMode = false;
		}

		if (FlxG.keys.justPressed.F8 && FlxG.keys.pressed.SHIFT)
		{
			autoMode = !autoMode;
			cpuMode = !cpuMode;
		}

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (curBeat % 4 == 0)
			{
				// trace(PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			}

			if (camFollow.x != dad.getMidpoint().x + 150 && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
				// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);

				switch (dad.curCharacter)
				{
					case 'mom':
						camFollow.y = dad.getMidpoint().y;
					case 'senpai':
						camFollow.y = dad.getMidpoint().y - 430;
						camFollow.x = dad.getMidpoint().x - 100;
					case 'senpai-angry':
						camFollow.y = dad.getMidpoint().y - 430;
						camFollow.x = dad.getMidpoint().x - 100;
					case 'senpaidumb':
						camFollow.y = dad.getMidpoint().y - 430;
						camFollow.x = dad.getMidpoint().x - 100;
					
				}

				if (dad.curCharacter == 'mom')
					vocals.volume = 1;

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					tweenCamIn();
				}
			}

			if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100)
			{
				camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

				switch (curStage)
				{
					case 'limo':
						camFollow.x = boyfriend.getMidpoint().x - 300;
					case 'mall':
						camFollow.y = boyfriend.getMidpoint().y - 200;
					case 'school':
						camFollow.x = boyfriend.getMidpoint().x - 200;
						camFollow.y = boyfriend.getMidpoint().y - 200;
					case 'schoolEvil':
						camFollow.x = boyfriend.getMidpoint().x - 200;
						camFollow.y = boyfriend.getMidpoint().y - 200;
					case 'mtc':
						camFollow.x = boyfriend.getMidpoint().x - 300;
					case 'pixelstreet':
						camFollow.x = boyfriend.getMidpoint().x - 300;
				}

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
				}
			}
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}
		
		// nof
		if (combo == 1000)
			combo == 10;

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);
		FlxG.watch.addQuick("healthShit", Math.round(health * 50));

		var yes:Bool = false;

		if (yes)
		{
			strumLineNotes.forEach(function(spr:FlxSprite){
				spr.flipY = !spr.flipY;
				spr.flipX = !spr.flipX;
			});
			notes.forEachAlive(function(spr:Note){
				spr.flipY = !spr.flipY;
				spr.flipX = !spr.flipX;
			});
		}

		var curGame:Int = 0;

		var gameInfo:FlxSprite = new FlxSprite();
		var ambience:Bool = false;

		if (curSong == 'Lootus')
		{
			while (ambience)
			{
				FlxG.sound.music.volume -= 0.05;
			}
			gameInfo.loadGraphic(Paths.image('uk/dosomething' + curGame + ''));
			gameInfo.screenCenter(X);
			gameInfo.scrollFactor.set();
			gameInfo.visible = false;
			switch (curStep)
			{
				case 38:
					FlxTween.tween(camHUD, { angle: 10 }, 1, { ease: FlxEase.circOut });
					camTurn();
				case 47:
					FlxTween.tween(camHUD, { angle: -10 }, 1, { ease: FlxEase.circOut });
					camTurn();
				case 55:
					FlxTween.tween(camHUD, { angle: 5 }, 1, { ease: FlxEase.circOut });
					camTurn();
				case 63:
					FlxTween.tween(camHUD, { angle: -10 }, 1, { ease: FlxEase.circOut });
					camTurn();
				case 71:
					FlxTween.tween(camHUD, { angle: -5 }, 1, { ease: FlxEase.circOut });
					camTurn();
				case 79:
					FlxTween.tween(camHUD, { angle: 10 }, 1, { ease: FlxEase.circOut });
					camTurn();
				case 87:
					FlxTween.tween(camHUD, { angle: -10 }, 1, { ease: FlxEase.circOut });
					camTurn();
				case 95:
					FlxTween.tween(camHUD, { angle: 5 }, 1, { ease: FlxEase.circOut });
					camTurn();
				case 103:
					FlxTween.tween(camHUD, { angle: 10 }, 1, { ease: FlxEase.circOut });
					camTurn();
				case 111:
					FlxTween.tween(camHUD, { angle: -10 }, 1, { ease: FlxEase.circOut });
					camTurn();
				case 119:
					FlxTween.tween(camHUD, { angle: 15 }, 1, { ease: FlxEase.circOut });
					camTurn();
				case 127:
					FlxTween.tween(camHUD, { angle: -10 }, 1, { ease: FlxEase.circOut });
					camTurn();
				case 135:
					FlxTween.tween(camHUD, { angle: 10 }, 1, { ease: FlxEase.circOut });
					camTurn();
				case 143:
					FlxTween.tween(camHUD, { angle: -5 }, 1, { ease: FlxEase.circOut });
					camTurn();
				case 153:
					FlxTween.tween(camHUD, { angle: 0 }, 1, { ease: FlxEase.circOut });
					camTurn();
				case 163:
					yes = true;
					scrollSet(true, 2);
				case 183:
					scrollSet(false, 2);
				case 200:
					scrollSet(true, 2);
				case 215:
					scrollSet(false, 2);
				case 231:
					scrollSet(true, 2);
				case 247:
					scrollSet(false, 2);
				case 263:
					scrollSet(true, 2);
				case 278:
					scrollSet(false, 3);
					yes = false;
					strumLineNotes.forEach(function(spr:FlxSprite){
						spr.flipY = false;
						spr.flipX = false;
					});
				case 295:
					strumLineNotes.forEach(function(spr:FlxSprite){
						FlxTween.tween(spr, { alpha: 0 }, 0.5, { ease: FlxEase.circOut });
					});
					no = true;
				case 420:
					strumLineNotes.forEach(function(spr:FlxSprite){
						FlxTween.tween(spr, { alpha: 1 }, 0.5, { ease: FlxEase.circOut });
					});
					no = false;
				case 544:
					ambience = true;
				case 546:
					clickBG.visible = true;
					clickButton.visible = true;
					clickBG.alpha = 0;
					clickButton.alpha = 0;
					clickBG.x -= 500;
					clickButton.x -= 500;
					FlxTween.tween(clickBG, { x: 0, alpha: 1 }, 0.5, {ease: FlxEase.quadInOut});
					FlxTween.tween(clickButton, { x: 0, alpha: 1 }, 0.6, {ease: FlxEase.circOut});
					ambience = false;
				case 549:
					strumLineNotes.forEach(function(spr:FlxSprite){
						FlxTween.tween(spr, { alpha: 0 }, 0.5, { ease: FlxEase.circOut });
					});
					notes.forEachAlive(function(daNote:Note){
						FlxTween.tween(daNote, { alpha: 0 }, 0.5, {ease: FlxEase.quadInOut});
					});
				case 553:
					FlxG.sound.play('assetss/sounds/ambience.ogg');
					inMiniGame1 = true;
				case 555:
					strumLineNotes.forEach(function(spr:FlxSprite){
						FlxTween.tween(spr, { x: spr.x + spr.width / 2 }, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
					});
					noteSnake = true;
					no = false;
					FlxG.sound.music.volume = 1;
				case 615:
					inMiniGame1 = false;
					FlxTween.tween(clickBG, { x: -500, alpha: 0 }, 0.5, {ease: FlxEase.quadInOut});
					FlxTween.tween(clickButton, { x: -500, alpha: 0 }, 0.6, {ease: FlxEase.circOut});
					showRate(won);
				case 620:
					strumLineNotes.forEach(function(spr:FlxSprite){
						FlxTween.tween(spr, { alpha: 1 }, 0.5, { ease: FlxEase.circOut });
					});
					notes.forEachAlive(function(daNote:Note){
						FlxTween.tween(daNote, { alpha: 1 }, 0.5, {ease: FlxEase.quadInOut});
					});
				case 635:
					won = false;
					clickBG.visible = false;
					clickButton.visible = false;
			}
		}

		if (curSong == 'Fresh')
		{
			switch (curBeat)
			{
				case 16:
					camZooming = true;
					gfSpeed = 2;
				case 48:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				case 112:
					gfSpeed = 1;
				case 163:
					// FlxG.sound.music.stop();
					// FlxG.switchState(new TitleState());
			}
		}

		if (curSong == 'Spookeez')
		{
			switch (curBeat)
			{
				case 39:
					// for later lmao
					// dad.playAnim('hey', true);
			}
		}	

		if (curSong == 'Bopeebo')
		{

			switch (curBeat)
			{
				case 128, 129, 130:
					vocals.volume = 0;
					// FlxG.sound.music.stop();
					// FlxG.switchState(new PlayState());
			}
		}

		if (curSong == 'Dadbattle' && storyDifficulty == 2)
			gfSpeed == 0.1;


		// better streaming of shit

		// RESET = Quick Game Over Screen
		if (controls.RESET)
		{
			TitleState.deathCounter += 1;
			boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			
			#if desktop
			// Game Over doesn't get his own variable because it's only used here
			DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			#end
			trace("RESET = True");
		}

		var currentlyAttacking:Bool = false;
		var regenderated:Bool = false;

		// CHEAT = brandon's a pussy
		if (controls.CHEAT)
		{
			regenderated = false;
			if (!regenderated)
			{
				if (health <= 2)
					health += 0.01;
				else
					regenderated = true;
			}
			trace("User is cheating!");
		}

		if (FlxG.keys.pressed.Z)
		{
			if (!currentlyAttacking)
				boyfriend.playAnim("singpreattack", true);
		}

		if (FlxG.keys.justReleased.Z)
		{
			if (!currentlyAttacking)
			{
				health += 0.075;
				currentlyAttacking = true;
				boyfriend.playAnim("singattack", true);
				new FlxTimer().start(0.7, function(tmr:FlxTimer){
					boyfriend.playAnim("singattack", true, true);
					new FlxTimer().start(0.7, function(tmr:FlxTimer){
						boyfriend.playAnim("singpreattack", true);
						currentlyAttacking = false;
					});
				});
			}
		}
		
		if (FlxG.keys.justPressed.C)
		{
			health -= 0.1;
			boyfriend.playAnim("singahfuckivebeenhit", true);
		}
		
		if (FlxG.keys.justPressed.V)
		{
			boyfriend.playAnim("singnoscope", true);
		}

		if (health <= 0 && !practiceMode)
		{
			TitleState.deathCounter += 1;
			boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			
			#if desktop
			// Game Over doesn't get his own variable because it's only used here
			DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			#end
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 1500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		var curSwing:Bool = false;

		if (generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				var possibleNotes:Array<Note> = [];

				var ignoreList:Array<Int> = [];
				var i:Float = 1;

				if (daNote.y > FlxG.height)
				{
					daNote.active = false;
					daNote.visible = false;
					i = 1;
				}
				else
				{
					i += 0.01;
					if (!OptionsHandler.options.cinematicMode)
					{
						daNote.visible = true;
						daNote.active = true;
					}
					else
					{
						daNote.alpha = 0;
					}
				}

				if (downScrollTime)
					daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (-0.45 * FlxMath.roundDecimal(SONG.speed, 2)));
				else
					daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(SONG.speed, 2)));

				var pi:Float = 0;
				pi += Math.PI/100;
				
				if (noteSnake) {
					if (FlxG.random.bool(50))
						daNote.x -= 10 / i;
					else
						daNote.x += 10 / i;
				}

				if (!downScrollTime)
				{
					// i am so fucking sorry for this if condition
					if (daNote.isSustainNote && daNote.y + daNote.offset.y <= strumLine.y + Note.swagWidth/2
						&& (!daNote.mustPress || (daNote.wasGoodHit || 
							(daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
					{
						var swagRect = new FlxRect(0, strumLine.y + Note.swagWidth/2 - daNote.y, daNote.width * 2, daNote.height * 2);
						swagRect.y /= daNote.scale.y;
						swagRect.height -= swagRect.y;
	
						daNote.clipRect = swagRect;
					}
					else if (autoMode && daNote.isSustainNote && daNote.y + daNote.offset.y <= strumLine.y + Note.swagWidth/2
						&& (daNote.mustPress || (daNote.wasGoodHit || 
							(daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
					{
						var swagRect = new FlxRect(0, strumLine.y + Note.swagWidth/2 - daNote.y, daNote.width * 2, daNote.height * 2);
						swagRect.y /= daNote.scale.y;
						swagRect.height -= swagRect.y;
	
						daNote.clipRect = swagRect;
					}
				}

				if (!daNote.mustPress && daNote.wasGoodHit)
				{
					if (SONG.song != 'Tutorial')
						camZooming = true;

					var altAnim:String = "";
					var noteAnim:String = "";

					if (SONG.notes[Math.floor(curStep / 16)] != null)
					{
						if (SONG.notes[Math.floor(curStep / 16)].altAnim)
							altAnim = '-alt';
					}

					if (SONG.notes[Math.floor(curStep / 16)] != null)
					{
						if (SONG.notes[Math.floor(curStep / 16)].longNoteAnim)
							if (daNote.isSustainNote)
								noteAnim = '-long';
					}

					switch (Math.abs(daNote.noteData))
					{
						case 0:
							dad.playAnim('singLEFT' + altAnim + noteAnim, true);
						case 1:
							dad.playAnim('singDOWN' + altAnim + noteAnim, true);
						case 2:
							dad.playAnim('singUP' + altAnim + noteAnim, true);
						case 3:
							dad.playAnim('singRIGHT' + altAnim + noteAnim, true);
						case 4:
							dad.playAnim('singLEFT' + altAnim + noteAnim, true);
						case 5:
							dad.playAnim('singDOWN' + altAnim + noteAnim, true);
						case 6:
							dad.playAnim('singUP' + altAnim + noteAnim, true);
						case 7:
							dad.playAnim('singRIGHT' + altAnim + noteAnim, true);
						case 8:
							dad.playAnim('singLEFT' + altAnim + noteAnim, true);
						case 9:
							dad.playAnim('singDOWN' + altAnim + noteAnim, true);
						case 10:
							dad.playAnim('singUP' + altAnim + noteAnim, true);
						case 11:
							dad.playAnim('singRIGHT' + altAnim + noteAnim, true);
						case 12:
							dad.playAnim('singLEFT' + altAnim + noteAnim, true);
						case 13:
							dad.playAnim('singDOWN' + altAnim + noteAnim, true);
						case 14:
							dad.playAnim('singUP' + altAnim + noteAnim, true);
						case 15:
							dad.playAnim('singRIGHT' + altAnim + noteAnim, true);
					}

					var strummingNotes:Int = daNote.noteData % 4;

					// lel
					if (OptionsHandler.options.p2noteStrums && curSong != "Lootus")
					{
						player2Strums.forEach(function(spr:FlxSprite)
						{
							if (Math.abs(strummingNotes) == spr.ID)
							{
								spr.animation.play('confirm');
								sustain2(spr.ID, spr, daNote);
							}
						});
					}
					
					dad.holdTimer = 0;

					if (SONG.needsVoices)
						vocals.volume = 1;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
					i = 1;
				}

				if (daNote.canBeHit && daNote.mustPress && autoMode && !daNote.mineNote)
				{
					new FlxTimer().start(0.0675, function(tmr:FlxTimer)
					{
						switch(Math.abs(daNote.noteData))
						{
							case 0:
								autoNoteHit(daNote);
							case 1:
								autoNoteHit(daNote);
							case 2:
								autoNoteHit(daNote);
							case 3:
								autoNoteHit(daNote);
							case 4:
								autoNoteHit(daNote);
							case 5:
								autoNoteHit(daNote);
							case 6:
								autoNoteHit(daNote);
							case 7:
								autoNoteHit(daNote);
						}
				
						boyfriend.holdTimer = 0;
		
						if (SONG.needsVoices)
							vocals.volume = 1;
	
						if (!daNote.mineNote)
						{
							daNote.kill();
							notes.remove(daNote, true);
							daNote.destroy();
						}
						i = 1;
						// idleShit();
					});	
				}

				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				// say no to missing

				if (no)
				{
					if (daNote.y <= 200 * SONG.speed && !downScrollTime || daNote.y >= strumLine.y + 86 && downScrollTime)
					{
						FlxTween.tween(daNote, { color: FlxColor.BLACK }, 0.5, { ease: FlxEase.circOut });
						daNote.alpha -= 0.1;
					}
				}

				if (!autoMode)
				{
					if (daNote.y < -daNote.height && !downScrollTime && !inMiniGame1 || daNote.y >= strumLine.y + 106 && downScrollTime && !inMiniGame1 )
					{
						if (daNote.tooLate || !daNote.wasGoodHit)
							{
								if (!daNote.mineNote)
								{
									health -= 0.0475 + healthLossModifier;
									misses += 1;
									combo = 0;
									songScore -= 10;
									vocals.volume = 0;
		
									if (poisonPlus && poisonTimes < 5) {
										poisonTimes += 1;
										var poisonPlusTimer = new FlxTimer().start(0.5, function (tmr:FlxTimer) {
											health -= 0.05;
										}, 0);
										// stop timer after 3 seconds
										new FlxTimer().start(3, function (tmr:FlxTimer) {
											poisonPlusTimer.cancel();
											poisonTimes -= 1;
										});
									}
								}
							}
							if (fullComboMode || perfectMode) {
								// you signed up for this your fault
								health = 0;
							}

						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
						i = 1;
					}
				}
			});

			if (OptionsHandler.options.p2noteStrums && curSong != "Lootus")
			{
				player2Strums.forEach(function(spr:FlxSprite)
				{
					if (strumming2[spr.ID])
					{
						spr.animation.play("confirm");
					}
		
					if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
					{
						spr.centerOffsets();
						spr.offset.x -= 13;
						spr.offset.y -= 13;
					}
					else
						spr.centerOffsets();
				});
			}
		}

		if (!inCutscene && !autoMode && inMiniGame1 == false)
			keyShit();
		else if (inMiniGame1 == true)
			miniKeyShit();

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end

		if (skippedSong)
			endSong();
	}

	function sustain2(strum:Int, spr:FlxSprite, note:Note):Void
	{
		var length:Float = note.sustainLength;
	
		if (length > 0)
		{
			strumming2[strum] = true;
		}
	
		var bps:Float = Conductor.bpm/60;
		var spb:Float = 1/bps;
	
		if (!note.isSustainNote && !paused)
		{
			new FlxTimer().start(length == 0 ? 0.2 : (length / Conductor.crochet * spb) + 0.1, function(tmr:FlxTimer)
			{
				if (!paused)
				{
					if (!strumming2[strum])
					{
						spr.animation.play("static", true);
					} else if (length > 0) {
						strumming2[strum] = false;
						spr.animation.play("static", true);
					}
				}
				else
				{
					trace('youre in the pause menu dumass');
					trace('youre cringe');
				}
			});
		}
	}
		
	/**
	 * says it all lmao
	 */
	function endSong():Void
	{
		lastHealth = 2;
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		if (SONG.validScore)
		{
			#if !switch
			Highscore.saveScore(SONG.song, Math.round(songScore), storyDifficulty);
			#end
		}

		if (isStoryMode)
		{
			campaignScore += Math.round(songScore);

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0)
			{
				TitleState.deathCounter = 0;
				FlxG.sound.playMusic(Paths.music('freakyMenu' + TitleState.bModdin, 'shared'));

				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;
				skippedSong = false;
				camHUD.visible = false;

				FlxG.switchState(new StoryMenuState());

				// if ()
				StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

				if (SONG.validScore)
				{
					NGio.unlockMedal(60961);
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
				}

				FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				FlxG.save.flush();
			}
			else
			{
				var difficulty:String = "";

				if (storyDifficulty == 2)
					difficulty = '-hard';

				if (storyDifficulty == 3)
					difficulty = '-hell';

				trace('LOADING NEXT SONG');
				trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

				if (SONG.song.toLowerCase() == 'eggnog')
				{
					var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
						-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackShit.scrollFactor.set();
					add(blackShit);
					camHUD.visible = false;

					FlxG.sound.play('assetss/sounds/Lights_Shut_off' + TitleState.soundExt);
				}

				if (!skippedSong)
				{
					TitleState.deathCounter = 0;
					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					FlxTween.tween(camHUD, {alpha: 0}, 0.4, {
						ease: FlxEase.quadOut,
						onComplete: function(twn:FlxTween)
						{
							trace('BACK TO MENU');
						}
					});
				}
				else 
				{
					FlxTransitionableState.skipNextTransIn = false;
					FlxTransitionableState.skipNextTransOut = false;
					camHUD.visible = true;
					camHUD.alpha = 1;
				}
				skippedSong = false;
				prevCamFollow = camFollow;

				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
				FlxG.sound.music.stop();

				FlxG.switchState(new PlayState());

			}
		}
		else
		{
			FlxTween.tween(camHUD, {alpha: 0}, 0.4, {
				ease: FlxEase.quadOut,
				onComplete: function(twn:FlxTween)
				{
					trace('BACK TO MENU');
				}
			});
			if (isCreditsMode)
			{
				trace('WENT BACK TO OPTION MENU??');
				FlxG.switchState(new OptionsMenu());
			}
			else if (isBSidesMode)
			{
					trace('Cringe B Mode ');
					FlxG.switchState(new BSidesState());
			}
			else if (isShitpostMode)
			{
					trace('Cringe Shitpost Mode ');
					FlxG.switchState(new CustomSongState());
			}
			else 
			{
				trace('WENT BACK TO FREEPLAY??');
				FlxG.switchState(new FreeplayState());
			}
		}
	}

	var endingSong:Bool = false;
	var comboText:Bool = true;

	/**
	 * Rating score function
	 *
	 * @param	Strumtime	How much early or late the note was hit.
	 *
	 */
	private function popUpScore(strumtime:Float):Void
	{
		var noteDiff:Float = strumtime - Conductor.songPosition;
		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		//

		var rating:FlxSprite = new FlxSprite();
		var timing:FlxSprite = new FlxSprite();
		var score:Float = 350;

		var daRating:String = "sick";
		var daTiming:String = "";

			if (noteDiff > Conductor.safeZoneOffset * 0.9)
			{
				daRating = 'shit';
				daTiming = 'early';
				score = 50;
				ss = false;
				comboText = false;
			}
			else if (noteDiff < Conductor.safeZoneOffset * -0.9)
			{
				daRating = 'shit';
				daTiming = 'late';
				score = 50;
				ss = false;
				comboText = false;
			}
			else if (noteDiff > Conductor.safeZoneOffset * 0.75)
			{
				daRating = 'bad';
				daTiming = 'early';
				score = 100;
				ss = false;
				comboText = false;
			}
			else if (noteDiff < Conductor.safeZoneOffset * -0.75)
			{
				daRating = 'bad';
				daTiming = 'late';
				score = 100;
				ss = false;
				comboText = false;
			}
			else if (noteDiff > Conductor.safeZoneOffset * 0.2)
			{
				daRating = 'good';
				daTiming = 'early';
				score = 200;
				ss = true;
				comboText = false;
			}
			else if (noteDiff < Conductor.safeZoneOffset * -0.2)
			{
				daRating = 'good';
				daTiming = 'late';
				score = 200;
				ss = true;
				comboText = false;
			}
			else if (noteDiff > Conductor.safeZoneOffset * 0.1)
			{
				daRating = 'fantastic';
				score = 300;
				ss = true;
				comboText = true;
			}
		if (daRating == 'sick')
		{
			ss = true;
			comboText = true;
		}
	
		trace('hit ' + daRating);

		if (!autoMode)
			songScore += Math.round(score);

		/* if (combo > 60)
				daRating = 'sick';
			else if (combo > 12)
				daRating = 'good'
			else if (combo > 4)
				daRating = 'bad';
		 */

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (curStage.startsWith('school'))
		{
			pixelShitPart1 = 'weeb/pixelUI/';
			pixelShitPart2 = '-pixel';
		}
		if (curStage.startsWith('pixelstreet'))
		{
			pixelShitPart1 = 'weeb/pixelUI/';
			pixelShitPart2 = '-pixel';
		}
		if (SONG.player1 == 'bf-pain')
		{
			pixelShitPart1 = 'pain/';
			pixelShitPart2 = '-bad';
		}

		rating.loadGraphic(Paths.image('' + pixelShitPart1 + daRating + pixelShitPart2));
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image('' + pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		if (comboText)
			add(comboSpr);
		
		if(daTiming != "")
		{
			timing.loadGraphic(Paths.image('' + pixelShitPart1 + daTiming + pixelShitPart2));
			timing.screenCenter();
			timing.x = coolText.x + 50;
			timing.acceleration.y = 550;
			timing.velocity.y -= FlxG.random.int(140, 175);
			timing.velocity.x -= FlxG.random.int(0, 10);
			add(timing);
		}
	
		add(rating);

		if (!curStage.startsWith('school'))
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = true;
			timing.setGraphicSize(Std.int(timing.width * 0.7));
			timing.antialiasing = true;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = true;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
			timing.setGraphicSize(Std.int(timing.width * daPixelZoom * 0.7));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();
		timing.updateHitbox();

		if (curStage == 'pixelstreet') {
			comboSpr.visible = false;
			rating.visible = false;
			timing.visible = false;
		}	

		var seperatedScore:Array<Int> = [];

		var comboSplit:Array<String> = (combo + "").split('');
		if (comboSplit.length == 2)
			seperatedScore.push(0); // make sure theres a 0 in front or it looks weird lol!

		for(i in 0...comboSplit.length)
		{
			var str:String = comboSplit[i];
			seperatedScore.push(Std.parseInt(str));
		}

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image('' + pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2 + ''));
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			if (!curStage.startsWith('school'))
			{
				numScore.antialiasing = true;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);

			if (combo >= 10 || combo == 0)
				add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}
		/* 
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(timing, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		if (comboText)
		{
			FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					coolText.destroy();
					comboSpr.destroy();
	
					timing.destroy();
					rating.destroy();
				},
				startDelay: Conductor.crochet * 0.001
			});
		}

		curSection += 1;
	}

	var timeShown = 0;
	var currentTimingShown:FlxText = null;

	/**
	 * Rating score function
	 *
	 * @param	Strumtime	How much early or late the note was hit.
	 *
	 */
	private function itgPopupScore(strumtime:Float):Void
	{
		var noteDiff:Float = strumtime - Conductor.songPosition;
		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);
		var showingCombo:Bool = false;

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter(X);
		coolText.x = FlxG.width * 0.55;
		//

		var rating:FlxSprite = new FlxSprite();
		var timing:FlxSprite = new FlxSprite();
		var score:Float = 350;

		var daRating:String = "sick";
		var daTiming:String = "";

			if (noteDiff > Conductor.safeZoneOffset * 0.9)
			{
				daRating = 'shit';
				daTiming = 'early';
				score = 50;
				ss = false;
				comboText = false;
			}
			else if (noteDiff < Conductor.safeZoneOffset * -0.9)
			{
				daRating = 'shit';
				daTiming = 'late';
				score = 50;
				ss = false;
				comboText = false;
			}
			else if (noteDiff > Conductor.safeZoneOffset * 0.75)
			{
				daRating = 'wayoff';
				daTiming = 'early';
				score = 100;
				ss = false;
				comboText = false;
			}
			else if (noteDiff < Conductor.safeZoneOffset * -0.75)
			{
				daRating = 'wayoff';
				daTiming = 'late';
				score = 100;
				ss = false;
				comboText = false;
			}
			else if (noteDiff > Conductor.safeZoneOffset * 0.2)
			{
				daRating = 'good';
				daTiming = 'early';
				score = 200;
				ss = true;
				comboText = false;
			}
			else if (noteDiff < Conductor.safeZoneOffset * -0.2)
			{
				daRating = 'good';
				daTiming = 'late';
				score = 200;
				ss = true;
				comboText = false;
			}
			else if (noteDiff > Conductor.safeZoneOffset * 0.1)
			{
				daRating = 'excellent';
				score = 300;
				ss = true;
				comboText = true;
			}
			else if (noteDiff > Conductor.safeZoneOffset * 0.05)
			{
				daRating = 'fantastic';
				score = 300;
				ss = true;
				comboText = true;
			}
		if (daRating == 'sick')
		{
			ss = true;
			comboText = true;
		}
	
		trace('hit ' + daRating);

		if (!autoMode)
			songScore += Math.round(score);

		/* if (combo > 60)
				daRating = 'sick';
			else if (combo > 12)
				daRating = 'good'
			else if (combo > 4)
				daRating = 'bad';
		 */
		 rating.loadGraphic(Paths.image('' + daRating));
		rating.screenCenter(XY);

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image('' + 'combo' + ''));
		comboSpr.screenCenter(XY);
		comboSpr.y += 140;

		if (showingCombo)
		{
			remove(coolText);
			remove(rating);

			if (currentTimingShown != null && timeShown >= 20)
			{
				remove(currentTimingShown);
				currentTimingShown = null;
			}
		}

		 // add(comboSpr);

		 var msTiming = truncateFloat(noteDiff, 3);

			if (currentTimingShown != null)
				remove(currentTimingShown);

			currentTimingShown = new FlxText(0,0,0,"0ms");
			timeShown = 0;
			switch(daRating)
			{
				case 'shit' | 'bad':
					currentTimingShown.color = FlxColor.RED;
				case 'good':
					currentTimingShown.color = FlxColor.GREEN;
				case 'sick':
					currentTimingShown.color = FlxColor.CYAN;
			}
			currentTimingShown.borderStyle = OUTLINE;
			currentTimingShown.borderSize = 1;
			currentTimingShown.borderColor = FlxColor.BLACK;
			currentTimingShown.text = msTiming + "ms";
			currentTimingShown.size = 20;

			if (currentTimingShown.alpha != 1)
				currentTimingShown.alpha = 1;

			add(currentTimingShown);

	
		 add(rating);

		 currentTimingShown.screenCenter(XY);
		 currentTimingShown.y += 245;

		

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		rating.cameras = [camHUD];
		comboSpr.cameras = [camHUD];
		currentTimingShown.cameras = [camHUD];

		rating.setGraphicSize(Std.int(rating.width * 0.7));
		rating.antialiasing = true;
		// comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
		// comboSpr.antialiasing = true;

		// comboSpr.updateHitbox();
		rating.updateHitbox();
		currentTimingShown.updateHitbox();

		var seperatedScore:Array<Int> = [];

		var comboSplit:Array<String> = (combo + "").split('');

		for(i in 0...comboSplit.length)
		{
			var str:String = comboSplit[i];
			seperatedScore.push(Std.parseInt(str));
		}

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image('' + 'num' + Std.int(i) + ''));
			numScore.screenCenter(Y);
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			numScore.antialiasing = true;
			numScore.setGraphicSize(Std.int(numScore.width * 0.5));

			numScore.updateHitbox();

			if (combo >= 10)
				add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});
			numScore.cameras = [camHUD];
			numScore.x += 250;

			daLoop++;
		}

		/* 
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		showingCombo = true;

		rating.x += 350;


		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001,
				onUpdate: function(tween:FlxTween)
				{
					showingCombo = false;
					timeShown++;
				}
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				showingCombo = false;
				coolText.destroy();

				timing.destroy();
				rating.destroy();

				if (currentTimingShown != null && timeShown >= 20)
					{
						remove(currentTimingShown);
						currentTimingShown = null;
					}
			},
			startDelay: Conductor.crochet * 0.001
		});

		curSection += 1;
	}

	/**
	 * key checking
	 */
	 private function keyShit():Void
		{
			// HOLDING
			var up = controls.UP;
			var right = controls.RIGHT;
			var down = controls.DOWN;
			var left = controls.LEFT;
	
			var upP = controls.UP_P;
			var rightP = controls.RIGHT_P;
			var downP = controls.DOWN_P;
			var leftP = controls.LEFT_P;
	
			var upR = controls.UP_R;
			var rightR = controls.RIGHT_R;
			var downR = controls.DOWN_R;
			var leftR = controls.LEFT_R;
	
			var controlArray:Array<Bool> = [leftP, downP, upP, rightP];
			var controlHoldArray:Array<Bool> = [left, down, up, right];
			var foundDirectionStrum:Array<Float> = [0, 0, 0, 0];
			var foundDirectionNote:Array<Note> = [null, null, null, null];
	
			var startCount:Int = 0;
	
			Conductor.safeZoneOffset = (Conductor.safeFrames / ((FlxG.updateFramerate / 60) * 60)) * 1000;
			successThisFrame = [false, false, false, false];
			foundDirection = [false, false, false, false];
	
			missQueue.direction = 0;
			missQueue.missedNote = null;
			missQueue.missed = false;
			// FlxG.watch.addQuick('asdfa', upP);
			if ((upP || rightP || downP || leftP) && !boyfriend.stunned && generatedMusic)
			{
				boyfriend.holdTimer = 0;
				var possibleNotes:Array<Note> = [];
	
				notes.forEachAlive(function(daNote:Note)
				{
					var noteData:Int = daNote.noteData % 4;
					if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
					{
						if (!foundDirection[noteData] || foundDirectionStrum[noteData] > daNote.strumTime)
						{
							possibleNotes.push(daNote);
							if (foundDirectionNote[noteData] != null)
								possibleNotes.remove(foundDirectionNote[noteData]);
							foundDirection[noteData] = true;
							foundDirectionStrum[noteData] = daNote.strumTime;
							foundDirectionNote[noteData] = daNote;
						}
					}
				});
				startCount = possibleNotes.length;
	
				if (possibleNotes.length > 0)
				{
					// Breaks with new input system
					// Probably not needed anyway tho
					if (perfectMode)
						noteCheck(true, controlArray, possibleNotes[0]);
	
					for (i in 0...possibleNotes.length)
					{
						var possibleData:Int = possibleNotes[i].noteData % 4;
						noteCheck(controlArray[possibleData], controlArray, possibleNotes[i]);
					}
				}
				else
				{
					// No possible notes to hit lel
					missQueue.missed = true;
					for (i in 0...5)
					{
						if (controlArray[i])
						{
							missQueue.direction = i;
						}
					}
					missQueue.missedNote = null;
				}
	
				missNoteCheck(startCount, possibleNotes.length);
			}
	
			if ((up || right || down || left) && !boyfriend.stunned && generatedMusic)
			{
				notes.forEachAlive(function(daNote:Note)
				{
					var noteData:Int = daNote.noteData % 4;
					if (daNote.canBeHit && daNote.mustPress && daNote.isSustainNote)
					{
						switch (noteData)
						{
							// NOTES YOU ARE HOLDING
							case 0:
								if (left)
									goodNoteHit(daNote, controlHoldArray);
							case 1:
								if (down)
									goodNoteHit(daNote, controlHoldArray);
							case 2:
								if (up)
									goodNoteHit(daNote, controlHoldArray);
							case 3:
								if (right)
									goodNoteHit(daNote, controlHoldArray);
							case 4:
								if (left)
									goodNoteHit(daNote, controlHoldArray);
							case 5:
								if (down)
									goodNoteHit(daNote, controlHoldArray);
							case 6:
								if (up)
									goodNoteHit(daNote, controlHoldArray);
							case 7:
								if (right)
									goodNoteHit(daNote, controlHoldArray);
							case 8:
								if (left)
									goodNoteHit(daNote, controlHoldArray);
							case 9:
								if (down)
									goodNoteHit(daNote, controlHoldArray);
							case 10:
								if (up)
									goodNoteHit(daNote, controlHoldArray);
							case 11:
								if (right)
									goodNoteHit(daNote, controlHoldArray);
							case 12:
								if (left)
									goodNoteHit(daNote, controlHoldArray);
							case 13:
								if (down)
									goodNoteHit(daNote, controlHoldArray);
							case 14:
								if (up)
									goodNoteHit(daNote, controlHoldArray);
							case 15:
								if (right)
									goodNoteHit(daNote, controlHoldArray);
						}
					}
				});
			}
	
			if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !up && !down && !right && !left)
			{
				if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
				{
					boyfriend.playAnim('idle');
				}
			}
	
			playerStrums.forEach(function(spr:FlxSprite)
			{
				switch (spr.ID)
				{
					case 0:
						if (leftP && spr.animation.curAnim.name != 'confirm')
							spr.animation.play('pressed');
						if (leftR)
							spr.animation.play('static');
					case 1:
						if (downP && spr.animation.curAnim.name != 'confirm')
							spr.animation.play('pressed');
						if (downR)
							spr.animation.play('static');
					case 2:
						if (upP && spr.animation.curAnim.name != 'confirm')
							spr.animation.play('pressed');
						if (upR)
							spr.animation.play('static');
					case 3:
						if (rightP && spr.animation.curAnim.name != 'confirm')
							spr.animation.play('pressed');
						if (rightR)
							spr.animation.play('static');
					case 4:
						if (leftP && spr.animation.curAnim.name != 'confirm')
							spr.animation.play('pressed');
						if (leftR)
							spr.animation.play('static');
					case 5:
						if (downP && spr.animation.curAnim.name != 'confirm')
							spr.animation.play('pressed');
						if (downR)
							spr.animation.play('static');
					case 6:
						if (upP && spr.animation.curAnim.name != 'confirm')
							spr.animation.play('pressed');
						if (upR)
							spr.animation.play('static');
					case 7:
						if (rightP && spr.animation.curAnim.name != 'confirm')
							spr.animation.play('pressed');
						if (rightR)
							spr.animation.play('static');
					case 8:
						if (leftP && spr.animation.curAnim.name != 'confirm')
							spr.animation.play('pressed');
						if (leftR)
							spr.animation.play('static');
					case 9:
						if (downP && spr.animation.curAnim.name != 'confirm')
							spr.animation.play('pressed');
						if (downR)
							spr.animation.play('static');
					case 10:
						if (upP && spr.animation.curAnim.name != 'confirm')
							spr.animation.play('pressed');
						if (upR)
							spr.animation.play('static');
					case 11:
						if (rightP && spr.animation.curAnim.name != 'confirm')
							spr.animation.play('pressed');
						if (rightR)
							spr.animation.play('static');
					case 12:
						if (leftP && spr.animation.curAnim.name != 'confirm')
							spr.animation.play('pressed');
						if (leftR)
							spr.animation.play('static');
					case 13:
						if (downP && spr.animation.curAnim.name != 'confirm')
							spr.animation.play('pressed');
						if (downR)
							spr.animation.play('static');
					case 14:
						if (upP && spr.animation.curAnim.name != 'confirm')
							spr.animation.play('pressed');
						if (upR)
							spr.animation.play('static');
					case 15:
						if (rightP && spr.animation.curAnim.name != 'confirm')
							spr.animation.play('pressed');
						if (rightR)
							spr.animation.play('static');
				}
	
				if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
				{
					spr.centerOffsets();
					spr.offset.x -= 13;
					spr.offset.y -= 13;
				}
				else
					spr.centerOffsets();
			});
		}
	
		function missNoteCheck(startCount:Int, currentCount:Int):Void
		{
			// Read from the missed note queue and decide what to do
			if (missQueue.missed)
			{
				if (!foundDirection[0] && !foundDirection[1] && !foundDirection[2] && !foundDirection[3])
					noteMiss(missQueue.direction, missQueue.missedNote);
				else if (missQueue.missedNote != null)
				{
					if (startCount == currentCount)
					{
						noteMiss(missQueue.direction, missQueue.missedNote);
					}
				} else
				{
					noteMiss(missQueue.direction, missQueue.missedNote);
				}
			}
		}
	
		function noteMiss(direction:Int = 1, note:Note):Void
		{
			if (note != null)
			{
				if (note.wasGoodHit || successThisFrame[note.noteData])
					return;
			}
	
			if (!boyfriend.stunned)
			{
				health -= 0.04;
				if (combo > 5 && gf.animOffsets.exists('sad'))
				{
					gf.playAnim('sad');
				}
				combo = 0;
				misses += 1;
				songScore -= 10;

				var dammit:String = "";
				if (boyfriend.curCharacter == 'luci-moment')
					dammit = '-luci';
	
				FlxG.sound.play('assetss/sounds/missnote' + FlxG.random.int(1, 3) + dammit + TitleState.soundExt, FlxG.random.float(0.1, 0.2));
				// FlxG.sound.play('assetss/sounds/missnote1' + TitleState.soundExt, 1, false);
				// FlxG.log.add('played imss note');
				// gang
	
				boyfriend.stunned = true;
	
				// get stunned for 5 seconds
				new FlxTimer().start(5 / 60, function(tmr:FlxTimer)
				{
					boyfriend.stunned = false;
				});
	
				switch (direction)
				{
					case 0:
						boyfriend.playAnim('singLEFTmiss', true);
					case 1:
						boyfriend.playAnim('singDOWNmiss', true);
					case 2:
						boyfriend.playAnim('singUPmiss', true);
					case 3:
						boyfriend.playAnim('singRIGHTmiss', true);
					case 4:
						boyfriend.playAnim('singLEFTmiss', true);
					case 5:
						boyfriend.playAnim('singDOWNmiss', true);
					case 6:
						boyfriend.playAnim('singUPmiss', true);
					case 7:
						boyfriend.playAnim('singRIGHTmiss', true);
				}

			}
			else
				FlxG.log.add('STILL STUNNED!');
		}
	
		function badNoteCheck(controlList:Array<Bool>, note:Note)
		{
			// i gotchu fam
			var noMiss:Bool = true;
			var hitNote:Bool = false;
			var dupNote:Bool = false;
			var missDir:Int = 0;
			var noteData:Int = note.noteData % 4;
			for (i in 0...5)
			{
				if (note != null)
				{
					if (!note.wasGoodHit)
					{
						if (controlList[i] && !foundDirection[i] && i != noteData)
						{
							noMiss = false;
							missDir = i;
						} else if (!controlList[i] && i == noteData)
						{
							if (!foundDirection[i])
							{
								noMiss = false;
								missDir = i;
							} else
							{
								dupNote = true;
							}
						}
					}
				} else 
				{
					if (controlList[i])
					{
						noMiss = false;
						missDir = i;
					}
				}
			}
	
			if (noMiss && !dupNote){
				if (note != null)
				{
					goodNoteHit(note, controlList);
				}
				hitNote = true;
			}
			else if (!hitNote && !dupNote)
			{
				if (note != null)
				{
					if (!note.wasGoodHit)
					{
						missQueue.direction = missDir;
						missQueue.missedNote = note;
						missQueue.missed = true;
					}
				} else
				{
					missQueue.direction = missDir;
					missQueue.missedNote = note;
					missQueue.missed = true;
				}
			}
		}
	
		function noteCheck(keyP:Bool, controlList:Array<Bool>, note:Note):Void
		{
			var noteData:Int = note.noteData % 4;
			if (controlList[noteData] || successThisFrame[noteData])
				badNoteCheck(controlList, note);
			else
			{
				badNoteCheck(controlList, note);
			}
		}
	
		function goodNoteHit(note:Note, controlList:Array<Bool>):Void
		{
			if (!note.wasGoodHit || !note.mineNote)
			{
				if (!note.isSustainNote)
				{
					if (!FlxG.save.data.itgPopupScore)
						popUpScore(note.strumTime);
					else
						itgPopupScore(note.strumTime);
					combo += 1;
				}
	
				if (note.noteData >= 8)
					health -= 0.004;
				else
					health += 0.004;
	
				switch (note.noteData)
				{
					case 0:
						boyfriend.playAnim('singLEFT', true);
					case 1:
						boyfriend.playAnim('singDOWN', true);
					case 2:
						boyfriend.playAnim('singUP', true);
					case 3:
						boyfriend.playAnim('singRIGHT', true);
					case 4:
						boyfriend.playAnim('singLEFT', true);
					case 5:
						boyfriend.playAnim('singDOWN', true);
					case 6:
						boyfriend.playAnim('singUP', true);
					case 7:
						boyfriend.playAnim('singRIGHT', true);
					case 8:
						boyfriend.playAnim('singLEFTmiss', true);
					case 9:
						boyfriend.playAnim('singDOWNmiss', true);
					case 10:
						boyfriend.playAnim('singUPmiss', true);
					case 11:
						boyfriend.playAnim('singRIGHTmiss', true);
					case 12:
						boyfriend.playAnim('singLEFTmiss', true);
					case 13:
						boyfriend.playAnim('singDOWNmiss', true);
					case 14:
						boyfriend.playAnim('singUPmiss', true);
					case 15:
						boyfriend.playAnim('singRIGHTmiss', true);
				}

				var strummingNotes:Int = note.noteData % 4;
	
				playerStrums.forEach(function(spr:FlxSprite)
				{
					if (Math.abs(strummingNotes) == spr.ID)
						spr.animation.play('confirm', true);	
				});
	
				note.wasGoodHit = true;
				vocals.volume = 1;
				successThisFrame[note.noteData] = true;
				missQueue.direction = 0;
				missQueue.missedNote = null;
				missQueue.missed = false;
	
				if (!note.isSustainNote)
				{
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}
			}
		}

	function autoNoteHit(note:Note):Void
		{
			if (!note.wasGoodHit)
			{
				if (!note.isSustainNote)
				{
					if (!FlxG.save.data.itgPopupScore)
						popUpScore(note.strumTime);
					else
						itgPopupScore(note.strumTime);
					combo += 1;
				}
	
				if (note.noteData >= 0)
					health += 0.023;
				else
					health += 0.004;

				var strummingNotes:Int = note.noteData % 4;
	
				switch (note.noteData)
				{
					case 0:
						boyfriend.playAnim('singLEFT', true);
					case 1:
						boyfriend.playAnim('singDOWN', true);
					case 2:
						boyfriend.playAnim('singUP', true);
					case 3:
						boyfriend.playAnim('singRIGHT', true);
					case 4:
						boyfriend.playAnim('singLEFT', true);
					case 5:
						boyfriend.playAnim('singDOWN', true);
					case 6:
						boyfriend.playAnim('singUP', true);
					case 7:
						boyfriend.playAnim('singRIGHT', true);
					case 8:
						boyfriend.playAnim('singLEFTmiss', true);
					case 9:
						boyfriend.playAnim('singDOWNmiss', true);
					case 10:
						boyfriend.playAnim('singUPmiss', true);
					case 11:
						boyfriend.playAnim('singRIGHTmiss', true);
					case 12:
						boyfriend.playAnim('singLEFTmiss', true);
					case 13:
						boyfriend.playAnim('singDOWNmiss', true);
					case 14:
						boyfriend.playAnim('singUPmiss', true);
					case 15:
						boyfriend.playAnim('singRIGHTmiss', true);
				}
	
				playerStrums.forEach(function(spr:FlxSprite)
				{
					if (Math.abs(strummingNotes) == spr.ID)
					{
						spr.animation.play('confirm', true);
						if (!curStage.startsWith('school'))
						{
							spr.centerOffsets();
							spr.offset.x -= 13;
							spr.offset.y -= 13;
						}
					}	
				});
	
				note.wasGoodHit = true;
				vocals.volume = 1;
				
				if (!note.isSustainNote)
				{
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}
			}
		}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	function fastCarDrive()
	{
		FlxG.sound.play('assetss/sounds/carPass' + FlxG.random.int(0, 1) + TitleState.soundExt, 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
		});
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			gf.playAnim('hairBlow');
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	/**
	 * pico stage train reset
	 */
	function trainReset():Void
	{
		gf.playAnim('hairFall');
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	/**
	 * ooooooooo spooky
	 */
	function lightningStrikeShit():Void
	{
		FlxG.sound.play('assetss/sounds/thunder_' + FlxG.random.int(1, 2) + TitleState.soundExt);
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriend.playAnim('scared', true);
		gf.playAnim('scared', true);
	}

	/**
	 * Step hit shit
	 */
	override function stepHit()
	{
		super.stepHit();
		if (SONG.needsVoices)
		{
			if (vocals.time > Conductor.songPosition + 20 || vocals.time < Conductor.songPosition - 20)
			{
				resyncVocals();
			}
		}

		if (dad.curCharacter == 'spooky' && curStep % 4 == 2)
		{
			// dad.dance();
		}

		if (curStep == 254 && curSong == 'B-Sides-Bopeebo')
		{
			boyfriend.playAnim('hey', true);
			gf.playAnim('cheer', true);
			if (dad.curCharacter == 'gf')
				dad.playAnim('cheer', true);
		}

		// peeeesh is hijacking my code pls help
		var oldXFirstNote:Int = 0;
		var oldXSecondNote:Int = 0;
		var oldXThirdNote:Int = 0;
		var oldXFourthNote:Int = 0;
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	/**
	 * Beat thingy i guess lmao
	 */
	override function beatHit()
	{
		super.beatHit();

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, FlxSort.DESCENDING);
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			// else
				// Conductor.changeBPM(SONG.bpm);

			if (autoMode)
			{
				// basic indication of autoplay
				playerStrums.forEach(function(spr:FlxSprite)
				{
					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						spr.animation.play('pressed', true);
						spr.centerOffsets();
						new FlxTimer().start(0.1, function(tmr:FlxTimer)
						{
							spr.animation.play('static', true);
							spr.centerOffsets();
						});
					});
				});
			}
		}

		// Dad no longer freezes and interrupts his own notes
		if (!dad.animation.curAnim.name.startsWith("sing"))
		{
			// theres a literal update function for the character to reset their animations ninja are you stupid
			dad.dance();
		}

		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);

		// HARDCODING FOR MILF ZOOMS!
		if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
			// OH GOD WHY
			if (storyDifficulty == 3)
			{
				FlxG.camera.angle = 180;
				camHUD.angle = 180;
			}
		}

		if (curSong.toLowerCase() == 'mc-mental-at-his-best' && curBeat >= 454 && curBeat < 518 && camZooming && FlxG.camera.zoom < 1.35)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
			camHUD.angle = 180;
		}

		if (curSong.toLowerCase() == 'mc-mental-at-his-best' && curBeat >= 519 && curBeat < 679 && camZooming && FlxG.camera.zoom < 1.35)
		{
			FlxG.camera.zoom += 0.025;
			camHUD.zoom += 0.06;
			camHUD.angle = 180;
		}

		if (curSong.toLowerCase() == 'mc-mental-at-his-best' && curBeat >= 680 && curBeat < 712 && camZooming && FlxG.camera.zoom < 1.35)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
			camHUD.angle = 180;
		}

		var deezNuts:Bool = false;

		if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0 && curSong.toLowerCase() != 'mc-mental-at-his-best')
		{
			if (!cameraUpside)
			{
				FlxG.camera.angle = 0;
			}
			if (curSong != 'Lootus')
			{
				camHUD.angle = 0;
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}
		}

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(iconP1.width, 180, 0.7)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(iconP2.width, 180, 0.7)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0)
		{
			gf.dance();
		}

		if (!boyfriend.animation.curAnim.name.startsWith("sing"))
		{
			boyfriend.dance();
		}

		if (curBeat % 8 == 7 && curSong == 'Bopeebo')
		{
			boyfriend.playAnim('hey', true);
			gf.playAnim('cheer', true);

			if (dad.curCharacter == 'gf')
				dad.playAnim('cheer', true);
		}

		if (curBeat % 8 == 7 && curSong == 'Friday-Night')
		{
			boyfriend.playAnim('hey', true);
			gf.playAnim('cheer', true);
			if (dad.curCharacter == 'gf')
				dad.playAnim('cheer', true);
		}

		if (curBeat == 7 && curSong == 'B-Sides-Bopeebo')
		{
			boyfriend.playAnim('hey', true);
			gf.playAnim('cheer', true);
			if (dad.curCharacter == 'gf')
				dad.playAnim('cheer', true);
		}

		switch (curStage)
		{
			case 'school':
				bgGirls.dance();

			case 'mall':
				upperBoppers.animation.play('bop', true);
				bottomBoppers.animation.play('bop', true);
				santa.animation.play('idle', true);

			case 'limo':
				grpLimoDancers.forEach(function(dancer:BackgroundDancer)
				{
					dancer.dance();
				});

				case 'lemonhell':
					grpLemonDancers.forEach(function(dancer:LemonDancer)
					{
						dancer.dance();
					});

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case "philly", 'annie':
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0)
				{
					phillyCityLights.forEach(function(light:FlxSprite)
					{
						light.visible = false;
					});

					curLight = FlxG.random.int(0, phillyCityLights.length - 1);

					phillyCityLights.members[curLight].visible = true;
					// phillyCityLights.members[curLight].alpha = 1;
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
			case "mtc":
				beepbop.animation.play('bop', true);
			
			case "mikuNew":
				simpBoppers.animation.play('bop', true);
		}

		if (isHalloween && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
	}

	var curLight:Int = 0;

	/**
	 * Unused shit
	 */
	function idleShit()
	{
		new FlxTimer().start(4, function(tmr:FlxTimer)
		{
			boyfriend.playAnim('idle');
		});
	}

	function camTurn()
	{
		// put some stuff here
		// REDO!
		camShake = true;
		new FlxTimer().start(0.5, function(tmr:FlxTimer){
			camShake = false;
			camHUD.x = 0;
		});
	}

	function scrollSet(downScroll:Bool = false, duration:Float = 10)
	{
		if (downScroll)
		{
			downScrollTime = true;
			strumLine.y = FlxG.height - 165;
			// move arrows
			strumLineNotes.forEach(function(spr:FlxSprite){
				FlxTween.tween(spr, { y: strumLine.y }, duration, { ease: FlxEase.sineOut });
			});
			// flip notes
			notes.forEachAlive(function(daNote:Note){
				if (daNote.isSustainNote)
					daNote.flipY = true;
				if (daNote.prevNote.isSustainNote)
					daNote.flipY = true;
			});
		}
		else
		{
			downScrollTime = false;
			strumLine.y = 50;
			// move arrows
			strumLineNotes.forEach(function(spr:FlxSprite){
				FlxTween.tween(spr, { y: strumLine.y }, duration, { ease: FlxEase.sineOut });
			});
			// flip notes
			notes.forEachAlive(function(daNote:Note){
				if (daNote.isSustainNote)
					daNote.flipY = false;
				if (daNote.prevNote.isSustainNote)
					daNote.flipY = false;
			});
		}
	}

	// ik this shouldnt be a function but whatevs
	function xScroll(min:Float = 0, max:Float = 0):Float
	{
		var returnedNum:Float;
		returnedNum = FlxG.random.float(min, max) / 2;
		return returnedNum;
	}

	function showRate(winornot:Bool = false)
	{
		var ratingShit:FlxSprite = new FlxSprite();
		add(ratingShit);

		if (winornot == true)
		{
			ratingShit.loadGraphic(Paths.image('uk/goodjob'));
			ratingShit.screenCenter(X);
			ratingShit.scrollFactor.set();
			ratingShit.cameras = [camHUD];
			FlxG.sound.play('assetss/sounds/good.ogg');
			fails = 0;
		}
		else
		{
			if (fails < 5)
			{
				ratingShit.loadGraphic(Paths.image('uk/badjob'));
				ratingShit.screenCenter(X);
				ratingShit.scrollFactor.set();
				ratingShit.cameras = [camHUD];
				FlxG.sound.play('assetss/sounds/wrong.ogg');
				fails++;
			}
			else if (fails > 5)
			{
				ratingShit.loadGraphic(Paths.image('uk/really'));
				ratingShit.screenCenter(X);
				ratingShit.scrollFactor.set();
				ratingShit.cameras = [camHUD];
				FlxG.sound.play('assetss/sounds/wrongbad.ogg');
				fails++;
			}
		}

		flixel.effects.FlxFlicker.flicker(ratingShit, 0.5, 0.15, false, false, function(flick:flixel.effects.FlxFlicker){
			remove(ratingShit);
		});
	}

	function miniKeyShit()
	{
		clickButton.scale.set(1, 1);
		if (clicks < 30)
		{
			//gang shit
			if (FlxG.keys.justPressed.LEFT)
			{
				FlxG.sound.play('assetss/sounds/butonpres.ogg');
				clickButton.scale.add(0.05, 0.05);	
				clicks += 1;
			}
			if (FlxG.keys.justPressed.RIGHT)
			{
				FlxG.sound.play('assetss/sounds/butonpres.ogg');
				clickButton.scale.add(0.05, 0.05);
				clicks += 1;
			}
			if (FlxG.keys.justPressed.UP)
			{
				FlxG.sound.play('assetss/sounds/butonpres.ogg');
				clickButton.scale.add(0.05, 0.05);
				clicks += 1;
			}
			if (FlxG.keys.justPressed.DOWN)
			{
				FlxG.sound.play('assetss/sounds/butonpres.ogg');
				clickButton.scale.add(0.05, 0.05);
				clicks += 1;
			}
		}
		else if (clicks == 30)
		{
			clickButton.scale.set(1, 1);
			clickButton.visible = false;
			won = true;
			clickBG.loadGraphic(Paths.image('uk/clicer/bgWin'));
			clicks += 1;
		}
	}

	public static var a1 =  0.254829592;
    public static var a2 = -0.284496736;
    public static var a3 =  1.421413741;
    public static var a4 = -1.453152027;
    public static var a5 =  1.061405429;
    public static var p  =  0.3275911;

    public static function erf(x:Float):Float
    {
        // Save the sign of x
        var sign = 1;
        if (x < 0)
            sign = -1;
        x = Math.abs(x);
    
        // A&S formula 7.1.26
        var t = 1.0/(1.0 + p*x);
        var y = 1.0 - (((((a5*t + a4)*t) + a3)*t + a2)*t + a1)*t*Math.exp(-x*x);
    
        return sign*y;
    }

	public static function wife3(maxms:Float, ts:Float)
	{
		var max_points = 1.0;
		var miss_weight = -5.5;
		var ridic= 5 * ts;
		var max_boo_weight = 180 * ts;
		var ts_pow = 0.75;
		var zero = 65 * (Math.pow(ts,ts_pow));
		var power = 2.5;
		var dev = 22.7 * (Math.pow(ts,ts_pow));
		
		if (maxms <= ridic) // anything below this (judge scaled) threshold is counted as full pts
			return max_points;
		else if (maxms <= zero) // ma/pa region, exponential
			return max_points * erf((zero - maxms) / dev);
		else if (maxms <= max_boo_weight)// cb region, linear
			return (maxms - zero) * miss_weight / (max_boo_weight - zero);
		else
			return miss_weight;
	}
}
/* I swear to god if you delete this you're a fucking racist
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWNXNWWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMXc..,;clodkOKKXNWWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMW0c.   ........',;cld0WMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMW0l. .';;,,,''...  .dNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWKo' .';:::::::,   cKMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMXd,..',;::::;.   ;0WMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNx;. ..;:::,    .xNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNkl;...,:;.  . .oXMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNO;. .,'  .' .:KMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWx.   .  .,,. ,OWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMK; .'.    ':;. .xNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNo  '::,'. .;:;. .lXMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWO. .:::::'  ':::'. :KMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMXO: .,:::::;. .;:::,. 'OWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWXOO0KNWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWd'. ':::::::.  .,,',.  .lkOOOOOOOOOOOOOOOOOOOOOOO0NWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMN0d:......,:loxOKXNWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWXOk0K0ko.  .;::::::,.            .........................':okKNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNKxc'. ..,,,''........';codk0XNWMMMMMMMMMMMMMMMMMWWNXK0kxolc;'  ...    .,:::::,.  .',,..   .',;;;;;;;;;;;;;;;;;;;;;,'.     .':okKNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMWXOl,....';::::::::::;;,,'........',:ldxOKXNXK0Oxdolc;,'...     ..,,,'.    .',;;'.  .,::::::,..  ..,:::::::::::::::::::.   ....     .':oOKNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMN0d:....',:::::::::::::::::::::::;,,'.............    ....'..   ..;cllllll:;'..  ..   ...........',..  ..,;:::::::::::::::,..  ..'''...     .,cdOXWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMWKkl,....,;::::::::::::::::::::::::::::::::::;;,''....     ....   .,:lllllllllc;,'.  ........      ..,:::,'.  ..,:::::::::::::::;,'..  ..',,..      ..,cdOXWMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMWXOo;....';:::::::::::::::::::::::::::::::::::::;;,,''....       ...   ....',;;;'......';cc:;,... ..',:clllllccc:,...,::::::::::::::::::;,...  ..   ...','.....;cdOXWMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMN0d:....',;::::::::::::::::::::::::::::::;,,'.......    .....'',;;:cccc:;,,'..... ...,;cc:;,......',:clllllllllllllllc:::::::::::::::::::::::::;,...',;::::::::;,'.....;lx0XWMMMMMMMMMMMMMMM
MMMMMMMMMMMK:.    ...''',,,;;;::::::::::::::::::::::;........'',,;::ccllllllllllllllllllllcc::;;;,.......',:clllllllllllllllllllllccc::::::::::::::::::::::::::::::::::::::::::;;,... ..;lx0NMMMMMMMMMMM
MMMMMMMMMMMO. .''.......     .......''',,,;;;::::::cc:::ccllllllllllllllllllllllllllllllllc;,......',,:cllllllllllllllllllllllllccc:::::::::::::::;;;;;;;,,,,''''''...............         .kWMMMMMMMMMM
MMMMMMMMMMMO. ,llllllccc::;;,,''....   ............'',;;::ccclllllllllllllllllllllllc:;,......',:cllllllllllllllllllccccc::::;;;,'''................              ...............'''''',,. .dWMMMMMMMMMM
MMMMMMMMMMMO. ,llllllllllllllllllllc. .ldollc:.  ................'',,;;;:cccclllc;,..   ..',;;;;;;,,,,,''''....................    ................''''',,,,,;;;;;;::::::::::::::::::::::, .dWMMMMMMMMMM
MMMMMMMMMMMO. ,llllllllllllllllllllc. .dOOOOOx, .:llcc:::;,,,''.................         ......................''''',,,,;;;;;;;;;;;;;::::::::::::::::::::::::::::::::::::::::::::::::::::, .dWMMMMMMMMMM
MMMMMMMMMMMO. ,llllllllllllllllllllc' .dOOOOOl. ,llllllllllllllllllccc:;,'...   ...',,,,,;;;;::::cccccclllllllllllllllllllcc:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::, .dWMMMMMMMMMM
MMMMMMMMMMMO. ,llllllllllllllllllllc. .d0OOOx, .:llllllllllllllllllllll;.         .,llllllllllllllllllllllllllllllllllllcc:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::, .dWMMMMMMMMMM
MMMMMMMMMMMO. ,llllllllllllllllllllc. .okOOOl. ,llllllllllllllllllllll:.           .lllllllllllllllllllllllllllllllllllcc::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::, .dWMMMMMMMMMM
MMMMMMMMMMMO. ,lllllllllllllllllllll,. ...',. .:llllllllllllllllllllll;.          .,lllllllllllllllllllllllllllllllllllcc::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::, .dWMMMMMMMMMM
MMMMMMMMMMMO. ,lllllllllllllllllllllc:;,,'....;llllllllllllllllllllllllc:::::. .,:clllllllllllllllllllllllllllllllllllcc:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::, .dWMMMMMMMMMM
MMMMMMMMMMMO. ,llllllllllllllllllllllllllllllllllllllllllllllllllllllllllllll' .:lllllllllllllllllllllllllllllllllllllc::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::, .dWMMMMMMMMMM
MMMMMMMMMMMO. ,llllllllllllllllllllllllllllllllllllllllllllllllllllllllllllll' .:llllllllllllllllllllllllllllllllllllcc::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::, .dWMMMMMMMMMM
MMMMMMMMMMMO. ,lllllllllcclllllllllllllllllllllllllllllllllllllllllllllllllll, .;llllllllllllllllllllllllllllllllllllcc::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::, .dWMMMMMMMMMM
MMMMMMMMMMMO. ,lllllllllcclllllllllllllllllllllllllllllllllllllllllllllllllll,  ;llllllllllllllllllllllllllllllllllllcc::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::, .dWMMMMMMMMMM
MMMMMMMMMMMO. ,lllllllllccllllllllllllllllllllllllcclllllllllllllllllllllllll,  ;llllllllllllllllllllllllllllllllllllcc::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::, .dWMMMMMMMMMM
MMMMMMMMMMMO. ,lllllllllclllllllllllllllllllllllllcclllllllllllllllllllllllll,  ;llllllllllllllllllllllllllllllllllllcc::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::, .dWMMMMMMMMMM
MMMMMMMMMMMO. ,lllllllllclllllllllllllllllllllllllcclllllllllllllllllllllllll,  ;llllllllllllllllllllllllllllllllllllcc::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::, .dWMMMMMMMMMM
MMMMMMMMMMMO. ,lllllllllcllllllllllllllllllllllllllclllllllllllllllllllllllll,  ;lllllllllllllllllllllllllllllllllllllcc:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::, .dWMMMMMMMMMM
MMMMMMMMMMMO. ,llllllllcclllllllllllllllllllllllllcclllllllllllllllllllllllll,  ;llllllllllllllllllllllllllllllllllllllc:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::, .dWMMMMMMMMMM
MMMMMMMMMMWk..,clllllll:;,''';clllllllllllllllllllc:cllllllllllllllllllllllll,  ;llllllllllllllllllllllllllllllllllllllcc::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::, .dWMMMMMMMMMM
MMMMMMMMMMWk'.':::::ccc;'.    .,llllllllllllllllll:;cllllllllllllllllllllllll;  ,llllllllllllllllllllllllllllllllllllllcc::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::, .dWMMMMMMMMMM
MMMMMMMMMMMO. ,llccc:;;,''...  .:llllllllllllllllc;,;;:clllllllllllllllllllll;. ,lllllllllllllllllllllllllllllllllllllllc::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::, .dWMMMMMMMMMM
MMMMMMMMMMMO. ,lllllll:,''.....':llllllllcccccccc;,,.. .'clllllllllllllllllll;  ,lllllllllllllllllllllllllllllllllllllllcc:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::, .dWMMMMMMMMMM
MMMMMMMMMMMO. ,lllllllc;,..  .':llllllllc::::;;;,,,,'.   'cllllllllllllllllll;  ,lllllllllllllllllllllllllllllllllllllllcc:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::, .dWMMMMMMMMMM
MMMMMMMMMMMO. ,llllllll:,;;;:clllllllllllllllllc,.''..   'cllllllllllllllllll;  ,lllllllllllllllllllllllllllllllllllllllllc::::::::::::::::::::::::::::::::::::;,''........',;:::::::::::, .dWMMMMMMMMMM
MMMMMMMMMMMO. ,llllllll:,:llllllllllllllllllllll:''..   .:lllllllccclllllllll;  ,lllllllllllllllllllllllllllllllllllllllllcc:::::::::::::::::::::::::::::::;,..           .......',;:::::, .dWMMMMMMMMMM
MMMMMMMMMMMO. ,llllllllc,:llllllllllllllllllllllll:;,,,:lllc:;'.....'clllllll;  ,llllllllllllllllllllllllllllllllllllllllccc:::::::::::::::::::::::::::::;..    ..';:lodxxkkxxdl:,...';::, .dWMMMMMMMMMM
MMMMMMMMMMMO. ,llllllllc;:lllllllllllllllllllllllllclllll:'.        'clllllll;. ,llllllllllllllllllllllllllllllllllllccccccc:::::::::::::::::::::::::::;'.   'lxO0KKKKKKKKKKKKKKKKOd;..,:, .dWMMMMMMMMMM
MMMMMMMMMMMO. ,lll:;cllc::lllllllllllllllllllllllllclllll:;;;;;;;,..;llllllll:. 'llllllllllllllllllllllllllllllllccc:::::::;;,,''',,,;;:::::::::::::::,.    ;kKKKKKKKKKKKKKKKKKKKKKK0o..,, .dWMMMMMMMMMM
MMMMMMMMMMMO. ,lllc;',;c:cllllllllllllllllllllllllccllllllcc;,;ll:..cllllllll:. 'llllllllllllllllllllllllllllllcc::::::,'..           .';::::::::::::;.    ;kKKKKKKKKKKKKKKKKKKKKKKKK0c .' .dWMMMMMMMMMM
MMMMMMMMMMMO. ,lllll:'...',;:cclllllllllllllllllllc:c:;,'.....:ll;.,lllllllll:. 'lllllllllllllllllllllllllllllcc::::;'.      .,:cclllc,..,:::::::::::.    'xKKKKKKKKKKKKKKKKKKKKKKKKKKx... .dWMMMMMMMMMM
MMMMMMMMMMMO. ,lllllll:,.     ....'',,,,,,,,,''''....     .';lllc''clllllllll:. 'llllllllllllllllllllllllllllcc::::,.      .ckKKKKKK0Ox, .;:::::::::;.    :OkllOKKKKKKKKKKKKKKKKKKKKKKO, . .dWMMMMMMMMMM
MMMMMMMMMMMO. ,llllllllll:,..                         ..';cllllll:cllllllllll:. 'llllllllllllllllllllllllllllcc:::,.       :0KKKKK0OOOko..':::::::::;.   .oOx:.'cdkO0KKKKKKKKKKKKKKKKK0: . .dWMMMMMMMMMM
MMMMMMMMMMMO. ,lllllllllllllc:;'....             ..';:cllllllllllllllllllllll:. 'llllllllllllllllllllllllllllc:::;.       .oKKKKKK0OOOOkl..,:::::::::.   .dOOkxl;',',xOocxKKKKKKKKKKKKKl.  .dWMMMMMMMMMM
MMMMMMMMMMMO. ,lllllllllllllllllllcc::;;;;;;;;;::clllllllllllllllllllllllllll:. 'clllllllllllllllllllllllllllc:::;.       .oKKKKKK00OOOOk; .;::::::::;.  .oOOOOOkkxc....'o0K0d;cxO0OxkOc   .dWMMMMMMMMMM
MMMMMMMMMMMO. ,llllllllllllllllllllllllllllllllllllllllllllllllllllllllllllll:. .clllllllllllllllllllllllllllcc:::'        ;OKKKKKK00OOOOd' .;::::::::,.  ,xOOOOOOko. 'lxkkOkd:'',,''cd:   .dWMMMMMMMMMM
MMMMMMMMMMMO. ,llllllllllllllllllllllllllllllllllllllllllllllllllllllllllllll:. .clllllllllllllllllllllllllllcc::::,.      .oKKKKKKK00OOOkl. ':::::::::;'. ,dkOOOko'.,oO0xk0kkxoollodoo;   .dWMMMMMMMMMM
MMMMMMMMMMMO. ,lllllllllllllllllc:;,,;,,,,,;,,;;cllllllllllllllllllllllllllllc. .clllllllllllllllllllllllllllccc:::::;'.    'kKKKKKKK0OOOOkl..'::::::::::;...;dkkd,.,dkxxkkOkkOkxkxkOkxc.  .dWMMMMMMMMMM
MMMMMMMMMMMO. ,lllllllllllllllll;. ...........  ,llllllllllllllllllllllllllllc. .cllllllllllllllllllllllllllllllcc::::::;,'..:0KKKKKKK0OOOOOo..,:::::::::::;'..':;..lkxxkkkkxkxO0xxxxxxc.  .dWMMMMMMMMMM
MMMMMMMMMMMO. ,lllllllllllllllll, .ckkkkkkkkkc. ,llllllllllllllllllllllllllllc. .clllllllllllllllllllllllllllllllcccc::::::;..c0KKKKKKK0OOOOkc..;::::::::::::;,... 'xkdxOO0OxOOOxxxdxkOc.  .dWMMMMMMMMMM
MMMMMMMMMMMO. ,lllllllllllllllll, .lOOOO0OOOOl. ;llllllllllllllllllllllllllllc. .clllllllllllllllllllllllllllllllcccc:::::::,..cOKKKKKK0OOOOOd' '::::::::::::::::' 'dkOkkOkkkkO0ddxxkkx;   .dWMMMMMMMMMM
MMMMMMMMMMMO. ,lllllllllllllllll, .lOOOOOOOOOc .;llllllllllllllllllllllllllllc. .clllllllllllllllllllllllllllllllccc:::::;,.. .ckKKK000OOOOOOk; .:::::::::::::::;. 'xk0OxkkkOkxdxkkO0Oo' . .dWMMMMMMMMMM
MMMMMMMMMMMO. .;:::cccclllllllll, .lOOO0OO0Ok: .:llllllllllllllllllllllllllllc. .clllllllllllllllllllllllllllllllc:::::;....;oOKKKKKKKK00OOOOk;.'::::::::::::::;;' .lkxOkk0OO0kdodxxdd:.   .xWMMMMMMMMMM
MMMMMMMMMMMKc..............''',,.  :dxxkkOOOk; .:llllllllllllllllllllllllllllc. .clllllllllllllllllllllllllllllcc::::,...;dOKKKKKKKKKKKKKK0OOd. .'''..............  .oO0OOKOOOkkxxkkdc'.:ddkNMMMMMMMMMMM
MMMMMMMMMMMMWXXK0Okkxdollcc:;,''.  .......','.  .,,;;;::cccclllllllllllllllllc. .cllllllllllllllllllllllllllcc::;;,,...lOKKKKKKKKKKKKKKK00OOx;....''',;;:ccclloddxko..:dxk0kkxkkxkxdd,.lNMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMWWWNNKl.;llcccc::;;,''................'',,,;;:::cc:. .:cccc:::;;;;,,,,'''.............   .:kKKKKKKKKKKKKKK000OOkdclOKXXNNNWWWMMMMMMMMMMMWO;.;lk0kOOdddkOx;.:KMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMX:'okOOO0KKKKKK00OOkxxddolcc:'   .''.........   .............''.     .;clloddxxc..ckKKKKKKKKKKKKKKK0OOOOOd:lXMMMMMMMMMMMMMMMMMMMMMMMNx'.:xxxxdoloo:.,0MMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMWKkdooolllllloooddxxl..lkOOOKKKKKKKKKKKKKKKKKKKK0o. .:clooddxxxddoodxxkkOO0KKXXKx:..:lc:cOWMMMMMNd,;xKKKKKKKKKKKKKKKK0OOOOOxcoXMMMMMMMMMMMMMMMMMMMMMMMMM0,  .........  ;KMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMW0:...  ................ ,xOO0KKKKKKKKKKKKKKKKKKKKKOo:,'.....'',;:clx0NMMMMMMMMMXc.. .;ccc:ccccccl;'o0KKKKKKKKKKKKKKKK0OOOOOkclKMMMMMMMMMMMMMMMMMMMMMMMMMXc     .. '.    .OMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMNl  ... .'''...''''.;ooccdkOOO0000KKKKKKKKKKKKKKKK0kdodxkxxo:;:''..  .:0WMMMMMMMk..,;,..........  .dKKKKKKKKKKKKKKKKK0OOOOOkc:0MMMMMMMMMMMMMMMMMMMMMMMMMM0'  .. ...:'    'OMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMWKxolc;.         ..,:lxdodxkkOOOOOOKKKKKKKKKKOxl:,'................    lNMMMMMMM0;.';:::::::;;'. .dKKKKKKKKKKKKKKKKKK0OOOOkc;kWMMMMMMMMMMMMMMMMMMMMMMMMMMO.     ...c;    .OMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMNx;'.  .','........cxdddoddoc;,'ckOxxO0ko;...,:lodddddxxkkxkkkkkkkkOXWMMMMMMMWKo,'........   ;kKKKKKKKKKKKKKKKKKK0OOOOkl,dWMMMMMMMMMMMMMMMMMMMMMMMMMMMk..'.. .....    .dWMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMk.  .. ...    ...,coo:::,..   ..;cdxl;'..;lkKNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWN0xollc:'. .o0KKKKKKKKKKKKKKKKKKK0OOOkc.cKXXXKKKK00000KKKKNWMMMMMMMMWO;.lXX0OOOOOOOOo. .lONMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMNkc;'',,.  .':ol:::,...    .,;ldl;'..,cxKWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWNKOkxdoc:;,'.....;xKKKKKKKKKKKKKKKKKKKKK0OOkc. .'................';dKWMMMMNo':ONMMMMMMMMMMMNOxoc,,l0WMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMWNNWK, .,..'...,:ox:  ..;c;'..':d0NMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWOl'......'';cloodoodk0KKKKKKKKKKKKKKKKKKK00OOko;,,:,.''','..',,'....  ;KMMMMO..dXWMMMMMMMMMMMMMMMWXx;':dOXNNWMMMMM
MMMMMMMMMMMMMMMMMMMMMMNd....,cdOKNWMX; ... ..;oOXWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMO.    .'.',.,:::::;,;:codk0KKKKKKKKKKKK0OOOOOOOkdoddc'.          ...',;oXMMMMO. .'lKWMMMMMMMMMMMMMMMNOc'.,;:;;xWMMM
MMMMMMMMMMMMMMMMMMMMMMMWX00XWMMMMMMMNo. .,lkXWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMKo::::::::::::::;;;;,,'...';lk0KKOkO0klcldkkkdodxkd;'''........  .,cxXWWMMMMMNl ...,OWMMMMMMMMMMMMMMWNKKKK0x:.,KMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMN0OKWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWWWWNNX0dc,..'coodxd;.  ..,;:loloo;..     .',. ..  .oNMMMMMMMO..,'.,KMMMMMMMMMMMMMMMMMMM0l;;,.,o0W
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNKxc'..,:coo:'.    ...,coo::c;..   .. ...,kWMMMMMMMWx... .xWMMMMMMMMMMXOxxddddl:col.  .c
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMN0d:...,:coc.   .:;'...,::,,' .o0kkk0NWMMMMMMMMMWKd:'.,:cloxO0XNWXc.............',. 
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWXOo;....... .OWX0xl;'.... 'OMMMMMMMMMMMMMMMMMMMWNKOxdolc:;;:c:. ...,;::::::::,..
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWKxc,.   'OMMMMMWN0kolo0WMMMMMMMMMMMMMMMMMMMMMMMMMMMMWNXKOxol:,......'''...,x
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMN0dllkNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWX0kdolcccldONW
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
*/