package;

import flixel.FlxObject;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxPoint;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
using flixel.util.FlxSpriteUtil;

class PlayFlowManager extends FlxObject
{
	static var instance : PlayFlowManager;
	public static function get(?World : PlayState = null) : PlayFlowManager
	{
		// There is no instance: create one
		if (instance == null)
		{
			instance = new PlayFlowManager(World);
		}
		// There is a former instance, update references
		else 
		{
			if (World != null)
				instance.world = World;
		}
		
		return instance;
	}

	public var world : PlayState;
	public var canResume : Bool;
	public var paused : Bool;
	public var group : FlxGroup;
	
	public function new(?World : PlayState/*, ?Gui : GUI*/)
	{
		super();

		if (World != null)
		{
			world = World;
		}
		
		create();
	}

	override public function destroy() : Void
	{
		group.destroy();
		group = null;

		instance = null;
	}

	public function create() : Void
	{
		paused = false;
		group = new FlxGroup();

		new FlxTimer(0.01, function(_t:FlxTimer) {
			doPause(true);
			// Fade-in?
			//spotlightFx.open(world.penguin.getMidpoint(), function() {
				doUnpause(true);
			//});
		});
	}

	public function onUpdate() : Bool
	{
		if (paused)
		{
			group.update();
			super.update();
			
			return false;
		}

		return true;
	}

	public function onDraw() : Bool
	{
		if (paused)
		{
		 	group.draw();
		 	super.draw();

		 	return false;
		}

		return true;
	}
	
	public function onDeath(deathType : String) : Void
	{
		if (!paused) 
		{
			trace("Dead by " + deathType);

			/*world.penguin.onDeath(deathType);*/

			doFinish(0xff000000);
		}
	}
	
	function doFinish(color : Int) : Void
	{
		doPause(true);
		
		/*spotlightFx.close(function() {		
			// spotlightFx.cancel();

			// TODO: Move this into the SpotlightEffect class
			// Set screen to full black
			FlxG.camera.fade(0xFF000000, 0.0, false);
			// Wait a tad before going back
			new FlxTimer(0.75, function(_t:FlxTimer) {
				FlxG.switchState(new WorldMapState());
			});
		});*/
	}
	
	public function doPause(silent : Bool = false) : Void
	{
		canResume = !silent;
	
		paused = true;
		
		for (entity in world.entities)
		{
			entity.freeze();
		}
	}
	
	public function doUnpause(force : Bool = false) : Void
	{
		if (!canResume && !force)
			return;
	
		paused = false;
		
		for (entity in world.entities)
		{
			entity.resume();
		}
	}
}