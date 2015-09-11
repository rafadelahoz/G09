package;

using flixel.util.FlxSpriteUtil;

class Coin extends Collectible
{
	public var value : Int = 1;
	
	public function new(X : Float, Y : Float, World : PlayState, ?Value : Int = 1)
	{
		super(X, Y, World);
		
		value = Value;
		
		makeGraphic(10, 10, 0xFFffdd00);
	}
	
	override public function onCollected() : Void
	{
		GameStatusManager.Status.coins += value;
		
		super.onCollected();
	}
}