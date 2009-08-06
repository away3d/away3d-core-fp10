/*
VERSION: 1.0
DATE: 1/8/2009
ACTIONSCRIPT VERSION: 3.0 (AS2 version is also available)
UPDATES & MORE DETAILED DOCUMENTATION AT: http://www.TweenMax.com
DESCRIPTION:
	Identical to bezier except that instead of defining bezier control point values, you
	define points through which the bezier values should move. This can be more intuitive
	than using control points. Simply pass as many objects in the bezier Array as you'd like, 
	one for each point through which the values should travel. For example, if you want the
	curved motion path to travel through the coordinates x:250, y:100 and x:50, y:200 and then
	end up at 500, 100, you'd do:
	
	TweenLite.to(mc, 2, {bezierThrough:[{x:250, y:100}, {x:50, y:200}, {x:500, y:200}]});
	
	Keep in mind that you can bezierThrough tween ANY properties, not just x/y. 
	
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
	TweenPlugin.activate([BezierThroughPlugin]); //only do this once in your SWF to activate the plugin in TweenLite (it is already activated in TweenMax by default)
	
	TweenLite.to(mc, 2, {bezierThrough:[{x:250, y:100}, {x:50, y:200}, {x:500, y:200}]});
	
BYTES ADDED TO SWF: 116 (not including dependencies)

AUTHOR: Jack Doyle, jack@greensock.com
Copyright 2009, GreenSock. All rights reserved. This work is subject to the terms in http://www.greensock.com/terms_of_use.html or for corporate Club GreenSock members, the software agreement that was issued with the corporate membership.
*/

package gs.plugins {
	import gs.*;
	
	public class BezierThroughPlugin extends BezierPlugin {
		public static const VERSION:Number = 1.0;
		public static const API:Number = 1.0; //If the API/Framework for plugins changes in the future, this number helps determine compatibility
		
		public function BezierThroughPlugin() {
			super();
			this.propName = "bezierThrough"; //name of the special property that the plugin should intercept/manage
		}
		
		override public function onInitTween($target:Object, $value:*, $tween:TweenLite):Boolean {
			if (!($value is Array)) {
				return false;
			}
			init($tween, $value as Array, true);
			return true;	
		}
		
		
	}
}