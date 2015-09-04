package;

import flixel.FlxSprite;

class Entity extends FlxSprite
{
	var world : PlayState;
	
	public var frozen : Bool;
	public var collideWithLevel : Bool;
	public var collideWithEnemies : Bool;
	
	public var baseline : Float;
	public var shadow : FlxSprite;

	public function new(X : Float, Y : Float, World : PlayState)
	{
		super(X, Y);
		world = World;
		frozen = false;
		collideWithLevel = true;
		collideWithEnemies = true;
		
		baseline = y + height;

		shadow = new FlxSprite(x, baseline).loadGraphic("assets/images/shadow.png");
		shadow.solid = false;
		
		world.entities.add(this);
	}

	public function setMovementMask() : Void
	{
		// Switch to the appropriate movement mask here
		// It will be used for traversing the map, so it
		// should represent the entity's feet.
	}
	
	public function setCollisionMask() : Void
	{
		// Switch to the appropriate collision mask here
		// It will be used for collisions vs bullets, enemies
		// or powerups, so it should be body-sized
	}
	
	public function freeze() : Void
	{
		frozen = true;
	}

	public function resume() : Void
	{
		frozen = false;
	}

	public function isFrozen() : Bool
	{
		return frozen;
	}

	override public function destroy() : Void
	{
		world.entities.remove(this);
	}
}