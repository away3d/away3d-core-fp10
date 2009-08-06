/*
VERSION: 1.0
DATE: 1/29/2009
ACTIONSCRIPT VERSION: 3.0
DESCRIPTION:
	This class works in conjunction with the TweenLiteVars or TweenMaxVars class to grant
	strict data typing and code hinting (in most code editors) for colorTransform tweens. See the documentation in
	the TweenLiteVars or TweenMaxVars for more information.

USAGE:
	
	Instead of TweenMax.to(my_mc, 1, {colorTransform:{exposure:2}}, onComplete:myFunction}), you could use this utility like:
	
		var myVars:TweenMaxVars = new TweenMaxVars();
		var ct:ColorTransformVars = new ColorTransformVars();
		ct.exposure = 2;
		myVars.colorTransform = ct;
		myVars.onComplete = myFunction;
		TweenMax.to(my_mc, 1, myVars);
		
		
NOTES:
	- This utility is completely optional. If you prefer the shorter synatax in the regular TweenLite/TweenMax class, feel
	  free to use it. The purpose of this utility is simply to enable code hinting and to allow for strict data typing.
	- You cannot define relative tween values with this utility. 

AUTHOR: Jack Doyle, jack@greensock.com
Copyright 2009, GreenSock. All rights reserved. This work is subject to the terms in http://www.greensock.com/terms_of_use.html or for corporate Club GreenSock members, the software agreement that was issued with the corporate membership.
*/


package gs.utils.tween {
	
	public class ColorTransformVars extends SubVars {
		
		public function ColorTransformVars($tint:Number=NaN, $tintAmount:Number=NaN, $exposure:Number=NaN, $brightness:Number=NaN, $redMultiplier:Number=NaN, $greenMultiplier:Number=NaN, $blueMultiplier:Number=NaN, $alphaMultiplier:Number=NaN, $redOffset:Number=NaN, $greenOffset:Number=NaN, $blueOffset:Number=NaN, $alphaOffset:Number=NaN) {
			super();
			if (!isNaN($tint)) {
				this.tint = uint($tint);
			}
			if (!isNaN($tintAmount)) {
				this.tintAmount = $tintAmount;
			}
			if (!isNaN($exposure)) {
				this.exposure = $exposure;
			}
			if (!isNaN($brightness)) {
				this.brightness = $brightness;
			}
			if (!isNaN($redMultiplier)) {
				this.redMultiplier = $redMultiplier;
			}
			if (!isNaN($greenMultiplier)) {
				this.greenMultiplier = $greenMultiplier;
			}
			if (!isNaN($blueMultiplier)) {
				this.blueMultiplier = $blueMultiplier;
			}
			if (!isNaN($alphaMultiplier)) {
				this.alphaMultiplier = $alphaMultiplier;
			}
			if (!isNaN($redOffset)) {
				this.redOffset = $redOffset;
			}
			if (!isNaN($greenOffset)) {
				this.greenOffset = $greenOffset;
			}
			if (!isNaN($blueOffset)) {
				this.blueOffset = $blueOffset;
			}
			if (!isNaN($alphaOffset)) {
				this.alphaOffset = $alphaOffset;
			}
		}
		
		public static function createFromGeneric($vars:Object):ColorTransformVars { //for parsing values that are passed in as generic Objects, like blurFilter:{blurX:5, blurY:3} (typically via the constructor)
			if ($vars is ColorTransformVars) {
				return $vars as ColorTransformVars;
			}
			return new ColorTransformVars($vars.tint,
										  $vars.tintAmount,
										  $vars.exposure, 
										  $vars.brightness,
										  $vars.redMultiplier,
										  $vars.greenMultiplier,
										  $vars.blueMultiplier,
										  $vars.alphaMultiplier,
										  $vars.redOffset,
										  $vars.greenOffset,
										  $vars.blueOffset,
										  $vars.alphaOffset);
		}
		
//---- GETTERS / SETTERS ------------------------------------------------------------------------------
		
		public function set tint($n:Number):void {
			this.exposedVars.tint = $n;
		}
		public function get tint():Number {
			return Number(this.exposedVars.tint);
		}
		public function set tintAmount($n:Number):void {
			this.exposedVars.tintAmount = $n;
		}
		public function get tintAmount():Number {
			return Number(this.exposedVars.tintAmount);
		}
		public function set exposure($n:Number):void {
			this.exposedVars.exposure = $n;
		}
		public function get exposure():Number {
			return Number(this.exposedVars.exposure);
		}
		public function set brightness($n:Number):void {
			this.exposedVars.brightness = $n;
		}
		public function get brightness():Number {
			return Number(this.exposedVars.brightness);
		}
		public function set redMultiplier($n:Number):void {
			this.exposedVars.redMultiplier = $n;
		}
		public function get redMultiplier():Number {
			return Number(this.exposedVars.redMultiplier);
		}
		public function set greenMultiplier($n:Number):void {
			this.exposedVars.greenMultiplier = $n;
		}
		public function get greenMultiplier():Number {
			return Number(this.exposedVars.greenMultiplier);
		}
		public function set blueMultiplier($n:Number):void {
			this.exposedVars.blueMultiplier = $n;
		}
		public function get blueMultiplier():Number {
			return Number(this.exposedVars.blueMultiplier);
		}
		public function set alphaMultiplier($n:Number):void {
			this.exposedVars.alphaMultiplier = $n;
		}
		public function get alphaMultiplier():Number {
			return Number(this.exposedVars.alphaMultiplier);
		}
		public function set redOffset($n:Number):void {
			this.exposedVars.redOffset = $n;
		}
		public function get redOffset():Number {
			return Number(this.exposedVars.redOffset);
		}
		public function set greenOffset($n:Number):void {
			this.exposedVars.greenOffset = $n;
		}
		public function get greenOffset():Number {
			return Number(this.exposedVars.greenOffset);
		}
		public function set blueOffset($n:Number):void {
			this.exposedVars.blueOffset = $n;
		}
		public function get blueOffset():Number {
			return Number(this.exposedVars.blueOffset);
		}
		public function set alphaOffset($n:Number):void {
			this.exposedVars.alphaOffset = $n;
		}
		public function get alphaOffset():Number {
			return Number(this.exposedVars.alphaOffset);
		}

	}
}