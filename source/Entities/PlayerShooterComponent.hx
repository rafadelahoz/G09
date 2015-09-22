package;

import flixel.util.FlxPoint;
import flixel.group.FlxTypedGroup;

class PlayerShooterComponent
{
	public static var PistolBulletSpeed : Float = 300;
	public static var BlasterBulletSpeed : Float = 320;
	public static var MelonBulletSpeed : Float = 200;
	public static var NetBulletSpeed : Float = 220;
	
	public static var PistolMaxBullets : Int = 3;
	public static var BlasterMaxBullets : Int = 6;
	public static var MelonMaxBullets : Int = 2;
	public static var NetMaxBullets : Int = 1;
	
	public static var PistolDelay : Float = 0.2;
	public static var BlasterDelay : Float = 0.05;
	public static var MelonDelay : Float = 0.75;
	public static var NetDelay : Float = 0.55;
	
	var type : PlayerBullet.BulletType;

	var world	: PlayState;
	var bullets : FlxTypedGroup<PlayerBullet>;

	public var bulletSpeed : Float = 100;
	
	public function new()
	{
		// ohai
		bullets = null;
	}
	
	public function init(World : PlayState, BulletType : PlayerBullet.BulletType = null)
	{
		world = World;
		
		type = BulletType;
		
		var MaxBullets : Int = getMaxBullets(type);
		
		if (bullets != null)
		{
			world.playerBullets.remove(bullets);
			bullets.destroy();
		}
	
		bullets = new FlxTypedGroup<PlayerBullet>(MaxBullets);

		for (i in 0...MaxBullets)
		{
			var bullet : PlayerBullet = new PlayerBullet(-1, -1, World, type);
			bullet.kill();
			bullets.add(bullet);
		}
		
		world.playerBullets.add(bullets);
	}
	
	function getMaxBullets(type : PlayerBullet.BulletType) : Int
	{
		switch (type)
		{
			case PlayerBullet.BulletType.Pistol:
				return PistolMaxBullets;
			case PlayerBullet.BulletType.Blaster:
				return BlasterMaxBullets;
			case PlayerBullet.BulletType.Melon:
				return MelonMaxBullets;
			case PlayerBullet.BulletType.Net:
				return NetMaxBullets;
		}
	}
	
	public function shoot(from : FlxPoint, target : FlxPoint) : Bool
	{
		// var bullet : PlayerBullet = bullets.recycle(PlayerBullet);
		var bullet : PlayerBullet = bullets.getFirstDead();
		if (bullet != null)
		{
			bullet.revive();
			var shotSpeed : FlxPoint = CalculateShootVelocity(from, target, bulletSpeed, type);
			bullet.init(Std.int(from.x), Std.int(from.y), shotSpeed.x, shotSpeed.y);
			
			return true;
		}
		else
		{
			// Not available!
			trace("Click!");
			
			return false;
		}
	}
	
	public function getDelay() : Float
	{
		switch (type)
		{
			case PlayerBullet.BulletType.Pistol:
				return PistolDelay;
			case PlayerBullet.BulletType.Blaster:
				return BlasterDelay;
			case PlayerBullet.BulletType.Melon:
				return MelonDelay;
			case PlayerBullet.BulletType.Net:
				return NetDelay;
		}
	}
	
	public function destroy()
	{
		world.playerBullets.remove(bullets);
		bullets.destroy();
		bullets = null;
	}
	
	public static function CalculateShootVelocity(from : FlxPoint, target : FlxPoint, speed : Float, type : PlayerBullet.BulletType) : FlxPoint
	{
		switch (type)
		{
			case PlayerBullet.BulletType.Pistol:
				return calculateStraightShootVelocity(from, target, PistolBulletSpeed);
			case PlayerBullet.BulletType.Blaster:
				return calculateStraightShootVelocity(from, target, BlasterBulletSpeed);
			case PlayerBullet.BulletType.Melon:
				return calculateStraightShootVelocity(from, target, MelonBulletSpeed);
			case PlayerBullet.BulletType.Net:
				return calculateStraightShootVelocity(from, target, NetBulletSpeed);
			default:
				return new FlxPoint(0, 0);
		}
	}
	
	static function calculateStraightShootVelocity(from : FlxPoint, target : FlxPoint, speed : Float) : FlxPoint
	{
		if (target.x < from.x)
			return new FlxPoint(-speed, 0);
		else /*if (target.x > from.x)*/
			return new FlxPoint(speed, 0);
	}
}