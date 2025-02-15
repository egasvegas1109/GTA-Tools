--28Sep05--
fn findCOL3 cf ver = (
	fseek cf 0 #seek_end
	dffend = ftell cf
 --format "end:%\n" dffend

	fseek cf 8 #seek_set
	if (readLong cf) != ver then return false
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
		if ( readLong cf == 0x334C4F43 ) then fseek cf -4 #seek_cur
		else (
			while (readLong cf != 0x334C4F43) do ( 
 --format "%\n" (ftell cf)
				if (ftell cf) >= dffend then return false
			)
			fseek cf -4 #seek_cur
        ) 
	) catch ( return false )
    
    return true
)--end fn findCOL3
--
fn ReadCOL3 f  Mname Iscale Nobound PartsAry = (
 clearlistener()
	headerID = readLong f
	if headerID == 0x4C4C4F43 then (messagebox "This is GTA3/VC COLL format!!!\nUse GTA COL IO script to import this." title:"Not a SA Collision COL"; return undefined) 
	if (HeaderID != 0x334C4F43) then (format "Error COL3![%]\n" (ftell f); return undefined)
	col3start = ftell f
	col3end = (readLong f) + col3start + 4
	col3name = readString f
	skipbyte = 23 - col3name.count
	fseek f skipbyte #seek_cur
	bboxmin = [(readFloat f),(readFloat f),(readFloat f)] * Iscale
	bboxmax = [(readFloat f),(readFloat f),(readFloat f)] * Iscale
	boxsize = bboxmax - bboxmin
	bspos = [(readFloat f),(readFloat f),(readFloat f)] * Iscale
	bsrad = (readFloat f) * Iscale
	if Nobound != true then (
		tmp = box length:boxsize.y width:boxsize.x height:boxsize.z xray:on wirecolor:(color 216 218 140)
		tmp.center = (bboxmax + bboxmin) / 2
		tmp.name = "Bounding Box"
		tmp = sphere radius:bsrad pos:bspos xray:on wirecolor:(color 216 218 140)
		tmp.name = "Bounding Sphere"
	)
 format "Bounding Sphere:%\tradius:%\n" bspos bsrad
 format "Bounding Box Min:%\n" bboxmin
 format "Bounding Box Max:%\n" bboxmax	
	CScount = readShort f
	CBcount = readShort f
	CMFaces = readLong f
	unknown1 = readLong f
	if unknown1 != 0x12 then format "Unknown1[%] -> %\n" ((ftell f)-4) unknown1 
	CSoffset = readLong f
	CBoffset = readLong f
	unknown2 = readLong f
	if unknown2 != 0 then format "Unknown2[%] -> %\n" ((ftell f)-4) unknown2
	addCMverts = (readLong f) + col3start
	addCMfaces = (readLong f) + col3start
	unknown3 = readLong f
	if unknown3 != 0 then format "Unknown3[%] -> %\n" ((ftell f)-4) unknown3
	SMFaces = readLong f
	addSMverts = (readLong f) + col3start
	addSMfaces = (readLong f) + col3start	
	--------------------
	--Collision Sphere--
	--------------------
	if CSoffset != 0 then (
		if (ftell f) != CSoffset + col3start then format "Error in Collision Sphere address[%]\n" (ftell f)
	)	
 format "Collision Spheres: %\n" CScount
	for i = 1 to CScount do (
		cspos = [(readFloat f),(readFloat f),(readFloat f)] * Iscale
		csrad = (readFloat f) * Iscale	
		tmp = sphere radius:csrad pos:cspos wirecolor:(color 52 132 166)
		tv = readByte f #unsigned
		sv = readByte f #unsigned
		setUserProp tmp "Surface" tv
		setUserProp tmp "Part" sv
		if sv == 0xFF then tmp.name = "Special"
		else tmp.name = PartsAry[(sv+1)] 
		if sv == 255 then sv = -1
		tp = readByte f #unsigned	
		sp = readByte f #unsigned
		setUserProp tmp "u1" tp
		setUserProp tmp "u2" sp
		try (tmp.material = GTA_COLSurface surface:tv part:sv u1:tp u2:sp) catch()
 --format "   %\tb1[%]\tb2[%]\tb3[%]\tb4[%]\n" tmp.name tv sv tp sp
	)--end for i	
	-----------------
	--Collision Box--
	-----------------
	if CBoffset != 0 then (
		if (ftell f) != CBoffset + col3start then format "Error in Collision Box address[%]\n" (ftell f)
	)	
 format "Collision Boxes: %\n" CBcount
	for i = 1 to CBcount do (
		bboxmin = [(readFloat f),(readFloat f),(readFloat f)] * Iscale
		bboxmax = [(readFloat f),(readFloat f),(readFloat f)] * Iscale
		boxsize = bboxmax - bboxmin
		tmp = box length:boxsize.y width:boxsize.x height:boxsize.z wirecolor:(color 52 132 166)
		tmp.center = (bboxmax + bboxmin) / 2
		tv = readByte f #unsigned
		sv = readByte f #unsigned
		setUserProp tmp "Surface" tv
		setUserProp tmp "Part" sv
		if sv == 0xFF then tmp.name = "Special"
		else tmp.name = PartsAry[(sv+1)] 
		if sv == 255 then sv = -1
		tp = readByte f #unsigned	
		sp = readByte f #unsigned
		setUserProp tmp "u1" tp
		setUserProp tmp "u2" sp
		try (tmp.material = GTA_COLSurface surface:tv part:sv u1:tp u2:sp) catch()
 --format "   %\tb1[%]\tb2[%]\tb3[%]\tb4[%]\n" tmp.name tv sv tp sp
	)--end for i	
	------------------
	--Collision Mesh--
	------------------
	if CMFaces != 0 then (

 --format "CSphere end:%\nCMesh verts start:%(end:%)\n" (ftell f) addCMverts addCMfaces

		if (ftell f) > addCMverts then format "Error in Collision Mesh verts -> Should Start:%[%]\n" addCMverts (ftell f)
		else if (ftell f) < addCMverts then (
			format "Some bytes between BS/BB and CM\n"
			while (ftell f) != addCMverts do format "%\n" (readByte f)
		)
		if (ftell f) == addCMverts then (
			VertAry = #()
			while (ftell f) < addCMfaces do (
				px = (readShort f)/128.0  * Iscale 
				py = (readShort f)/128.0  * Iscale
				pz = (readShort f)/128.0  * Iscale
				append VertAry [px,py,pz]
			)
 --Format "CMFace Start:%\n" (ftell f)
			if (ftell f) > addCMfaces then ( 
 format "over verts[%]\n" (ftell f)
				deleteitem VertAry VertAry.count
				fseek f addCMfaces #seek_set
			)
			FaceAry = #()
			MtlAry = #() 
			FIDAry = #()
			maxidx = 0
			for jj = 1 to CMFaces do (
				f2 = (readShort f) + 1
				f1 = (readShort f) + 1
				f3 = (readShort f) + 1
				append FaceAry [f1,f2,f3]
				if maxidx < f1 then maxidx = f1
				if maxidx < f2 then maxidx = f2
				if maxidx < f3 then maxidx = f3
				tv = readByte f #unsigned
				ts = readByte f #unsigned
				if ts == 255 then ts = -1
				--if ts != -1 then format "%:\t%\t%\n" jj tv ts
				sdata = [tv,ts]
				Fid = finditem MtlAry sdata
				if Fid == 0 then (
					append MtlAry sdata
					append FIDAry MtlAry.count
				) else append FIDAry Fid
			)
 Format "Collision Mesh: Verts:%   Faces:%   Max Vert Used:%\n" VertAry.count CMFaces maxidx
			tmp = mesh vertices:VertAry faces:FaceAry materialIDs:FIDAry wirecolor:(color 52 132 166)
			tmp.name = "CM_" + Mname
			if GTA_COLSurface != undefined then (
				if MtlAry.count == 1 then tmp.material = GTA_COLSurface  surface:MtlAry[1].x part:MtlAry[1].y		
				else (
					tmp.material = multimaterial numsubs:MtlAry.count
					for i = 1 to MtlAry.count do tmp.material[i] =  GTA_COLSurface  surface:MtlAry[i].x part:MtlAry[i].y
				)
			)
            
		)--end if/else
	)
	---------------
	--Shadow Mesh--
	---------------
	if SMFaces != 0 then (
	
 --format "CMesh end:%\nSMesh verts start:%(end:%)\n" (ftell f) addSMverts addSMfaces

		if (ftell f) > addSMverts then format "Error in Shadow Mesh verts -> Should Start:%[%]\n" addSMverts (ftell f)
		else if (ftell f) < addSMverts then (
			format "Some bytes between CM and SM\n"
			while (ftell f) != addSMverts do format "%\n" (readByte f)
		)
		if (ftell f) == addSMverts then (
			VertAry = #()
			while (ftell f) < addSMfaces do (
				px = (readShort f)/128.0  * Iscale 
				py = (readShort f)/128.0  * Iscale
				pz = (readShort f)/128.0  * Iscale
				append VertAry [px,py,pz]
			)
 --Format "SMFace Start:%\n" (ftell f)
			if (ftell f) > addSMfaces then ( 
 format "over verts[%]\n" (ftell f)
				deleteitem VertAry VertAry.count
				fseek f addSMfaces #seek_set
			)
			FaceAry = #()
			SdwAry = #()
			FIDAry = #()
			maxidx = 0

			for jj = 1 to SMFaces do (
				f2 = (readShort f) + 1
				f1 = (readShort f) + 1
				f3 = (readShort f) + 1
				append FaceAry [f1,f2,f3]
				if maxidx < f1 then maxidx = f1
				if maxidx < f2 then maxidx = f2
				if maxidx < f3 then maxidx = f3
				tv = readByte f #unsigned
				ts = readByte f #unsigned
				--if ts != 255 then format "%:\t%\t%\n" jj tv ts
				sdata = [tv,ts]
				Fid = finditem SdwAry sdata
				if Fid == 0 then (
					append SdwAry sdata 			
					append FIDAry SdwAry.count
				) else append FIDAry Fid
			)
 Format "Shadow Mesh: Verts:%   Faces:%   Max Vert Used:%\n" VertAry.count SMFaces maxidx
 			tmp = mesh vertices:VertAry faces:FaceAry materialIDs:FIDAry wirecolor:(color 60 60 60)
 			tmp.name = "SM_" + Mname
			if GTA_COLShadow != undefined then (
				if SdwAry.count == 1 then tmp.material = GTA_COLShadow  u1:SdwAry[1].x u2:SdwAry[1].y		
				else (
					tmp.material = multimaterial numsubs:SdwAry.count
					for i = 1 to SdwAry.count do tmp.material[i] =  GTA_COLShadow  u1:SdwAry[i].x u2:SdwAry[i].y
				)
			)
 --format "SMesh end:%\n" (ftell f)
		)--end if/else
	)
	format "end of file[%]\n\n" (ftell f)
)--end fn ReadCOL3
--
fn ReadCOL2 f  Mname Iscale Nobound PartsAry = (
	clearlistener()
	headerID = readLong f
	if headerID == 0x4C4C4F43 then (messagebox "This is GTA3/VC COLL format!!!\nUse GTA COL IO script to import this." title:"Not a SA Collision COL"; return undefined) 
	if (HeaderID != 0x324C4F43) then (format "Error COL2![%]\n" (ftell f); return undefined)
	col2start = ftell f
	col2end = (readLong f) + col2start + 4
	col2name = readString f
	skipbyte = 23 - col2name.count
	fseek f skipbyte #seek_cur
	bboxmin = [(readFloat f),(readFloat f),(readFloat f)] * Iscale
	bboxmax = [(readFloat f),(readFloat f),(readFloat f)] * Iscale
	boxsize = bboxmax - bboxmin
	bspos = [(readFloat f),(readFloat f),(readFloat f)] * Iscale
	bsrad = (readFloat f) * Iscale
	if Nobound != true then (
		tmp = box length:boxsize.y width:boxsize.x height:boxsize.z xray:on wirecolor:(color 216 218 140)
		tmp.center = (bboxmax + bboxmin) / 2
		tmp.name = "Bounding Box"
		tmp = sphere radius:bsrad pos:bspos xray:on wirecolor:(color 216 218 140)
		tmp.name = "Bounding Sphere"
	)
	format "Bounding Sphere:%\tradius:%\n" bspos bsrad
	format "Bounding Box Min:%\n" bboxmin
	format "Bounding Box Max:%\n" bboxmax	
	CScount = readShort f
	CBcount = readShort f
	CMFaces = readLong f
	unknown1 = readLong f
	if unknown1 != 2 then format "Unknown1[%] -> %\n" ((ftell f)-4) unknown1 
	CSoffset = readLong f
	CBoffset = readLong f
	unknown2 = readLong f
	if unknown2 != 0 then format "Unknown2[%] -> %\n" ((ftell f)-4) unknown2
	addCMverts = (readLong f) + col2start
	addCMfaces = (readLong f) + col2start
 	unknown3 = readLong f
	if unknown3 != 0 then format "Unknown3[%] -> %\n" ((ftell f)-4) unknown3   
	--------------------
	--Collision Sphere--
	--------------------
	if CSoffset != 0 then (
		if (ftell f) != CSoffset + col2start then format "Error in Collision Sphere address[%]\n" (ftell f)
	)	
	format "Collision Spheres: %\n" CScount
	for i = 1 to CScount do (
		cspos = [(readFloat f),(readFloat f),(readFloat f)] * Iscale
		csrad = (readFloat f) * Iscale	
		tmp = sphere radius:csrad pos:cspos wirecolor:(color 52 132 166)
		tv = readByte f #unsigned
		sv = readByte f #unsigned
		setUserProp tmp "Surface" tv
		setUserProp tmp "Part" sv
		if sv == 0xFF then tmp.name = "Special"
		else tmp.name = PartsAry[(sv+1)] 
		if sv == 255 then sv = -1
		tp = readByte f #unsigned	
		sp = readByte f #unsigned
		setUserProp tmp "u1" tp
		setUserProp tmp "u2" sp
		try (tmp.material = GTA_COLSurface surface:tv part:sv u1:tp u2:sp) catch()
		--format "   %\tb1[%]\tb2[%]\tb3[%]\tb4[%]\n" tmp.name tv sv tp sp
	)--end for i	
	-----------------
	--Collision Box--
	-----------------
	if CBoffset != 0 then (
		if (ftell f) != CBoffset + col2start then format "Error in Collision Box address[%]\n" (ftell f)
	)	
	format "Collision Boxes: %\n" CBcount
	for i = 1 to CBcount do (
		bboxmin = [(readFloat f),(readFloat f),(readFloat f)] * Iscale
		bboxmax = [(readFloat f),(readFloat f),(readFloat f)] * Iscale
		boxsize = bboxmax - bboxmin
		tmp = box length:boxsize.y width:boxsize.x height:boxsize.z wirecolor:(color 52 132 166)
		tmp.center = (bboxmax + bboxmin) / 2
		tv = readByte f #unsigned
		sv = readByte f #unsigned
		setUserProp tmp "Surface" tv
		setUserProp tmp "Part" sv
		if sv == 0xFF then tmp.name = "Special"
		else tmp.name = PartsAry[(sv+1)] 
		if sv == 255 then sv = -1
		tp = readByte f #unsigned	
		sp = readByte f #unsigned
		setUserProp tmp "u1" tp
		setUserProp tmp "u2" sp
		try (tmp.material = GTA_COLSurface surface:tv part:sv u1:tp u2:sp) catch()
		--format "   %\tb1[%]\tb2[%]\tb3[%]\tb4[%]\n" tmp.name tv sv tp sp
	)--end for i	
	------------------
	--Collision Mesh--
	------------------
	if CMFaces != 0 then (

		--format "CSphere end:%\nCMesh verts start:%(end:%)\n" (ftell f) addCMverts addCMfaces

		if (ftell f) > addCMverts then format "Error in Collision Mesh verts -> Should Start:%[%]\n" addCMverts (ftell f)
		else if (ftell f) < addCMverts then (
			format "Some bytes between BS/BB and CM\n"
			while (ftell f) != addCMverts do format "%\n" (readByte f)
		)
		if (ftell f) == addCMverts then (
			VertAry = #()
			while (ftell f) < addCMfaces do (
				px = (readShort f)/128.0  * Iscale 
				py = (readShort f)/128.0  * Iscale
				pz = (readShort f)/128.0  * Iscale
				append VertAry [px,py,pz]
			)
			--Format "CMFace Start:%\n" (ftell f)
			if (ftell f) > addCMfaces then ( 
				format "over verts[%]\n" (ftell f)
				deleteitem VertAry VertAry.count
				fseek f addCMfaces #seek_set
			)
			FaceAry = #()
			MtlAry = #() 
			FIDAry = #()
			maxidx = 0
			for jj = 1 to CMFaces do (
				f2 = (readShort f) + 1
				f1 = (readShort f) + 1
				f3 = (readShort f) + 1
				append FaceAry [f1,f2,f3]
				if maxidx < f1 then maxidx = f1
				if maxidx < f2 then maxidx = f2
				if maxidx < f3 then maxidx = f3
				tv = readByte f #unsigned
				ts = readByte f #unsigned
				if ts == 255 then ts = -1
				--if ts != -1 then format "%:\t%\t%\n" jj tv ts
				sdata = [tv,ts]
				Fid = finditem MtlAry sdata
				if Fid == 0 then (
					append MtlAry sdata
					append FIDAry MtlAry.count
				) else append FIDAry Fid
			)
			Format "Collision Mesh: Verts:%   Faces:%   Max Vert Used:%\n" VertAry.count CMFaces maxidx
			tmp = mesh vertices:VertAry faces:FaceAry materialIDs:FIDAry wirecolor:(color 52 132 166)
			tmp.name = "CM_" + Mname
			if GTA_COLSurface != undefined then (
				if MtlAry.count == 1 then tmp.material = GTA_COLSurface  surface:MtlAry[1].x part:MtlAry[1].y		
				else (
					tmp.material = multimaterial numsubs:MtlAry.count
					for i = 1 to MtlAry.count do tmp.material[i] =  GTA_COLSurface  surface:MtlAry[i].x part:MtlAry[i].y
				)
			)
            
		)--end if/else
	)

	format "end of file[%]\n\n" (ftell f)
)--end fn ReadCOL2
--
fn ReadCOLL f Mname Iscale Nobound PartsAry = (
 clearlistener()
	if (readLong f) != 0x4C4C4F43 then ( format "\nError in ReadCol!!!\n" ; return undefined )
	fseek f 28 #seek_cur
	bradius = (readFloat f) * Iscale
	brpos = [(readFloat f),(readFloat f),(readFloat f)] * Iscale
	bboxmin = [(readFloat f),(readFloat f),(readFloat f)] * Iscale
	bboxmax = [(readFloat f),(readFloat f),(readFloat f)] * Iscale
	boxsize = bboxmax - bboxmin
	if Nobound != true then (
		tmp = sphere radius:bradius pos:brpos xray:on wirecolor:(color 216 218 140)
		tmp.name = "Bounding Sphere"
		tmp = box length:boxsize.y width:boxsize.x height:boxsize.z xray:on wirecolor:(color 216 218 140)
		tmp.center = (bboxmax + bboxmin) / 2
		tmp.name = "Bounding Box"
	)    
 format "Bounding Sphere:%\tradius:%\n" brpos bradius
 format "Bounding Box Min:%\n" bboxmin
 format "Bounding Box Max:%\n" bboxmax
	--------------------
	--Collision Sphere--
	--------------------
	sp_count = readLong f
 format "Collision Spheres: %\n" sp_count 
 --format "here:%\n" (ftell f)
	for i = 1 to sp_count do (
		spr = (readFloat f) * Iscale
		sppos = [(readFloat f),(readFloat f),(readFloat f)] * Iscale
		tmp = sphere radius:spr pos:sppos wirecolor:(color 52 132 166)
		sv = readByte f #unsigned
		sp = readByte f #unsigned
		setUserProp tmp "Surface" sv
		setUserProp tmp "Part" sp
		if sp == 0xFF then tmp.name = "Special"
		else tmp.name = PartsAry[(sp+1)] 
		if sp == 255 then sv = -1
		z1 = readByte f
		z2 = readByte f
		try (tmp.material = GTA_COLSurface surface:sv part:sp u1:z1 u2:z2) catch()
	)
	readLong f
	-----------------
	--Collision Box--
	-----------------
	bx_count = readLong f
 format "Collision boxes: %\n" bx_count 
 --format "here:%\n" (ftell f)
	for i = 1 to bx_count do (
		boxmin = [(readFloat f),(readFloat f),(readFloat f)] * Iscale
		boxmax = [(readFloat f),(readFloat f),(readFloat f)] * Iscale
		boxsize = boxmax - boxmin
		tmp = box length:boxsize.y width:boxsize.x height:boxsize.z wirecolor:(color 52 132 166)
		tmp.center = (boxmax + boxmin) / 2
		sv = readByte f #unsigned
		sp = readByte f #unsigned
		setUserProp tmp "Surface" sv
		setUserProp tmp "Part" sp
		if sp == 0xFF then tmp.name = "Special"
		else tmp.name = PartsAry[(sp+1)] 
		if sp == 255 then sv = -1
		z1 = readByte f
		z2 = readByte f
		try (tmp.material = GTA_COLSurface surface:sv part:sp u1:z1 u2:z2) catch()
	)
	------------------
	--Collision Mesh--
	------------------
	verts_count = readLong f
 format "Collision Mesh: Verts:%\t" verts_count
	VertAry = #()
	for i = 1 to verts_count do (
		append VertAry ( [(readFloat f),(readFloat f),(readFloat f)] * Iscale )
	)
	FaceAry = #()
	MtlAry = #() 
	FIDAry = #()
	faces_count = readLong f 
 format "Faces:%\n\n" faces_count
	for i = 1 to faces_count do (
		f2 = (readLong f) + 1.0
		f1 = (readLong f) + 1.0
		f3 = (readLong f) + 1.0
		append FaceAry [f1,f2,f3]
		sv = readByte f #unsigned
		sp = readByte f #unsigned
		if sp == 255 then sp = -1
		zz = readShort f
		sdata = [sv,sp,zz]
		Fid = finditem MtlAry sdata
		if Fid == 0 then (
			append MtlAry sdata
			append FIDAry MtlAry.count
		) else append FIDAry Fid
	)
	if faces_count != 0 then (
		tmp = mesh vertices:VertAry faces:FaceAry materialIDs:FIDAry wirecolor:(color 52 132 166)
		tmp.name = "CM_" + Mname
		if GTA_COLSurface != undefined then (
			if MtlAry.count == 1 then tmp.material = GTA_COLSurface  surface:MtlAry[1].x part:MtlAry[1].y u1:(mod MtlAry[1].z 256) u2:(MtlAry[1].z/256)
			else (
				tmp.material = multimaterial numsubs:MtlAry.count
				for i = 1 to MtlAry.count do tmp.material[i] =  GTA_COLSurface  surface:MtlAry[i].x part:MtlAry[i].y u1:(mod MtlAry[i].z 256) u2:(MtlAry[i].z/256)
			)
		)
	)
	--format "%\n%\nHere:%\n" VertAry FaceAry (ftell f)
)--end fn ReadCOLL
--
fn setColArray f = (
	--Get file size--
	fseek f 0 #seek_end
	endofcol = ftell f
	fseek f 0 #seek_set
 --format "eof:%\nHere %\n" endofcol (ftell f)
	ColStartAry = #(0)
	ColNameAry = #()
	
	while (ftell f) < endofcol do (
		collheader = readLong f 
 --format "->%[%]\n" collheader (ftell f)
 		if collheader == 0 then exit
		if (collheader == 0x4C4C4F43)OR(collheader == 0x334C4F43)OR(collheader == 0x324C4F43) then (
			thiscolsize = readLong f #unsigned
			append ColStartAry ( (ftell f) + thiscolsize )
			thiscolname = readstring f
			append ColNameAry thiscolname
			fseek f (thiscolsize - 1 - thiscolname.count) #seek_cur
 --format "%[%]\n" thiscolname (ftell f)
		) else (
			format "Collision Header Error!\n"
			return undefined
		)
	)--end while
	
	deleteitem ColStartAry (ColStartAry.count)
	return #(ColStartAry,ColNameAry)
	
)--end fn setColArray 
--
fn expCOL3 f colname allobjects cmesh smesh Iscale = (
	--Caculate the size first--
	bcount = 112
	bsary = for sp in allobjects where (classof sp == Sphere)AND(sp.name != "Bounding Sphere") collect sp
	bbary = for bx in allobjects where (classof bx == Box)AND(bx.name != "Bounding Box") collect bx
	bcount += bsary.count * 20 
	bcount += bbary.count * 28 	
	if cmesh != undefined then (
		cmsh = snapshot cmesh
		bcount += cmsh.numverts * 6 + cmsh.numfaces * 8
	)
	if smesh != undefined then (
		smsh = snapshot smesh
		bcount += smsh.numverts * 6 + smsh.numfaces * 8
	)
	--Writting Start--
	--==============--
	WriteLong f 0x334C4F43 					--"COL3"
	WriteLong f bcount
	WriteString f colname
	for i = 1 to (23 - colname.count) do WriteByte f 0
	--Write Boundings--
	--===============--
	bs = for obj in allobjects where (obj.name == "Bounding Sphere") collect obj
	bb = for obj in allobjects where (obj.name == "Bounding Box") collect obj
	if (bs.count > 0)AND(bb.count > 0) then (
		bmax = bb[1].max
		bmin = bb[1].min
		bsp = bs[1]
			if bsp.scale != [1,1,1] then (
				sc = bsp.scale.x
				if sc > bsp.scale.y then sc = bsp.scale.y
				if sc > bsp.scale.z then sc = bsp.scale.z
			) else sc = 1
	) else (
		try ( deselect bs; deselect bb ) catch()
		try ( selectmore cmesh ) catch()
		try ( selectmore smesh ) catch()
		bmax = $.max
		bmin = $.min
		boxsize = bmax - bmin
		br = sqrt ( (boxsize.x/2 * boxsize.x/2)+(boxsize.y/2 * boxsize.y/2)+(boxsize.z/2 * boxsize.z/2) )
		bsp = sphere radius:br xray:on wirecolor:(color 216 218 140)
		bsp.center = (bmax + bmin) / 2
		sc = 1
	)	
	WriteFloat f (bmin.x * Iscale)
	WriteFloat f (bmin.y * Iscale)
	WriteFloat f (bmin.z * Iscale)
	WriteFloat f (bmax.x * Iscale)
	WriteFloat f (bmax.y * Iscale)
	WriteFloat f (bmax.z * Iscale)
	WriteFloat f (bsp.pos.x * Iscale) 
	WriteFloat f (bsp.pos.y * Iscale) 
	WriteFloat f (bsp.pos.z * Iscale)
	WriteFloat f (bsp.radius * sc * Iscale) 
	if bs.count == 0 then delete bsp
	--Write information--
	--=================--
	addos = 116
	WriteShort f bsary.count
	WriteShort f bbary.count
	if cmsh == undefined then WriteLong f 0
	else WriteLong f cmsh.numfaces
    
	--unknown1--
	if smsh != undefined then WriteLong f 0x12
	else if cmsh != undefined then WriteLong f 2
	else if (bsary.count > 0)OR(bbary.count > 0) then WriteLong f 2
	else WriteLong f 0

	if bsary.count > 0 then (
		WriteLong f addos
		addos += bsary.count * 20
	) else WriteLong f 0
	if bbary.count > 0 then (
		WriteLong f addos
		addos += bbary.count * 28
	) else WriteLong f 0
	WriteLong f 0										--unknown2
	if cmsh != undefined then (
		WriteLong f addos
		addos += cmsh.numverts * 6
		WriteLong f addos
		addos += cmsh.numFaces * 8
	) else (
		WriteLong f 0
		WriteLong f 0
	)
	WriteLong f 0										--unknown3
	if smsh != undefined then (
		WriteLong f smsh.numfaces
		WriteLong f addos
		addos += smsh.numverts * 6
		WriteLong f addos
		addos += smsh.numFaces * 8
	) else (
		WriteLong f 0
		WriteLong f 0
		WriteLong f 0
	)
	--Write Col Spheres--
	--=================--
	for sp in bsary do (
		if sp.scale != [1,1,1] then (
			sc = sp.scale.x
			if sc > sp.scale.y then sc = sp.scale.y
			if sc > sp.scale.z then sc = sp.scale.z
		) else sc = 1
		WriteFloat f (sp.pos.x * Iscale) 
		WriteFloat f (sp.pos.y * Iscale) 
		WriteFloat f (sp.pos.z * Iscale) 
		WriteFloat f (sp.radius * sc * Iscale)
		if classof sp.material == GTA_COLSurface then (
			ts = sp.material.surface
			tp = sp.material.part
			u1 = sp.material.u1
			u2 = sp.material.u2
		) else (
			ts = getUserProp sp "Surface"
			if ts == undefined then ts = 0
			tp = getUserProp sp "Part"
			if tp == undefined then tp = 0
			u1 = getUserProp sp "u1"
			if u1 == undefined then u1 = 0xBB
			u2 = getUserProp sp "u2"
			if u2 == undefined then u2 = 0
		)
		WriteByte f ts
		WriteByte f tp
		WriteByte f u1								--Always
		WriteByte f u2									--unknown
	)
	--Write Col boxes--
	--===============--
	for bx in bbary do (
		WriteFloat f (bx.min.x * Iscale)
		WriteFloat f (bx.min.y * Iscale)
		WriteFloat f (bx.min.z * Iscale)
		WriteFloat f (bx.max.x * Iscale)
		WriteFloat f (bx.max.y * Iscale)
		WriteFloat f (bx.max.z * Iscale)
		if classof bx.material == GTA_COLSurface then (
			ts = bx.material.surface
			tp = bx.material.part
			u1 = bx.material.u1
			u2 = bx.material.u2
		) else (
			ts = getUserProp bx "Surface"
			if ts == undefined then ts = 0
			tp = getUserProp bx "Part"
			if tp == undefined then tp = 0
			u1 = getUserProp bx "u1"
			if u1 == undefined then u1 = 0xBB
			u2 = getUserProp bx "u2"
			if u2 == undefined then u2 = 0
		)
		WriteByte f ts
		WriteByte f tp
		WriteByte f u1								--Always
		WriteByte f u2									--unknown
	)
	--Write Col Mesh--
	--==============--
	if cmsh != undefined then (
		for i = 1 to cmsh.numverts do (
			pt = cmsh.verts[i].pos
			val = pt.x * 128 * Iscale
			if val - (val as integer) > 0.5 then val += 1
			writeShort f (val as integer)
			val = pt.y * 128 * Iscale
			if val - (val as integer) > 0.5 then val += 1
			writeShort f (val as integer)
			val = pt.z * 128 * Iscale
			if val - (val as integer) > 0.5 then val += 1
			writeShort f (val as integer)
		)
		for i = 1 to cmsh.numfaces do (
			fc = getface cmsh i
			WriteShort f (fc.y - 1)
			WriteShort f (fc.x - 1)
			WriteShort f (fc.z - 1)
			if classof cmsh.material == GTA_COLSurface then (
				WriteByte f cmsh.material.surface
				WriteByte f cmsh.material.part
			) else if classof cmsh.material == Multimaterial then (
				fid = getFaceMatID cmsh i
				if classof cmsh.material[fid] == GTA_COLSurface then (
					WriteByte f cmsh.material[fid].surface
					WriteByte f cmsh.material[fid].part
				) else (
					WriteByte f 0
					WriteByte f 0
				)
			) else (
				WriteByte f 0
				WriteByte f 0
			) 
		)
		delete cmsh
	)
	--Write Shadow Mesh--
	--=================--
	if smsh != undefined then (
		for i = 1 to smsh.numverts do (
			pt = smsh.verts[i].pos
			val = pt.x * 128 * Iscale
			if val - (val as integer) > 0.5 then val += 1
			writeShort f (val as integer)
			val = pt.y * 128 * Iscale
			if val - (val as integer) > 0.5 then val += 1
			writeShort f (val as integer)
			val = pt.z * 128 * Iscale
			if val - (val as integer) > 0.5 then val += 1
			writeShort f (val as integer)
		)
		for i = 1 to smsh.numfaces do (
			fc = getface smsh i
			WriteShort f (fc.y - 1)
			WriteShort f (fc.x - 1)
			WriteShort f (fc.z - 1)
			if classof smsh.material == GTA_COLShadow then (
				WriteByte f smsh.material.u1
				WriteByte f smsh.material.u2
			) else if classof smsh.material == Multimaterial then (
				fid = getFaceMatID smsh i
				if classof smsh.material[fid] == GTA_COLShadow then (
					WriteByte f smsh.material[fid].u1
					WriteByte f smsh.material[fid].u2
				) else (
					WriteByte f 0
					WriteByte f 255
				)
			) else (
				WriteByte f 0
				WriteByte f 255
			) 
		)
		delete smsh
	)
)--end fn expCOL3
--
fn expCOLL f colname allobjects cmesh Iscale = (
		local cmsh = undefined
		--calculate size--
		bcount = 36 + 48				--Name[20] unknown unknown numVerts numFaces
		bsary = for sp in allobjects where (classof sp == Sphere)AND(sp.name != "Bounding Sphere") collect sp
		bbary = for bx in allobjects where (classof bx == Box)AND(bx.name != "Bounding Box") collect bx
		bcount += bsary.count * 20 
		bcount += bbary.count * 28 	
		if cmesh != undefined then (
			cmsh = snapshot cmesh
			bcount += cmsh.numverts * 12
			bcount += cmsh.numFaces * 16
		)

		writeLong f 0x4C4C4F43 
		writeLong f bcount
		WriteString f colname
		for i = 1 to (19 - colname.count) do WriteByte f 0
		writeLong f 0x0030FFFF				-- unknown
		--Write Boundings--
		--===============--
		bs = for obj in allobjects where (obj.name == "Bounding Sphere") collect obj
		bb = for obj in allobjects where (obj.name == "Bounding Box") collect obj
		if (bs.count > 0)AND(bb.count > 0) then (
			bmax = bb[1].max
			bmin = bb[1].min
			bsp = bs[1]
				if bsp.scale != [1,1,1] then (
					sc = bsp.scale.x
					if sc > bsp.scale.y then sc = bsp.scale.y
					if sc > bsp.scale.z then sc = bsp.scale.z
				) else sc = 1
		) else (
			try ( deselect bs; deselect bb ) catch()
			try ( selectmore cmesh ) catch () 
			bmax = $.max
			bmin = $.min
			boxsize = bmax - bmin
			br = sqrt ( (boxsize.x/2 * boxsize.x/2)+(boxsize.y/2 * boxsize.y/2)+(boxsize.z/2 * boxsize.z/2) )
			bsp = sphere radius:br xray:on wirecolor:(color 216 218 140)
			bsp.center = (bmax + bmin) / 2
			sc = 1
		)	
		--BoundingSphere R X Y Z
		writeFloat f (bsp.radius * sc * Iscale) 
		writeFloat f (bsp.pos.x * Iscale) 
		writeFloat f (bsp.pos.y * Iscale) 
		writeFloat f (bsp.pos.z * Iscale)
		--BoundingBox min max
		writeFloat f (bmin.x * Iscale)
		writeFloat f (bmin.y * Iscale)
		writeFloat f (bmin.z * Iscale)
		writeFloat f (bmax.x * Iscale)
		writeFloat f (bmax.y * Iscale)
		writeFloat f (bmax.z * Iscale)
		if bs.count == 0 then delete bsp
		--Write Col Spheres--
		--=================--	
			writeLong f bsary.count
			for sp in bsary do (
				if sp.scale != [1,1,1] then (
					sc = sp.scale.x
					if sc > sp.scale.y then sc = sp.scale.y
					if sc > sp.scale.z then sc = sp.scale.z
				) else sc = 1
				writeFloat f (sp.radius * sc * Iscale)
				writeFloat f (sp.pos.x * Iscale)
				writeFloat f (sp.pos.y * Iscale)
				writeFloat f (sp.pos.z * Iscale)
				if classof sp.material == GTA_COLSurface then (
					ts = sp.material.surface
					tp = sp.material.part
					u1 = sp.material.u1
					u2 = sp.material.u2
				) else (
					ts = getUserProp sp "Surface"
					if ts == undefined then ts = 0
					tp = getUserProp sp "Part"
					if tp == undefined then tp = 0
					u1 = getUserProp sp "u1"
					if u1 == undefined then u1 = 0
					u2 = getUserProp sp "u2"
					if u2 == undefined then u2 = 0
				)
				writeByte f ts
				writeByte f tp
				writeByte f u1								--Always
				writeByte f u2									--unknown
			)	
 		--Write Col boxes--
 		--===============--
		writeLong f 0
		writeLong f bbary.count
 		for bx in bbary do (
			writeFloat f  (bx.min.x * Iscale)
			writeFloat f  (bx.min.y * Iscale)
			writeFloat f  (bx.min.z * Iscale)
			writeFloat f  (bx.max.x * Iscale)
			writeFloat f  (bx.max.y * Iscale)
			writeFloat f  (bx.max.z * Iscale)
			if classof bx.material == GTA_COLSurface then (
				ts = bx.material.surface
				tp = bx.material.part
				u1 = bx.material.u1
				u2 = bx.material.u2
			) else (
				ts = getUserProp bx "Surface"
				if ts == undefined then ts = 0
				tp = getUserProp bx "Part"
				if tp == undefined then tp = 0
				u1 = getUserProp bx "u1"
				if u1 == undefined then u1 = 0
				u2 = getUserProp bx "u2"
				if u2 == undefined then u2 = 0
			)
			writeByte f ts
			writeByte f tp
			writeByte f u1								--Always
			writeByte f u2									--unknown
		)
	 	--Write Col Mesh--
	 	--==============--

		if cmsh != undefined then (
			writeLong f  cmsh.numverts
			for i = 1 to cmsh.numverts do (
				writeFloat f (cmsh.verts[i].pos.x * Iscale)
				writeFloat f (cmsh.verts[i].pos.y * Iscale)
				writeFloat f (cmsh.verts[i].pos.z * Iscale)
			)--end for i
			writeLong f  cmsh.numfaces
			for i = 1 to cmsh.numfaces do (
				fc = getface cmsh i
				writeLong f  ((fc.y - 1) as integer)
				writeLong f ((fc.x - 1) as integer)
				writeLong f ((fc.z - 1) as integer)
				if classof cmsh.material == GTA_COLSurface then (
					writeLong f (cmsh.material.surface + cmsh.material.part * 256)
				) else if classof cmsh.material == Multimaterial then (
					fid = getFaceMatID cmsh i
					if classof cmsh.material[fid] == GTA_COLSurface then (
						writeLong f (cmsh.material[fid].surface + cmsh.material[fid].part * 256)
					) else writeLong f 0
				) else writeLong f 0
			)
			delete cmsh
		) else (
			writeLong f 0
			writeLong f 0
		)	
)--end fn expCOLL
--
fn expCOL2 f colname allobjects cmesh Iscale = (
	--Caculate the size first--
	bcount = 100
	bsary = for sp in allobjects where (classof sp == Sphere)AND(sp.name != "Bounding Sphere") collect sp
	bbary = for bx in allobjects where (classof bx == Box)AND(bx.name != "Bounding Box") collect bx
	bcount += bsary.count * 20 
	bcount += bbary.count * 28 	
	if cmesh != undefined then (
		cmsh = snapshot cmesh
		bcount += cmsh.numverts * 6 + cmsh.numfaces * 8
	)

	--Writting Start--
	--==============--
	WriteLong f 0x324C4F43 					--"COL2"
	WriteLong f bcount
	WriteString f colname
	for i = 1 to (23 - colname.count) do WriteByte f 0
	--Write Boundings--
	--===============--
	bs = for obj in allobjects where (obj.name == "Bounding Sphere") collect obj
	bb = for obj in allobjects where (obj.name == "Bounding Box") collect obj
	if (bs.count > 0)AND(bb.count > 0) then (
		bmax = bb[1].max
		bmin = bb[1].min
		bsp = bs[1]
			if bsp.scale != [1,1,1] then (
				sc = bsp.scale.x
				if sc > bsp.scale.y then sc = bsp.scale.y
				if sc > bsp.scale.z then sc = bsp.scale.z
			) else sc = 1
	) else (
		try ( deselect bs; deselect bb ) catch()
		try ( selectmore cmesh ) catch()
		bmax = $.max
		bmin = $.min
		boxsize = bmax - bmin
		br = sqrt ( (boxsize.x/2 * boxsize.x/2)+(boxsize.y/2 * boxsize.y/2)+(boxsize.z/2 * boxsize.z/2) )
		bsp = sphere radius:br xray:on wirecolor:(color 216 218 140)
		bsp.center = (bmax + bmin) / 2
		sc = 1
	)	
	WriteFloat f (bmin.x * Iscale)
	WriteFloat f (bmin.y * Iscale)
	WriteFloat f (bmin.z * Iscale)
	WriteFloat f (bmax.x * Iscale)
	WriteFloat f (bmax.y * Iscale)
	WriteFloat f (bmax.z * Iscale)
	WriteFloat f (bsp.pos.x * Iscale) 
	WriteFloat f (bsp.pos.y * Iscale) 
	WriteFloat f (bsp.pos.z * Iscale)
	WriteFloat f (bsp.radius * sc * Iscale) 
	if bs.count == 0 then delete bsp
	--Write information--
	--=================--
	addos = 104
	WriteShort f bsary.count
	WriteShort f bbary.count
	if cmsh == undefined then WriteLong f 0
	else WriteLong f cmsh.numfaces
    
	--unknown1--
	if cmsh != undefined then WriteLong f 2
	else if (bsary.count > 0)OR(bbary.count > 0) then WriteLong f 2
	else WriteLong f 0

	if bsary.count > 0 then (
		WriteLong f addos
		addos += bsary.count * 20
	) else WriteLong f 0
	if bbary.count > 0 then (
		WriteLong f addos
		addos += bbary.count * 28
	) else WriteLong f 0
	WriteLong f 0										--unknown2
	if cmsh != undefined then (
		WriteLong f addos
		addos += cmsh.numverts * 6
		WriteLong f addos
		addos += cmsh.numFaces * 8
	) else (
		WriteLong f 0
		WriteLong f 0
	)
	WriteLong f 0										--unknown3

	--Write Col Spheres--
	--=================--
	for sp in bsary do (
		if sp.scale != [1,1,1] then (
			sc = sp.scale.x
			if sc > sp.scale.y then sc = sp.scale.y
			if sc > sp.scale.z then sc = sp.scale.z
		) else sc = 1
		WriteFloat f (sp.pos.x * Iscale) 
		WriteFloat f (sp.pos.y * Iscale) 
		WriteFloat f (sp.pos.z * Iscale) 
		WriteFloat f (sp.radius * sc * Iscale)
		if classof sp.material == GTA_COLSurface then (
			ts = sp.material.surface
			tp = sp.material.part
			u1 = sp.material.u1
			u2 = sp.material.u2
		) else (
			ts = getUserProp sp "Surface"
			if ts == undefined then ts = 0
			tp = getUserProp sp "Part"
			if tp == undefined then tp = 0
			u1 = getUserProp sp "u1"
			if u1 == undefined then u1 = 0xBB
			u2 = getUserProp sp "u2"
			if u2 == undefined then u2 = 0
		)
		WriteByte f ts
		WriteByte f tp
		WriteByte f u1								--Always
		WriteByte f u2									--unknown
	)
	--Write Col boxes--
	--===============--
	for bx in bbary do (
		WriteFloat f (bx.min.x * Iscale)
		WriteFloat f (bx.min.y * Iscale)
		WriteFloat f (bx.min.z * Iscale)
		WriteFloat f (bx.max.x * Iscale)
		WriteFloat f (bx.max.y * Iscale)
		WriteFloat f (bx.max.z * Iscale)
		if classof bx.material == GTA_COLSurface then (
			ts = bx.material.surface
			tp = bx.material.part
			u1 = bx.material.u1
			u2 = bx.material.u2
		) else (
			ts = getUserProp bx "Surface"
			if ts == undefined then ts = 0
			tp = getUserProp bx "Part"
			if tp == undefined then tp = 0
			u1 = getUserProp bx "u1"
			if u1 == undefined then u1 = 0xBB
			u2 = getUserProp bx "u2"
			if u2 == undefined then u2 = 0
		)
		WriteByte f ts
		WriteByte f tp
		WriteByte f u1								--Always
		WriteByte f u2									--unknown
	)
	--Write Col Mesh--
	--==============--
	if cmsh != undefined then (
		for i = 1 to cmsh.numverts do (
			pt = cmsh.verts[i].pos
			val = pt.x * 128 * Iscale
			if val - (val as integer) > 0.5 then val += 1
			writeShort f (val as integer)
			val = pt.y * 128 * Iscale
			if val - (val as integer) > 0.5 then val += 1
			writeShort f (val as integer)
			val = pt.z * 128 * Iscale
			if val - (val as integer) > 0.5 then val += 1
			writeShort f (val as integer)
		)
		for i = 1 to cmsh.numfaces do (
			fc = getface cmsh i
			WriteShort f (fc.y - 1)
			WriteShort f (fc.x - 1)
			WriteShort f (fc.z - 1)
			if classof cmsh.material == GTA_COLSurface then (
				WriteByte f cmsh.material.surface
				WriteByte f cmsh.material.part
			) else if classof cmsh.material == Multimaterial then (
				fid = getFaceMatID cmsh i
				if classof cmsh.material[fid] == GTA_COLSurface then (
					WriteByte f cmsh.material[fid].surface
					WriteByte f cmsh.material[fid].part
				) else (
					WriteByte f 0
					WriteByte f 0
				)
			) else (
				WriteByte f 0
				WriteByte f 0
			) 
		)
		delete cmsh
	)
)--end fn expCOL2
--
fn dumpCOL3 SavePathName colname allobjects cmesh smesh Iscale autograb = (
	format "\n\n"
	clearlistener()
	if autograb == true then format "<snoopstart file=%>\n" SavePathName
	else format "<!-- path=\"%\" -->\n" SavePathName
	format "//\n//SA Collision file <%> start here\n//\n" Colname
	--Caculate the size first--
	bcount = 112
	bsary = for sp in allobjects where (classof sp == Sphere)AND(sp.name != "Bounding Sphere") collect sp
	bbary = for bx in allobjects where (classof bx == Box)AND(bx.name != "Bounding Box") collect bx
	bcount += bsary.count * 20 
	bcount += bbary.count * 28 	
	if cmesh != undefined then (
		cmsh = snapshot cmesh
		bcount += cmsh.numverts * 6 + cmsh.numfaces * 8
	)
	if smesh != undefined then (
		smsh = snapshot smesh
		bcount += smsh.numverts * 6 + smsh.numfaces * 8
	)
	--Writting Start--
	--==============--
	format "i 2\n% %\n" 0x334C4F43 bcount				--"COL3"
	format "c 24\n%\n" colname
	--Write Boundings--
	--===============--
	bs = for obj in allobjects where (obj.name == "Bounding Sphere") collect obj
	bb = for obj in allobjects where (obj.name == "Bounding Box") collect obj
	if (bs.count > 0)AND(bb.count > 0) then (
		bmax = bb[1].max
		bmin = bb[1].min
		bsp = bs[1]
			if bsp.scale != [1,1,1] then (
				sc = bsp.scale.x
				if sc > bsp.scale.y then sc = bsp.scale.y
				if sc > bsp.scale.z then sc = bsp.scale.z
			) else sc = 1
	) else (
		try ( deselect bs; deselect bb ) catch()
		try ( selectmore cmesh ) catch () 
		try ( selectmore smesh ) catch ()
		bmax = $.max
		bmin = $.min
		boxsize = bmax - bmin
		br = sqrt ( (boxsize.x/2 * boxsize.x/2)+(boxsize.y/2 * boxsize.y/2)+(boxsize.z/2 * boxsize.z/2) )
		bsp = sphere radius:br xray:on wirecolor:(color 216 218 140)
		bsp.center = (bmax + bmin) / 2
		sc = 1
	)	
	format "f 10\n % " (bmin.x * Iscale)
	format "% " (bmin.y * Iscale)
	format "% " (bmin.z * Iscale)
	format "% " (bmax.x * Iscale)
	format "% " (bmax.y * Iscale)
	format "% " (bmax.z * Iscale)
	format "% " (bsp.pos.x * Iscale) 
	format "% " (bsp.pos.y * Iscale) 
	format "% " (bsp.pos.z * Iscale)
	format "%\n" (bsp.radius * sc * Iscale) 
	if bs.count == 0 then delete bsp
	--Write information--
	--=================--
	addos = 116
	format "w 2\n% %\ni 11\n" bsary.count bbary.count
	if cmsh == undefined then format "0 "
	else format "% " cmsh.numfaces
    
	--unknown1--
	if smsh != undefined then format "18 "
	else if cmsh != undefined then format "2 "
	else if (bsary.count > 0)OR(bbary.count > 0) then format "2 "
	else format "0 "

	if bsary.count > 0 then (
		format "% " addos
		addos += bsary.count * 20
	) else format "0 "
	if bbary.count > 0 then (
		format "% " addos
		addos += bbary.count * 28
	) else format "0 "
	format "0 "										--unknown2
	if cmsh != undefined then (
		format "% " addos
		addos += cmsh.numverts * 6
		format "% " addos
		addos += cmsh.numFaces * 8
	) else format "0 0 "
	format "0 "										--unknown3
	if smsh != undefined then (
		format "% " smsh.numfaces
		format "% " addos
		addos += smsh.numverts * 6
		format "% " addos
		addos += smsh.numFaces * 8
	) else format "0 0 0 "
	format "\n"
	--Write Col Spheres--
	--=================--
	for sp in bsary do (
		if sp.scale != [1,1,1] then (
			sc = sp.scale.x
			if sc > sp.scale.y then sc = sp.scale.y
			if sc > sp.scale.z then sc = sp.scale.z
		) else sc = 1
		format "f 4\n% " (sp.pos.x * Iscale)
		format "% " (sp.pos.y * Iscale)
		format "% " (sp.pos.z * Iscale)
		format "%\n" (sp.radius * sc * Iscale)
		if classof sp.material == GTA_COLSurface then (
			ts = sp.material.surface
			tp = sp.material.part
			u1 = sp.material.u1
			u2 = sp.material.u2
		) else (
			ts = getUserProp sp "Surface"
			if ts == undefined then ts = 0
			tp = getUserProp sp "Part"
			if tp == undefined then tp = 0
			u1 = getUserProp sp "u1"
			if u1 == undefined then u1 = 0xBB
			u2 = getUserProp sp "u2"
			if u2 == undefined then u2 = 0
		)
		format "b 4\n% " ts
		format "% " tp
		format "% " u1								--Always
		format "%\n" u2									--unknown
	)
	--Write Col boxes--
	--===============--
	for bx in bbary do (
		format "f 6\n% " (bx.min.x * Iscale)
		format "% " (bx.min.y * Iscale)
		format "% " (bx.min.z * Iscale)
		format "% " (bx.max.x * Iscale)
		format "% " (bx.max.y * Iscale)
		format "%\n" (bx.max.z * Iscale)
		if classof bx.material == GTA_COLSurface then (
			ts = bx.material.surface
			tp = bx.material.part
			u1 = bx.material.u1
			u2 = bx.material.u2
		) else (
			ts = getUserProp bx "Surface"
			if ts == undefined then ts = 0
			tp = getUserProp bx "Part"
			if tp == undefined then tp = 0
			u1 = getUserProp bx "u1"
			if u1 == undefined then u1 = 0xBB
			u2 = getUserProp bx "u2"
			if u2 == undefined then u2 = 0
		)
		format "b 4\n% " ts
		format "% " tp
		format "% " u1								--Always
		format "%\n" u2									--unknown
	)
	--Write Col Mesh--
	--==============--
	if cmsh != undefined then (
		format "w %\n" (cmsh.numverts * 3)
		for i = 1 to cmsh.numverts do (
			pt = cmsh.verts[i].pos
			val = pt.x * 128 * Iscale
			if val - (val as integer) > 0.5 then val += 1
			format "% " (val as integer)
			val = pt.y * 128 * Iscale
			if val - (val as integer) > 0.5 then val += 1
			format "% " (val as integer)
			val = pt.z * 128 * Iscale
			if val - (val as integer) > 0.5 then val += 1
			format "% " (val as integer)
			if (mod i 10) == 0 then format"\n"
		)
		if (mod cmsh.numverts 10) != 0 then format"\n"
		format "w %\n" (cmsh.numfaces * 4)
		for i = 1 to cmsh.numfaces do (
			fc = getface cmsh i
			format "% " ((fc.y - 1) as integer)
			format "% " ((fc.x - 1) as integer)
			format "% " ((fc.z - 1) as integer)
			if classof cmsh.material == GTA_COLSurface then (
				format "% " (cmsh.material.surface + cmsh.material.part * 256)
			) else if classof cmsh.material == Multimaterial then (
				fid = getFaceMatID cmsh i
				if classof cmsh.material[fid] == GTA_COLSurface then (
					format "% " (cmsh.material[fid].surface + cmsh.material[fid].part * 256)
				) else format "0 "
			) else format "0 "
			if (mod i 10) == 0 then format"\n"
		)
		if (mod cmsh.numfaces 10) != 0 then format"\n"
		delete cmsh
	)
	--Write Shadow Mesh--
	--=================--
	if smsh != undefined then (
		format "w %\n" (smsh.numverts * 3)
		for i = 1 to smsh.numverts do (
			pt = smsh.verts[i].pos
			val = pt.x * 128 * Iscale
			if val - (val as integer) > 0.5 then val += 1
			format "% " (val as integer)
			val = pt.y * 128 * Iscale
			if val - (val as integer) > 0.5 then val += 1
			format "% " (val as integer)
			val = pt.z * 128 * Iscale
			if val - (val as integer) > 0.5 then val += 1
			format "% " (val as integer)
			if (mod i 10) == 0 then format"\n"
		)
		if (mod smsh.numverts 10) != 0 then format"\n"
		format "w %\n" (smsh.numfaces * 4)
		for i = 1 to smsh.numfaces do (
			fc = getface smsh i
			format "% " ((fc.y - 1) as integer)
			format "% " ((fc.x - 1) as integer)
			format "% " ((fc.z - 1) as integer)
			if classof smsh.material == GTA_COLShadow then (
				format "% " (smsh.material.u1 + smsh.material.u2 * 256)
			) else if classof smsh.material == Multimaterial then (
				fid = getFaceMatID smsh i
				if classof smsh.material[fid] == GTA_COLShadow then (
					format "% " (smsh.material[fid].u1 + smsh.material[fid].u2 * 256)
				) else format "65280 "
			) else format "65280 "
			if (mod i 10) == 0 then format"\n"
		)
		if (mod smsh.numfaces 10) != 0 then format"\n"
		delete smsh
	)
	format "\n\n"
	if autograb == true then format "</snoopend>\n"
)--end fn dumpCOL3
--
fn dumpCOL2 SavePathName colname allobjects cmesh  Iscale autograb = (
	format "\n\n"
	clearlistener()
	if autograb == true then format "<snoopstart file=%>\n" SavePathName
	else format "<!-- path=\"%\" -->\n" SavePathName
	format "//\n//SA Collision file <%> start here\n//\n" Colname
	--Caculate the size first--
	bcount = 100
	bsary = for sp in allobjects where (classof sp == Sphere)AND(sp.name != "Bounding Sphere") collect sp
	bbary = for bx in allobjects where (classof bx == Box)AND(bx.name != "Bounding Box") collect bx
	bcount += bsary.count * 20 
	bcount += bbary.count * 28 	
	if cmesh != undefined then (
		cmsh = snapshot cmesh
		bcount += cmsh.numverts * 6 + cmsh.numfaces * 8
	)

	--Writting Start--
	--==============--
	format "i 2\n% %\n" 0x324C4F43 bcount				--"COL2"
	format "c 24\n%\n" colname
	--Write Boundings--
	--===============--
	bs = for obj in allobjects where (obj.name == "Bounding Sphere") collect obj
	bb = for obj in allobjects where (obj.name == "Bounding Box") collect obj
	if (bs.count > 0)AND(bb.count > 0) then (
		bmax = bb[1].max
		bmin = bb[1].min
		bsp = bs[1]
			if bsp.scale != [1,1,1] then (
				sc = bsp.scale.x
				if sc > bsp.scale.y then sc = bsp.scale.y
				if sc > bsp.scale.z then sc = bsp.scale.z
			) else sc = 1
	) else (
		try ( deselect bs; deselect bb ) catch()
		try ( selectmore cmesh ) catch () 
		bmax = $.max
		bmin = $.min
		boxsize = bmax - bmin
		br = sqrt ( (boxsize.x/2 * boxsize.x/2)+(boxsize.y/2 * boxsize.y/2)+(boxsize.z/2 * boxsize.z/2) )
		bsp = sphere radius:br xray:on wirecolor:(color 216 218 140)
		bsp.center = (bmax + bmin) / 2
		sc = 1
	)	
	format "f 10\n % " (bmin.x * Iscale)
	format "% " (bmin.y * Iscale)
	format "% " (bmin.z * Iscale)
	format "% " (bmax.x * Iscale)
	format "% " (bmax.y * Iscale)
	format "% " (bmax.z * Iscale)
	format "% " (bsp.pos.x * Iscale) 
	format "% " (bsp.pos.y * Iscale) 
	format "% " (bsp.pos.z * Iscale)
	format "%\n" (bsp.radius * sc * Iscale) 
	if bs.count == 0 then delete bsp
	--Write information--
	--=================--
	addos = 104
	format "w 2\n% %\ni 8\n" bsary.count bbary.count
	if cmsh == undefined then format "0 "
	else format "% " cmsh.numfaces
    
	--unknown1--
	if cmsh != undefined then format "2 "
	else if (bsary.count > 0)OR(bbary.count > 0) then format "2 "
	else format "0 "

	if bsary.count > 0 then (
		format "% " addos
		addos += bsary.count * 20
	) else format "0 "
	if bbary.count > 0 then (
		format "% " addos
		addos += bbary.count * 28
	) else format "0 "
	format "0 "										--unknown2
	if cmsh != undefined then (
		format "% " addos
		addos += cmsh.numverts * 6
		format "% " addos
		addos += cmsh.numFaces * 8
	) else format "0 0 "
	format "0 "										--unknown3

	--Write Col Spheres--
	--=================--
	for sp in bsary do (
		if sp.scale != [1,1,1] then (
			sc = sp.scale.x
			if sc > sp.scale.y then sc = sp.scale.y
			if sc > sp.scale.z then sc = sp.scale.z
		) else sc = 1
		format "f 4\n% " (sp.pos.x * Iscale)
		format "% " (sp.pos.y * Iscale)
		format "% " (sp.pos.z * Iscale)
		format "%\n" (sp.radius * sc * Iscale)
		if classof sp.material == GTA_COLSurface then (
			ts = sp.material.surface
			tp = sp.material.part
			u1 = sp.material.u1
			u2 = sp.material.u2
		) else (
			ts = getUserProp sp "Surface"
			if ts == undefined then ts = 0
			tp = getUserProp sp "Part"
			if tp == undefined then tp = 0
			u1 = getUserProp sp "u1"
			if u1 == undefined then u1 = 0xBB
			u2 = getUserProp sp "u2"
			if u2 == undefined then u2 = 0
		)
		format "b 4\n% " ts
		format "% " tp
		format "% " u1								--Always
		format "%\n" u2									--unknown
	)
	--Write Col boxes--
	--===============--
	for bx in bbary do (
		format "f 6\n% " (bx.min.x * Iscale)
		format "% " (bx.min.y * Iscale)
		format "% " (bx.min.z * Iscale)
		format "% " (bx.max.x * Iscale)
		format "% " (bx.max.y * Iscale)
		format "%\n" (bx.max.z * Iscale)
		if classof bx.material == GTA_COLSurface then (
			ts = bx.material.surface
			tp = bx.material.part
			u1 = bx.material.u1
			u2 = bx.material.u2
		) else (
			ts = getUserProp bx "Surface"
			if ts == undefined then ts = 0
			tp = getUserProp bx "Part"
			if tp == undefined then tp = 0
			u1 = getUserProp bx "u1"
			if u1 == undefined then u1 = 0xBB
			u2 = getUserProp bx "u2"
			if u2 == undefined then u2 = 0
		)
		format "b 4\n% " ts
		format "% " tp
		format "% " u1								--Always
		format "%\n" u2									--unknown
	)
	--Write Col Mesh--
	--==============--
	if cmsh != undefined then (
		format "w %\n" (cmsh.numverts * 3)
		for i = 1 to cmsh.numverts do (
			pt = cmsh.verts[i].pos
			val = pt.x * 128 * Iscale
			if val - (val as integer) > 0.5 then val += 1
			format "% " (val as integer)
			val = pt.y * 128 * Iscale
			if val - (val as integer) > 0.5 then val += 1
			format "% " (val as integer)
			val = pt.z * 128 * Iscale
			if val - (val as integer) > 0.5 then val += 1
			format "% " (val as integer)
			if (mod i 10) == 0 then format"\n"
		)
		if (mod cmsh.numverts 10) != 0 then format"\n"
		format "w %\n" (cmsh.numfaces * 4)
		for i = 1 to cmsh.numfaces do (
			fc = getface cmsh i
			format "% " ((fc.y - 1) as integer)
			format "% " ((fc.x - 1) as integer)
			format "% " ((fc.z - 1) as integer)
			if classof cmsh.material == GTA_COLSurface then (
				format "% " (cmsh.material.surface + cmsh.material.part * 256)
			) else if classof cmsh.material == Multimaterial then (
				fid = getFaceMatID cmsh i
				if classof cmsh.material[fid] == GTA_COLSurface then (
					format "% " (cmsh.material[fid].surface + cmsh.material[fid].part * 256)
				) else format "0 "
			) else format "0 "
			if (mod i 10) == 0 then format"\n"
		)
		if (mod cmsh.numfaces 10) != 0 then format"\n"
		delete cmsh
	)
	format "\n\n"
	if autograb == true then format "</snoopend>\n"
)--end fn dumpCOL2
--
fn dumpCOLL SavePathName colname allobjects cmesh Iscale autograb = (
		local cmsh = undefined
		--calculate size--
		bcount = 36 + 48				--Name[20] unknown unknown numVerts numFaces
		bsary = for sp in allobjects where (classof sp == Sphere)AND(sp.name != "Bounding Sphere") collect sp
		bbary = for bx in allobjects where (classof bx == Box)AND(bx.name != "Bounding Box") collect bx
		bcount += bsary.count * 20 
		bcount += bbary.count * 28 	
		if cmesh != undefined then (
			cmsh = snapshot cmesh
			bcount += cmsh.numverts * 12
			bcount += cmsh.numFaces * 16
		)
		format "\n\n"
		clearlistener()
		if autograb == true then format "<snoopstart file=%>\n" SavePathName
		else format "<!-- path=\"%\" -->\n" SavePathName
		format "//\n//Collision file(COLL) <%> start here\n//\n" Colname
		format "i 2\n % %\n" 0x4C4C4F43 bcount
		format "c 20\n%\n" colname
		format "i 1\n%\n" 0x0030FFFF				-- unknown
		--Write Boundings--
		--===============--
		bs = for obj in allobjects where (obj.name == "Bounding Sphere") collect obj
		bb = for obj in allobjects where (obj.name == "Bounding Box") collect obj
		if (bs.count > 0)AND(bb.count > 0) then (
			bmax = bb[1].max
			bmin = bb[1].min
			bsp = bs[1]
				if bsp.scale != [1,1,1] then (
					sc = bsp.scale.x
					if sc > bsp.scale.y then sc = bsp.scale.y
					if sc > bsp.scale.z then sc = bsp.scale.z
				) else sc = 1
		) else (
			try ( deselect bs; deselect bb ) catch()
			try ( selectmore cmesh ) catch () 
			bmax = $.max
			bmin = $.min
			boxsize = bmax - bmin
			br = sqrt ( (boxsize.x/2 * boxsize.x/2)+(boxsize.y/2 * boxsize.y/2)+(boxsize.z/2 * boxsize.z/2) )
			bsp = sphere radius:br xray:on wirecolor:(color 216 218 140)
			bsp.center = (bmax + bmin) / 2
			sc = 1
		)	
		--format "//BoundingSphere R X Y Z\n"
		format "f 10\n % " (bsp.radius * sc * Iscale) 
		format "% " (bsp.pos.x * Iscale) 
		format "% " (bsp.pos.y * Iscale) 
		format "% " (bsp.pos.z * Iscale)
		--format "//BoundingBox min max\n"
		format "% " (bmin.x * Iscale)
		format "% " (bmin.y * Iscale)
		format "% " (bmin.z * Iscale)
		format "% " (bmax.x * Iscale)
		format "% " (bmax.y * Iscale)
		format "%\n" (bmax.z * Iscale)
		if bs.count == 0 then delete bsp
		--Write Col Spheres--
		--=================--	
			--format "//Spheres\n"
			format "i 1\n%\n" bsary.count
			for sp in bsary do (
				if sp.scale != [1,1,1] then (
					sc = sp.scale.x
					if sc > sp.scale.y then sc = sp.scale.y
					if sc > sp.scale.z then sc = sp.scale.z
				) else sc = 1
				format "f 4\n% " (sp.radius * sc * Iscale)
				format "% " (sp.pos.x * Iscale)
				format "% " (sp.pos.y * Iscale)
				format "%\n" (sp.pos.z * Iscale)
				if classof sp.material == GTA_COLSurface then (
					ts = sp.material.surface
					tp = sp.material.part
					u1 = sp.material.u1
					u2 = sp.material.u2
				) else (
					ts = getUserProp sp "Surface"
					if ts == undefined then ts = 0
					tp = getUserProp sp "Part"
					if tp == undefined then tp = 0
					u1 = getUserProp sp "u1"
					if u1 == undefined then u1 = 0
					u2 = getUserProp sp "u2"
					if u2 == undefined then u2 = 0
				)
				format "b 4\n% " ts
				format "% " tp
				format "% " u1								--Always
				format "%\n" u2									--unknown
			)	
 		--Write Col boxes--
 		--===============--
 		--format "//Boxes\n"
		format "i 2\n0 %\n"bbary.count
 		for bx in bbary do (
			format "f 6\n% " (bx.min.x * Iscale)
			format "% " (bx.min.y * Iscale)
			format "% " (bx.min.z * Iscale)
			format "% " (bx.max.x * Iscale)
			format "% " (bx.max.y * Iscale)
			format "%\n" (bx.max.z * Iscale)
			if classof bx.material == GTA_COLSurface then (
				ts = bx.material.surface
				tp = bx.material.part
				u1 = bx.material.u1
				u2 = bx.material.u2
			) else (
				ts = getUserProp bx "Surface"
				if ts == undefined then ts = 0
				tp = getUserProp bx "Part"
				if tp == undefined then tp = 0
				u1 = getUserProp bx "u1"
				if u1 == undefined then u1 = 0
				u2 = getUserProp bx "u2"
				if u2 == undefined then u2 = 0
			)
			format "b 4\n% " ts
			format "% " tp
			format "% " u1								--Always
			format "%\n" u2									--unknown
		)
	 	--Write Col Mesh--
	 	--==============--
 		--format "//Collision Mesh\n"	
		if cmsh != undefined then (
			format "i 1\n%\nf %\n" cmsh.numverts (cmsh.numverts * 3)
			for i = 1 to cmsh.numverts do (
				format "% % % " (cmsh.verts[i].pos.x * Iscale) (cmsh.verts[i].pos.y * Iscale) (cmsh.verts[i].pos.z * Iscale)
				if (mod i 10) == 0 then format"\n"
			)--end for i
			if (mod cmsh.numverts 10) != 0 then format"\n"
			format "i %\n%\n" (cmsh.numfaces * 4 + 1) cmsh.numfaces
			for i = 1 to cmsh.numfaces do (
				fc = getface cmsh i
				format "% " ((fc.y - 1) as integer)
				format "% " ((fc.x - 1) as integer)
				format "% " ((fc.z - 1) as integer)
				if classof cmsh.material == GTA_COLSurface then (
					format "% " (cmsh.material.surface + cmsh.material.part * 256)
				) else if classof cmsh.material == Multimaterial then (
					fid = getFaceMatID cmsh i
					if classof cmsh.material[fid] == GTA_COLSurface then (
						format "% " (cmsh.material[fid].surface + cmsh.material[fid].part * 256)
					) else format "0 "
				) else format "0 "
				if (mod i 10) == 0 then format"\n"
			)
			if (mod cmsh.numfaces 10) != 0 then format"\n"
			delete cmsh
		) else 			format "i 2\n0 0\n"
	format "\n\n"
	if autograb == true then format "</snoopend>\n"
)--end fn dumpCOLL
--
Global fname

rollout COLaboutRoll "About" (
	group "GMax Setting"(
		checkbox gtamaxON "Use GTAmax.exe" checked:true
	label a1 "*Great news form Alex(ak73)"
	label a2 "   with his great program" align:#left
	label a3 "   GTAmax.exe, files will be" align:#left
	label a4 "   saved automatically!!!" align:#left
	label a5 "Thanks Alex, you're superstar!"
	)
	label l1 "GTA Collision IO"
	label l3 " " 

	--label l3a "A test Import/Export COL3"	align:#left
	label l3d "Thanks ocram for helping" align:#left
	label l3e "me to finish this script !"	align:#left
	--label l3f "will be correct!? If you want"	align:#left
	--label l3g "me to continue, report any"	align:#left
	--label l3h "finding to me and I'll finish" align:#left
	--label l3i "this script!"align:#left
	label l3j ""
	label l4 "by Kam" align:#left across:2
	label l5 "05Dec05" align:#right
	label l6 "kam.lai@ntlworld.com"

)--end rollout COLaboutRoll


rollout COLin "IO Controls" (
	local PartAry = #( 	"Default", 
    "Bonnet",            "Boot", 
	"Front Bumper",      "Rear Bumper",
	"Left Front Door",   "Right Front Door",
	"Left Rear Door",    "Right Rear Door",
	"Left Front Wing",   "Right Front Wing",
	"Left Rear Wing",    "Right Rear Wing",
	"ID 13","ID 14","ID 15","ID 16",			--13-16 are emply
	"Windscreen" )

	local colmesh = undefined
	local shwmesh = undefined

	fn meshfilter obj = superclassof obj == GeometryClass 

	button impCol "Open Collision File" width:120 align:#center tooltip:"Open Collision File (COL/DFF)"
	listbox ColList "" height:10 offset:[0,-3]
	button loaCol "Load" width:61 align:#left tooltip:"Load the selected model into (G)Max" offset:[0,-3] across:2 
	spinner INScale "" range:[0.000001,100000,1] fieldwidth:45 align:#right offset:[-1,0] 
	checkbox skipbSB "Skip bounding"

	group "Max Only Control" (
 	 	button DelCol "Delete" width:60 tooltip:"Delete a Collision Set From File List"    across:2
	 	button appcol "Append" width:60 tooltip:"Append export to current Collision File"    
--		button BatchCOL "COL Convertion" width:120 align:#center tooltip:"Batch convert col set across COLL/COL2/COL3"   
	)

	edittext newname "" align:#center width:125 offset:[-2,-5]
	 button Ecol "Export" width:120 align:#center  tooltip:"Save As New Collision File(*.col)"   
	 button Ecolfast "Fast export" width:120 align:#center  tooltip:"Fast Export Collision File(*.col)"   

	group "Export Setting" (
 	 	checkbutton tycoll "COLL" width:40 highlightcolor:green enabled:true across:3
	 	checkbutton tycol2 "COL2" width:40  highlightcolor:green 
	 	checkbutton tycol3 "COL3" width:40 checked:true highlightcolor:green 		
		pickbutton pkcm "Collision Mesh" width:103 align:#left filter:meshfilter tooltip:"Select the Collision Mesh" across:2
		button clrcm "C" width:18 align:#right tooltip:"Clear Collision Mesh"
		pickbutton pksm "Shadow Mesh" width:103 align:#left filter:meshfilter tooltip:"Select the Shadow Mesh" offset:[0,-5] across:2
		button clrsm "C" width:18 align:#right offset:[0,-5] tooltip:"Clear Shadow Mesh"
	)
    
	on pkcm picked obj do (
		pkcm.text = obj.name
		colmesh = obj
	)
	on pksm picked obj do (
		pksm.text = obj.name
		shwmesh = obj
	)
	on clrcm pressed do (
		pkcm.text = "Collision Mesh"
		colmesh = undefined
	)
	on clrsm pressed do (
		pksm.text = "Shadow Mesh"
		shwmesh = undefined
	)
--
	on DelCol pressed do (
		if ColList.items.count == 1 then (
			ColList.items = #()
			ColAry = #()
			impCol.text = "Open Collision File"
			gc()
		) else 	
		if (ColList.selection > 0) then (	
			try (
				Sname = (getFilenamePath fname) + "temp.bin"
				f = fopen Sname "wb"
				ff = fopen fname "rb"
	
				addstart2 = undefined
				addend2 = undefined
				if ColList.selection == ColList.items.count then (
					addstart1 = 0
					addend1 = ColAry[1][ColList.selection] - 1
				) else
				if ColList.selection == 1 then (
					addstart1 = ColAry[1][2]
					fseek ff 0 #seek_end
					addend1 = (ftell ff) - 1
				) else (
					addstart1 = 0
					addend1 = ColAry[1][(ColList.selection)] - 1
					addstart2 = ColAry[1][(ColList.selection + 1)]
					fseek ff 0 #seek_end
					addend2 = (ftell ff) - 1
				)				
				format "start:%\tend:%\n" addstart1	addend1
				fseek ff addstart1 #seek_set
				for i = addstart1 to addend1 do  writeByte f (readByte ff)				
				if addstart2 != undefined then (
					fseek ff addstart2 #seek_set
					for i = addstart2 to addend2 do  writeByte f (readByte ff)
				--format "start:%\tend:%\n" addstart2	addend2
		 		)
			 
			 	fclose ff
				fclose f
				gc()
				deleteFile fname
				renameFile Sname fname					
				f = fopen fname "rb"
				global ColAry = setColArray f
				ColList.items = ColAry[2]
				fclose f		
				gc()                
			) catch()
		)
	)--end on DelCol
--
	on AppCol pressed do (
		if ($selection.count > 0)AND(newname.text.count > 0)AND(ColList.selection > 0) then (
				--try (				--	undefined * undefined
					Sname = (getFilenamePath fname) + "temp.bin"
					f = fopen Sname "wb"
					ff = fopen fname "rb"
					fseek ff 0 #seek_end
					totalbyte = ftell ff
					fseek ff 0 #seek_set
					for i = 1 to totalbyte do ( writeByte f (readByte ff) )
					fclose ff
					if tycol3.checked == true then expCOL3   f   newname.text   $selection   colmesh   shwmesh   (1/INScale.value)
					else if tycol2.checked == true then expCOL2   f   newname.text   $selection   colmesh   (1/INScale.value)
					else expCOLL   f   newname.text   $selection   colmesh   (1/INScale.value)
					fclose f
					gc()
					format "Data Appended\n"	
					deleteFile fname
					renameFile Sname fname					

					f = fopen fname "rb"
					global ColAry = setColArray f
					ColList.items = ColAry[2]
					fclose f					
					gc()
				--) catch (
				--	Sname = (getFilenamePath fname) + newname.text + ".txt"
				--	dumpCol $selection Sname newname.text INScale.value
				--)--end try/catch

		)--end if
	)--end on AppCol
--
	on tycoll changed state do (
		if state == false then tycoll.checked = true
		else (
			tycol2.checked = false
			tycol3.checked = false
		)
	)
	on tycol2 changed state do (
		if state == false then tycol2.checked = true
		else (
			tycoll.checked = false
			tycol3.checked = false
		)
	)
	on tycol3 changed state do (
		if state == false then tycol3.checked = true
		else (
			tycoll.checked = false
			tycol2.checked = false
		)
	)
--
	on BatchCOL pressed do (
		if $geometry.count != 0 then messagebox "Please start a new scene before batch convertion" title:"This scene is going to be clear"
		else (
			fname = getOpenFileName caption:"Open Collision File" types:"COL File (*.col)|*.col|"
			if fname != undefined then (
				Sname = (getFilenamePath fname) + (getFilenameFile fname) + "_converted.COL"
				clearlistener()
				f = fopen fname "rb"
				ff = fopen Sname "wb"
				--Read all Col's name and size--
				global ColAry = setColArray f
				fseek f 0 #seek_set

				-----------------------------
				--start loop for convertion--
				-----------------------------
				for i = 1 to ColAry[1].count do	(
					------------
					--Read col--
					------------
					format "%:\t%\n" ColAry[2][i] ColAry[1][i]
					ColHeader = readLong f
					fseek f  -4 #seek_cur
					case ColHeader of (
						0x4C4C4F43: ReadCOLL f  ColAry[2][i] 1 false PartAry
						0x334C4F43: ReadCOL3 f  ColAry[2][i] 1 false PartAry
						0x324C4F43: ReadCOL2 f  ColAry[2][i] 1 false PartAry
					)--end case
--messagebox "read col done!"
					-----------------------------------
					--collect Collision & Shadow mesh--
					-----------------------------------	
					OA = for obj in geometry where (substring obj.name 1 3)=="CM_" collect obj
					if OA.count == 0 then colmesh = undefined
					else colmesh = OA[1]
					OA = for obj in geometry where (substring obj.name 1 3)=="SM_" collect obj
					if OA.count == 0 then shwmesh = undefined
					else shwmesh = OA[1]
--messagebox "CM && SM done!"
					---------------------------
					--Changing Material Stuff--
					--Must have GTA_COLSurface to work on--
					---------------------------
					if GTA_COLSurface() != undefined then (
						if tycoll.checked == true then u = 0
						else u = 187
						for obj in geometry where obj.material != undefined do (
							if classof obj.material == GTA_COLSurface then obj.material.u1 = u
							else if classof obj.material == Multimaterial then (
								for j = 1 to obj.material.count do 
									if classof obj.material[j] == GTA_COLSurface then obj.material[j].u1 = u
							)
						)--end for
					)--end if
					--------------
					--Export COL--
					--------------
					max select all
					if tycol3.checked == true then 		expCOL3   ff   ColAry[2][i]   $selection   colmesh   shwmesh   1
					else if tycol2.checked == true then expCOL2   ff   ColAry[2][i]   $selection   colmesh   1
					else 								expCOLL   ff   ColAry[2][i]   $selection   colmesh   1
					delete $selection
				)--end for i			
	
				fclose ff
				fclose f
				gc()
				format "\n\nConvertion Done!!\n"			
			)--end if fname	
		)--end if/else clear scene
	)--end on BatchCOL
--
	on Ecol pressed do (
		if (newname.text != "")AND($selection.count > 0) then (
			Sname = getSaveFileName caption:"Save Collision File" types:"COL File (*.col)|*.col|"
			if Sname != undefined then (
				try (                   --undefined * undefined
					f = fopen Sname "wb"
					if tycol3.checked == true then expCOL3   f   newname.text   $selection   colmesh   shwmesh   (1/INScale.value)
					else if tycol2.checked == true then expCOL2   f   newname.text   $selection   colmesh   (1/INScale.value)
					else expCOLL   f   newname.text   $selection   colmesh   (1/INScale.value)
					fclose f
					gc()
				) catch (
					--Sname = (substring Sname 1 (Sname.count-4)) + ".txt"
					if tycol3.checked == true then   dumpCOL3   Sname   newname.text   $selection   colmesh   shwmesh   (1/INScale.value) COLaboutRoll.gtamaxON.checked  
					else if tycol2.checked == true then dumpCOL2   Sname   newname.text   $selection   colmesh   (1/INScale.value) COLaboutRoll.gtamaxON.checked 
					else dumpCOLL   Sname   newname.text   $selection   colmesh   (1/INScale.value) COLaboutRoll.gtamaxON.checked 
				)
			)--end if Sname
		)--end if newname
	)--end on Ecol

	on Ecolfast pressed do (
		if ($selection.count > 0) then 
		(
			colmesh = $selection[1]
			Sname = getSaveFileName filename: $selection[1].name caption:"Save Collision File" types:"COL File (*.col)|*.col|"

			if Sname != undefined then 
			(
				try 
				(                   --undefined * undefined
					f = fopen Sname "wb"
					if tycol3.checked == true then expCOL3   f   $selection[1].name   $selection   colmesh   shwmesh   (1/INScale.value)
					else if tycol2.checked == true then expCOL2   f   $selection[1].name   $selection   colmesh   (1/INScale.value)
					else expCOLL   f   $selection[1].name   $selection   colmesh   (1/INScale.value)
					fclose f
					gc()
				) catch (
					--Sname = (substring Sname 1 (Sname.count-4)) + ".txt"
					if tycol3.checked == true then   dumpCOL3   Sname   $selection[1].name  $selection   colmesh   shwmesh   (1/INScale.value) COLaboutRoll.gtamaxON.checked  
					else if tycol2.checked == true then dumpCOL2   Sname   $selection[1].name   $selection   colmesh   (1/INScale.value) COLaboutRoll.gtamaxON.checked 
					else dumpCOLL   Sname   $selection[1].name   $selection   colmesh   (1/INScale.value) COLaboutRoll.gtamaxON.checked 
				)
			)--end if Sname
		)--end if newname
	)--end on Ecol
--
	on impCol pressed do (
		fname = getOpenFileName caption:"Open SA Vehicle DFF File" types:"COL File (*.col)|*.col|DFF File (*.dff)|*.dff|"
		if fname != undefined then (
			clearlistener()
			f = fopen fname "rb"
				--Read COL--
				--========--
			if ((getFilenameType fname) == ".col")OR((getFilenameType fname) == ".COL") then (
				--f = fopen fname "rb"
				global ColAry = setColArray f
				ColList.items = ColAry[2]
				for i = 1 to ColAry[1].count do		format "%:\t%\n" ColAry[2][i] ColAry[1][i]
				impCol.text = "Col. File :  " + (FilenameFromPath fname)
				fclose f
				gc()
			) else (
				--Read DFF--
				--========--
				if (findCOL3 f 0x1803FFFF) != true then ( messagebox "Can't find COL3!\nMake sure to select SA vehicle dff only!" title:"NO COL3 in DFF"; format "%\n" (ftell f) )
				else (
					ReadCOL3 f  (getFilenameFile fname) INScale.value skipbSB.checked PartAry
					--format "%\n" fname			
					impCol.text =  "Open Collision File" 
					ColList.items = #()
				)
			)
			fclose f
		) else (
			impCol.text =  "Open Collision File" 
			ColList.items = #()
		)
		gc()
	)--end on impCol
--
	on loaCol pressed do (
		if (ColList.selection > 0) then (
			f = fopen fname "rb"
			format "\nColl. File:> %\n" ColList.selected
			fseek f  ColAry[1][ColList.selection]  #seek_set
			ColHeader = readLong f
			fseek f  -4 #seek_cur
			case ColHeader of (
				0x4C4C4F43: ReadCOLL f  ColList.selected INScale.value skipbSB.checked PartAry
				0x334C4F43: ReadCOL3 f  ColList.selected INScale.value skipbSB.checked PartAry
				0x324C4F43: ReadCOL2 f  ColList.selected INScale.value skipbSB.checked PartAry
			)
			fclose f
			newname.text = ColList.selected
			gc()
		)
	)--end on loaCol
--
	on ColList doubleclicked idx do (
			f = fopen fname "rb"
			format "\nColl. File:> %\n" ColList.selected
			fseek f  ColAry[1][ColList.selection]  #seek_set
			ColHeader = readLong f
			fseek f  -4 #seek_cur
			case ColHeader of (
				0x4C4C4F43: ReadCOLL f  ColList.selected INScale.value skipbSB.checked PartAry
				0x334C4F43: ReadCOL3 f  ColList.selected INScale.value skipbSB.checked PartAry
				0x324C4F43: ReadCOL2 f  ColList.selected INScale.value skipbSB.checked PartAry

			)
			fclose f
			newname.text = ColList.selected
			gc()
	)--end on ColList
--
)--end rollout COLin 




if Kam_SACOL != undefined then ( closeRolloutFloater Kam_SACOL; gc() )
Kam_SACOL = newRolloutFloater "GTA Collision IO" 175 490 10 50	--175 510 10 50	
addRollout COLin Kam_SACOL --rolledup:true
addRollout COLaboutRoll Kam_SACOL rolledup:true

