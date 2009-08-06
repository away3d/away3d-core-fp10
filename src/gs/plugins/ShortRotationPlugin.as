/*
VERSION: 1.0
DATE: 1/8/2009
ACTIONSCRIPT VERSION: 3.0 (AS2 version is also available)
UPDATES & MORE DETAILED DOCUMENTATION AT: http://www.TweenMax.com
DESCRIPTION:
	To tween any rotation property of the target object in the shortest direction, use "shortRotation" 
	For example, if myObject.rotation is currently 170 degrees and you want to tween it to -170 degrees, 
	a normal rotation tween would travel a total of 340 degrees in the counter-clockwise direction, 
	but if you use shortRotation, it would travel 20 degrees in the clockwise direction instead. You 
	can define any number of rotation properties in the shortRotation object which makes 3D tweening
	easier, like TweenMax.to(mc, 2, {shortRotation:{rotationX:-170, rotationY:35, rotationZ:200}});
	
USAGE:
	import gs.*;
	import gs.plugins.*;
	TweenPlugin.activate([ShortRotationPlugin]); //only do this once in your SWF to activate the plugin in TweenLite (it is already activated in TweenMax by default)
	
	TweenLite.to(mc, 1, {shortRotation:{rotation:-170}});
	
	//or for a 3D tween with multiple rotation values...
	TweenLite.to(mc, 1, {shortRotation:{rotationX:-170, rotationY:35, rotationZ:10}});

	
BYTES ADDED TO SWF: 361 (not including dependencies)

AUTHOR: Jack Doyle, jack@greensock.com
Copyright 2009, GreenSock. All rights reserved. This work is subject to the terms in http://www.greensock.com/terms_of_use.html or for corporate Club GreenSock members, the software agreement that was issued with the corporate membership.
*/

package gs.plugins {
	import flash.display.*;
	import gs.*;
	
	public class ShortRotationPlugin extends TweenPlugin {
		public static const VERSION:Number = 1.0;
		public static const API:Number = 1.0; //If the API/Framework for plugins changes in the future, this number helps determine compatibility
		
		public function ShortRotationPlugin() {
			super();
			this.propName = "shortRotation";
			this.overwriteProps = [];
		}
		
		override public function onInitTween($target:Object, $value:*, $tween:TweenLite):Boolean {
			if (typeof($value) == "number") {
				trace("WARNING: You appear to be using the old shortRotation syntax. Instead of passing a number, please pass an object with properties that correspond to the rotations values For example, TweenMax.to(mc, 2, {shortRotation:{rotationX:-170, rotationY:25}})");
				return false;
			}
			for (var p:String in $value) {
				initRotation($target, p, $target[p], $value[p]);
			}
			return true;
		}
		
		public function initRotation($target:Object, $propName:String, $start:Number, $end:Number):void {
			var dif:Number = ($end - $start) % 360;
			if (dif != dif % 180) {
				dif = (dif < 0) ? dif + 360 : dif - 360;
			}
			addTween($target, $propName, $start, $start + dif, $propName);
			this.overwriteProps[this.overwriteProps.length] = $propName;
		}	

	}
}