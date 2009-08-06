/*
VERSION: 1.0
DATE: 1/8/2009
ACTIONSCRIPT VERSION: 3.0 (AS2 version is also available)
UPDATES & MORE DETAILED DOCUMENTATION AT: http://www.TweenMax.com
DESCRIPTION:
	Use autoAlpha instead of the alpha property to gain the additional feature of toggling 
	the "visible" property to false if/when alpha reaches 0. It will also toggle visible 
	to true before the tween starts if the value of autoAlpha is greater than zero.
	
USAGE:
	import gs.*;
	import gs.plugins.*;
	TweenPlugin.activate([AutoAlphaPlugin]); //only do this once in your SWF to activate the plugin (it is already activated in TweenLite and TweenMax by default)
	
	TweenLite.to(mc, 1, {autoAlpha:0});
	
BYTES ADDED TO SWF: 339 (0.3kb) (not including dependencies)

AUTHOR: Jack Doyle, jack@greensock.com
Copyright 2009, GreenSock. All rights reserved. This work is subject to the terms in http://www.greensock.com/terms_of_use.html or for corporate Club GreenSock members, the software agreement that was issued with the corporate membership.
*/

package gs.plugins {
	import flash.display.*;
	
	import gs.*;
	
	public class AutoAlphaPlugin extends TweenPlugin {
		public static const VERSION:Number = 1.0;
		public static const API:Number = 1.0; //If the API/Framework for plugins changes in the future, this number helps determine compatibility
		
		protected var _tweenVisible:Boolean;
		protected var _visible:Boolean;
		protected var _tween:TweenLite;
		protected var _target:Object;
		
		public function AutoAlphaPlugin() {
			super();
			this.propName = "autoAlpha";
			this.overwriteProps = ["alpha","visible"];
			this.onComplete = onCompleteTween;
		}
		
		override public function onInitTween($target:Object, $value:*, $tween:TweenLite):Boolean {
			_target = $target;
			_tween = $tween;
			_visible = Boolean($value != 0);
			_tweenVisible = true;
			addTween($target, "alpha", $target.alpha, $value, "alpha");
			return true;
		}
		
		override public function killProps($lookup:Object):void {
			super.killProps($lookup);
			_tweenVisible = !Boolean("visible" in $lookup);
		}
		
		public function onCompleteTween():void {
			if (_tweenVisible && _tween.vars.runBackwards != true && _tween.ease == _tween.vars.ease) { //_tween.ease == _tween.vars.ease checks to make sure the tween wasn't reversed with a TweenGroup
				_target.visible = _visible;
			}
		}
		
		override public function set changeFactor($n:Number):void {
			updateTweens($n);
			if (_target.visible != true && _tweenVisible) {
				_target.visible = true;
			}
		}
		
	}
}