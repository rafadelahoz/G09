package;

import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import openfl.display.BlendMode;

class Enemy extends Entity
{
	var hp : Int;
	var brain : StateMachine;
	var timer : FlxTimer;
	var stunned : Bool;
	var dead : Bool;
	var tween : FlxTween;
	
	public var player (get, null) : Player;
	inline function get_player() { return world.player; }

	public function new(X : Float, Y : Float, World : PlayState)
	{
		super(X, Y, World);
		
		timer = new FlxTimer();
	}
	
	public function init(variation : Int)
	{
		hp = 1;
		stunned = false;
	}
	
	override public function update()
	{
		if (dead)
		{
			if (scale.x <= 0) 
				kill();
		}
	
		if (brain != null)
			brain.update();
			
		super.update();
		
		baseline = y + height;
	}
	
	public function hit(?Pow : Int = 1)
	{
		// You are hit!
		hp -= Pow;
	
		// Stun if not stunned
		if (!stunned)
		{
			if (hp <= 0)
			{
				hp = 0;
				stunned = true;
				onStun();
			}
		}
		// Die if stunned
		else if (!dead)
		{
			if (hp <= -1)
				die();
		}
	}
	
	public function die()
	{
		if (!dead)
		{
			dead = true;
			onDeath();
		}
	}
	
	public function onStun()
	{
		// Override me!
	}
	
	public function onDeath()
	{
		// Override me!
		alive = false;
		blend = BlendMode.MULTIPLY;
		tween = FlxTween.tween(scale, { x:0, y:1.5 }, 0.175);
		velocity.y = -150;
	}
	
	public function onCollisionWithPlayerBullet(bullet : PlayerBullet)
	{
		hit();
	}
	
	public function onCollisionWithPlayer(player : Player)
	{
		// delegating...
	}
}