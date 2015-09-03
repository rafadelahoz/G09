package;

class Player extends Entity
{
	public var WalkHSpeed : Float = 100;
	public var WalkHAcceleration : Float = 900;
	public var WalkVSpeed : Float = 70;
	public var WalkVAcceleration : Float = 500;

	public function new(X : Int, Y : Int, World : PlayState)
	{
		super(X, Y, World);
		
		makeGraphic(14, 24, 0xFF459932);
		setSize(14, 14);
		offset.set(1, 10);
		
		maxVelocity.set(WalkHSpeed, WalkVSpeed);
		drag.set(900, 500);
	}
	
	override public function update()
	{
		if (frozen)
			return;
	
		if (GamePad.checkButton(GamePad.Left))
			acceleration.x = -WalkHAcceleration;
		else if (GamePad.checkButton(GamePad.Right))
			acceleration.x = WalkHAcceleration;
		else
			acceleration.x = 0;
		
		if (GamePad.checkButton(GamePad.Up))
			acceleration.y = -WalkVAcceleration;
		else if (GamePad.checkButton(GamePad.Down))
			acceleration.y = WalkVAcceleration;
		else
			acceleration.y = 0;
			
		if (acceleration.x != 0)
			acceleration.y = 0;
			
		super.update();
	}
	
	public function onCollisionWithEnemy(enemy : Enemy)
	{
	}
}