package away3d.core.utils 
{
	import away3d.arcane;
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.math.*;
	import away3d.core.render.*;
	import away3d.core.session.*;
	import away3d.core.vos.*;
	import away3d.lights.*;
	
	import flash.display.*;
	
	use namespace arcane;
	
	/**
	 * @author robbateman
	 */
	public class FaceNormalShader 
	{
		private var _session:AbstractSession;
		private var focus:Number;
        private var zoom:Number;
        private var persp:Number;
        private var v0x:Number;
        private var v0y:Number;
        private var v0z:Number;
        private var v1x:Number;
        private var v1y:Number;
        private var v1z:Number;
        private var v2x:Number;
        private var v2y:Number;
        private var v2z:Number;
        private var d1x:Number;
        private var d1y:Number;
        private var d1z:Number;
        private var d2x:Number;
        private var d2y:Number;
        private var d2z:Number;
        private var pa:Number;
        private var pb:Number;
        private var pc:Number;
        private var pdd:Number;
        private var c0x:Number;
        private var c0y:Number;
        private var c0z:Number;
        private var kar:Number;
        private var kag:Number;
        private var kab:Number;
        private var kdr:Number;
        private var kdg:Number;
        private var kdb:Number;
        private var ksr:Number;
        private var ksg:Number;
        private var ksb:Number;
        private var red:Number;
        private var green:Number;
        private var blue:Number;
        private var dfx:Number;
        private var dfy:Number;
        private var dfz:Number;
        private var df:Number;
        private var nx:Number;
        private var ny:Number;
        private var nz:Number;
        private var fade:Number;
        private var amb:Number;
        private var nf:Number;
        private var diff:Number;
        private var rfx:Number;
        private var rfy:Number;
        private var rfz:Number;
        private var spec:Number;
        private var rf:Number;
        private var graphics:Graphics;
        private var cz:Number;
        private var cx:Number;
        private var cy:Number;
        private var ncz:Number;
        private var ncx:Number;
        private var ncy:Number;
        private var sum:Number;
        private var ffz:Number;
        private var ffx:Number;
        private var ffy:Number;
        private var fz:Number;
        private var fx:Number;
        private var fy:Number;
        private var rz:Number;
        private var rx:Number;
        private var ry:Number;
        private var draw_normal:Boolean = false;
        private var draw_fall:Boolean = false;
        private var draw_fall_k:Number = 1;
        private var draw_reflect:Boolean = false;
        private var draw_reflect_k:Number = 1;
        private var _diffuseTransform:MatrixAway3D;
        private var _specularTransform:MatrixAway3D;
        private var _viewPosition:Number3D;
        private var _source:Mesh;
        private var _view:View3D;
        private var _startIndex:uint;
        private var _endIndex:uint;
        private var _faceVO:FaceVO;
        private var _screenVertices:Array;
        private var _screenIndices:Array;
        
		public function getTriangleShade(priIndex:uint, viewSourceObject:ViewSourceObject, renderer:Renderer, shininess:Number):FaceNormalShaderVO
        {		
			_source = viewSourceObject.source as Mesh;
			_view = renderer._view;
        	_session = renderer._session;
            focus = _view.camera.focus;
            zoom = _view.camera.zoom;
            
            _startIndex = renderer.primitiveProperties[priIndex*9];
        	_endIndex = renderer.primitiveProperties[priIndex*9+1];
        	_faceVO = renderer.primitiveElements[priIndex];
        	
			_screenVertices = viewSourceObject.screenVertices;
			_screenIndices = viewSourceObject.screenIndices;
			
			var indexA:uint;
			var indexB:uint;
			var indexC:uint;
			
            if(_endIndex - _startIndex > 10) {
            	indexA = _screenIndices[_startIndex]*3;
            	indexB = _screenIndices[_startIndex + 5]*3;
            	indexC = _screenIndices[_startIndex + 9]*3;
            } else {
	            indexA = _screenIndices[_startIndex]*3;
            	indexB = _screenIndices[_startIndex + 1]*3;
            	indexC = _screenIndices[_startIndex + 2]*3;
            }
            
        	v0z = _screenVertices[indexA+2];
			persp = (1 + v0z / focus)/zoom;
            v0x = _screenVertices[indexA]*persp;
            v0y = _screenVertices[indexA+1]*persp;
			
            v1z = _screenVertices[indexB+2];
			persp = (1 + v1z / focus)/zoom;
            v1x = _screenVertices[indexB]*persp;
            v1y = _screenVertices[indexB+1]*persp;
			
            v2z = _screenVertices[indexC+2];
			persp = (1 + v2z / focus)/zoom;
            v2x = _screenVertices[indexC]*persp;
            v2y = _screenVertices[indexC+1]*persp;
            
            d1x = v1x - v0x;
            d1y = v1y - v0y;
            d1z = v1z - v0z;
			
            d2x = v2x - v0x;
            d2y = v2y - v0y;
            d2z = v2z - v0z;
			
            pa = d1y*d2z - d1z*d2y;
            pb = d1z*d2x - d1x*d2z;
            pc = d1x*d2y - d1y*d2x;
            pdd = Math.sqrt(pa*pa + pb*pb + pc*pc);
            
            pa /= pdd;
            pb /= pdd;
            pc /= pdd;
			
            c0x = (v0x + v1x + v2x) / 3;
            c0y = (v0y + v1y + v2y) / 3;
            c0z = (v0z + v1z + v2z) / 3;
			
            kar = kag = kab = kdr = kdg = kdb = ksr = ksg = ksb = 0;

			
			var directional:DirectionalLight3D;
			
			var _tri_scene_directionalLights:Array = _source.scene.directionalLights;
			for each (directional in _tri_scene_directionalLights)
            {
            	_diffuseTransform = directional.diffuseTransform[_source];
            	
                red = directional._red;
                green = directional._green;
                blue = directional._blue;
				
                dfx = _diffuseTransform.szx;
				dfy = _diffuseTransform.szy;
				dfz = _diffuseTransform.szz;
                
                nx = _faceVO.face.normal.x;
                ny = _faceVO.face.normal.y;
                nz = _faceVO.face.normal.z;
                
                amb = directional.ambient;
				
                kar += red * amb;
                kag += green * amb;
                kab += blue * amb;
                
                nf = dfx*nx + dfy*ny + dfz*nz;
				
                if (nf < 0)
                    continue;
				
                diff = directional.diffuse * nf;
                
                kdr += red * diff;
                kdg += green * diff;
                kdb += blue * diff;
                
                _specularTransform = directional.specularTransform[_source][_view];
                
                rfx = _specularTransform.szx;
				rfy = _specularTransform.szy;
				rfz = _specularTransform.szz;
				
				rf = rfx*nx + rfy*ny + rfz*nz;
				
                spec = directional.specular * Math.pow(rf, shininess);
                
                ksr += red * spec;
                ksg += green * spec;
                ksb += blue * spec;
            }
            
            var _tri_scene_pointLights:Array = _source.scene.pointLights;
			var point:PointLight3D;
			
            for each (point in _tri_scene_pointLights)
            {
                red = point._red;
                green = point._green;
                blue = point._blue;
				
				_viewPosition = point.viewPositions[_view];
				
                dfx = _viewPosition.x - c0x;
                dfy = _viewPosition.y - c0y;
                dfz = _viewPosition.z - c0z;
                df = Math.sqrt(dfx*dfx + dfy*dfy + dfz*dfz);
                dfx /= df;
                dfy /= df;
                dfz /= df;
                fade = 1 / df / df;
                
                amb = point.ambient;
				
                kar += red * amb;
                kag += green * amb;
                kab += blue * amb;
                
                nf = dfx*pa + dfy*pb + dfz*pc;
				
                if (nf < 0)
                    continue;
				
                diff = point.diffuse * point.brightness * fade * nf * 250000;
				
                kdr += red * diff;
                kdg += green * diff;
                kdb += blue * diff;
                
                rfz = dfz - 2*nf*pc;
				
                if (rfz < 0)
                    continue;
				
                rfx = dfx - 2*nf*pa;
                rfy = dfy - 2*nf*pb;
                
                spec = point.specular * point.brightness * fade * Math.pow(rfz, shininess) * 250000;
				
                ksr += red * spec;
                ksg += green * spec;
                ksb += blue * spec;
            }
			
            if (draw_fall || draw_reflect || draw_normal)
            {
                graphics = _session.graphics,
                cz = c0z,
                cx = c0x * zoom / (1 + cz / focus),
                cy = c0y * zoom / (1 + cz / focus);
                
                if (draw_normal)
                {
                    ncz = (c0z + 30*pc),
                    ncx = (c0x + 30*pa) * zoom * focus / (focus + ncz),
                    ncy = (c0y + 30*pb) * zoom * focus / (focus + ncz);
					
                    graphics.lineStyle(1, 0x000000, 1);
                    graphics.moveTo(cx, cy);
                    graphics.lineTo(ncx, ncy);
                    graphics.moveTo(cx, cy);
                    graphics.drawCircle(cx, cy, 2);
                }
				
                if (draw_fall || draw_reflect)
                {
                    var _tri_source_scene_pointLights_new:Array = _source.scene.pointLights;
            		for each (point in _tri_source_scene_pointLights_new)
                    {
                        red = point._red;
                        green = point._green;
                        blue = point._blue;
                        sum = (red + green + blue) / 0xFF;
                        red /= sum;
                        green /= sum;
                        blue /= sum;
                		
                        dfx = _viewPosition.x - c0x;
                        dfy = _viewPosition.y - c0y;
                        dfz = _viewPosition.z - c0z;
                        df = Math.sqrt(dfx*dfx + dfy*dfy + dfz*dfz);
                        dfx /= df;
                        dfy /= df;
                        dfz /= df;
                		
                        nf = dfx*pa + dfy*pb + dfz*pc;
                        if (nf < 0)
                            continue;
                		
                        if (draw_fall)
                        {
                            ffz = (c0z + 30*dfz*(1-draw_fall_k)),
                            ffx = (c0x + 30*dfx*(1-draw_fall_k)) * zoom * focus / (focus + ffz),
                            ffy = (c0y + 30*dfy*(1-draw_fall_k)) * zoom * focus / (focus + ffz),
							
                            fz = (c0z + 30*dfz),
                            fx = (c0x + 30*dfx) * zoom * focus / (focus + fz),
                            fy = (c0y + 30*dfy) * zoom * focus / (focus + fz);
							
                            graphics.lineStyle(1, int(red)*0x10000 + int(green)*0x100 + int(blue), 1);
                            graphics.moveTo(ffx, ffy);
                            graphics.lineTo(fx, fy);
                            graphics.moveTo(ffx, ffy);
                        }

                        if (draw_reflect)
                        {
                            rfx = dfx - 2*nf*pa;
                            rfy = dfy - 2*nf*pb;
                            rfz = dfz - 2*nf*pc;
                    		
                            rz = (c0z - 30*rfz*draw_reflect_k),
                            rx = (c0x - 30*rfx*draw_reflect_k) * zoom * focus / (focus + rz),
                            ry = (c0y - 30*rfy*draw_reflect_k) * zoom * focus / (focus + rz);
                        	
                            graphics.lineStyle(1, int(red*0.5)*0x10000 + int(green*0.5)*0x100 + int(blue*0.5), 1);
                            graphics.moveTo(cx, cy);
                            graphics.lineTo(rx, ry);
                            graphics.moveTo(cx, cy);
                        }
                    }
                }
            }
			
            return new FaceNormalShaderVO(kar, kag, kab, kdr, kdg, kdb, ksr, ksg, ksb);
        }
	}
}
