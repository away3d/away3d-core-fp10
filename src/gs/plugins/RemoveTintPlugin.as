/*
VERSION: 1.01
DATE: 1/23/2009
ACTIONSCRIPT VERSION: 3.0 (AS2 version is also available)
UPDATES & MORE DETAILED DOCUMENTATION AT: http://www.TweenMax.com
DESCRIPTION:
	Removes the tint of a DisplayObject over time. 
	
USAGE:
	import gs.*;
	import gs.plugins.*;
	TweenPlugin.activate([RemoveTintPlugin]); //only do this once in your SWF to activate the plugin (it is already activated in TweenLite and TweenMax by default)
	
	TweenLite.to(mc, 1, {removeTint:true});
	
	
BYTES ADDED TO SWF: 61 (not including dependencies)

AUTHOR: Jack Doyle, jack@greensock.com
Copyright 2009, GreenSock. All rights reserved. This work is subject to the terms in http://www.greensock.com/terms_of_use.html or for corporate Club GreenSock members, the software agreement that was issued with the corporate membership.
*/

package gs.plugins {
	import flash.display.*;
	import flash.geom.ColorTransform;
	import gs.*;
	import gs.plugins.*;
	
	public class RemoveTintPlugin extends TintPlugin {
		public static const VERSION:Number = 1.01;
		public static const API:Number = 1.0; //If the API/Framework for plugins changes in the future, this number helps determine compatibility
		
		public function RemoveTintPlugin() {
			super();
			this.propName = "removeTint";
		}

	}
}