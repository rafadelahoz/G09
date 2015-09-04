package;

import flixel.util.FlxTimer;

class Enemy extends Entity
{
	var brain : StateMachine;
	var timer : FlxTimer;

	public function new(X : Float, Y : Float, World : PlayState)
	{
		super(X, Y, World);
		
		timer = new FlxTimer();
	}
	
	public function init(variation : Int)
	{
	}
	
	override public function update()
	{
		if (brain != null)
			brain.update();
			
		super.update();
	}
	
	public function onCollisionWithPlayerBullet(bullet : PlayerBullet)
	{
		// delegating...
	}
	
	public function onCollisionWithPlayer(player : Player)
	{
		// delegating...
	}
}