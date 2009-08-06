/*
VERSION: 1.01
DATE: 2/23/2009
ACTIONSCRIPT VERSION: 3.0 (AS2 version is also available)
UPDATES & MORE DETAILED DOCUMENTATION AT: http://www.TweenMax.com
DESCRIPTION:
	Tweens a MovieClip to a particular frame number
	
USAGE:
	import gs.*;
	import gs.plugins.*;
	TweenPlugin.activate([FrameLabelPlugin]); //only do this once in your SWF to activate the plugin (it is already activated in TweenLite and TweenMax by default)
	
	TweenLite.to(mc, 1, {frame:125});
	
	
BYTES ADDED TO SWF: 218 (not including dependencies)

AUTHOR: Jack Doyle, jack@greensock.com
Copyright 2009, GreenSock. All rights reserved. This work is subject to the terms in http://www.greensock.com/terms_of_use.html or for corporate Club GreenSock members, the software agreement that was issued with the corporate membership.
*/

package gs.plugins {
	import flash.display.*;
	import gs.*;
	
	public class FramePlugin extends TweenPlugin {
		public static const VERSION:Number = 1.01;
		public static const API:Number = 1.0; //If the API/Framework for plugins changes in the future, this number helps determine compatibility
		
		public var frame:int;
		protected var _target:MovieClip;
		
		public function FramePlugin() {
			super();
			this.propName = "frame";
			this.overwriteProps = ["frame"];
			this.round = true;
		}
		
		override public function onInitTween($target:Object, $value:*, $tween:TweenLite):Boolean {
			if (!($target is MovieClip) || isNaN($value)) {
				return false;
			}
			_target = $target as MovieClip;
			this.frame = _target.currentFrame;
			addTween(this, "frame", this.frame, $value, "frame");
			return true;
		}
		
		override public function set changeFactor($n:Number):void {
			updateTweens($n);
			_target.gotoAndStop(this.frame);
		}
		

	}
}