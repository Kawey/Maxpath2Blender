	---ToDo
	--2side getbitmap
	--2side not in multysub

fn FnUnSupMAt mat = (

	arr = getClassInstances bitmapTexture target: mat

	Blender = Standardmaterial ()
	for i = 1 to arr.count do(
		if Arr[i] != undefined do ( 
			case i of
			(				
				1: Blender.diffusemap = Arr[i]
				2: Blender.reflectionMap = Arr[i]
				3: Blender.specularLevelMap = Arr[i]
				4: Blender.glossinessMap = Arr[i]
				5: Blender.selfIllumMap = Arr[i]
				6: Blender.opacityMap = Arr[i]
				7: Blender.bumpMap = Arr[i]
				default: print "default"
			)
		)
	)	
	
	return Blender
)	

	
fn FnConvertMAt mat = (
	if classof mat== CoronaMtl do 
	(
		TargetNode =#(	
			mat.texmapDiffuse,
			mat.texmapReflect,
			mat.texmapRefract,
			mat.texmapReflectGlossiness,
			mat.texmapTranslucency, 
			mat.texmapOpacity,
			mat.texmapBump
		)	
	)
	if classof mat== VRayMtl do (
		TargetNode =#(
			mat.texmap_diffuse,
			mat.texmap_reflection,
			mat.texmap_refraction,
			mat.texmap_reflectionGlossiness,
			mat.texmap_translucent,
			mat.texmap_opacity,
			mat.texmap_bump
		)
	)		

	Blender = Standardmaterial ()
	for i = 1 to TargetNode.count do(
		if TargetNode[i] != undefined do ( 
			a = getClassInstances bitmapTexture target:TargetNode[i]
			if a != undefined then 
			(			
				case i of
				(				
					1: Blender.diffusemap = a[1]
					2: Blender.reflectionMap = a[1]
					3: Blender.specularLevelMap = a[1]
					4: Blender.glossinessMap = a[1]
					5: Blender.selfIllumMap = a[1]
					6: Blender.opacityMap = a[1]
					7: Blender.bumpMap = a[1]
					default: print "default"
				)
			)
		)	
	)
	return Blender
)	

ArrObj = selection as array

if ArrObj.count >0 then
(
	clearSelection()
	for obj in ArrObj where superclassof obj == GeometryClass and obj.material != undefined do (
		matName =  obj.material.name
		format "Obj Name %\n"  obj.name
		if classof obj.material == VRayMtl or classof obj.material == CoronaMtl or classof obj.material == Multimaterial then (
			if classof obj.material == VRayMtl do (
				obj.material = FnConvertMAt obj.material
				obj.material.name = matName
			)
			if classof obj.material == Multimaterial and (classof obj.material[1] != Standardmaterial) then 
			(
				MuMat = Multimaterial()
				MuMat.count = obj.material.count
				MuMat.name = matName
				for m = 1 to obj.material.numsubs do
				(	
					if obj.material[m] == undefined  then exit
					if  classof obj.material[m] == CoronaMtl  or classof obj.material[m] == VRayMtl then
					(
						matName = obj.material[m].name
						if classof obj.material[m]== VRay2SidedMtl then (
							MuMat[m] = FnConvertMAt obj.material[m].frontMtl
							MuMat[m].name = matName
						)else(
							Format "MAt: %\n" (classof obj.material[m])
							MuMat[m] = FnConvertMAt obj.material[m]
							MuMat[m].name = matName
						)
					)
					else
					(
						Format "Unsupported Mat: % in MultySub\n" (classof obj.material[m])
						
						matName = obj.material[m].name
						MuMat[m] = FnUnSupMAt obj.material[m]
						MuMat[m].name = matName
					)
					
				)
				obj.material = MuMat
			)else(print "StandartMTL")		
		)else(print "StandartMTL")	
			
	)
	print "done"	
)else(
	print "None selected"
)

	

