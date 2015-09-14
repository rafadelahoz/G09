package text;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxTimer;

/**
 * @author Simon Zeni (Bl4ckb0ne)
 */

class TextBox extends FlxGroup
{
	private var _background:FlxSprite;
	private var _isVisible:Bool;
	private var _name:FlxText;
	private var _typetext:TypeWriter;
	private var _isTalking:Bool;
	private var _skip:FlxText;
	private var _doublePress:Bool;
	
	public static function Message(name : String, message : String)
	{
		var dialog : TextBox = new TextBox(name);		
		dialog.talk(message);
		PlayFlowManager.get().group.add(dialog);
	}

	override public function new(NAME:String):Void
	{
		super();

		// Initialize the background image, you can use a simple FlxSprite fill with one color
		// _background = new FlxSprite(0, FlxG.height - 128, "assets/images/textbox.png");
		_background = new FlxSprite(8, 8).makeGraphic(Std.int(FlxG.width - 16), Std.int(FlxG.height / 2 - 16), 0xFF010101);
		_background.scrollFactor.set(0, 0);
		
	 	// The name of the person who talk, from the arguments
	 	_name = new FlxText(8 , _background.y, 136, NAME, 8);
	 	_name.color = 0xffbcbcbc;	

	 	// The skip text, you can change the key
	 	_skip = new FlxText(FlxG.width - 132, _background.y + _background.height - 24, 132, ">", 8);
	 	_skip.color = 0xffbcbcbc;

	 	// Initialize all the bools for the TextBox system
		_isVisible = false;
		_isTalking = false;
	 	_doublePress = false;
	}

	public function show():Void
	{
		add(_background);
		add(_name);
		add(_skip);
		_isVisible = true;
		
		PlayFlowManager.get().doPause();
	}

	public function hide():Void	
	{
		remove(_background);
		remove(_name);
		remove(_typetext);
		remove(_skip);
		_isVisible = false;
		
		PlayFlowManager.get().doUnpause();
	}

	public function talk(TEXT:String):Void
	{	
		if(!_isTalking) {
			_isTalking = true;
			show();

			// Set up a new TypeWriter for each text
			_typetext = new TypeWriter(Std.int(_background.x + 8), Std.int(_background.y + 8), 
									Std.int(_background.width - 16), TEXT, 8, Std.int(_background.height - 16));

			_typetext.scrollFactor.set();
			
			// All the arguments, go see http://api.haxeflixel.com/flixel/addons/text/TypeWriter.html to more explanations
		 	_typetext.delay = 0.1;
			_typetext.eraseDelay = 0.2;
			// _typetext.showCursor = true;
			// _typetext.cursorBlinkSpeed = 1.0;
			// _typetext.setTypingVariation(0.75, true);
			_typetext.useDefaultSound = true;
			_typetext.color = 0xffdedede; 
			// _typetext.skipKeys = ["A"];

			// Add it to the screen and start it
			add(_typetext);
			_typetext.start(0.02);

			// Backup timer to clear the text after 20 seconds
			// new FlxTimer(20, quitTalk);
		}
	}

	public function quitTalk(TIMER:FlxTimer = null):Void 
	{
		// Condition if we use the function as a callback for the timer
		if(TIMER != null)
			TIMER.cancel();

		hide();	
	 	_isTalking = false;
	}

	override public function destroy():Void
	{
		super.destroy();
	}

	override public function update():Void
	{
		super.update();	

		/* Double press the key A to quit the textbox
		 * First to activate the bool _doublePress and skip the typetext
		 * Second to activate quitTalk and set _doublePress to false
		 */
		/*if(FlxG.keys.justReleased.A && _doublePress) {
			quitTalk();
			_doublePress = false;
		} else if(FlxG.keys.justReleased.A) {
			_doublePress = true;
		}*/
	}	
}