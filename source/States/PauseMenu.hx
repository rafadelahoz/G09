package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.addons.text.FlxBitmapFont;
import flixel.util.FlxRandom;
import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class PauseMenu extends FlxSubState
{
	var group : FlxSpriteGroup;
	var text : FlxBitmapFont;
	var bg : FlxSprite;
	
	var capturesListText : FlxBitmapFont;
	
	public function new()
	{
		super(0x00000000);
		
		group = new FlxSpriteGroup(0, FlxG.height);
		
		bg = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		bg.scrollFactor.set();
		
		text = new FlxBitmapFont(GameConstants.Font, 8, 8, FlxBitmapFont.TEXT_SET1, 16);
		text.x = FlxG.width / 2 - 48;
		text.y = FlxG.height / 4;
		text.text = " ~ PAUSED! ~ ";
		text.scrollFactor.set();
		
		capturesListText = new FlxBitmapFont(GameConstants.Font, 8, 8, FlxBitmapFont.TEXT_SET1, 16);
		var listText = "-CAPTURES-\n";
		for (capture in GameStatusManager.getCaptures())
		{
			listText += "> " + capture + "\n";
		}
		capturesListText.setText(listText, true);
		capturesListText.x = 16;
		capturesListText.y = text.y + 16;
		capturesListText.scrollFactor.set();
		
		group.scrollFactor.set();
		
		group.add(bg);
		group.add(text);
		group.add(capturesListText);
		
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
		
		super.close();
	}
	
	override public function update()
	{
		GamePad.handlePadState();
		
		if (GamePad.justReleased(GamePad.Start))
		{
			FlxTween.tween(group, {y: FlxG.height}, 0.5, { ease: FlxEase.bounceOut, complete: function(_t:FlxTween) {
				close();
			}});
		}
	
		super.update();
	}
}
