--
--04Oct05 replace this with DFFin--
fn DFFfromMap  f  texEx  setsname = (

	local RootObj
	cpary = rClump f false
	if cpAry[1] < 4 then (

		LetsRockandRoll = True

		tmp = rFrameList f 1 false
		FrameAry = tmp[1]
		NumGeo = rGeometryList f false
		MshAry = #()
		for i = 1 to NumGeo do (
			msh = rGeometry f 1 texEx false false
			if msh == undefined then (return undefined)
			append MshAry msh
		)

		while (readLong f) != 3 do (
			fseek f -4 #seek_cur
			local Idx = rAtomic f false
			if Idx.count == 3 then FrameAry[(Idx[1])].obj = Idx[2]
			else if Idx != undefined then FrameAry[(Idx[1])].obj = MshAry[(Idx[2])]
		)
		
		for i = 1 to FrameAry.count do (
			if FrameAry[i].obj == undefined then (
				FrameAry[i].obj = dummy boxsize:( [1,1,1] * 0.1  )
			) 
		)

		for i = 1 to FrameAry.count do (
			if FrameAry[i].parentID != 0 then (
				bkup = FrameAry[(FrameAry[i].parentID)].obj.transform
				FrameAry[(FrameAry[i].parentID)].obj.transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])
				FrameAry[i].obj.parent = FrameAry[(FrameAry[i].parentID)].obj				
				if false == true then format "% -> %\n" FrameAry[i].obj.name FrameAry[(FrameAry[i].parentID)].obj.name
				FrameAry[i].obj.transform = FrameAry[i].transform
				FrameAry[(FrameAry[i].parentID)].obj.transform = bkup
			) else ( 
				FrameAry[i].obj.transform = FrameAry[i].transform
				RootObj = FrameAry[i].obj    
			)
		) --end for i
        
		if setsname != undefined then (
			allObjs = for fm in FrameAry collect fm.obj
			selectionSets[setsname] = allObjs
		)

		LetsRockandRoll = false
		gc()
		return RootObj

	) else (
        return undefined
    )--end if/else cpAry[1]

)--end fn DFFfromMap
--
-----------------------------------
--find total sub-object in chain--
fn getsubnum obj tso = (
	if obj.children.count > 0 then (
		for i = 1 to obj.children.count do (
			o = obj.children[i]
			if superclassof o == GeometryClass then tso += 1
			tso = getsubnum o tso
		)--end for i
	)--end if
	return tso
)
fn totalsubobj obj = (
	while obj.parent != undefined do obj = obj.parent
	tso = 1
	tso = getsubnum obj tso
	return tso
)
-----------------------------------

global RFpos = [200,200]

fn createVDary obj tso = (

	txt = "rollout SVD \"Set View Distance\" (\n"
	txt += "label lbl1 \"Object: " + obj.name + "\" align:#left\n"
	
	for i = 1 to tso do 
		txt += "spinner VD" + i as string + " \"View Distance " + i as string + " :\" fieldwidth:45 type:#integer range:[0,3000,300] align:#right\n"
	
	txt += "button setVD \"Set View Distance\"\non setVD pressed do (\n"
	txt += "VDary=#()\n"
	for i = 1 to tso do 
	--	txt += "SetUserProp VDobj \"View"  + i as string + "\" VD" + i as string + ".value\n"
		txt += "VDary["  + i as string + "] = VD" + i as string + ".value\n"
	txt += "RFpos = SVDRF.pos\ncloseRolloutFloater SVDRF\n"
	txt += ")\n)\nif SVDRF != undefined then (RFpos = SVDRF.pos; closeRolloutFloater SVDRF)\n"
	txt += "SVDRF = newRolloutFloater \"\" 200 200\naddRollout SVD SVDRF\nSVDRF.pos = RFpos\n"

	if VDary.count == tso then (
		for ii = 1 to tso do 
			txt += "SVD.VD" + ii as string + ".value = VDary[" + ii as string + "]\n"
	)

	execute txt
 --	clearlistener()
 --	format "%\n" txt
)--end fn createVDary

------------------
--Plugin setting--
------------------
fn culleffect obj val = (
	tmp = val
	if tmp >= 32768 then (obj.e16 = true; tmp -= 32768)
	if tmp >= 16384 then (obj.e15 = true; tmp -= 16384)
	if tmp >= 8192 then (obj.e14 = true; tmp -= 8192)
	if tmp >= 4096 then (obj.e13 = true; tmp -= 4096)
	if tmp >= 2048 then (obj.e12 = true; tmp -= 2048)
	if tmp >= 1024 then (obj.e11 = true; tmp -= 1024)
	if tmp >= 512 then (obj.e10 = true; tmp -= 512)
	if tmp >= 256 then (obj.e9 = true; tmp -= 256)
	if tmp >= 128 then (obj.e8 = true; tmp -= 128)
	if tmp >= 64 then (obj.e7 = true; tmp -= 64)
	if tmp >= 32 then (obj.e6 = true; tmp -= 32)
	if tmp >= 16 then (obj.e5 = true; tmp -= 16)
	if tmp >= 8 then (obj.e4 = true; tmp -= 8)
	if tmp >= 4 then (obj.e3 = true; tmp -= 4)
	if tmp >= 2 then (obj.e2 = true; tmp -= 2)
	if tmp == 1 then obj.e1 = true
)
fn NewEnex plength pwidth ppos cpos = (
	tmp = GTAenex length:plength width:pwidth pos:ppos showlinks:true
	ctmp = GTAexit pos:cpos showlinks:true
	ctmp.name = tmp.name + ".exit"
	ctmp.parent = tmp
 --	ctmp.showlinks = true
	ctmp.wirecolor = tmp.wirecolor
 --	tmp.showlinks = true
	return tmp
)
--1--------------
--IPL functions--
-----------------
fn dumpDFF fname = (	
	dffAry = #()
	f = openFile fname			
	ln = readLine f			
	while findstring ln "inst" == undefined do ln = readLine f
	lnctr = 0
	loopend = false
	ln = readline f
	while (ln.count < 3)OR(findstring ln "#" != undefined) do ln = readline f
	if (findstring ln "end" != undefined)AND(ln.count < 10) then loopend = true 

	while loopend == false do (

		lln = ln as stringStream 
		readValue lln
		dffname = readDelimitedString lln ","
		if finditem dffAry dffname == 0 then append dffAry dffname
		lnctr += 1
		ln = readLine f
		while (ln.count < 3)OR(findstring ln "#" != undefined) do ln = readline f
		if (findstring ln "end" != undefined)AND(ln.count < 10) then loopend = true 

	)--end while
	sort dffAry 	
	close f
	return #(lnctr,dffAry)
)--end fn dumpDFF						--<l1>--
--
fn readinst f dffpath VerIdx textype = (
 --Tmp Variable for enable/disable rwLight--
	Norwlight = true

	lnctr = 1
	loopend = false
	ln = readLine f
	while (ln.count < 3)OR(findstring ln "#" != undefined) do ln = readline f
	if (findstring ln "end" != undefined)AND(ln.count < 10) then loopend = true 

	while loopend == false do (
				
		lln = ln as stringStream 
		ID = readValue lln
		dffname = readDelimitedString lln ","
		dfffile  = dffpath + "\\" + dffname + ".dff"
		
		if (VerIdx != 1) then Intr = readValue lln else Intr = undefined
		
		dffpos   = [(readValue lln),(readValue lln),(readValue lln)]
		if (VerIdx != 3) then dffscale = [(readValue lln),(readValue lln),(readValue lln)]
		dffrot   = quat (readValue lln) (readValue lln) (readValue lln) (readValue lln)
		if (VerIdx == 3) then unknown01 = readValue lln
		
		format "line  %\n" 	lnctr
 --		format "ID: %\n" ID 
 --		format "Object: %\n" dfffile
 --		format "Pos: % \n" dffpos
 --		format "Scale: %\n" dffscale
 --		format "Rotation: %\n" dffrot
		lnctr += 1

		if (SelectionSets[dffname] != undefined) AND \
			(SelectionSets[dffname].count != 0) then (
			format "\t\tFound instance!\n\n"
			rootAry = for obj in SelectionSets[dffname] where obj.parent == undefined collect obj	
			rootobj = instance rootAry[1]
			rootobj.rotation = conjugate dffrot
			if (VerIdx != 3) then rootobj.scale = dffscale
			rootobj.pos = dffpos
			rootobj.name = dffname
			setUserProp rootobj "ID" (getUserProp rootAry[1] "ID")
			
			if Intr != undefined then setUserProp rootobj "Interior" Intr
			if (VerIdx == 3) then setUserProp rootobj "unknown01" unknown01

		) else (
			try (
				ff = fopen dfffile "rb"
				if ff != undefined then (
					format "\t\tReading %...\n\n" dfffile
					if textype == 1 then	rootobj = DFFfromMap  ff  ".png"  dffname 
					else 					rootobj = DFFfromMap  ff  ".png"  dffname 
					if rootobj == undefined then format ">>>Error in reading %<<<\n\n" dfffile
					else (
						rootobj.rotation = conjugate dffrot
						if (VerIdx != 3) then rootobj.scale = dffscale
						rootobj.pos = dffpos
						setUserProp rootobj "ID" ID
						
						if Intr != undefined then setUserProp rootobj "Interior" Intr
						if (VerIdx == 3) then setUserProp rootobj "unknown01" unknown01	
						
						rootobj.name = dffname
						
						if Norwlight == true then (
							tary = SelectionSets[dffname]
							for i = tary.count to 1 by -1 do 
								if classof tary[i] == Omnilight then delete tary[i]
						)
						
						gc()
					)
 					fclose ff
				) else ( format "\t\t>>>Can't Find/Open %<<<\n\n" dfffile )	
			) catch ( format "\t\t>>>Can't Find/Open %<<<\n\n" dfffile )
		)--end if/else
		ln = readLine f
		while (ln.count < 3)OR(findstring ln "#" != undefined) do ln = readline f
		if (findstring ln "end" != undefined)AND(ln.count < 10) then loopend = true 

	)--end while
)--end readinst


fn readcull f = (
 --	lnctr = 1
	loopend = false
	ln = readLine f
	while (ln.count < 3)OR(findstring ln "#" != undefined) do ln = readline f
	if (findstring ln "end" != undefined)AND(ln.count < 10) then loopend = true 
	while loopend == false do (
		lln = ln as stringstream
		unknownpos = [(readvalue lln),(readvalue lln),(readvalue lln)]
		cullmin = [(readvalue lln),(readvalue lln),(readvalue lln)]
		cullmax = [(readvalue lln),(readvalue lln),(readvalue lln)]
		zoneprop = readvalue lln
		unknown = readvalue lln
 --		format "Cull  %\t" 	lnctr
 --		format "Zone Min.: %\n" cullmin
 --		format "Zone Max.: %\n" cullmax
 --		format "Effect: %\n" zoneprop
 --		format "Unknown: %\n\n" unknown
		boxsize = cullmax - cullmin
			tmp = GTAcull length:boxsize.y width:boxsize.x height:boxsize.z  xray:on wirecolor:(color 216 218 140) renderable:false
			tmp.center = (cullmax + cullmin) / 2
			culleffect tmp zoneprop
 --		lnctr += 1
		ln = readLine f
		while (ln.count < 3)OR(findstring ln "#" != undefined) do ln = readline f
		if (findstring ln "end" != undefined)AND(ln.count < 10) then loopend = true 
	)--end while
)--end readcull
fn readSAcull f = (
	loopend = false
	ln = readLine f
	while (ln.count < 3)OR(findstring ln "#" != undefined) do ln = readline f
	if (findstring ln "end" != undefined)AND(ln.count < 10) then loopend = true 
	while loopend == false do (
		lln = ln as stringstream
		cullcenter = [(readvalue lln),(readvalue lln),(readvalue lln)]
		z1 = readvalue lln
        culllength = readvalue lln
		cullZmin = readvalue lln
		cullwidth = readvalue lln
		z2 = readvalue lln
		cullZmax = readvalue lln
		zoneprop = readvalue lln
			tmp = GTAcull length:culllength width:cullwidth height:(cullZmax-cullZmin) xray:on wirecolor:(color 216 218 140) renderable:false
			tmp.center = cullcenter
			culleffect tmp zoneprop
		ln = readLine f
		while (ln.count < 3)OR(findstring ln "#" != undefined) do ln = readline f
		if (findstring ln "end" != undefined)AND(ln.count < 10) then loopend = true 		
	)--end while
)--end readSAcull
fn readgrge f = (
	loopend = false
	ln = readLine f
	while (ln.count < 3)OR(findstring ln "#" != undefined) do ln = readline f
	if (findstring ln "end" != undefined)AND(ln.count < 10) then loopend = true 
	while loopend == false do (
		lln = ln as stringstream
		Px1 = readvalue lln
		Py1 = readvalue lln
		Pz1 = readvalue lln
		Px2 = readvalue lln
		Py2 = readvalue lln
		Px3 = readvalue lln
		Py3 = readvalue lln
		Pz3 = readvalue lln

		dx1 = Px2 - Px1
		dy1 = Py2 - Py1
		gwidth = sqrt(dx1 * dx1 + dy1 * dy1)
		dx2 = Px3 - Px1
		dy2 = Py3 - Py1
		glength = sqrt(dx2 * dx2 + dy2 * dy2)
		gheight = Pz3 - Pz1
		centerX = (Px1 + Px2 + Px3 + Px3 + dx1)/4.0
		centerY = (Py1 + Py2 + Py3 + Py3 + dy1)/4.0
		Zrot = asin (dy1/gwidth)
		if dy2 < 0 then Zrot += 180
		else if (dy2 == 0)AND(dx2 > 0) then Zrot += 180
	
		tmp = GTAgrge length:glength width:gwidth height:gheight
		tmp.rotation.z_rotation = zrot
		tmp.pos = [centerX,centerY,Pz1]

		tmp.flag = readvalue lln
		tmp.type = readvalue lln
		
		txt  = filterString ln "-., 1234567890"
		if txt[1] != undefined then tmp.text = txt[1]
		
		ln = readLine f
		while (ln.count < 3)OR(findstring ln "#" != undefined) do ln = readline f
		if (findstring ln "end" != undefined)AND(ln.count < 10) then loopend = true 		
	)--end while
)
fn readenex f = (
	loopend = false
	ln = readLine f
	while (ln.count < 3)OR(findstring ln "#" != undefined) do ln = readline f
	if (findstring ln "end" != undefined)AND(ln.count < 10) then loopend = true 
	while loopend == false do (
		lln = ln as stringstream
		ppos = [(readvalue lln),(readvalue lln),(readvalue lln)]
 --	--	prot = readvalue lln
		prot = mod (radToDeg (readvalue lln)) 360
		pwidth = (readvalue lln) * 2.0
		plength = (readvalue lln) * 2.0
		c8 = readvalue lln
		cpos = [(readvalue lln),(readvalue lln),(readvalue lln)]
 --	--	crot = readvalue lln
		crot = mod (readvalue lln) 360
		max select none
			local obj = NewEnex plength pwidth ppos cpos
			select obj
			obj.angle = prot
			obj.facing = crot
			obj.rotation.z_rotation = prot
			obj.int1 = readvalue lln
			obj.int2 = readvalue lln
			tt = filterstring (readDelimitedString lln ",") "\""
			if tt[1] != undefined then obj.text = tt[1]
			obj.I1 = readvalue lln
			obj.I2 = readvalue lln
			obj.time_on = readvalue lln
			obj.time_off = readvalue lln
		max select none
		ln = readLine f
		while (ln.count < 3)OR(findstring ln "#" != undefined) do ln = readline f
		if (findstring ln "end" != undefined)AND(ln.count < 10) then loopend = true 		
	)--end while
)
fn readpick f = (
	loopend = false
	ln = readLine f
	while (ln.count < 3)OR(findstring ln "#" != undefined) do ln = readline f
	if (findstring ln "end" != undefined)AND(ln.count < 10) then loopend = true 
	while loopend == false do (
		lln = ln as stringstream
		tmp = GTApick item:(readvalue lln) 
		tmp.pos=[(readvalue lln),(readvalue lln),(readvalue lln)]
		ln = readLine f
		while (ln.count < 3)OR(findstring ln "#" != undefined) do ln = readline f
		if (findstring ln "end" != undefined)AND(ln.count < 10) then loopend = true 		
	)--end while
)
fn readcars f = (
	loopend = false
	ln = readLine f
	while (ln.count < 3)OR(findstring ln "#" != undefined) do ln = readline f
	if (findstring ln "end" != undefined)AND(ln.count < 10) then loopend = true 
	while loopend == false do (
		lln = ln as stringstream
		max select none
			tmp = GTAcars pos:[(readvalue lln),(readvalue lln),(readvalue lln)]
			select tmp 
			tmp.angle = readvalue lln
			tmp.id = readvalue lln
			tmp.color1 = readvalue lln
			tmp.color2 = readvalue lln
			tmp.u1 = readvalue lln
			tmp.alarm = readvalue lln
			tmp.doorlock = readvalue lln
			tmp.u2 = readvalue lln
			tmp.u3 = readvalue lln
		max select none
		ln = readLine f
		while (ln.count < 3)OR(findstring ln "#" != undefined) do ln = readline f
		if (findstring ln "end" != undefined)AND(ln.count < 10) then loopend = true 		
	)--end while
)
fn readauzo f = (
	loopend = false
	ln = readLine f
	while (ln.count < 3)OR(findstring ln "#" != undefined) do ln = readline f
	if (findstring ln "end" != undefined)AND(ln.count < 10) then loopend = true 
	while loopend == false do (
		lln = ln as stringstream
		tt = filterString ln "-., 1234567890"
		readDelimitedString lln ","
		ukn1 = readvalue lln
		ukn2 = readvalue lln
		p1 = [(readvalue lln),(readvalue lln),(readvalue lln)]
		p2 = [(readvalue lln),(readvalue lln),(readvalue lln)]
		tmp = GTAauzo length:(abs(p2.y-p1.y)) width:(abs(p2.x-p1.x)) height:(abs(p2.z-p1.z))
		tmp.pos = [((p2.x+p1.x)/2),((p2.y+p1.y)/2),p1.z]
		tmp.u1 = ukn1
		tmp.u2 = ukn2
		if tt[1] != undefined then tmp.text = tt[1]
		ln = readLine f
		while (ln.count < 3)OR(findstring ln "#" != undefined) do ln = readline f
		if (findstring ln "end" != undefined)AND(ln.count < 10) then loopend = true 		
	)--end while
)
fn readjump f = (
	loopend = false
	ln = readLine f
	while (ln.count < 3)OR(findstring ln "#" != undefined) do ln = readline f
	if (findstring ln "end" != undefined)AND(ln.count < 10) then loopend = true 
	while loopend == false do (
		lln = ln as stringstream

		jpos = [(readvalue lln),(readvalue lln),(readvalue lln)]
		w1 = (readvalue lln) * 2.0
		l1 = (readvalue lln) * 2.0
		h1 = (readvalue lln) * 2.0
		jmp = GTAjump width:w1 length:l1 height:h1 showlinks:true
        jmp.pos = jpos
		lpos = [(readvalue lln),(readvalue lln),(readvalue lln)]
		w2 = (readvalue lln) * 2.0
		l2 = (readvalue lln) * 2.0
		h2 = (readvalue lln) * 2.0
		lnd = GTAland width:w2 length:l2 height:h2 showlinks:true
		lnd.pos = lpos
		cam = GTAjcam pos:[(readvalue lln),(readvalue lln),(readvalue lln)]
		lnd.reward = readvalue lln
		cam.target = lnd
		cam.name = lnd.name + ".camrea"
		cam.wirecolor = lnd.wirecolor
		jmp.parent = lnd
		jmp.name = lnd.name + ".start"
		jmp.wirecolor = lnd.wirecolor
		jd = dummy boxsize:[w1,w1,w1] pos:lnd.pos
		jd.name = lnd.name + ".dummy"
		lnd.parent = jd		
		cam.parent = jd
		
		ln = readLine f
		while (ln.count < 3)OR(findstring ln "#" != undefined) do ln = readline f
		if (findstring ln "end" != undefined)AND(ln.count < 10) then loopend = true 		
	)--end while
)


fn ReadIPL iplname dffpath VerIdx textype = (

	f = openFile iplname			

	while not (eof f) do (
		ln = readLine f
 format ">%\n" ln	
		if findstring ln "#" != undefined then ()
		else if findstring ln "inst" != undefined then readinst f dffpath VerIdx textype
        else if findstring ln "cull" != undefined then (
			if VerIdx != 3 then readcull f
			else readSAcull f
		)
		else if findstring ln "grge" != undefined then readgrge f
		else if findstring ln "enex" != undefined then readenex f
		else if findstring ln "pick" != undefined then readpick f
		else if findstring ln "cars" != undefined then readcars f
		else if findstring ln "auzo" != undefined then readauzo f
		else if findstring ln "jump" != undefined then readjump f
	)--end while eof

	
	close f
)--end fn ReadIPL						--<l2>--


fn WriteInst f AllObjects verTxt = (
	AllRoots = for obj in Allobjects where (obj.parent == undefined) AND \
		(Classof obj != GTAcull)AND(Classof obj != GTAgrge)AND \
		(Classof obj != GTAenex)AND(Classof obj != GTAexit)AND \
		(Classof obj != GTApick)AND(Classof obj != GTAcars)AND \
		(Classof obj != GTAauzo)AND(Classof obj != GTAjump)AND \
		(Classof obj != GTAland)AND(Classof obj != GTAjcam)	AND \
		((findstring obj.name ".dummy") == undefined) collect obj
	for obj in AllRoots do (
		ID = getUserProp obj "ID"
		if ID == undefined then (
			txt = "object:   " + obj.name + "   doesn't have ID\nPlease set it and export again!"
			messagebox txt title:"Can't Export"
			return undefined
		)
		Crot = conjugate obj.rotation 
		format "%, %, " ID obj.name								to:f
		if verTxt != 1 then (
			interiorID = getUserProp obj "Interior"
			if interiorID == undefined then interiorID = 0
			format "%, " interiorID								to:f
		)
		format "%, %, %, " obj.pos.x obj.pos.y obj.pos.z		to:f
		if verTxt != 3 then format "%, %, %, " obj.scale.x obj.scale.y obj.scale.z	to:f
		format "%, %, %, %" Crot.x Crot.y Crot.z Crot.w			to:f
		if verTxt == 3 then (
			unknown01 == getUserProp obj "unknown01"
			if unknown01 == undefined then unknown01 = -1
			format ", %" unknown01								to:f
		)
		format "\n"												to:f
	)--end for

	return f

)--end fn WriteIPL						--<l3>--

fn WriteCull f Allobjects verTxt = (
	AllRoots = for obj in Allobjects where (Classof obj == GTAcull) collect obj
    if verTxt != 3 then (
		for obj in AllRoots do (
			format "%, %, %, " obj.center.x obj.center.y obj.center.z	to:f
			format "%, %, %, " obj.min.x obj.min.y obj.min.z			to:f	
			format "%, %, %, " obj.max.x obj.max.y obj.max.z			to:f
			format "%, 0\n" obj.effect											to:f
		)--end for
	) else (
		for obj in AllRoots do (
			format "%, %, %, 0, " obj.center.x obj.center.y obj.center.z	to:f
			format "%, %, %, 0, " obj.length obj.min.z obj.width 	to:f
			format "%, %\n" obj.max.z obj.effect									to:f
		)
	)
	return f
)--end fn WriteCull						--<l4>--
fn WriteGrge f Allobjects = (
	AllRoots = for obj in Allobjects where (Classof obj == GTAgrge) collect obj
	for obj in AllRoots do (
		tmp = snapshot obj
		p1 = tmp.verts[1].pos
		p2 = tmp.verts[2].pos
		p3 = tmp.verts[3].pos
		format "%, %, %, " p1.x p1.y p1.z						to:f
		format "%, %, " p2.x p2.y 								to:f
		format "%, %, %, " p3.x p3.y p3.z						to:f
		format "%, %, %\n" obj.flag obj.type obj.text			to:f
		delete tmp
	)
	return f
)--end
fn WriteEnex f Allobjects = (
	AllRoots = for obj in Allobjects where (Classof obj == GTAenex) collect obj
	for obj in AllRoots do (
		if classof obj.children[1] == GTAexit then (
			format "%, %, %, " obj.pos.x obj.pos.y obj.pos.z											to:f
			format "%, %, %, " (degTorad obj.rotation.z_rotation) (obj.width/2.0) (obj.length/2.0)			to:f
			format "8, %, %, %, " obj.children[1].pos.x obj.children[1].pos.y obj.children[1].pos.z		to:f
			format "%, %, %, " obj.children[1].rotation.z_rotation obj.int1 obj.int2					to:f
			format "\"%\", %, %, " obj.text obj.I1 obj.I2												to:f
			format "%, %\n" obj.time_on obj.time_off													to:f
		)
	)
	return f
)--end 
fn WritePick f Allobjects = (
	AllRoots = for obj in Allobjects where (Classof obj == GTApick) collect obj
	for obj in AllRoots do (
		format "%, %, %, %\n" obj.item obj.pos.x obj.pos.y obj.pos.z						to:f
	)
	return f
)--end 
fn WriteCars f Allobjects = (
	AllRoots = for obj in Allobjects where (Classof obj == GTAcars) collect obj
	for obj in AllRoots do (
		format "%, %, %, %, " obj.pos.x obj.pos.y obj.pos.z obj.rotation.z_rotation		to:f
		format "%, %, %, %, " obj.id obj.color1 obj.color2 obj.u1						to:f
		format "%, %, %, %\n" obj.alarm obj.doorlock obj.u2 obj.u3						to:f
	)
	return f
)--end 
fn WriteAuzo f Allobjects = (
	AllRoots = for obj in Allobjects where (Classof obj == GTAauzo) collect obj
	for obj in AllRoots do (
		format "%, %, %, " obj.text obj.u1 obj.u2						to:f
		format "%, %, %, " obj.min.x obj.min.y obj.min.z				to:f
		format "%, %, %\n" obj.max.x obj.max.y obj.max.z				to:f
	)
	return f
)--end
fn WriteJump f Allobjects = (
	AllRoots = for obj in Allobjects where (Classof obj == GTAland) collect obj
	AllJCam = for obj in Allobjects where (Classof obj == GTAjcam) collect obj
	for obj in AllRoots do (
		jcam = for cam in AllJCam where cam.target == obj collect cam
		if (classof obj.children[1] == GTAjump)AND(jcam[1] != undefined) then (
			format "%, %, %, " obj.children[1].pos.x obj.children[1].pos.y obj.children[1].pos.z						to:f
			format "%, %, %, " (obj.children[1].width/2.0) (obj.children[1].length/2.0) (obj.children[1].height/2.0)	to:f
			format "%, %, %, " obj.pos.x obj.pos.y obj.pos.z															to:f
			format "%, %, %, " (obj.width/2.0) (obj.length/2.0) (obj.height/2.0)										to:f
			format "%, %, %, "  jcam[1].pos.x jcam[1].pos.y jcam[1].pos.z												to:f
			format "%\n" obj.reward																						to:f
		)
	)
	return f
)--end 
--<4>--


--2--------------
--IDE functions--
-----------------
fn rIDEobjs_old f isTimeObj = (
	loopend = false
	ln = readline f
	while (ln.count < 3)OR(findstring ln "#" != undefined) do ln = readline f
	if (findstring ln "end" != undefined)AND(ln.count < 10) then loopend = true 

	while loopend == false do (

		lln = ln as stringStream
		ID = readValue lln
		DFFName = readDelimitedString lln ","
		TXDname = readDelimitedString lln ","
		subobj_count = readvalue lln
		if subobj_count == 1 then viewDist = readvalue lln
		else (
			viewDist = #()
			for i = 1 to subobj_count do ( viewDist[i] = readvalue lln )
		)--end if/else
		rendEff = readvalue lln
		if isTimeObj == true then (
			ton = readvalue lln
			toff = readvalue lln
		)--end if isTimeObj
		
		for obj in geometry where obj.name == DFFName do (
			setUserProp obj "ID" ID
			setUserProp obj "TXD" TXDname
			setUserProp obj "SubObj" subobj_count
			if subobj_count == 1 then setUserProp obj "View" viewDist
			else (
				for i = 1 to subobj_count do (
					keytxt = "View" + (i as string)
					setUserProp obj keytxt viewDist[i]
				)--end for i
			)--end if/else
			setUserProp obj "RenderEffect" rendEff
			if isTimeObj == true then (	
				setUserProp obj "TimeOn" ton
				setUserProp obj "TimeOff" toff
			)--end if isTimeObj		
		)--end for obj
		ln = readline f
		while (ln.count < 3)OR(findstring ln "#" != undefined) do ln = readline f
		if (findstring ln "end" != undefined)AND(ln.count < 10) then loopend = true 
	)--end while
)--fn rIDEobjs_old
fn rIDEobjs f isTimeObj verTxt = (
	loopend = false
	ln = readline f
	while (ln.count < 3)OR(findstring ln "#" != undefined) do ln = readline f
	if (findstring ln "end" != undefined)AND(ln.count < 10) then loopend = true 

	while loopend == false do (
	
		lln = ln as stringStream

		upb = "ID = " + (readValue lln) as string									--ID
		DFFName = readDelimitedString lln ","							--DFF
		upb += "\nTXD = " + (readDelimitedString lln ",")					--TXD
		if verTxt != 3 then (
			subobj_count = readvalue lln									--subObj
		) else subobj_count = 1
			upb += "\nSubObj=" + subobj_count as string

		if subobj_count == 1 then 
			upb += "\nView=" + (readvalue lln) as string			--ViewDistance
		else (
			for i = 1 to subobj_count do
				upb += "\nView" + i as string + "=" \
					+ (readvalue lln) as string
		)
		upb += "\nRenderEffect=" + (readvalue lln) as string		--RenderEffect
		if isTimeObj == true then (
			upb += "\nTimeOn" + (readvalue lln) as string
			upb += "\nTimeOff" + (readvalue lln) as string
		)--end if isTimeObj
		upb += "\n"
 --format "%\n" upb		

		for o in geometry where o.name == DFFName do (
			intr = getUserProp o "Interior"
 --format "%:%\n" DFFName intr
			setUserPropBuffer o upb
			if intr != undefined then setUserProp o "Interior" intr
		)
		ln = readline f
		while (ln.count < 3)OR(findstring ln "#" != undefined) do ln = readline f
		if (findstring ln "end" != undefined)AND(ln.count < 10) then loopend = true 
	)--end while
)--fn rIDEobjs							--<e1>--


fn rIDE2dfx f fxsize = (
	loopend = false
	ln = readline f
	while (ln.count < 3)OR(findstring ln "#" != undefined) do ln = readline f
	if (findstring ln "end" != undefined)AND(ln.count < 10) then loopend = true 

 	subID = 0.00011
	while loopend == false do (

		lln = ln as stringStream
		ID = readValue lln

		PAry = for o in geometry where ( getUserProp o "ID" ) == ID collect o
		if PAry.count > 0 then (
			fx2dpos = [(readValue lln), (readValue lln), (readValue lln)]
			fx2dCol = color (readValue lln) (readValue lln) (readValue lln)

			IDtxt = (subID as string)
			IDtxt = substring IDtxt 3 4
			subID += 0.0001

			upb = "ID=" + (ID as string) + "-" + IDtxt
			upb += "\nunkn1=" + (readValue lln) as string
			
			fx2dtype =  readValue lln
            case fx2dtype of (
				0: (				--lights--
					fx2d = Donut radius1:fxsize radius2:(fxsize * 0.5) --transform:(matrix3 [1,0,0] [0,0,1] [0,-1,0] [0,0,0])
					fx2d.name = "2dfx_light" + IDtxt
					upb += "\nt1=" 			+ readDelimitedString lln ","			--coronastar
					upb += "\nt2=" 			+ readDelimitedString lln ","			--shad_exp
					upb += "\nView=" 		+ (readValue lln) as string				--ViewDistance
					upb += "\nOutRange="	+ (readValue lln) as string				--Outter Range
					upb += "\nLampSize="	+ (readValue lln) as string				--Lamp Size
					upb += "\nInRange="		+ (readValue lln) as string				--Inner Range
					upb += "\nCorona="		+ (readValue lln) as string				--Corona Size
					upb += "\nControl="		+ (readValue lln) as string				--Control
					upb += "\nReflection="	+ (readValue lln) as string				--Reflection  on wet roads
					upb += "\nLensFlare="	+ (readValue lln) as string				--LensFlare
					upb += "\nDust="		+ (readValue lln) as string				--Dust
				)
				1: (				--Particles--
					fx2d = Text size:(fxsize * 5) --transform:(matrix3 [1,0,0] [0,0,1] [0,-1,0] [0,0,0])
					fx2d.text = "P"
					fx2d.name = "2dfx_Particle" + IDtxt
					upb += "\nType="	+ (readValue lln) as string				--Particles Type
					upb += "\nunknP1="	+ (readValue lln) as string				--Unknown 1
					upb += "\nunknP2="	+ (readValue lln) as string				--Unknown 2
					upb += "\nunknP3="	+ (readValue lln) as string				--Unknown 3
					upb += "\nSize="	+ (readValue lln) as string				--Size
				)
				2: (				--Unknown--
					fx2d = Text size:(fxsize * 5) --transform:(matrix3 [1,0,0] [0,0,1] [0,-1,0] [0,0,0])
					fx2d.text = "U"
					fx2d.name = "2dfx_unknown" + IDtxt
					upb += "\nType="	+ (readValue lln) as string				--Particles Type
					upb += "\nunknP1="	+ (readValue lln) as string				--Unknown 1
					upb += "\nunknP2="	+ (readValue lln) as string				--Unknown 2
					upb += "\nunknP3="	+ (readValue lln) as string				--Unknown 3
					upb += "\nSize="	+ (readValue lln) as string				--Size
				)
				3: (				--Ped Animation Areas--
					fx2d = Rectangle length:(fxsize * 2) width:(fxsize * 2) --transform:(matrix3 [1,0,0] [0,0,1] [0,-1,0] [0,0,0])
					fx2d.name = "2dfx_PedArea" + IDtxt
					upb += "\nAnimation="		+ (readValue lln) as string			--Type of Animation
					p1 = [( readValue lln), ( readValue lln), ( readValue lln)]
					p2 = [( readValue lln), ( readValue lln), ( readValue lln)]
					upb += "\nPos1="			+ p1 as string						--?? point of bounding area
					upb += "\nPos2="			+ p2 as string						--?? point of bounding area
				)
				4: (				--sunreflections--
					fx2d.name = "2dfx_sunreflection" + IDtxt
					fx2d = Star radius1:fxsize radius2:(fxsize * 0.5) --transform:(matrix3 [1,0,0] [0,0,1] [0,-1,0] [0,0,0])
				)
			)--end case
            
			fx2d.wirecolor = fx2dCol
			setUserPropBuffer fx2d upb
			fx2d.parent = PAry[1]
			in coordsys parent fx2d.pos = fx2dpos
			for i = 2 to PAry.count do (
				ifx = instance fx2d
				ifx.wirecolor = fx2dCol
				ifx.name = fx2d.name
				setUserPropBuffer ifx upb
				ifx.parent = PAry[i]
				in coordsys parent ifx.pos = fx2dpos				
			)--end for i

		)--end PAry

		ln = readline f
		while (ln.count < 3)OR(findstring ln "#" != undefined) do ln = readline f
		if (findstring ln "end" != undefined)AND(ln.count < 10) then loopend = true 
	)--end while
)--end fn rIDE2dfx							--<e2>--


fn ReadIDE fname verTxt fx fxsize = (
	f = openfile fname
	clearlistener()
	while not (EOF f) do (
		ln = readLine f
		if findstring ln "objs" != undefined then rIDEobjs f false verTxt
		else
		if findstring ln "tobj" != undefined then rIDEobjs f true verTxt
	--	else
		if (findstring ln "2dfx" != undefined)AND(fx == true) then rIDE2dfx f fxsize
	--	format "count: %\t%\n" ln.count ln
	)
	close f
)--end fn ReadIDE						--<e3>--


fn write2dfx shapeAry = (
	OutAry = #()
	txt = "2dfx\n"
	for s in shapeAry do (
		IDtxt = getUserProp s "ID"
		if IDtxt == undefined then (
			messagebox "Unknown Properties in 2dfx shape!\nPlease set it and export again!" title:"Can't Export"
			select s
			return undefined
		)--end if IDtxt
		subID = (substring IDtxt (IDtxt.count-3) 4) as integer
		if finditem OutAry subID == 0 then (
			append OutAry subID
			txt += substring IDtxt 1 (IDtxt.count-5) + ", "
			in coordsys parent (
				txt += s.pos.x as string + ", "
				txt += s.pos.y as string + ", "
				txt += s.pos.z as string + ", "
			)
			txt += (s.wirecolor.r as integer) as string + ", " 	
			txt += (s.wirecolor.g as integer) as string + ", "
			txt += (s.wirecolor.b as integer) as string + ", "
			txt += (getUserProp s "unkn1") as string + ", "
			
			if classof s == Donut then (
				txt += "0, "
				txt += (getUserProp s "t1") + ", "
				txt += (getUserProp s "t2") + ", "
				txt += (getUserProp s "View") as string + ", "
				txt += (getUserProp s "OutRange") as string + ", "
				txt += (getUserProp s "LampSize") as string + ", "
				txt += (getUserProp s "InRange") as string + ", "
				txt += (getUserProp s "Corona") as string + ", "
				txt += (getUserProp s "Control") as string + ", "
				txt += (getUserProp s "Reflection") as string + ", "
				txt += (getUserProp s "LensFlare") as string + ", "
				txt += (getUserProp s "Dust") as string + "\n"
			)
			if (classof s == text) then (
				if s.text = "P"then txt += "1, "
				else txt += "2, "
				txt += (getUserProp s "Type")  as string + ", "
				txt += (getUserProp s "unknP1") as string + ", "
				txt += (getUserProp s "unknP2") as string + ", "
				txt += (getUserProp s "unknP3") as string + ", "
				txt += (getUserProp s "Size")  as string + "\n"				
			)
			if classof s == Rectangle then (
				txt += "3, "
				Pos1 = getUserProp s "Pos1"
				txt += (Pos1.x) as string + ", "
				txt += (Pos1.y) as string + ", "
				txt += (Pos1.z) as string + ", "
				Pos2 = getUserProp s "Pos2"
				txt += (Pos2.x) as string + ", "
				txt += (Pos2.y) as string + ", "
				txt += (Pos2.z) as string + "\n"	
			)
			if classof s == Star then (
				txt += "4\n"
			)
		)--end if finditem
	)--end for s

    txt += "end\n"
    
	return txt

)--end fn write2dfx						--<e4>--


fn WriteIDE f AllObjects verTxt = (
	AllRoots = for obj in Allobjects where (obj.parent == undefined) AND \
		(Classof obj != GTAcull)AND(Classof obj != GTAgrge)AND \
		(Classof obj != GTAenex)AND(Classof obj != GTAexit)AND \
		(Classof obj != GTApick)AND(Classof obj != GTAcars)AND \
		(Classof obj != GTAauzo)AND(Classof obj != GTAjump)AND \
		(Classof obj != GTAland)AND(Classof obj != GTAjcam)	AND \
		((findstring obj.name ".dummy") == undefined) collect obj


	OutAry = #()	-- Objs
	OutTAry = #()	-- Tobj
	OutAAry = #()	-- Anim
	TXDPAry = #()	-- Txdp

	format "objs\n"																to:f
	for obj in AllRoots do (
		if (finditem OutAry obj.name == 0)AND(finditem OutTAry obj.name == 0)AND \
			(finditem OutAAry obj.name == 0) then (

			ton=getUserProp obj "TimeOn"
			toff=getUserProp obj "TimeOff"
			Anm = getUserProp obj "Anim"
			if (ton != undefined)AND(toff != undefined) then append OutTAry obj.name
			else if (Anm != undefined)AND(verTxt == 3) then append OutAAry obj.name
			else (
				append OutAry obj.name
				ID = getUserProp obj "ID"
				TXD = getUserProp obj "TXD"
				if (ID == undefined)OR(TXD == undefined) then (
					txt = "object:   " + obj.name + "   doesn't have ID or TXD\nPlease set it and export again!"
					messagebox txt title:"Can't Export"
					return undefined
				)--end if ID & TXD

				txdp = getUserProp obj "TXDP"
				if txdp != undefined then (
					ta = #(TXD, txdp)
					if finditem TXDPAry ta == 0 then append TXDPAry ta
				)

				format "%, %, %, " ID obj.name TXD								to:f

				if verTxt != 3 then (
					SB = totalsubobj obj
					format "%, " SB												to:f
				) else SB = 1
				if SB == 1 then (
					VD = getUserProp obj "View"
					if VD == undefined then format "300, "						to:f
					else format "%, " VD										to:f
				) else (
					for jj = 1 to SB do (
						txt = "VD = getUserProp obj \"View" + jj as string + "\" \n"
						execute txt
						if VD == undefined then format "300, "					to:f
						else format "%, " VD									to:f
					)--end for jj
				)--end if/else SB

				RE = getUserProp obj "RenderEffect"
				if RE == undefined then format "0\n"							to:f
				else format "%\n" RE											to:f

			)--end if/else timeobject

		)--end if OutAry
	)--end for obj

	format "end\ntobj\n"														to:f

	if OutTAry.count != 0 then (
		for j = 1 to OutTAry.count do (
			k = 1
			while AllRoots[k].name != OutTAry[j] do k +=1
			obj = AllRoots[k]

			ID = getUserProp obj "ID"
			TXD = getUserProp obj "TXD"
			if (ID == undefined)OR(TXD == undefined) then (
				txt = "TimeObject:   " + obj.name + "   doesn't have ID or TXD\nPlease set it and export again!"
				messagebox txt title:"Can't Export"
				return undefined
			)

				txdp = getUserProp obj "TXDP"
				if txdp != undefined then (
					ta = #(TXD, txdp)
					if finditem TXDPAry ta == 0 then append TXDPAry ta
				)

			format "%, %, %, " ID obj.name TXD									to:f

				if verTxt != 3 then (
					SB = totalsubobj obj
					format "%, " SB												to:f
				) else SB = 1
				if SB == 1 then (
					VD = getUserProp obj "View"
					if VD == undefined then format "300, "						to:f
					else format "%, " VD										to:f
				) else (
					for jj = 1 to SB do (
						txt = "VD = getUserProp obj \"View" + jj as string + "\" \n"
						execute txt
						if VD == undefined then format "300, "					to:f
						else format "%, " VD									to:f
					)--end for jj
				)--end if/else SB

			RE = getUserProp obj "RenderEffect"
			if RE == undefined then format "0, "								to:f
			else format "%, " RE												to:f

			format "%, %\n" (getUserProp obj "TimeOn") \
				 (getUserProp obj "TimeOff")									to:f

		)--end for j

	)--end if OutTAry

	format "end\n"																to:f
	format "path\nend\n"														to:f

	ShapeAry = for s in AllObjects where superclassof s == shape collect s
	if ShapeAry.count != 0 then fxtxt = write2dfx ShapeAry
 	else    fxtxt = "2dfx\nend\n"
	format "%" fxtxt															to:f

	if verTxt == 3 then (
		format "anim\n"															to:f
		if OutAAry.count != 0 then (
			for j = 1 to OutAAry.count do (
				k = 1
				while AllRoots[k].name != OutAAry[j] do k +=1
				obj = AllRoots[k]

				ID = getUserProp obj "ID"
				TXD = getUserProp obj "TXD"
				if (ID == undefined)OR(TXD == undefined) then (
					txt = "AnimObject:   " + obj.name + "   doesn't have ID or TXD\nPlease set it and export again!"
					messagebox txt title:"Can't Export"
					return undefined
				)

				txdp = getUserProp obj "TXDP"
				if txdp != undefined then (
					ta = #(TXD, txdp)
					if finditem TXDPAry ta == 0 then append TXDPAry ta
				)

				format "%, %, %, " ID obj.name TXD									to:f
				format "%, " (getfilenamefile (getUserProp obj "Anim"))		to:f

				VD = getUserProp obj "View"
				if VD == undefined then format "300, "						to:f
				else format "%, " VD										to:f 

				RE = getUserProp obj "RenderEffect"
				if RE == undefined then format "0, "								to:f
				else format "%\n" RE												to:f
			)
		)
		format "end\n"															to:f
		if TXDPAry.count  > 0 then (
			format "txdp\n"														to:f
			for i = 1 to TXDPAry.count do 
				format "%, %\n" TXDPAry[i][1] TXDPAry[i][2]						to:f
			format "txdp\nend\n"												to:f
		) else format "txdp\nend\n"												to:f
	)
	
	return f
)--end fn WriteIDE						--<e4>--






fn CheckTXD txdpath ListMissing = (
			clearlistener()
			TXDAry = #()
			NoPropAry = #()
			for obj in geometry where (obj.parent == undefined)AND(Classof obj != Box) do (
				txd = getUserProp obj "TXD"
--format "txd: %\n" txd
				if txd == undefined then (
					if finditem NoPropAry obj.name == 0 then (
						append NoPropAry obj.name
						format "% has no TXD properities\n" obj.name
					)
				)
				else 	if finditem TXDAry txd == 0 then append TXDAry txd
			)
--format "TXDAry:%\n" TXDAry 

			if ListMissing == true then (

				tmp = getFiles ( txdpath + "\\*.txd" )
				flist = for d in tmp collect (getFilenameFile d)
--format "flist: %\n" flist
				format "\nMissing TXD:\n\n"
				for txd in TXDAry do 	if finditem flist txd == 0 then format "%\n" txd
				format "\nDONE!!\n"
			) else (
				format "\nTXD needed: %\n\n" TXDAry.count
				for txd in TXDAry do format "%\n" txd
				format "\nDONE!!\n"
			)
)--end on CheckTXD						--<e5>--


--end 									--<4>--


--3--------------
--ZON functions--
-----------------
fn ReadZon fname = (
	f = openfile fname
	clearlistener()  	ln = readLine f
	while findstring ln "zone" == undefined do ln = readLine f

	loopend = false
	ln = readline f
	while (ln.count < 3)OR(findstring ln "#" != undefined) do ln = readline f
	if (findstring ln "end" != undefined)AND(ln.count < 10) then loopend = true 

	while loopend == false do (

		lln = ln as stringStream
		ZoneName = readDelimitedString lln ","
		ZoneType = readvalue lln
		ZoneMin = [(readValue lln),(readValue lln),(readValue lln)]
		ZoneMax = [(readValue lln),(readValue lln),(readValue lln)]
		IslandID = readvalue lln
	
		boxsize = ZoneMax - ZoneMin
		tmp = box length:boxsize.y width:boxsize.x height:boxsize.z xray:on wirecolor:(color 255 255 0) renderable:false
		tmp.name = ZoneName
		setUserProp tmp "Zone" true
		setUserProp tmp "Type" ZoneType		
		setUserProp tmp "IslandID" IslandID	
		
		ln = readline f
		while (ln.count < 3)OR(findstring ln "#" != undefined) do ln = readline f
		if (findstring ln "end" != undefined)AND(ln.count < 10) then loopend = true 
	)--end while
	close f
)--end fn ReadZon						--<n1>--

fn WriteZon f Allobjects verTxt = (
	ZoneAry = for obj in Allobjects where (getUserProp obj "Zone" == true) collect obj
	if ZoneAry.count > 0 then (
	 	format "zone\n"														to:f
		for obj in ZoneAry do (
			zonetype = getUserProp obj "Type"
			if zonetype == undefined then zonetype = 0
			format "%, %, " obj.name zonetype								to:f
			format "%, %, %, " obj.min.x obj.min.y obj.min.z				to:f
			format "%, %, %, " obj.max.x obj.max.y obj.max.z				to:f
			if verTxt == 2 then islandID = 1
			else (
				islandID = getUserProp obj "IslandID"
				if islandID == undefined then zonetype = 1
			)
			format "%\n" islandID											to:f
		)
		format "end\n"														to:f
	)
	return f
)--end fn ReadZon

--end 									--<1>--


------------
--2dfx fns--
------------
fn select2dfx s Roll2dfx = (
	if classof s == Donut then (
		Roll2dfx.spVD.enabled 		= true	
		Roll2dfx.spLS.enabled 		= true
		Roll2dfx.spOutR.enabled 	= true
		Roll2dfx.spInR.enabled 		= true
		Roll2dfx.spCS.enabled 		= true
		Roll2dfx.spRf.enabled 		= true
		Roll2dfx.spLF.enabled 		= true
		Roll2dfx.spDust.enabled 	= true
		Roll2dfx.lgtcolor.enabled 	= true
		Roll2dfx.dlcontrol.enabled 	= true
		
		Roll2dfx.parcolor.enabled	= false
		Roll2dfx.dlpar.enabled		= false
		Roll2dfx.spPsize.enabled	= false	
		Roll2dfx.spukn1.enabled		= false
		Roll2dfx.spukn2.enabled		= false
		Roll2dfx.spukn3.enabled		= false	

		Roll2dfx.pedcolor.enabled	= false	
		Roll2dfx.pedanim.enabled	= false
		Roll2dfx.spdir1x.enabled	= false	
		Roll2dfx.spdir1y.enabled	= false	
		Roll2dfx.spdir1z.enabled	= false	
		Roll2dfx.spdir2x.enabled	= false	
		Roll2dfx.spdir2y.enabled	= false	
		Roll2dfx.spdir2z.enabled	= false	

		Roll2dfx.sfcolor.enabled	= false	

		try (
			Roll2dfx.lgtcolor.color		= s.wirecolor
			Roll2dfx.spVD.value		= getUserProp s "View"	
			Roll2dfx.spLS.value 	= getUserProp s "LampSize"
			Roll2dfx.spOutR.value	= getUserProp s "OutRange"
			Roll2dfx.spInR.value	= getUserProp s "InRange"
			Roll2dfx.spCS.value		= getUserProp s "Corona"
			Roll2dfx.spRf.value 	= getUserProp s "Reflection"
			Roll2dfx.spLF.value 	= getUserProp s "LensFlare"
			Roll2dfx.spDust.value 	= getUserProp s "Dust"
			Roll2dfx.dlcontrol.selection= (getUserProp s "Control") + 1
			return true
		) catch (return false)
	
	)--end Donut

	if classof s == Text then (
		if (s.text == "P")OR(s.text == "U") then (
		
		Roll2dfx.spVD.enabled 		= false	
		Roll2dfx.spLS.enabled 		= false
		Roll2dfx.spOutR.enabled 	= false
		Roll2dfx.spInR.enabled 		= false
		Roll2dfx.spCS.enabled 		= false
		Roll2dfx.spRf.enabled 		= false
		Roll2dfx.spLF.enabled 		= false
		Roll2dfx.spDust.enabled 	= false
		Roll2dfx.lgtcolor.enabled 	= false
		Roll2dfx.dlcontrol.enabled 	= false
		
		Roll2dfx.parcolor.enabled	= true
		Roll2dfx.dlpar.enabled		= true
		Roll2dfx.spPsize.enabled	= true	
		Roll2dfx.spukn1.enabled		= true
		Roll2dfx.spukn2.enabled		= true
		Roll2dfx.spukn3.enabled		= true	

		Roll2dfx.pedcolor.enabled	= false	
		Roll2dfx.pedanim.enabled	= false
		Roll2dfx.spdir1x.enabled	= false	
		Roll2dfx.spdir1y.enabled	= false	
		Roll2dfx.spdir1z.enabled	= false	
		Roll2dfx.spdir2x.enabled	= false	
		Roll2dfx.spdir2y.enabled	= false	
		Roll2dfx.spdir2z.enabled	= false	

		Roll2dfx.sfcolor.enabled	= false	

		try (
			Roll2dfx.parcolor.color	= s.wirecolor
			Roll2dfx.spPsize.value	= getUserProp s "Size"	
			Roll2dfx.spukn1.value 	= getUserProp s "unknP1"
			Roll2dfx.spukn2.value	= getUserProp s "unknP2"
			Roll2dfx.spukn3.value	= getUserProp s "unknP3"
			Roll2dfx.dlpar.selection= (getUserProp s "Type") + 1
			return true
		) catch (return false)
		
		)--end if P/U
	)--end Text

	if classof s == Rectangle then (
		Roll2dfx.spVD.enabled 		= false	
		Roll2dfx.spLS.enabled 		= false
		Roll2dfx.spOutR.enabled 	= false
		Roll2dfx.spInR.enabled 		= false
		Roll2dfx.spCS.enabled 		= false
		Roll2dfx.spRf.enabled 		= false
		Roll2dfx.spLF.enabled 		= false
		Roll2dfx.spDust.enabled 	= false
		Roll2dfx.lgtcolor.enabled 	= false
		Roll2dfx.dlcontrol.enabled 	= false
		
		Roll2dfx.parcolor.enabled	= false
		Roll2dfx.dlpar.enabled		= false
		Roll2dfx.spPsize.enabled	= false	
		Roll2dfx.spukn1.enabled		= false
		Roll2dfx.spukn2.enabled		= false
		Roll2dfx.spukn3.enabled		= false	

		Roll2dfx.pedcolor.enabled	= true	
		Roll2dfx.pedanim.enabled	= true
		Roll2dfx.spdir1x.enabled	= true	
		Roll2dfx.spdir1y.enabled	= true	
		Roll2dfx.spdir1z.enabled	= true	
		Roll2dfx.spdir2x.enabled	= true	
		Roll2dfx.spdir2y.enabled	= true	
		Roll2dfx.spdir2z.enabled	= true	

		Roll2dfx.sfcolor.enabled	= false	

		try (
			Roll2dfx.pedcolor.color	= s.wirecolor
			Roll2dfx.pedanim.selection = (getUserProp s "Animation") + 1 
			Roll2dfx.spdir1x.value 	= getUserProp s "Pos1x"
			Roll2dfx.spdir1y.value	= getUserProp s "Pos1y"
			Roll2dfx.spdir1z.value	= getUserProp s "Pos1z"
			Roll2dfx.spdir2x.value 	= getUserProp s "Pos2x"
			Roll2dfx.spdir2y.value	= getUserProp s "Pos2y"
			Roll2dfx.spdir2z.value	= getUserProp s "Pos2z"
			Roll2dfx.pedanim.selection = (getUserProp s "Animation") + 1 
			return true
		) catch (return false)
	
	)--end Rectangle

	if classof s == Star then (
		Roll2dfx.spVD.enabled 		= false	
		Roll2dfx.spLS.enabled 		= false
		Roll2dfx.spOutR.enabled 	= false
		Roll2dfx.spInR.enabled 		= false
		Roll2dfx.spCS.enabled 		= false
		Roll2dfx.spRf.enabled 		= false
		Roll2dfx.spLF.enabled 		= false
		Roll2dfx.spDust.enabled 	= false
		Roll2dfx.lgtcolor.enabled 	= false
		Roll2dfx.dlcontrol.enabled 	= false
		
		Roll2dfx.parcolor.enabled	= false
		Roll2dfx.dlpar.enabled		= false
		Roll2dfx.spPsize.enabled	= false	
		Roll2dfx.spukn1.enabled		= false
		Roll2dfx.spukn2.enabled		= false
		Roll2dfx.spukn3.enabled		= false	

		Roll2dfx.pedcolor.enabled	= false	
		Roll2dfx.pedanim.enabled	= false
		Roll2dfx.spdir1x.enabled	= false	
		Roll2dfx.spdir1y.enabled	= false	
		Roll2dfx.spdir1z.enabled	= false	
		Roll2dfx.spdir2x.enabled	= false	
		Roll2dfx.spdir2y.enabled	= false	
		Roll2dfx.spdir2z.enabled	= false	

		Roll2dfx.sfcolor.enabled	= true	

		Roll2dfx.sfcolor.color		= s.wirecolor
		
		if getuserProp s "ID" != undefined then	return true
		else return false
		
	)--end Star

	return undefined
)--end fn select2dfx


fn createfx shp fxID =(
	o = shp.parent
	while o.parent != undefined do o = o.parent
	PID = getUserProp o "ID"
	IDtxt = fxID as string
	NewID = PID as string + "-" + (substring IDtxt 3 4)
	case classof shp of (
		Donut:		shp.name = "2dfx_light"
		Rectangle:	shp.name = "2dfx_pedarea"
		Star:		shp.name = "2dfx_sunreflection"
		Text:		(if shp.text == "P" then shp.name = "2dfx_particle"
						else shp.name = "2dfx_unknown"
					)
	)
	shp.name += substring IDtxt 3 4
	setUserProp shp "ID" NewID
	in coordsys parent pp = shp.pos
	
	objAry = for oo in geometry where (oo.name == o.name)AND(oo != o) collect oo
	if objAry.count > 0 then (
		for o in objAry do (
			nshp = instance shp
			nshp.name = shp.name
			nshp.wirecolor = shp.wirecolor
			setUserProp nshp "ID" NewID
			nshp.parent = o
			in coordsys parent nshp.pos = pp
		)--end for o
	)--end if objAry	
)--end fn createfx

fn update2dfx shp Roll2dfx = (
	upb = "ID=" + getUserProp shp "ID"
	upb += "\nunkn1=" + (Roll2dfx.Unkn.value) as string
    case classof shp of (
		Donut: (
			t1 = getUserProp shp "t1"
			t2 = getUserProp shp "t2"
			if t1 == undefined then t1 = "coronastar"
			if t2 == undefined then t2 = "shad_exp"
			upb += "\nt1=" + t1 + "\nt2=" + t2										--coronastar,shad_exp
			upb += "\nView=" 		+ Roll2dfx.spVD.value as string 				--ViewDistance
			upb += "\nOutRange="	+ Roll2dfx.spOutR.value as string				--Outter Range
			upb += "\nLampSize=" 	+ Roll2dfx.spLS.value as string					--Lamp Size
			upb += "\nInRange=" 	+ Roll2dfx.spInR.value as string				--Inner Range
			upb += "\nCorona=" 		+ Roll2dfx.spCS.value as string					--Corona Size
			upb += "\nControl=" 	+ (Roll2dfx.dlcontrol.selection - 1) as string	--Control
			upb += "\nReflection=" 	+ Roll2dfx.spRf.value as string					--Reflection  on wet roads
			upb += "\nLensFlare=" 	+ Roll2dfx.spLF.value as string					--LensFlare
			upb += "\nDust="		+ Roll2dfx.spDust.value as string				--Dust
			shp.wirecolor = Roll2dfx.lgtcolor.color
		)
		Text: (
			upb += "\nType="	+ (Roll2dfx.dlpar.selection - 1) as string		--Particles Type
			upb += "\nunknP1="	+ Roll2dfx.spukn1.value as string				--Unknown 1
			upb += "\nunknP2="	+ Roll2dfx.spukn2.value as string				--Unknown 2
			upb += "\nunknP3="	+ Roll2dfx.spukn3.value as string				--Unknown 3
			upb += "\nSize="	+ Roll2dfx.spPsize.value as string
			shp.wirecolor = Roll2dfx.parcolor.color
		)
		Rectangle: (
			upb += "\nAnimation="	+ (Roll2dfx.pedanim.selection - 1) as string		--Type of Animation
			upb += "\nPos1x="		+ Roll2dfx.spdir1x.value as string										--?? point of bounding area
			upb += "\nPos1y="		+ Roll2dfx.spdir1y.value as string										--?? point of bounding area
			upb += "\nPos1z="		+ Roll2dfx.spdir1z.value as string										--?? point of bounding area
			upb += "\nPos2x="		+ Roll2dfx.spdir2x.value as string										--?? point of bounding area
			upb += "\nPos2y="		+ Roll2dfx.spdir2y.value as string										--?? point of bounding area
			upb += "\nPos2z="		+ Roll2dfx.spdir2z.value as string										--?? point of bounding area
			shp.wirecolor = Roll2dfx.pedcolor.color
		)
		Star: (
			shp.wirecolor = Roll2dfx.sfcolor.color
		)
	)--end case
	upb += "\n"
	setUserPropBuffer shp upb
 	in coordsys parent pp = shp.pos
 	tcolor = shp.wirecolor 

	shpAry = for s in shapes where (s.name == shp.name) collect s
	if shpAry.count > 0 then (
		for s in shpAry do (
			setUserPropbuffer s upb
			in coordsys parent s.pos = pp
			s.wirecolor = tcolor
		)--end for s
	)--end if shpAry	

)--end fn update2dfx


fn MapIOInfo = (
	format "\nMap IO Version 0.5b\n\nby Kam		 10Oct05\nkam.lai@ntlworld.com\n\n"
	return 051010
)