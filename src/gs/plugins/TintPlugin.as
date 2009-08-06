/*
VERSION: 1.1
DATE: 2/27/2009
ACTIONSCRIPT VERSION: 3.0 (AS2 version is also available)
UPDATES & MORE DETAILED DOCUMENTATION AT: http://www.TweenMax.com
DESCRIPTION:
	To change a DisplayObject's tint/color, set this to the hex value of the tint you'd like
	to end up at (or begin at if you're using TweenMax.from()). An example hex value would be 0xFF0000.
	
	To remove a tint completely, use the RemoveTintPlugin (after activating it, you can just set removeTint:true)
	
USAGE:
	import gs.*;
	import gs.plugins.*;
	TweenPlugin.activate([TintPlugin]); //only do this once in your SWF to activate the plugin (it is already activated in TweenLite and TweenMax by default)
	
	TweenLite.to(mc, 1, {tint:0xFF0000});

	
BYTES ADDED TO SWF: 436 (not including dependencies)

AUTHOR: Jack Doyle, jack@greensock.com
Copyright 2009, GreenSock. All rights reserved. This work is subject to the terms in http://www.greensock.com/terms_of_use.html or for corporate Club GreenSock members, the software agreement that was issued with the corporate membership.
*/

package gs.plugins {
	import flash.display.*;
	import flash.geom.ColorTransform;
	
	import gs.*;
	import gs.utils.tween.TweenInfo;
	
	public class TintPlugin extends TweenPlugin {
		public static const VERSION:Number = 1.1;
		public static const API:Number = 1.0; //If the API/Framework for plugins changes in the future, this number helps determine compatibility
		protected static var _props:Array = ["redMultiplier", "greenMultiplier", "blueMultiplier", "alphaMultiplier", "redOffset", "greenOffset", "blueOffset", "alphaOffset"];
		
		protected var _target:DisplayObject;
		protected var _ct:ColorTransform;
		protected var _ignoreAlpha:Boolean;
		
		public function TintPlugin() {
			super();
			this.propName = "tint"; 
			this.overwriteProps = ["tint"];
		}
		
		override public function onInitTween($target:Object, $value:*, $tween:TweenLite):Boolean {
			if (!($target is DisplayObject)) {
				return false;
			}
			var end:ColorTransform = new ColorTransform();
			if ($value != null && $tween.exposedVars.removeTint != true) {
				end.color = uint($value);
			}
			_ignoreAlpha = true;
			init($target as DisplayObject, end);
			return true;
		}
		
		public function init($target:DisplayObject, $end:ColorTransform):void {
			_target = $target;
			_ct = _target.transform.colorTransform;
			var i:int, p:String;
			for (i = _props.length - 1; i > -1; i--) {
				p = _props[i];
				if (_ct[p] != $end[p]) {
					_tweens[_tweens.length] = new TweenInfo(_ct, p, _ct[p], $end[p] - _ct[p], "tint", false);
				}
			}
		}
		
		override public function set changeFactor($n:Number):void {
			updateTweens($n);
			if (_ignoreAlpha) {
				var ct:ColorTransform = _target.transform.colorTransform;
				_ct.alphaMultiplier = ct.alphaMultiplier;
				_ct.alphaOffset = ct.alphaOffset;
			}
			_target.transform.colorTransform = _ct;			
		}
		
	}
}