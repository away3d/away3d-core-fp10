/*
VERSION: 10.11
DATE: 2/25/2009
ACTIONSCRIPT VERSION: 3.0 (AS2 version is also available)
UPDATES & MORE DETAILED DOCUMENTATION AT: http://www.TweenMax.com 
DESCRIPTION:
	TweenMax extends the extremely lightweight, FAST TweenLite engine, adding many useful features
	like pause/resume, timeScale, event listeners, reverse(), restart(), setDestination(), yoyo, loop, 
	rounding, and the ability to jump to any point in the tween using the "progress" property. It also 
	activates many extra plugins by default, making it extremely full-featured. Since TweenMax extends 
	TweenLite, it can do ANYTHING TweenLite can do plus much more. Same syntax. There are plenty of other 
	tweening engines out there to choose from, so here's why you might want to consider TweenMax:
	
		- SPEED - I'm not aware of any popular tweening engine with a similar feature set that's as fast
		  as TweenMax. See some speed comparisons yourself at http://blog.greensock.com/tweening-speed-test/
		  
		- Feature set - In addition to tweening ANY numeric property of ANY object, TweenMax can tween filters, 
		  hex colors, volume, tint, frames, saturation, contrast, hue, colorization, brightness, and even do 
		  bezier tweening, orientToBezier, pause/resume, reverse(), restart(), round values, jump to any point 
		  in the tween with the "progress" property, automatically rotate in the shortest direction, plus LOTS more. 
		  Overwrite management is an important consideration for a tweening engine as well which is another area 
		  where the GreenSock tweening platform shines. You have options for AUTO overwriting or you can manually 
		  define how each tween will handle overlapping tweens of the same object.
		  
		- Expandability - With its new plugin architecture, you can activate as many (or as few) features as your 
		  project requires. Or write your own plugin if you need a feature that's unavailable. Minimize bloat and
		  maximize performance.
		  
		- Management features - TweenGroup makes it surprisingly simple to create complex sequences and groups
		  of TweenLite/Max tweens that you can pause(), resume(), restart(), or reverse(). You can even tween 
		  a TweenGroup's progress property to fastforward or rewind the entire group/sequence. 
		  
		- Ease of use - Designers and Developers alike rave about how intuitive the GreenSock tweening platform is.
		
		- Updates - Frequent updates and feature additions make the GreenSock tweening platform reliable and robust.
		
		- AS2 and AS3 - Most other engines are only developed for AS2 or AS3 but not both.
	

PARAMETERS:
	1) $target : Object - Target object whose properties we're tweening
	2) $duration : Number - Duration (in seconds) of the tween
	3) $vars : Object - An object containing the end values of all the properties you'd like tweened (or if you're using 
	         			TweenMax.from(), these variables would define the BEGINNING values). For example, to tween
	         			myClip's alpha to 0.5 over the course of 1 second, you'd do: TweenMax.to(myClip, 1, {alpha:0.5}).
	         			
SPECIAL PROPERTIES (no plugins required):
	Any of the following special properties can optionally be passed in through the $vars object (the third parameter):

	delay : Number - Amount of delay before the tween should begin (in seconds).
	ease : Function - Use any standard easing equation to control the rate of change. For example, 
					  gs.easing.Elastic.easeOut. The Default is Regular.easeOut.
	easeParams : Array - An Array of extra parameters to feed the easing equation. This can be useful when 
						 using an ease like Elastic and want to control extra parameters like the amplitude and period.
						 Most easing equations, however, don't require extra parameters so you won't need to pass in any easeParams.
	onStart : Function - If you'd like to call a function as soon as the tween begins, reference it here.
	onStartParams : Array - An Array of parameters to pass the onStart function.
	onUpdate : Function - If you'd like to call a function every time the property values are updated (on every frame during
						  the course of the tween), reference it here.
	onUpdateParams : Array - An Array of parameters to pass the onUpdate function
	onComplete : Function - If you'd like to call a function when the tween has finished, reference it here. 
	onCompleteParams : Array - An Array of parameters to pass the onComplete function
	persist : Boolean - if true, the TweenMax instance will NOT automatically be removed by the garbage collector when it is complete.
  					    However, it is still eligible to be overwritten by new tweens even if persist is true. By default, it is false.
	renderOnStart : Boolean - If you're using TweenMax.from() with a delay and want to prevent the tween from rendering until it
							  actually begins, set this to true. By default, it's false which causes TweenMax.from() to render
							  its values immediately, even before the delay has expired.
	overwrite : int - Controls how other tweens of the same object are handled when this tween is created. Here are the options:
  					- 0 (NONE): No tweens are overwritten. This is the fastest mode, but you need to be careful not to create any 
  								tweens with overlapping properties, otherwise they'll conflict with each other. 
								
					- 1 (ALL): (this is the default unless OverwriteManager.init() has been called) All tweens of the same object 
							   are completely overwritten immediately when the tween is created. 
							   		TweenMax.to(mc, 1, {x:100, y:200});
									TweenMax.to(mc, 1, {x:300, delay:2, overwrite:1}); //immediately overwrites the previous tween
									
					- 2 (AUTO): (used by default if OverwriteManager.init() has been called) Searches for and overwrites only 
								individual overlapping properties in tweens that are active when the tween begins. 
									TweenMax.to(mc, 1, {x:100, y:200});
									TweenMax.to(mc, 1, {x:300, overwrite:2}); //only overwrites the "x" property in the previous tween
									
					- 3 (CONCURRENT): Overwrites all tweens of the same object that are active when the tween begins.
									  TweenMax.to(mc, 1, {x:100, y:200});
									  TweenMax.to(mc, 1, {x:300, delay:2, overwrite:3}); //does NOT overwrite the previous tween because the first tween will have finished by the time this one begins.
	onStartListener : Function - A function to which the TweenMax instance should dispatch a TweenEvent when it begins.
	  							   This is the same as doing myTweenMaxInstance.addEventListener(TweenEvent.START, myFunction);
	
	onUpdateListener : Function - A function to which the TweenMax instance should dispatch a TweenEvent every time it updates values.
	  							   This is the same as doing myTweenMaxInstance.addEventListener(TweenEvent.UPDATE, myFunction);
	  
	onCompleteListener : Function - A function to which the TweenMax instance should dispatch a TweenEvent when it completes.
	  							   	  This is the same as doing myTweenMaxInstance.addEventListener(TweenEvent.COMPLETE, myFunction);
	  							   	  
	yoyo : Number - To make the tween reverse when it completes (like a yoyo) any number of times, set this to the number of cycles 
	  				  you'd like the tween to yoyo. A value of zero causes the tween to yoyo endlessly.
	  				  
	loop : Number - To make the tween repeat when it completes any number of times, set this to the number of cycles 
	  				  you'd like the tween to loop. A value of zero causes the tween to loop endlessly.
	  				  
	timeScale : Number - Multiplier that controls the speed of the tween (perceived duration) where 1 = normal speed, 0.5 = half speed, 2 = double speed, etc. 
	  					   NOTE: There is also a static TweenMax.globalTimeScale property that affects ALL TweenMax and TweenFilterLite tweens (not TweenLite though)
	
	startAt : Object - Allows you to define the starting values for each property. Typically, TweenMax uses the current
					   value (whatever it happens to be at the time the tween begins) as the start value, but startAt
					   allows you to override that behavior. Simply pass an object in with whatever properties you'd like
					   to set just before the tween begins. For example, if mc.x is currently 100, and you'd like to 
					   tween it from 0 to 500, do TweenMax.to(mc, 2, {x:500, startAt:{x:0}});


PLUGINS:
	There are many plugins that add capabilities through other special properties. Adding the capabilities 
	is as simple as activating the plugin with a single line of code, like SetSizePlugin.activate();
	Get information about all the plugins at http://blog.greensock.com/plugins/
	The following plugins are activated by default in TweenMax (you can easily prevent them from activating, 
	thus saving file size, by commenting out the associated activation lines of code in the constructor):
	
	  autoAlpha : Number - Use it instead of the alpha property to gain the additional feature of toggling 
						   the visible property to false when alpha reaches 0. It will also toggle visible 
						   to true before the tween starts if the value of autoAlpha is greater than zero.
						   
	  visible : Boolean - To set a DisplayObject's "visible" property at the end of the tween, use this special property.
	  
	  volume : Number - Tweens the volume of an object with a soundTransform property (MovieClip/SoundChannel/NetStream, etc.)
	  
	  tint : Number - To change a DisplayObject's tint/color, set this to the hex value of the tint you'd like
					  to end up at(or begin at if you're using TweenMax.from()). An example hex value would be 0xFF0000.
					  
	  removeTint : Boolean - If you'd like to remove the tint that's applied to a DisplayObject, pass true for this special property.
	  
	  frame : Number - Use this to tween a MovieClip to a particular frame.
	  
	  bezier : Array - Bezier tweening allows you to tween in a non-linear way. For example, you may want to tween
					   a MovieClip's position from the origin (0,0) 500 pixels to the right (500,0) but curve downwards
					   through the middle of the tween. Simply pass as many objects in the bezier array as you'd like, 
					   one for each "control point" (see documentation on Flash's curveTo() drawing method for more
					   about how control points work). In this example, let's say the control point would be at x/y coordinates
					   250,50. Just make sure your my_mc is at coordinates 0,0 and then do: 
					   TweenMax.to(my_mc, 3, {_x:500, _y:0, bezier:[{_x:250, _y:50}]});
					   
	  bezierThrough : Array - Identical to bezier except that instead of passing bezier control point values, you
							  pass points through which the bezier values should move. This can be more intuitive
							  than using control points.
							  
	  orientToBezier : Array (or Boolean) - A common effect that designers/developers want is for a MovieClip/Sprite to 
	  						orient itself in the direction of a Bezier path (alter its rotation). orientToBezier
							makes it easy. In order to alter a rotation property accurately, TweenMax needs 4 pieces
							of information: 
								1) Position property 1 (typically "x")
								2) Position property 2 (typically "y")
								3) Rotational property (typically "rotation")
								4) Number of degrees to add (optional - makes it easy to orient your MovieClip properly)
							The orientToBezier property should be an Array containing one Array for each set of these values. 
							For maximum flexibility, you can pass in any number of arrays inside the container array, one 
							for each rotational property. This can be convenient when working in 3D because you can rotate
							on multiple axis. If you're doing a standard 2D x/y tween on a bezier, you can simply pass 
							in a boolean value of true and TweenMax will use a typical setup, [["x", "y", "rotation", 0]]. 
							Hint: Don't forget the container Array (notice the double outer brackets)
							
	  hexColors : Object - Although hex colors are technically numbers, if you try to tween them conventionally,
				 you'll notice that they don't tween smoothly. To tween them properly, the red, green, and 
				 blue components must be extracted and tweened independently. TweenMax makes it easy. To tween
				 a property of your object that's a hex color to another hex color, use this special hexColors 
				 property of TweenMax. It must be an OBJECT with properties named the same as your object's 
				 hex color properties. For example, if your my_obj object has a "myHexColor" property that you'd like
				 to tween to red (0xFF0000) over the course of 2 seconds, do: 
				 TweenMax.to(my_obj, 2, {hexColors:{myHexColor:0xFF0000}});
				 You can pass in any number of hexColor properties.
				 
	  shortRotation : Number - To tween the rotation property of the target object in the shortest direction, use "shortRotation" 
	  						   instead of "rotation" as the property. For example, if myObject.rotation is currently 170 degrees 
	  						   and you want to tween it to -170 degrees, a normal rotation tween would travel a total of 340 degrees 
	  						   in the counter-clockwise direction, but if you use shortRotation, it would travel 20 degrees in the 
	  						   clockwise direction instead.
	  					   
	  roundProps : Array - If you'd like the inbetween values in a tween to always get rounded to the nearest integer, use the roundProps
	  					   special property. Just pass in an Array containing the property names that you'd like rounded. For example,
	  					   if you're tweening the x, y, and alpha properties of mc and you want to round the x and y values (not alpha)
	  					   every time the tween is rendered, you'd do: TweenMax.to(mc, 2, {x:300, y:200, alpha:0.5, roundProps:["x","y"]});
	  					   
	  blurFilter : Object - To apply a BlurFilter, pass an object with one or more of the following properties:
	  						blurX, blurY, quality
	  						
	  glowFilter : Object - To apply a GlowFilter, pass an object with one or more of the following properties:
	  						alpha, blurX, blurY, color, strength, quality, inner, knockout
	  						
	  colorMatrixFilter : Object - To apply a ColorMatrixFilter, pass an object with one or more of the following properties:
								   colorize, amount, contrast, brightness, saturation, hue, threshold, relative, matrix
								   
	  dropShadowFilter : Object - To apply a DropShadowFilter, pass an object with one or more of the following properties:
								  alpha, angle, blurX, blurY, color, distance, strength, quality
								  
	  bevelFilter : Object - To apply a BevelFilter, pass an object with one or more of the following properties:
							 angle, blurX, blurY, distance, highlightAlpha, highlightColor, shadowAlpha, shadowColor, strength, quality
					  
	
KEY PROPERTIES:
	- progress : Number (0 - 1 where 0 = tween hasn't progressed, 0.5 = tween is halfway done, and 1 = tween is finished)
	- timeScale : Number (Multiplier that controls the speed of the tween where 1 = normal speed, 0.5 = half speed, 2 = double speed, etc. )
	- paused : Boolean
	- reversed : Boolean
	
KEY METHODS:
	- TweenMax.to(target:Object, duration:Number, vars:Object):TweenMax
	- TweenMax.from(target:Object, duration:Number, vars:Object):TweenMax
	- TweenMax.getTweensOf(target:Object):Array
	- TweenMax.isTweening(target:Object):Boolean
	- TweenMax.getAllTweens():Array
	- TweenMax.killAllTweens(complete:Boolean):void
	- TweenMax.killAllDelayedCalls(complete:Boolean):void
	- TweenMax.pauseAll(tweens:Boolean, delayedCalls:Boolean):void
	- TweenMax.resumeAll(tweens:Boolean, delayedCalls:Boolean):void
	- TweenMax.delayedCall(delay:Number, function:Function, params:Array, persist:Boolean):TweenMax
	- TweenMax.setGlobalTimeScale(scale:Number):void
	- addEventListener(type:String, listener:Function, useCapture:Boolean, priority:int, useWeakReference:Boolean):void
	- removeEventListener(type:String, listener:Function):void
	- pause():void
	- resume():void
	- restart(includeDelay:Boolean):void
	- reverse(adjustStart:Boolean, forcePlay:Boolean):void
	- setDestination(property:String, value:*, adjustStartValues:Boolean):void
	- invalidate(adjustStartValues:Boolean):void
	- killProperties(names:Array):void
	
	
EXAMPLES: 
	
	To tween the clip_mc MovieClip over 5 seconds, changing the alpha to 0.5, the x to 120 using the Back.easeOut
	easing function, delay starting the whole tween by 2 seconds, and then call	a function named "onFinishTween" when 
	it has completed and pass in a few parameters to that function (a value of 5 and a reference to the clip_mc), 
	you'd do so like:
		
		import gs.*;
		import gs.easing.*;
		TweenMax.to(clip_mc, 5, {alpha:0.5, x:120, ease:Back.easeOut, delay:2, onComplete:onFinishTween, onCompleteParams:[5, clip_mc]});
		function onFinishTween(argument1:Number, argument2:MovieClip):void {
			trace("The tween has finished! argument1 = " + argument1 + ", and argument2 = " + argument2);
		}
	
	If you have a MovieClip on the stage that is already in it's end position and you just want to animate it into 
	place over 5 seconds (drop it into place by changing its y property to 100 pixels higher on the screen and 
	dropping it from there), you could:
		
		import gs.*;
		import gs.easing.*;
		TweenMax.from(clip_mc, 5, {y:"-100", ease:Elastic.easeOut});
		
	To set up an onUpdate listener (not callback) that traces the "progress" property of a tween, and another listener
	that gets called when the tween completes, you could do:
	
		import gs.*;
		import gs.events.TweenEvent;
		
		TweenMax.to(clip_mc, 2, {x:200, onUpdateListener:reportProgress, onCompleteListener:tweenFinished});
		function reportProgress($e:TweenEvent):void {
			trace("tween progress: " + $e.target.progress);
		}
		function tweenFinished($e:TweenEvent):void {
			trace("tween finished!");
		}
	

NOTES / HINTS:

	- Passing values as Strings will make the tween relative to the current value. For example, if you do
	  TweenMax.to(mc, 2, {x:"-20"}); it'll move the mc.x to the left 20 pixels which is the same as doing
	  TweenMax.to(mc, 2, {x:mc.x - 20}); You could also cast it like: TweenMax.to(mc, 2, {x:String(myVariable)});
	  
	- If you prefer, instead of using the onCompleteListener, onStartListener, and onUpdateListener special properties, 
	  you can set up listeners the typical way, like: 
	  var myTween:TweenMax = new TweenMax(my_mc, 2, {x:200});
	  myTween.addEventListener(TweenEvent.COMPLETE, myFunction);
	  
	- To tween an Array, just pass in an Array as a property named endArray like:
	  var myArray:Array = [1,2,3,4];
	  TweenMax.to(myArray, 1.5, {endArray:[10,20,30,40]});
	  
	- You can kill all tweens of a particular object anytime with the TweenMax.killTweensOf(myObject); 
	  function. If you want to have the tweens forced to completion, pass true as the second parameter, 
	  like TweenMax.killTweensOf(myObject, true);
	  
	- You can kill all delayedCalls to a particular function using TweenMax.killDelayedCallsTo(myFunction);
	  This can be helpful if you want to preempt a call.
	  
	- Use the TweenMax.from() method to animate things into place. For example, if you have things set up on 
	  the stage in the spot where they should end up, and you just want to animate them into place, you can 
	  pass in the beginning x and/or y and/or alpha (or whatever properties you want).
	  
	- If you find this class useful, please consider joining Club GreenSock which not only contributes
	  to ongoing development, but also gets you bonus classes (and other benefits) that are ONLY available 
	  to members. Learn more at http://blog.greensock.com/club/
	  
	  
CHANGE LOG:
	10.11:
		- Fixed bug in setDestination() when adjustStartValues was false
		- Fixed bug in startAt that caused it to wait one frame when the delay was zero.
	10.1:
		- Fixed bug that caused error when "omit trace actions" was selected in publish settings.
	10.09:
		- Fixed bug with timeScale
	10.08:
		- Fixed bug in setDestination()
		- Fixed bug in SetSizePlugin
		- Fixed bug in isTweening() which didn't report true immediately after a tween was created.
	10.07:
		- Fixed reporting of "paused" property being reversed
	10.06:
		- Added "startAt" special property for defining starting values.
		- Speed improvements
		- Integrated a new gs.utils.tween.TweenInfo class
		- Minor internal changes
	10.0:
		- Major update, shifting to a "plugin" architecture for handling special properties. 
		- Eliminated TweenFilterLite and extended TweenLite instead
		- Added "remove" property to all filter tweens to accommodate removing the filter at the end of the tween
		- Added "setSize" and "frameLabel" plugins
		- Speed enhancements
		- Fixed minor overwrite bugs
		- Updated the version to sync better with TweenLite (jumped from 3.6 to 10.0)
	3.6:
		- Added compatibility with TweenProxy and TweenProxy3D
		- Fixed bug with adding event listeners via TweenMaxVars
	3.52:
		- Adjusted how the timeScale special property is handled internally. It should be more flexible and slightly faster now.
		- Changed the way parseBeziers() stores values to make bezier tweening faster (Arrays instead of Objects with named properties)
	3.51:
		- Fixed problem that caused killAllTweens() to not fully kill paused tweens
	3.5:
		- Changed yoyo and loop behavior so that instead of being Boolean values that loop or yoyo endlessly, they're numbers so that you can define a specific number of cycles you'd like the tween to loop or yoyo. Zero causes the loop or yoyo to repeat endlessly.
	3.41:
		- Fixed conflict between TweenMaxVars and the new shortRotation property in Flash Player 10
	3.4:
		- Added "shortRotation" special property
		- Minor speed enhancement
	3.391:
		- Minor change to make the timing of looping and yoyo-ing tweens more accurate (a few milliseconds could have been lost previously when the loop or yoyo was triggered)
	3.39:
		- Speed improvement and slight file size decrease
	3.37:
		- Fixed resumeAll()
	3.36:
		- Fixed bug with autoAlpha tweens working with TweenGroups when they're reversed.
	3.35:
		- Deprecated allTo() and allFrom() in favor of the much more powerful and flexible TweenGroup class (see http://blog.greensock.com/tweengroup/ for details)
	3.2:
		- Added "roundProps" special property for rounding values
		- Fixed but with TweenLiteVars, TweenFilterVars, and TweenMaxVars that caused "visible" to always get set at the end of a tween
	3.1:
		- In AUTO or CONCURRENT mode, OverwriteManager doesn't handle overwriting until the tween actually begins which allows for immediate pause()-ing or re-ordering in TweenGroup, etc.
		- Re-architected some inner-workings to further optimize for speed and reduce file size
	3.04:
		- Fixed bug with killTweensOf()
		- Fixed bug with reverse()
		- Fixed bug with from()
	3.0:
		- Deprecated sequence() and multiSequence() in favor of the much more powerful and flexible TweenGroup class (see http://blog.greensock.com/tweengroup/ for details)
		- Added clear() method
		- Added a "clear" parameter to the removeTween() method
		- Exposed TweenLite.currentTime as well as several other TweenLite variables for compatibility with TweenGroup
	2.35:
		- Fixed potential problem if multiple tweens used the same vars object and reverse() was called on more than one.
	2.34:
		- Fixed problem with COMPLETE event listeners not firing when killTweensOf() was called with the forceComplete parameter set to true
	2.32:
		- Fixed bug with invalidating() a tween with event listeners and adding an UPDATE listener after a tween is instantiated.
	2.31:
		- invalidate() reparses onCompleteListener, onUpdateListener, and onStartListener special properties now.
		- If a tween completed without persist:true and the globalTimeScale was updated between that time and the time restart(), reverse(), or resume() was called, it could have an incorrect timeScale. That's fixed now.
	2.3:
		- Added setGlobalTimeScale() function to control the speed of all TweenFilterLite and TweenMax instances
		- Added static "globalTimeScale" property to TweenMax and TweenFilterLite classes. You can even tween it like TweenLite.to(TweenMax, 1, {globalTimeScale:0.5});
		- Changed timeScale so that it also affects the delay (if any)


AUTHOR: Jack Doyle, jack@greensock.com
Copyright 2009, GreenSock. All rights reserved. This work is subject to the terms in http://www.greensock.com/terms_of_use.html or for corporate Club GreenSock members, the software agreement that was issued with the corporate membership.
*/

package gs {
	import flash.events.*;
	import flash.utils.*;
	
	import gs.events.TweenEvent;
	import gs.plugins.*;
	import gs.utils.tween.*;

	public class TweenMax extends TweenLite implements IEventDispatcher {
		public static const version:Number = 10.1;
		
		private static var _activatedPlugins:Boolean = TweenPlugin.activate([
			
			
			//ACTIVATE (OR DEACTIVATE) PLUGINS HERE...
			
			TintPlugin,					//tweens tints
			RemoveTintPlugin,			//allows you to remove a tint
			FramePlugin,				//tweens MovieClip frames
			AutoAlphaPlugin,			//tweens alpha and then toggles "visible" to false if/when alpha is zero
			VisiblePlugin,				//tweens a target's "visible" property
			VolumePlugin,				//tweens the volume of a MovieClip or SoundChannel or anything with a "soundTransform" property
			EndArrayPlugin,				//tweens numbers in an Array
			
			HexColorsPlugin,			//tweens hex colors
			BlurFilterPlugin,			//tweens BlurFilters
			ColorMatrixFilterPlugin,	//tweens ColorMatrixFilters (including hue, saturation, colorize, contrast, brightness, and threshold)
			BevelFilterPlugin,			//tweens BevelFilters
			DropShadowFilterPlugin,		//tweens DropShadowFilters
			GlowFilterPlugin,			//tweens GlowFilters
			RoundPropsPlugin,			//enables the roundProps special property for rounding values.
			BezierPlugin,				//enables bezier tweening
			BezierThroughPlugin,		//enables bezierThrough tweening
			ShortRotationPlugin			//tweens rotation values in the shortest direction
			
			
			]); //activated in static var instead of constructor because otherwise if there's a from() tween, TweenLite's constructor would get called first and initTweenVals() would run before the plugins were activated.
		
		private static var _overwriteMode:int = (OverwriteManager.enabled) ? OverwriteManager.mode : OverwriteManager.init(); //OverwriteManager is optional for TweenLite and TweenFilterLite, but it is used by default in TweenMax.
		public static var killTweensOf:Function = TweenLite.killTweensOf;
		public static var killDelayedCallsTo:Function = TweenLite.killTweensOf;
		public static var removeTween:Function = TweenLite.removeTween;
		protected static var _pausedTweens:Dictionary = new Dictionary(false); //protects from garbage collection issues
		protected static var _globalTimeScale:Number = 1;
		protected var _dispatcher:EventDispatcher;
		protected var _callbacks:Object; //stores the original onComplete, onStart, and onUpdate Functions from the this.vars Object (we replace them if/when dispatching events)
		protected var _repeatCount:Number; //number of times the tween has yoyo'd or loop'd.
		protected var _timeScale:Number; //Allows you to speed up or slow down a tween. Default is 1 (normal speed) 0.5 would be half-speed
		public var pauseTime:Number;
		
		public function TweenMax($target:Object, $duration:Number, $vars:Object) {
			super($target, $duration, $vars);
			if (TweenLite.version < 10.09) {
				trace("TweenMax error! Please update your TweenLite class or try deleting your ASO files. TweenMax requires a more recent version. Download updates at http://www.TweenMax.com.");
			}
			if (this.combinedTimeScale != 1 && this.target is TweenMax) { //in case the user is trying to tween the timeScale of another TweenFilterLite/TweenMax instance
				_timeScale = 1;
				this.combinedTimeScale = _globalTimeScale;
			} else {
				_timeScale = this.combinedTimeScale;
				this.combinedTimeScale *= _globalTimeScale; //combining them speeds processing in important functions like render().
			}
			if (this.combinedTimeScale != 1 && this.delay != 0) {
				this.startTime = this.initTime + (this.delay * (1000 / this.combinedTimeScale));
			}
			
			if (this.vars.onCompleteListener != null || this.vars.onUpdateListener != null || this.vars.onStartListener != null) {
				initDispatcher();
				if ($duration == 0 && this.delay == 0) {
					onUpdateDispatcher();
					onCompleteDispatcher();
				}
			}
			_repeatCount = 0;
			if (!isNaN(this.vars.yoyo) || !isNaN(this.vars.loop)) {
				this.vars.persist = true;
			}
			if (this.delay == 0 && this.exposedVars.startAt != null) {
				this.exposedVars.startAt.overwrite = 0;
				new TweenMax(this.target, 0, this.exposedVars.startAt);
			}
		}
				
		override public function initTweenVals():void {
			if (this.exposedVars.startAt != null && this.delay != 0) {
				this.exposedVars.startAt.overwrite = 0;
				new TweenMax(this.target, 0, this.exposedVars.startAt);
			}
			super.initTweenVals();
			//accommodate rounding if necessary...
			if (this.exposedVars.roundProps is Array && TweenLite.plugins.roundProps != null) {
				var i:int, j:int, prop:String, multiProps:String, rp:Array = this.exposedVars.roundProps, plugin:Object, ti:TweenInfo;
				for (i = rp.length - 1; i > -1; i--) {
					prop = rp[i];
					for (j = this.tweens.length - 1; j > -1; j--) {
						ti = this.tweens[j];
						if (ti.name == prop) {
							if (ti.isPlugin) {
								ti.target.round = true;
							} else {
								if (plugin == null) {
									plugin = new TweenLite.plugins.roundProps();
									plugin.add(ti.target, prop, ti.start, ti.change);
									_hasPlugins = true;
									this.tweens[j] = new TweenInfo(plugin, "changeFactor", 0, 1, prop, true);
								} else {
									plugin.add(ti.target, prop, ti.start, ti.change); //using a single plugin for rounding speeds processing
									this.tweens.splice(j, 1);
								}
							}
						} else if (ti.isPlugin && ti.name == "_MULTIPLE_" && !ti.target.round) {
							multiProps = " " + ti.target.overwriteProps.join(" ") + " ";
							if (multiProps.indexOf(" " + prop + " ") != -1) {
								ti.target.round = true;
							}
						}
					}
				}
			}
		}
		
		public function pause():void {
			if (isNaN(this.pauseTime)) {
				this.pauseTime = currentTime;
				this.startTime = 999999999999999; //required for OverwriteManager
				this.enabled = false;
				_pausedTweens[this] = this;
			}
		}
		
		public function resume():void {
			this.enabled = true;
			if (!isNaN(this.pauseTime)) {
				this.initTime += currentTime - this.pauseTime;
				this.startTime = this.initTime + (this.delay * (1000 / this.combinedTimeScale));
				this.pauseTime = NaN;
				if (!this.started && currentTime >= this.startTime) {
					activate(); //triggers onStart if necessary and initTweenVals()
				} else {
					this.active = this.started;
				}
				_pausedTweens[this] = null;
				delete _pausedTweens[this];
			}
		}
		
		public function restart($includeDelay:Boolean=false):void {
			if ($includeDelay) {
				this.initTime = currentTime;
				this.startTime = currentTime + (this.delay * (1000 / this.combinedTimeScale));
			} else {
				this.startTime = currentTime;
				this.initTime = currentTime - (this.delay * (1000 / this.combinedTimeScale));
			}
			_repeatCount = 0;
			if (this.target != this.vars.onComplete) { //protects delayedCall()s from being rendered.
				render(this.startTime); 
			}
			this.pauseTime = NaN;
			_pausedTweens[this] = null;
			delete _pausedTweens[this];
			this.enabled = true;
		}
		
		public function reverse($adjustDuration:Boolean=true, $forcePlay:Boolean=true):void {
			this.ease = (this.vars.ease == this.ease) ? reverseEase : this.vars.ease;
			var p:Number = this.progress;			
			if ($adjustDuration && p > 0) {
				this.startTime = currentTime - ((1 - p) * this.duration * 1000 / this.combinedTimeScale);
				this.initTime = this.startTime - (this.delay * (1000 / this.combinedTimeScale));
			}
			if ($forcePlay != false) {
				if (p < 1) {
					resume();
				} else {
					restart();
				}
			}
		}
		
		public function reverseEase($t:Number, $b:Number, $c:Number, $d:Number):Number {
			return this.vars.ease($d - $t, $b, $c, $d);
		}
	
		public function invalidate($adjustStartValues:Boolean=true):void { //forces the vars to be re-parsed and immediately re-rendered
			if (this.initted) {
				var p:Number = this.progress;
				if (!$adjustStartValues && p != 0) {
					this.progress = 0;
				}
				this.tweens = [];
				_hasPlugins = false;
				this.exposedVars = (this.vars.isTV == true) ? this.vars.exposedProps : this.vars; //for TweenLiteVars and TweenMaxVars
				initTweenVals();
				_timeScale = this.vars.timeScale || 1;
				this.combinedTimeScale = _timeScale * _globalTimeScale;
				this.delay = this.vars.delay || 0;
				if (isNaN(this.pauseTime)) {
					this.startTime = this.initTime + (this.delay * 1000 / this.combinedTimeScale);
				}
				if (this.vars.onCompleteListener != null || this.vars.onUpdateListener != null || this.vars.onStartListener != null) {
					if (_dispatcher != null) {
						this.vars.onStart = _callbacks.onStart;
						this.vars.onUpdate = _callbacks.onUpdate;
						this.vars.onComplete = _callbacks.onComplete;
						_dispatcher = null;
					}
					initDispatcher();
				}
				if (p != 0) {
					if ($adjustStartValues) {
						adjustStartValues();
					} else {
						this.progress = p;
					}
				}
			}
		}
		
		public function setDestination($property:String, $value:*, $adjustStartValues:Boolean=true):void {
			var p:Number = this.progress, i:int, ti:TweenInfo;
			if (this.initted) {
				if (!$adjustStartValues) {
					for (i = this.tweens.length - 1; i > -1; i--) {
						ti = this.tweens[i];
						if (ti.name == $property) {
							ti.target[ti.property] = ti.start; //return it to its start value (tween index values: [object, property, start, change, name])
						}
					}
				}
				var varsOld:Object = this.vars;
				var exposedVarsOld:Object = this.exposedVars;
				var tweensOld:Array = this.tweens;
				var hadPlugins:Boolean = _hasPlugins;
				this.tweens = [];
				this.vars = this.exposedVars = {};
				this.vars[$property] = $value;
				initTweenVals();
				if (this.ease != reverseEase && varsOld.ease is Function) {
					this.ease = varsOld.ease;
				}
				if ($adjustStartValues && p != 0) {
					adjustStartValues();
				}
				
				var addedTweens:Array = this.tweens;
				
				this.vars = varsOld;
				this.exposedVars = exposedVarsOld;
				this.tweens = tweensOld;
				
				var killVars:Object = {};
				killVars[$property] = true;
				for (i = this.tweens.length - 1; i > -1; i--) {
					ti = this.tweens[i];
					if (ti.name == $property) {
						this.tweens.splice(i, 1);
					} else if (ti.isPlugin && ti.name == "_MULTIPLE_") { //is a plugin with multiple overwritable properties
						ti.target.killProps(killVars);
						if (ti.target.overwriteProps.length == 0) {
							this.tweens.splice(i, 1);
						}
					}
				}				
				
				this.tweens = this.tweens.concat(addedTweens);
				_hasPlugins = Boolean(hadPlugins || _hasPlugins);
			}
			this.vars[$property] = this.exposedVars[$property] = $value;
		}
		
		protected function adjustStartValues():void { //adjusts the start values in the tweens so that the current progress and end values are maintained which prevents "skipping" when changing destination values mid-way through the tween.
			var p:Number = this.progress;
			if (p != 0) {
				var factor:Number = this.ease(p, 0, 1, 1);
				var inv:Number = 1 / (1 - factor);
				var endValue:Number, ti:TweenInfo, i:int;
				for (i = this.tweens.length - 1; i > -1; i--) {
					ti = this.tweens[i];
					endValue = ti.start + ti.change; //[object, property, start, change, name, isPlugin]
					if (ti.isPlugin) { //can't read the "progress" value of a plugin, but we know what it is based on the factor (above)
						ti.change = (endValue - factor) * inv;
					} else {
						ti.change = (endValue - ti.target[ti.property]) * inv;
					}
					ti.start = endValue - ti.change;
				}
			}
		}
		
		public function killProperties($names:Array):void {
			var v:Object = {}, i:int;
			for (i = $names.length - 1; i > -1; i--) {
				v[$names[i]] = true;
			}
			killVars(v);
		}
		
		override public function render($t:uint):void {
			var time:Number = ($t - this.startTime) * 0.001 * this.combinedTimeScale, factor:Number, ti:TweenInfo, i:int;
			if (time >= this.duration) {
				time = this.duration;
				factor = (this.ease == this.vars.ease || this.duration == 0.001) ? 1 : 0; //to accommodate TweenMax.reverse(). Without this, the last frame would render incorrectly
			} else {
				factor = this.ease(time, 0, 1, this.duration);
			}
			for (i = this.tweens.length - 1; i > -1; i--) {
				ti = this.tweens[i];
				ti.target[ti.property] = ti.start + (factor * ti.change); //tween index values: [object, property, start, change, name, isPlugin]
			}
			if (_hasUpdate) {
				this.vars.onUpdate.apply(null, this.vars.onUpdateParams);
			}
			if (time == this.duration) { //Check to see if we're done
				complete(true);
			}
		}
		
		override public function complete($skipRender:Boolean = false):void {
			if ((!isNaN(this.vars.yoyo) && (_repeatCount < this.vars.yoyo || this.vars.yoyo == 0)) || (!isNaN(this.vars.loop) && (_repeatCount < this.vars.loop || this.vars.loop == 0))) {
				_repeatCount++;
				if (!isNaN(this.vars.yoyo)) {
					this.ease = (this.vars.ease == this.ease) ? reverseEase : this.vars.ease;
				}
				this.startTime = ($skipRender) ? this.startTime + (this.duration * (1000 / this.combinedTimeScale)) : currentTime; //for more accurate results, add the duration to the startTime, otherwise a few milliseconds might be skipped. You can occassionally see this if you have two simultaneous looping tweens with different end times that move objects that are butted up against each other.
				this.initTime = this.startTime - (this.delay * (1000 / this.combinedTimeScale));				
			} else if (this.vars.persist == true) {
				//super.complete($skipRender);
				pause();
				//return;
			}
			super.complete($skipRender);
		}
		
		
//---- EVENT DISPATCHING ----------------------------------------------------------------------------------------------------------
		
		protected function initDispatcher():void {
			if (_dispatcher == null) {
				_dispatcher = new EventDispatcher(this);
				_callbacks = {onStart:this.vars.onStart, onUpdate:this.vars.onUpdate, onComplete:this.vars.onComplete}; //store the originals
				if (this.vars.isTV == true) { //For TweenLiteVars, TweenFilterLiteVars, and TweenMaxVars compatibility
					this.vars = this.vars.clone();
				} else {
					var v:Object = {}, p:String;
					for (p in this.vars) {
						v[p] = this.vars[p]; //Just in case the same vars Object is reused for multiple tweens, we need to copy all the properties and create a duplicate so that we don't interfere with other tweens.
					}
					this.vars = v;
				}
				this.vars.onStart = onStartDispatcher;
				this.vars.onComplete = onCompleteDispatcher;
				
				if (this.vars.onStartListener is Function) {
					_dispatcher.addEventListener(TweenEvent.START, this.vars.onStartListener, false, 0, true);
				}
				if (this.vars.onUpdateListener is Function) {
					_dispatcher.addEventListener(TweenEvent.UPDATE, this.vars.onUpdateListener, false, 0, true);
					this.vars.onUpdate = onUpdateDispatcher; //To improve performance, we only want to add UPDATE dispatching if absolutely necessary.
					_hasUpdate = true;
				}
				if (this.vars.onCompleteListener is Function) {
					_dispatcher.addEventListener(TweenEvent.COMPLETE, this.vars.onCompleteListener, false, 0, true);
				}
			}
		}
		
		protected function onStartDispatcher(... $args):void {
			if (_callbacks.onStart != null) {
				_callbacks.onStart.apply(null, this.vars.onStartParams);
			}
			_dispatcher.dispatchEvent(new TweenEvent(TweenEvent.START));
		}
		
		protected function onUpdateDispatcher(... $args):void {
			if (_callbacks.onUpdate != null) {
				_callbacks.onUpdate.apply(null, this.vars.onUpdateParams);
			}
			_dispatcher.dispatchEvent(new TweenEvent(TweenEvent.UPDATE));
		}
		
		protected function onCompleteDispatcher(... $args):void {
			if (_callbacks.onComplete != null) {
				_callbacks.onComplete.apply(null, this.vars.onCompleteParams);
			}
			_dispatcher.dispatchEvent(new TweenEvent(TweenEvent.COMPLETE));
		}
		
		public function addEventListener($type:String, $listener:Function, $useCapture:Boolean = false, $priority:int = 0, $useWeakReference:Boolean = false):void {
			if (_dispatcher == null) {
				initDispatcher();
			}
			if ($type == TweenEvent.UPDATE && this.vars.onUpdate != onUpdateDispatcher) { //To improve performance, we only want to add UPDATE dispatching if absolutely necessary.
				this.vars.onUpdate = onUpdateDispatcher;
				_hasUpdate = true;
			}
			_dispatcher.addEventListener($type, $listener, $useCapture, $priority, $useWeakReference);
		}
		
		public function removeEventListener($type:String, $listener:Function, $useCapture:Boolean = false):void {
			if (_dispatcher != null) {
				_dispatcher.removeEventListener($type, $listener, $useCapture);
			}
		}
		
		public function hasEventListener($type:String):Boolean {
			if (_dispatcher == null) {
				return false;
			} else {
				return _dispatcher.hasEventListener($type);
			}
		}
		
		public function willTrigger($type:String):Boolean {
			if (_dispatcher == null) {
				return false;
			} else {
				return _dispatcher.willTrigger($type);
			}
		}
		
		public function dispatchEvent($e:Event):Boolean {
			if (_dispatcher == null) {
				return false;
			} else {
				return _dispatcher.dispatchEvent($e);
			}
		}
		
		
//---- STATIC FUNCTIONS -----------------------------------------------------------------------------------------------------------
		
		public static function to($target:Object, $duration:Number, $vars:Object):TweenMax {
			return new TweenMax($target, $duration, $vars);
		}
		
		public static function from($target:Object, $duration:Number, $vars:Object):TweenMax {
			$vars.runBackwards = true;
			return new TweenMax($target, $duration, $vars);
		}
		
		public static function delayedCall($delay:Number, $onComplete:Function, $onCompleteParams:Array=null, $persist:Boolean=false):TweenMax {
			return new TweenMax($onComplete, 0, {delay:$delay, onComplete:$onComplete, onCompleteParams:$onCompleteParams, persist:$persist, overwrite:0});
		}
		
		public static function setGlobalTimeScale($scale:Number):void {
			if ($scale < 0.00001) {
				$scale = 0.00001;
			}
			var ml:Dictionary = masterList, i:int, a:Array;
			_globalTimeScale = $scale;
			for each (a in ml) {
				for (i = a.length - 1; i > -1; i--) {
					if (a[i] is TweenMax) {
						a[i].timeScale *= 1; //just forces combining of the _timeScale and _globalTimeScale.
					}
				}
			}
		}
		
		public static function getTweensOf($target:Object):Array {
			var a:Array = masterList[$target];
			var toReturn:Array = [];
			if(a != null) {
				for (var i:int = a.length - 1; i > -1; i--) {
					if (!a[i].gc) {
						toReturn[toReturn.length] = a[i];
					}
				}
			}
			for each (var tween:TweenLite in _pausedTweens) {
				if (tween.target == $target) {
					toReturn[toReturn.length] = tween;
				}
			}
			return toReturn;
		}
		
		public static function isTweening($target:Object):Boolean {
			var a:Array = getTweensOf($target);
			for (var i:int = a.length - 1; i > -1; i--) {
				if ((a[i].active || a[i].startTime == currentTime) && !a[i].gc) {
					return true;
				}
			}
			return false;
		}
		
		public static function getAllTweens():Array {
			var ml:Dictionary = masterList; //speeds things up slightly
			var toReturn:Array = [], a:Array, i:int, tween:TweenLite;
			for each (a in ml) {
				for (i = a.length - 1; i > -1; i--) {
					if (!a[i].gc) {
						toReturn[toReturn.length] = a[i];
					}
				}
			}
			for each (tween in _pausedTweens) {
				toReturn[toReturn.length] = tween;
			}
			return toReturn;
		}
		
		public static function killAllTweens($complete:Boolean = false):void {
			killAll($complete, true, false);
		}
		
		public static function killAllDelayedCalls($complete:Boolean = false):void {
			killAll($complete, false, true);
		}
		
		public static function killAll($complete:Boolean = false, $tweens:Boolean = true, $delayedCalls:Boolean = true):void {
			var a:Array = getAllTweens();
			var isDC:Boolean, i:int; //is delayedCall
			for (i = a.length - 1; i > -1; i--) {
				isDC = (a[i].target == a[i].vars.onComplete);
				if (isDC == $delayedCalls || isDC != $tweens) {
					if ($complete) {
						a[i].complete(false);
						a[i].clear();
					} else {
						TweenLite.removeTween(a[i], true);
					}
				}
			}
		}
		
		public static function pauseAll($tweens:Boolean = true, $delayedCalls:Boolean = false):void {
			changePause(true, $tweens, $delayedCalls);
		}
		
		public static function resumeAll($tweens:Boolean = true, $delayedCalls:Boolean = false):void {
			changePause(false, $tweens, $delayedCalls);
		}
		
		public static function changePause($pause:Boolean, $tweens:Boolean = true, $delayedCalls:Boolean = false):void {
			var a:Array = getAllTweens();
			var isDC:Boolean; //is delayedCall
			for (var i:int = a.length - 1; i > -1; i--) {
				isDC = (a[i].target == a[i].vars.onComplete);
				if (a[i] is TweenMax && (isDC == $delayedCalls || isDC != $tweens)) {
					a[i].paused = $pause;
				}
			}
		}
		
	
//---- GETTERS / SETTERS ----------------------------------------------------------------------------------------------------------
		
		public function get paused():Boolean {
			return !isNaN(this.pauseTime);
		}
		public function set paused($b:Boolean):void {
			if ($b) {
				pause();
			} else {
				resume();
			}
		}
		public function get reversed():Boolean {
			return (this.ease == reverseEase);
		}
		public function set reversed($b:Boolean):void {
			if (this.reversed != $b) {
				reverse();
			}
		}
		public function get timeScale():Number {
			return _timeScale;
		}
		public function set timeScale($n:Number):void {
			if ($n < 0.00001) {
				$n = _timeScale = 0.00001;
			} else {
				_timeScale = $n;
				$n *= _globalTimeScale; //instead of doing _timeScale * _globalTimeScale in the render() and elsewhere, we improve performance by combining them here.
			}
			this.initTime = currentTime - ((currentTime - this.initTime - (this.delay * (1000 / this.combinedTimeScale))) * this.combinedTimeScale * (1 / $n)) - (this.delay * (1000 / $n));
			if (this.startTime != 999999999999999) { //required for OverwriteManager (indicates a TweenMax instance that has been paused)
				this.startTime = this.initTime + (this.delay * (1000 / $n));
			}
			this.combinedTimeScale = $n;
		}
		override public function set enabled($b:Boolean):void {
			if (!$b) {
				_pausedTweens[this] = null;
				delete _pausedTweens[this];
			}
			super.enabled = $b;
			if ($b) {
				this.combinedTimeScale = _timeScale * _globalTimeScale;
			}
		}
		public static function set globalTimeScale($n:Number):void {
			setGlobalTimeScale($n);
		}
		public static function get globalTimeScale():Number {
			return _globalTimeScale;
		}
		public function get progress():Number {
			var t:Number = (!isNaN(this.pauseTime)) ? this.pauseTime : currentTime;
			var p:Number = (((t - this.initTime) * 0.001) - this.delay / this.combinedTimeScale) / this.duration * this.combinedTimeScale;
			if (p > 1) {
				return 1;
			} else if (p < 0) {
				return 0;
			} else {
				return p;
			}
		}
		public function set progress($n:Number):void {
			this.startTime = currentTime - ((this.duration * $n) * 1000);
			this.initTime = this.startTime - (this.delay * (1000 / this.combinedTimeScale));
			if (!this.started) {
				activate();//Just to trigger all the onStart stuff and make sure initTweenVals() has been called.
			}
			render(currentTime);
			
			if (!isNaN(this.pauseTime)) {
				this.pauseTime = currentTime;
				this.startTime = 999999999999999; //required for OverwriteManager
				this.active = false;
			}
		}
		
	}
}