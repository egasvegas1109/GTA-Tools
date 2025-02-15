/*
changelog

20.11.2019
	
*/

struct sideData (
	sID = #(),
	sNAME = #()
)
global ideData

global pbideCount
global pbideMax

fn pbProgressUpdate = (
	pbideCount += 1.0
	progressUpdate ((pbideCount / pbideMax) * 100)
)

fn pbProgressRename pbname = (
	progressStart pbname
	progressUpdate ((pbideCount / pbideMax) * 100)
	setProgressCancel false
)

fn getoffsetInIpl iplname = (
	ff = fopen iplname  "rb"
	ch = 0
	sect = "    "	
	while (ch != undefined) do (
		ch = ReadByte ff
		if toLower(bit.intAsChar(ch)) == "o" then (
			sect[1] = bit.intAsChar(ch)
			sect[2] = bit.intAsChar(ReadByte ff)
			sect[3] = bit.intAsChar(ReadByte ff)
			sect[4] = bit.intAsChar(ReadByte ff)
			if toLower(sect) == "objs" then (
				pos = ftell ff
				fclose  ff
				return pos-4
			)
		)
	)
	return undefined
)

fn getINSToffsetInIpl iplname = (
	ff = fopen iplname  "rb"
	ch = 0
	sect = "    "	
	while (ch != undefined) do (
		ch = ReadByte ff
		if (ch != undefined  and toLower(bit.intAsChar(ch)) == "i") then (
			sect[1] = bit.intAsChar(ch)
			ch2 = ReadByte ff
			if ch2== undefined then return 1
			sect[2] = bit.intAsChar(ch2)
			ch2 = ReadByte ff
			if ch2== undefined then return 1
			sect[3] = bit.intAsChar(ch2)
			ch2 = ReadByte ff
			if ch2== undefined then return 1
			sect[4] = bit.intAsChar(ch2)
			if toLower(sect) == "inst" then (
				pos = ftell ff
				fclose  ff
				return pos-4
			)
		)
	)
	return 1
)


 fn readline_ f = (
	ch = 0
	str = ""
	while true do (
		ch = readByte f #unsigned
		if ch != undefined then (
			if ch >= 192 and ch <= 255 then ch = 95
			if ch == 13 or ch == 10 then (
				ch = readByte f #unsigned
				if ch == 13 or ch == 10 then (
					str += (bit.intAsChar 0)
					return str
				)
				fseek f -1 #seek_cur 
				str += (bit.intAsChar 0)
				return str
			)
			str += (bit.intAsChar ch)
		) else (
			if str == "" then return undefined
			str += (bit.intAsChar 0)
			return str
		)
	)
)

fn DFFfromMap  f  texEx  setsname mattype = (
	if fakeImport == true then (
		obj = (Plane  length:50 width:50 lengthsegs:1 widthsegs:1)
		obj.name = setsname
	) else (
		try ( 
			obj = DFFin f 1.0 mattype texEx 0.1 false false setsname
			obj.name = setsname
			st_tTlDFF += 1
		) catch (
			format "  - DFF IMPORT ERROR %\n" setsname
			return undefined
		)
	)
	return obj
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


fn readinst f dffpath VerIdx textype mattype = (
	Norwlight = true
	lnctr = 1
	loopend = false
	ln = readLine f
	if (findstring ln "end" != undefined) then return false
	while (ln.count < 4)OR(findstring ln "#" != undefined) do ln = readline f
	if (findstring ln "end" != undefined)AND(ln.count < 10) then loopend = true 
	while loopend == false do (
		pbProgressUpdate()
		--try (
			lln = ln as stringStream 
			ID = readValue lln
			dffname = readDelimitedString lln ","
			dfffile  = dffpath + "\\" + dffname + ".dff"
			
			if (VerIdx != 1) then Intr = readValue lln else Intr = undefined
			
			dffpos   = [(readValue lln),(readValue lln),(readValue lln)]
			if (VerIdx != 3) then dffscale = [(readValue lln),(readValue lln),(readValue lln)]
			dffrot   = quat (readValue lln) (readValue lln) (readValue lln) (readValue lln)
			if (VerIdx == 3) then unknown01 = readValue lln

	 --		format "ID: %\n" ID 
	 --		format "Object: %\n" dfffile
	 --		format "Pos: % \n" dffpos
	 --		format "Scale: %\n" dffscale
	 --		format "Rotation: %\n" dffrot
			st_inst += 1
			if (SelectionSets[dffname] != undefined) AND \
				(SelectionSets[dffname].count != 0) then (
				rootAry = for obj in SelectionSets[dffname] where obj.parent == undefined collect obj	
				rootobj = instance rootAry[1]
				rootobj.rotation = conjugate dffrot
				if (VerIdx != 3) then rootobj.scale = dffscale
				rootobj.pos = dffpos
				rootobj.name = dffname
				if ((substring (toLower dffname) 1 3)== "lod") then st_tTlLod += 1 else st_tTlObj += 1
				st_tTlAll += 1
				--setUserProp rootobj "ID" (getUserProp rootAry[1] "ID")
				
				--if Intr != undefined then setUserProp rootobj "Interior" Intr
				--if (VerIdx == 3) then setUserProp rootobj "unknown01" unknown01

			) else ( -- new model
					format "line  %\n" 	lnctr
					ff = fopen dfffile "rb"
					if ff != undefined then (
						format "\t\tLoad dff %...\n\n" dfffile
						if textype == 1 then	rootobj = DFFfromMap  ff  ".png"  dffname mattype 
						else 					rootobj = DFFfromMap  ff  ".tga"  dffname mattype
						if rootobj == undefined then format ">>>Error in reading1 %<<<\n\n" dfffile
						else (
							st_tTlAll += 1
							if ((substring (toLower dffname) 1 3)== "lod") then st_tTlLod += 1 else st_tTlObj += 1
							rootobj.rotation = conjugate dffrot
							if (VerIdx != 3) then rootobj.scale = dffscale
							rootobj.pos = dffpos
							--setUserProp rootobj "ID" ID
							
							--if Intr != undefined then setUserProp rootobj "Interior" Intr
							--if (VerIdx == 3) then setUserProp rootobj "unknown01" unknown01	
							
							rootobj.name = dffname
							gc()
						)
						fclose ff
						
					) else ( 
						format "#ERROR  % (DFF not found)\n\n" dfffile 
						st_tTlerr += 1
					)	
			
			)
			st_tTllines += 1
		--) catch (format "[line %] #ERROR READ \"%\"\n\n" lnctr ln )
		lnctr += 1
		ln = readLine f
		while (ln.count < 3)OR(findstring ln "#" != undefined) do ln = readline f
		if (findstring ln "end" != undefined)AND(ln.count < 10) then loopend = true 

	)
	return true
	
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
	if (findstring ln "end" != undefined) then return false
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
		st_cull += 1
			tmp = GTAcull length:culllength width:cullwidth height:(cullZmax-cullZmin) xray:on wirecolor:(color 216 218 140) renderable:false
			tmp.center = cullcenter
			culleffect tmp zoneprop
		ln = readLine f
		while (ln.count < 3)OR(findstring ln "#" != undefined) do ln = readline f
		if (findstring ln "end" != undefined)AND(ln.count < 10) then loopend = true 		
	)--end while
	return true
)--end readSAcull
fn readgrge f = (
	loopend = false
	ln = readLine f
	if (findstring ln "end" != undefined) then return false
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
		st_grge += 1
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
	return true
)

fn readenex f = (
	loopend = false
	ln = readLine f
	if (findstring ln "end" != undefined) then return false
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
		--max select none
		st_enex += 1
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
		--max select none
		ln = readLine f
		while (ln.count < 3)OR(findstring ln "#" != undefined) do ln = readline f
		if (findstring ln "end" != undefined)AND(ln.count < 10) then loopend = true 		
	)--end while
	return true
)

fn readpick f = (
	loopend = false
	ln = readLine f
	if (findstring ln "end" != undefined) then return false
	while (ln.count < 3)OR(findstring ln "#" != undefined) do ln = readline f
	if (findstring ln "end" != undefined)AND(ln.count < 10) then loopend = true 
	while loopend == false do (
		lln = ln as stringstream
		st_pick += 1
		tmp = GTApick item:(readvalue lln) 
		tmp.pos=[(readvalue lln),(readvalue lln),(readvalue lln)]
		ln = readLine f
		while (ln.count < 3)OR(findstring ln "#" != undefined) do ln = readline f
		if (findstring ln "end" != undefined)AND(ln.count < 10) then loopend = true 		
	)--end while
	return true
)
fn readcars f = (
	loopend = false
	ln = readLine f
	if (findstring ln "end" != undefined) then return false
	while (ln.count < 3)OR(findstring ln "#" != undefined) do ln = readline f
	if (findstring ln "end" != undefined)AND(ln.count < 10) then loopend = true 
	while loopend == false do (
		lln = ln as stringstream
		--max select none
		st_cars += 1
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
		--max select none
		ln = readLine f
		while (ln.count < 3)OR(findstring ln "#" != undefined) do ln = readline f
		if (findstring ln "end" != undefined)AND(ln.count < 10) then loopend = true 		
	)--end while
	return true
)
fn readauzo f = (
	loopend = false
	ln = readLine f
	if (findstring ln "end" != undefined) then return false
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
		st_auzo += 1
		tmp = GTAauzo length:(abs(p2.y-p1.y)) width:(abs(p2.x-p1.x)) height:(abs(p2.z-p1.z))
		tmp.pos = [((p2.x+p1.x)/2),((p2.y+p1.y)/2),p1.z]
		tmp.u1 = ukn1
		tmp.u2 = ukn2
		if tt[1] != undefined then tmp.text = tt[1]
		ln = readLine f
		while (ln.count < 3)OR(findstring ln "#" != undefined) do ln = readline f
		if (findstring ln "end" != undefined)AND(ln.count < 10) then loopend = true 		
	)--end while
	return true
)
fn readjump f = (
	loopend = false
	ln = readLine f
	if (findstring ln "end" != undefined) then return false
	while (ln.count < 3)OR(findstring ln "#" != undefined) do ln = readline f
	if (findstring ln "end" != undefined)AND(ln.count < 10) then loopend = true 
	while loopend == false do (
		lln = ln as stringstream
		st_jump += 1
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
	return true
)

fn binaryIplRead iplname dffpath VerIdx textype mattype = (
	pbProgressRename "IMPORT MAP FROM BIN IPL..."
	format "\n -> IMPORT MAP FROM BIN IPL...\n\n"
	ff = fopen iplname  "rb"
	ReadLong ff
	INSTnum = ReadLong ff
	ReadLong ff;ReadLong ff; ReadLong ff
	CARSnum = ReadLong ff
	ReadLong ff
	INSToffset = ReadLong ff
	ReadLong ff
	fseek ff INSToffset #seek_set
	for i=1 to INSTnum do (
		pbProgressUpdate()
		posx = ReadFloat ff
		posy = ReadFloat ff
		posz = ReadFloat ff
		rotx = ReadFloat ff
		roty = ReadFloat ff
		rotz = ReadFloat ff
		rotw = ReadFloat ff
		objid = ReadLong ff #unsigned
		interior = ReadLong ff
		lodIndex = ReadLong ff
		
		dffpos   = [posx,posy,posz]
		dffrot   = quat rotx roty rotz rotw
		myitem = findItem ideData.sID objid
		st_tTllines += 1
		st_inst += 1
		if myitem != 0 then (
			dffName = ideData.sNAME[myitem]
			if (SelectionSets[dffname] != undefined) AND \
				(SelectionSets[dffname].count != 0) then (
				if ((substring (toLower dffname) 1 3)== "lod") then st_tTlLod += 1 else st_tTlObj += 1
				rootAry = for obj in SelectionSets[dffname] where obj.parent == undefined collect obj	
				rootobj = instance rootAry[1]
				rootobj.rotation = conjugate dffrot
				if (VerIdx != 3) then rootobj.scale = dffscale
				rootobj.pos = dffpos
				rootobj.name = dffname
				st_tTlAll += 1
				--setUserProp rootobj "ID" (getUserProp rootAry[1] "ID")
				
				--if Intr != undefined then setUserProp rootobj "Interior" Intr
				--if (VerIdx == 3) then setUserProp rootobj "unknown01" unknown01

			) else ( -- new model	
			
				dfffile  = dffpath + "\\" + dffname + ".dff"
				f = fopen dfffile "rb"
				if f != undefined then (
					format "\t\tLoad dff %...\n\n" dfffile
					if textype == 1 then	rootobj = DFFfromMap  f  ".png"  dffname mattype 
					else if textype == 2 then rootobj = DFFfromMap  f  ".tga"  dffname mattype
					else rootobj = DFFfromMap  f  ("."+IORoll.textcust.text)  dffname mattype
					if rootobj == undefined then format ">>>Error in reading1 %<<<\n\n" dfffile
					else (
						st_tTlAll += 1
						if ((substring (toLower dffname) 1 3)== "lod") then st_tTlLod += 1 else st_tTlObj += 1
						rootobj.rotation = conjugate dffrot
						if (VerIdx != 3) then rootobj.scale = dffscale
						rootobj.pos = dffpos
						--setUserProp rootobj "ID" ID
						
						--if Intr != undefined then setUserProp rootobj "Interior" Intr
						--if (VerIdx == 3) then setUserProp rootobj "unknown01" unknown01	
						
						rootobj.name = dffname
						gc()
					)
					fclose f
				) else ( 
					format "#ERROR  % (DFF not found)\n\n" dfffile
					st_tTlerr += 1
				)	

			)				
		) else (
			format "NOT FOUND ID %  | file %\n" objid iplname
			st_tTlerr += 1
		)
	)
)

fn  getSectionSize file = (
	count = 0
	--try(
		f = openFile file
		ln = readline f
		while (findstring ln "objs" != 1) do (
			if (eof f) then exit
			ln = readline f
		)
		if not (EOF f) then (
			ln = readline f
			while (findstring ln "end" != 1) do (
				if (eof f) then exit
				if (ln.count > 0 and findstring ln "#" == undefined) then count += 1
				ln = readline f
			)
			if not (EOF f) then (
				while (findstring ln "tobj" != 1) do (
					if (eof f) then exit
					ln = readline f
				)
				if not (EOF f) then (
					ln = readline f
					while (findstring ln "end" != 1) do (
						if (eof f) then exit
						if (ln.count > 0 and findstring ln "#" == undefined) then count += 1
						ln = readline f
					)
				)
			)
		)
		count-=1
		close f
		return count
	--) catch(return undefined)
)

fn getIdeSize fname idePathArr = (
	idecount = 0
	for ipath in idePathArr do (
		idesize = getSectionSize (fname + ipath)
		if idesize != undefined then (
			idecount += idesize
		)
	)
	return idecount
)

fn fillId fname = (
	format "\n -> Restore BIN IPL func v 0.2b by Goldfish\n"
	if fname != undefined then (
        ideData.sID = #()
        ideData.sNAME = #()
		format " read gta.dat...\n"
		f = openFile fname
		idePath = #()
		while not eof f do (
			sline = readline f
			if sline != undefined then (
				fs = filterString sline " "
				if fs[1] == "IDE" then append idePath fs[2] 
			)
		)
		close f
		
		fname_ = fname
		fname = getFilenamePath fname_
		toLower fname
		datafix = findstring fname "data"
		if datafix != undefined then (
			fname_ = substring fname 1 (datafix-1)
			fname_ + "\\"
			fname = fname_
		)

		format " SCAN IDs..\n"
		for ipath in idePath do (
			pbProgressUpdate()
			try(
				fpath = (fname + ipath)
				f = openFile fpath
				fpos = getoffsetInIpl fpath
				seek f fpos
				ln = readline f
				while (findstring ln "objs" != 1) do (
					if (eof f) then exit
					ln = readline f
				)
				if not (EOF f) then (
					ln = readline f
					while (findstring ln "end" != 1) do (
						if (eof f) then exit
						if (ln.count > 0 and findstring ln "#" == undefined) then (
							fs = filterString ln ","
							append ideData.sID (fs[1] as integer)
							fstr = filterString fs[2] " "
							append ideData.sNAME fstr[1]						
						)
						ln = readline f
					)
					if not (EOF f) then (
						while (findstring ln "tobj" != 1) do (
							if (eof f) then exit
							ln = readline f
						)
						if not (EOF f) then (
							ln = readline f
							while (findstring ln "end" != 1) do (
								if (eof f) then exit
								if (ln.count > 0 and findstring ln "#" == undefined) then (
									fs = filterString ln ","
									append ideData.sID (fs[1] as integer)
									fstr = filterString fs[2] " "
									append ideData.sNAME fstr[1]
								)
								ln = readline f
							)
						)
					)
				)
				close f
			) catch ( format "#ERROR READ BIN IPL  %\n\n" (fname + ipath) )	
		)
		format " END Read\nTotal: % id\n" ideData.sID.count
	)
)

fn getCountDatFile fname = (
	if fname != undefined then (
		f = openFile fname
		icount = 0
		while not eof f do (
			sline = readline f
			if sline != undefined then (
				fs = filterString sline " "
				if fs[1] == "IDE" then icount += 1
			)
		)
		close f
	)
	return icount
)
		
fn BinIplPrepare = (
	--try (
		if ideData.sID.count == 0 then (
			messagebox "Found BINARY IPL\n\nplease select gta.dat file in GTA directory!\n(GTA SA\\data\\gta.dat)" title:"Found BINARY IPL!"
			gtaDatfile = getOpenFileName caption:"Select gta.dat"  types:"GTA data file (gta.dat)|gta.dat|"
			if gtaDatfile != undefined then (
				pbideMax += getCountDatFile(gtaDatfile) as float
				pbProgressRename "SCAN DFF NAMES..."
				format "\n -> SCAN DFF NAMES...\n"
				fillId(gtaDatfile)
			)
		)
		return gtaDatfile
	--) catch (
	--)
)


fn isBinIPL iplname = (
	ch = "    "	
	ff = fopen iplname  "rb"
	ch[1] = (bit.intAsChar (ReadByte ff))
	ch[2] = (bit.intAsChar (ReadByte ff))
	ch[3] = (bit.intAsChar (ReadByte ff))
	ch[4] = (bit.intAsChar (ReadByte ff))
	fclose ff
	if ch == "bnry" then return true else return false
)

fn readBinIdePrepare iplfile = (
	ff = fopen iplfile  "rb"
	ReadLong ff
	isize = ReadLong ff
	fclose
	return isize
)

fn readIdePrepare iplfile = (
	isize = 0
	f = openFile iplfile
	ln = readline f
	while (findstring ln "inst" != 1) do (
		if (eof f) then exit
		ln = readline f
	)
	if not (EOF f) then (
		ln = readline f
		while (findstring ln "end" != 1) do (
			if (eof f) then exit
			if (ln.count > 0 and findstring ln "#" == undefined) then isize += 1
			ln = readline f
		)
	)
	close f
	return isize
)

fn getIDcountFromIpl iplarr = (
	instCount = 0
	for i = 1 to iplarr.count do (
		if (isBinIPL iplarr[i]) == true then instCount += (readBinIdePrepare iplarr[i])
		else instCount +=  (readIdePrepare iplarr[i])
	)
	return instCount
)

fn ReadIPL iplname dffpath VerIdx textype mattype = (
	--try (
		if (isBinIPL iplname == true ) then (
			binaryIplRead iplname dffpath VerIdx textype mattype
		) else (	
			pbProgressRename "IMPORT MAP FROM IPL..."
			format "\n -> IMPORT MAP FROM IPL...\n"
			f = openFile iplname	
			fpos = getINSToffsetInIpl iplname
			seek f fpos
			
			while not (eof f) do (
				ln = readLine f
				if findstring ln "inst" != undefined then (
					if sChImport.inst == true then (
						format "\n -> read inst...\n"
						--try (
							res = readinst f dffpath VerIdx textype mattype
						--) catch (format "\n -> ERROR read inst\n")
					)
				)
				else if findstring ln "cull" != undefined then (
					if VerIdx != 3 then readcull f
					else (
						if sChImport.cull == true then (
							format "\n -> read cull...\n"
							try (
								res = readSAcull f
							) catch (format "\n -> ERROR read cull\n")
						)
					)
				)
				else if findstring ln "grge" != undefined then (
					if sChImport.grge == true then (
						format "\n -> read grge...\n"
						try (
							res = readgrge f
						) catch (format "\n -> ERROR read grge\n")
					)
				)
				else if findstring ln "enex" != undefined then (
					if sChImport.enex == true then (
						format "\n -> read enex...\n"
						try (
							res = readenex f
						) catch (format "\n -> ERROR read enex\n")
					)
				)
				else if findstring ln "pick" != undefined then (
					if sChImport.pick == true then (
						format "\n -> read pick...\n"
						try (
							res = readpick f
						) catch (format "\n -> ERROR read pick\n")
					)
				)
				else if findstring ln "cars" != undefined then (
					if sChImport.cars == true then (
						format "\n -> read cars...\n"
						try (
							res = readcars f
						) catch (format "\n -> ERROR read cars\n")
					)
				)
				else if findstring ln "auzo" != undefined then (
					--if sChImport.auzo == true then (
						--format "\n -> read auzo...\n"
						--try (
							--res = readauzo f
						--) catch (format "\n -> ERROR read auzo\n")
					--)
				)
				else if findstring ln "jump" != undefined then (
					if sChImport.jump == true then (
						format "\n -> read jump...\n"
						try (
							res = readjump f
						) catch (format "\n -> ERROR read jump\n")
					)
				)
			)--end while eof

			close f
		)
	--) catch(format "#ERROR READ IPL  %\n\n" iplname )
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


fn ReadIDE_2dfx fname verTxt fx fxsize = (
	f = openfile fname
	while not (EOF f) do (
		ln = readLine f
		if (findstring ln "2dfx" != undefined)AND(fx == true) then rIDE2dfx f fxsize
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

					--<e5>--


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
)ят