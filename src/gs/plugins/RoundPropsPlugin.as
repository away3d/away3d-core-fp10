/*
VERSION: 1.0
DATE: 12/30/2008
ACTIONSCRIPT VERSION: 3.0 (AS2 version is also available)
UPDATES & MORE DETAILED DOCUMENTATION AT: http://www.TweenMax.com
DESCRIPTION:
	If you'd like the inbetween values in a tween to always get rounded to the nearest integer, use the roundProps
	special property. Just pass in an Array containing the property names that you'd like rounded. For example,
	if you're tweening the x, y, and alpha properties of mc and you want to round the x and y values (not alpha)
	every time the tween is rendered, you'd do: 
		
		TweenMax.to(mc, 2, {x:300, y:200, alpha:0.5, roundProps:["x","y"]});

	roundProps requires TweenMax! TweenLite tweens will not round properties.
	
	
USAGE:
	(this plugin is activated by default in TweenMax and cannot be activated in TweenLite)
	
	import gs.*;
	
	TweenMax.to(mc, 2, {x:300, y:200, alpha:0.5, roundProps:["x","y"]});
	
	
BYTES ADDED TO SWF: 158 (not including dependencies)

AUTHOR: Jack Doyle, jack@greensock.com
Copyright 2009, GreenSock. All rights reserved. This work is subject to the terms in http://www.greensock.com/terms_of_use.html or for corporate Club GreenSock members, the software agreement that was issued with the corporate membership.
*/

package gs.plugins {
	import flash.display.*;
	import gs.*;
	
	public class RoundPropsPlugin extends TweenPlugin {
		public static const VERSION:Number = 1.0;
		public static const API:Number = 1.0; //If the API/Framework for plugins changes in the future, this number helps determine compatibility
		
		public function RoundPropsPlugin() {
			super();
			this.propName = "roundProps";
			this.overwriteProps = [];
			this.round = true;
		}
		
		public function add($object:Object, $propName:String, $start:Number, $change:Number):void {
			addTween($object, $propName, $start, $start + $change, $propName);
			this.overwriteProps[this.overwriteProps.length] = $propName;
		}

	}
}