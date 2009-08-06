/*
VERSION: 1.01
DATE: 2/5/2009
ACTIONSCRIPT VERSION: 3.0 (AS2 version is also available)
UPDATES & MORE DETAILED DOCUMENTATION AT: http://www.TweenMax.com
DESCRIPTION:
	Although hex colors are technically numbers, if you try to tween them conventionally, 
	you'll notice that they don't tween smoothly. To tween them properly, the red, green, and 
	blue components must be extracted and tweened independently. The HexColorsPlugin makes it easy. 
	To tween a property of your object that's a hex color to another hex color, just pass a hexColors 
	Object with properties named the same as your object's hex color properties. For example, 
	if myObject has a "myHexColor" property that you'd like to tween to red (0xFF0000) over the 
	course of 2 seconds, you'd do:
		
		TweenMax.to(myObject, 2, {hexColors:{myHexColor:0xFF0000}});
		
	You can pass in any number of hexColor properties.
	
USAGE:
	import gs.*;
	import gs.plugins.*;
	TweenPlugin.activate([HexColorsPlugin]); //only do this once in your SWF to activate the plugin in TweenLite (it is already activated in TweenMax by default)
	
	TweenLite.to(myObject, 2, {hexColors:{myHexColor:0xFF0000}});
	
	or if you just want to tween a color and apply it somewhere on every frame, you could do:
	
	var myColor:Object = {hex:0xFF0000};
	TweenLite.to(myColor, 2, {hexColors:{hex:0x0000FF}, onUpdate:applyColor});
	function applyColor():void {
		mc.graphics.clear();
		mc.graphics.beginFill(myColor.hex, 1);
		mc.graphics.drawRect(0, 0, 100, 100);
		mc.graphics.endFill();		
	}
	
	
BYTES ADDED TO SWF: 389 (not including dependencies)

AUTHOR: Jack Doyle, jack@greensock.com
Copyright 2009, GreenSock. All rights reserved. This work is subject to the terms in http://www.greensock.com/terms_of_use.html or for corporate Club GreenSock members, the software agreement that was issued with the corporate membership.
*/

package gs.plugins {
	import flash.display.*;
	import gs.*;
	
	public class HexColorsPlugin extends TweenPlugin {
		public static const VERSION:Number = 1.01;
		public static const API:Number = 1.0; //If the API/Framework for plugins changes in the future, this number helps determine compatibility
		
		protected var _colors:Array;
		
		public function HexColorsPlugin() {
			super();
			this.propName = "hexColors";
			this.overwriteProps = [];
			_colors = [];
		}
		
		override public function onInitTween($target:Object, $value:*, $tween:TweenLite):Boolean {
			for (var p:String in $value) {
				initColor($target, p, uint($target[p]), uint($value[p]));
			}
			return true;
		}
		
		public function initColor($target:Object, $propName:String, $start:uint, $end:uint):void {
			if ($start != $end) {
				var r:Number = $start >> 16;
				var g:Number = ($start >> 8) & 0xff;
				var b:Number = $start & 0xff;
				_colors[_colors.length] = [$target, 
										   $propName, 
										   r,
										   ($end >> 16) - r,
										   g,
										   (($end >> 8) & 0xff) - g,
										   b,
										   ($end & 0xff) - b];
				this.overwriteProps[this.overwriteProps.length] = $propName;
			}
		}
		
		override public function killProps($lookup:Object):void {
			for (var i:int = _colors.length - 1; i > -1; i--) {
				if ($lookup[_colors[i][1]] != undefined) {
					_colors.splice(i, 1);
				}
			}
			super.killProps($lookup);
		}	
		
		override public function set changeFactor($n:Number):void {
			var i:int, a:Array;
			for (i = _colors.length - 1; i > -1; i--) {
				a = _colors[i];
				a[0][a[1]] = ((a[2] + ($n * a[3])) << 16 | (a[4] + ($n * a[5])) << 8 | (a[6] + ($n * a[7])));
			}
		}
		

	}
}