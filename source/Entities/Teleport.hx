package;

import flixel.FlxObject;
import flixel.util.FlxPoint;
import flixel.util.FlxMath;

class Teleport extends FlxObject
{
	public var name : String;
	public var mapName : String;
	
	public function new(X : Float, Y : Float, Width : Float, Height : Float, Name : String, MapName : String)
	{
		super(X, Y, Width, Height);
		
		name = Name;
		mapName = MapName;
		
		immovable = true;
	}
	
	public function decodePosition(point : FlxPoint) : FlxPoint
	{
		return new FlxPoint(x + point.x * width, y + point.y * height);
	}
	
	public function computePosition(point : FlxPoint) : FlxPoint
	{
		var xx = computeComponent(point.x - x, width);
		var yy = computeComponent(point.y - y, height);
		
		var validXX = xx >= 0 && xx < 1;
		var validYY = yy >= 0 && yy < 1;
			
		if (!validXX && !validYY)
		{
			// Use the smaller distance as the good one and fix it!
			var nxx : Float = normalizeComponent(xx);
			var nyy : Float = normalizeComponent(yy);
				
			if (nxx <= nyy)
				xx = FlxMath.bound(xx, 0, 1);
			else
				yy = FlxMath.bound(yy, 0, 1);
		}
			
		if (xx < 0 && validYY)
			xx = 2;
		else if (xx > 1 && validYY)
			xx = -1;
		else if (validXX && yy < 0)
			yy = 2;
		else if (validXX && yy > 1)
			yy = -1;
		
		return new FlxPoint(xx, yy);
	}
	
	function computeComponent(position : Float, length : Float) : Float
	{
		var component = position / length;
		return component;
	}
	
	function normalizeComponent(component : Float) : Float
	{
		if (component < 0)
			component *= -1;
		else if (component > 1)
			component -= 1;
			
		return component;
	}
	
	public function getData() : TeleportData
	{
		return {
			name : name,
			target : mapName,
			position : null
		};
	}
}

typedef TeleportData = {
	name: String,
	target: String,
	position: FlxPoint
};