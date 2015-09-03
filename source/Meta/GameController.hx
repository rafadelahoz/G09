package;

import flixel.FlxG;
import flixel.util.FlxSave;

class GameController 
{
	public static var SAVESLOTS (get, null) : Array<String>;
	static inline function get_SAVESLOTS() : Array<String> { return ["SAVE0", "SAVE1", "SAVE2"]; }
	public static var SAVESLOT = "SAVE0";

	private static var gameSave : FlxSave;

	public static var GameStatus : GameStatusData;
	
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
		FlxG.switchState(new PlayState(GameStatus.currentMap));
	}
	
	public static function Teleport()
	{
		GameStatus.currentMap = GameStatus.lastTeleport.target;
	
		FlxG.switchState(new PlayState(GameStatus.currentMap));
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
		
		GameStatus = {
			currentMap: "w0m0",
			lastTeleport: null,
			coins: 0
		};
	}
	
	public static function checkSavefiles() : Map<String, GameStatusData>
	{
		var savefilesMap : Map<String, GameStatusData> = new Map<String, GameStatusData>();
		
		for (saveslot in SAVESLOTS)
		{
			savefilesMap.set(saveslot, checkSaveslot(saveslot));
		}
		
		return savefilesMap;
	}
	
	public static function checkSaveslot(slot : String) : GameStatusData
	{
		gameSave.bind(slot);
		
		var data : GameStatusData = gameSave.data.gameStatus;
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
		gameSave.data.gameStatus = GameStatus;
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
			GameStatus = gameSave.data.gameStatus;
			trace("Loaded: " + gameSave.data);
		}
	}
	
	/** Data parsing **/
}


typedef GameStatusData = { 
	currentMap: String,
	lastTeleport: Teleport.TeleportData,
	coins: Int
}
