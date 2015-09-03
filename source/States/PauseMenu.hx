package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxRandom;


class PauseMenu extends FlxSubState
{
	var text : FlxText;
	
	public function new()
	{
		super(0x00000000);
		
		var bg : FlxSprite = new FlxSprite(FlxG.width / 2 - 40, FlxG.height / 4 - 2).makeGraphic(80, 32, 0x99000000);
		text = new FlxText(FlxG.width / 2 - 32, FlxG.height / 4, 64, 		" ~ PAUSED! ~ ", 8);
		
		bg.scrollFactor.set();
		text.scrollFactor.set();
		
		add(bg);
		add(text);
		
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
		
		text.color = FlxRandom.color();
	
		if (GamePad.justReleased(GamePad.Start))
		{
			close();
		}
	
		super.update();
	}
}