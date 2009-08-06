/*
VERSION: 1.01
DATE: 1/10/2009
ACTIONSCRIPT VERSION: 3.0 (AS2 version is also available)
UPDATES & MORE DETAILED DOCUMENTATION AT: http://www.TweenMax.com
DESCRIPTION:
	Tweens numbers in an Array. 
	
USAGE:
	import gs.*;
	import gs.plugins.*;
	TweenPlugin.activate([EndArrayPlugin]); //only do this once in your SWF to activate the plugin (it is already activated in TweenLite and TweenMax by default)

	var myArray:Array = [1,2,3,4];
	TweenMax.to(myArray, 1.5, {endArray:[10,20,30,40]});

	
BYTES ADDED TO SWF: 278 (not including dependencies)

AUTHOR: Jack Doyle, jack@greensock.com
Copyright 2009, GreenSock. All rights reserved. This work is subject to the terms in http://www.greensock.com/terms_of_use.html or for corporate Club GreenSock members, the software agreement that was issued with the corporate membership.
*/

package gs.plugins {
	import flash.display.*;
	
	import gs.*;
	import gs.utils.tween.*;
	
	public class EndArrayPlugin extends TweenPlugin {
		public static const VERSION:Number = 1.01;
		public static const API:Number = 1.0; //If the API/Framework for plugins changes in the future, this number helps determine compatibility
		
		protected var _a:Array;
		protected var _info:Array = [];
		
		public function EndArrayPlugin() {
			super();
			this.propName = "endArray"; //name of the special property that the plugin should intercept/manage
			this.overwriteProps = ["endArray"];
		}
		
		override public function onInitTween($target:Object, $value:*, $tween:TweenLite):Boolean {
			if (!($target is Array) || !($value is Array)) {
				return false;
			}
			init($target as Array, $value);
			return true;
		}
		
		public function init($start:Array, $end:Array):void {
			_a = $start;
			for (var i:int = $end.length - 1; i > -1; i--) {
				if ($start[i] != $end[i] && $start[i] != null) {
					_info[_info.length] = new ArrayTweenInfo(i, _a[i], $end[i] - _a[i]);
				}
			}
		}
		
		override public function set changeFactor($n:Number):void {
			var i:int, ti:ArrayTweenInfo;
			if (this.round) {
				var val:Number, neg:int;
				for (i = _info.length - 1; i > -1; i--) {
					ti = _info[i];
					val = ti.start + (ti.change * $n);
					neg = (val < 0) ? -1 : 1;
					_a[ti.index] = ((val % 1) * neg > 0.5) ? int(val) + neg : int(val); //twice as fast as Math.round()
				}
			} else {
				for (i = _info.length - 1; i > -1; i--) {
					ti = _info[i];
					_a[ti.index] = ti.start + (ti.change * $n);
				}
			}
		}
		

	}
}