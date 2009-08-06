/*
VERSION: 1.01
DATE: 2/23/2009
ACTIONSCRIPT VERSION: 3.0 (AS2 version is also available)
UPDATES & MORE DETAILED DOCUMENTATION AT: http://www.TweenMax.com
DESCRIPTION:
	Tweens a MovieClip to a particular frame label
	
USAGE:
	import gs.*;
	import gs.plugins.*;
	TweenPlugin.activate([FrameLabelPlugin]); //only do this once in your SWF to activate the plugin in TweenLite (it is already activated in TweenMax by default)
	
	TweenLite.to(mc, 1, {frameLabel:"myLabel"});

	
BYTES ADDED TO SWF: 222 (not including dependencies)

AUTHOR: Jack Doyle, jack@greensock.com
Copyright 2009, GreenSock. All rights reserved. This work is subject to the terms in http://www.greensock.com/terms_of_use.html or for corporate Club GreenSock members, the software agreement that was issued with the corporate membership.
*/

package gs.plugins {
	import flash.display.*;
	import gs.*;
	import gs.plugins.*;
	
	public class FrameLabelPlugin extends FramePlugin {
		public static const VERSION:Number = 1.01;
		public static const API:Number = 1.0; //If the API/Framework for plugins changes in the future, this number helps determine compatibility
		
		public function FrameLabelPlugin() {
			super();
			this.propName = "frameLabel";
		}
		
		override public function onInitTween($target:Object, $value:*, $tween:TweenLite):Boolean {
			if (!$tween.target is MovieClip) {
				return false;
			}
			_target = $target as MovieClip;
			this.frame = _target.currentFrame;
			var labels:Array = _target.currentLabels, label:String = $value, endFrame:int = _target.currentFrame, i:int;
			for (i = labels.length - 1; i > -1; i--) {
				if (labels[i].name == label) {
					endFrame = labels[i].frame;
					break;
				}
			}
			if (this.frame != endFrame) {
				addTween(this, "frame", this.frame, endFrame, "frame");
			}
			return true;
		}
		

	}
}