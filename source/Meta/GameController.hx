package;

import flixel.FlxG;
import flixel.util.FlxSave;

class GameController 
{
	public static var SAVESLOTS (get, null) : Array<String>;
	static inline function get_SAVESLOTS() : Array<String> { return ["SAVE0", "SAVE1", "SAVE2"]; }
	public static var SAVESLOT = "SAVE0";

	private static var gameSave : FlxSave;
	
	/** Game Management API **/
	public static function ToTitleScreen()
	{
		FlxG.switchState(new MenuState());
	}
	
	public static function ToGameSelectScreen()
	{
		FlxG.switchState(new GamefileState());
	}
	
	public static function StartGame()
	{
		FlxG.switchState(new PlayState(GameStatusManager.Status.currentMap));
	}
	
	public static function Teleport()
	{
		GameStatusManager.Status.currentMap = GameStatusManager.Status.lastTeleport.target;
	
		FlxG.switchState(new PlayState(GameStatusManager.Status.currentMap));
	}
	
	public static function OnPlayerDeath() 
	{
		text.TextBox.Message("", "   YOU ARE DEAD!   ", function() {
			// Revive for now
			GameStatusManager.setPlayerHP(3);
		});
	}
	
	/** Status handling functions **/
	
	public static function NewGame()
	{
		GameController.clearSave();
		GameController.init();
		GameController.save();
	}
	
	public static function SaveGame()
	{
		save();
	}
	
	public static function ContinueGame()
	{
		load();
	}
	
	/** Low Level Save/Load API **/
	
	public static function init() 
	{
		gameSave = new FlxSave();
		
		GameStatusManager.Init();
	}
	
	public static function checkSavefiles() : Map<String, GameStatusManager.Data>
	{
		var savefilesMap : Map<String, GameStatusManager.Data> = new Map<String, GameStatusManager.Data>();
		
		for (saveslot in SAVESLOTS)
		{
			savefilesMap.set(saveslot, checkSaveslot(saveslot));
		}
		
		return savefilesMap;
	}
	
	public static function checkSaveslot(slot : String) : GameStatusManager.Data
	{
		gameSave.bind(slot);
		
		var data : GameStatusManager.Data = gameSave.data.gameStatus;
		gameSave.destroy();
		return data;
	}
	
	public static function clearSave()
	{
		gameSave.bind(SAVESLOT);
		gameSave.data.gameStatus = null;
		gameSave.close();
	}
	
	public static function save() 
	{
		
		gameSave.bind(SAVESLOT);
		gameSave.data.gameStatus = GameStatusManager.Status;
		trace("Saving " + gameSave.data);
		gameSave.close();
	}
	
	public static function load() 
	{
		gameSave.bind(SAVESLOT);
		if (gameSave.data.gameStatus == null)
		{
			trace("Load unsuccessful");
		}
		else 
		{
			GameStatusManager.Status = gameSave.data.gameStatus;
			trace("Loaded: " + gameSave.data);
		}
	}
	
	/** Data parsing **/
}