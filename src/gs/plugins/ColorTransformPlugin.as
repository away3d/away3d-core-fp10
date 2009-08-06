/*
VERSION: 1.01
DATE: 1/29/2009
ACTIONSCRIPT VERSION: 3.0 (AS2 version is also available)
UPDATES & MORE DETAILED DOCUMENTATION AT: http://www.TweenMax.com
DESCRIPTION:
	Ever wanted to tween ColorTransform properties of a DisplayObject to do advanced effects like overexposing, altering
	the brightness or setting the percent/amount of tint? Or maybe you wanted to tween individual ColorTransform 
	properties like redMultiplier, redOffset, blueMultiplier, blueOffset, etc. This class gives you an easy way to 
	do just that. 
	
	PROPERTIES:
		- tint (or color) : uint - Color of the tint. Use a hex value, like 0xFF0000 for red.
		- tintAmount : Number - Number between 0 and 1. Works with the "tint" property and indicats how much of an effect the tint should have. 0 makes the tint invisible, 0.5 is halfway tinted, and 1 is completely tinted.
		- brightness : Number - Number between 0 and 2 where 1 is normal brightness, 0 is completely dark/black, and 2 is completely bright/white
		- exposure : Number - Number between 0 and 2 where 1 is normal exposure, 0, is completely underexposed, and 2 is completely overexposed. Overexposing an object is different then changing the brightness - it seems to almost bleach the image and looks more dynamic and interesting (subjectively speaking). 
		- redOffset : Number
		- greenOffset : Number
		- blueOffset : Number
		- alphaOffset : Number
		- redMultiplier : Number
		- greenMultiplier : Number
		- blueMultiplier : Number
		- alphaMultiplier : Number
	
USAGE:
	import gs.*;
	import gs.plugins.*;
	TweenPlugin.activate([ColorTransformPlugin]); //only do this once in your SWF to activate the plugin (it is already activated in TweenLite and TweenMax by default)
	
	TweenLite.to(mc, 1, {colorTransform:{tint:0xFF0000, tintAmount:0.5});

	
BYTES ADDED TO SWF: 371 (not including dependencies)

AUTHOR: Jack Doyle, jack@greensock.com
Copyright 2009, GreenSock. All rights reserved. This work is subject to the terms in http://www.greensock.com/terms_of_use.html or for corporate Club GreenSock members, the software agreement that was issued with the corporate membership.
*/

package gs.plugins {
	import flash.display.*;
	import flash.geom.ColorTransform;
	
	import gs.*;
	
	public class ColorTransformPlugin extends TintPlugin {
		public static const VERSION:Number = 1.01;
		public static const API:Number = 1.0; //If the API/Framework for plugins changes in the future, this number helps determine compatibility
		
		public function ColorTransformPlugin() {
			super();
			this.propName = "colorTransform"; 
		}
		
		override public function onInitTween($target:Object, $value:*, $tween:TweenLite):Boolean {
			if (!($target is DisplayObject)) {
				return false;
			}
			var end:ColorTransform = $target.transform.colorTransform;
			if ($value.isTV == true) {
				$value = $value.exposedVars; //for compatibility with TweenLiteVars and TweenMaxVars
			}
			for (var p:String in $value) {
				if (p == "tint" || p == "color") {
					if ($value[p] != null) {
						end.color = int($value[p]);
					}
				} else if (p == "tintAmount" || p == "exposure" || p == "brightness") {
					//handle this later...
				} else {
					end[p] = $value[p];
				}
			}
			
			if (!isNaN($value.tintAmount)) {
				var ratio:Number = $value.tintAmount / (1 - ((end.redMultiplier + end.greenMultiplier + end.blueMultiplier) / 3));
				end.redOffset *= ratio;
				end.greenOffset *= ratio;
				end.blueOffset *= ratio;
				end.redMultiplier = end.greenMultiplier = end.blueMultiplier = 1 - $value.tintAmount;
			} else if (!isNaN($value.exposure)) {
				end.redOffset = end.greenOffset = end.blueOffset = 255 * ($value.exposure - 1);
				end.redMultiplier = end.greenMultiplier = end.blueMultiplier = 1;
			} else if (!isNaN($value.brightness)) {
				end.redOffset = end.greenOffset = end.blueOffset = Math.max(0, ($value.brightness - 1) * 255);
				end.redMultiplier = end.greenMultiplier = end.blueMultiplier = 1 - Math.abs($value.brightness - 1);
			}
			
			if ($tween.exposedVars.alpha != undefined && $value.alphaMultiplier == undefined) {
				end.alphaMultiplier = $tween.exposedVars.alpha;
				$tween.killVars({alpha:1});
			}
			
			init($target as DisplayObject, end);
			
			return true;
		}
		
	}
}