package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import flixel.util.FlxPoint;
import flixel.group.FlxTypedGroup;

using flixel.util.FlxSpriteUtil;

class EnemySniper extends Enemy
{
	public var HurtTime : Float = 0.34;

	var idleTime : Float = 4;
	var shootTime : Float = 1;
	var shoots : Int = 1;
		
	var shooter : ShooterComponent;

	var flickering : Bool;
	
	public function new(X : Float, Y : Float, World: PlayState)
	{
		super(X, Y, World);
		
		makeGraphic(16, 24, 0xFF880450);
		/*loadGraphic("assets/images/plant-sheet.png", true, 32, 24);
		animation.add("idle", [4]);
		animation.add("open", [4, 5], 6, false);
		animation.add("shoot", [6]);
		animation.play("idle");*/
		
		timer = new FlxTimer();
	}
	
	override public function init(variation : Int)
	{
		super.init(variation);
		
		hp = 2;
		
		shooter = new ShooterComponent();
		shooter.init(world, EnemyBullet.EBulletType.Aimed);
		shooter.bulletSpeed = 185;
		
		brain = new StateMachine(null, onStateChange);
		brain.transition(idle, "idle");
		
		immovable = true;
		flickering = false;
	}
	
	override public function destroy()
	{
		timer.destroy();
	}
	
	override public function update()
	{
		if (frozen)
		{
			timer.active = false;
			if (tween != null)
				tween.active = false;
			return;
		}
		else
		{
			timer.active = true;
			if (tween != null)
				tween.active = true;
		}
		
		// Debug shoot
		if (FlxG.mouse.justPressed)
			// Shoot!
			shootBullet();
		
		super.update();
	}
	
	public function idle()
	{
		// animation.play("idle");
	}
	
	public function shoot()
	{
		/*if (animation.name == "open" && animation.finished)
		{*/
			// animation.play("shoot");

			// Shoot!
			shootBullet();
			
			// Wait a tad...
			//timer.start(shootTime, function(t : FlxTimer) : Void {
				// And idle
				brain.transition(idle, "idle");
			//});
			
		//}
	}
	
	public function hitState()
	{
		// wait...
		// animation.play("hurt");
	}
	
	public function stunState()
	{
		color = 0xFF772424;

		// wait...
		// animation.play("hurt");
	}
	
	
	public function onStateChange(newState : String) : Void
	{
		switch (newState)
		{
			case "idle":
				timer.start(idleTime, 
					function (t : FlxTimer) : Void {
						brain.transition(shoot, "shoot");
					});
			case "half-idle":
				timer.start(idleTime / 2, 
					function (t : FlxTimer) : Void {
						brain.transition(shoot, "shoot");
					});
			case "shoot":
				// animation.play("open");
			case "hit":
				flickering = true;
				flicker(HurtTime);
				
				timer.start(HurtTime, function(_t:FlxTimer) {
					flickering = false;
				
					if (!dead && !stunned)
					{
						brain.transition(idle, "half-idle");
					}
					else if (!dead && stunned)
					{
						brain.transition(stunState, "stun");
					}
				});
		}
	}
	
	override public function onBulletHit(bullet : PlayerBullet)
	{
		if (!dead/* && !flickering*/)
		{
			hit();
			
			brain.transition(hitState, "hit");
		}
	}
	
	public function shootBullet() : Void
	{
		// Shoot
		var origin : FlxPoint = getMidpoint();
		origin.y -= 6;
		
		shooter.shoot(origin, player.asTarget());
	}
}