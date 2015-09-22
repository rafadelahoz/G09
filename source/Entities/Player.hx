package;

import flixel.FlxObject;
import flixel.util.FlxPoint;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.effects.FlxFlicker;

using flixel.util.FlxSpriteUtil;

class Player extends Entity
{
	public static var WPISTOL 		: Int = 0x1;
	public static var WBLASTER 		: Int = 0x2;
	public static var WMELON 		: Int = 0x4;
	public static var WNET 			: Int = 0x8;

	public var WalkHSpeed 			: Float = 80;
	public var WalkHAcceleration 	: Float = 800;
	public var WalkVSpeed 			: Float = 65;
	public var WalkVAcceleration 	: Float = 450;
	
	public var RollDuration 		: Float = 0.3;
	public var RollHSpeed 			: Float = 110;
	public var RollVSpeed 			: Float = 90;
	
	public var HitHAcceleration 	: Float = 900;
	public var HitVAcceleration 	: Float = 580;

	public var HitDuration 			: Float = 1;
	public var HaltedDuration 		: Float = 0.6;
	
	public var MaxCarriedPackages 	: Int = 3;

	var hp (get, set): Int;
	var invulnerable : Bool;
	var halted : Bool;
	
	var shooterComponent : PlayerShooterComponent;
	var timer : FlxTimer;
	var tween : FlxTween;
	
	var shooting : Bool;
	public var rolling : Bool;
	var lastDirection : Int;
	var rollSpeed : FlxPoint;
	
	public var carriedPackages : Int;
	
	public function new(X : Int, Y : Int, World : PlayState)
	{
		super(X, Y, World);
		
		loadGraphic("assets/images/player-sheet.png", true, 32, 32);
		animation.add("idle", [0]);
		animation.add("walk", [1, 0], 5, true);
		animation.add("walk-vertical", [1, 0], 4, true);

		animation.play("idle");

		setSize(14, 10);
		offset.set(9, 21);
		
		maxVelocity.set(WalkHSpeed, WalkVSpeed);
		drag.set(WalkHAcceleration * 1.5, WalkVAcceleration * 1.5);
		
		// Pistol shooter component
		shooterComponent = new PlayerShooterComponent();
		initShooterComponent(GameStatusManager.currentWeapon());
		
		shooting = false;
		rolling = false;
		rollSpeed = new FlxPoint();
		
		invulnerable = false;
		halted = false;
		
		timer = new FlxTimer();
		tween = null;
		
		lastDirection = FlxObject.RIGHT;
		
		carriedPackages = 0;
	}
	
	override public function update()
	{
		if (frozen)
		{
			if (tween != null)
				tween.active = false;
			return;
		}
		else
		{
			if (tween != null)
				tween.active = true;
		}
	
		if (halted)
		{
			drag.set(HitHAcceleration * 1.5, HitHAcceleration * 1.5);
		}
		else
		{
			drag.set(WalkHAcceleration * 1.5, WalkVAcceleration * 1.5);
			
			if (rolling)
			{
				velocity.x = rollSpeed.x;
				velocity.y = rollSpeed.y;
				
				if (GamePad.checkButton(GamePad.Left))
				{
					lastDirection = FlxObject.LEFT;
				}
				else if (GamePad.checkButton(GamePad.Right))
				{
					lastDirection = FlxObject.RIGHT;
				}
			}
			else
			{
				if (!shooting)
				{
					if (GamePad.checkButton(GamePad.Left))
					{
						acceleration.x = -WalkHAcceleration;
						facing = FlxObject.LEFT;
						lastDirection = FlxObject.LEFT;
					}
					else if (GamePad.checkButton(GamePad.Right))
					{
						acceleration.x = WalkHAcceleration;
						facing = FlxObject.RIGHT;
						lastDirection = FlxObject.RIGHT;
					}
					else
						acceleration.x = 0;
					
					if (GamePad.checkButton(GamePad.Up))
					{
						acceleration.y = -WalkVAcceleration;
						lastDirection = FlxObject.UP;
					}
					else if (GamePad.checkButton(GamePad.Down))
					{
						acceleration.y = WalkVAcceleration;
						lastDirection = FlxObject.DOWN;
					}
					else
						acceleration.y = 0;
						
					if (acceleration.x != 0)
						acceleration.y = 0;
						
					handleWeapon();
						
					handleRolling();
				}
				
				handleShooting();

				if (acceleration.x != 0)
					animation.play("walk");
				else if (acceleration.y != 0)
					animation.play("walk-vertical");
				else
					animation.play("idle");

				flipX = (facing == FlxObject.LEFT);
			}
		}
		
		baseline = y + height;
	
		super.update();
		
		shadow.x = getMidpoint().x - shadow.width / 2;
		shadow.y = y + height - shadow.height / 2;
		shadow.update();
	}

	function handleWeapon() : Void
	{
		if (GamePad.justPressed(GamePad.Select))
		{
			var previousWeapon : Int = GameStatusManager.currentWeapon();
			var currentWeapon : Int = GameStatusManager.switchWeapon();
			if (currentWeapon != previousWeapon)
			{
				initShooterComponent(currentWeapon);
			}
		}
	}
	
	function initShooterComponent(weapon : Int) : Void
	{
		var btype : PlayerBullet.BulletType = PlayerBullet.BulletType.Pistol;
		
		// Play sound, animation...?
		
		switch (weapon)
		{
			case Player.WPISTOL:
				btype = PlayerBullet.BulletType.Pistol;
			case Player.WBLASTER:
				btype = PlayerBullet.BulletType.Blaster;
			case Player.WMELON:
				btype = PlayerBullet.BulletType.Melon;
			case Player.WNET:
				btype = PlayerBullet.BulletType.Net;
		}
		
		shooterComponent.init(world, btype);
	}
	
	function handleShooting() : Void
	{
		if (GamePad.justPressed(GamePad.B))
		{
			// Shoot!
			if (shooterComponent.shoot(getShootpoint(), getTargetpoint())) 
			{
				// And pause
				acceleration.set();
				velocity.set();
				
				// For a little while
				shooting = true;
				
				timer.start(shooterComponent.getDelay(), function(_t:FlxTimer) {
					shooting = false;
				});
			}
		}
	}
	
	function handleRolling() : Void
	{
		if (GamePad.justPressed(GamePad.A) && !rolling)
		{
			rolling = true;
			
			acceleration.set();
			velocity.set();
			rollSpeed.set();
			
			switch (lastDirection)
			{
				case FlxObject.LEFT:
					rollSpeed.x = -RollHSpeed;
				case FlxObject.RIGHT:
					rollSpeed.x = RollHSpeed;
				case FlxObject.UP:
					rollSpeed.y = -RollVSpeed;
				case FlxObject.DOWN:
					rollSpeed.y = RollVSpeed;
			}
			
			velocity.x = rollSpeed.x;
			velocity.y = rollSpeed.y;
			
			tween = FlxTween.tween(this, {angle: (facing == FlxObject.LEFT ? -360 : 360)}, RollDuration, 
				{
					complete: function(t:FlxTween) { angle=0; }
				});
			
			timer.start(RollDuration, function(_t:FlxTimer) {
				rolling = false;
				velocity.set();
				
				if (lastDirection == FlxObject.LEFT || lastDirection == FlxObject.RIGHT)
					facing = lastDirection;
			});
		}
	}
	
	public function hit(from : FlxPoint, ?damage : Int = 1)
	{
		hp -= damage;
		invulnerable = true;
		
		acceleration.set();
		velocity.set();
		
		if (from.x < getMidpoint().y)
			velocity.x = HitHAcceleration;
		else
			velocity.x = -HitHAcceleration;
			
		if (from.y < getMidpoint().y)
			velocity.y = HitVAcceleration;
		else
			velocity.y = -HitVAcceleration;
		
		if (hp <= 0)
		{
			// Player is dead!
			doFlicker(function(_f:FlxFlicker) {
				invulnerable = false;
				GameController.OnPlayerDeath();
			});
		}
		else 
		{	
			doFlicker(function(_f:FlxFlicker) {
				invulnerable = false;
			});
		}
	}
	
	public function doFlicker(completeCallback : FlxFlicker -> Void) 
	{
		this.flicker(HitDuration, completeCallback);
		
		halted = true;
		timer.start(HaltedDuration, function(_t:FlxTimer) {
			halted = false;
		});
	}
	
	public function onCollisionWithEnemy(enemy : Enemy)
	{
		if (!invulnerable)
			hit(enemy.getMidpoint());
	}
	
	public function onCollisionWithEnemyBullet(bullet : EnemyBullet)
	{
		if (!invulnerable)
			hit(bullet.getMidpoint());
	}
	
	override public function draw() : Void
	{
		shadow.draw();
		super.draw();
	}
	
	public function getShootpoint() : FlxPoint
	{
		var ox : Float = getMidpoint().x;
		var oy : Float = getMidpoint().y;
		
		return new FlxPoint(ox + (facing == FlxObject.LEFT ? -1 : 1) * 4, oy - 8);
	}
	
	public function getTargetpoint() : FlxPoint
	{
		var midpoint : FlxPoint = getMidpoint();
		if (facing == FlxObject.LEFT)
			midpoint.x -= 16;
		else
			midpoint.x += 16;
			
		return midpoint;
	}
	
	public function teleportTo(pos : FlxPoint) : Void
	{
		x = pos.x - width / 2;
		y = pos.y - height / 2;
	}
	
	public function asTarget() : FlxPoint
	{
		var targetPoint : FlxPoint = new FlxPoint();
		getMidpoint(targetPoint);
		targetPoint.y -= 10;
		
		return targetPoint;
	}
	
	public function get_hp() : Int
	{
		return GameStatusManager.getPlayerHP();
	}
	
	public function set_hp(hp : Int) : Int
	{
		GameStatusManager.setPlayerHP(hp);
		return hp;
	}
}