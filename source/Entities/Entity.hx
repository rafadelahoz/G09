package;

import flixel.FlxSprite;
using flixel.util.FlxSpriteUtil;

class Entity extends FlxSprite
{
	var world : PlayState;
	
	public var frozen : Bool;
	public var collideWithLevel : Bool;
	public var collideWithEnemies : Bool;
	
	public var baseline : Float;
	public var shadow : FlxSprite;
	
	public var dbgBaseline : FlxSprite;

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
		
		dbgBaseline = new FlxSprite(x - 8, y);
		dbgBaseline.makeGraphic(16, 1);
		dbgBaseline.drawLine(0, 0, dbgBaseline.width, dbgBaseline.height);
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
	
	override public function update()
	{
		super.update();
		
		dbgBaseline.x = Std.int(getMidpoint().x - dbgBaseline.width/2);
		dbgBaseline.y = baseline;
	}
	
	override public function draw()
	{
		super.draw();
		// dbgBaseline.draw();
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