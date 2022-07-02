package;

import flixel.util.FlxTimer;
import lime.net.URIParser;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;

using StringTools;

class PlayGameMenuState extends MusicBeatState
{
//	public static var psychEngineVersion:String = '0.5.2h'; //This is also used for Discord RPC
//	public static var monoEngineVersion:String = '0.0.1'; //This is also used for Discord RPC
//	public static var curSelected:Int = 1;

	//var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;

//	var storyMode:FlxSprite;
	var freeplay:FlxSprite;
	var extra:FlxSprite;
	var joke:FlxSprite;
//	var credits:FlxSprite;
//	var donate:FlxSprite;
//	var options:FlxSprite;
	
	var optionStuff:Array<String> = [
		'freeplay',
		'extra',
		'joke'
	];

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;
	var introTimer:FlxTimer;

	override function create()
	{
		WeekData.loadTheFirstEnabledMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionStuff.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite(-400, -50).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.set(1, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		magenta = new FlxSprite(-400, -50).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.set(1, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		magenta.color = 0xFFfd719b;
		add(magenta);
		
		// magenta.scrollFactor.set();

		var scale:Float = 1;
		/*if(optionStuff.length > 6) {
			scale = 6 / optionStuff.length;
		}*/

		freeplay = new FlxSprite(10, -280);
		freeplay.frames = Paths.getSparrowAtlas("mainmenu/menu_freeplay");
		freeplay.animation.addByPrefix("idle", "freeplay basic", 24, true);
		freeplay.animation.addByPrefix("selected", "freeplay white", 24, true);
		freeplay.animation.play("idle");
		freeplay.scrollFactor.set(0, 1);
		freeplay.antialiasing = ClientPrefs.globalAntialiasing;
		add(freeplay);

		extra = new FlxSprite(10, -140);
		extra.frames = Paths.getSparrowAtlas("mainmenu/menu_extra");
		extra.animation.addByPrefix("idle", "mods basic", 24, true);
		extra.animation.addByPrefix("selected", "mods white", 24, true);
		extra.animation.play("idle");
		extra.scrollFactor.set(0, 1);
		extra.antialiasing = ClientPrefs.globalAntialiasing;
		add(extra);

		joke = new FlxSprite(10, 0);
		joke.frames = Paths.getSparrowAtlas("mainmenu/menu_joke");
		joke.animation.addByPrefix("idle", "awards basic", 24, true);
		joke.animation.addByPrefix("selected", "awards white", 24, true);
		joke.animation.play("idle");
		joke.scrollFactor.set(0, 1);
		joke.antialiasing = ClientPrefs.globalAntialiasing;
		add(joke);

		introTimer = new FlxTimer();
		introTimer.start(0.5);

		/*for (i in 0...optionStuff.length)
		{
			var offset:Float = 108 - (Math.max(optionStuff.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(0, (i * 140)  + offset);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionStuff[i]);
			menuItem.animation.addByPrefix('idle', optionStuff[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionStuff[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItems.add(menuItem);
			var scr:Float = (optionStuff.length - 4) * 0.135;
			if(optionStuff.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();
		}*/

		FlxG.camera.follow(camFollowPos, null, 1);

		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Monochrome Engine v" + monoEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Built on Manny Engine v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) {
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}
		#end

		super.create();
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement() {
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

	function switchState(_)
	{
		switch (curSelected)
		{
			case 1:
				MusicBeatState.switchState(new FreeplayState());

			case 2:
				MusicBeatState.switchState(new ExtraplayState());
					
			case 3:
				MusicBeatState.switchState(new JokeplayState());
				
		}
	}

	function secondTween(_)
	{
		switch (curSelected)
		{
			case 1:
				FlxTween.tween(freeplay.scale, {x: freeplay.scale.x + 2, y: freeplay.scale.y + 2}, 0.33, {ease: FlxEase.circIn, onComplete: switchState});
				FlxTween.tween(FlxG.camera, {zoom: 2}, 0.33, {ease: FlxEase.circIn});
					
			case 2:
				FlxTween.tween(extra.scale, {x: extra.scale.x + 2, y: extra.scale.y + 2}, 0.33, {ease: FlxEase.circIn, onComplete: switchState});
				FlxTween.tween(FlxG.camera, {zoom: 2}, 0.33, {ease: FlxEase.circIn});
				
			case 3:
				FlxTween.tween(joke.scale, {x: joke.scale.x + 2, y: joke.scale.y + 2}, 0.33, {ease: FlxEase.circIn, onComplete: switchState});
				FlxTween.tween(FlxG.camera, {zoom: 2}, 0.33, {ease: FlxEase.circIn});
				
		}
	}

	function introTween()
	{
//		FlxTween.tween(storyMode, {alpha: 1, x: 10}, 0.8, {ease: FlxEase.circOut});
		FlxTween.tween(freeplay, {alpha: 1, x: 10}, 0.8, {ease: FlxEase.circOut});
		FlxTween.tween(extra, {alpha: 1, x: 10}, 0.8, {ease: FlxEase.circOut});
		FlxTween.tween(joke, {alpha: 1, x: 10}, 0.8, {ease: FlxEase.circOut});
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					if(ClientPrefs.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					switch (curSelected)
					{
						case 1:
							FlxTween.tween(freeplay, {x: freeplay.x + 300}, 0.5, {ease: FlxEase.circOut, onComplete: secondTween});
							FlxTween.tween(extra, {alpha: 0, y: joke.y + 10}, 0.33, {ease: FlxEase.circOut});
							FlxTween.tween(joke, {alpha: 0, y: joke.y + 10}, 0.33, {ease: FlxEase.circOut});
							camFollow.setPosition(400, 65);

						case 2:
							FlxTween.tween(freeplay, {alpha: 0, y: freeplay.y - 10}, 0.33, {ease: FlxEase.circOut});
							FlxTween.tween(extra, {x: extra.x + 440}, 0.5, {ease: FlxEase.circOut, onComplete: secondTween});
							FlxTween.tween(awards, {alpha: 0, y: joke.y + 10}, 0.33, {ease: FlxEase.circOut});
							camFollow.setPosition(400, 130);

						case 3:
							FlxTween.tween(freeplay, {alpha: 0, y: freeplay.y - 10}, 0.33, {ease: FlxEase.circOut});
							FlxTween.tween(extra, {alpha: 0, y: freeplay.y - 10}, 0.33, {ease: FlxEase.circOut});
							FlxTween.tween(joke, {x: joke.x + 350}, 0.5, {ease: FlxEase.circOut, onComplete: secondTween});
							camFollow.setPosition(400, 195);


					/*menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionStuff[curSelected];

								switch (daChoice)
								{
									case 'story_mode':
										MusicBeatState.switchState(new StoryMenuState());
									case 'freeplay':
										MusicBeatState.switchState(new FreeplayState());
									#if MODS_ALLOWED
									case 'mods':
										MusicBeatState.switchState(new ModsMenuState());
									#end
									case 'awards':
										MusicBeatState.switchState(new AchievementsMenuState());
									case 'credits':
										MusicBeatState.switchState(new CreditsState());
									case 'options':
										LoadingState.loadAndSwitchState(new options.OptionsState());
								}
							});
						}
					});*/
				}
			}
			#if desktop
//			else if (FlxG.keys.anyJustPressed(debugKeys))
//			{
//				selectedSomethin = true;
//				MusicBeatState.switchState(new MasterEditorMenu());
//			}
			#end

			if (curSelected == 4)
			{
				curSelected = 1;
				freeplay.animation.play('selected');
				camFollow.setPosition(freeplay.getGraphicMidpoint().x - 90, 1); //don't ask me why this specific one has to be the x - 90. i don't know.
			}
			else if (curSelected == 0)
			{
				curSelected = 3;
				joke.animation.play('selected');
				camFollow.setPosition(freeplay.getGraphicMidpoint().x, 390);
			}
		}

		super.update(elapsed);
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		/*if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;*/

		freeplay.animation.play('idle');
		extra.animation.play('idle');
		joke.animation.play('idle');

		switch (curSelected)
		{
			case 1:
				freeplay.animation.play('selected');
				camFollow.setPosition(freeplay.getGraphicMidpoint().x, 65);
				
			case 2:
				extra.animation.play('selected');
				camFollow.setPosition(freeplay.getGraphicMidpoint().x, 130);
					
			case 3:
				joke.animation.play('selected');
				camFollow.setPosition(freeplay.getGraphicMidpoint().x, 195);

		}
	}
}
