package text;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.text.FlxBitmapTextField;
import flixel.text.pxText.PxBitmapFont;
import flixel.util.FlxTimer;

import openfl.Assets;

/**
 * @author Simon Zeni (Bl4ckb0ne)
 */

class TextBox extends FlxGroup
{
	var originX : Int = 8;
	var originY : Int = 10;
	
	var borderX : Int = 8;
	var borderY : Int = 8;
		
	var boxWidth : Int = Std.int(FlxG.width - 16);
	var boxHeight: Int = Std.int(FlxG.height / 2 - 16);
	
	private var _background:FlxSprite;
	private var _isVisible:Bool;
	private var _name:FlxText;
	private var _typetext:TypeWriter;
	private var _isTalking:Bool;
	private var _skip:FlxText;
	private var _doublePress:Bool;
	private var _callback:Dynamic;

	private static var textBox : TextBox;
	public static function Message(name : String, message : String, ?callback:Dynamic)
	{
		if (textBox == null) 
		{
			textBox = new TextBox(name);
			textBox.talk(message);
			PlayFlowManager.get().group.add(textBox);
		}
	}

	override public function new(NAME:String):Void
	{
		super();

		// var FontStr : String = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~\\";
		/*var FontStr : String =" !\"#$%&'()*+,-./" + "0123456789:;<=>?" + "@ABCDEFGHIJKLMNO" + "PQRSTUVWXYZ[]^_" + "abcdefghijklmno" + "pqrstuvwxyz{|}~\\";
		trace("Loading font");
		var what : Dynamic = Assets.getBitmapData("assets/images/font.png");
		trace("Got Bitmap data");
		var font : PxBitmapFont = new PxBitmapFont().loadPixelizer(what, FontStr);*/
		
		// Initialize the background image, you can use a simple FlxSprite fill with one color
		_background = new FlxSprite(originX, originY).makeGraphic(boxWidth, boxHeight, 0xFF010101);
		_background.scrollFactor.set(0, 0);
		
	 	// The name of the person who talk, from the arguments
	 	/*_name = new FlxText(originX, originY, NAME, 8);
	 	_name.color = 0xffbcbcbc;	
		_name.scrollFactor.set(0, 0);*/

	 	// The skip text, you can change the key
	 	_skip = new FlxText(originX + boxWidth - 8, originY + boxHeight - 8, 8, ">", 8);
	 	_skip.color = 0xffbcbcbc;
		_skip.scrollFactor.set(0, 0);

	 	// Initialize all the bools for the TextBox system
		_isVisible = false;
		_isTalking = false;
	 	_doublePress = false;
	}

	public function show():Void
	{
		/*add(_background);
		// add(_name);
		add(_skip);*/
		
				
		var textBytes = Assets.getText("assets/fonts/16bfzx.fnt");
		var XMLData = Xml.parse(textBytes);
		var font:PxBitmapFont = new PxBitmapFont().loadAngelCode(Assets.getBitmapData("assets/fonts/16bfzx.png"), XMLData);
		
		var text : FlxBitmapTextField = new FlxBitmapTextField(font);
		text.x = originX;
		text.y = originY;
		text.text = "The name is 123546?._!";
		text.color = 0xffffff;
		text.fixedWidth = false;
		text.multiLine = true;
		text.lineSpacing = 5;
		text.padding = 5;
		text.scale.x = 5;
		text.scrollFactor.set(0, 0);
		trace(text);
		add(text);
		
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

		PlayFlowManager.get().group.remove(textBox);
		textBox.destroy();
		textBox = null;
		
		PlayFlowManager.get().doUnpause();
	}

	public function talk(TEXT:String):Void
	{	
		if(!_isTalking) {
			_isTalking = true;
			show();

			// Set up a new TypeWriter for each text
			_typetext = new TypeWriter(originX + borderX, 
									   originY + borderY, 
									   boxWidth - borderX*2, 
									   TEXT, 8, boxHeight - borderY*2);

			_typetext.scrollFactor.set();
			
			// All the arguments, go see http://api.haxeflixel.com/flixel/addons/text/TypeWriter.html to more explanations
		 	_typetext.delay = 0.1;
			_typetext.eraseDelay = 0.2;
			// _typetext.showCursor = true;
			// _typetext.cursorBlinkSpeed = 1.0;
			_typetext.setTypingVariation(0.75, true);
			_typetext.useDefaultSound = true;
			_typetext.color = 0xffdedede; 
			// _typetext.skipKeys = ["A"];

			// Add it to the screen and start it
			add(_typetext);
			_typetext.start(0.02, onCompleted);

			// Backup timer to clear the text after 20 seconds
			// new FlxTimer(20, quitTalk);
		}
	}

	public function onCompleted(TIMER:FlxTimer = null):Void 
	{
		// Condition if we use the function as a callback for the timer
		if(TIMER != null)
			TIMER.cancel();

		hide();	
	 	_isTalking = false;

	 	if (_callback != null)
	 		_callback();
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