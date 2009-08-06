/*
VERSION: 1.0
DATE: 1/29/2009
ACTIONSCRIPT VERSION: 3.0
DESCRIPTION:
	This class works in conjunction with the TweenLiteVars or TweenMaxVars class to grant
	strict data typing and code hinting (in most code editors) for transformAroundPoint tweens. See the documentation in
	the TweenLiteVars or TweenMaxVars for more information.

USAGE:
	
	Instead of TweenMax.to(my_mc, 1, {transformAroundPoint:{point:new Point(100, 50), scaleX:2, scaleY:1.5, rotation:30}}, onComplete:myFunction}), you could use this utility like:
	
		var myVars:TweenMaxVars = new TweenMaxVars();
		myVars.transformAroundPoint = new TransformAroundPointVars(new Point(100, 50), 2, 1.5, 30);
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
	import flash.geom.Point;
	
	public class TransformAroundPointVars extends SubVars {
		
		public function TransformAroundPointVars($point:Point=null, $scaleX:Number=NaN, $scaleY:Number=NaN, $rotation:Number=NaN, $width:Number=NaN, $height:Number=NaN, $shortRotation:Object=null, $x:Number=NaN, $y:Number=NaN) {
			super();
			if ($point != null) {
				this.point = $point;
			}
			if (!isNaN($scaleX)) {
				this.scaleX = $scaleX;
			}
			if (!isNaN($scaleY)) {
				this.scaleY = $scaleY;
			}
			if (!isNaN($rotation)) {
				this.rotation = $rotation;
			}
			if (!isNaN($width)) {
				this.width = $width;
			}
			if (!isNaN($height)) {
				this.height = $height;
			}
			if ($shortRotation != null) {
				this.shortRotation = $shortRotation;
			}
			if (!isNaN($x)) {
				this.x = $x;
			}
			if (!isNaN($y)) {
				this.y = $y;
			}
		}
		
		public static function createFromGeneric($vars:Object):TransformAroundPointVars { //for parsing values that are passed in as generic Objects, like blurFilter:{blurX:5, blurY:3} (typically via the constructor)
			if ($vars is TransformAroundPointVars) {
				return $vars as TransformAroundPointVars;
			}
			return new TransformAroundPointVars($vars.point,
												$vars.scaleX,
												$vars.scaleY,
												$vars.rotation,
												$vars.width,
												$vars.height,
												$vars.shortRotation,
												$vars.x,
												$vars.y);
		}
		
//---- GETTERS / SETTERS ------------------------------------------------------------------------------
		
		public function set point($p:Point):void {
			this.exposedVars.point = $p;
		}
		public function get point():Point {
			return this.exposedVars.point;
		}
		public function set scaleX($n:Number):void {
			this.exposedVars.scaleX = $n;
		}
		public function get scaleX():Number {
			return Number(this.exposedVars.scaleX);
		}
		public function set scaleY($n:Number):void {
			this.exposedVars.scaleY = $n;
		}
		public function get scaleY():Number {
			return Number(this.exposedVars.scaleY);
		}
		public function set scale($n:Number):void {
			this.exposedVars.scale = $n;
		}
		public function get scale():Number {
			return Number(this.exposedVars.scale);
		}
		public function set rotation($n:Number):void {
			this.exposedVars.rotation = $n;
		}
		public function get rotation():Number {
			return Number(this.exposedVars.rotation);
		}
		public function set width($n:Number):void {
			this.exposedVars.width = $n;
		}
		public function get width():Number {
			return Number(this.exposedVars.width);
		}
		public function set height($n:Number):void {
			this.exposedVars.height = $n;
		}
		public function get height():Number {
			return Number(this.exposedVars.height);
		}
		public function set shortRotation($o:Object):void {
			this.exposedVars.shortRotation = $o;
		}
		public function get shortRotation():Object {
			return this.exposedVars.shortRotation;
		}
		public function set x($n:Number):void {
			this.exposedVars.x = $n;
		}
		public function get x():Number {
			return Number(this.exposedVars.x);
		}
		public function set y($n:Number):void {
			this.exposedVars.y = $n;
		}
		public function get y():Number {
			return Number(this.exposedVars.y);
		}

	}
}