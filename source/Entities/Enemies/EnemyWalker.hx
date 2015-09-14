package;

import flixel.FlxObject;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import flixel.util.FlxVelocity;

using flixel.util.FlxSpriteUtil;

class EnemyWalker extends Enemy
{
	public var HurtTime : Float = 0.34;
	
	public var Acceleration : Float = 750;
	public var MaxHSpeed : Float = 70;
	public var MaxVSpeed : Float = 57;

	public var display : FlxText;
	
	public var flickering : Bool;
	public var direction : Int;
	
	public function new(X : Float, Y : Float, World : PlayState)
	{
		super(X, Y, World);
	
		// makeGraphic(16, 20, 0xFF208805);
		loadGraphic("assets/images/walker-sheet.png", true, 32, 32);
		animation.add("walk", [0, 1], 8);
		animation.add("hurt", [2]);
		animation.play("walk");

		setSize(16, 24);
		offset.set(8, 7);
		
		display = new FlxText(x, y, "");
		display.color = 0xFF000000;
	}
	
	override public function init(variation : Int)
	{
		super.init(variation);
		
		hp = 2;
		flickering = false;
		
		direction = chooseDirection();

		maxVelocity.set(MaxHSpeed, MaxVSpeed);
		
		brain = new StateMachine(null, onStateChange);
		brain.transition(moveState, "move");
	}
	
	override public function update()
	{	
		/*display.x = x;
		display.y = y - 8;
		display.text = "HP: " + hp;*/
		
		super.update();

		shadow.x = getMidpoint().x - shadow.width / 2;
		shadow.y = y + height - shadow.height / 2;
		shadow.update();
		
		display.update();
	}
	
	public function onStateChange(newState : String) : Void
	{
		switch (newState)
		{
			case "move":
			case "hit":
				flickering = true;
				flicker(HurtTime);
				
				timer.start(HurtTime, function(_t:FlxTimer) {
					flickering = false;
				
					if (!dead && !stunned)
					{
						direction = chooseDirection();
						brain.transition(moveState, "move");
					}
					else if (!dead && stunned)
					{
						brain.transition(stunState, "stun");
					}
				});
		}
	}
	
	static function isHorizontalDirection(direction : Int) : Bool
	{
		return (direction == FlxObject.LEFT || direction == FlxObject.RIGHT);
	}
	
	function chooseDirection() : Int
	{
		// Check whether we are closer vertically or horizontally
		// Horizontal distance is biased because of perspective
		if (Math.abs(player.getMidpoint().y - getMidpoint().y) > 
			Math.abs(player.getMidpoint().x - getMidpoint().x) * 0.7)
		{
			return chooseHorizontalDirection();
		}
		else
		{
			return chooseVerticalDirection();
		}
	}
	
	function chooseHorizontalDirection() : Int
	{
		if (player.getMidpoint().x < getMidpoint().x)
			return FlxObject.LEFT;
		else
			return FlxObject.RIGHT;
	}
	
	function chooseVerticalDirection() : Int
	{
		if (player.getMidpoint().y < getMidpoint().y)
			return FlxObject.UP;
		else
			return FlxObject.DOWN;
	}
	
	public function moveState()
	{
		immovable = false;
		
		if (justTouched(direction))
		{
			// Turn!
			if (isHorizontalDirection(direction))
				direction = chooseVerticalDirection();
			else
				direction = chooseHorizontalDirection();
		}
		else
		{
			// velocity.set();
			acceleration.set();
			
			switch (direction)
			{
				case FlxObject.LEFT:
					facing = FlxObject.LEFT;
					acceleration.x = -Acceleration;
				case FlxObject.RIGHT:
					facing = FlxObject.RIGHT;
					acceleration.x = Acceleration;
				case FlxObject.UP:
					acceleration.y = -Acceleration;
				case FlxObject.DOWN:
					acceleration.y = Acceleration;
			}
		}

		animation.play("walk");
		if (facing == FlxObject.LEFT)
			flipX = true;
		else
			flipX = false;
	}
	
	public function hitState()
	{
		immovable = true;
		drag.set(1000, 1000);

		animation.play("hurt");
	}
	
	public function stunState()
	{
		color = 0xFF772424;
		
		immovable = true;
		drag.set(1000, 1000);

		animation.play("hurt");
	}
	
	override public function onStun()
	{
		super.onStun();
		brain.transition(stunState, "stun");
	}
	
	override public function onBulletHit(bullet : PlayerBullet)
	{
		if (!dead/* && !flickering*/)
		{
			hit();
			
			brain.transition(hitState, "hit");
				
			acceleration.set();
			velocity.set();
			if (bullet.getMidpoint().x > getMidpoint().x)
				velocity.x = -400;
			else
				velocity.x = 400;
		}
	}	
	
	override public function onCollisionWithPlayer(player : Player)
	{
		// delegating...
	}
	
	override public function draw()
	{
		shadow.draw();
		super.draw();
		// display.draw();
	}
}