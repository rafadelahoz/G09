package;

import flixel.util.FlxPoint;
import flixel.util.FlxAngle;
import flixel.group.FlxTypedGroup;

class ShooterComponent
{
	public static var BulletSpeed : Float = 300;
	
	var type : EnemyBullet.EBulletType;

	var world	: PlayState;
	
	public var bulletSpeed : Float = 100;
	
	public function new()
	{
		// ohai
	}
	
	public function init(World : PlayState, EBulletType : EnemyBullet.EBulletType = null)
	{
		world = World;
		
		type = EBulletType;
	}
	
	public function shoot(from : FlxPoint, target : FlxPoint) : Bool
	{
		world.add(new DebugPoint(from.x, from.y));
		world.add(new DebugPoint(target.x, target.y));
	
		var bullet : EnemyBullet = world.enemyBullets.recycle(EnemyBullet, [from.x, from.y, world]);
		// var bullet : EnemyBullet = world.enemyBullets.getFirstDead();
		if (bullet != null)
		{
			bullet.revive();
			var shotSpeed : FlxPoint = CalculateShootVelocity(from, target, bulletSpeed, type);
			bullet.init(from.x, from.y, shotSpeed.x, shotSpeed.y);
			
			return true;
		}
		else
		{
			// Not available!
			trace("No more enemy bullets available!");
			
			return false;
		}
	}
	
	public static function CalculateShootVelocity(from : FlxPoint, target : FlxPoint, Speed : Float, type : EnemyBullet.EBulletType) : FlxPoint
	{
		switch (type)
		{
			case EnemyBullet.EBulletType.Straight:
				return calculateStraightShootVelocity(from, target, Speed);
			case EnemyBullet.EBulletType.Aimed:
				return calculateAimedShootVelocity(from, target, Speed);
		}
	}
	
	static function calculateAimedShootVelocity(from : FlxPoint, target : FlxPoint, Speed : Float) : FlxPoint
	{
		var angle : Float = FlxAngle.getAngle(from, target) - 90;
		angle *= FlxAngle.TO_RAD;
		
		var velocity : FlxPoint = new FlxPoint();
		velocity.x = Math.cos(angle) * Speed;
		velocity.y = Math.sin(angle) * Speed;
		
		return velocity;
	}
	
	static function calculateStraightShootVelocity(from : FlxPoint, target : FlxPoint, speed : Float) : FlxPoint
	{
		if (target.x < from.x)
			return new FlxPoint(-speed, 0);
		else /*if (target.x > from.x)*/
			return new FlxPoint(speed, 0);
	}
}