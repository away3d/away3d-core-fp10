/*
VERSION: 10.091
DATE: 3/20/2009
ACTIONSCRIPT VERSION: 3.0 (AS2 version is also available)
UPDATES & MORE DETAILED DOCUMENTATION AT: http://www.TweenLite.com
DESCRIPTION:
	TweenLite is an extremely lightweight, FAST, and flexible tweening engine that serves as the core of 
	the GreenSock tweening platform. There are plenty of other tweening engines out there to choose from,
	so here's why you might want to consider TweenLite:
	
		- SPEED - I'm not aware of any popular tweening engine with a similar feature set that's as fast
		  as TweenLite. See some speed comparisons yourself at http://blog.greensock.com/tweening-speed-test/
		  
		- Feature set - In addition to tweening ANY numeric property of ANY object, TweenLite can tween filters, 
		  hex colors, volume, tint, and frames, and even do bezier tweening, plus LOTS more. TweenMax extends 
		  TweenLite and adds even more capabilities like pause/resume, rounding, event listeners, and more. 
		  Overwrite management is an important consideration for a tweening engine as well which is another 
		  area where the GreenSock tweening platform shines. You have options for AUTO overwriting or you can
		  manually define how each tween will handle overlapping tweens of the same object.
		  
		- Expandability - With its new plugin architecture, you can activate as many (or as few) features as your 
		  project requires. Or write your own plugin if you need a feature that's unavailable. Minimize bloat, and
		  maximize performance.
		  
		- Management features - TweenGroup makes it surprisingly simple to create complex sequences and groups
		  of TweenLite/Max tweens that you can pause(), resume(), restart(), or reverse(). You can even tween a TweenGroup's 
		  progress property to fastforward or rewind the entire group/sequence. 
		  
		- Ease of use - Designers and Developers alike rave about how intuitive the GreenSock tweening platform is.
		
		- Updates - Frequent updates and feature additions make the GreenSock tweening platform reliable and robust.
		
		- AS2 and AS3 - Most other engines are only developed for AS2 or AS3 but not both.
	

PARAMETERS:
	1) $target : Object - Target object whose properties we're tweening
	2) $duration : Number - Duration (in seconds) of the tween
	3) $vars : Object - An object containing the end values of all the properties you'd like tweened (or if you're using 
	         			TweenLite.from(), these variables would define the BEGINNING values). For example, to tween
	         			myClip's alpha to 0.5 over the course of 1 second, you'd do: TweenLite.to(myClip, 1, {alpha:0.5}).
	         			
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
	
	persist : Boolean - if true, the TweenLite instance will NOT automatically be removed by the garbage collector when it is complete.
  					    However, it is still eligible to be overwritten by new tweens even if persist is true. By default, it is false.
	
	renderOnStart : Boolean - If you're using TweenLite.from() with a delay and want to prevent the tween from rendering until it
							  actually begins, set this to true. By default, it's false which causes TweenLite.from() to render
							  its values immediately, even before the delay has expired.
	
	overwrite : int - Controls how other tweens of the same object are handled when this tween is created. Here are the options:
  					- 0 (NONE): No tweens are overwritten. This is the fastest mode, but you need to be careful not to create any 
  								tweens with overlapping properties, otherwise they'll conflict with each other. 
								
					- 1 (ALL): (this is the default unless OverwriteManager.init() has been called) All tweens of the same object 
							   are completely overwritten immediately when the tween is created. 
							   		TweenLite.to(mc, 1, {x:100, y:200});
									TweenLite.to(mc, 1, {x:300, delay:2, overwrite:1}); //immediately overwrites the previous tween
									
					- 2 (AUTO): (used by default if OverwriteManager.init() has been called) Searches for and overwrites only 
								individual overlapping properties in tweens that are active when the tween begins. 
									TweenLite.to(mc, 1, {x:100, y:200});
									TweenLite.to(mc, 1, {x:300, overwrite:2}); //only overwrites the "x" property in the previous tween
									
					- 3 (CONCURRENT): Overwrites all tweens of the same object that are active when the tween begins.
									  TweenLite.to(mc, 1, {x:100, y:200});
									  TweenLite.to(mc, 1, {x:300, delay:2, overwrite:3}); //does NOT overwrite the previous tween because the first tween will have finished by the time this one begins.
	

PLUGINS:
	There are many plugins that add capabilities through other special properties. Some examples are "tint", 
	"volume", "frame", "frameLabel", "bezier", "blurFilter", "colorMatrixFilter", "hexColors", and many more.
	Adding the capabilities is as simple as activating the plugin with a single line of code, like TintPlugin.activate();
	Get information about all the plugins at http://blog.greensock.com/plugins/


EXAMPLES: 
	Tween the alpha to 50% (0.5) and move the x position of a MovieClip named "clip_mc" 
	to 120 and fade the volume to 0 over the course of 1.5 seconds like so:
	
		import gs.*;
		TweenLite.to(clip_mc, 1.5, {alpha:0.5, x:120, volume:0});
	
	If you want to get more advanced and tween the clip_mc MovieClip over 5 seconds, changing the alpha to 0.5, 
	the x to 120 using the "Back.easeOut" easing function, delay starting the whole tween by 2 seconds, and then call
	a function named "onFinishTween" when it has completed and pass a few parameters to that function (a value of
	5 and a reference to the clip_mc), you'd do so like:
		
		import gs.*;
		import gs.easing.*;
		TweenLite.to(clip_mc, 5, {alpha:0.5, x:120, ease:Back.easeOut, delay:2, onComplete:onFinishTween, onCompleteParams:[5, clip_mc]});
		function onFinishTween(argument1:Number, argument2:MovieClip):void {
			trace("The tween has finished! argument1 = " + argument1 + ", and argument2 = " + argument2);
		}
	
	If you have a MovieClip on the stage that is already in it's end position and you just want to animate it into 
	place over 5 seconds (drop it into place by changing its y property to 100 pixels higher on the screen and 
	dropping it from there), you could:
		
		import gs.*;
		import gs.easing.*;
		TweenLite.from(clip_mc, 5, {y:"-100", ease:Elastic.easeOut});		
	

NOTES:

	- The base TweenLite class adds about 2.9kb to your Flash file, but if you activate the extra features
	  that were available in versions prior to 10.0 (tint, removeTint, frame, endArray, visible, and autoAlpha), 
	  it totals about 5k. You can easily activate those plugins by uncommenting out the associated lines of 
	  code in the constructor.
	  
	- Passing values as Strings will make the tween relative to the current value. For example, if you do
	  TweenLite.to(mc, 2, {x:"-20"}); it'll move the mc.x to the left 20 pixels which is the same as doing
	  TweenLite.to(mc, 2, {x:mc.x - 20}); You could also cast it like: TweenLite.to(mc, 2, {x:String(myVariable)});
	  
	- You can change the TweenLite.defaultEase function if you prefer something other than Regular.easeOut.
	
	- Kill all tweens for a particular object anytime with the TweenLite.killTweensOf(myClip_mc); 
	  function. If you want to have the tweens forced to completion, pass true as the second parameter, 
	  like TweenLite.killTweensOf(myClip_mc, true);
	  
	- You can kill all delayedCalls to a particular function using TweenLite.killDelayedCallsTo(myFunction_func);
	  This can be helpful if you want to preempt a call.
	  
	- Use the TweenLite.from() method to animate things into place. For example, if you have things set up on 
	  the stage in the spot where they should end up, and you just want to animate them into place, you can 
	  pass in the beginning x and/or y and/or alpha (or whatever properties you want).
	  
	- If you find this class useful, please consider joining Club GreenSock which not only contributes
	  to ongoing development, but also gets you bonus classes (and other benefits) that are ONLY available 
	  to members. Learn more at http://blog.greensock.com/club/
	  
	  
CHANGE LOG:
	10.091:
		- Fixed bug that prevented timeScale tweens of TweenGroups 
	10.09:
		- Fixed bug with timeScale
	10.06:
		- Speed improvements
		- Integrated a new gs.utils.tween.TweenInfo class
		- Minor internal changes
	10.0:
		- Major update, shifting to a "plugin" architecture for handling special properties. 
		- Added "remove" property to all filter tweens to accommodate removing the filter at the end of the tween
		- Added "setSize" and "frameLabel" plugins
		- Speed enhancements
		- Fixed minor overwrite bugs
	9.3:
		- Added compatibility with TweenProxy and TweenProxy3D
	9.291:
		- Adjusted how the timeScale special property is handled internally. It should be more flexible and slightly faster now.
	9.29:
		- Minor speed enhancement
	9.26:
		- Speed improvement and slight file size decrease
	9.25:
		- Fixed bug with autoAlpha tweens working with TweenGroups when they're reversed.
	9.22:
		- Fixed bug with from() when used in a TweenGroup
	9.12:
		- Fixed but with TweenLiteVars, TweenFilterVars, and TweenMaxVars that caused "visible" to always get set at the end of a tween
	9.1:
		- In AUTO or CONCURRENT mode, OverwriteManager doesn't handle overwriting until the tween actually begins which allows for immediate pause()-ing or re-ordering in TweenGroup, etc.
		- Re-architected some inner-workings to further optimize for speed and reduce file size
	9.05:
		- Fixed bug with killTweensOf()
		- Fixed bug with from()
		- Fixed bug with timeScale
	9.0:
		- Made compatible with the new TweenGroup class (see http://blog.greensock.com/tweengroup/ for details) which allows for sequencing and much more
		- Added clear() method
		- Added a "clear" parameter to the removeTween() method
		- Exposed TweenLite.currentTime as well as several other variables for compatibility with TweenGroup
	8.16:
		- Fixed bug that prevented using another tween to gradually change the timeScale of a tween
	8.15:
		- Fixed bug that caused from() delays not to function since version 8.14
	8.14:
		- Fixed bug in managing overwrites
	8.11:
		- Added the ability to overwrite only individual overlapping properties with the new OverwriteManager class
		- Added the killVars() method
		- Fixed potential garbage collection issue
	7.04:
		- Speed optimizations
	7.02:
		- Added ability to tween the volume of any object that has a soundTransform property instead of just MoveiClips and SoundChannels. Now NetStream volumes can be tweened too.
	7.01:
		- Fixed delayedCall() error (removed onCompleteScope since it's not useful in AS3 anyway)
	7.0:
		- Added "persist" special property
		- Added "removeTint" special property (please use this instead of tint:null)
		- Added compatibility with TweenLiteVars utility class

AUTHOR: Jack Doyle, jack@greensock.com
Copyright 2009, GreenSock. All rights reserved. This work is subject to the terms in http://www.greensock.com/terms_of_use.html or for corporate Club GreenSock members, the software agreement that was issued with the corporate membership.
*/

package gs {
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	
	import gs.plugins.*;
	import gs.utils.tween.*;

	public class TweenLite {
		public static const version:Number = 10.091;
		public static var plugins:Object = {};
		public static var killDelayedCallsTo:Function = TweenLite.killTweensOf;
		public static var defaultEase:Function = TweenLite.easeOut;
		public static var overwriteManager:Object; //makes it possible to integrate the gs.utils.tween.OverwriteManager for adding autoOverwrite capabilities
		public static var currentTime:uint;
		public static var masterList:Dictionary = new Dictionary(false); //Holds references to all our instances.
		public static var timingSprite:Sprite = new Sprite(); //A reference to the sprite that we use to drive all our ENTER_FRAME events.
		private static var _tlInitted:Boolean; //TweenLite class initted
		private static var _timer:Timer = new Timer(2000);
		protected static var _reservedProps:Object = {ease:1, delay:1, overwrite:1, onComplete:1, onCompleteParams:1, runBackwards:1, startAt:1, onUpdate:1, onUpdateParams:1, roundProps:1, onStart:1, onStartParams:1, persist:1, renderOnStart:1, proxiedEase:1, easeParams:1, yoyo:1, loop:1, onCompleteListener:1, onUpdateListener:1, onStartListener:1, orientToBezier:1, timeScale:1};
	
		public var duration:Number; //Duration (in seconds)
		public var vars:Object; //Variables (holds things like alpha or y or whatever we're tweening)
		public var delay:Number; //Delay (in seconds)
		public var startTime:Number; //Start time
		public var initTime:Number; //Time of initialization. Remember, we can build in delays so this property tells us when the frame action was born, not when it actually started doing anything.
		public var tweens:Array; //Contains parsed data for each property that's being tweened (target, property, start, change, name, and isPlugin).
		public var target:Object; //Target object 
		public var active:Boolean; 
		public var ease:Function;
		public var initted:Boolean;
		public var combinedTimeScale:Number; //even though TweenLite doesn't use this variable TweenMax does and it optimized things to store it here, particularly for TweenGroup
		public var gc:Boolean; //flagged for garbage collection
		public var started:Boolean;
		public var exposedVars:Object; //Helps when using TweenLiteVars and TweenMaxVars utility classes because certain properties are only exposed via vars.exposedVars (for example, the "visible" property is Boolean, so we cannot normally check to see if it's undefined)
		
		protected var _hasPlugins:Boolean; //if there are TweenPlugins in the tweens Array, we set this to true - it helps speed things up in onComplete
		protected var _hasUpdate:Boolean; //has onUpdate. Tracking this as a Boolean value is faster than checking this.vars.onUpdate == null.
		
		public function TweenLite($target:Object, $duration:Number, $vars:Object) {
			if ($target == null) {
				return
			}
			if (!_tlInitted) {
				
				TweenPlugin.activate([
		
		
					//ACTIVATE (OR DEACTIVATE) PLUGINS HERE...
					
					TintPlugin,					//tweens tints
					RemoveTintPlugin,			//allows you to remove a tint
					FramePlugin,				//tweens MovieClip frames
					AutoAlphaPlugin,			//tweens alpha and then toggles "visible" to false if/when alpha is zero
					VisiblePlugin,				//tweens a target's "visible" property
					VolumePlugin,				//tweens the volume of a MovieClip or SoundChannel or anything with a "soundTransform" property
					EndArrayPlugin				//tweens numbers in an Array		
					
					
					]);
				
				
				currentTime = getTimer();
				timingSprite.addEventListener(Event.ENTER_FRAME, updateAll, false, 0, true);
				if (overwriteManager == null) {
					overwriteManager = {mode:1, enabled:false};
				}			
				_timer.addEventListener("timer", killGarbage, false, 0, true);
            	_timer.start();
				_tlInitted = true;
			}
			this.vars = $vars;
			this.duration = $duration || 0.001; //easing equations don't work when the duration is zero.
			this.delay = $vars.delay || 0;
			this.combinedTimeScale = $vars.timeScale || 1;
			this.active = Boolean($duration == 0 && this.delay == 0);
			this.target = $target;
			if (typeof(this.vars.ease) != "function") {
				this.vars.ease = defaultEase;
			}
			if (this.vars.easeParams != null) {
				this.vars.proxiedEase = this.vars.ease;
				this.vars.ease = easeProxy;
			}
			this.ease = this.vars.ease;
			this.exposedVars = (this.vars.isTV == true) ? this.vars.exposedVars : this.vars; //for TweenLiteVars and TweenMaxVars (we need an object with enumerable properties)
			this.tweens = [];
			this.initTime = currentTime;
			this.startTime = this.initTime + (this.delay * 1000);
			
			var mode:int = ($vars.overwrite == undefined || (!overwriteManager.enabled && $vars.overwrite > 1)) ? overwriteManager.mode : int($vars.overwrite);
			if (!($target in masterList) || mode == 1) { 
				masterList[$target] = [this];
			} else {
				masterList[$target].push(this);
			}
			
			if ((this.vars.runBackwards == true && this.vars.renderOnStart != true) || this.active) {
				initTweenVals();
				if (this.active) { //Means duration is zero and delay is zero, so render it now, but add one to the startTime because this.duration is always forced to be at least 0.001 since easing equations can't handle zero.
					render(this.startTime + 1);
				} else {
					render(this.startTime);
				}
				if (this.exposedVars.visible != null && this.vars.runBackwards == true && (this.target is DisplayObject)) {
					this.target.visible = this.exposedVars.visible;
				}
			}
		}
		
		public function initTweenVals():void {
			var p:String, i:int, plugin:*;
			if (this.exposedVars.timeScale != undefined && this.target.hasOwnProperty("timeScale")) {
				this.tweens[this.tweens.length] = new TweenInfo(this.target, "timeScale", this.target.timeScale, this.exposedVars.timeScale - this.target.timeScale, "timeScale", false); //[object, property, start, change, name, isPlugin]
			}
			for (p in this.exposedVars) {
				if (p in _reservedProps) { 
					//ignore
					
				} else if (p in plugins) {
					plugin = new plugins[p]();
					if (plugin.onInitTween(this.target, this.exposedVars[p], this) == false) {
						this.tweens[this.tweens.length] = new TweenInfo(this.target, p, this.target[p], (typeof(this.exposedVars[p]) == "number") ? this.exposedVars[p] - this.target[p] : Number(this.exposedVars[p]), p, false); //[object, property, start, change, name, isPlugin]
					} else {
						this.tweens[this.tweens.length] = new TweenInfo(plugin, "changeFactor", 0, 1, (plugin.overwriteProps.length == 1) ? plugin.overwriteProps[0] : "_MULTIPLE_", true); //[object, property, start, change, name, isPlugin]
						_hasPlugins = true;
					}
					
				} else {
					this.tweens[this.tweens.length] = new TweenInfo(this.target, p, this.target[p], (typeof(this.exposedVars[p]) == "number") ? this.exposedVars[p] - this.target[p] : Number(this.exposedVars[p]), p, false); //[object, property, start, change, name, isPlugin]
				}
			}
			if (this.vars.runBackwards == true) {
				var ti:TweenInfo;
				for (i = this.tweens.length - 1; i > -1; i--) {
					ti = this.tweens[i];
					ti.start += ti.change;
					ti.change = -ti.change;
				}
			}
			if (this.vars.onUpdate != null) {
				_hasUpdate = true;
			}
			if (TweenLite.overwriteManager.enabled && this.target in masterList) {
				overwriteManager.manageOverwrites(this, masterList[this.target]);
			}
			this.initted = true;
		}
		
		public function activate():void {
			this.started = this.active = true;
			if (!this.initted) {
				initTweenVals();
			}
			if (this.vars.onStart != null) {
				this.vars.onStart.apply(null, this.vars.onStartParams);
			}
			if (this.duration == 0.001) { //In the constructor, if the duration is zero, we shift it to 0.001 because the easing functions won't work otherwise. We need to offset the this.startTime to compensate too.
				this.startTime -= 1;
			}
		}
		
		public function render($t:uint):void {
			var time:Number = ($t - this.startTime) * 0.001, factor:Number, ti:TweenInfo, i:int;
			if (time >= this.duration) {
				time = this.duration;
				factor = (this.ease == this.vars.ease || this.duration == 0.001) ? 1 : 0; //to accommodate TweenMax.reverse(). Without this, the last frame would render incorrectly
			} else {
				factor = this.ease(time, 0, 1, this.duration);			
			}
			for (i = this.tweens.length - 1; i > -1; i--) {
				ti = this.tweens[i];
				ti.target[ti.property] = ti.start + (factor * ti.change); 
			}
			if (_hasUpdate) {
				this.vars.onUpdate.apply(null, this.vars.onUpdateParams);
			}
			if (time == this.duration) {
				complete(true);
			}
		}
		
		public function complete($skipRender:Boolean = false):void {
			if (!$skipRender) {
				if (!this.initted) {
					initTweenVals();
				}
				this.startTime = currentTime - (this.duration * 1000) / this.combinedTimeScale;
				render(currentTime); //Just to force the final render
				return;
			}
			if (_hasPlugins) {
				for (var i:int = this.tweens.length - 1; i > -1; i--) {
					if (this.tweens[i].isPlugin && this.tweens[i].target.onComplete != null) { //function calls are expensive performance-wise, so don't call the plugin's onComplete() unless necessary. Most plugins don't require them.
						this.tweens[i].target.onComplete();
					}
				}
			}
			if (this.vars.persist != true) {
				this.enabled = false; //moved above the onComplete callback in case there's an error in the user's onComplete - this prevents constant errors
			}
			if (this.vars.onComplete != null) {
				this.vars.onComplete.apply(null, this.vars.onCompleteParams);
			}
		}
	
		public function clear():void {
			this.tweens = [];
			this.vars = this.exposedVars = {ease:this.vars.ease}; //just to avoid potential errors if someone tries to set the progress on a reversed tween that has been killed (unlikely, I know);
			_hasUpdate = false;
		}
		
		public function killVars($vars:Object):void {
			if (overwriteManager.enabled) {
				overwriteManager.killVars($vars, this.exposedVars, this.tweens);
			}
		}
		
		
//---- STATIC FUNCTIONS -------------------------------------------------------------------------
		
		public static function to($target:Object, $duration:Number, $vars:Object):TweenLite {
			return new TweenLite($target, $duration, $vars);
		}
		
		public static function from($target:Object, $duration:Number, $vars:Object):TweenLite {
			$vars.runBackwards = true;
			return new TweenLite($target, $duration, $vars);
		}
		
		public static function delayedCall($delay:Number, $onComplete:Function, $onCompleteParams:Array = null):TweenLite {
			return new TweenLite($onComplete, 0, {delay:$delay, onComplete:$onComplete, onCompleteParams:$onCompleteParams, overwrite:0});
		}
		
		public static function updateAll($e:Event = null):void {
			var time:uint = currentTime = getTimer(), ml:Dictionary = masterList, a:Array, i:int, tween:TweenLite;
			for each (a in ml) {
				for (i = a.length - 1; i > -1; i--) {
					tween = a[i];
					if (tween.active) {
						tween.render(time);
					} else if (tween.gc) {
						a.splice(i, 1);
					} else if (time >= tween.startTime) {
						tween.activate();
						tween.render(time);
					}
				}
			}
		}
		
		public static function removeTween($tween:TweenLite, $clear:Boolean = true):void {
			if ($tween != null) {
				if ($clear) { 
					$tween.clear();
				}
				$tween.enabled = false;
			}
		}
		
		public static function killTweensOf($target:Object = null, $complete:Boolean = false):void {
			if ($target != null && $target in masterList) {
				var a:Array = masterList[$target], i:int, tween:TweenLite;
				for (i = a.length - 1; i > -1; i--) {
					tween = a[i];
					if ($complete && !tween.gc) {
						tween.complete(false);
					}
					tween.clear(); //prevents situations where a tween is killed but is still referenced elsewhere and put back in the render queue, like if a TweenLiteGroup is paused, then the tween is removed, then the group is unpaused.
				}
				delete masterList[$target];
			}
		}
		
		protected static function killGarbage($e:TimerEvent):void {
			var ml:Dictionary = masterList, tgt:Object;
			for (tgt in ml) {
				if (ml[tgt].length == 0) {
					delete ml[tgt];
				}
			}
		}
		
		public static function easeOut($t:Number, $b:Number, $c:Number, $d:Number):Number {
			return -$c * ($t /= $d) * ($t - 2) + $b;
		}
		
		
//---- PROXY FUNCTIONS ------------------------------------------------------------------------
		
		protected function easeProxy($t:Number, $b:Number, $c:Number, $d:Number):Number { //Just for when easeParams are passed in via the vars object.
			return this.vars.proxiedEase.apply(null, arguments.concat(this.vars.easeParams));
		}
		
		
//---- GETTERS / SETTERS -----------------------------------------------------------------------
		
		public function get enabled():Boolean {
			return (this.gc) ? false : true;
		}
		
		public function set enabled($b:Boolean):void {
			if ($b) {
				if (!(this.target in masterList)) {
					masterList[this.target] = [this];
				} else {
					var a:Array = masterList[this.target], found:Boolean, i:int;
					for (i = a.length - 1; i > -1; i--) {
						if (a[i] == this) {
							found = true;
							break;
						}
					}
					if (!found) {
						a[a.length] = this;
					}
				}
			}
			this.gc = ($b) ? false : true;
			if (this.gc) {
				this.active = false;
			} else {
				this.active = this.started;
			}
		}
	}
	
}