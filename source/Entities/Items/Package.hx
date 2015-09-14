package;

import flixel.util.FlxRandom;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
using flixel.util.FlxSpriteUtil;

class Package extends Collectible
{
	public var code : String;

	public function new(X : Float, Y : Float, World : PlayState, Code : String)
	{
		super(X, Y, World);
		
		code = Code;
		
		makeGraphic(20, 20, 0x00FFFFFF);
		
		drawRoundRect(0, 4, 16, 16, 7, 7, 0xFFD4BC90);
		drawRect(14, 2, 17, 4, 0xFFD2BA8D);
		
		FlxTween.tween(this, {x: x+2}, 0.3, { ease: FlxEase.elasticInOut, type: FlxTween.LOOPING, loopDelay: FlxRandom.floatRanged(0.2, 0.7) });
	}
	
	override public function onCollected() : Void
	{
		if (alive)
		{
			if (world.player.carriedPackages < world.player.MaxCarriedPackages)
			{
				/*var carried : CarriedPackage = new CarriedPackage(x, y, world, code);
				world.entities.add(carried);
				
				alive = false;*/
				
				GameStatusManager.addCapture(code);
				
				kill();
			}
		}
	}
}