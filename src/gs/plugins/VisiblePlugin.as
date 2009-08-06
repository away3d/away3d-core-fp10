/*
VERSION: 1.0
DATE: 1/8/2009
ACTIONSCRIPT VERSION: 3.0 (AS2 version is also available)
UPDATES & MORE DETAILED DOCUMENTATION AT: http://www.TweenMax.com
DESCRIPTION:
	Toggles the visibility at the end of a tween. For example, if you want to set visible to false
	at the end of the tween, do TweenLite.to(mc, 1, {x:100, visible:false});
	
	The visible property is forced to true during the course of the tween.
	
USAGE:
	import gs.*;
	import gs.plugins.*;
	TweenPlugin.activate([VisiblePlugin]); //only do this once in your SWF to activate the plugin (it is already activated in TweenLite and TweenMax by default)
	
	TweenLite.to(mc, 1, {x:100, visible:false});
	
	
BYTES ADDED TO SWF: 244 (not including dependencies)

AUTHOR: Jack Doyle, jack@greensock.com
Copyright 2009, GreenSock. All rights reserved. This work is subject to the terms in http://www.greensock.com/terms_of_use.html or for corporate Club GreenSock members, the software agreement that was issued with the corporate membership.
*/

package gs.plugins {
	import flash.display.*;
	import gs.*;
	
	public class VisiblePlugin extends TweenPlugin {
		public static const VERSION:Number = 1.0;
		public static const API:Number = 1.0; //If the API/Framework for plugins changes in the future, this number helps determine compatibility
		
		protected var _target:Object;
		protected var _tween:TweenLite;
		protected var _visible:Boolean;
		
		public function VisiblePlugin() {
			super();
			this.propName = "visible";
			this.overwriteProps = ["visible"];
			this.onComplete = onCompleteTween;
		}
		
		override public function onInitTween($target:Object, $value:*, $tween:TweenLite):Boolean {
			_target = $target;
			_tween = $tween;
			_visible = Boolean($value);
			return true;
		}
		
		public function onCompleteTween():void {
			if (_tween.vars.runBackwards != true && _tween.ease == _tween.vars.ease) { //_tween.ease == _tween.vars.ease checks to make sure the tween wasn't reversed with a TweenGroup
				_target.visible = _visible;
			}
		}
		
		override public function set changeFactor($n:Number):void {
			if (_target.visible != true) {
				_target.visible = true;
			}
		}

	}
}