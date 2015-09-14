package;

import flixel.util.FlxVelocity;
using flixel.util.FlxSpriteUtil;

class CarriedPackage extends Entity
{
	public var MaxSpeed : Float = 200;
	public var Acceleration : Float = 900;
	
	public var code : String;
	
	var carriedIndex : Int;
	
	public function new(X : Float, Y : Float, World : PlayState, Code : String)
	{
		super(X, Y, World);
		
		code = Code;
		
		makeGraphic(20, 20, 0x00FFFFFF);
		
		drawRoundRect(0, 4, 16, 16, 7, 7, 0xFFD4BC90);
		drawRect(14, 2, 17, 4, 0xFFD2BA8D);
		
		solid = false;
		
		carriedIndex = world.player.carriedPackages;
		world.player.carriedPackages++;
	}
	
	override public function update()
	{
		/*var tpos = world.player.pastPositions[(world.player.pastPositions.length - 1) - 10 - carriedIndex * 2];
		
		x = tpos.x - width/2;
		y = tpos.y - height - (carriedIndex * height/2);
		
		super.update();
		
		baseline = world.player.baseline - 1;*/
		
		super.update();
	}
}