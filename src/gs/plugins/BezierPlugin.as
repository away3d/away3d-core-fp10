/*
VERSION: 1.01
DATE: 1/22/2009
ACTIONSCRIPT VERSION: 3.0 (AS2 version is also available)
UPDATES & MORE DETAILED DOCUMENTATION AT: http://www.TweenMax.com
DESCRIPTION:
	Bezier tweening allows you to tween in a non-linear way. For example, you may want to tween
	a MovieClip's position from the origin (0,0) 500 pixels to the right (500,0) but curve downwards
	through the middle of the tween. Simply pass as many objects in the bezier array as you'd like, 
	one for each "control point" (see documentation on Flash's curveTo() drawing method for more
	about how control points work).
	
	Keep in mind that you can bezier tween ANY properties, not just x/y. 
	
	Also, if you'd like to rotate the target in the direction of the bezier path, 
	use the orientToBeizer special property. In order to alter a rotation property accurately, 
	TweenLite/Max needs 4 pieces of information: 
		1) Position property 1 (typically "x")
		2) Position property 2 (typically "y")
		3) Rotational property (typically "rotation")
		4) Number of degrees to add (optional - makes it easy to orient your MovieClip properly)
	The orientToBezier property should be an Array containing one Array for each set of these values. 
	For maximum flexibility, you can pass in any number of arrays inside the container array, one 
	for each rotational property. This can be convenient when working in 3D because you can rotate
	on multiple axis. If you're doing a standard 2D x/y tween on a bezier, you can simply pass 
	in a boolean value of true and TweenLite/Max will use a typical setup, [["x", "y", "rotation", 0]]. 
	Hint: Don't forget the container Array (notice the double outer brackets)
	
	
USAGE:
	import gs.*;
	import gs.plugins.*;
	TweenPlugin.activate([BezierPlugin]); //only do this once in your SWF to activate the plugin in TweenLite (it is already activated in TweenMax by default)
	
	TweenLite.to(my_mc, 3, {bezier:[{x:250, y:50}, {x:500, y:0}]}); //makes my_mc travel through 250,50 and end up at 500,0.
	
	
BYTES ADDED TO SWF: 1215 (not including dependencies)

AUTHOR: Jack Doyle, jack@greensock.com
Copyright 2009, GreenSock. All rights reserved. This work is subject to the terms in http://www.greensock.com/terms_of_use.html or for corporate Club GreenSock members, the software agreement that was issued with the corporate membership.
*/

package gs.plugins {
	import gs.*;
	import gs.utils.tween.*;
	
	public class BezierPlugin extends TweenPlugin {
		public static const VERSION:Number = 1.01;
		public static const API:Number = 1.0; //If the API/Framework for plugins changes in the future, this number helps determine compatibility
		
		protected static const _RAD2DEG:Number = 180 / Math.PI; //precalculate for speed
		
		protected var _target:Object;
		protected var _orientData:Array;
		protected var _orient:Boolean;
		protected var _future:Object = {}; //used for orientToBezier projections
		protected var _beziers:Object;
		
		public function BezierPlugin() {
			super();
			this.propName = "bezier"; //name of the special property that the plugin should intercept/manage
			this.overwriteProps = []; //will be populated in init()
		}
		
		override public function onInitTween($target:Object, $value:*, $tween:TweenLite):Boolean {
			if (!($value is Array)) {
				return false;
			}
			init($tween, $value as Array, false);
			return true;
		}
		
		protected function init($tween:TweenLite, $beziers:Array, $through:Boolean):void {
			_target = $tween.target;
			if ($tween.exposedVars.orientToBezier == true) {
				_orientData = [["x", "y", "rotation", 0]];
				_orient = true;
			} else if ($tween.exposedVars.orientToBezier is Array) {
				_orientData = $tween.exposedVars.orientToBezier;
				_orient = true;
			}
			var props:Object = {}, i:int, p:String;
			for (i = 0; i < $beziers.length; i++) {
				for (p in $beziers[i]) {
					if (props[p] == undefined) {
						props[p] = [$tween.target[p]];
					}
					if (typeof($beziers[i][p]) == "number") {
						props[p].push($beziers[i][p]);
					} else {
						props[p].push($tween.target[p] + Number($beziers[i][p])); //relative value
					}
				}
			}
			for (p in props) {
				this.overwriteProps[this.overwriteProps.length] = p;
				if ($tween.exposedVars[p] != undefined) {
					if (typeof($tween.exposedVars[p]) == "number") {
						props[p].push($tween.exposedVars[p]);
					} else {
						props[p].push($tween.target[p] + Number($tween.exposedVars[p])); //relative value
					}
					delete $tween.exposedVars[p]; //prevent TweenLite from creating normal tweens of the bezier properties.
					for (i = $tween.tweens.length - 1; i > -1; i--) {
						if ($tween.tweens[i].name == p) {
							$tween.tweens.splice(i, 1); //delete any normal tweens of the bezier properties. 
						}
					}
				}
			}
			_beziers = parseBeziers(props, $through);
		}
		
		public static function parseBeziers($props:Object, $through:Boolean=false):Object { //$props object should contain a property for each one you'd like bezier paths for. Each property should contain a single Array with the numeric point values (i.e. props.x = [12,50,80] and props.y = [50,97,158]). It'll return a new object with an array of values for each property. The first element in the array  is the start value, the second is the control point, and the 3rd is the end value. (i.e. returnObject.x = [[12, 32, 50}, [50, 65, 80]])
			var i:int, a:Array, b:Object, p:String;
			var all:Object = {};
			if ($through) {
				for (p in $props) {
					a = $props[p];
					all[p] = b = [];
					if (a.length > 2) {
						b[b.length] = [a[0], a[1] - ((a[2] - a[0]) / 4), a[1]];
						for (i = 1; i < a.length - 1; i++) {
							b[b.length] = [a[i], a[i] + (a[i] - b[i - 1][1]), a[i + 1]];
						}
					} else {
						b[b.length] = [a[0], (a[0] + a[1]) / 2, a[1]];
					}
				}
			} else {
				for (p in $props) {
					a = $props[p];
					all[p] = b = [];
					if (a.length > 3) {
						b[b.length] = [a[0], a[1], (a[1] + a[2]) / 2];
						for (i = 2; i < a.length - 2; i++) {
							b[b.length] = [b[i - 2][2], a[i], (a[i] + a[i + 1]) / 2];
						}
						b[b.length] = [b[b.length - 1][2], a[a.length - 2], a[a.length - 1]];
					} else if (a.length == 3) {
						b[b.length] = [a[0], a[1], a[2]];
					} else if (a.length == 2) {
						b[b.length] = [a[0], (a[0] + a[1]) / 2, a[1]];
					}
				}
			}
			return all;
		}
		
		override public function killProps($lookup:Object):void {
			for (var p:String in _beziers) {
				if (p in $lookup) {
					delete _beziers[p];
				}
			}
			super.killProps($lookup);
		}	
		
		override public function set changeFactor($n:Number):void {
			var i:int, p:String, b:Object, t:Number, segments:uint, val:Number, neg:int;
			if ($n == 1) { //to make sure the end values are EXACTLY what they need to be.
				for (p in _beziers) {
					i = _beziers[p].length - 1;
					_target[p] = _beziers[p][i][2];
				}
			} else {
				for (p in _beziers) {
					segments = _beziers[p].length;
					if ($n < 0) {
						i = 0;
					} else if ($n >= 1) {
						i = segments - 1;
					} else {
						i = int(segments * $n);
					}
					t = ($n - (i * (1 / segments))) * segments;
					b = _beziers[p][i];
					if (this.round) {
						val = b[0] + t * (2 * (1 - t) * (b[1] - b[0]) + t * (b[2] - b[0]));
						neg = (val < 0) ? -1 : 1;
						_target[p] = ((val % 1) * neg > 0.5) ? int(val) + neg : int(val); //twice as fast as Math.round()
					} else {
						_target[p] = b[0] + t * (2 * (1 - t) * (b[1] - b[0]) + t * (b[2] - b[0]));
					}
				}
			}
			
			if (_orient) {
				var oldTarget:Object = _target, oldRound:Boolean = this.round;
				_target = _future;
				this.round = false;
				_orient = false;
				this.changeFactor = $n + 0.01;
				_target = oldTarget;
				this.round = oldRound;
				_orient = true;
				var dx:Number, dy:Number, cotb:Array, toAdd:Number;
				for (i = 0; i < _orientData.length; i++) {
					cotb = _orientData[i]; //current orientToBezier Array
					toAdd = cotb[3] || 0;
					dx = _future[cotb[0]] - _target[cotb[0]];
					dy = _future[cotb[1]] - _target[cotb[1]];
					_target[cotb[2]] = Math.atan2(dy, dx) * _RAD2DEG + toAdd;
				}
			}
			
		}
		
	}
}