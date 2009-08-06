/*
VERSION: 1.01
DATE: 2/6/2009
ACTIONSCRIPT VERSION: 3.0 (AS2 version is also available)
UPDATES & MORE DETAILED DOCUMENTATION AT: http://www.TweenMax.com
DESCRIPTION:
	Some components require resizing with setSize() instead of standard tweens of width/height in
	order to scale properly. The SetSizePlugin accommodates this easily. You can define the width, 
	height, or both.
	
USAGE:
	import gs.*;
	import gs.plugins.*;
	TweenPlugin.activate([SetSizePlugin]); //only do this once in your SWF to activate the plugin
	
	TweenLite.to(myComponent, 1, {setSize:{width:200, height:30}});
	
	
BYTES ADDED TO SWF: 365 (not including dependencies)

AUTHOR: Jack Doyle, jack@greensock.com
Copyright 2009, GreenSock. All rights reserved. This work is subject to the terms in http://www.greensock.com/terms_of_use.html or for corporate Club GreenSock members, the software agreement that was issued with the corporate membership.
*/

package gs.plugins {
	import flash.display.*;
	
	import gs.*;
	
	public class SetSizePlugin extends TweenPlugin {
		public static const VERSION:Number = 1.01;
		public static const API:Number = 1.0; //If the API/Framework for plugins changes in the future, this number helps determine compatibility
		
		public var width:Number;
		public var height:Number;
		
		protected var _target:Object;
		protected var _setWidth:Boolean;
		protected var _setHeight:Boolean;
		protected var _hasSetSize:Boolean;
		
		public function SetSizePlugin() {
			super();
			this.propName = "setSize";
			this.overwriteProps = ["setSize","width","height","scaleX","scaleY"];
			this.round = true;
		}
		
		override public function onInitTween($target:Object, $value:*, $tween:TweenLite):Boolean {
			_target = $target;
			_hasSetSize = Boolean("setSize" in _target);
			if ("width" in $value && _target.width != $value.width) {
				addTween((_hasSetSize) ? this : _target, "width", _target.width, $value.width, "width");
				_setWidth = _hasSetSize;
			}
			if ("height" in $value && _target.height != $value.height) {
				addTween((_hasSetSize) ? this : _target, "height", _target.height, $value.height, "height");
				_setHeight = _hasSetSize;
			}			
			return true;
		}
		
		override public function killProps($lookup:Object):void {
			super.killProps($lookup);
			if (_tweens.length == 0 || "setSize" in $lookup) {
				this.overwriteProps = [];
			}
		}
		
		override public function set changeFactor($n:Number):void {
			updateTweens($n);
			if (_hasSetSize) {
				_target.setSize((_setWidth) ? this.width : _target.width, (_setHeight) ? this.height : _target.height);
			}
		}
		

	}
}