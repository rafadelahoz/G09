package;

class EnemyFollower extends Enemy
{
	public var HurtTime : Float = 0.34;
	
	public var Acceleration : Float = 700;
	public var MaxHSpeed : Float = 75;
	public var MaxVSpeed : Float = 60;

	public var display : FlxText;
	
	public var flickering : Bool;
	
	public function new(X : Float, Y : Float, World : PlayState)
	{
		super(X, Y, World);
	
		makeGraphic(16, 20, 0xFF200588);
		display = new FlxText(x, y, "");
		display.color = 0xFF000000;
	}
	
	override public function init(variation : Int)
	{
		super.init(variation);
		
		hp = 2;
		flickering = false;
		
		brain = new StateMachine(null, onStateChange);
		brain.transition(moveState, "move");
	}
	
	override public function update()
	{
		super.update();
		
		shadow.x = getMidpoint().x - shadow.width / 2;
		shadow.y = y + height - shadow.height / 2;
		shadow.update();
		
		display.x = x;
		display.y = y - 8;
		display.text = "HP: " + hp;
		
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
						brain.transition(moveState, "move");
					}
					else if (!dead && stunned)
					{
						brain.transition(stunState, "stun");
					}
				});
		}
	}
	
	public function moveState()
	{
		immovable = false;
		FlxVelocity.accelerateTowardsObject(this, world.player, Acceleration, MaxHSpeed, MaxVSpeed);
		
		drag.set();
	}
	
	public function hitState()
	{
		immovable = true;
		drag.set(1000, 1000);
	}
	
	public function stunState()
	{
		color = 0xFF772424;
		
		immovable = true;
		drag.set(1000, 1000);
	}
	
	override public function onStun()
	{
		brain.transition(stunState, "stun");
	}
	
	override public function onCollisionWithPlayerBullet(bullet : PlayerBullet)
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
		display.draw();
	}
}