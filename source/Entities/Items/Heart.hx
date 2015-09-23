package;

using flixel.FlxSprite;
using flixel.util.FlxSpriteUtil;

class Heart extends Collectible
{
	public var value : Int = 1;
	
	public function new(X : Float, Y : Float, World : PlayState, ?Value : Int = 1)
	{
		super(X, Y, World);
		
		value = Value;

		makeGraphic(10, 10, 0xFFFF6666);
		
		shadow = new FlxSprite(x, baseline);
		shadow.loadGraphic("assets/images/shadow-small.png");
		shadow.solid = false;

		// animation.play("idle");
	}

	override public function onCollected() : Void
	{
		GameStatusManager.setPlayerHP(GameStatusManager.getPlayerHP() + value);
		
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