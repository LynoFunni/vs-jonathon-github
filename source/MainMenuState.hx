package;

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
import flixel.util.FlxTimer;
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

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.5.1'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	var menubgsgroup:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		//#if MODS_ALLOWED 'mods', #end
		//#if ACHIEVEMENTS_ALLOWED 'awards', #end
		'credits',
		//#if !switch 'donate', #end
		'options'
	];

	var optionbgShit:Array<String> = [
		'story_modebg',
		'freeplaybg',
		//#if MODS_ALLOWED 'mods', #end
		//#if ACHIEVEMENTS_ALLOWED 'awards', #end
		'creditsbg',
		//#if !switch 'donate', #end
		'optionsbg'
	];

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;
	private var storymodebg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('modebgs/mode_storymode'));
	private var optionsbg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('modebgs/mode_credits'));
	private var creditsbg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('modebgs/mode_options'));
	private var freeplaybg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('modebgs/mode_freeplay'));


	override function create()
	{
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


		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		storymodebg.scrollFactor.set(0);
	    storymodebg.setGraphicSize(Std.int(storymodebg.width * 1.175));
	    storymodebg.updateHitbox();
	    storymodebg.visible = false;
	    storymodebg.screenCenter();
	    storymodebg.antialiasing = ClientPrefs.globalAntialiasing;
	    add(storymodebg);

		optionsbg.scrollFactor.set(0);
	    optionsbg.setGraphicSize(Std.int(optionsbg.width * 1.175));
		optionsbg.updateHitbox();
		optionsbg.visible = false;
		optionsbg.screenCenter();
		optionsbg.antialiasing = ClientPrefs.globalAntialiasing;
	    add(optionsbg);

		creditsbg.scrollFactor.set(0);
		creditsbg.setGraphicSize(Std.int(creditsbg.width * 1.175));
		creditsbg.updateHitbox();
		creditsbg.visible = false;
		creditsbg.screenCenter();
		creditsbg.antialiasing = ClientPrefs.globalAntialiasing;
	    add(creditsbg);

		freeplaybg.scrollFactor.set(0);
		freeplaybg.setGraphicSize(Std.int(freeplaybg.width * 1.175));
		freeplaybg.updateHitbox();
		freeplaybg.visible = false;
		freeplaybg.screenCenter();
		freeplaybg.antialiasing = ClientPrefs.globalAntialiasing;
	    add(freeplaybg);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		magenta.color = 0xFFfd719b;
		add(magenta);
		
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		menubgsgroup = new FlxTypedGroup<FlxSprite>();
		add(menubgsgroup);


		var scale:Float = 0.8;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/
            
	
		    //FreePlay Mode
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(-220,-100);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[1]);
			menuItem.animation.addByPrefix('idle', optionShit[1] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[1] + " white", 24);
			menuItem.animation.addByPrefix('pressright', optionShit[1] + " right press", 24);
			menuItem.animation.addByPrefix('pressleft', optionShit[1] + " left press", 24);		
			menuItem.visible = false;
			menuItem.ID = 1;
			//menuItem.x = 100;
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();

			//Story Mode
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(-220,-100);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[0]);
			menuItem.animation.addByPrefix('idle', optionShit[0] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[0] + " white", 24);
			menuItem.animation.addByPrefix('pressright', optionShit[0] + " right press", 24);
			menuItem.animation.addByPrefix('pressleft', optionShit[0] + " left press", 24);		
			menuItem.ID = 0;
			//menuItem.x = 100;
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 1;
			menuItem.scrollFactor.set(1, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();

			//Credits
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(-220,-100);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[2]);
			menuItem.animation.addByPrefix('idle', optionShit[2] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[2] + " white", 24);
			menuItem.animation.addByPrefix('pressright', optionShit[2] + " right press", 24);
			menuItem.animation.addByPrefix('pressleft', optionShit[2] + " left press", 24);
			menuItem.visible = false;
			menuItem.ID = 2;
			//menuItem.x = 100;
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 2;
			menuItem.scrollFactor.set(2, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();

			//Options
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(-220,-100);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[3]);
			menuItem.animation.addByPrefix('idle', optionShit[3] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[3] + " white", 24);
			menuItem.animation.addByPrefix('pressright', optionShit[3] + " right press", 24);
			menuItem.animation.addByPrefix('pressleft', optionShit[3] + " left press", 24);
			menuItem.visible = false;
			menuItem.ID = 3;
			//menuItem.x = 100;
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 3;
			menuItem.scrollFactor.set(3, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();
		

		//FlxG.camera.follow(camFollowPos, null, 1);


		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
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

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{

        if (optionShit[curSelected] == 'story_mode')
			{
				storymodebg.visible = true;

				changeItem(-1);
				changeItem(1);

				optionsbg.visible = false;

				creditsbg.visible = false;

				freeplaybg.visible = false;

				menuItems.forEach(function(spr:FlxSprite)
					{
						
						if (spr.ID == 0)
						{   
							if (controls.UI_RIGHT_P)
								{
								  spr.animation.play('pressright');	
								  new FlxTimer().start(0.4, function(tmr:FlxTimer)
									{
										spr.visible = false;
									});
								}
						}

						if (spr.ID == 1)
							{   
								if (controls.UI_RIGHT_P)
									{
									  new FlxTimer().start(0.4, function(tmr:FlxTimer)
										{   
											spr.animation.play('idle');	
											spr.visible = true;
										});
									}
							}

							if (spr.ID == 0)
								{   
									if (controls.UI_LEFT_P)
										{
										  spr.animation.play('pressleft');	
										  new FlxTimer().start(0.4, function(tmr:FlxTimer)
											{
												spr.visible = false;
											});
										}
								}
		
								if (spr.ID == 3)
									{   
										if (controls.UI_LEFT_P)
											{
											  new FlxTimer().start(0.4, function(tmr:FlxTimer)
												{   
													spr.animation.play('idle');	
													spr.visible = true;
												});
											}
									}
		

							
					});

                
				
			}

		if (optionShit[curSelected] == 'freeplay')
				{
					storymodebg.visible = false;
	
					changeItem(-1);
					changeItem(1);

					optionsbg.visible = false;

					creditsbg.visible = false;

					freeplaybg.visible = true;
					menuItems.forEach(function(spr:FlxSprite)
						{
							if (spr.ID == 1)
							{   
								if (controls.UI_RIGHT_P)
									{
									  spr.animation.play('pressright');	
									  new FlxTimer().start(0.4, function(tmr:FlxTimer)
										{
											spr.visible = false;
										});
									}
							}
	
							if (spr.ID == 2)
								{   
									if (controls.UI_RIGHT_P)
										{
										  new FlxTimer().start(0.4, function(tmr:FlxTimer)
											{   
												spr.animation.play('idle');	
												spr.visible = true;
											});
										}
								}

								if (spr.ID == 1)
									{   
										if (controls.UI_LEFT_P)
											{
											  spr.animation.play('pressleft');	
											  new FlxTimer().start(0.4, function(tmr:FlxTimer)
												{
													spr.visible = false;
												});
											}
									}
			
									if (spr.ID == 0)
										{   
											if (controls.UI_LEFT_P)
												{
												  new FlxTimer().start(0.4, function(tmr:FlxTimer)
													{   
														spr.animation.play('idle');	
														spr.visible = true;
													});
												}
										}

					
						});
	
	
				}

				if (optionShit[curSelected] == 'credits')
					{
						freeplaybg.visible = false;

						storymodebg.visible = false;
		
						changeItem(-1);
						changeItem(1);

						optionsbg.visible = false;

						creditsbg.visible = true;
						menuItems.forEach(function(spr:FlxSprite)
							{
								if (spr.ID == 2)
								{   
									if (controls.UI_RIGHT_P)
										{
										  spr.animation.play('pressright');	
										  new FlxTimer().start(0.4, function(tmr:FlxTimer)
											{
												spr.visible = false;
											});
										}
								}
		
								if (spr.ID == 3)
									{   
										if (controls.UI_RIGHT_P)
											{
											  new FlxTimer().start(0.4, function(tmr:FlxTimer)
												{
													spr.animation.play('idle');	
													spr.visible = true;
												});
											}
									}

									if (spr.ID == 2)
										{   
											if (controls.UI_LEFT_P)
												{
												  spr.animation.play('pressleft');	
												  new FlxTimer().start(0.4, function(tmr:FlxTimer)
													{
														spr.visible = false;
													});
												}
										}
				
										if (spr.ID == 1)
											{   
												if (controls.UI_LEFT_P)
													{
													  new FlxTimer().start(0.4, function(tmr:FlxTimer)
														{   
															spr.animation.play('idle');	
															spr.visible = true;
														});
													}
											}

							
							});
		
					}
			
				if (optionShit[curSelected] == 'options')
						{
							storymodebg.visible = false;

							optionsbg.visible = true;
			                  
							changeItem(-1);
							changeItem(1);

							creditsbg.visible = false;

							freeplaybg.visible = false;

							menuItems.forEach(function(spr:FlxSprite)
								{
									if (spr.ID == 3)
									{   
										if (controls.UI_RIGHT_P)
											{
											  spr.animation.play('pressright');	
											  new FlxTimer().start(0.4, function(tmr:FlxTimer)
												{
													spr.visible = false;
												});
											}
									}
			
									if (spr.ID == 0)
										{   
											if (controls.UI_RIGHT_P)
												{
												  new FlxTimer().start(0.4, function(tmr:FlxTimer)
													{   
														spr.animation.play('idle');	
														spr.visible = true;
													});
												}
										}

										if (spr.ID == 3)
											{   
												if (controls.UI_LEFT_P)
													{
													  spr.animation.play('pressleft');	
													  new FlxTimer().start(0.4, function(tmr:FlxTimer)
														{
															spr.visible = false;
														});
													}
											}
					
											if (spr.ID == 2)
												{   
													if (controls.UI_LEFT_P)
														{
														  new FlxTimer().start(0.4, function(tmr:FlxTimer)
															{   
																spr.animation.play('idle');	
																spr.visible = true;
															});
														}
												}
								});
			
						}

		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			if (controls.UI_LEFT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_RIGHT_P)
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
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					if(ClientPrefs.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
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
								var daChoice:String = optionShit[curSelected];

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
					});
				}
			}
			#if desktop
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			//spr.screenCenter(X);
		});
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{   
				spr.animation.play('selected');
				var add:Float = 0;
				if(menuItems.length > 4) {
					add = menuItems.length * 8;
				}
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - add);
				spr.centerOffsets();
			}
		});
	}
}
