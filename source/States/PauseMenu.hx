package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.text.FlxBitmapTextField;
import flixel.util.FlxRandom;
import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

import text.PixelText;

class PauseMenu extends FlxSubState
{
	var group : FlxSpriteGroup;
	var text : FlxBitmapTextField;
	var bg : FlxSprite;
	
	var capturesListText : FlxBitmapTextField;
	var weaponsListText : FlxBitmapTextField;
	
	public function new()
	{
		super(0x00000000);
		
		group = new FlxSpriteGroup(0, FlxG.height);
		
		bg = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		bg.scrollFactor.set();
		
		text = PixelText.New(FlxG.width / 2 - 48, FlxG.height / 4, " ~ PAUSED! ~ ");
		text.scrollFactor.set();
		
		
		var listText = "-CAPTURES-\n";
		for (capture in GameStatusManager.getCaptures())
		{
			listText += "> " + capture + "\n";
		}
		
		capturesListText = PixelText.New(16, text.y+16, listText, 0xFFFFFFFF, 12*8);
		capturesListText.scrollFactor.set();
		
		var weaponsText = "-WEAPONS-\n";
		if (GameStatusManager.hasWeapon(Player.WPISTOL))
			weaponsText += (GameStatusManager.currentWeapon() == Player.WPISTOL ? ">" : " ") + " PISTOL\n";
		if (GameStatusManager.hasWeapon(Player.WBLASTER))
			weaponsText += (GameStatusManager.currentWeapon() == Player.WBLASTER ? ">" : " ") + " BLASTER\n";
		if (GameStatusManager.hasWeapon(Player.WMELON))
			weaponsText += (GameStatusManager.currentWeapon() == Player.WMELON ? ">" : " ") + " MELON\n";
		if (GameStatusManager.hasWeapon(Player.WNET))
			weaponsText += (GameStatusManager.currentWeapon() == Player.WNET ? ">" : " ") + " NET\n";
		
		weaponsListText = PixelText.New(148, text.y + 16, weaponsText, 0xFFFFFFFF ,12*8);
		weaponsListText.scrollFactor.set();
		
		group.scrollFactor.set();
		
		group.add(bg);
		group.add(text);
		group.add(capturesListText);
		group.add(weaponsListText);
		
		add(group);
		
		FlxTween.tween(group, {y: 0}, 0.5, { ease: FlxEase.bounceOut });
		
		add(GamePad.virtualPad);
		
		FlxG.inputs.reset();
		GamePad.resetInputs();
	}
	
	override public function close()
	{
		FlxG.inputs.reset();
		GamePad.resetInputs();
		
		// PlayFlowManager.get().world.player.initShooterComponent(GameStatusManager.currentWeapon());
		
		super.close();
	}
	
	override public function update()
	{
		GamePad.handlePadState();
		
		// updateWeaponDisplay();
		
		if (GamePad.justReleased(GamePad.Start))
		{
			FlxTween.tween(group, {y: FlxG.height}, 0.5, { ease: FlxEase.bounceOut, complete: function(_t:FlxTween) {
				close();
			}});
		}
	
		super.update();
	}
	
	var weaponList : Array<Int> = [Player.WPISTOL, Player.WBLASTER, Player.WMELON, Player.WNET];
	
	function getAvailableWeapons() : Array<Int>
	{
		var availableWeapons : Array<Int> = new Array<Int>();
		for (weapon in weaponList)
		{
			if (GameStatusManager.hasWeapon(weapon))
				availableWeapons.push(weapon);
		}
		
		return availableWeapons;
	}
	
	function updateWeaponDisplay()
	{
		// var availableWeapons : Array<Int> = getAvailableWeapons();
		
		if (GamePad.justPressed(GamePad.Right))
		{
			/*var currentWeapon : Int = GameStatusManager.currentWeapon();

			var nextWeapon : Int = availableWeapons.indexOf(currentWeapon) + delta;
			if (nextWeapon < 0)
				nextWeapon = availableWeapons.length + nextWeapon;
			else if (nextWeapon >= availableWeapons.length)
				nextWeapon -= availableWeapons.length;
			
			var actualWeapon : Int = availableWeapons.get(nextWeapon);*/
			
			GameStatusManager.switchWeapon();
		}
		
		var weaponsText = "-WEAPONS-\n";
		
		if (GameStatusManager.hasWeapon(Player.WPISTOL))
			weaponsText += (GameStatusManager.currentWeapon() == Player.WPISTOL ? ">" : " ") + " PISTOL\n";
		if (GameStatusManager.hasWeapon(Player.WBLASTER))
			weaponsText += (GameStatusManager.currentWeapon() == Player.WBLASTER ? ">" : " ") + " BLASTER\n";
		if (GameStatusManager.hasWeapon(Player.WMELON))
			weaponsText += (GameStatusManager.currentWeapon() == Player.WMELON ? ">" : " ") + " MELON\n";
		if (GameStatusManager.hasWeapon(Player.WNET))
			weaponsText += (GameStatusManager.currentWeapon() == Player.WNET ? ">" : " ") + " NET\n";
			
		weaponsListText.text = weaponsText;
	}
}
