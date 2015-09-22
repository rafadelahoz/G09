package;

import flixel.FlxG;
import flixel.FlxObject;

enum EBulletType { Straight; Aimed; }

class EnemyBullet extends Entity
{
	public var type : EBulletType;
	public var power : Int;
	
	public function new(X : Float, Y : Float, World : PlayState, Type : EBulletType)
	{
		super(X, Y, World);
		
		type = Type;

		makeGraphic(8, 8, 0xFFFFD324);
	}
	
	public function init(X : Float, Y : Float, HSpeed : Float, VSpeed : Float)
	{
		x = X;
		y = Y;
		
		centerOrigin();
		
		velocity.set(HSpeed, VSpeed);

		baseline = y + height * 2;
	}
	
	override public function update()
	{
		if (frozen)
			return;
	
		if (!inWorldBounds() || justTouched(FlxObject.ANY))
		{
			kill();
		}
		
		super.update();
	}
	
	public function onCollisionWithPlayer(player : Player)
	{
		kill();
	}
	
	public function onCollisionWithDecoration(decoration : Decoration)
	{
		kill();
	}
	
	public function onCollisionWithEnemy(enemy : Enemy)
	{
		// ...
	}
}

