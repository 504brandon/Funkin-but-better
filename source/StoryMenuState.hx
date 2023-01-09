package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;

using StringTools;

typedef WeekStruct = {
	var songs:Array<Array<String>>;
	var sprites:Array<String>;
	var chars:Array<Array<String>>;
	var names:Array<String>;
	var diffs:Array<Array<String>>;
}

class StoryMenuState extends MusicBeatState
{
	var scoreText:FlxText;

	var weekData:WeekStruct = {songs: [], sprites: [], chars: [], names: [], diffs: []};
	var curDifficulty:Int = 1;

	//public static var weekUnlocked:Array<Bool> = [true, true, true, true, true, true, true];

	var txtWeekTitle:FlxText;

	var curWeek:Int = 0;

	var txtTracklist:FlxText;

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekData:FlxTypedGroup<MenuCharacter>;

	//var grpLocks:FlxTypedGroup<FlxSprite>;

	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	override function create()
	{
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		weekData = {songs: [], sprites: [], chars: [], names: [], diffs: []};
		for (line in CoolUtil.coolTextFile(Paths.txt("weekList"))) {
			var daVars:Array<String> = [for (thing in line.split("||")) thing.trim()];
			weekData.songs.push([for (song in daVars[3].split(",")) song.trim()]);
			weekData.sprites.push(daVars[1]);
			weekData.chars.push([for (char in daVars[2].split(",")) char.trim()]);
			weekData.names.push(daVars[0]);
			weekData.diffs.push([for (diff in daVars[4].split(",")) diff.toLowerCase().trim()]);
		}

		if (FlxG.sound.music != null)
		{
			if (!FlxG.sound.music.playing)
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		persistentUpdate = persistentDraw = true;

		scoreText = new FlxText(10, 10, 0, "SCORE: 49324858", 36);
		scoreText.setFormat("VCR OSD Mono", 32);

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;

		var rankText:FlxText = new FlxText(0, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font("vcr.ttf"), 32);
		rankText.size = scoreText.size;
		rankText.screenCenter(X);

		var ui_tex = Paths.getSparrowAtlas('storymenu/campaign_menu_UI_assets');
		var yellowBG:FlxSprite = new FlxSprite(0, 56).makeGraphic(FlxG.width, 400, 0xFFF9CF51);

		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		add(blackBarThingie);

		grpWeekData = new FlxTypedGroup<MenuCharacter>();

		//grpLocks = new FlxTypedGroup<FlxSprite>();
		//add(grpLocks);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		for (i in 0...weekData.songs.length)
		{
			var weekThing:MenuItem = new MenuItem(0, yellowBG.y + yellowBG.height + 10, weekData.sprites[i]);
			weekThing.y += ((weekThing.height + 20) * i);
			weekThing.targetY = i;
			grpWeekText.add(weekThing);

			weekThing.screenCenter(X);
			weekThing.antialiasing = true;
			// weekThing.updateHitbox();

			// Needs an offset thingie
			/*
			if (!weekUnlocked[i])
			{
				var lock:FlxSprite = new FlxSprite(weekThing.width + 10 + weekThing.x);
				lock.frames = ui_tex;
				lock.animation.addByPrefix('lock', 'lock');
				lock.animation.play('lock');
				lock.ID = i;
				lock.antialiasing = true;
				grpLocks.add(lock);
			}*/
		}

		for (char in 0...3)
		{
			var weekCharacterThing:MenuCharacter = new MenuCharacter((FlxG.width * 0.25) * (1 + char) - 150, weekData.chars[curWeek][char]);
			weekCharacterThing.y += 70;
			weekCharacterThing.antialiasing = true;
			grpWeekData.add(weekCharacterThing);
		}

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		leftArrow = new FlxSprite(grpWeekText.members[0].x + grpWeekText.members[0].width + 10, grpWeekText.members[0].y + 10);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		difficultySelectors.add(leftArrow);

		sprDifficulty = new FlxSprite(leftArrow.x + 130, leftArrow.y);
		difficultySelectors.add(sprDifficulty);

		rightArrow = new FlxSprite(sprDifficulty.x + sprDifficulty.width + 50, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		difficultySelectors.add(rightArrow);

		add(yellowBG);
		add(grpWeekData);

		txtTracklist = new FlxText(FlxG.width * 0.05, yellowBG.x + yellowBG.height + 100, 0, "Tracks", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.font = rankText.font;
		txtTracklist.color = 0xFFe55777;
		add(txtTracklist);
		// add(rankText);
		add(scoreText);
		add(txtWeekTitle);

		updateText();

		super.create();
	}

	override function update(elapsed:Float)
	{
		// scoreText.setFormat('VCR OSD Mono', 32);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.5));

		scoreText.text = "WEEK SCORE:" + lerpScore;

		txtWeekTitle.text = weekData.names[curWeek].toUpperCase();
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		// FlxG.watch.addQuick('font', scoreText.font);

		//difficultySelectors.visible = weekUnlocked[curWeek];

		/*grpLocks.forEach(function(lock:FlxSprite)
		{
			lock.y = grpWeekText.members[lock.ID].y;
		});*/

		if (!movedBack)
		{
			if (!selectedWeek)
			{
				if (controls.UP_P)
				{
					changeWeek(-1);
				}

				if (controls.DOWN_P)
				{
					changeWeek(1);
				}

				if (controls.RIGHT)
					rightArrow.animation.play('press')
				else
					rightArrow.animation.play('idle');

				if (controls.LEFT)
					leftArrow.animation.play('press');
				else
					leftArrow.animation.play('idle');

				if (controls.RIGHT_P)
					changeDifficulty(1);
				if (controls.LEFT_P)
					changeDifficulty(-1);
			}

			if (controls.ACCEPT)
			{
				selectWeek();
			}
		}

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			FlxG.switchState(new MainMenuState());
		}

		super.update(elapsed);
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek() {
		//if (weekUnlocked[curWeek]) {
			if (stopspamming == false)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));

				grpWeekText.members[curWeek].startFlashing();
				for (char in grpWeekData.members) {
					if (char.animation.exists("confirm"))
						char.animation.play('confirm');
				}
				stopspamming = true;
			}

			PlayState.storyPlaylist = weekData.songs[curWeek];
			PlayState.isStoryMode = true;
			selectedWeek = true;
			CoolUtil.diffArray = weekData.diffs[curWeek];
			PlayState.storyDifficulty = curDifficulty;
			PlayState.SONG = Song.loadFromJson(Highscore.formatSong(PlayState.storyPlaylist[0], curDifficulty), PlayState.storyPlaylist[0].toLowerCase());
			PlayState.storyWeek = curWeek;
			PlayState.campaignScore = 0;
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				LoadingState.loadAndSwitchState(new PlayState(), true);
			});
		//}
	}

	function changeDifficulty(change:Int = 0):Void {
		curDifficulty = (curDifficulty + weekData.diffs[curWeek].length + change) % weekData.diffs[curWeek].length;

		sprDifficulty.loadGraphic(Paths.image('storymenu/difficulties/${weekData.diffs[curWeek][curDifficulty]}'));
		sprDifficulty.updateHitbox();
		sprDifficulty.alpha = 0;
		leftArrow.x = grpWeekText.members[curWeek].x + grpWeekText.members[curWeek].width + 10;
		sprDifficulty.x = leftArrow.x + leftArrow.width + 10;
		rightArrow.x = sprDifficulty.x + sprDifficulty.width + 10;

		// USING THESE WEIRD VALUES SO THAT IT DOESNT FLOAT UP
		var daY =  leftArrow.y + leftArrow.height / 2 - sprDifficulty.height / 2;
		sprDifficulty.y = daY - 15;
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		FlxTween.tween(sprDifficulty, {y: daY, alpha: 1}, 0.07);
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		curWeek = (curWeek + weekData.names.length + change) % weekData.names.length;

		var bullShit:Int = 0;

		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			if (item.targetY == Std.int(0) /*&& weekUnlocked[curWeek]*/)
				item.alpha = 1;
			else
				item.alpha = 0.6;
			bullShit++;
		}

		FlxG.sound.play(Paths.sound('scrollMenu'));


		updateText();
	}

	function updateText()
	{
		changeDifficulty();

		grpWeekData.members[0].changeChar(weekData.chars[curWeek][0]);
		grpWeekData.members[1].changeChar(weekData.chars[curWeek][1]);
		grpWeekData.members[2].changeChar(weekData.chars[curWeek][2]);
		txtTracklist.text = "Tracks\n";

		var stringThing:Array<String> = weekData.songs[curWeek];

		for (i in stringThing)
		{
			txtTracklist.text += "\n" + i;
		}

		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;

		#if !switch
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		#end
	}
}
