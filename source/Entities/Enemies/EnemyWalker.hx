package;

import flixel.util.FlxTimer;
import flixel.util.FlxVelocity;

using flixel.util.FlxSpriteUtil;

class EnemyWalker extends Enemy
{
	public var HurtTime : Float = 0.5;
	
	public var Acceleration : Float = 700;
	public var MaxHSpeed : Float = 70;
	public var MaxVSpeed : Float = 57;

	public function new(X : Float, Y : Float, World : PlayState)
	{
		super(X, Y, World);
	
		makeGraphic(16, 20, 0xFF200588);
	}
	
	override public function init(variation : Int)
	{
		brain = new StateMachine(null, onStateChange);
		
		brain.transition(move, "move");
	}
	
	override public function update()
	{
		shadow.x = getMidpoint().x - shadow.width / 2;
		shadow.y = y + height - shadow.height / 2;
		shadow.update();
		
		super.update();
	}
	
	public function onStateChange(newState : String) : Void
	{
		switch (newState)
		{
			case "move":
			case "hit":
				flicker(HurtTime);
				timer.start(HurtTime, function(_t:FlxTimer) {
					brain.transition(move, "move");
				});
		}
	}
	
	public function move()
	{
		FlxVelocity.accelerateTowardsObject(this, world.player, Acceleration, MaxHSpeed, MaxVSpeed);
	}
	
	public function hit()
	{
		velocity.set();
		acceleration.set();
	}
	
	override public function draw()
	{
		shadow.draw();
		super.draw();
	}
	
	override public function onCollisionWithPlayerBullet(bullet : PlayerBullet)
	{
		if (bullet.getMidpoint().x > getMidpoint().x)
			velocity.x = -400;
		else
			velocity.x = 400;
			
		brain.transition(hit, "hit");
	}
	
	override public function onCollisionWithPlayer(player : Player)
	{
		// delegating...
	}
}