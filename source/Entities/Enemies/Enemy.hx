package;

import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import openfl.display.BlendMode;
import flixel.util.FlxRandom;

class Enemy extends Entity
{
	var DeathDelay : Float = 5.0;
	
	var code : String;
	
	var hp : Int;
	var spawnsItem : Bool;
	
	var brain : StateMachine;
	var timer : FlxTimer;
	var deathTimer : FlxTimer;
	
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
		spawnsItem = true;
		
		code = "ENEMYBASE";
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
	
	public function capture(?Pow : Int = 1)
	{
		if (stunned)
		{
			var pkg : Package = new Package(getMidpoint().x - 8, y + height - 16, world, code);
			world.collectibles.add(pkg);
			kill();
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
		setupDeathTimer();
	}
	
	public function setupDeathTimer() : Void
	{
		if (!dead)
		{
			deathTimer = new FlxTimer(DeathDelay, function(_t:FlxTimer) {
				die();
			});
		}
	}
	
	public function onDeath()
	{
		// Override me!
		alive = false;
		blend = BlendMode.MULTIPLY;
		tween = FlxTween.tween(scale, { x:0, y:1.5 }, 0.175);
		velocity.y = -150;
		
		spawnItem();
	}
	
	public function spawnItem()
	{
		if (!spawnsItem)
			return;
		
		// Choose item to spawn
		var items : Array<String> = ["none", "coin", "purse", "heart"];
		var weights : Array<Float> = [70, 20, 10, 40 - GameStatusManager.getPlayerHP()*10];
		var selected : Int = FlxRandom.weightedPick(weights);
		// Instantiate it
		switch (items[selected])
		{
			case "none":
			case "coin":
				var coin : Coin = new Coin(getMidpoint().x, getMidpoint().y, world);
				world.collectibles.add(coin);
			case "purse":
				var coin : Coin = new Coin(getMidpoint().x, getMidpoint().y, world, 10);
				world.collectibles.add(coin);
			case "heart":
				var heart : Heart = new Heart(getMidpoint().x, getMidpoint().y, world);
				world.collectibles.add(heart);
		}
	}
	
	public function onCollisionWithPlayerBullet(bullet : PlayerBullet)
	{
		if (bullet.type == PlayerBullet.BulletType.Net)
			onNetHit(bullet);
		else
			onBulletHit(bullet);
	}
	
	public function onNetHit(net : PlayerBullet)
	{
		// Override this!
		capture(net.power);
	}
	
	public function onBulletHit(bullet : PlayerBullet)
	{
		// Override this!
		hit(bullet.power);
	}
	
	public function onCollisionWithPlayer(player : Player)
	{
		// delegating...
	}
}