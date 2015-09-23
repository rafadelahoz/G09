package;

import flixel.FlxG;
import flixel.FlxObject;

enum BulletType { Pistol; Blaster; Melon; Net; }

class PlayerBullet extends Entity
{
	public var type : BulletType;
	public var power : Int;
	
	public function new(X : Float, Y : Float, World : PlayState, Type : BulletType)
	{
		super(X, Y, World);
		
		type = Type;
		
		switch (type)
		{
			case Pistol:
				makeGraphic(10, 6, 0xFFEDEDED);
				power = 1;
			case Blaster:
				makeGraphic(10, 8, 0xFFFFDDDD);
				power = 1;
			case Melon:
				makeGraphic(12, 12, 0xFF90D49A);
				power = 2;
			case Net:
				makeGraphic(14, 14, 0xFFD4BC90);
				power = 1;
		}
	}
	
	public function init(X : Float, Y : Float, HSpeed : Float, VSpeed : Float)
	{
		x = X;
		y = Y;
		
		centerOrigin();
		
		velocity.set(HSpeed, VSpeed);

		baseline = world.player.baseline;
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
	
	public function onCollisionWithDecoration(decoration : Decoration)
	{
		kill();
	}
	
	public function onCollisionWithEnemy(enemy : Enemy)
	{
		kill();
	}
}

