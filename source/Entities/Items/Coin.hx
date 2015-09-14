package;

using flixel.util.FlxSpriteUtil;

class Coin extends Collectible
{
	public var value : Int = 1;
	
	public function new(X : Float, Y : Float, World : PlayState, ?Value : Int = 1)
	{
		super(X, Y, World);
		
		value = Value;
		
		if (value > 5)
			makeGraphic(14, 14, 0xFFffee11);
		else
			makeGraphic(10, 10, 0xFFffdd00);
	}
	
	override public function onCollected() : Void
	{
		GameStatusManager.addCoins(value);
		
		super.onCollected();
	}
}