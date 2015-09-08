package;

import flixel.util.FlxRect;
import utils.tiled.TiledImage;

class Decoration extends Entity
{
	var movementRect : FlxRect;
	var collisionRect : FlxRect;
	
	public function new(X : Float, Y : Float, World : PlayState, Image : TiledImage)
	{
		// Correct by the offset
		super(X + Image.offsetX, Y + Image.offsetY, World);
		
		loadGraphic(Image.imagePath);
		setSize(Image.width, Image.height);
		offset.set(Image.offsetX, Image.offsetY);
		
		movementRect = new FlxRect(Image.offsetX, Image.offsetY, Image.width, Image.height);
		collisionRect = new FlxRect(Image.maskOffsetX, Image.maskOffsetY, Image.maskWidth, Image.maskHeight);
		
		immovable = true;
		
		baseline = y + height;
	}
	
	override public function setMovementMask() : Void
	{
		setMask(movementRect);
	}
	
	override public function setCollisionMask() : Void
	{
		setMask(collisionRect);
	}
	
	function setMask(mask : FlxRect) : Void
	{
		setSize(mask.width, mask.height);
		offset.set(mask.x, mask.y);
	}
}