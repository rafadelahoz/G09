package;

class GameStatusManager
{
	public static var Status : Data;
	
	public static function Init() : Void
	{
		Status = {
			currentMap: "w0m0",
			lastTeleport: null,
			coins: 0
		};
	}
}

typedef Data = { 
	currentMap: String,
	lastTeleport: Teleport.TeleportData,
	coins: Int
}