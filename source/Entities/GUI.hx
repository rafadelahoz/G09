package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.text.FlxBitmapFont;
import flixel.group.FlxTypedGroup;
import flixel.util.FlxRect;
import flixel.util.FlxPoint;
import flixel.util.FlxColorUtil;
import flixel.text.FlxBitmapTextField;

import text.PixelText;

using flixel.util.FlxSpriteUtil;

class GUI extends FlxTypedGroup<FlxSprite>
{
	var topBackground : FlxSprite;
	
	var coinDisplayText : FlxBitmapFont;
	var weaponDisplayText : FlxBitmapFont;
	
	var dbgText : FlxBitmapTextField;

	public function new()
	{
		super();
		
		topBackground = new FlxSprite(0, 0).makeGraphic(FlxG.width, 8, 0xFF000000);
		add(topBackground);
		
		coinDisplayText = new FlxBitmapFont(GameConstants.Font, 8, 8, FlxBitmapFont.TEXT_SET1, 16);
		add(coinDisplayText);
		
		weaponDisplayText = new FlxBitmapFont(GameConstants.Font, 8, 8, FlxBitmapFont.TEXT_SET1, 16);
		weaponDisplayText.x = FlxG.width - 64;
		add(weaponDisplayText);
		
		dbgText = PixelText.New(32, -4, "HELLO THERE!\nARE you HeRe for the MUFFINS?? :)", 0xFF00FFFF, 80);
		add(dbgText);
		
		// Scrollfactor.set()
		forEach(function(spr : FlxSprite) {
			spr.scrollFactor.set();
		});
	}
	
	override public function update()
	{
		updateCoinDisplay();
		updateWeaponDisplay();
		
		var mousePos : FlxPoint = FlxG.mouse.getScreenPosition();
		dbgText.x = mousePos.x;
		dbgText.y = mousePos.y;
		
		super.update();
	}
	
	private function updateCoinDisplay()
	{
		var text = "COINS: " + GameStatusManager.Status.coins;
		// Update only when necessary!
		if (text != coinDisplayText.text)
			coinDisplayText.text = text;
	}
	
	private function updateWeaponDisplay()
	{
		var text : String = "";
		switch (GameStatusManager.currentWeapon())
		{
			case Player.WPISTOL:
				text += "PISTOL";
			case Player.WBLASTER:
				text += "BLASTER";
			case Player.WMELON:
				text += "MELON";
			case Player.WNET:
				text += "NET";
		}
		
		// Update only when necessary!
		if (text != weaponDisplayText.text)
			weaponDisplayText.text = text;
	}
}