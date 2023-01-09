package options;

import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;

class GameplayMenu extends MusicBeatState {
	var menuItems:Array<String> = ['DownScroll', 'Ghost Tapping', 'darkmode'];
	var grpMenuShit:FlxTypedGroup<Alphabet>;
	var curSelected:Int = 0;

	override public function create() {
		FlxG.sound.music.loadEmbedded(Paths.music('breakfast'), true);

		var bg = new FlxSprite(0, 0, Paths.image('menuDesat'));
		bg.color = 0x182714;
		bg.screenCenter();
		add(bg);

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		for (i in 0...menuItems.length) {
			var songText:Alphabet = new Alphabet(0, (70 * i) + 4, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		changeSelection();
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP) {
			changeSelection(-1);
		}
		if (downP) {
			changeSelection(1);
		}

		if (FlxG.keys.justPressed.ESCAPE)
			FlxG.switchState(new OptionsMenu());

		if (accepted) {
			var daSelected:String = menuItems[curSelected];

			switch (daSelected) {
				case "Ghost Tapping":
					if (!OptionVars.ghosttapping)
						OptionVars.ghosttapping = true;
					else
						OptionVars.ghosttapping = false;

				case "DownScroll":
					if (!OptionVars.downscroll)
						OptionVars.downscroll = true;
					else
						OptionVars.downscroll = false;

				case "darkmode":
					if (!OptionVars.darkmode)
						OptionVars.darkmode = true;
					else
						OptionVars.darkmode = false;
				default:
					trace('you got a null option');
			}
			OptionsMenu.savesettings();
		}
	}

	function changeSelection(change:Int = 0):Void {
		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0) {
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}
