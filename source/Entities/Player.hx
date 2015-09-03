package;

import flixel.util.FlxPoint;

class Player extends Entity
{
	public var WalkHSpeed : Float = 80;
	public var WalkHAcceleration : Float = 800;
	public var WalkVSpeed : Float = 65;
	public var WalkVAcceleration : Float = 450;

	public function new(X : Int, Y : Int, World : PlayState)
	{
		super(X, Y, World);
		
		makeGraphic(14, 24, 0xFF459932);
		setSize(14, 14);
		offset.set(1, 10);
		
		maxVelocity.set(WalkHSpeed, WalkVSpeed);
		drag.set(WalkHAcceleration * 1.5, WalkVAcceleration * 1.5);
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
	
	public function teleportTo(pos : FlxPoint) : Void
	{
		x = pos.x - width / 2;
		y = pos.y - height / 2;
	}
	
	public function onCollisionWithEnemy(enemy : Enemy)
	{
	}
}