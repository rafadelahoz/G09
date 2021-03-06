package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;
import flixel.group.FlxTypedGroup;

using flixel.util.FlxSpriteUtil;

class EnemyShooter extends Enemy
{
	public var HurtTime : Float = 0.34;
	public var IdleTime : Float = 0.4;
	public var CooldownTime : Float = 0.4;
	public var CoverWaitTime : Float = 1.5;
	public var AttackDistance : Int = 128;
		
	var shooter : ShooterComponent;
	
	var waitingInCover : Bool;
	var covered : Bool;
	var flickering : Bool;
	
	public function new(X : Float, Y : Float, World: PlayState)
	{
		super(X, Y, World);
		
		makeGraphic(16, 24, 0xFF500488);
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
		shooter.init(world, EnemyBullet.EBulletType.Straight);
		shooter.bulletSpeed = 185;
		
		brain = new StateMachine(null, onStateChange);
		brain.transition(coverState, "cover");
		
		immovable = true;
		flickering = false;
		waitingInCover = false;
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
	
	public function coverState()
	{
		covered = true;
		alpha = 0.4;
		
		if (!waitingInCover)
		{
			if (getMidpoint().distanceTo(player.asTarget()) < AttackDistance && FlxRandom.chanceRoll(20))
			{
				if (!player.invulnerable)
					brain.transition(idle, "idle");
			}
		}
	}
	
	public function idle()
	{
		covered = false;
		alpha = 1;
		
		color = 0xFFFFFFFF;
		// animation.play("idle");
		
		if (getMidpoint().distanceTo(player.asTarget()) > AttackDistance && FlxRandom.chanceRoll(50))
		{
			brain.transition(coverState, "cover");
		}
	}
	
	public function shoot()
	{
		/*if (animation.name == "open" && animation.finished)
		{*/
			// animation.play("shoot");

			// Shoot!
			shootBullet();
			
			// Wait a tad...
			brain.transition(cooldown, "cooldown");
			
		//}
	}
	
	public function cooldown()
	{
		// ...
		color = 0xFF400377;
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
	
	override public function setCollisionMask() : Void
	{
		if (covered)
			setSize(0, 0);
		else
			setSize(16, 24);
	}
	
	public function onStateChange(newState : String) : Void
	{
		switch (newState)
		{
			case "idle":
				timer.start(IdleTime, function(_t:FlxTimer) {
					brain.transition(shoot, "shoot");
				});
			case "shoot":
				// animation.play("open");
			case "cooldown":
				timer.start(CooldownTime, function(_t:FlxTimer) {
					if (FlxRandom.chanceRoll(30))
						brain.transition(idle, "idle");
					else
						brain.transition(coverState, "cover-wait");
				});
			case "cover":
				waitingInCover = false;
			case "cover-wait":
				waitingInCover = true;
				timer.start(CoverWaitTime, function(_t:FlxTimer) {
					waitingInCover = false;
				});
			case "hit":
				flickering = true;
				flicker(HurtTime);
				
				timer.start(HurtTime, function(_t:FlxTimer) {
					flickering = false;
				
					if (!dead && !stunned)
					{
						brain.transition(idle, "shoot");
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