/*
VERSION: 1.01
DATE: 2/17/2009
ACTIONSCRIPT VERSION: 3.0 (AS2 version is also available)
UPDATES & MORE DETAILED DOCUMENTATION AT: http://www.TweenMax.com
DESCRIPTION:
	Tweens the volume of an object with a soundTransform property (MovieClip/SoundChannel/NetStream, etc.)
	
USAGE:
	import gs.*;
	import gs.plugins.*;
	TweenPlugin.activate([VolumePlugin]); //only do this once in your SWF to activate the plugin (it is already activated in TweenLite and TweenMax by default)
	
	TweenLite.to(mc, 1, {volume:0});
	
	
BYTES ADDED TO SWF: 275 (not including dependencies)

AUTHOR: Jack Doyle, jack@greensock.com
Copyright 2009, GreenSock. All rights reserved. This work is subject to the terms in http://www.greensock.com/terms_of_use.html or for corporate Club GreenSock members, the software agreement that was issued with the corporate membership.
*/

package gs.plugins {
	import flash.display.*;
	import flash.media.SoundTransform;
	import gs.*;
	import gs.plugins.*;
	
	public class VolumePlugin extends TweenPlugin {
		public static const VERSION:Number = 1.01;
		public static const API:Number = 1.0; //If the API/Framework for plugins changes in the future, this number helps determine compatibility
		
		protected var _target:Object;
		protected var _st:SoundTransform;
		
		public function VolumePlugin() {
			super();
			this.propName = "volume";
			this.overwriteProps = ["volume"];
		}
		
		override public function onInitTween($target:Object, $value:*, $tween:TweenLite):Boolean {
			if (isNaN($value) || !$target.hasOwnProperty("soundTransform")) {
				return false;
			}
			_target = $target;
			_st = _target.soundTransform;
			addTween(_st, "volume", _st.volume, $value, "volume");
			return true;
		}
		
		override public function set changeFactor($n:Number):void {
			updateTweens($n);
			_target.soundTransform = _st;
		}
		

	}
}