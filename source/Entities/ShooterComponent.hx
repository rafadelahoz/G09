package;

import flixel.util.FlxPoint;
import flixel.group.FlxTypedGroup;

class ShooterComponent
{
	public static var PistolBulletSpeed : Float = 300;
	public static var BlasterBulletSpeed : Float = 320;
	
	public static var PistolDelay : Float = 0.2;
	public static var BlasterDelay : Float = 0.05;

	var type : PlayerBullet.BulletType;

	var world	: PlayState;
	var bullets : FlxTypedGroup<PlayerBullet>;

	public var bulletSpeed : Float = 100;
	
	public function new()
	{
		// ohai
	}
	
	public function init(World : PlayState, MaxBullets : Int = 5, BulletType : PlayerBullet.BulletType = null)
	{
		world = World;
		
		type = BulletType;
	
		bullets = new FlxTypedGroup<PlayerBullet>(MaxBullets);

		for (i in 0...MaxBullets)
		{
			var bullet : PlayerBullet = new PlayerBullet(-1, -1, World, type);
			bullet.kill();
			bullets.add(bullet);
		}
		
		world.playerBullets.add(bullets);
	}
	
	public function shoot(from : FlxPoint, target : FlxPoint)
	{
		var bullet : PlayerBullet = bullets.recycle(PlayerBullet);
		var shotSpeed : FlxPoint = CalculateShootVelocity(from, target, bulletSpeed, type);
		bullet.init(Std.int(from.x), Std.int(from.y), shotSpeed.x, shotSpeed.y);
	}
	
	public function getDelay() : Float
	{
		switch (type)
		{
			case PlayerBullet.BulletType.Pistol:
				return PistolDelay;
			case PlayerBullet.BulletType.Blaster:
				return BlasterDelay;
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