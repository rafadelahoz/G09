package;

import flixel.FlxSprite;
import flixel.util.FlxTimer;
import flixel.util.FlxPoint;

class DebugPoint extends FlxSprite
{
	public function new(X : Float, Y : Float)
	{
		super(X, Y);
		makeGraphic(2, 2, 0xFFFF00FF);
		new FlxTimer(0.01, function(timer:FlxTimer){kill();});
	}
}