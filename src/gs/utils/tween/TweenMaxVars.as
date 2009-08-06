/*
VERSION: 2.01
DATE: 1/19/2009
ACTIONSCRIPT VERSION: 3.0
DESCRIPTION:
	There are 2 primary benefits of using this utility to define your TweenMax variables:
		1) In most code editors, code hinting will be activated which helps remind you which special properties are available in TweenMax
		2) It allows you to code using strict datatyping (although it doesn't force you to).

USAGE:
	
	Instead of TweenMax.to(my_mc, 1, {x:300, tint:0xFF0000, onComplete:myFunction}), you could use this utility like:
	
		var myVars:TweenMaxVars = new TweenMaxVars();
		myVars.addProp("x", 300); // use addProp() to add any property that doesn't already exist in the TweenMaxVars instance.
		myVars.tint = 0xFF0000;
		myVars.onComplete = myFunction;
		TweenMax.to(my_mc, 1, myVars);
		
	Or if you just want to add multiple properties with one function, you can add up to 15 with the addProps() function, like:
	
		var myVars:TweenMaxVars = new TweenMaxVars();
		myVars.addProps("x", 300, false, "y", 100, false, "scaleX", 1.5, false, "scaleY", 1.5, false);
		myVars.onComplete = myFunction;
		TweenMax.to(my_mc, 1, myVars);
		
NOTES:
	- This class adds about 14 Kb to your published SWF.
	- This utility is completely optional. If you prefer the shorter synatax in the regular TweenMax class, feel
	  free to use it. The purpose of this utility is simply to enable code hinting and to allow for strict datatyping.
	- You may add custom properties to this class if you want, but in order to expose them to TweenMax, make sure
	  you also add a getter and a setter that adds the property to the _exposedVars Object.
	- You can reuse a single TweenMaxVars Object for multiple tweens if you want, but be aware that there are a few
	  properties that must be handled in a special way, and once you set them, you cannot remove them. Those properties
	  are: frame, visible, tint, and volume. If you are altering these values, it might be better to avoid reusing a TweenMaxVars
	  Object.

AUTHOR: Jack Doyle, jack@greensock.com
Copyright 2009, GreenSock. All rights reserved. This work is subject to the terms in http://www.greensock.com/terms_of_use.html or for corporate Club GreenSock members, the software agreement that was issued with the corporate membership.
*/

package gs.utils.tween {
	import gs.utils.tween.TweenLiteVars;

	dynamic public class TweenMaxVars extends TweenLiteVars {
		public static const version:Number = 2.01;
		/**
		 * A function to which the TweenMax instance should dispatch a TweenEvent when it begins. This is the same as doing myTweenMaxInstance.addEventListener(TweenEvent.START, myFunction); 
		 */
		public var onStartListener:Function;
		/**
		 * A function to which the TweenMax instance should dispatch a TweenEvent every time it updates values. This is the same as doing myTweenMaxInstance.addEventListener(TweenEvent.UPDATE, myFunction); 
		 */
		public var onUpdateListener:Function;
		/**
		 * A function to which the TweenMax instance should dispatch a TweenEvent when it completes. This is the same as doing myTweenMaxInstance.addEventListener(TweenEvent.COMPLETE, myFunction); 
		 */
		public var onCompleteListener:Function;
		/**
		 * To make the tween reverse when it completes (like a yoyo) any number of times, set this to the number of cycles you'd like the tween to yoyo. A value of zero causes the tween to yoyo endlessly.
		 */
		public var yoyo:Number;
		/**
		 * To make the tween repeat when it completes any number of times, set this to the number of cycles you'd like the tween to loop. A value of zero causes the tween to loop endlessly.
		 */
		public var loop:Number;
		
		protected var _roundProps:Array;
		
		/**
		 * @param $vars An Object containing properties that correspond to the properties you'd like to add to this TweenMaxVars Object. For example, TweenMaxVars({blurFilter:{blurX:10, blurY:20}, onComplete:myFunction})
		 */
		public function TweenMaxVars($vars:Object = null) {
			super($vars);
		}
		
		/**
		 * Clones the TweenMaxVars object.
		 */
		override public function clone():TweenLiteVars {
			var vars:Object = {protectedVars:{}};
			appendCloneVars(vars, vars.protectedVars);
			return new TweenMaxVars(vars);
		}
		
		/**
		 * Works with clone() to copy all the necessary properties. Split apart from clone() to take advantage of inheritence
		 */
		override protected function appendCloneVars($vars:Object, $protectedVars:Object):void {
			super.appendCloneVars($vars, $protectedVars);
			var props:Array = ["onStartListener","onUpdateListener","onCompleteListener","onCompleteAllListener","yoyo","loop"];
			for (var i:int = props.length - 1; i > -1; i--) {
				$vars[props[i]] = this[props[i]];
			}
			$protectedVars._roundProps = _roundProps;
		}
		
		
//---- GETTERS / SETTERS ---------------------------------------------------------------------------------------------
		
		/**
		 * @param $a An Array of the names of properties that should be rounded to the nearest integer when tweening
		 */
		public function set roundProps($a:Array):void {
			_roundProps = _exposedVars.roundProps = $a;
		}
		public function get roundProps():Array {
			return _roundProps;
		}
		
		
	}
}