package;

import flixel.FlxObject;

enum BulletType { Pistol; Blaster; }

class PlayerBullet extends Entity
{
	var type : BulletType;
	
	public function new(X : Float, Y : Float, World : PlayState, Type : BulletType)
	{
		super(X, Y, World);
		
		makeGraphic(10, 6, 0xFFE1E1E1);
		
		type = Type;
	}
	
	public function init(X : Int, Y : Int, HSpeed : Float, VSpeed : Float)
	{
		x = X;
		y = Y;
		
		centerOrigin();
		
		velocity.set(HSpeed, VSpeed);
	}
	
	override public function update()
	{
		if (!inWorldBounds() || justTouched(FlxObject.ANY))
		{
			kill();
		}
		
		super.update();
	}
	
	public function onCollisionWithEnemy(enemy : Enemy)
	{
		kill();
	}
}

