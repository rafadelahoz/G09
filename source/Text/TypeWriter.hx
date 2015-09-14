package text;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.system.FlxSound;
import flixel.util.FlxRandom;

/**
 * This is loosely based on the TypeText class by Noel Berry, who wrote it for his Ludum Dare 22 game - Abandoned
 * http://www.ludumdare.com/compo/ludum-dare-22/?action=preview&uid=1527
 * @author Noel Berry
 */
class TypeWriter extends FlxText
{
	/**
	 * The delay between each character, in seconds.
	 */
	public var delay:Float = 0.05;
	
	/**
	 * The delay between each character erasure, in seconds.
	 */
	public var eraseDelay:Float = 0.02;
	
	/**
	 * Set to true to show a blinking cursor at the end of the text.
	 */
	public var showCursor:Bool = false;
	
	/**
	 * The character to blink at the end of the text.
	 */
	public var cursorCharacter:String = "|";
	
	/**
	 * The speed at which the cursor should blink, if shown at all.
	 */
	public var cursorBlinkSpeed:Float = 0.5;
	
	/**
	 * Text to add at the beginning, without animating.
	 */
	public var prefix:String = "";
	
	/**
	 * Whether or not to erase this message when it is complete.
	 */
	public var autoErase:Bool = false;
	
	/**
	 * How long to pause after finishing the text before erasing it. Only used if autoErase is true.
	 */
	public var waitTime:Float = 1.0;
	
	/**
	 * Whether or not to animate the text. Set to false by start() and erase().
	 */
	public var paused:Bool = false;
	
	/**
	 * If this is set to true, this class will use typetext.wav from flixel-addons for the type sound unless you specify another.
	 */
	public var useDefaultSound:Bool = false;
	
	/**
	 * The sound that is played when letters are added; optional.
	 */
	public var sound:FlxSound;
	
	/**
	 * An array of keys as string values (e.g. "SPACE", "L") that will advance the text.
	 */
	public var skipKeys:Array<String>;
	
	/**
	 * The text that will ultimately be displayed.
	 */
	private var _finalText:String = "";
	
	/**
	 * This function is called when the message is done typing.
	 */
	private var _onComplete:Dynamic = null;
	
	/**
	 * Optional parameters that will be passed to the _onComplete function.
	 */
	private var _onCompleteParams:Array<Dynamic>;
	
	/**
	 * This function is called when the message is done erasing, if that is enabled.
	 */
	private var _onErase:Dynamic = null;
	
	/**
	 * Optional parameters that will be passed to the _onErase function.
	 */
	private var _onEraseParams:Array<Dynamic>;
	
	/**
	 * This is incremented every frame by FlxG.elapsed, and when greater than delay, adds the next letter.
	 */
	private var _timer:Float = 0.0;
	
	/**
	 * A timer that is used while waiting between typing and erasing.
	 */
	private var _waitTimer:Float = 0.0;
	
	/**
	 * Internal tracker for current string length, not counting the prefix.
	 */
	private var _length:Int = 0;
	
	/**
	 * Whether or not to type the text. Set to true by start() and false by pause().
	 */
	private var _typing:Bool = false;
	
	/**
	 * Whether or not to erase the text. Set to true by erase() and false by pause().
	 */
	private var _erasing:Bool = false;
	
	/**
	 * Whether or not we're waiting between the type and erase phases.
	 */
	private var _waiting:Bool = false;
	
	/**
	 * Internal tracker for cursor blink time.
	 */
	private var _cursorTimer:Float = 0.0;
	
	/**
	 * Whether or not to add a "natural" uneven rhythm to the typing speed.
	 */
	private var _typingVariation:Bool = false;
	
	/**
	 * How much to vary typing speed, as a percent. So, at 0.5, each letter will be "typed" up to 50% sooner or later than the delay variable is set.
	 */
	private var _typeVarPercent:Float = 0.5;
	
	/**
	 * Helper string to reduce garbage generation.
	 */
	private static var helperString:String = "";
	
	private var finished : Bool;
	
	private static var lineHeight : Int = 10;
	
	private var targetHeight : Int;
	
	private var remainingText : String;
	
	/**
	 * Create a FlxTypeText object, which is very similar to FlxText except that the text is initially hidden and can be
	 * animated one character at a time by calling start().
	 * 
	 * @param	X				The X position for this object.
	 * @param	Y				The Y position for this object.
	 * @param	Width			The width of this object. Text wraps automatically.
	 * @param	Text			The text that will ultimately be displayed.
	 * @param	Size			The size of the text.
	 * @param	EmbeddedFont	Whether this text field uses embedded fonts or not.
	 */
	public function new(X:Float, Y:Float, Width:Int, Text:String, Size:Int = 8, TargetHeight : Int = -1, EmbeddedFont:Bool = true)
	{
		super(X, Y, Width, "", Size, EmbeddedFont);
		_finalText = Text;
		
		lineHeight = Size;
		targetHeight = TargetHeight;
		
		_onComplete = null;
		_onErase = null;
		_onCompleteParams = [];
		_onEraseParams = [];
		skipKeys = [];
	}
	
	/**
	 * Set a function to be called when typing the message is complete.
	 * 
	 * @param	Callback	The callback function.
	 * @param	Params		Any params you want to pass to the function. Optional!
	 */
	public function setCompleteCallback(Callback:Dynamic, ?Params:Array<Dynamic>):Void
	{
		_onComplete = Callback;
		
		if (Params == null)
		{
			Params = [];
		}
		
		_onCompleteParams = Params;
	}
	
	/**
	 * Set a function to be called when erasing is complete.
	 * Make sure to set erase = true or else this will never be called!
	 * 
	 * @param	Callback		The callback function.
	 * @param	Params			Any params you want to pass to the function. Optional!
	 */
	public function setEraseCallback(Callback:Dynamic, ?Params:Array<Dynamic>):Void
	{
		_onErase = Callback;
		
		if (Params == null)
		{
			Params = [];
		}
		
		_onEraseParams = Params;
	}
	
	/**
	 * Start the text animation.
	 * 
	 * @param	Delay			Optionally, set the delay between characters. Can also be set separately.
	 * @param	ForceRestart	Whether or not to start this animation over if currently animating; false by default.
	 * @param	AutoErase		Whether or not to begin the erase animation when the typing animation is complete. Can also be set separately.
	 * @param	Sound			A FlxSound object to play when a character is typed. Can also be set separately.
	 * @param	SkipKeys		An array of keys as string values (e.g. "SPACE", "L") that will advance the text. Can also be set separately.
	 * @param	Callback		An optional callback function, to be called when the typing animation is complete.
	 * @param 	Params			Optional parameters to pass to the callback function.
	 */
	public function start(?Delay:Float, ForceRestart:Bool = false, AutoErase:Bool = false, ?Sound:FlxSound, ?SkipKeys:Array<String>, ?Callback:Dynamic, ?Params:Array<Dynamic>):Void
	{
		if (Delay != null)
		{
			delay = Delay;
		}
		
		_typing = true;
		_erasing = false;
		paused = false;
		_waiting = false;
		
		if (ForceRestart)
		{
			text = "";
			_length = 0;
		}
		
		autoErase = AutoErase;
		
		/*#if !FLX_NO_SOUND_SYSTEM
		if (Sound != null)
		{
			sound = Sound;
		}
		else if (useDefaultSound)
		{
			sound = FlxG.sound.load(new TypeSound());
		}
		#end*/
		
		if (SkipKeys != null)
		{
			skipKeys = SkipKeys;
		}
		
		if (Callback != null)
		{
			_onComplete = Callback;
		}
		
		if (Params != null)
		{
			_onCompleteParams = Params;
		}
		
		remainingText = null;
		finished = false;
	}
	
	/**
	 * Begin an animated erase of this text.
	 * 
	 * @param	Delay			Optionally, set the delay between characters. Can also be set separately.
	 * @param	ForceRestart	Whether or not to start this animation over if currently animating; false by default.
	 * @param	Sound			A FlxSound object to play when a character is typed. Can also be set separately.
	 * @param	SkipKeys		An array of keys as string values (e.g. "SPACE", "L") that will advance the text. Can also be set separately.
	 * @param	Callback		An optional callback function, to be called when the erasing animation is complete.
	 * @param	Params			Optional parameters to pass to the callback function.
	 */
	public function erase(?Delay:Float, ForceRestart:Bool = false, ?Sound:FlxSound, ?SkipKeys:Array<String>, ?Callback:Dynamic, ?Params:Array<Dynamic>):Void
	{
		_erasing = true;
		_typing = false;
		paused = false;
		_waiting = false;
		
		if (Delay != null)
		{
			eraseDelay = Delay;
		}
		
		if (ForceRestart)
		{
			_length = _finalText.length;
			text = _finalText;
		}
		
		/*#if !FLX_NO_SOUND_SYSTEM
		if (Sound != null)
		{
			sound = Sound;
		}
		else if (useDefaultSound)
		{
			sound = FlxG.sound.load(new TypeSound());
		}
		#end*/
		
		if (SkipKeys != null)
		{
			skipKeys = SkipKeys;
		}
		
		if (Callback != null)
		{
			_onErase = Callback;
		}
		
		if (Params != null)
		{
			_onEraseParams = Params;
		}
	}
	
	/**
	 * Reset the text with a new text string. Automatically cancels typing, and erasing.
	 * 
	 * @param	Text	The text that will ultimately be displayed.
	 */
	public function resetText(Text:String):Void
	{
		text = "";
		_finalText = Text;
		_typing = false;
		_erasing = false;
		paused = false;
		_waiting = false;
		finished = false;
		remainingText = null;
	}
	
	/**
	 * Define the keys that can be used to advance text.
	 * 
	 * @param	Keys	An array of keys as string values (e.g. "SPACE", "L") that will advance the text.
	 */
	public function setSkipKeys(Keys:Array<String>):Void
	{
		skipKeys = Keys;
	}
	
	/**
	 * Set a sound that will be played each time a letter is added to the text.
	 * 
	 * @param	Sound	A FlxSound object.
	 */
	public function setSound(Sound:FlxSound):Void
	{
		sound = Sound;
	}
	
	/**
	 * If called with On set to true, a random variation will be added to the rate of typing.
	 * Especially with sound enabled, this can give a more "natural" feel to the typing.
	 * Much more noticable with longer text delays.
	 * 
	 * @param	Amount		How much variation to add, as a percentage of delay (0.5 = 50% is the maximum amount that will be added or subtracted from the delay variable). Only valid if >0 and <1.
	 * @param	On			Whether or not to add the random variation. True by default.
	 */
	public function setTypingVariation(Amount:Float = 0.5, On:Bool = true):Void
	{
		_typingVariation = On;
		
		if (Amount > 0 && Amount < 1)
		{
			_typeVarPercent = Amount;
		}
		else
		{
			_typeVarPercent = 0.5;
		}
	}
	
	/**
	 * Internal function that is called when typing is complete.
	 */
	private function onComplete():Void
	{
		trace("onComplete");
		_timer = 0;
		_typing = false;
	
		if (_onComplete != null)
		{
			Reflect.callMethod(null, _onComplete, _onCompleteParams);
		}
		
		if (autoErase && waitTime <= 0)
		{
			_erasing = true;
		}
		else if (autoErase)
		{
			_waitTimer = waitTime;
			_waiting = true;
		}
	}
	
	private function onErased():Void
	{
		_timer = 0;
		_erasing = false;
		
		if (_onErase != null)
		{
			Reflect.callMethod(null, _onErase, _onEraseParams);
		}
	}
	
	override public function update():Void
	{
		// If the skip key was pressed, complete the animation.
		
		/*#if !FLX_NO_KEYBOARD
		if (skipKeys != null && skipKeys.length > 0 && FlxG.keys.anyJustPressed(skipKeys))
		{
			skip();
		}
		#end*/
		
		// When the message has finished, wait for the user to 
		// press a key before closing or continuing with the text
		if (finished)
		{
			if (FlxG.keys.justReleased.A)
			{
				finished = false;
				// If there is more text, we have not finished
				if (remainingText != null)
				{				
					resetText(remainingText);
					trace("Resetted");	
					start(delay, true);
					trace("Started");
				}
				// If there is no more text, we are done
				else if (_typing)
				{
					onComplete();
				}
				// Or maybe we were erasing and we are done
				else if (_erasing)
				{
					onErased();
				}
			}
			else
				return;
		}
		
		if (_waiting && !paused)
		{
			_waitTimer -= FlxG.elapsed;
			
			if (_waitTimer <= 0)
			{
				_waiting = false;
				_erasing = true;
			}
		}
		
		// So long as we should be animating, increment the timer by time elapsed.
		
		if (!_waiting && !paused)
		{
			if (_length < _finalText.length && _typing)
			{
				_timer += FlxG.elapsed;
			}
			
			if (_length > 0 && _erasing)
			{
				_timer += FlxG.elapsed;
			}
		}
		
		// If the timer value is higher than the rate at which we should be changing letters, increase or decrease desired string length.
		
		if (_typing || _erasing)
		{
			if (_typing && _timer >= delay)
			{
				_length ++;
			}
			
			if (_erasing && _timer >= eraseDelay)
			{
				_length --;
			}
			
			if ((_typing && _timer >= delay) || (_erasing && _timer >= eraseDelay))
			{
				if (_typingVariation )
				{
					if (_typing)
					{
						_timer = FlxRandom.floatRanged( -delay * _typeVarPercent / 2, delay * _typeVarPercent / 2);
					}
					else
					{
						_timer = FlxRandom.floatRanged( -eraseDelay * _typeVarPercent / 2, eraseDelay * _typeVarPercent / 2);
					}
				}
				else
				{
					_timer = 0;
				}
				
				/*#if !FLX_NO_SOUND_SYSTEM
				if (sound != null)
				{
					sound.play(true);
				}
				#end*/
			}
		}
		
		// Update the helper string with what could potentially be the new text.
		
		helperString = prefix + _finalText.substr(0, _length);
		
		// Append the cursor if needed.
		
		if (showCursor)
		{
			_cursorTimer += FlxG.elapsed;
			
			if (_cursorTimer > cursorBlinkSpeed / 2)
			{
				helperString += cursorCharacter.charAt(0);
			}
			
			if (_cursorTimer > cursorBlinkSpeed)
			{
				_cursorTimer = 0;
			}
		}
		
		// If the text changed, update it.
		
		if (helperString != text && !finished)
		{
			text = helperString;
			
			// Check if there is more space available for lines
			if (targetHeight > 0 && height + lineHeight > targetHeight && _length < _finalText.length)
			{
				finished = true;

				// Remove 1 character
				text = text.substring(0, text.length-1);
				
				// We have run out of space!
				remainingText = _finalText.substring(_length - 1);				
				
				trace("There is no more space for: \n" + remainingText);
			}
			else
			{
			
				// If we're done typing, call the onComplete() function
				
				if (_length >= _finalText.length && _typing && !_waiting && !_erasing)
				{
					finished = true;
					trace("finished typing");
				}
				
				// If we're done erasing, call the onErased() function
				
				if (_length == 0 && _erasing && !_typing && !_waiting)
				{
					finished = true;
					trace("finished erasing");
				}
			}
		}
		
		super.update();
	}
	
	/**
	 * Immediately finishes the animation. Called if any of the skipKeys is pressed.
	 * Handy for custom skipping behaviour (for example with different inputs like mouse or gamepad).
	 */
	/*public function skip():Void
	{
		if (_erasing || _waiting)
		{
			_length = 0;
			_waiting = false;
		}
		else if (_typing)
		{
			_length = _finalText.length;
		}
	}*/
}