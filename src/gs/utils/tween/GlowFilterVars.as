/*
VERSION: 1.01
DATE: 1/29/2009
ACTIONSCRIPT VERSION: 3.0
DESCRIPTION:
	This class works in conjunction with the TweenLiteVars or TweenMaxVars class to grant
	strict data typing and code hinting (in most code editors) for filter tweens. See the documentation in
	the TweenLiteVars, or TweenMaxVars for more information.

USAGE:
	
	Instead of TweenMax.to(my_mc, 1, {glowFilter:{blurX:10, blurY:10, color:0xFF0000}, onComplete:myFunction}), you could use this utility like:
	
		var myVars:TweenMaxVars = new TweenMaxVars();
		myVars.glowFilter = new GlowFilterVars(10, 10);
		myVars.onComplete = myFunction;
		TweenMax.to(my_mc, 1, myVars);
		
		
NOTES:
	- This utility is completely optional. If you prefer the shorter synatax in the regular TweenLite/TweenMax class, feel
	  free to use it. The purpose of this utility is simply to enable code hinting and to allow for strict data typing.
	- You cannot define relative tween values with this utility. If you need relative values, just use the shorter (non strictly 
	  data typed) syntax, like TweenMax.to(my_mc, 1, {glowFilter:{blurX:"-5", blurY:"3"}});

AUTHOR: Jack Doyle, jack@greensock.com
Copyright 2009, GreenSock. All rights reserved. This work is subject to the terms in http://www.greensock.com/terms_of_use.html or for corporate Club GreenSock members, the software agreement that was issued with the corporate membership.
*/


package gs.utils.tween {
	
	public class GlowFilterVars extends FilterVars {		
		protected var _blurX:Number;
		protected var _blurY:Number;
		protected var _color:uint;
		protected var _alpha:Number;
		protected var _strength:Number; 
		protected var _inner:Boolean;
		protected var _knockout:Boolean;
		protected var _quality:uint;
		
		public function GlowFilterVars($blurX:Number=10, $blurY:Number=10, $color:uint=0xFFFFFF, $alpha:Number=1, $strength:Number=2, $inner:Boolean=false, $knockout:Boolean=false, $quality:uint=2, $remove:Boolean=false, $index:int=-1, $addFilter:Boolean=false) {
			super($remove, $index, $addFilter);
			this.blurX = $blurX;
			this.blurY = $blurY;
			this.color = $color;
			this.alpha = $alpha;
			this.strength = $strength;
			this.inner = $inner;
			this.knockout = $knockout;
			this.quality = $quality;
		}
		
		public static function createFromGeneric($vars:Object):GlowFilterVars { //for parsing values that are passed in as generic Objects, like blurFilter:{blurX:5, blurY:3} (typically via the constructor)
			if ($vars is GlowFilterVars) {
				return $vars as GlowFilterVars;
			}
			return new GlowFilterVars($vars.blurX || 0,
									  $vars.blurY || 0,
									  ($vars.color == null) ? 0x000000 : $vars.color,
									  $vars.alpha || 0,
									  ($vars.strength == null) ? 2 : $vars.strength,
									  Boolean($vars.inner),
									  Boolean($vars.knockout),
									  $vars.quality || 2,
									  $vars.remove || false,
									  ($vars.index == null) ? -1 : $vars.index,
									  $vars.addFilter || false);
		}
		
//---- GETTERS / SETTERS -------------------------------------------------------------------------------------
		
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
		public function set color($n:uint):void {
			_color = this.exposedVars.color = $n;
		}
		public function get color():uint {
			return _color;
		}
		public function set alpha($n:Number):void {
			_alpha = this.exposedVars.alpha = $n;
		}
		public function get alpha():Number {
			return _alpha;
		}
		public function set strength($n:Number):void { 
			_strength = this.exposedVars.strength = $n;
		}
		public function get strength():Number {
			return _strength;
		}
		public function set inner($b:Boolean):void {
			_inner = this.exposedVars.inner = $b;
		}
		public function get inner():Boolean {
			return _inner;
		}
		public function set knockout($b:Boolean):void {
			_knockout = this.exposedVars.knockout = $b;
		}
		public function get knockout():Boolean {
			return _knockout;
		}
		public function set quality($n:uint):void {
			_quality = this.exposedVars.quality = $n;
		}
		public function get quality():uint {
			return _quality;
		}
		

	}
	
}