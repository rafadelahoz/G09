package;

import flixel.FlxObject;
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
		
		loadGraphic("assets/images/player-sheet.png", true, 32, 32);
		animation.add("idle", [0]);
		animation.add("walk", [1, 0], 5, true);
		animation.add("walk-vertical", [1, 0], 4, true);

		animation.play("idle");

		setSize(14, 12);
		offset.set(9, 19);
		
		maxVelocity.set(WalkHSpeed, WalkVSpeed);
		drag.set(WalkHAcceleration * 1.5, WalkVAcceleration * 1.5);
	}
	
	override public function update()
	{
		if (frozen)
			return;
	
		if (GamePad.checkButton(GamePad.Left))
		{
			acceleration.x = -WalkHAcceleration;
			facing = FlxObject.LEFT;
		}
		else if (GamePad.checkButton(GamePad.Right))
		{
			acceleration.x = WalkHAcceleration;
			facing = FlxObject.RIGHT;
		}
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

		if (acceleration.x != 0)
			animation.play("walk");
		else if (acceleration.y != 0)
			animation.play("walk-vertical");
		else
			animation.play("idle");

		flipX = (facing == FlxObject.LEFT);
			
		super.update();

		shadow.x = getMidpoint().x - shadow.width / 2;
		shadow.y = y + height - shadow.height / 2;
		shadow.update();
	}

	override public function draw() : Void
	{
		shadow.draw();
		super.draw();
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