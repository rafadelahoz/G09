package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.text.FlxBitmapFont;
import flixel.group.FlxTypedGroup;
import flixel.util.FlxRect;
import flixel.util.FlxPoint;
import flixel.util.FlxColorUtil;

using flixel.util.FlxSpriteUtil;

class GUI extends FlxTypedGroup<FlxSprite>
{
	var topBackground : FlxSprite;
	
	var coinDisplayText : FlxBitmapFont;

	public function new()
	{
		super();
		
		topBackground = new FlxSprite(0, 0).makeGraphic(FlxG.width, 8, 0xFF000000);
		add(topBackground);
		
		coinDisplayText = new FlxBitmapFont(GameConstants.Font, 8, 8, FlxBitmapFont.TEXT_SET1, 16);
		add(coinDisplayText);
		
		// Scrollfactor.set()
		forEach(function(spr : FlxSprite) {
			spr.scrollFactor.set();
		});
	}
	
	override public function update()
	{
		updateCoinDisplay();
		
		super.update();
	}
	
	private function updateCoinDisplay()
	{
		// Not efficient! Update only when necessary!
		coinDisplayText.text = "COINS: " + GameStatusManager.Status.coins;
	}
}