package;

using flixel.FlxSprite;
using flixel.util.FlxSpriteUtil;

class Coin extends Collectible
{
	public var value : Int = 1;
	
	public function new(X : Float, Y : Float, World : PlayState, ?Value : Int = 1)
	{
		super(X, Y, World);
		
		value = Value;
		
		loadGraphic("assets/images/coin-sheet.png", true, 8, 8);
		animation.add("idle", [0, 1, 2, 3, 4, 0, 4], 5);
		animation.play("idle");

		shadow = new FlxSprite(x, baseline).loadGraphic("assets/images/shadow-small.png");
		shadow.solid = false;
	}

	override public function onCollected() : Void
	{
		GameStatusManager.Status.coins += value;
		
		super.onCollected();
	}

	override public function update() : Void
	{
		super.update();
		
		shadow.x = getMidpoint().x - shadow.width / 2;
		shadow.y = y + height - shadow.height / 2;
		shadow.update();
	}

	override public function draw()
	{
		if (alive)
			shadow.draw();
		super.draw();
	}
}