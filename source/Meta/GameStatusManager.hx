package;

import flixel.FlxObject;

class GameStatusManager
{
	public static var Status : Data;
	public static var PlayerStatus : PlayerData;
	
	public static function Init() : Void
	{
		Status = {
			currentMap: "w0m0",
			lastTeleport: null,
			coins: 0,
			weapons: Player.WPISTOL | Player.WBLASTER | Player.WMELON | Player.WNET,
			captures: []
		};
		
		PlayerStatus = {
			weapon: Player.WPISTOL,
			facing: FlxObject.RIGHT
		};
	}
	
	/** Coins Management **/
	
	public static function getCoins() : Int
	{
		return Status.coins;
	}
	
	public static function addCoins(coins : Int) : Void
	{
		Status.coins += coins;
	}
	
	/** Captures Management **/
	
	public static function addCapture(code : String)
	{
		if (Status.captures == null)
			Status.captures = new Array<String>();
			
		Status.captures.push(code);
	}
	
	public static function getCaptures() : Array<String>
	{
		if (Status.captures == null)
			Status.captures = new Array<String>();
			
		return Status.captures;
	}
	
	/** Weapons Management **/
	
	public static function currentWeapon() : Int
	{
		return PlayerStatus.weapon;
	}
	
	public static function hasWeapon(weapon : Int) : Bool
	{
		return (Status.weapons & weapon) != 0;
	}
	
	public static function onWeaponCollected(weapon : Int) : Void
	{
		Status.weapons = Status.weapons | weapon;
	}
	
	public static function switchWeapon() : Int
	{
		var weapons : Array<Int> = [Player.WPISTOL, Player.WBLASTER, Player.WMELON, Player.WNET];
		
		var currentIndex : Int = weapons.indexOf(PlayerStatus.weapon);
		var currentWeapon : Int = -1;
		
		// Find the next weapon from currentIndex + 1 to the end of the list
		for (index in (currentIndex+1)...weapons.length)
		{
			var weapon : Int = weapons[index];
			if (hasWeapon(weapon))
			{
				currentWeapon = weapon;
				break;
			}
		}
		
		// If not found, check from 0 to currentIndex-1
		if (currentWeapon < 0) 
		{
			for (index in 0...(currentIndex-1))
			{
				var weapon : Int = weapons[index];
				if (hasWeapon(weapon))
				{
					currentWeapon = weapon;
					break;
				}	
			}
		}
		
		// If found
		if (currentWeapon >= 0)
			PlayerStatus.weapon = currentWeapon;
		// else: No more weapons available
		
		return PlayerStatus.weapon;
	}
}

typedef Data = { 
	currentMap: String,
	lastTeleport: Teleport.TeleportData,
	coins: Int,
	weapons: Int,
	captures: Array<String>
}

typedef PlayerData = {
	weapon: Int,
	facing: Int
}