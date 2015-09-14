package;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.group.FlxTypedGroup;
import flixel.FlxCamera;
import flixel.tile.FlxTilemap;
import flixel.util.FlxTimer;
import flixel.util.FlxPoint;
import flixel.util.FlxRect;
import flixel.util.FlxSort;
import flixel.util.FlxRandom;
import flixel.addons.display.FlxGridOverlay;

using flixel.util.FlxSpriteUtil;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends GameState
{
	/* Level config */
	public var mapName : String;
	
	/* General elements */
	var playflowManager : PlayFlowManager;
	var camera : FlxCamera;
	var gui : GUI;
	var grid : FlxSprite;
	
	/* Entities lists */
	public var player : Player;
	
	public var level : TiledLevel;

	public var enemies : FlxGroup;
		public var collidableEnemies : FlxGroup;
		public var nonCollidableEnemies : FlxGroup;
		
	public var playerBullets : FlxGroup;
	
	public var enemyBullets : FlxGroup;
	
	public var collectibles : FlxTypedGroup<Collectible>;
	
	public var decoration : FlxTypedGroup<Decoration>;
	public var teleports : FlxTypedGroup<Teleport>;

	// General entities list for pausing
	public var entities : FlxTypedGroup<Entity>;

	public function new(?Level : String)
	{
		super();

		if (Level == null)
			Level = "" + GameStatusManager.Status.currentMap;

		mapName = Level;
	}

	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{

		// Random Background color
		var bgColors = [0xFFBE3241, 0xFFDF7A92, 0xFF3EA5F2, 0xFF545454, 0xFF24323F, 0xFF6888FC, 0xFF3C565C, 0xFF529023, 0xFFA6CD33, 0xFFFFFFFF, 0xFFF7E176, 0xFF574A38, 0xFF463C2D, 0xFF352D22, 0xFF231E17, 0xFF120F0C];
		FlxG.camera.bgColor = bgColors[FlxRandom.intRanged(0, bgColors.length-1)];

		// Prepare state holders
		entities = new FlxTypedGroup<Entity>();

		player  = null;
		
		enemies = new FlxGroup();
			collidableEnemies = new FlxGroup();
			nonCollidableEnemies = new FlxGroup();
			enemies.add(collidableEnemies);
			enemies.add(nonCollidableEnemies);
			
		playerBullets = new FlxGroup();
		
		enemyBullets = new FlxGroup();

		collectibles = new FlxTypedGroup<Collectible>();
		teleports = new FlxTypedGroup<Teleport>();
		
		decoration = new FlxTypedGroup<Decoration>();

		// Load the tiled level
		level = new TiledLevel("assets/maps/" + mapName + ".tmx");
		
		// Read level parameters

		// Add tilemaps
		add(level.backgroundTiles);

		// Load level objects
		level.loadObjects(this);

		add(entities);
		
		handlePlayerPosition();
		
		// Add overlay tiles
		add(level.overlayTiles);

		// Debug grid thing
		/*grid = FlxGridOverlay.create(16, 16, level.fullWidth, level.fullHeight);
		grid.alpha = 0.5;
		add(grid);*/
		
		// Set the camera to follow the player
		if (player != null)
			FlxG.camera.follow(player, FlxCamera.STYLE_TOPDOWN, null, 0);

		// Add the GUI
		gui = new GUI();
		add(gui);
			
		// Prepare death manager
		playflowManager = PlayFlowManager.get(this/*, gui*/);
		
		// Delegate
		super.create();
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		if (player != null) {
			player.destroy();
			player = null;
		}

		level.destroy();
		level = null;

		collidableEnemies.destroy();
		collidableEnemies = null;
		nonCollidableEnemies.destroy();
		nonCollidableEnemies = null;
		enemies.destroy();
		enemies = null;
		
		teleports.destroy();
		teleports = null;
		
		decoration.destroy();
		decoration = null;
		
		collectibles.destroy();
		collectibles = null;
		
		gui.destroy();
		gui = null;

		playflowManager.destroy();
		playflowManager = null;

		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		/* If the game is not paused due to death, level finished, ... */
		if (playflowManager.onUpdate()) 
		{
			if (GamePad.justReleased(GamePad.Start))
			{
				// playflowManager.doPause();
				openSubState(new PauseMenu());
			}
		
			/* Resolve vs World collisions */
			
			// Switch to movement masks!
			entities.callAll("setMovementMask");
			
			// Enemies vs World
			resolveEnemiesWorldCollision();

			// Player vs World
			level.collideWithLevel(player);
			
			// Player vs Decoration
			FlxG.collide(decoration, player);
			
			// Enemies vs Decoration
			FlxG.collide(decoration, enemies);
			
			// Player vs Teleports
			FlxG.overlap(teleports, player, onTeleportCollision);
			
			// Player bullets vs World
			// TODO: Bullets should collide with tall obstacles!
			// resolveGroupWorldCollision(playerBullets);
			
			// Enemies vs enemies
			FlxG.collide(collidableEnemies);
			
			/* Resolve vs World collisions */
			
			// Switch to fight masks!
			entities.callAll("setCollisionMask");
			
			// Player vs Collectibles
			FlxG.overlap(collectibles, player, onCollectibleCollision);
			
			// PlayerBullets vs Enemies
			FlxG.overlap(playerBullets, enemies, onBulletEnemyCollision);
			
			// PlayerBullets vs Decoration
			// FlxG.overlap(playerBullets, decoration, onBulletDecorationCollision);
			
			// Player vs Enemies
			FlxG.overlap(enemies, player, onEnemyCollision);
			
			// Switch to movement masks!
			entities.callAll("setMovementMask");
			
			/* Update the GUI */
			// gui.updateGUI(icecream, this);
		}
		else
		{
			// Player pause
			if (playflowManager.canResume)
			{
				/*if (GamePad.justPressed(GamePad.Start))
					playflowManager.doUnpause();
				else if (GamePad.justPressed(GamePad.A))
					playflowManager.onDeath("Suicide");*/
			}
		}
		
		/* Do the debug things */
		doDebug();

		/* Go on */
		super.update();
		
		/* Sort */
		entities.sort(sortByBaseline, FlxSort.ASCENDING);
	}
	
	public static function sortByBaseline(Order : Int, Obj1 : FlxBasic, Obj2 : FlxBasic) : Int
	{
		var result:Int = 0;
		
		var Value1 : Float;
		var Value2 : Float;
		
		if (Std.is(Obj1, Entity))
			Value1 = cast(Obj1, Entity).baseline;
		else 
			Value1 = cast(Obj1, FlxObject).y + cast(Obj1, FlxObject).height;
			
		if (Std.is(Obj2, Entity))
			Value2 = cast(Obj2, Entity).baseline;
		else
			Value2 = (cast Obj2).y + (cast Obj2).height;
		
		if (Value1 < Value2)
		{
			result = Order;
		}
		else if (Value1 > Value2)
		{
			result = -Order;
		}
		
		return result;
	}
	
	function resolveGroupWorldCollision(group : FlxGroup) : Void
	{
		for (element in group)
		{
			if (Std.is(element, FlxGroup))
			{
				resolveGroupWorldCollision(cast(element, FlxGroup));
			}
			else
			{
				level.collideWithLevel(cast element);
			}
		}
	}
	
	function resolveEnemiesWorldCollision() : Void
	{
		enemies.forEach(resolveEnemyWorldCollision);
		collidableEnemies.forEach(resolveEnemyWorldCollision);
		nonCollidableEnemies.forEach(resolveEnemyWorldCollision);
	}
	
	function resolveEnemyWorldCollision(enemy : FlxBasic) : Void
	{
		if ((cast enemy).collideWithLevel)
		{
			level.collideWithLevel((cast enemy));
		}
	}

	override public function draw() : Void
	{
		super.draw();
		playflowManager.onDraw();
	}

	public function onBulletDecorationCollision(bullet : PlayerBullet, decoration : Decoration) : Void
	{
		bullet.onCollisionWithDecoration(decoration);
	}
	
	public function onBulletEnemyCollision(bullet : PlayerBullet, enemy : Enemy) : Void
	{
		bullet.onCollisionWithEnemy(enemy);
		enemy.onCollisionWithPlayerBullet(bullet);
	}
	
	public function onEnemyCollision(one : Enemy, two : Player) : Void
	{
		FlxObject.separate(one, two);
		one.onCollisionWithPlayer(two);
		two.onCollisionWithEnemy(one);
	}
	
	public function onEnemyEnemyCollision(a : Enemy, b : Enemy) : Void
	{
		trace("Colliding " + a + " and " + b);
		if (a.collideWithEnemies && b.collideWithEnemies)
			FlxObject.separate(a, b);
		else
			trace("NO COLL");
	}

	public function onCollectibleCollision(collectible : Collectible, player : Player)
	{
		collectible.onCollisionWithPlayer(player);
		// Don't notify the player for now
	}
	
	public function onTeleportCollision(teleport : Teleport, player : Player)
	{
		// playflowManager.onGoal(teleport);
		
		FlxObject.separate(teleport, player);
		
		var pos : FlxPoint = teleport.computePosition(player.getMidpoint());		
		
		GameStatusManager.Status.lastTeleport = teleport.getData();
		GameStatusManager.Status.lastTeleport.position = pos;
		
		GameController.Teleport();
	}

	public function addPlayer(p : Player) : Void
	{
		if (player != null)
			player = null;

		player = p;

		// add(player);
	}

	public function addEnemy(enemy : Enemy) : Void
	{
		if (enemy.collideWithEnemies)
			collidableEnemies.add(enemy);
		else
			nonCollidableEnemies.add(enemy);
	}
	
	public function handlePlayerPosition()
	{
		var lastTeleportData : Teleport.TeleportData = GameStatusManager.Status.lastTeleport;
		if (lastTeleportData != null)
		{
			// Locate the actual teleport
			for (teleport in teleports)
			{
				if (teleport.name == lastTeleportData.name)
				{
					var position = teleport.decodePosition(lastTeleportData.position);
					player.teleportTo(position);
					break;
				}
			}
		}
	}
	
	function doDebug() : Void
	{
		if (FlxG.keys.anyPressed(["K"])) {
			PlayFlowManager.get().onDeath("kill");
		}
		
		var mousePos : FlxPoint = FlxG.mouse.getWorldPosition();
		
		if (FlxG.mouse.justPressed)
		{
			/*var enemy : Enemy = new EnemyWalker(mousePos.x, mousePos.y, this);
			enemy.init(0);
			addEnemy(enemy);*/
			
			var coin : Coin = new Coin(mousePos.x, mousePos.y, this);
			collectibles.add(coin);
		}

		if (FlxG.keys.justPressed.ONE) 
		{
			var enemy : Enemy = new EnemyWalker(mousePos.x, mousePos.y, this);
			enemy.init(0);
			addEnemy(enemy);
		} 
		else if (FlxG.keys.justReleased.TWO) 
		{
			var enemy : Enemy = new EnemyFollower(mousePos.x, mousePos.y, this);
			enemy.init(0);
			addEnemy(enemy);
		}
		
		if (FlxG.keys.anyJustPressed(["T"]))
		{
			player.x = Std.int(mousePos.x);
			player.y = Std.int(mousePos.y);
		}
		
		/*if (FlxG.keys.anyJustPressed(["UP"]))
			FlxG.timeScale = Math.min(FlxG.timeScale + 0.5, 1);
		else if (FlxG.keys.anyJustPressed(["DOWN"]))
			FlxG.timeScale = Math.max(FlxG.timeScale - 0.5, 0);*/
	}
}