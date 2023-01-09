package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

class MenuCharacter extends FlxSprite
{
	public var character:String = "hubba-dubba-bubble-tape";

	public function new(x:Float, character:String = 'bf')
	{
		super(x);
		changeChar(character);
	}

	public function changeChar(char:String = "bf") {
		if (char == character) return;
		character = char;
		if (character == "<NONE>") {
			visible = false;
			return;
		}
		visible = true;
		frames = Paths.getSparrowAtlas('storymenu/characters/$character');
		animation.addByPrefix('idle', "idle", 24);
		animation.addByPrefix("confirm", 'confirm', 24, false);

		animation.play("idle");
		var data:Array<String> = CoolUtil.coolTextFile('assets/images/storymenu/characters/$character-data.txt');
		offset.set(100 + Std.parseFloat(data[0].trim()), 100 + Std.parseFloat(data[1].trim()));
		setGraphicSize(Std.int(frameWidth * Std.parseFloat(data[2].trim())));
		flipX = (data[3].trim() == "true");
	}
}
