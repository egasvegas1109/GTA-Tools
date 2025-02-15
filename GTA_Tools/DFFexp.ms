-----------------------
--Collision Functions--
-----------------------
global exp_lockDFF
global objExpName

global DFF2dfx_light_rol
global DFF2dfx_prt_rol
global DFF2dfx_sgn_rol
global DFF2dfx_stm_rol
global DFF2dfx_esc_rol
global DFF2dfx_light

fn MMCCheck obj = (
	MMCuseFlag = false
	mclr = 0.0
	maph = 0.0
	if classof (obj.material)== Multimaterial then (
		for mtl in obj.material where mtl !=undefined do (
			if classof mtl == Standardmaterial then (
				mclr = [(mtl.diffuse.r as integer),(mtl.diffuse.g as integer),(mtl.diffuse.b as integer)]
				maph = mtl.opacity/100.0
				if (mtl.diffusemapEnable == false)OR(classof mtl.diffusemap != Bitmaptexture) then MMCuseFlag = true
			) else if classof mtl == GTA_Mtl then (
				mclr = [(mtl.color.r as integer),(mtl.color.g as integer),(mtl.color.b as integer)]
				maph = mtl.alpha/255.0
				if (mtl.use_colormap == false)OR(classof mtl.colormap != Bitmaptexture) then MMCuseFlag = true
			)	
			if (mclr == [255,0,175])OR(mclr == [60,255,0])OR(mclr == [255,175,0])OR \
				(mclr == [0,255,200])OR(mclr == [185,255,0])OR(mclr == [255,60,0])OR \
				(mclr == [0,255,255]) then MMCuseFlag = true
			if maph != 1.0 then MMCuseFlag = true			
		)
	) else (
		mtl = obj.material
		if classof mtl == Standardmaterial then (
			mclr = [(mtl.diffuse.r as integer),(mtl.diffuse.g as integer),(mtl.diffuse.b as integer)]
			maph = mtl.opacity/100.0
			if (mtl.diffusemapEnable == false)OR(classof mtl.diffusemap != Bitmaptexture) then MMCuseFlag = true
		) else if classof mtl == GTA_Mtl then (
			mclr = [(mtl.color.r as integer),(mtl.color.g as integer),(mtl.color.b as integer)]
			maph = mtl.alpha/255.0
			if (mtl.use_colormap == false)OR(classof mtl.colormap != Bitmaptexture) then MMCuseFlag = true
		)
		if (mclr == [255,0,175])OR(mclr == [60,255,0])OR(mclr == [255,175,0])OR \
			(mclr == [0,255,200])OR(mclr == [185,255,0])OR(mclr == [255,60,0])OR \
			(mclr == [0,255,255]) then MMCuseFlag = true
		if maph != 1.0 then MMCuseFlag = true
	)	
	return MMCuseFlag
)

fn newLockDFF state = (
	if state == true then (
		exp_lockDFF = true  
		format "[on] DFF lock is activated\n"
	) else (
		if state == false then (
			exp_lockDFF = false
			format "[off] DFF lock is deactivated\n"
		)
	)
)

Global lightArr = #()
fn checkUV2Bitmap obj = (
	if (classof obj.material == GTA_mtl) then (
		if (obj.material.use_RF == true)AND(classof obj.material.reflectionmap == Bitmaptexture) then (
			if (obj.material.reflectionmap.fileName != undefined) then (
				if (getFilenameFile (obj.material.reflectionmap.fileName) == "xvehicleenv128") then ( return true )
				else ( return false )
			)
		)
	) else if (classof obj.material == standardmaterial) then (
		if (obj.material.reflectionMapEnable == true)AND(classof obj.material.reflectionmap == Bitmaptexture) then (
			if (obj.material.reflectionmap.fileName != undefined) then (
				if (getFilenameFile (obj.material.reflectionmap.fileName) == "xvehicleenv128")  then ( return true )
				else ( return false )
			)
		)
	) else return undefined 
)

-- uv compression by Goldfish
fn reBuildUV obj chanell = ( 
	if (meshop.getMapSupport obj chanell) == true then (
		local statNumV = (meshop.getNumMapVerts obj chanell)
		local statNumResult
		local vertCoordAr = #()
		for i = 1 to (meshop.getNumMapVerts obj chanell) do (
			append vertCoordAr (meshop.getMapVert obj chanell i)
		)
		for i = 1 to (meshop.getNumMapFaces obj chanell) do (
			mFs = (meshop.getMapFace obj chanell i)
			vX = finditem vertCoordAr (meshop.getMapVert obj chanell mFs.x)
			vY = finditem vertCoordAr (meshop.getMapVert obj chanell mFs.y)
			vZ = finditem vertCoordAr (meshop.getMapVert obj chanell mFs.z)
			meshop.SetMapFace obj chanell i [vX,vY,vZ]
		)
		meshop.buildMapFaces obj chanell
		statNumResult = statNumV - (meshop.getNumMapVerts obj chanell)
		format "    -> Compressed % of % UV% coord = %\n" statNumResult statNumV chanell (meshop.getNumMapVerts obj chanell)
	)
)

-- fn transfer normals (by Goldish)
fn transferNormals fromObj obj = (				 
	for i = 1 to fromObj.numFaces  do (
		nVert=meshop.GetFaceRNormals fromObj i
		fVert = getFace obj i
		setnormal obj fVert[1] nVert[1]
		setnormal obj fVert[2] nVert[2]
		setnormal obj fVert[3] nVert[3]
	)
)

-- fn detach by smooth group (by Goldish)
fn detachBySmGr obj = (
	fbySm = #()
	for i = 1 to obj.numfaces do (
		j = (getFaceSmoothGroup obj i as integer)
		if j != 0 then (
			if fbySm[j] == undefined then (
				m = true
				while (m == true) do (
					append fbySm #()				
					if fbySm[j]	!= undefined then m = false
					if fbySm.count > obj.numfaces then (m = false; format " debug -> [detachBySmGr]: #error loop\n")
				)
			)
			append fbySm[j] i
		)  	
	)
	if fbySm.count > 0 then (
		for i = 1 to fbySm.count do (
			if fbySm[i] != undefined then meshop.detachFaces obj fbySm[i]
			else format " debug -> [detachBySmGr]: #error array\n"
		)
	)
)

fn writeCOL3 dff f ver = (
	cf = fopen dff "rb"
	fseek cf 8 #seek_set
	if ver != 0X1803FFFF then return false

	fseek cf 24 #seek_set
	objCount = readLong cf

	fseek cf 40 #seek_set        --FrameList
	skip =  (readLong cf) + 8
	fseek cf skip #seek_cur      --GeometryList
	skip =  (readLong cf) + 8
	fseek cf skip #seek_cur      --Atomic

	for i = 1 to objCount do (
		skip = (readLong cf) + 8        
		fseek cf skip #seek_cur      --Atomic
	)
	--Make sure it is COL3--
	col3leng = (readLong cf) - 12
	fseek cf 16 #seek_cur
	if ( readLong cf == 0x334C4F43 ) then fseek cf -4 #seek_cur
	else (
		while (readLong cf != 0x334C4F43) do ()
		fseek cf -24 #seek_cur
		col3leng = (readLong cf) - 12
		fseek cf 16 #seek_cur
	)

	writeLong f 0X0253F2FA          --SA Appended COL
	writeLong f col3leng
	writeLong f ver 
	for i = 1 to col3leng do writeByte f (readByte cf)

	fclose cf
	return true
)
--
fn writeCOLL col f ver = (
	cf = fopen col "rb"
	fseek cf 0 #seek_end
	colleng = ftell cf
	fseek cf 0 #seek_set

	writeLong f 0X0253F2FA          --SA Appended COL
	writeLong f colleng
	writeLong f ver     
	for i = 1 to colleng do writeByte f (readByte cf)    

	fclose cf
	return true    
)
--
fn checkRoot AllObjects = (
	objset = AllObjects as array
	RootAry = for obj in objSet where
		(finditem objset obj.parent) == 0  collect obj
	if RootAry.count == 1 then return RootAry[1]
	else (
		messagebox "More than 1 Hierarchy links were selected!\nOnly 1 is allowed in dff." title:"Hierarchy Error"
		return undefined
	)
)--end fn checkRoot
--
fn singleCOL cf = (
	fseek cf 0 #seek_end
	cfend = ftell cf
	fseek cf 0 #seek_set
	headerID = readLong cf				--"COLL" or "COL3"
	if (headerID == 0x334C4F43)OR(headerID == 0x4C4C4F43) then (
		endCOL = readLong cf
		fseek cf endCOL #seek_cur
		if (ftell cf) == cfend then return (endCOL + 8)
		headerID = readLong cf
		if (headerID == 0x334C4F43)OR(headerID == 0x4C4C4F43) then return 0
		return (endCOL + 8)
	) else return -1
 --return:--
 -- -1: not a col file
 --  0: not a single Col file
 -- >8: Col file size
)--end fn singleCOL
--
fn findCOL3 cf ver = (
	fseek cf 8 #seek_set
	if (readLong cf) != ver then return -1
	try (
		fseek cf 24 #seek_set
		objCount = readLong cf
    
		fseek cf 40 #seek_set        --FrameList
		skip =  (readLong cf) + 8
		fseek cf skip #seek_cur      --GeometryList
		skip =  (readLong cf) + 8
		fseek cf skip #seek_cur      --Atomic
        
		for i = 1 to objCount do (
			skip = (readLong cf) + 8        
			fseek cf skip #seek_cur      --Atomic
		)

		--Make sure it is COL3--
		fseek cf 16 #seek_cur
		if ( readLong cf == 0x334C4F43 ) then  return ((readLong cf) + 8)
		else (
			while (readLong cf != 0x334C4F43) do ()
			return ((readLong cf) + 8)
        ) 
	) catch ( return 0 )

 --Return: --
 -- -1: ver not correct
 -- 0: Can't find COL3
 -- >8: Col3 file size
)--end fn findCOL3
--
-------------------						--2nd UV added(19Jul05)
-- Remap Tool v1.5--						--with skin data remapped--
-- upd 27.02.2018 by Goldfish
-------------------						--Suppose SkinData is a Global Variable--

global dffExportCurMshName

fn CondenseMtlByID obj = (
	if obj.numtverts == 0 then setUserProp obj "MMC" true
	else 	setUserProp obj "MMC" false
	MMCready = false
	--If not Multimaterial--
	if classof obj.material != Multimaterial then return obj
	MaxID = obj.material.count
	IDAry = #()
	for i = 1 to obj.numfaces do (
		thisID = mod (getFaceMatID obj i) MaxID
		if thisID == 0 then thisID = MaxID
		if IDAry[thisID] == undefined then IDAry[thisID] = #()
		append IDAry[thisID] i
	)--end for i
	
	CondenseAry = #()
	for i = 1 to IDAry.count do 
		if IDAry[i] != undefined then 	append CondenseAry i

	NewMtl = Multimaterial numsubs:CondenseAry.count
	for i = 1 to CondenseAry.count do (
		for j = 1 to IDAry[(CondenseAry[i])].count do setFaceMatID obj IDAry[(CondenseAry[i])][j] i		
		NewMtl[i] = obj.material[(CondenseAry[i])]
	)
	obj.material = NewMtl
		--format "in CondenseMtlByID:%\n" (getUserProp obj "MMC") 
	return obj
)
--end fn CondenseMtlByID

fn RemapByVT msh SkinData = (
	--Verts based--
	--format " (debug: remapByVerts)\n\n"
	--===========--	
	NewUVAry = #()
	if (meshop.getMapSupport msh -1 == false) then NewNVColAry = undefined else NewNVColAry = #()
	if (meshop.getMapSupport msh 2 == false) then NewUV2Ary = undefined else NewUV2Ary = #()
	if (meshop.getMapSupport msh -2 == false) then NewVCaAry = undefined else NewVCaAry = #()
	
	NVColFace  = #()				
	if (getNumCPVVerts msh) != 0 then 	NewVColAry = #() 	else 	NewVColAry = undefined
	try (
		if msh.numTVerts != 0 then (
			interfaceUpdate()
			for i = 1 to msh.numFaces do (
				try (
					UVFace = getTVFace msh i
					VertFace = getFace msh i
					NewUVAry[VertFace.x] = getTVert msh UVFace.x
					NewUVAry[VertFace.y] = getTVert msh UVFace.y
					NewUVAry[VertFace.z] = getTVert msh UVFace.z

				) catch()
			)--end for i
		)--end if UV != 0
		interfaceUpdate()
		for i = 1 to msh.numFaces do (
			VertFace = getFace msh i
			if NewVColAry != undefined then (
					VColFace = getVCFace msh i
					NewVColAry[VertFace.x] = getVertColor msh VColFace.x
					NewVColAry[VertFace.y] = getVertColor msh VColFace.y
					NewVColAry[VertFace.z] = getVertColor msh VColFace.z
			)--end HasVCol			
			if NewNVColAry != undefined then (
					NVColFace = meshop.getMapFace msh -1 i 
					NewNVColAry[VertFace.x] = meshop.getMapVert msh -1 NVColFace[1] 
					NewNVColAry[VertFace.y] = meshop.getMapVert msh -1 NVColFace[2] 
					NewNVColAry[VertFace.z] = meshop.getMapVert msh -1 NVColFace[3] 
			)--end HasNVCol
			if NewVCaAry != undefined then (
					VCaFace = meshop.getMapFace msh -2 i 
					NewVCaAry[VertFace.x] = meshop.getMapVert msh -2 VCaFace[1] 
					NewVCaAry[VertFace.y] = meshop.getMapVert msh -2 VCaFace[2] 
					NewVCaAry[VertFace.z] = meshop.getMapVert msh -2 VCaFace[3] 
			)--end HasNVCol

			if NewUV2Ary != undefined then (
					UV2Face = meshop.getMapFace msh 2 i 
					NewUV2Ary[VertFace.x] = meshop.getMapVert msh 2 UV2Face[1] 
					NewUV2Ary[VertFace.y] = meshop.getMapVert msh 2 UV2Face[2] 
					NewUV2Ary[VertFace.z] = meshop.getMapVert msh 2 UV2Face[3] 
			)--end HasNVCol	
		)--end for i
	) catch (format " debug -> [RemapByVT - loop]: #error\n")

	-------------------------------
	--Add UV as [0,0,0]          --
	--and Dead VertColor to black--
	-------------------------------
	interfaceUpdate()
	for j = 1 to msh.numVerts do (
		if (msh.numTVerts != 0)AND(NewUVAry[j] == undefined) then NewUVAry[j] = [0,0,0]
		if (NewVColAry != undefined)AND(NewVColAry[j] == undefined) then NewVColAry[j] = color 0 0 0
		if (NewNVColAry != undefined)AND(NewNVColAry[j] == undefined) then (
			NewNVColAry[j] = color 0 0 0
		)
		if (NewVCaAry != undefined)AND(NewVCaAry[j] == undefined) then (
			NewVCaAry[j] = color 0 0 0
		)		
	)
	Newmesh = snapshot msh

	try (
		if (NewUV2Ary != undefined) then (
			meshop.setNumMaps Newmesh 3
			meshop.setMapSupport Newmesh 2 false
			meshop.setMapSupport Newmesh 2 true
			
		)
	) catch (format " debug -> [RemapByVT - setMapSupport]: #error\n")
	
	--Set UV1 / UV2--
	interfaceUpdate()
	try (
		UV2Ary = undefined
		Newmesh.numTVerts = msh.numVerts
		buildTVFaces Newmesh
		if msh.numTVerts != 0 then (
			for j = 1 to msh.numVerts do (
				setTVert Newmesh j NewUVAry[j]
				if NewUV2Ary != undefined then meshop.setMapVert Newmesh 2 j NewUV2Ary[j]
			)
		)--end if/else 
	) catch (format " debug -> [RemapByVT - Set UV1 / UV2]: #error\n")
	
	--Set VertColors--
	try (
		if NewVColAry != undefined then (
			interfaceUpdate()
			setNumCPVVerts Newmesh msh.numVerts
			buildVCFaces Newmesh
			for j = 1 to msh.numVerts do 	setVertColor Newmesh j NewVColAry[j]		
		)
	) catch (format " debug -> [RemapByVT - Set VC]: #error\n")
	
	--Set NVC--
	try (
		if NewNVColAry != undefined then (	
			interfaceUpdate()
			meshop.setMapSupport Newmesh -1 false
			meshop.setMapSupport Newmesh -1 true
			for j = 1 to Newmesh.numVerts do meshop.setMapVert Newmesh -1 j NewNVColAry[j] 
		)
	) catch (format " debug -> [RemapByVT - Set NVC]: #error\n")
	--format "- % %\n" (meshop.getNumMapVerts msh -1) msh.numVerts
	interfaceUpdate()
	try (
		for j = 1 to msh.numFaces do (
			setFaceMatID Newmesh j (getFaceMatID msh j)
			if msh.numTVerts != 0 then 			setTVFace Newmesh j (getFace msh j)
			if NewVColAry != undefined then 	setVCFace Newmesh j (getTVFace msh j)
		)--end for j	
	) catch (format " debug -> [RemapByVT - Faces]: #error\n")

	--Set Vertex Alpha--
	try (
		if NewVCaAry != undefined then (
			interfaceUpdate()
			meshop.setMapSupport Newmesh -2 false
			meshop.setMapSupport Newmesh -2 true
			if NewVCaAry != undefined then (		
				for j = 1 to Newmesh.numVerts do meshop.setMapVert Newmesh -2 j NewVCaAry[j] 
			)
		) else meshop.setMapSupport Newmesh -2 false
	) catch (format " debug -> [RemapByVT - Set vAlpha]: #error\n")
	--format " - % %\n" (meshop.getNumMapVerts Newmesh -2) (meshop.getNumMapVerts Newmesh -1)
	delete msh
	return #(Newmesh, UV2Ary, SkinData)
	
)
--
fn RemapByUV1 msh SkinData = (
	--format " (debug: remapByUV1)\n\n"
	if (getNumCPVVerts msh) != 0 then NewVColAry = #() 	else 	NewVColAry = undefined
	NewVertAry = #()
	NewFaceindexAry = #()
	if (meshop.getMapSupport msh -1 == false) then NewNVColAry = undefined else NewNVColAry = #()
	if (meshop.getMapSupport msh -2 == false) then NewVCaAry = undefined else NewVCaAry = #()
	if (meshop.getMapSupport msh 2 == false) then NewUV2Ary = undefined else NewUV2Ary = #()
	NVColFace  = #()			
	if SkinData != undefined then (
		NewBv = #()
		NewBw = #()
	)
	interfaceUpdate()
	try (
		for i = 1 to msh.numFaces do (
			UVFace = getTVFace msh i
			VertFace = getFace msh i
			NewFaceindexAry[i] = UVFace
			NewVertAry[UVFace.x] = msh.verts[VertFace.x].pos
			NewVertAry[UVFace.y] = msh.verts[VertFace.y].pos
			NewVertAry[UVFace.z] = msh.verts[VertFace.z].pos
			
			if SkinData != undefined then (
				NewBv[UVFace.x] = SkinData[1][VertFace.x]
				NewBv[UVFace.y] = SkinData[1][VertFace.y]
				NewBv[UVFace.z] = SkinData[1][VertFace.z]
				NewBw[UVFace.x] = SkinData[2][VertFace.x]
				NewBw[UVFace.y] = SkinData[2][VertFace.y]
				NewBw[UVFace.z] = SkinData[2][VertFace.z]
			)
			--NewVColAry = undefined
			if NewVColAry != undefined then (
					VColFace = getVCFace msh i
					NewVColAry[UVFace.x] = getVertColor msh VColFace.x
					NewVColAry[UVFace.y] = getVertColor msh VColFace.y
					NewVColAry[UVFace.z] = getVertColor msh VColFace.z
			)--end HasVCol	
			if NewNVColAry != undefined then (
					NVColFace = meshop.getMapFace msh -1 i 
					NewNVColAry[UVFace.x] = meshop.getMapVert msh -1 NVColFace[1] 
					NewNVColAry[UVFace.y] = meshop.getMapVert msh -1 NVColFace[2] 
					NewNVColAry[UVFace.z] = meshop.getMapVert msh -1 NVColFace[3] 
			)--end HasNVCol	
			
			if NewVCaAry != undefined then (
					VCaFace = meshop.getMapFace msh -2 i 
					NewVCaAry[UVFace.x] = meshop.getMapVert msh -2 VCaFace[1] 
					NewVCaAry[UVFace.y] = meshop.getMapVert msh -2 VCaFace[2] 
					NewVCaAry[UVFace.z] = meshop.getMapVert msh -2 VCaFace[3] 
			)--end HasNVCol	
			
			if NewUV2Ary != undefined then (
					UV2Face = meshop.getMapFace msh 2 i 
					NewUV2Ary[UVFace.x] = meshop.getMapVert msh 2 UV2Face[1] 
					NewUV2Ary[UVFace.y] = meshop.getMapVert msh 2 UV2Face[2] 
					NewUV2Ary[UVFace.z] = meshop.getMapVert msh 2 UV2Face[3] 
			)--end HasNVCol				
		)--end for i
	) catch (format " debug -> [RemapByUV1 - loop]: #error\n")
	-------------------------------
	--replace Dead UV to [0,0,0] --
	--Dead Normal upward [0,0,1] --
	--and Dead VertColor to black--
	-------------------------------
	interfaceUpdate()
	for j = 1 to NewVertAry.count do (
		if NewVertAry[j] == undefined then (
			NewVertAry[j] = [0,0,0]
		)
		if (NewUV2Ary != undefined) AND (NewUV2Ary[j] == undefined) then (
			NewUV2Ary[j] = [0.0,0.0,0.0]
		)
		if (NewVColAry != undefined)AND(NewVColAry[j] == undefined) then (
			NewVColAry[j] = color 0 0 0
		)
		if (NewNVColAry != undefined)AND(NewNVColAry[j] == undefined) then (
			NewNVColAry[j] = color 0 0 0
		)	
		if (NewVCaAry != undefined)AND(NewVCaAry[j] == undefined) then (
			NewVCaAry[j] = color 0 0 0
		)	
	)

	--rebuild mesh--
	Newmesh = mesh vertices:NewVertAry faces:NewFaceindexAry
	if (NewUV2Ary != undefined) then meshop.setNumMaps Newmesh 3
	
	--Set UV1 /UV2--
	interfaceUpdate()
	try (
		UV2Ary = undefined
		Newmesh.numTVerts = NewVertAry.count
		buildTVFaces Newmesh
		for j = 1 to NewVertAry.count do (
			setTVert Newmesh j (getTVert msh j)
			if NewUV2Ary != undefined then meshop.setMapVert Newmesh 2 j NewUV2Ary[j]
		)
	) catch (format " debug -> [RemapByUV1 - Set UV1 / UV2]: #error\n")
	
	--Set VertColors--
	try (
		if NewVColAry != undefined then (
			interfaceUpdate()
			setNumCPVVerts Newmesh NewVertAry.count
			buildVCFaces Newmesh
			try (
				for j = 1 to NewVertAry.count do 	(
					setVertColor Newmesh j NewVColAry[j]
				)
			) catch (format "err write VC\n")
		)--end if HasVCol 
	) catch (format " debug -> [RemapByUV1 - Set VC]: #error\n")
	--Set Night VertColors--
	
	--Set NVC--
	try (
		if NewNVColAry != undefined then (
			interfaceUpdate()
			meshop.setMapSupport Newmesh -1 false
			meshop.setMapSupport Newmesh -1 true
			try (
				for j = 1 to NewVertAry.count do 	(
					meshop.setMapVert Newmesh -1 j NewNVColAry[j]
				)
			) catch (format "err write NVC\n")
		)--end if HasVCol 
	) catch (format " debug -> [RemapByUV1 - Set NVC]: #error\n")
	
	--Set Vertex alpha--
	try (
		if NewVCaAry != undefined then (
			interfaceUpdate()
			meshop.setMapSupport Newmesh -2 false
			meshop.setMapSupport Newmesh -2 true
			try (
				for j = 1 to NewVertAry.count do 	(
					meshop.setMapVert Newmesh -2 j NewVCaAry[j]
				)
			) catch (format "err write NVC\n")
		)--end if HasVCol 
	) catch (format " debug -> [RemapByUV1 - Set vAlpha]: #error\n")
	interfaceUpdate()
	try (
		for j = 1 to msh.numFaces do (
			setTVFace Newmesh j (getTVFace msh j)
			setFaceMatID Newmesh j (getFaceMatID msh j)
			if NewVColAry != undefined then  setVCFace Newmesh j (getTVFace msh j)
		)--end for j
	) catch (format " debug -> [RemapByUV1 - Faces]: #error\n")

	if SkinData != undefined then  (
        SkinData2 = #(NewBv,NewBw,SkinData[3])
 --format "SkinData2:%\n" SkinData2[1].count
	)
	delete msh
	return #(Newmesh, undefined, SkinData2)
)

fn RemapByUV2 msh SkinData = (
	--format " (debug: remapByUV2)\n\n"
	if (getNumCPVVerts msh) != 0 then 	NewVColAry = #() 	else 	NewVColAry = undefined
	NewVertAry = #()
	UV2Ary = #()
	NewNormalAry = #()
	NewFaceindexAry = #()	
	interfaceUpdate()	
	try (
		for i = 1 to msh.numFaces do (
			UVFace = meshop.getMapFace msh 2 i
			VertFace = getFace msh i
			NewFaceindexAry[i] = UVFace
			NewVertAry[UVFace.x] = msh.verts[VertFace.x].pos
			NewVertAry[UVFace.y] = msh.verts[VertFace.y].pos
			NewVertAry[UVFace.z] = msh.verts[VertFace.z].pos

			if NewVColAry != undefined then (
				try (
					VColFace = getVCFace msh i
					NewVColAry[UVFace.x] = getVertColor msh VColFace.x
					NewVColAry[UVFace.y] = getVertColor msh VColFace.y
					NewVColAry[UVFace.z] = getVertColor msh VColFace.z
				) catch()
			)--end HasVCol		
		
		)--end for i
	) catch (format " debug -> [RemapByUV2 - loop]: #error\n")
	interfaceUpdate()
	for j = 1 to NewVertAry.count do (
		if NewVertAry[j] == undefined then NewVertAry[j] = [0,0,0]
		if (NewVColAry != undefined)AND(NewVColAry[j] == undefined) then NewVColAry[j] = color 0 0 0
	)

	Newmesh = mesh vertices:NewVertAry faces:NewFaceindexAry
	meshop.setNumMaps Newmesh 3
	interfaceUpdate()
	--Set UV1 / UV2--
	try (
		Newmesh.numTVerts = NewVertAry.count
		buildTVFaces Newmesh
		for j = 1 to NewVertAry.count do (
			meshop.setMapVert Newmesh 2 j (meshop.getMapVert msh 2 j)
		)
	) catch (format " debug -> [RemapByUV2 - Set UV1 / UV2]: #error\n")
	
	--Set VertColors--
	try (
		if NewVColAry != undefined then (	
			interfaceUpdate()			
			setNumCPVVerts Newmesh NewVertAry.count
			for j = 1 to NewVertAry.count do (
				setVertColor Newmesh j NewVColAry[j]
			)
		)--end if HasVCol 
	) catch (format " debug -> [RemapByUV2 - Set VC]: #error\n")
	interfaceUpdate()
	--Set faces--
	try (
		for j = 1 to msh.numFaces do (
			fVerts = (meshop.getMapFace msh 1 j)
			setTVFace Newmesh j fVerts
			setTVert Newmesh fVerts.x (getTVert msh fVerts.x)
			setTVert Newmesh fVerts.y (getTVert msh fVerts.y)
			setTVert Newmesh fVerts.z (getTVert msh fVerts.z)
			meshop.setMapFace Newmesh 2 j (meshop.getMapFace msh 2 j)			
		)--end for j
	) catch (format " debug -> [RemapByUV2 - Set faces]: #error\n")

	delete msh
	return #(Newmesh, UV2Ary,undefined)
)
--end fn RemapByUV2
fn RemapGeo obj SkinData = (
	bkTrans = (coordsys local obj.transform)
	msh = snapshot obj
	msh.transform = matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0]
	if gUVpack == true then (
		format "     [debug] UV Fix == true\n"
		interfaceUpdate()
		popPrompt()
		pushPrompt ("Export DFF: " + (objExpName as string) + " - compression UV...")
		if (meshop.getMapSupport msh 1) == true then reBuildUV msh 1
		if (meshop.getMapSupport msh 2) == true then try (
			interfaceUpdate()
			reBuildUV msh 2
		) catch (format " [Error]: reBuildUV UV2\n";delete msh; msh = snapshot obj)
	)
	nVT = msh.numVerts
	nUV1 = msh.numTVerts
	if (meshop.getMapSupport msh 2) == true then nUV2 = (meshop.getNumMapVerts msh 2) else nUV2 = undefined
	delUV1 = false
	if nUV1 == 0 then (
		delUV1 = true
		meshop.setMapSupport msh 1 true
		msh.numTVerts = nVT
		buildTVFaces msh
		for j = 1 to msh.numTVerts do (
			setTVert msh j [0.0,0.0,0.0]
		)
		for j = 1 to msh.numFaces do (
			setTVFace msh j (getFace msh j)
		)
	)

	Rult = nVT
	if nUV1 > Rult then Rult = nUV1
	if nUV2 != undefined and nUV2 > Rult then Rult = nUV2
	--format "vx % uv1 % uv2 %\n" nVT nUV1 nUV2
	popPrompt()
	pushPrompt ("Export DFF: " + (objExpName as string) + " - remap...")
	tmp = case Rult of ( -- fix by Goldfish
		nVT: RemapByVT msh SkinData 
		nUV1: RemapByUV1 msh SkinData
		nUV2: RemapByUV2 msh SkinData
	)	
	Newmesh = tmp[1]
	--copy Newmesh
	Newmesh.transform = bkTrans
	Newmesh.name = obj.name + "_remap"
	Newmesh.material = obj.material
	Newmesh.wirecolor = obj.wirecolor
	if delUV1 == true then meshop.setMapSupport Newmesh 1 false
	return #(Newmesh,tmp[2],tmp[3])
)

--end fn RemapGeo
--
--2--------------------
--Bones/Skin Function--
-----------------------
fn BoneArybyIndex BonesAry = (
    SortedAry = #()
    for i = 1 to BonesAry.count do (
        bna = for bn in BonesAry where (getUserProp bn "BoneIndex") == (i-1) collect bn
        if bna == undefined then return undefined
        else append SortedAry bna[1]
    )
    return SortedAry
)
--end fn BoneArybyIndex
--
fn wHAnim f BonesAry ver = (
    if classof BonesAry == Array then (
		WriteLong f 0x011E			-- rwHAnimPLG
		WriteLong f (((BonesAry.count*3)+5)*4)	
		WriteLong f ver	
		WriteLong f 256
		WriteLong f (getUserProp BonesAry[1] "BoneID")
		WriteLong f (BonesAry.count)
		WriteLong f 0
		WriteLong f 36    
        for i = 1 to BonesAry.count do (
            WriteLong f (getUserProp BonesAry[i] "BoneID" )
            WriteLong f (getUserProp BonesAry[i] "BoneIndex" )
            WriteLong f (getUserProp BonesAry[i] "BoneType" )
        )--end for i
    ) else (
		--format "%\n" BonesAry
		WriteLong f 0x011E			-- rwHAnimPLG
		WriteLong f 12	
		WriteLong f ver
		WriteLong f 256
		WriteLong f (getUserProp BonesAry "BoneID")
		WriteLong f 0
    )
)
--end fn wHAnim
--
fn wSkinFrameList f BonesAry Iscale ver = (
	writeLong f 0x0E						-- rwFrameList
	FL_length_add = ftell f
	writeLong f 0							-- temp for clump size
	writeLong f ver							-- file version for GTA3
	writeLong f 1
	writeLong f ( (BonesAry.count + 1) * 56 + 4 )
	writeLong f ver							-- file version for GTA3
	
	writeLong f (BonesAry.count + 1)
	
	--export Mesh transform--
    if ver == 0x1803FFFF then tfm = matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0]
	else tfm = (coordsys local $.transform)
	writeFloat f tfm.row1.x
	writeFloat f tfm.row1.y
	writeFloat f tfm.row1.z
	writeFloat f tfm.row2.x
	writeFloat f tfm.row2.y
	writeFloat f tfm.row2.z
	writeFloat f tfm.row3.x
	writeFloat f tfm.row3.y
	writeFloat f tfm.row3.z
	tpos = tfm.row4
	writeFloat f tpos.x
	writeFloat f tpos.y
	writeFloat f tpos.z
	writeLong f -1
	writeLong f 131075
	
	--export Bones transform--	
	for i = 1 to BonesAry.count do (
        if i == 1 then tfm = (coordsys local BonesAry[1].transform)
        else (
            bkup = (coordsys local BonesAry[i].parent.transform)
            BonesAry[i].parent.transform = matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0]
            tfm = (coordsys local BonesAry[i].transform)
            BonesAry[i].parent.transform = bkup
        )
		writeFloat f tfm.row1.x
		writeFloat f tfm.row1.y
		writeFloat f tfm.row1.z
		writeFloat f tfm.row2.x
		writeFloat f tfm.row2.y
		writeFloat f tfm.row2.z
		writeFloat f tfm.row3.x
		writeFloat f tfm.row3.y
		writeFloat f tfm.row3.z
		tfm.row4
		writeFloat f tfm.row4.x
		writeFloat f tfm.row4.y
		writeFloat f tfm.row4.z
		pf = (finditem BonesAry BonesAry[i].parent)
        --format "%: Parent Frame:%\n" i pf
		writeLong f pf
		if ver == 0x1803FFFF then writeLong f 3
        else writeLong f 0
	)--end for i

	--Mesh Frame--
	if ver != 0x1803FFFF then (
		WriteLong f 3						-- rwExtension
		WriteLong f ( $.name.count + 36 )
		WriteLong f ver						-- file version for GTA3	
		WriteLong f 0x0253F2FE				-- rwFrame 39056126
		WriteLong f ( $.name.count )	
		WriteLong f ver
		writeString f $.name
		fseek f -1 #seek_cur	
		WriteLong f 0x011E					-- rwHAnimPLG
		WriteLong f 12	
		WriteLong f ver	
		WriteLong f 256
		WriteLong f -1
		WriteLong f 0
	) else (
		WriteLong f 3						-- rwExtension
		WriteLong f 0
		WriteLong f ver    
	)

	--Bone Frame--
	WriteLong f 3
	WriteLong f ( BonesAry[1].name.count + 24 + (((BonesAry.count)*3+5)*4) )
	WriteLong f ver				-- file version for GTA3		
	if ver == 0x1803FFFF then wHAnim f BonesAry ver
	WriteLong f 0x0253F2FE		-- rwFrame 39056126
	WriteLong f ( BonesAry[1].name.count )	
	WriteLong f ver
	WriteString f BonesAry[1].name
	fseek f -1 #seek_cur
	if ver != 0x1803FFFF then wHAnim f BonesAry ver
    
	for i = 2 to BonesAry.count do (
		--child bone--
		WriteLong f 3
		WriteLong f ( BonesAry[i].name.count + 36 )
		WriteLong f ver				-- file version for GTA3			
		if ver == 0x1803FFFF then wHAnim f BonesAry[i] ver
		WriteLong f 0x0253F2FE		-- rwFrame 39056126
		WriteLong f ( BonesAry[i].name.count )	
		WriteLong f ver
		WriteString f BonesAry[i].name
		fseek f -1 #seek_cur
		if ver != 0x1803FFFF then wHAnim f BonesAry[i] ver
	)--end for i	
	
	local here = ftell f
	FL_length = here - 8 - FL_length_add
	fseek f FL_length_add #seek_set
	WriteLong f FL_length
	fseek f here #seek_set
)
--end fn wSkinFrameList			--<e9>--
--
fn sortBybw bv bw = (
	for i = bw.count to 2 by -1 do (
		if bw[i] > bw[(i-1)] then (
			swap bw[i] bw[(i-1)]
			swap bv[i] bv[(i-1)]
		) else exit
	)
	if bw.count == 5 then (
		deleteitem bw 5
		deleteitem bv 5
	)
	
	return #(bv,bw)
	
)
--end fn sortBybw			--<s1>--
--
fn CreateSkinData obj = (
	select obj
	max modify mode
	skn = obj.modifiers[1]
	totalVerts = skinOps.getNumberVertices skn
	bvAry = #()
	bwAry = #()
	spBoneAry = #()
	for i = 1 to totalVerts do (
		infbones = skinOps.GetVertexWeightCount skn i
        --format "Catch you V:%\tno.bones:%\n" i infbones
		bid = skinOps.GetVertexWeightBoneID skn i 1
		bname = skinOps.GetBoneName skn bid 0
 		tt = "getUserProp $'" + bname + "' \"BoneIndex\""
		idx = execute tt
		bv = #( idx )

		bw = #( (skinOps.GetVertexWeight skn i 1) )
		for j = 2 to infbones do (
			bid = skinOps.GetVertexWeightBoneID skn i j
			bname = skinOps.GetBoneName skn bid 0
 			tt = "getUserProp $'" + bname + "' \"BoneIndex\""
			idx = execute tt
			append bv idx

			append bw (skinOps.GetVertexWeight skn i j)
			tmp = sortBybw bv bw
			bv = tmp[1]
			bw = tmp[2]
		)--end for j

		--normalize boneweight if influencing bones more than 4
		-------------------------------------------------------
		if infbones > 4 then (
			infactor = 1 / ( bw[1] + bw[2] + bw[3] + bw[4] )
			for j = 1 to 4 do bw[j] *= infactor
		)
	
		--Root bone must be the last one in array
		-----------------------------------------
		fr = finditem bv 0 
		if fr != 0 then (
			swap bv[fr] bv[(bv.count)]
			swap bw[fr] bw[(bv.count)]
		)
	
		--fill up arrays to 4 bone spaces
		---------------------------------
		for k = (bv.count+1) to 4 do (
			append bv 0
			append bw 0
		)
	
		append bvAry bv
		append bwAry bw
        
		for id in bv where id != 0 do spBoneAry[id] = id

	)--end for i
    
	for i = spBoneAry.count to 1  by -1 do if  spBoneAry[i] == undefined then deleteitem spBoneAry i
	--format "spBoneAry:%\n" spBoneAry

	return #(bvAry,bwAry,spBoneAry)

)
--end fn CreateSkinData	--<s2>--
--
fn CreateInvBoneMatrices BonesAry Roottfm bodypart = (
	InvBoneMatrices = #()
    if (ver == 0x1803FFFF)AND(bodypart==true) then Roottfm = BonesAry[1].transform --; format "\n\nRoot bone:%\n\n" BonesAry[1].name
	for i = 1 to BonesAry.count do (
		parentindex = finditem BonesAry BonesAry[i].parent
		if parentindex == 0 then append InvBoneMatrices ( BonesAry[i].transform * inverse (Roottfm) )
		else append InvBoneMatrices (  Roottfm * inverse( BonesAry[i].transform) )        
	)--end for i
	   
	return InvBoneMatrices
	
)
--fn CreateInvBoneMatrices				--<B2>--
--
fn wSkinPlg f SkinData BonesAry Roottfm bodypart Iscale ver = (
	--format "SkinData:%\n" SkinData[1].count

    if ver == 0x1803FFFF then skinPlg_size = (SkinData[1].count * 20) + (BonesAry.count * 64) + 16 + SkinData[3].count
	else skinPlg_size = (SkinData[1].count * 20) + (BonesAry.count * 68) + 4

	writeLong f 0x116                       --Skin PLG
	writeLong f skinPlg_size
	writeLong f ver

	if ver == 0x1803FFFF then (
		writeByte f BonesAry.count
		writeByte f SkinData[3].count
		writeByte f (getUserProp BonesAry[1] "SPunknown")
		writeByte f 0
		for id in SkinData[3] do writeByte f id 
	) else writeLong f BonesAry.count

	--format "Verts:%\n"  SkinData[1].count
	for i = 1 to SkinData[1].count do (
		writeByte f SkinData[1][i][1]
		writeByte f SkinData[1][i][2]
		writeByte f SkinData[1][i][3]
		writeByte f SkinData[1][i][4]
	)--end for i
    
	for i = 1 to SkinData[2].count do (
		writeFloat f SkinData[2][i][1]
		writeFloat f SkinData[2][i][2]
		writeFloat f SkinData[2][i][3]
		writeFloat f SkinData[2][i][4]
	)--end for i

    ibm = CreateInvBoneMatrices BonesAry Roottfm bodypart
	for jj = 1 to ibm.count do (
		tfm = ibm[jj]
        if ver != 0x1803FFFF then (
		    writeShort f 0xDEAD
		    writeShort f 0xDEAD
        ) 
		writeFloat f tfm.row1.x
		writeFloat f tfm.row1.y
		writeFloat f tfm.row1.z
		writeFloat f 0                      --unknown ?? Testing
		writeFloat f tfm.row2.x
		writeFloat f tfm.row2.y
		writeFloat f tfm.row2.z
		writeFloat f 0                      --unknown ?? Testing
		writeFloat f tfm.row3.x
		writeFloat f tfm.row3.y
		writeFloat f tfm.row3.z
		writeFloat f 0                      --unknown ?? Testing
		tpos = tfm.row4 * Iscale 
		writeFloat f tpos.x
		writeFloat f tpos.y
		writeFloat f tpos.z    
		writeFloat f 0                      --unknown ?? Testing
	)--end for jj

	if ver == 0x1803FFFF then (
		writeFloat f 0; writeFloat f 0; writeFloat f 0
	)
    
	if ver != 0x1803FFFF then (
		writeLong f 0x105                       --Morph PLG
		writeLong f 4
		writeLong f ver
		writeLong f 0
		return (skinPlg_size + 28)
	)

	return (skinPlg_size + 12)
	    
)
--end fn wSkinPlg				--<e11>--
--
--3-----------------------
-- Functions for Export --
--------------------------
fn wClump f object_count ver = (
	WriteLong f 0x10						-- rwClump
	WriteLong f 0							-- temp for clump size
	WriteLong f ver							-- file version for GTA3
	--DATA--
	WriteLong f 0x01						-- rwData
	if (ver == 0x0800FFFF)OR(ver == 0x00000310) then (
		WriteLong f	4
		WriteLong f ver						-- file version for GTA3
		WriteLong f object_count
	) else (
		WriteLong f	12
		WriteLong f ver						-- file version for GTA3
		WriteLong f object_count
		WriteLong f 0; WriteLong f 0
	)
)

fn wClumpobj f object_count light_count ver = (
	WriteLong f 0x10						-- rwClump
	WriteLong f 0							-- temp for clump size
	WriteLong f ver							-- file version for GTA3
	--DATA--
	WriteLong f 0x01						-- rwData
	if (ver == 0x0800FFFF) then (
		WriteLong f	4
	) else (
		WriteLong f	12
	)
	WriteLong f ver
	WriteLong f object_count
	if (ver != 0x0800FFFF) then (
		WriteLong f light_count
		WriteLong f 0
	)
)
--end fn wClump				--<e1>--
--
fn wFrameList f Allobjects Iscale ver = (
	tmp = Allobjects as array
	writeLong f 0x0E							-- rwFrameList
	FL_length_add = ftell f
	writeLong f 0								-- temp for clump size
	writeLong f ver								-- file version for GTA3
    
	writeLong f 0x01							-- rwData
	writeLong f ( tmp.count * 56 + 4 )
	writeLong f ver								-- file version for GTA3
	writeLong f tmp.count
	for i = 1 to tmp.count do (
		if tmp[i].parent != undefined then (
			bkup = tmp[i].parent.transform
			tmp[i].parent.transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])
			tfm = tmp[i].transform
			tmp[i].parent.transform = bkup
		) else ( 
			tfm = matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0]
			--format "Root->%\n" tmp[i].name
		)
		writeFloat f tfm.row1.x
		writeFloat f tfm.row1.y
		writeFloat f tfm.row1.z
		writeFloat f tfm.row2.x
		writeFloat f tfm.row2.y
		writeFloat f tfm.row2.z
		writeFloat f tfm.row3.x
		writeFloat f tfm.row3.y
		writeFloat f tfm.row3.z
		tpos = tfm.row4 * Iscale
		writeFloat f tpos.x
		writeFloat f tpos.y
		writeFloat f tpos.z
		writeLong f ( finditem tmp tmp[i].parent - 1 )
		if tmp[i].parent != undefined then writeLong f 3
		else writeLong f 131075
	)--end for i
	for i = 1 to tmp.count do (
		WriteLong f 0x03						--rwExtension
		WriteLong f ( tmp[i].name.count + 12 )
		WriteLong f ver							-- file version for GTA3
		WriteLong f 0x0253F2FE					--rwFrame  39056126
		WriteLong f ( tmp[i].name.count )
		WriteLong f ver							-- file version for GTA3
		writeString f tmp[i].name
		fseek f -1 #seek_cur
	)--end for i
	local here = ftell f
	FL_length = here - 8 - FL_length_add
	fseek f FL_length_add #seek_set
	WriteLong f FL_length
	fseek f here #seek_set
)
--end fn wFrameList			--<e2>--
--
fn wAtomic f Fidx Gidx ver noCol hasRef = (

	atmbyte  = 40
	if hasRef == true or hasRef == 3 then (
		atmbyte += 16
		if (ver == 0X1803FFFF) then atmbyte += 20
	)
	if (ver == 0X1803FFFF)AND(noCol == 2) then atmbyte += 16

    WriteLong f 0x14						-- rwAtomic
	WriteLong f atmbyte
	WriteLong f ver							-- file version for GTA3
	writeLong f 1
	writeLong f 16							-- fixed for GTA3
	WriteLong f ver							-- file version for GTA3
	writeLong f (Fidx - 1)
	writeLong f (Gidx - 1)
	writeLong f 5							-- unknown??
	writeLong f 0							-- unknown??
	writeLong f 3							-- rwExtension

	extbyte = atmbyte - 40
    
	writeLong f extbyte
	writeLong f ver

	if extbyte > 0 then (

		if hasRef == true then (
			if (ver == 0X1803FFFF) then (
				writeLong f 0x1F					--Right To Render
				writeLong f 8
				writeLong f ver
				writeLong f 0X120
				writeLong f 0
			)
			writeLong f 0x120						-- rwMaterialEffectPLG
			writeLong f 4							-- fixed for GTA3
			WriteLong f ver							-- file version
			writeLong f 1
		) else if hasRef == 3 then (
			if (ver == 0X1803FFFF) then (
				writeLong f 0x1F					--Right To Render
				writeLong f 8
				writeLong f ver
				writeLong f 0X133
				writeLong f 1
			)
			writeLong f 0x120						-- rwMaterialEffectPLG
			writeLong f 4							-- fixed for GTA3
			WriteLong f ver							-- file version
			writeLong f 1			
		)
		if (ver == 0x1803FFFF)AND(noCol == 2) then (
			writeLong f 0x253F2F3						-- Extra parts for SA vehicle
			writeLong f 4							-- fixed for GTA3
			WriteLong f ver							-- file version for GTA3    
			writeLong f 0x53F2009A   
		)
    )
)
--end fn wAtomic				--<e3>--
--
fn wGeometryList f Allobjects ver = (
    geo = for obj in Allobjects where superclassof obj == geometryClass collect obj
    writeLong f 0x1A						-- rwGeometryList
	GL_length_add = ftell f
	writeLong f 0							-- temp for GeometryList size
	WriteLong f ver							-- file version for GTA3
	writeLong f 1							-- rwData
	writeLong f 4
 	WriteLong f ver							-- file version for GTA3
	writeLong f geo.count
	return GL_length_add
)
--end fn wGeometryList			--<e4>--
--
fn wMaterialSplit f msh ver = (
	writeLong f 0x050E						-- rwMatrialSplit
	MSplt_length_add = ftell f
	writeLong f 0							-- temp for MaterialSplit size
	WriteLong f ver							-- file version for GTA3
	
	local FIDAry = #()
	if classof msh.material != Multimaterial then (
		FIDAry[1] = #()
		for i = 1 to msh.numfaces do append FIDAry[1] i
	) else (
		for i = 1 to msh.material.count do FIDAry[i] = #()
 	    for i = 1 to msh.numfaces do (
        	id = mod (getfaceMatid msh i) msh.material.count
			if id == 0 then id = msh.material.count
	        append FIDAry[id] i
    	)--end for i
	)--end if/else
    writeLong f 0							--Split Type
    writeLong f FIDAry.count
    writeLong f (msh.numfaces * 3)
    for i = 1 to FIDAry.count do (
        writeLong f (FIDAry[i].count * 3)
        writeLong f (i - 1)
        for j = 1 to FIDAry[i].count do (
            local tmp = getFace msh FIDAry[i][j]
    		writeLong f (tmp.x - 1)
            writeLong f (tmp.y - 1)
            writeLong f (tmp.z - 1)
        )--end for j
    )--end for i
	local here = ftell f
	MSplt_length = here - 8 - MSplt_length_add
	fseek f MSplt_length_add #seek_set
	writeLong f MSplt_length
	fseek f here #seek_set
)
--end fn wMaterialSplit		--<e5>--
--
fn wTexture f mtl isreflection ver = ( 
	writeLong f 0x06						-- rwTexture
	T_length_add = ftell f
	writeLong f 0							-- temp for Material size
	WriteLong f ver							-- file version for GTA3
	writeLong f 1
	writeLong f 4							-- Data size (filter flag, unknown)
	WriteLong f ver							-- file version for GTA3   
	
	if isreflection == true or isreflection == -1 or isreflection == -2 or isreflection == -3 or isreflection == -4 then (
		if isreflection == true then (
			tname = getFilenameFile mtl.reflectionMap.filename
			Filtertype = mtl.reflectionMap.filtering
			mname = ""
		) else if isreflection == -1 then (
			tname = getFilenameFile mtl.bumpMap.filename
			Filtertype = mtl.bumpMap.filtering
			mname = ""
		) else if isreflection == -2 then (
			tname = getFilenameFile mtl.dualMap.filename
			Filtertype = mtl.dualMap.filtering
			mname = ""
		) else if isreflection == -3 then (
			if mtl.dkpNmap != undefined then (
				tname = getFilenameFile mtl.dkpNmap.filename
				mname = ""
			) else (
				tname = ""
				mname = ""
			)
		) else if isreflection == -4 then (
			if mtl.dkpRmap != undefined then (
				tname = getFilenameFile mtl.dkpRmap.filename
				mname = ""
			) else (
				tname = ""
				mname = ""
			)
		)
	) else (
		if classof mtl == GTA_Mtl then (
			if (classof mtl.alphamap == Bitmaptexture)AND(mtl.use_alphamap == true) then (
				mname = getFilenameFile mtl.alphamap.filename
				Filtertype = mtl.alphamap.filtering
			) else mname = ""        
			if (classof mtl.colormap == Bitmaptexture)AND(mtl.use_colormap == true) then (
				tname = getFilenameFile mtl.colormap.filename
				Filtertype = mtl.colormap.filtering
			) else tname = ""
        ) else (
			if (classof mtl.opacitymap == Bitmaptexture)AND(mtl.opacityMapEnable == true) then (
				mname = getFilenameFile mtl.opacitymap.filename
				Filtertype = mtl.opacitymap.filtering
			) else mname = ""
			if (classof mtl.diffusemap == Bitmaptexture)AND(mtl.diffuseMapEnable == true) then (
				tname = getFilenameFile mtl.diffusemap.filename
				Filtertype = mtl.diffusemap.filtering
			) else tname = ""
		)--end if/else GTA_mtl
	)
	
	if isreflection == -3 or isreflection == -4 then (
		writeShort f 0x1106
		writeShort f 0
	) else (
		------- Filter Type ------------
		case FilterType of (
			0: writeShort f 0x106
			1: writeShort f 0x102
			2: writeShort f 0x101
			default: writeShort f 0x1102
		)--end case

		if ver == 0X1803FFFF then writeShort f 1
			else writeShort f 0
		----------------------------------
	)

	local noffset = mod (tname.count + 1) 4
	if noffset != 0 then  nc = ((tname.count + 1)/4 + 1) * 4
	else  nc = tname.count + 1
	
	writeLong f 0x02						-- rwString
	writeLong f nc
	WriteLong f ver							-- file version for GTA3    
	writeString f tname
    
	if noffset != 0 then (
		for i = 1 to (4 - noffset) do 
			writeByte f 0
	)
    
	local noffset = mod (mname.count + 1) 4
	if noffset != 0 then  nc = ((mname.count + 1)/4 + 1) * 4
	else  nc = mname.count + 1
    
	writeLong f 0x02						-- rwString
	writeLong f nc
	writeLong f ver							-- file version for GTA3    
	writeString f mname
    
	if noffset != 0 then (
		for i = 1 to (4 - noffset) do 
			writeByte f 0
	)
    
	writeLong f 3
	writeLong f 0
	writeLong f ver							-- file version for GTA3 
	local here = ftell f
	T_length = here - 8 - T_length_add
	fseek f T_length_add #seek_set
	writeLong f T_length
	fseek f here #seek_set  
)
--end fn wTexture				--<e6>--
--
fn wMaterial f msh mtl ver = (
	writeLong f 0x07						-- rwMaterial
	M_length_add = ftell f
	writeLong f 0							-- temp for Material size
	WriteLong f ver							-- file version for GTA3
	writeLong f 1							-- rwData
	writeLong f 28							-- Data size (material_count, unknown)
 	WriteLong f ver							-- file version for GTA3 
	writeLong f 0							--unknown??
	if mtl != undefined then (
		if classof mtl == GTA_Mtl then (
			writeByte f mtl.color.r
			writeByte f mtl.color.g
			writeByte f mtl.color.b
			writeByte f mtl.alpha
			if ver == 0X1803FFFF then writeLong f 16688092
			else writeLong f 1629820					--unknown??
			if (classof mtl.colormap == Bitmaptexture)AND(mtl.use_colorMap == true) \
						OR(classof mtl.alphamap == Bitmaptexture)AND(mtl.use_alphamap == true) \
						then	writeLong f 1
			else writeLong f 0
			writeFloat f mtl.amb
			writeFloat f mtl.spc
			writeFloat f mtl.dif
			if (classof mtl.colormap == Bitmaptexture)AND(mtl.use_colorMap == true) \
						OR(classof mtl.alphamap == Bitmaptexture)AND(mtl.use_alphamap == true) \
						then 		wTexture f mtl false ver
		) else (
			writeByte f (mtl.diffuse.r as integer) 
			writeByte f (mtl.diffuse.g as integer)
			writeByte f (mtl.diffuse.b as integer)
			writeByte f ((mtl.opacity/100 * 255.0) as integer) #unsigned
			if ver == 0X1803FFFF then writeLong f 16688092
			else writeLong f 1629820					--unknown??
			--texture_count--
			if (classof mtl.diffusemap == Bitmaptexture)AND(mtl.diffuseMapEnable == true) \
						OR(classof mtl.opacitymap == Bitmaptexture)AND(mtl.opacityMapEnable == true) \
						then	writeLong f 1
			else writeLong f 0
			writeFloat f 1.0					--unknown??
			writeFloat f (mtl.specular_level / 100.0)
			writeFloat f 1.0					--unknown??
			if (classof mtl.diffusemap == Bitmaptexture)AND(mtl.diffuseMapEnable == true) \
						OR(classof mtl.opacitymap == Bitmaptexture)AND(mtl.opacityMapEnable == true) \
						then 		wTexture f mtl false ver
		)

		writeLong f 3					-- rwExtension
		MatExt_Length_add = ftell f
		writeLong f 0					-- temp for Material extension size
		writeLong f ver					-- file version for GTA3
        
		--Reflection--
		chMfx = true
		try mtl.matEffect catch chMfx = false	
		if chMfx == true then (
			if mtl.matEffect != undefined then (
				if mtl.dkpRmap != undefined and mtl.dkpNmap == undefined then chMfx = false
				else (
					if (mtl.matEffect as integer) == 6 and (mtl.dkpNmap != undefined ) then chMfx = true else chMfx = false
				)
			)
		) else chMfx = false
		
		if chMfx == false then (
			expReflection = false
			if (classof mtl == GTA_Mtl)AND(mtl.use_RF == true) then (
				if (ver == 0X1803FFFF)AND((classof mtl.reflectionmap != Bitmaptexture)OR(mtl.use_reflectionmap == false)) then (
					if (mtl.matEffect as integer) == 4 then format "     - Reflection map (no texture - bump not support )\n"
					else format "     - Reflection map (no texture )\n"
					writeLong f 0x0120
					writeLong f 24
					writeLong f ver
					writeLong f 2
					writeLong f 2
					writeFloat f (mtl.Reflection/100)
					writeLong f 0
					writeLong f 0
					writeLong f 0
					setUserProp msh "Ref" true
					expReflection  = false
				) else if ((classof mtl.reflectionmap == Bitmaptexture)AND(mtl.use_reflectionmap == true)) then expReflection = true
			) else if (classof mtl == standardmaterial)AND(mtl.reflectionMapEnable==true)AND(classof mtl.reflectionmap == Bitmaptexture) then expReflection = true
			if expReflection  == true then (
				writeLong f 0x0120				--Material Effects PLG
				matEffPLG_Length_add = ftell f
				writeLong f 0					-- temp for Material Effects PLG size
				writeLong f ver					-- file version for GTA3	
				chMfx = true
				try mtl.matEffect catch chMfx = false		
				if chMfx == true then (
					if (mtl.matEffect as integer) == 4 then writeLong f 3 else (
						writeLong f 2
						format "     - Reflection map\n"
					)
				) else (
					writeLong f 2
					format "     - Reflection map\n"
				)
				if chMfx == true and (mtl.matEffect as integer) == 4 then (
					expReflection = true
					format "     - (Reflection + Bump map)\n"
					writeLong f 1 	-- Type (1 - bump)
					if classof mtl == standardmaterial then (
					if (mtl.bumpMapAmount as float) > 0.0 then bAmount = (mtl.bumpMapAmount as float) / 100.0
					else bAmount = 0.0
					) else bAmount = (mtl.bumpMapAmount as float)
					writeFloat f bAmount
					writeLong f 0 	-- Replace Map ( 0/1 )
					writeLong f 1	-- Use bump Map ( 0/1 )
					wTexture f mtl -1 ver
				)
				writeLong f 2		-- unknown
				if classof mtl == GTA_Mtl then writeFloat f (mtl.Reflection/100.0)
				else writeFloat f (mtl.reflectionmapamount/100.0)
				writeLong f 0;writeLong f 1		-- unknown
				wTexture f mtl true ver
				if chMfx == true then ( if (mtl.matEffect as integer) != 4 then writeLong f 0)
				else writeLong f 0
				here = ftell f
				fseek f matEffPLG_Length_add #seek_set
				writeLong f (here - matEffPLG_Length_add - 8)
				fseek f here #seek_set
				setUserProp msh "Ref" true
			) 
			
			if expReflection == false then (
				-- BUMP Check
				chMfx = true
				try mtl.matEffect catch chMfx = false
				if chMfx == false  then ( -- check original bump
					chMfx = mtl.bumpMapEnable
					if chMfx == true and mtl.bumpMap != undefined then chMfx = true else chMfx = false 
				) else if (mtl.matEffect as integer) == 3 and mtl.bumpMap != undefined then chMfx = true else chMfx = false  -- check gtaMat bump
				if chMfx == true  then (
					format "     - Bump map\n"
					writeLong f 0x0120				--Material Effects PLG
					matEffPLG_Length_add = ftell f
					writeLong f 0					-- temp for Material Effects PLG size
					writeLong f ver					-- file version for GTA3			
						writeLong f 1 	-- General type ( rpMATFXEFFECTBUMPENVMAP )
						writeLong f 1 	-- Type (1 - bump)
						if classof mtl == standardmaterial then (
							if (mtl.bumpMapAmount as float) > 0.0 then bAmount = (mtl.bumpMapAmount as float) / 100.0
							else bAmount = 0.0
						) else bAmount = (mtl.bumpMapAmount as float)
						writeFloat f bAmount
						writeLong f 0 	-- Replace Map ( 0/1 )
						writeLong f 1	-- Use bump Map ( 0/1 )
						wTexture f mtl -1 ver
						writeLong f 0			
					here = ftell f
					fseek f matEffPLG_Length_add #seek_set
					writeLong f (here - matEffPLG_Length_add - 8)
					fseek f here #seek_set
					setUserProp msh "Ref" true
				)
				-- DUAL map Check
				chMfx = true
				try mtl.matEffect catch chMfx = false
				if chMfx == true  then (
					if (mtl.matEffect as integer) == 5 and mtl.dualMap != undefined then chMfx = true else chMfx = false  -- check DUAL gtaMat 
				)
				if chMfx == true  then (
					format "     - Dual map\n"
					writeLong f 0x0120				--Material Effects PLG
					matEffPLG_Length_add = ftell f
					writeLong f 0					-- temp for Material Effects PLG size
					writeLong f ver					-- file version for GTA3			
						writeLong f 4 	-- General type ( rpMATFXEFFECTDUAL )
						writeLong f 4 	-- Type (4 - Dual map)
						writeLong f (mtl.p_srcblend  as integer) 
						writeLong f (mtl.p_destblend  as integer) 
						writeLong f 1	-- Use bump Map ( 0/1 )
						wTexture f mtl -2 ver
						writeLong f 0			
					here = ftell f
					fseek f matEffPLG_Length_add #seek_set
					writeLong f (here - matEffPLG_Length_add - 8)
					fseek f here #seek_set
					setUserProp msh "Ref" true
				)
			)
		) else (
			format "     - Normal map(DK)\n"
			writeLong f 0x133				--Material Effects PLG
			matEffPLG_Length_add = ftell f
			writeLong f 0					-- temp for Material Effects PLG size
			writeLong f ver					-- file version for GTA3			
				writeLong f 49 	-- General type
				wTexture f mtl -3 ver	
			writeFloat f mtl.dkpRAmount	
			wTexture f mtl -4 ver	
			here = ftell f
			fseek f matEffPLG_Length_add #seek_set
			writeLong f (here - matEffPLG_Length_add - 8)
			fseek f here #seek_set
			setUserProp msh "Ref" 3
		) -- dkpRmap
		
		--RefMat--
		if (ver == 0X1803FFFF) then (
			expRefMat = false
			if (classof mtl == GTA_Mtl)AND(mtl.use_SAS == true) then expRefMat = true
			else if (classof mtl == standardmaterial)AND(mtl.specular != (color 0 0 0)) then expRefMat = true
			if expRefMat == true then (
				writeLong f 0x0253F2FC				--RefMat
				writeLong f 24
				writeLong f ver					-- file version for GTA3	
				writeFloat f (mtl.specular.r/255.0)
				writeFloat f (mtl.specular.g/255.0)
				writeFloat f (mtl.specular.b/255.0)
            
				if classof mtl == GTA_Mtl then (
					writeFloat f (mtl.spec_alpha/255.0)
					writeFloat f mtl.blend
				) else (
					writeFloat f 1
					bnd = mtl.glossiness + mtl.soften
					writeFloat f bnd
				)
				writeFloat f 0
            )
		)
		
        --SpecMat???--
		if (ver == 0X1803FFFF) then (
			expSpecMat = false
			if (classof mtl == GTA_Mtl)AND(mtl.use_SI == true) then expSpecMat = true
			else if (classof mtl == standardmaterial)AND(classof mtl.SpecularMap == Bitmaptexture)AND(mtl.SpecularMapEnable == true) then expSpecMat = true
			if expSpecMat == true then (
				writeLong f 0x0253F2F6				--Unknown??
				writeLong f 28					-- ??
				writeLong f ver					-- file version for GTA3
 				if classof mtl == GTA_Mtl then writeFloat f (mtl.spec_power/100)
            	else 		writeFloat f (mtl.Specular_level/100.0)
 				try (SPname = getFilenameFile mtl.SpecularMap.filename)catch(SPname = " ")
 				if SPname.count >23 then SPname = substring SPname 1 23
            	writeString f SPname
            	for ii = 1 to (23 - SPname.count) do ( writeByte f 0 )
			)
		)

		--End of Material Extension--
		here = ftell f
		fseek f MatExt_Length_add #seek_set
		writeLong f (here - MatExt_Length_add - 8)
		fseek f here #seek_set
        
	) else (                    -- if no material assigned
		writeByte f ((msh.wirecolor.r) as integer)
		writeByte f ((msh.wirecolor.g) as integer)
		writeByte f ((msh.wirecolor.b) as integer)
		writeByte f 255

		if ver == 0X1803FFFF then writeLong f 16688092
		else writeLong f 1629820					--unknown??

		writeLong f 0
		writeFloat f 1.0					--unknown??
		writeFloat f 0.05
		writeFloat f 1.0					--unknown??
		writeLong f 0x03					-- rwExtension
		writeLong f 0						-- Data size (material_count, unknown)
		writeLong f ver						-- file version for GTA3 
	)

	local here = ftell f
	M_length = here - 8 - M_length_add
	fseek f M_length_add #seek_set
	writeLong f M_length
	fseek f here #seek_set 
)
--end fn wMaterial				--<e7>--
--
fn wMaterialList f msh ver = (
    writeLong f 0x08						-- rwMaterialList
	ML_length_add = ftell f
	writeLong f 0							-- temp for MaterialList size
	WriteLong f ver							-- file version for GTA3
	writeLong f 0x01						-- rwData
    if classof msh.material != MultiMaterial then (
        writeLong f 8						-- Data size (material_count, unknown)
 	    WriteLong f ver						-- file version for GTA3 
        writeLong f 1
        writeLong f -1						--unknown??
        wMaterial f msh msh.material ver
    ) else (
        local DataSize = (1 + msh.material.count) * 4
 	    writeLong f DataSize				-- Data size (material_count, unknown)
        WriteLong f ver						-- file version for GTA3 
        writeLong f (msh.material.count)
		for i = 1 to msh.material.count do 
  		      writeLong f -1				--unknown??
        for i = 1 to msh.material.count do (
            wMaterial f msh msh.material[i] ver
        )
    )--end if/else
    local here = ftell f
	ML_length = here - 8 - ML_length_add
	fseek f ML_length_add #seek_set
	writeLong f ML_length
	fseek f here #seek_set
)
--end fn wMaterialList			--<e8>--
--
fn wGeometry f mshAry BonesAry MMC TUV CPV NOR Iscale SkinPlugData bodypart ver = (
	local UV1check = false, UV2check = false
	vcDefolt = gVcDefolt
	nvcDefolt = gNvcDefolt
	local msh = mshAry[1]
	format "     Verts: %  Tris: %\n"  msh.numverts msh.numfaces
	if SkinPlugData != undefined then Roottfm = (coordsys local msh.transform)
	if (ver == 0x1803FFFF)AND(bodypart==true) then (
		msh.pivot = (coordsys local BonesAry[1].pivot)
		msh.rotation -= BonesAry[1].rotation 
		msh.pos = [0,0,0]
	) else msh.transform = matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0]
	--byte Flag info.
	--      1   use Tri-Strip
	--      2   Position
	--      4   Texture UV
	--      8   Prelit (Vertex Colors)
	--      16  Normal
	--      32  Light
	--      64  Modulate Material Color
	--      128 Textured2 ??
	local GeometryFlags = 0
	
	if ver != 0X0C02FFFF then (
		if (gValpha == true) and (meshop.getMapSupport msh -2) == true then (
			GeometryFlags = 0
		) else (
			GeometryFlags += 32
			format "     - Light\n"
		)
	) else (
		GeometryFlags += 32
		format "     - Light\n"
	)
	
	if ((MMCCheck msh) == true) then (
		GeometryFlags += 64
		format "     - MMC\n"
	)
	if NOR == true then (
		GeometryFlags += 16
		format "     - normals\n"
	)
	if (msh.numTVerts > 0) then (
		if (msh.numTVerts == msh.numverts) then (
			GeometryFlags += 4
			format "     - UV1\n"
			UV1check = true
		) else format "     debug -> [check UV]: #error num UV1\n"
	)
	if (meshop.getMapSupport msh 2 == true) then (
		if ((meshop.getNumMapVerts msh 2) == msh.numverts) then (
			GeometryFlags += (128 - 4) --Texture2:on, Texture:off
			UV2check = true
			format "     - UV2\n"
		) else format "     debug -> [check UV]: #error num UV2\n"
	)
	
	if (bNVC == true)OR(CPV == true) then (
		if (CPV == true) then (
			if ((meshop.getMapSupport msh 0) == true) then (
				if msh.numCPVVerts == msh.numverts then (
					format "     - Vertex Color\n"
					GeometryFlags += 8
				) else format "     - Vertex Color | debug -> [check VC]: #invalid number of VC. Data will be recreated automatically\n"
			) else (
				GeometryFlags += 8
				format "     - [Warning] Vertex Color NOT EXIST. Defolt: %\n" vcDefolt
			)
		) else GeometryFlags += 8
	)
	--format " = % %\n" (meshop.getNumMapVerts msh -1)  msh.numverts
	if (bNVC == true) then (
		if ((meshop.getMapSupport msh -1) == true) then (
			if ((meshop.getNumMapVerts msh -1) == msh.numverts) then (
				format "     - Night Vertex Color\n"
			) else format "     - Night Vertex Color | debug -> [check NVC]: #invalid number of NVC. Data will be recreated automatically\n"
		) else (
			format "     - [Warning] Night Vertex Color NOT EXIST. Defolt: %\n" nvcDefolt
		)
	)
	vAlphStat = false
	if (gValpha == true) and ((meshop.getMapSupport msh -2) == true) and ((meshop.getNumMapVerts msh -2) == msh.numverts) then (
		format "     - Vertex Alpha\n"
		vAlphStat = true
	)
		
	if lightArr.count >= 1 then format "     - 2dfx: light (%)\n" lightArr.count
	
	if (ver == 0x1803FFFF)OR(ver == 0x0C02FFFF) then GeometryFlags += 2
            
	writeLong f 0x0F				-- rwGeometry
	G_length_add = ftell f
	writeLong f 0			        -- temp for Geometry size
	WriteLong f ver	        		-- file version for GTA3
	writeLong f 1
	msh_length_add = ftell f
	writeLong f 0			        -- temp for mesh size
 	WriteLong f ver	        		-- file version for GTA3
	writeShort f GeometryFlags		-- GeometryFlags

	if (meshop.getMapSupport msh 2 == true)AND(TUV == true) then writeShort f 2
	else if (msh.numTVerts > 0)AND(TUV == true) then writeShort f 1
    else writeShort f 0			        -- no. texture in geometry

	writeLong f msh.numfaces
	writeLong f msh.numverts
	writeLong f 1			        -- no. morph target

	if (ver == 0x1003FFFF)OR(ver == 0x1803FFFF) then ()
	else (
		writeFloat f 1			        -- Ambient
		writeFloat f 1			        -- Diffuse
		writeFloat f 1			        -- Specular
	)
	format "     write data..\n" 
	pbUpdate()
	interfaceUpdate()
	
	--Vertex Colors--
	try (
		if (bNVC == true)OR(CPV == true) then (
			if (msh.numCPVVerts == msh.numverts) and (CPV == true) then (
				popPrompt()
				pushPrompt ("Export DFF: " + (objExpName as string) + " - write vc...")
				for i = 1 to msh.numCPVVerts do (
					VCol = getVertColor msh i
					if vAlphStat == true then (vA = ((meshop.getMapVert msh -2 i) * 255.0))
					else vA = [255,255,255]
					writeByte f (VCol.r as integer) #unsigned
					writeByte f (VCol.g as integer) #unsigned
					writeByte f (VCol.b as integer) #unsigned
					writeByte f (vA.x  as integer) #unsigned
				) 
			) else (
				popPrompt()
				pushPrompt ("Export DFF: " + (objExpName as string) + " - write vc...")
				for i= 1 to msh.numverts do (		
					if vAlphStat == true then (vA = ((meshop.getMapVert msh -2 i) * 255.0))
					else vA = [255,255,255]					
					writebyte f vcDefolt #unsigned
					writebyte f vcDefolt #unsigned
					writebyte f vcDefolt #unsigned
					writebyte f (vA.x  as integer) #unsigned
				)
			)
		)
	) catch (format "     [Error] write VC\n")
	--END - Vertex Colors--
	interfaceUpdate()
	popPrompt()
	pushPrompt ("Export DFF: " + (objExpName as string) + " - write uv...")
	--UVs--
	try (
		if (UV1check == true) then (
			for i = 1 to msh.numverts do (
				tmp = getTVert msh i
				writeFloat f tmp.x
				writeFloat f ( 1- tmp.y)
			)--end for i
		)	
	) catch (format "     [Error] write UV1\n")
	interfaceUpdate()
	--UV2s--
	try (
		if (UV2check == true) then (
			for j = 1 to msh.numverts do (
				tmp = meshop.getMapVert msh 2 j
				writeFloat f tmp.x
				writeFloat f ( 1- tmp.y)
			)
		)	
	) catch (format "     [Error] write UV2\n")	

	pbUpdate()
	interfaceUpdate()
	popPrompt()
	pushPrompt ("Export DFF: " + (objExpName as string) + " - write faces...")
	--faces--
	try (
		if exp_lockDFF == true then (
			for i = 1 to msh.numfaces do (
				tmp = getface msh i
				writeShort f (random 1 (msh.numverts-1))
				writeShort f (random 1 (msh.numverts-1)) 
				writeShort f 0
				writeShort f (random 1 (msh.numverts-1))
			)
		) else (
			for i = 1 to msh.numfaces do (
				tmp = getface msh i
				writeShort f (tmp.y - 1)
				writeShort f (tmp.x - 1)
				writeShort f 0
				writeShort f (tmp.z - 1)
			)
		)
	) catch (format "     [Error] write Faces\n")
	
	--bounding Sphere--
	interfaceUpdate()
	try (
		writeFloat f (coordsys local msh.center.x)
		writeFloat f (coordsys local msh.center.y)
		writeFloat f (coordsys local msh.center.z) 
		bkupcenter = (coordsys local msh.center)
		msh.center = [0,0,0]
		rds = 0.0
		for v in msh.verts do (
			vt = v.pos
			rfp = length (vt)		
			if rds < rfp then rds = rfp
		)
		msh.center = bkupcenter	
		writeFloat f rds
		writeLong f 1									--unknown??
		if (NOR  == true) then	writeLong f 1			--Normal Flag??
		else	writeLong f 0
	) catch (format "     [Error] write bounding Sphere\n")
	interfaceUpdate()
	popPrompt()
	pushPrompt ("Export DFF: " + (objExpName as string) + " - write verts...")
	--vertices--
	try (
		for i = 1 to msh.numverts do (
			tmp = (coordsys local getVert msh i)
			writeFloat f tmp.x 
			writeFloat f tmp.y
			writeFloat f tmp.z
		)
	) catch (format "     [Error] write vertices\n")
	interfaceUpdate()
	--normals--	
	try (
		if (NOR == true) then ( 
			popPrompt()
			pushPrompt ("Export DFF: " + (objExpName as string) + " - write normals...")
			for i = 1 to msh.numverts do (
				tmp = getNormal msh i
				writeFloat f tmp.x
				writeFloat f tmp.y
				writeFloat f tmp.z
			)--end for i
		)--end if NOR
	) catch (format "     [Error] write normals\n")
	
	local here = ftell f
	msh_length = here - 8 - msh_length_add
	fseek f msh_length_add #seek_set
	writeLong f msh_length
	fseek f here #seek_set
	interfaceUpdate()
	try (
		wMaterialList f msh ver
	) catch (format "     [Error] write MaterialList\n")

	writeLong f 0x03				-- rwExtension
	GExt_length_add = ftell f
	writeLong f 0					-- temp for Geometry Extension
 	WriteLong f ver					-- file version for GTA3
	interfaceUpdate()
	try (
		wMaterialSplit f msh ver
	) catch (format "     [Error] write BIN Mesh PLG\n")

	if BonesAry != undefined then (
 		--format "3: SkinPlugData:%\n" SkinPlugData[1].count
		wSkinPlg f SkinPlugData BonesAry Roottfm bodypart Iscale ver
	)
	interfaceUpdate()
	if ver == 0x1803FFFF then (
		writeLong f 0x0253F2FD
		writeLong f 4
		writeLong f ver
		writeLong f 0
	)
	-- NVC --
	try (
		if (bNVC == true and chCol == true ) then (
			popPrompt()
			pushPrompt ("Export DFF: " + (objExpName as string) + " - write nvc...")
			NVC = #()
				writeLong f 0x253F2F9 
				writeLong f (msh.numverts *4 + 4) #unsigned
				writeLong f ver
				writebyte f 255 
				writebyte f 255 
				writebyte f 255 
				writebyte f 255 
			if (meshop.getMapSupport msh -1 == true) and (meshop.getNumMapVerts msh -1) == msh.numverts then (
				for i = 1 to msh.numverts  do (
					NVC = (meshop.getMapVert msh -1 i  * 255)
					if vAlphStat == true then vA = ((meshop.getMapVert msh -2 i) * 255.0)
					else vA = [255,255,255]
					writebyte f NVC.x #unsigned
					writebyte f NVC.y #unsigned
					writebyte f NVC.z #unsigned
					writebyte f (vA.x as integer) #unsigned
				)
			) else (
				for i = 1 to msh.numverts  do (
					if vAlphStat == true then vA = ((meshop.getMapVert msh -2 i) * 255.0)
					else vA = [255,255,255]
					writebyte f nvcDefolt #unsigned
					writebyte f nvcDefolt #unsigned
					writebyte f nvcDefolt #unsigned
					writebyte f (vA.x as integer) #unsigned
				)								
			)
		)
	) catch (format "     [Error] write NVC\n")

	pbUpdate()
	interfaceUpdate()
	-- 2Dfx --
	try (
		if lightArr.count >= 1 then (
			popPrompt()
			pushPrompt ("Export DFF: " + (objExpName as string) + " - write 2dfx...")
			writeLong f 0x0253F2F8 
			writeLong f (100 * lightArr.count + 4)
			writeLong f ver
			writelong f lightArr.count -- light count
			if DFF2dfx_light != undefined and DFF2dfx_light.DFF2dfxLog.checked == true then format "\n - 2DFX Export log ----\n"
			tmpCnt = 0
			for objLidht in lightArr do (
				tmpCnt += 1
				posx = in coordsys parent objLidht.pos.x
				posy = in coordsys parent objLidht.pos.y
				posz = in coordsys parent objLidht.pos.z
					
				v2d_L_Dist = getuserprop objLidht "2d_L_Dist" 
				if v2d_L_Dist == undefined then v2d_L_Dist = DFF2dfx.LDrawDistance.value
				v2d_L_OutRange = getuserprop objLidht "2d_L_OutRange" 
				if v2d_L_OutRange == undefined then v2d_L_OutRange = DFF2dfx.LLightRange.value
				v2d_L_Size = getuserprop objLidht "2d_L_Size" 
				if v2d_L_Size == undefined then v2d_L_Size = DFF2dfx.LCoronaSize.value
				v2d_L_ShSize = getuserprop objLidht "2d_L_ShSize"  	
				if v2d_L_ShSize == undefined then v2d_L_ShSize = DFF2dfx.LShadowSize.value
				v2d_L_ShowMode = getuserprop objLidht "2d_L_ShowMode" 
				if v2d_L_ShowMode == undefined then v2d_L_ShowMode = getNum(DFF2dfx.LShowModeText.text)
				v2d_L_Refl = getuserprop objLidht "2d_L_Refl"
				if v2d_L_Refl == undefined then (
					if DFF2dfx.LCoronaRefl.checked == true then tmp = 1 else tmp = 0
					v2d_L_Refl = tmp
				)
				v2d_L_coronaFlareType = getuserprop objLidht "2d_L_coronaFlareType"
				if v2d_L_coronaFlareType == undefined then (
					if DFF2dfx.LFlareType.selection == 1 then tmp = 0 
						else if DFF2dfx.LFlareType.selection == 2 then tmp = 1 
							else if DFF2dfx.LFlareType.selection == 3 then tmp = 2
					v2d_L_coronaFlareType = tmp
				)					
				v2d_L_shadowColorMultiplier = getuserprop objLidht "2d_L_shadowColorMultiplier"
				if v2d_L_shadowColorMultiplier == undefined then v2d_L_shadowColorMultiplier = DFF2dfx.LShadowMP.value
				v2d_L_Flags1 = getuserprop objLidht "2d_L_Flags1"
				if v2d_L_Flags1 == undefined then v2d_L_Flags1 = DFF2dfx.LSflags1.value
				v2d_L_CoroneName = getuserprop objLidht "2d_L_CoroneName" 	
				if v2d_L_CoroneName == undefined then v2d_L_CoroneName = DFF2dfx.LCoronaName.text
				v2d_L_shadowName = getuserprop objLidht "2d_L_shadowName" 	
				if v2d_L_shadowName == undefined then v2d_L_shadowName = DFF2dfx.LShadowName.text
					
				v2d_L_shadowZDistance = getuserprop objLidht "2d_L_shadowZDistance" 
				if v2d_L_shadowZDistance == undefined then v2d_L_shadowZDistance = DFF2dfx.LShadowDistance.value
				v2d_L_Flags2 = getuserprop objLidht "2d_L_Flags2" 
				if v2d_L_Flags2 == undefined then v2d_L_Flags2 = DFF2dfx.LSflags2.value
				v2d_L_DirectionX = getuserprop objLidht "2d_L_DirectionX" 
				if v2d_L_DirectionX == undefined then v2d_L_DirectionX = DFF2dfx.LVX.value
				v2d_L_DirectionY = getuserprop objLidht "2d_L_DirectionY" 
				if v2d_L_DirectionY == undefined then v2d_L_DirectionY = DFF2dfx.LVY.value
				v2d_L_DirectionZ = getuserprop objLidht "2d_L_DirectionZ"  
				if v2d_L_DirectionZ == undefined then v2d_L_DirectionZ = DFF2dfx.LVZ.value
					
				if DFF2dfx_light != undefined and DFF2dfx_light.DFF2dfxLog.checked == true then (
					format "     2d_L_Dist = %\n     2d_L_OutRange = %\n     2d_L_Size = %\n     2d_L_ShSize = %\n     2d_L_ShowMode = %\n     2d_L_Refl = %\n" v2d_L_Dist v2d_L_OutRange v2d_L_Size v2d_L_ShSize v2d_L_ShowMode v2d_L_Refl 
					format "     2d_L_coronaFlareType = %\n     2d_L_shadowColorMultiplier = %\n     2d_L_Flags1 = %\n     2d_L_CoroneName = %\n     2d_L_shadowName = %\n" v2d_L_coronaFlareType v2d_L_shadowColorMultiplier v2d_L_Flags1 v2d_L_CoroneName v2d_L_shadowName
					format "     2d_L_shadowZDistance = %\n     2d_L_Flags2 = %\n     Direction:\n     X = %\n     Y = %\n     Z = %\n\n" v2d_L_shadowZDistance v2d_L_Flags2 v2d_L_DirectionX v2d_L_DirectionY v2d_L_DirectionZ
				)
				
				writefloat f posx
				writefloat f posy
				writefloat f posz
				writelong f 0 -- type: light
				writelong f 80 -- size
				
				--write light data	- 80 bytes
				writebyte f (objLidht.color.r as integer) #unsigned -- 0x00 | RwRGBA color
				writebyte f (objLidht.color.g as integer) #unsigned
				writebyte f (objLidht.color.b as integer) #unsigned
				writebyte f 255 #unsigned
				writefloat f (v2d_L_Dist as float)								-- 0x04 | float  coronaFarClip (draw distance)
				writefloat f (v2d_L_OutRange as float)						--0x08  | float  pointlightRange (range of lighting models)
				writefloat f (v2d_L_Size as float) 								-- 0x0C | float  coronaSize 
				writefloat f (v2d_L_ShSize as float) 							-- 0x10 | float  shadowSize 		
				writebyte f (v2d_L_ShowMode as integer) #unsigned					-- 0x14 | BYTE   coronaShowMode (0 DEFAULT)
				writebyte f (v2d_L_Refl as integer) #unsigned							-- 0x15 | BYTE   coronaEnableReflection
				writebyte f (v2d_L_coronaFlareType as integer) #unsigned			-- 0x16 | BYTE   coronaFlareType
				writebyte f (v2d_L_shadowColorMultiplier as integer) #unsigned	-- 0x17 | BYTE   shadowColorMultiplier		
				writebyte f (v2d_L_Flags1 as integer) #unsigned						-- 0x18 | BYTE   flags1 (32 AT_DAY,64 AT_NIGHT) 
				writestring f v2d_L_CoroneName 								-- 0x19 | char   coronaTexName[24]
				for i=1 to 23 - v2d_L_CoroneName.count do writebyte f 0 -- aligment (coronaTexName)
				writestring f v2d_L_shadowName 								-- 0x31 | char   shadowTexName[24] 
				for i=1 to 23 - v2d_L_shadowName.count do writebyte f 0 -- aligment (shadowTexName)
				writebyte f (v2d_L_shadowZDistance as integer)#unsigned 			-- 0x49 | BYTE   shadowZDistance
				writebyte f (v2d_L_Flags2 as integer) #unsigned						-- 0x4A | BYTE   flags2  
				writebyte f (v2d_L_DirectionX as integer) #unsigned					-- 0x4B | BYTE   lookDirection_x
				writebyte f (v2d_L_DirectionY as integer) #unsigned					-- 0x4C | BYTE   lookDirection_y
				writebyte f (v2d_L_DirectionZ as integer)#unsigned 					-- 0x4D | BYTE   lookDirection_z 
				writebyte f 0 											-- BYTE   padding
				writebyte f 0 											-- BYTE   padding[2]
			)
		)
	) catch (format "     [Error] write 2Dfx\n")
	
	local here = ftell f
	GExt_length = here - 8 - GExt_length_add
	fseek f GExt_length_add #seek_set
	writeLong f GExt_length
    
	fseek f here #seek_set
    local here = ftell f
	G_length = here - 8 - G_length_add
    
	fseek f G_length_add #seek_set
	writeLong f G_length
	fseek f here #seek_set
	format "     data writed\n"
)
--end fn wGeometry				--<e9>--
--
--M---------------------
--Main Export Function--
------------------------
----- hierarchy ReSort ----------------
global newHierarchyArr = #()

fn buildHierarchy obj = (
	append newHierarchyArr obj
	objCh = obj.children
	for i = 1 to objCh.count do (
		if objCh[i].children[1] != undefined then buildHierarchy objCh[i]
		else (
			if objCh[i].isHidden == false and objCh[i].isFrozen == false then  append newHierarchyArr objCh[i]
		)
	)
)

fn hierarchyReSort objArr = (
	nodeObj = objArr[1]
	local nodeObjFirst
	while (nodeObj != undefined) do (
		nodeObjFirst = nodeObj
		nodeObj = nodeObj.parent
	)
	buildHierarchy nodeObjFirst
)
-------------------------------

fn fixUV obj = (
	--max modify mode -- open mod panel
	if (meshop.getMapSupport obj 1) == true then (
		format "          uv cbannel 1\n"
		addModifier obj (Unwrap_UVW ())
		g = obj.Unwrap_UVW.NumberVertices()
		bArr = #()
		for i = 1 to g do append bArr i
		obj.Unwrap_UVW.selectVertices (bArr as bitarray)
		obj.Unwrap_UVW.weldSelected()
		collapseStack obj
	)
	if (meshop.getMapSupport obj 2) == true then (
		format "          uv cbannel 2\n"
		addModifier obj (Unwrap_UVW ())
		obj.modifiers[#unwrap_uvw].unwrap.setMapChannel 2
		g = obj.Unwrap_UVW.NumberVertices()
		bArr = #()
		for i = 1 to g do append bArr i
		obj.Unwrap_UVW.selectVertices (bArr as bitarray)
		obj.Unwrap_UVW.weldSelected()
		collapseStack obj
	)
)

fn DFFout f Allobjects MMC TUV CPV NOR ExSc ver SAColBase noCol addlock = (
	Noproblem = true
	tmpObj = #()
	pbUpdate()

		SkinData = undefined
		bonechain = undefined
		Clump_Start = ftell f
		local ObjAry=#(),lightIDs=#(),geo_count=0, light_count=0, help_count=0
		lightArr = #()
		pbUpdate()
		interfaceUpdate()
		for i  in  Allobjects do (
			if (superclassof i == GeometryClass) then (
				geo_count+=1
				append ObjAry i
			)
			if (superclassof i == light) then (
				light_count+=1
				append lightArr i
			)
			if (superclassof i == helper) then (
				help_count+=1
			)
		)
		try (
			wClumpObj f geo_count light_count ver
		) catch format " [Error] write Clump\n"
		try (
			wFrameList f Allobjects ExSc ver
		) catch format " [Error] write FrameList\n"		
		pbUpdate()
		interfaceUpdate()
		GL_length_add = wGeometryList f Allobjects ver
		AtmRefAry = #()		
		for i = 1 to ObjAry.count do (
			tmpMsh = copy ObjAry[i]
			if gMeshFix == true then (
				format "     [debug] Mesh Fix == true\n"
				convertTo tmpMsh Editable_Patch 
				converttomesh tmpMsh
				fixUV tmpMsh
			)
			if (classof tmpMsh) != Editable_mesh then converttomesh tmpMsh
			meshop.deleteIsoVerts tmpMsh
			if (meshop.getMapSupport tmpMsh -2) == true then (
				if (meshop.getNumMapVerts tmpMsh -2) == 0 then (
					meshop.setMapSupport tmpMsh -2 false
					meshop.setMapSupport tmpMsh -2 true
				)
				try (meshop.buildMapFaces tmpMsh -2)
				catch (
					format "[debug] error in buildMapFaces -2\n"
					meshop.setMapSupport tmpMsh -2 false
					meshop.setMapSupport tmpMsh -2 true
					meshop.buildMapFaces tmpMsh -2
				)
			)
			if (meshop.getMapSupport tmpMsh -1) == true then (
				if (meshop.getNumMapVerts tmpMsh -1) == 0 then (
					meshop.setMapSupport tmpMsh -1 false
					meshop.setMapSupport tmpMsh -1 true
				)
				try (meshop.buildMapFaces tmpMsh -1)
				catch (
					format "[debug] error in buildMapFaces -1\n"
					meshop.setMapSupport tmpMsh -1 false
					meshop.setMapSupport tmpMsh -1 true
					meshop.buildMapFaces tmpMsh -1
				)
			)
			if (meshop.getMapSupport tmpMsh 0) == true then (
				if (meshop.getNumMapVerts tmpMsh 0) == 0 then (
					meshop.setMapSupport tmpMsh 0 false
					meshop.setMapSupport tmpMsh 0 true
				)
				try (meshop.buildMapFaces tmpMsh 0)
				catch (
					format "[debug] error in buildMapFaces 0\n"
					meshop.setMapSupport tmpMsh 0 false
					meshop.setMapSupport tmpMsh 0 true
					meshop.buildMapFaces tmpMsh 0
				)
			)
			if (meshop.getMapSupport tmpMsh 1) == true then (
				if (meshop.getNumMapVerts tmpMsh 1) == 0 then (
					meshop.setMapSupport tmpMsh 1 false
					meshop.setMapSupport tmpMsh 1 true
				)
				try (meshop.buildMapFaces tmpMsh 1)
				catch (
					format "[debug] error in buildMapFaces 1\n"
					meshop.setMapSupport tmpMsh 1 false
					meshop.setMapSupport tmpMsh 1 true
					meshop.buildMapFaces tmpMsh 1
				)
			)
			if (meshop.getMapSupport tmpMsh 2) == true then (
				if (meshop.getNumMapVerts tmpMsh 2) == 0 then (
					meshop.setMapSupport tmpMsh 2 false
					meshop.setMapSupport tmpMsh 2 true
				)
				try (meshop.buildMapFaces tmpMsh 2)
				catch (
					format "[debug] error in buildMapFaces 2\n"
					meshop.setMapSupport tmpMsh 2 false
					meshop.setMapSupport tmpMsh 2 true
					meshop.buildMapFaces tmpMsh 2
				)
			)
			----------------------------------------------
			if NOR == true then try (
				popPrompt()
				pushPrompt ("Export DFF: " + (tmpMsh.name as string) + " - preparing Smoothing Groups...")
				detachBySmGr tmpMsh
			) catch (
				format " [Error]: fn detachBySmGr\n"
				tmpMsh = copy ObjAry[i]
				if (classof tmpMsh) != Editable_mesh then converttomesh tmpMsh
			)
			pbUpdate()
			----------------------------------------------
			objExpName = ObjAry[i].name
			tmsh = RemapGeo tmpMsh undefined
			pbUpdate()
			----------------------------------------------
			if NOR == true then transferNormals tmpMsh tmsh[1] 
			---------------------------------------------
			pbUpdate()
			delete tmpMsh			
			if tmsh != undefined then (
				tmsh[1] = CondenseMtlByID tmsh[1]
				--objExpName = ObjAry[i].name
				format "\n   [%] %\n" i ObjAry[i].name 	
				wGeometry f tmsh undefined MMC TUV CPV NOR ExSc undefined false ver
								
				 hasRef = getUserProp tmsh[1] "Ref"
				if hasRef == true then append AtmRefAry true
				else if (hasRef != undefined and (hasRef as integer) == 3) then append AtmRefAry 3 else append AtmRefAry false
				
				delete tmsh[1]
			) else (
				Noproblem = false
				format "Can't export: %\n>>>This dff WON'T work<<<\n" ObjAry[i]
			)--end if tmsh
		)--end for i

		local here = ftell f
		GL_length = here - 8 - GL_length_add
		fseek f GL_length_add #seek_set
		writeLong f GL_length
		fseek f here #seek_set
		
		noGeo = 0
		ctr = 1
		popPrompt()
		pushPrompt ("Export DFF:  write atomic...")
		for i = 1 to Allobjects.count do (
			if superclassof Allobjects[i] == GeometryClass then (
				wAtomic f i (i - noGeo) ver noCol AtmRefAry[ctr]
				ctr += 1
			) else noGeo += 1
		)
		pbUpdate()
		interfaceUpdate()
		for i = 1 to Allobjects.count do (
			if superclassof Allobjects[i] == light then (
				--rwLight--
				writeLong f 0x01
				writeLong f 4
				writeLong f ver
				writeLong f (i-1)
				writeLong f 0x12
				writeLong f 48
				writeLong f ver
				writeLong f 0x01
				writeLong f 24
				writeLong f ver
				writeFloat f (Allobjects[i].farAttenEnd)
				writeFloat f (Allobjects[i].color.r / 255)
				writeFloat f (Allobjects[i].color.g / 255)
				writeFloat f (Allobjects[i].color.b / 255)
				writeFloat f 0
				writeShort f 3
				if classof Allobjects[i] == Omnilight then writeShort f 0x80
                else writeShort f 0x81

				writeLong f 0x03
				writeLong f 0
				writeLong f ver
			)
		)
		pbUpdate()
		WriteLong f 3
		EndExtAdd = ftell f
		WriteLong f 0
		WriteLong f ver	-- file version for GTA3

		if (ver == 0X1803FFFF)AND(noCol == 0) then (
            if findstring SAColBase ".dff" != undefined then    ret = writeCOL3 SAColBase f ver 
            else ret = writeCOLL SAColBase f ver 

			endhere = ftell f
			if ret == true then (
				EndExtLeng = endhere - EndExtAdd - 8
				fseek f EndExtAdd #seek_set
				writelong f EndExtLeng
				fseek f endhere #seek_set
			) else (
				ermsg = "Error in reading " + SAColBase + " Collision Data!!\nThis file will not work ingame!!"
				messagebox ermsg
			)
		) --else endhere = ftell f

		endhere = ftell f

	--Add zmod lock here--
	if addlock == true then (
		h1 = random 0 255
		h2 = random 0 252
		e1 = h1 - 31 						--original should - 32
		e2 = h2 + 1 						--original should + 3
		WriteLong f 0xF21E
		WriteLong f 8
		WriteLong f ver
		WriteByte f h1
		WriteByte f h2
		WriteShort f 0x1C15
		WriteShort f 0x9493		--original should be 0x61031C15
		WriteByte f e1
		WriteByte f e2
	)
        
	clump_length = endhere - 12 - Clump_Start
	fseek f (Clump_Start+4) #seek_set
	writeLong f clump_length		
	popPrompt()
	popPrompt()
	pbUpdate()
	return Noproblem

)
--end fn DFFout				--<M1>--
--
fn wCharDFFout f obj BonesAry MMC TUV CPV NOR ExSc  ver bodypart addlock = (

	Noproblem = true
	Clump_Start = ftell f
	wClump f 1 ver
	wSkinFrameList f BonesAry ExSc ver
	GL_length_add = wGeometryList f obj ver
    
	SkinPlugData = CreateSkinData obj
	tmsh = RemapGeo obj	SkinPlugData   
 
    if tmsh != undefined then tmsh[1] = CondenseMtlByID tmsh[1]
    --format "tmsh[3]:%\n" tmsh[3][1].count
	--tmsh[1].transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])
    SkinPlugData = tmsh[3]
    --format"2: SkinData:%\n" SkinPlugData[1].count
	wGeometry f tmsh BonesAry MMC TUV CPV NOR ExSc SkinPlugData bodypart ver
	delete tmsh[1]
	local here = ftell f
	GL_length = here - 8 - GL_length_add
	fseek f GL_length_add #seek_set
	writeLong f GL_length
	fseek f here #seek_set
    
	--Write Atomic--
	WriteLong f 0x14
	if ver == 0x1803FFFF then WriteLong f 60
    else WriteLong f 76
	WriteLong f ver	
	WriteLong f 1
	WriteLong f 16
	WriteLong f ver
	if (ver == 0x1803FFFF)AND(bodypart==true) then WriteLong f 1
	else WriteLong f 0
	WriteLong f 0
	WriteLong f 5
	WriteLong f 0
	WriteLong f 3
	if ver == 0x1803FFFF then WriteLong f 20
    else WriteLong f 36
	WriteLong f ver	
	WriteLong f 0x1F
	WriteLong f 8
	WriteLong f ver
	WriteLong f 0x116
	WriteLong f 1  
    if ver != 0x1803FFFF then (
		WriteLong f 0x120
		WriteLong f 4
		WriteLong f ver
		WriteLong f 0    
	)

	--end Extension--
	WriteLong f 3
	WriteLong f 0
	WriteLong f ver	-- file version for GTA3
	endhere = ftell f
    

	--Add zmod lock here--
	if addlock == true then (
		h1 = random 0 255
		h2 = random 0 252
		e1 = h1 - 31 						--original should - 32
		e2 = h2 + 1 						--original should + 3
		WriteLong f 0xF21E
		WriteLong f 8
		WriteLong f ver
		WriteByte f h1
		WriteByte f h2
		WriteShort f 0x1C15
		WriteShort f 0x9493		--original should be 0x61031C15
		WriteByte f e1
		WriteByte f e2
	)

	clump_length = endhere - 12 - Clump_Start
	fseek f (Clump_Start+4) #seek_set
	writeLong f clump_length
	
	return Noproblem
	
)
--end fn wCharDFFout			--<M2>--

fn DFFoutInfo = (    
    return (777)
)