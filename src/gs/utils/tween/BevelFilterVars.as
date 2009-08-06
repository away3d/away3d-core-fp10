/*
VERSION: 1.01
DATE: 1/29/2009
ACTIONSCRIPT VERSION: 3.0
DESCRIPTION:
	This class works in conjunction with the TweenLiteVars or TweenMaxVars class to grant
	strict data typing and code hinting (in most code editors) for filter tweens. See the documentation 
	in TweenMaxVars for more information.

USAGE:
	
	Instead of TweenMax.to(my_mc, 1, {bevelFilter:{distance:5, blurX:10, blurY:10, strength:2}, onComplete:myFunction}), you could use this utility like:
	
		var myVars:TweenMaxVars = new TweenMaxVars();
		myVars.bevelFilter = new BevelFilterVars(5, 10, 10, 2);
		myVars.onComplete = myFunction;
		TweenMax.to(my_mc, 1, myVars);
		
		
NOTES:
	- This utility is completely optional. If you prefer the shorter synatax in the regular TweenMax class, feel
	  free to use it. The purpose of this utility is simply to enable code hinting and to allow for strict data typing.
	- You cannot define relative tween values with this utility. If you need relative values, just use the shorter (non strictly 
	  data typed) syntax, like TweenMax.to(my_mc, 1, {bevelFilter:{blurX:"-5", blurY:"3"}});

AUTHOR: Jack Doyle, jack@greensock.com
Copyright 2009, GreenSock. All rights reserved. This work is subject to the terms in http://www.greensock.com/terms_of_use.html or for corporate Club GreenSock members, the software agreement that was issued with the corporate membership.
*/


package gs.utils.tween {
	
	public class BevelFilterVars extends FilterVars {
		
		protected var _distance:Number;
		protected var _blurX:Number;
		protected var _blurY:Number;
		protected var _strength:Number; 
		protected var _angle:Number;
		protected var _highlightAlpha:Number;
		protected var _highlightColor:uint;
		protected var _shadowAlpha:Number;
		protected var _shadowColor:uint;
		protected var _quality:uint;
		
		public function BevelFilterVars($distance:Number=4, $blurX:Number=4, $blurY:Number=4, $strength:Number=1, $angle:Number=45, $highlightAlpha:Number=1, $highlightColor:uint=0xFFFFFF, $shadowAlpha:Number=1, $shadowColor:uint=0x000000, $quality:uint=2, $remove:Boolean=false, $index:int=-1, $addFilter:Boolean=false) {
			super($remove, $index, $addFilter);
			this.distance = $distance;
			this.blurX = $blurX;
			this.blurY = $blurY;
			this.strength = $strength;
			this.angle = $angle;
			this.highlightAlpha = $highlightAlpha;
			this.highlightColor = $highlightColor;
			this.shadowAlpha = $shadowAlpha;
			this.shadowColor = $shadowColor;
			this.quality = $quality;
		}
		
		public static function createFromGeneric($vars:Object):BevelFilterVars { //for parsing values that are passed in as generic Objects, like blurFilter:{blurX:5, blurY:3} (typically via the constructor)
			if ($vars is BevelFilterVars) {
				return $vars as BevelFilterVars;
			}
			return new BevelFilterVars($vars.distance || 0,
									   $vars.blurX || 0,
									   $vars.blurY || 0,
									   ($vars.strength == null) ? 1 : $vars.strength,
									   ($vars.angle == null) ? 45 : $vars.angle,
									   ($vars.highlightAlpha == null) ? 1 : $vars.highlightAlpha,
									   ($vars.highlightColor == null) ? 0xFFFFFF : $vars.highlightColor,
									   ($vars.shadowAlpha == null) ? 1 : $vars.shadowAlpha,
									   ($vars.shadowColor == null) ? 0xFFFFFF : $vars.shadowColor,
									   $vars.quality || 2,
									   $vars.remove || false,
									   ($vars.index == null) ? -1 : $vars.index,
									   $vars.addFilter || false);
		}
		
//---- GETTERS / SETTERS --------------------------------------------------------------------------------------------
		
		public function set distance($n:Number):void {
			_distance = this.exposedVars.distance = $n;
		}
		public function get distance():Number {
			return _distance;
		}
		public function set blurX($n:Number):void {
			_blurX = this.exposedVars.blurX = $n;
		}
		public function get blurX():Number {
			return _blurX;
		}
		public function set blurY($n:Number):void {
			_blurY = this.exposedVars.blurY = $n;
		}
		public function get blurY():Number {
			return _blurY;
		}
		public function set strength($n:Number):void { 
			_strength = this.exposedVars.strength = $n;
		}
		public function get strength():Number {
			return _strength;
		}
		public function set angle($n:Number):void {
			_angle = this.exposedVars.angle = $n;
		}
		public function get angle():Number {
			return _angle;
		}
		public function set highlightAlpha($n:Number):void {
			_highlightAlpha = this.exposedVars.highlightAlpha = $n;
		}
		public function get highlightAlpha():Number {
			return _highlightAlpha;
		}
		public function set highlightColor($n:uint):void {
			_highlightColor = this.exposedVars.highlightColor = $n;
		}
		public function get highlightColor():uint {
			return _highlightColor;
		}
		public function set shadowAlpha($n:Number):void {
			_shadowAlpha = this.exposedVars.shadowAlpha = $n;
		}
		public function get shadowAlpha():Number {
			return _shadowAlpha;
		}
		public function set shadowColor($n:uint):void {
			_shadowColor = this.exposedVars.shadowColor = $n;
		}
		public function get shadowColor():uint {
			return _shadowColor;
		}
		public function set quality($n:uint):void {
			_quality = this.exposedVars.quality = $n;
		}
		public function get quality():uint {
			return _quality;
		}

	}
	
}