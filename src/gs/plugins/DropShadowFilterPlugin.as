/*
VERSION: 1.0
DATE: 1/8/2009
ACTIONSCRIPT VERSION: 3.0 (AS2 version is also available)
UPDATES & MORE DETAILED DOCUMENTATION AT: http://www.TweenMax.com
DESCRIPTION:
	Tweens a DropShadowFilter. The following properties are available (you only need to define the ones you want to tween):
	
		- distance : Number [0]
		- angle : Number [45]
		- color : uint [0x000000]
		- alpha :Number [0]
		- blurX : Number [0]
		- blurY : Number [0]
		- strength : Number [1]
		- quality : uint [2]
		- inner : Boolean [false]
		- knockout : Boolean [false]
		- hideObject : Boolean [false]
		- index : uint
		- addFilter : Boolean [false]
		- remove : Boolean [false]
		
	Set remove to true if you want the filter to be removed when the tween completes.
	
USAGE:
	import gs.*;
	import gs.plugins.*;
	TweenPlugin.activate([DropShadowFilterPlugin]); //only do this once in your SWF to activate the plugin in TweenLite (it is already activated in TweenMax by default)
	
	TweenLite.to(mc, 1, {dropShadowFilter:{blurX:5, blurY:5, distance:5, alpha:0.6}});
	
	
BYTES ADDED TO SWF: 184 (not including dependencies)

AUTHOR: Jack Doyle, jack@greensock.com
Copyright 2009, GreenSock. All rights reserved. This work is subject to the terms in http://www.greensock.com/terms_of_use.html or for corporate Club GreenSock members, the software agreement that was issued with the corporate membership.
*/

package gs.plugins {
	import flash.filters.*;
	import flash.display.*;
	import gs.*;
	
	public class DropShadowFilterPlugin extends FilterPlugin {		
		public static const VERSION:Number = 1.0;
		public static const API:Number = 1.0; //If the API/Framework for plugins changes in the future, this number helps determine compatibility
		
		public function DropShadowFilterPlugin() {
			super();
			this.propName = "dropShadowFilter";
			this.overwriteProps = ["dropShadowFilter"];
		}
		
		override public function onInitTween($target:Object, $value:*, $tween:TweenLite):Boolean {
			_target = $target;
			_type = DropShadowFilter;
			initFilter($value, new DropShadowFilter(0, 45, 0x000000, 0, 0, 0, 1, $value.quality || 2, $value.inner, $value.knockout, $value.hideObject));
			return true;
		}
		
	}
}