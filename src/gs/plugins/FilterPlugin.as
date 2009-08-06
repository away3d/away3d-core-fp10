/*
VERSION: 1.03
DATE: 1/24/2009
ACTIONSCRIPT VERSION: 3.0 (AS2 version is also available)
UPDATES & MORE DETAILED DOCUMENTATION AT: http://www.TweenMax.com
DESCRIPTION:
	Base class for all filter plugins (like BlurFilter, colorMatrixFilter, etc.). Handles common routines.
	
USAGE:
	filter plugins extend this class.

	
BYTES ADDED TO SWF: 672 (1kb) (not including dependencies)

AUTHOR: Jack Doyle, jack@greensock.com
Copyright 2009, GreenSock. All rights reserved. This work is subject to the terms in http://www.greensock.com/terms_of_use.html or for corporate Club GreenSock members, the software agreement that was issued with the corporate membership.
*/

package gs.plugins {
	import flash.display.*;
	import flash.filters.*;
	
	import gs.*;
	import gs.utils.tween.TweenInfo;
	
	public class FilterPlugin extends TweenPlugin {		
		public static const VERSION:Number = 1.03;
		public static const API:Number = 1.0; //If the API/Framework for plugins changes in the future, this number helps determine compatibility
		
		protected var _target:Object;
		protected var _type:Class;
		protected var _filter:BitmapFilter;
		protected var _index:int;
		protected var _remove:Boolean;
		
		public function FilterPlugin() {
			super();
		}
		
		protected function initFilter($props:Object, $default:BitmapFilter):void {
			var filters:Array = _target.filters, p:String, i:int, colorTween:HexColorsPlugin;
			_index = -1;
			if ($props.index != null) {
				_index = $props.index;
			} else {
				for (i = filters.length - 1; i > -1; i--) {
					if (filters[i] is _type) {
						_index = i;
						break;
					}
				}
			}
			if (_index == -1 || filters[_index] == null || $props.addFilter == true) {
				_index = ($props.index != null) ? $props.index : filters.length;
				filters[_index] = $default;
				_target.filters = filters;
			}
			_filter = filters[_index];
			
			_remove = Boolean($props.remove == true);
			if (_remove) {
				this.onComplete = onCompleteTween;
			}
			var props:Object = ($props.isTV == true) ? $props.exposedVars : $props; //accommodates TweenLiteVars and TweenMaxVars
			for (p in props) {
				if (!(p in _filter) || _filter[p] == props[p] || p == "remove" || p == "index" || p == "addFilter") {
					//ignore
				} else {
					if (p == "color" || p == "highlightColor" || p == "shadowColor") {
						colorTween = new HexColorsPlugin();
						colorTween.initColor(_filter, p, _filter[p], props[p]);
						_tweens[_tweens.length] = new TweenInfo(colorTween, "changeFactor", 0, 1, p, false);
					} else if (p == "quality" || p == "inner" || p == "knockout" || p == "hideObject") {
						_filter[p] = props[p];
					} else {
						addTween(_filter, p, _filter[p], props[p], p);
					}
				}
			}
		}
		
		public function onCompleteTween():void {
			if (_remove) {
				var i:int, filters:Array = _target.filters;
				if (!(filters[_index] is _type)) { //a filter may have been added or removed since the tween began, changing the index.
					for (i = filters.length - 1; i > -1; i--) {
						if (filters[i] is _type) {
							filters.splice(i, 1);
							break;
						}
					}
				} else {
					filters.splice(_index, 1);
				}
				_target.filters = filters;
			}
		}
		
		override public function set changeFactor($n:Number):void {
			var i:int, ti:TweenInfo, filters:Array = _target.filters;
			for (i = _tweens.length - 1; i > -1; i--) {
				ti = _tweens[i];
				ti.target[ti.property] = ti.start + (ti.change * $n);
			}
			
			if (!(filters[_index] is _type)) { //a filter may have been added or removed since the tween began, changing the index.
				_index = filters.length - 1; //default (in case it was removed)
				for (i = filters.length - 1; i > -1; i--) {
					if (filters[i] is _type) {
						_index = i;
						break;
					}
				}
			}
			filters[_index] = _filter;
			_target.filters = filters;
		}
		
	}
}