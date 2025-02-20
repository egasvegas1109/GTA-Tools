--15Dec05--

--fns should be hidden--
------------------------
global lightArr_
global LetsRockandRoll = true		--hidden feature--
global impHas2dfx
global imp2dfxCount
Global FrameAry = #()
Global SkinData = #()
global implightErr = false
global isIplImport = false
global cntLDffNow
global cntLDffMax

struct _2dfinfo (
	v2d_L_posX = #(),
	v2d_L_posY = #(),
	v2d_L_posZ = #(),
	v2d_L_color = #(),
	v2d_L_Dist = #(),	
	v2d_L_OutRange = #(),
	v2d_L_Size = #(),
	v2d_L_ShSize = #(),
	v2d_L_ShowMode = #(),
	v2d_L_Refl = #(),	
	v2d_L_coronaFlareType = #(),
	v2d_L_shadowColorMultiplier = #(),
	v2d_L_Flags1 = #(),
	v2d_L_CoroneName  = #(),		
	v2d_L_shadowName = #() ,
	v2d_L_shadowZDistance = #(),
	v2d_L_Flags2 = #(),
	v2d_L_DirectionX = #(),
	v2d_L_DirectionY = #(),
	v2d_L_DirectionZ = #()
)
global s_2dfinfo

fn r2DFX msh size f = (
	try(
		impHas2dfx = true
		chSize = ((size as double) - 4.0) / 100.0
		s_2dfinfo = _2dfinfo()
		--format " %\n"  s_2dfinfo.v2d_L_posX.count
		fdbg = ftell f
		lightCount  = readlong f -- 2d count
		_2dCountdebug = 0
		imp2dfxCount = lightCount
		
		sz = 0
		tp = 0
		_v2d_L_posX = 0.0
		_v2d_L_posY = 0.0
		_v2d_L_posZ = 0.0
		_2dfxCount = 0
		for i = 1 to lightCount do (
			_v2d_L_posX = readfloat f -- x
			_v2d_L_posY = readfloat f -- y
			_v2d_L_posZ = readfloat f -- z		
			tp = readlong f -- type
			sz = readlong f -- size
			--format "% %\n" tp sz
			if tp == 0 then (
				_2dfxCount += 1
				i2 = _2dfxCount
				s_2dfinfo.v2d_L_posX[i2] = _v2d_L_posX
				s_2dfinfo.v2d_L_posY[i2] = _v2d_L_posY
				s_2dfinfo.v2d_L_posZ[i2] = _v2d_L_posZ
				_2dCountdebug += 1
				r = readbyte f #unsigned
				g = readbyte f #unsigned
				b = readbyte f #unsigned
				a = readbyte f #unsigned
				s_2dfinfo.v2d_L_color[i2] = (color r g b)
				s_2dfinfo.v2d_L_Dist[i2] = readfloat f
				s_2dfinfo.v2d_L_OutRange[i2] = readfloat f
				s_2dfinfo.v2d_L_Size[i2] = readfloat f	
				s_2dfinfo.v2d_L_ShSize[i2] = readfloat f		
				s_2dfinfo.v2d_L_ShowMode[i2] = readbyte f #unsigned
				s_2dfinfo.v2d_L_Refl[i2] = readbyte f #unsigned		
				s_2dfinfo.v2d_L_coronaFlareType[i2] = readbyte f #unsigned	
				s_2dfinfo.v2d_L_shadowColorMultiplier[i2] = readbyte f #unsigned	
				s_2dfinfo.v2d_L_Flags1[i2] = readbyte f #unsigned		
				endtex = (ftell f) + 24
				s_2dfinfo.v2d_L_CoroneName[i2] = readstring f
				fseek f endtex #seek_set
				endtex = (ftell f) + 24	
				s_2dfinfo.v2d_L_shadowName[i2] = readstring f
				fseek f endtex #seek_set	
				s_2dfinfo.v2d_L_shadowZDistance[i2] = readbyte f #unsigned	
				s_2dfinfo.v2d_L_Flags2[i2] = readbyte f #unsigned
				
				if (chSize) == (abs (floor chSize)) then ( 
					s_2dfinfo.v2d_L_DirectionX[i2] = readbyte f #unsigned
					s_2dfinfo.v2d_L_DirectionY[i2] = readbyte f #unsigned
					s_2dfinfo.v2d_L_DirectionZ[i2] = readbyte f #unsigned
					readbyte f
					readbyte f
					--format " = loop\n"
				)else (
					readbyte f
					--format " = loop2\n"
				)
			) else (
				if tp > 10 or sz > size then exit
				fseek f ((ftell f)+sz) #seek_set
			)
		)
	)catch (format "Error read 2dfx\n")
	--format "2dfx\ncount %\nxyz % % %\ntype %\nsize %\n" a b c d e1 f1
	if _2dCountdebug > 0 then format " [debug]: imported % 2dfx(omnii)\n" _2dCountdebug
	imp2dfxCount = _2dCountdebug
)


fn rNVC msh f = (
	readbyte f
	readbyte f
	readbyte f
	readbyte f
	meshop.setMapSupport msh -1 true
	for i = 1 to msh.numverts do ( 
		r = (readbyte f) * 1.0 / 255.0
		g = (readbyte f) * 1.0 / 255.0
		b = (readbyte f) * 1.0 / 255.0		
		readbyte f
		meshop.setMapVert msh -1 i [r,g,b]
		--format "= % % %\n" r g b
	)
)

--A-----------------
-- General Functions
--------------------
fn Byte2char thisbyte = (
	char = " ! #$%& ()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_ abcdefghijklmnopqrstuvwxyz"
	t = thisbyte - 31
	if t > 91 then t = 4
	return char[t]
)
--end fn Byte2char			--<A1>--
--
fn stripSpace str = (
	local tmp = ""
	for i = 1 to str.count do (
		if substring str i 1 == " " then tmp += "~"
		else tmp += substring str i 1
	)--end for i
	return tmp
)
--end fn stripSpace		--<A2>--
--
fn RestoreSpace str = (
	local tmp = ""
	for i = 1 to str.count do (
		if substring str i 1 == "~" then tmp += " "
		else tmp += substring str i 1
	)--end for i
	return tmp
)
--end fn RestoreSpace		--<A3>--
--
--C---------------
-- Clump Functions
------------------
struct GTA3frame ( 
	transform, parentID, unknown, name, obj, boneID		--unknown -> Coords Reference?? 0:special 3:parent 0x020003:world
)
--
fn WhichRWver f = (
    local bkup = (ftell f) 
    fseek f 0 #seek_set
    readLong f;readLong f
	bb = readShort f #unsigned
	b1 = readByte f #unsigned
	b2 = readByte f #unsigned
	format "This File is RW Version : 3.%.%.%\n" (b2/4) (b1/16) ((mod b1 8) as integer)
    fseek f bkup #seek_set
	return (b2*0x1000000 + b1*0x10000 + bb)
)
--end fn WhichRWver		--<C1>--
--
fn CheckZmodLock f = (
	Zmodlocked = false
	fseek f 0 #seek_set
	if (readLong f) != 16 then return false
	else (
		loop = true
		try (
			while loop == true do (
				fseek f ((readLong f) + 4) #seek_cur
				--mult-clump check--
				headerID = readLong f
				case headerID of (
					0xF21E: (
						skipbyte = 8 - (readlong f)
						readLong f
						s1 = readByte f
						s2 = readByte f
						cc = readLong f
						e1 = readByte f
						e2 = readByte f
						if (cc==0x1C14)OR(cc==0x1C15) then ()
						else Zmodlocked = true
						if s1 != e1 then Zmodlocked = true
						if s2 != e2 - 2 then Zmodlocked = true
						if skipbyte != 0 then Zmodlocked = true
						loop = false
					)
					default: ()
				)--end case
			)--end while
		) catch()
	)--end if/else	
	fseek f 0 #seek_set
	return Zmodlocked
)
--end fn CheckZmodLock		--<C3>--
--
fn checkClump f = (
	if LetsRockandRoll != true then 
		if  (CheckZmodLock f ) == true then return undefined

    fseek f 0 #seek_end
    dffend = ftell f
    fseek f 0 #seek_set
    
    noclump = 0
	clumpary = #()
    voidclump = true
    
    while voidclump == true do (
        if (readLong f #unsigned) == 16 then (
			append clumpary ((ftell f) - 4)
            Clump_size = readLong f #unsigned
	        readLong f
            noclump += 1        
            try (fseek f Clump_size #seek_cur) catch ( voidclump = false)
        )else (
            voidclump = false
        )--end if/else
    )--end while
	fseek f 0 #seek_set
    return clumpary
)
--end fn checkClump		--<C2>--
--
--0---------------------------
-- Functions for Bones & Skins
------------------------------
struct BoneStruct (
	boneID, boneIndex, boneType
)
--
--05Oct05 Bone created in rHAnimPLG and return bone object with BoneID in userprop
fn rHAnimPLG f string_length = (
	if (readLong f) != 256 then (
		format "Error in HAnim PLG(0x11E): %[%] skipped\n" i (ftell f)
		local skip = string_length - 4
		fseek f skip #seek_cur
		return undefined
	) else (
		FrameboneID = readLong f
		Bone_Count = readLong f #unsigned
		
		if FrameboneID == -1 then ( return undefined )
		
		--GTAbone = bone showlinks:true
		GTAbone = dummy boxsize:([0,0,0] ) wirecolor:yellow showlinks:true
		setUserProp GTAbone "BoneID" FrameboneID
        GTAbone.showLinksOnly = true
		
		if Bone_Count == 0 then return GTAbone
		else (
			readLong f;readLong f						--Unknown, always 0 36
			BoneDataAry = #()
			for j = 1 to Bone_Count do (
				BoneDataAry[j] = BoneStruct()
				BoneDataAry[j].boneID = readLong f #unsigned
				BoneDataAry[j].boneIndex = readLong f #unsigned
				BoneDataAry[j].boneType = readLong f #unsigned
			) 
			return #(GTAbone, BoneDataAry)
		)--end if/else FrameboneID
	)--end if const
)
--end fn rHAnimPLG			--<B1>--
--
--06Oct05 return vertsarray weightarray ibm specialunknown
fn rSkinPLG f data_length Vert_count ver = (

	dataEND = (ftell f) + data_length

	bvAry = #()
	bwAry = #()

	bone_count = readByte f #unsigned
	sp_count = readByte f #unsigned
	SPunknown = readByte f			--unknown??
	readByte f						--unknown??

	if DebugMode == true then format "Here:%\tdata length:%\tEnd Add:%\tvert_count:%\nBones:%\tSP:%\tunknown:%\n" here data_length dataEND Vert_count bone_count sp_count SPunknown

	if sp_count != 0 then (
		for i = 1 to sp_count do readByte f		--What is this??
	)--end if sp_count 

	for i = 1 to Vert_count do (
		vert1 = readByte f #unsigned
		vert2 = readByte f #unsigned
		vert3 = readByte f #unsigned
		vert4 = readByte f #unsigned
		bv = #((vert1 + 1))
		if vert2 != 0 then (
			append bv (vert2 + 1)
			if vert3 != 0 then (
				append bv (vert3 + 1)
				if vert4 != 0 then append bv (vert4 + 1)
			)
		)
		append bvAry bv
	)--end for i

	for j = 1 to Vert_count do (
		weight1 = readFloat f
		weight2 = readFloat f
		weight3 = readFloat f
		weight4 = readFloat f
		bw = #(weight1)
		if bvAry[j][2] != undefined then (
			append bw weight2
			if bvAry[j][3] != undefined then (
				append bw weight3
				if bvAry[j][4] != undefined then append bw weight4
			)
		)
		append bwAry bw
	)--end for j

	--Read IBM--
	if DebugMode == true then format "IBM start here(%)  bones:%\n" (ftell f) bone_count 
	global ibm = #()
	for i = 1 to bone_count do (
		if ver != 0x1803FFFF then (
			constDEAD = readLong f
			if DebugMode == true then format ": % :: " constDEAD
		)
		m1 = [(readFloat f),(readFloat f),(readFloat f)]
		u1 =  (readLong f)
		if DebugMode == true then format "%, " u1
		m2 = [(readFloat f),(readFloat f),(readFloat f)]
		u2 = (readLong f)
		if DebugMode == true then format "%, " u2
		m3 = [(readFloat f),(readFloat f),(readFloat f)]
		u3 = (readLong f)
		if DebugMode == true then format "%, " u3
		m4 = [(readFloat f),(readFloat f),(readFloat f)]
		u4 = (readLong f)
		if DebugMode == true then format "%\n" u4
		append ibm  (matrix3  m1 m2 m3 m4)
	)--end for i
	if ver == 0x1803FFFF then ( 
		if DebugMode == true then format ":: [%, %, %]\n" (readFloat f) (readFloat f) (readFloat f) 
		else ( for tt = 1 to 3 do (readFloat f)  )
	)
	if (ftell f) != dataEND then (
		format "\n>> error in reading Invert Bone Matrics :[%]<<(%)\n\n" dataEND (ftell f)
		fseek f dataEND #seek_set
	)
	return #(bvAry,bwAry,ibm,SPunknown)
)
--end fn rSkinPLG			--<B2>--
--
--1-----------------------
-- Functions for Import --
--------------------------
fn rClump f showdetail = (
	rvar = readLong f
	ercheck = false
	if rvar == 43 then format "\t\t(!) DFF have UV Animation clump!\n" 
	while (rvar !=16) do (
		tmpClumpsz = readLong f #unsigned
		readLong f #unsigned
		if (tmpClumpsz == undefined) then (
			ercheck = true
			exit
		)
		fseek f tmpClumpsz #seek_cur 
		rvar = readLong f
		if rvar == 43 then format "\t\t(!) DFF have UV Animation clump!\n" 
	)
	if (rvar != 16 or ercheck == true)  then ( 
		format "Error in Clump % %\n" rvar f
		exit 
	) 
	local Clumpsize = readLong f #unsigned
	if showdetail == true then (
		rVer = WhichRWver f
		format "\nClump(16) Size: %\n" Clumpsize
		format "\t->Version: %\n" rVer
		readLong f
	) else rVer = readLong f #unsigned
	if readLong f != 1 then ( format "Error in Clump Data\n"; exit )
	local Data_length = (readLong f)/4
	ver = readLong f
	object_count = readLong f
	if showdetail == true then format "\t->Object Count: %\n" object_count
	if Data_length > 1 then (
		for i = 2 to Data_length do (
			tmp = readLong f #unsigned
			if showdetail == true then format "\t->??: %\n" tmp
		)--end for i
	)
	return #(object_count,ver)
)
--end fn rClump			--<i1>--
--
fn rFrameList f Iscale showdetail = (
	if (readLong f) != 14 then ( format "Error in FrameList\n"; exit )
	tmp = (readLong f #unsigned)
	if showdetail == true then format "\tFrameList(14) Size: %\n" tmp
	readLong f		--Version
	if readLong f != 1 then ( format "Error in FrameList Data\n"; exit )
	FL_length = (readLong f #unsigned)
	readLong f		--Version
	frame_count = readLong f
	if showdetail == true then format "\t\t->Frame Count:%\n" frame_count
	frameAry = #()
	BoneDataAry = undefined
	for i = 1 to frame_count do (
		frameAry[i] = GTA3frame()
		frameAry[i].transform = matrix3 [(readFloat f),(readFloat f),(readFloat f)] [(readFloat f),(readFloat f),(readFloat f)] [(readFloat f),(readFloat f),(readFloat f)] [((readFloat f) * Iscale),((readFloat f) * Iscale),((readFloat f) * Iscale)]
		frameAry[i].parentID = (readLong f) + 1
		frameAry[i].unknown = readLong f #unsigned
	)
	for i = 1 to frame_count do (
		if readLong f != 3 then ( format "Error in FrameList Extension: %[pos: %]\n" i (ftell f); exit )
		Ext_length = readLong f
		ver = readLong f		--Version
		if Ext_length != 0 then (
            local Loop_end = (ftell f) + Ext_length
            while (ftell f) < Loop_end do (
               local header = readLong f
                string_length = readLong f
                readLong f		--Version            
                case header of (
                    39056126: (
                        tmp = ""
				        for j = 1 to string_length do (
    					    rbyte = readbyte f #unsigned
	    				    tmp += Byte2Char rbyte 
				        )
    				    frameAry[i].name = tmp
                    )
                    286: (
						if showdetail == true then format "\t\t->Bones Data(286): size: %\n" string_length
						tmp = rHAnimPLG f string_length
						if classof tmp == Array then (
							BoneDataAry = tmp[2]
                            frameAry[i].obj = tmp[1]
						) else (frameAry[i].obj = tmp)
					)
					default: (
						if showdetail == true then format "\t\t->unknown(%) size: %\n" header string_length
						fseek f string_length #seek_cur                
					)
                )--end case of
			)--end while		
		) else ( 
			if ver == 0x1803FFFF then ( 
				frameAry[i].name = "Skin_Mesh"
            )
		) --end if/else
	)--end for i

	if (BoneDataAry != undefined) then (
		for i = 1 to frameAry.count do (
			if classof frameAry[i].obj == dummy then ( --bone then (	
				tmp = for b in BoneDataAry where b.boneID == (getUserProp FrameAry[i].obj "BoneID") collect b
				setUserProp (frameAry[i].obj) "BoneType" tmp[1].boneType
				setUserProp (frameAry[i].obj) "BoneIndex" tmp[1].boneIndex
			)--end if bone
		)--end for
	)--end BoneDataAry

	return frameAry
)
--end fn rFrameList		--<i2>--
--
--Read rwLight after Atomic--**
fn rExtra f showdetail = (
    dataleng =  readLong f
    readlong f                  --ver
    if dataleng == 4 then  frame_index = (readLong f) + 1
    else fseek f dataleng #seek_cur
    section = readLong f
    if (section == 0x12) then (
		tmp = (readLong f #unsigned)
		readLong f				--ver
		if showdetail == true then format "\tLight(18) Size: %\n" tmp    
		readLong f; readLong f; readLong f				--data(0x01),size(24),ver
		lgt = Omnilight  multiplier:0.15 
		readFloat f
		cr = (readFloat f) * 255
		cg = (readFloat f) * 255
		cb = (readFloat f) * 255
			--lgt.color = color cr cg cb
			append lightArr_ lgt
		readLong f						--fallof
		readShort f						--type
		readShort f						--light type
		readLong f						--extension(0x03)
		extleng = readLong f
		readLong f						--ver
		if extleng != 0 then fseek f extleng #seek_cur
        return #(frame_index, lgt, "light")
    ) else fseek f (4 + (readLong f)) #seek_cur
    return undefined
)
--end fn rExtra
--
fn rAtomic f showdetail = (
    section = readLong f
    if section == 1 then ( return rExtra f showdetail )
	if section != 20 then ( format "Error in Atomic\n";implightErr = true;  exit )
	atmsize = (readLong f #unsigned)
	if showdetail == true then format "\tAtomic(20) Size: %\n" atmsize
	readLong f		--Version
	if readLong f != 1 then ( format "Error in Atomic Data\n"; exit )
	readLong f      --Data length (should be 16)
	readLong f		--Version
    frame_index = (readLong f) + 1
    Geometry_index = (readLong f) + 1
    readLong f;readLong f       --unknown?? (5,0)
 	if (readLong f) != 3 then ( format "Error in Atomic Extension\n"; exit )
	AExt = readLong f #unsigned
	if showdetail == true then format "\t\tExtension(3) Size: %\n" AExt
	readLong f		--Version
	local AEend = (ftell f) + AExt
	while (ftell f) < AEend do (
		local header = readLong f #unsigned
		local hdsize = readLong f #unsigned
		readLong f		--Version
		case header of (	
			31:	 (
					tmp = readLong f
					if showdetail == true then format "\t\t\tRight To Render(31)??: %\n" tmp
					readLong f
					 )
			288:	 (
					tmp = readLong f
					if showdetail == true then format "\t\t\tMaterial Effect(288)??: %\n" tmp
					 )
			280:	 (
					tmp = readLong f
					if showdetail == true then format "\t\t\tParticles(280)??: %\n" tmp
					 )
			default: (
					if showdetail == true then format "\t\t\tunknown??(%) Size: %\n" header hdsize
					fseek f hdsize #seek_cur
					 )
		)--end case
	)--end while
	return #(frame_index, Geometry_index, 0, atmsize)
)
--end fn rAtomic			--<i3>--
--
fn rGeometryList f showdetail = (
	if (readLong f) != 26 then ( format "Error in GeometryList\n"; exit )
	tmp = (readLong f #unsigned)
	if showdetail == true then format "\tGeometryList(26) Size: %\n" tmp
	readLong f		--Version
	if readLong f != 1 then ( format "Error in GeometryList Data\n"; exit )
	readLong f		--Data size( should be 4 for only contain Geometry Count )
	readLong f		--Version
	geometry_count = readLong f
	if showdetail == true then format "\t\t->Geometry Count:%\n" geometry_count
	return geometry_count
)
--end fn rGeomeList		--<i4>--
--
fn rMaterialSplit thismesh file showdetail = (
	SplitType = ReadLong file
	split_count = ReadLong file
	Face_Index_count = ReadLong file
	
	if showdetail == true then format "\t\t\t\t->Split Type:%\t" SplitType 
	local faced = 0

    --Create lookup Array--
	local tary = #()
	if SplitType == 0 then (
		for i = 1 to thismesh.numfaces do ( append tary (getface thismesh i) )
    ) else (
		for i = 1 to thismesh.numfaces do ( 
			t = (getface thismesh i)
			if t.x > t.z then swap t.x t.z
			if t.y < t.x then swap t.y t.x
			if t.y > t.z then swap t.y t.z
			append tary t
		)--end for i
	)--end if/else

	for i = 1 to split_count do (
    
        case SplitType of (
        0: (    
		    IndexCount = (readlong file)/3
		    MtlID = (readlong file) + 1            
            for j = 1 to IndexCount do ( 
			    a1 = (readLong file #unsigned) + 1
			    a2 = (readLong file #unsigned) + 1
			    a3 = (readLong file #unsigned) + 1
				tpt = [a1,a2,a3]
				aaa = finditem tary tpt
				--shit zmod2 faces index changed(12Aug08)--
                if (aaa == 0)AND(LetsRockandRoll != True) then (
					delete thismesh
					if showdetail == true then clearlistener()
					messagebox "This is a Non-Standard DFF !" title:"Import Aborted"
					return undefined
                )
				if aaa == 0 then (
					tpt = [a2,a1,a3]
					aaa = finditem tary tpt
				)
				if aaa == 0 then (
					tpt = [a3,a1,a2]
					aaa = finditem tary tpt
				)
				if aaa == 0 then (
					tpt = [a1,a3,a2]
					aaa = finditem tary tpt
				)
				if aaa == 0 then (
					tpt = [a3,a2,a1]
					aaa = finditem tary tpt
				)
				if aaa == 0 then (
					tpt = [a2,a3,a1]
					aaa = finditem tary tpt
				)				
				----------------------------------
				setFaceMatID thismesh aaa MtlID
            )--end for j
        )
        1: (
				IndexCount = (readlong file) - 2
				MtlID = (readlong file) + 1            
				a1 = (readLong file  #unsigned) + 1
				a2 = (readLong file  #unsigned) + 1 
				for j = 1 to IndexCount do ( 
					a3 = (readLong file  #unsigned) + 1
					tpt = [a1,a2,a3] 
					if tpt.x > tpt.z then swap tpt.x tpt.z
					if tpt.y < tpt.x then swap tpt.y tpt.x
					if tpt.y > tpt.z then swap tpt.y tpt.z
					aaa = finditem tary tpt
					if aaa != 0 then (
						setFaceMatID thismesh aaa MtlID
						faced +=1	
					)--end if aaa
					a1 = a2
					a2 = a3
				)--end for j        
        )
        default: (
            if showdetail == true then format "Unknown Split Type: % , rwMaterialSplit Skipped\n" SplitType
            skips = readLong f #unsigned
            readlong file       --MatID
            for j = 1 to skips do readLong f            
        )
        )--end case

    )--end for i
	if showdetail == true then (
		if SplitType == 1 then format "Mesh Face:% Splited Face:%\n" thismesh.numfaces faced
		else format "\n"
	)
   return thismesh
)
--end fn ReadrwMaterialSplit	--<i5>--
--
fn rTexture f mtl texEx showdetail = (
	if (readLong f) != 6 then ( format "Error in Texture\n"; exit )
	tmp = (readLong f #unsigned)
	if showdetail == true then format "\t\t\t\t\tTexture(6) Size: %\n" tmp
	readLong f		--Version
	if readLong f != 1 then ( format "Error in Texture Data\n"; exit )
	readLong f      --Data length (should be 4 bytes for filter flag, unknown ??)
	readLong f		--Version
	TexFlag = readLong f      --filter flag, unknown??
	--diffuse texture--
	if (readLong f) != 2 then ( format "Error in Texture String1\n"; exit )
	string_length = readLong f
	readLong f		--Version
    endtex = (ftell f) + string_length
	DTex = readString f
    fseek f endtex #seek_set
	if DTex != "" then (
    
--if DebugMode == true then mtlflag[1] = true

		if classof mtl == GTA_Mtl then (
			mtl.colormap = bitmaptexture name:DTex filename:(DTex+texEx)
			df = mtl.colormap
		) else (
			mtl.diffusemap = bitmaptexture name:DTex filename:(DTex+texEx)
			df =   mtl.diffusemap
		)    
		if TexFlag == 0x106 then df.filtering = 0
		if TexFlag == 0x10102 then df.filtering = 1
		if TexFlag == 0x10101 then df.filtering = 2
	)
	--mask texture--
	if (readLong f) != 2 then ( format "Error in Texture String2\n"; exit )
	string_length = readLong f
	readLong f		--Version
    endtex = (ftell f) + string_length
	MTex = readString f
    fseek f endtex #seek_set
	if MTex != "" then (

--if DebugMode == true then mtlflag[2] = true

		if classof mtl == GTA_Mtl then (
			mtl.alphamap = bitmaptexture name:DTex filename:(DTex+texEx)
			df = mtl.alphamap
		) else (
			mtl.opacitymap = bitmaptexture name:DTex filename:(DTex+texEx)
			df =   mtl.opacitymap
		)  
		if TexFlag == 0x106 then df.filtering = 0
		if TexFlag == 0x10102 then df.filtering = 1
		if TexFlag == 0x10101 then df.filtering = 2
	)
	if showdetail == true then format "\t\t\t\t\t\t->Texture: %\tMask: %\n" DTex MTex
	if (readLong f) != 3 then ( format "Error in Texture Extension\n"; exit )
	TExt_length = readLong f
	readLong f		--Version 
	if TExt_length != 0 then fseek f TExt_length #seek_cur
	return mtl
)
--end rTexture				--<i6>--
--
fn rMaterial f mattype texEx showdetail = (
	if (readLong f) != 7 then ( format "Error in Material\n"; exit )
	tmp = (readLong f #unsigned)
	if showdetail == true then format "\t\t\t\tMaterial(7) Size: %\n" tmp
	readLong f		--Version
	if readLong f != 1 then ( format "Error in Material Data\n"; exit )
	M_length = (readLong f #unsigned)
	readLong f		--Version
	readLong f		--unknown?? 0
	colR = readByte f #unsigned
	colG = readByte f #unsigned
	colB = readByte f #unsigned
	colA = readByte f #unsigned
	if showdetail == true then format "\t\t\t\t\t->RGBA: %, %, %, %\n" colR colG colB colA
	readLong f		--unknown?? 1629836
	texture_count = readLong f
	
if (DebugMode == true)AND(texture_count == 0) then mtlflag[1] = true

	Gamb = readFloat f
    Gspc = readFloat f
    Gdif = readFloat f

	gtaMatFlag = true
	if (mattype == 1) and (GTA_Mtl != undefined) then (
		mtl = GTA_Mtl()
		mtl.alpha = colA
		mtl.amb = Gamb
		mtl.spc = Gspc
		mtl.dif = Gdif
		if (DebugMode == true)AND(colA != 255)  then mtlflag[2] = true
	) else (
		gtaMatFlag = false
		mtl = StandardMaterial()
		--mtl.specular = color 255 255 255
		mtl.opacity = (colA/255.0 * 100) as integer
	)
	for i = 1 to texture_count do (
		rTexture f mtl texEx showdetail
	)

	if (readLong f) != 3 then ( format "Error in Material Extension[Pos: %]\n" (ftell f); exit )
	MExt = readLong f #unsigned
	readLong f		--Version	
        
	if MExt != 0 then (
		local Loop_end = (ftell f) + MExt
        while (ftell f) < Loop_end do (
			local header = readLong f
            local tmpsize = readLong f #unsigned
			readLong f		--Version

  			case header of (
				307: (
					if (gtaMatFlag == true) then (
						MExt_end = (ftell f) + tmpsize
						impCh = true
						try mtl.matEffect catch chMfx = false	
						if impCh == true then (
							if showdetail == true then format "\t\t\t\t\tMaterial Effect(307) Size: %\n" tmpsize
							if tmpsize >= 24 then (
								try (
									typeDK = readLong f
									
									if typeDK == 49 then ( 
										mtl.matEffect = 6
										posStr  = (ftell f)
										if (readLong f) == 6 then (
											texSize = readLong f      --Data size
											readLong f		--Version
											if (readLong f) != 1 then ( format "Error in Material Effect Texture[Pos: %]\n" (ftell f); exit )
											readLong f		--Data size-->2 int (Texture Filter Mode Flags, unknown)
											readLong f		--Version
											readLong f
											if (readLong f) != 2 then ( format "Error in Material Effect String[Pos: %]\n" (ftell f); exit )
											local string_Length = readLong f #unsigned
											readLong f		--Version
											RTex = readString f
											if RTex != "" then mtl.dkpNmap = bitmaptexture name:RTex filename:(RTex+texEx)  
										) else ( fseek f MExt_end #seek_set )
										fseek f (posStr + texSize + 12) #seek_set
										mtl.dkpRAmount = readFloat f 
										if (readLong f) == 6 then (
											readLong f      --Data size
											readLong f		--Version
											if (readLong f) != 1 then ( format "Error in Material Effect Texture[Pos: %]\n" (ftell f); exit )
											readLong f		--Data size-->2 int (Texture Filter Mode Flags, unknown)
											readLong f		--Version
											readLong f
											if (readLong f) != 2 then ( format "Error in Material Effect String[Pos: %]\n" (ftell f); exit )
											local string_Length = readLong f #unsigned
											readLong f		--Version
											RTex = readString f
											if RTex != "" then mtl.dkpRmap = bitmaptexture name:RTex filename:(RTex+texEx)  
											fseek f MExt_end #seek_set 
										) else ( fseek f MExt_end #seek_set )
									)  else if typeDK == 1 then ( 
										mtl.matEffect = 6
										if (readLong f) == 6 then (
											readLong f      --Data size
											readLong f		--Version
											if (readLong f) != 1 then ( format "Error in Material Effect Texture[Pos: %]\n" (ftell f); exit )
											readLong f		--Data size-->2 int (Texture Filter Mode Flags, unknown)
											readLong f		--Version
											readLong f
											if (readLong f) != 2 then ( format "Error in Material Effect String[Pos: %]\n" (ftell f); exit )
											local string_Length = readLong f #unsigned
											readLong f		--Version
											RTex = readString f
											if RTex != "" then mtl.dkpNmap = bitmaptexture name:RTex filename:(RTex+texEx)  
										) else ( fseek f MExt_end #seek_set )
										fseek f MExt_end #seek_set
									)
								) catch ( 
									format "error read Mat Fx\n"
									fseek f MExt_end #seek_set 
								)
							) else ( fseek f MExt_end #seek_set )
						)  else ( fseek f MExt_end #seek_set )
					)
				)
				288: (
					MExt_end = (ftell f) + tmpsize
 					if showdetail == true then format "\t\t\t\t\tMaterial Effect(288) Size: %\n" tmpsize
    				if tmpsize >= 24 then (
					try (
						if DebugMode == true then mtlflag[3] = true
							ReadLong f
							type = ReadLong f
							if type == 1 then ( -- BUMP
								if (gtaMatFlag == true) then (
									chMfx = true
									impCh = false
									try mtl.matEffect catch chMfx = false	
									if (classof mtl == GTA_Mtl) and chMfx == true then impCh = true
									else if (classof mtl == standardmaterial) then impCh = true
									if impCh == true then (
										mtl.matEffect = 3
										mtl.bumpMapAmount = (Readfloat f)
										ReadLong f; ReadLong f	--unknown?? 0 1 <-this 1 act as on/off texture switch?
										if (readLong f) == 6 then (
											readLong f      --Data size
											readLong f		--Version
											if (readLong f) != 1 then ( format "Error in Material Effect Texture[Pos: %]\n" (ftell f); exit )
											readLong f		--Data size-->2 int (Texture Filter Mode Flags, unknown)
											readLong f		--Version
											readLong f
											if (readLong f) != 2 then ( format "Error in Material Effect String[Pos: %]\n" (ftell f); exit )
											local string_Length = readLong f #unsigned
											readLong f		--Version
											RTex = readString f
											if RTex != "" then mtl.bumpMap = bitmaptexture name:RTex filename:(RTex+texEx)  
											fseek f MExt_end #seek_set
										) else ( fseek f MExt_end #seek_set )
									) else ( fseek f MExt_end #seek_set )
								) else fseek f MExt_end #seek_set
							) else (
								if type == 2 then (
									if classof mtl == GTA_Mtl then (
										mtl.reflection = (Readfloat f) * 100
										try (mtl.use_RF = true) catch ()
										mtl.matEffect = 2
									) else mtl.reflectionMapAmount = (Readfloat f) * 100
									ReadLong f; ReadLong f	--unknown?? 0 1 <-this 1 act as on/off texture switch?
									if tmpsize > 24 then (
										if (readLong f) == 6 then (
											readLong f      --Data size
											readLong f		--Version
											if (readLong f) != 1 then ( format "Error in Material Effect Texture[Pos: %]\n" (ftell f); exit )
											readLong f		--Data size-->2 int (Texture Filter Mode Flags, unknown)
											readLong f		--Version
											readLong f
											if (readLong f) != 2 then ( format "Error in Material Effect String[Pos: %]\n" (ftell f); exit )
											local string_Length = readLong f #unsigned
											readLong f		--Version
											RTex = readString f
											if RTex != "" then mtl.reflectionmap = bitmaptexture name:RTex filename:(RTex+texEx)  
											fseek f MExt_end #seek_set
										) else ( fseek f MExt_end #seek_set )
									) else readlong f --should be 0 if no reflection texture map
								) else (
									if type == 4 then ( -- Dual
										chMfx = true
										impCh = false
										try mtl.matEffect catch chMfx = false	
										if (classof mtl == GTA_Mtl) and chMfx == true then impCh = true
										if impCh == true then (
											mtl.matEffect = 5
											mtl.p_srcblend = (ReadLong f)
											mtl.p_destblend = (ReadLong f)
											ReadLong f	--unknown?? 0 1 <-this 1 act as on/off texture switch?
											if (readLong f) == 6 then (
												readLong f      --Data size
												readLong f		--Version
												if (readLong f) != 1 then ( format "Error in Material Effect Texture[Pos: %]\n" (ftell f); exit )
												readLong f		--Data size-->2 int (Texture Filter Mode Flags, unknown)
												readLong f		--Version
												readLong f
												if (readLong f) != 2 then ( format "Error in Material Effect String[Pos: %]\n" (ftell f); exit )
												local string_Length = readLong f #unsigned
												readLong f		--Version
												RTex = readString f
												if RTex != "" then mtl.dualMap = bitmaptexture name:RTex filename:(RTex+texEx)  
												fseek f MExt_end #seek_set
											) else ( fseek f MExt_end #seek_set )
										) else ( fseek f MExt_end #seek_set )
									) else (fseek f MExt_end #seek_set )
								)
							)
						) catch ( 
							format "error read Mat Fx\n"
							fseek f MExt_end #seek_set 
						)
					) else ( fseek f MExt_end #seek_set )
				)
				39056124: (
						if showdetail == true then format "\t\t\t\tSA RefMat(%) Size: %\n" header tmpsize
						if (tmpsize != 24) and (gtaMatFlag == false) then (fseek f tmpsize #seek_cur)
						else (
							if DebugMode == true then mtlflag[5] = true
							sr = (readFloat f) * 255
							sg = (readFloat f) * 255
							sb = (readFloat f) * 255
							sa = (readFloat f) * 255
							bnd = readFloat f
							mtl.specular = color sr sg sb
							if classof mtl == GTA_Mtl then (
								try (mtl.use_SAS = true) catch ()
								mtl.blend = bnd
								mtl.spec_alpha = sa
							) else (
								mtl.glossiness = bnd as integer
								mtl.Soften = bnd - mtl.glossiness
							)
							readFloat f
						)
				) 
 				39056118: (
					MExt_end = (ftell f) + tmpsize
					if showdetail == true then format "\t\t\t\tSA SpecMat(%) Size: %\n" header tmpsize
					spwr = (readFloat f)*100
					slTex = readString f
					try (mtl.use_SI = true) catch ()
					if classof mtl == GTA_Mtl then mtl.spec_power = spwr
					else mtl.specular_level = spwr
					mtl.specularmap = bitmaptexture name:slTex filename:(slTex+texEx)
					fseek f MExt_end #seek_set

					if DebugMode == true then mtlflag[4] = true

				)
				default: (
					if showdetail == true then format "\t\t\t\tunknown(%) Size: %\n" header tmpsize
					fseek f tmpsize #seek_cur
				)
			)--end case
		)--end while 
            
	)--end if MExt

	return mtl
    
)
--end fn rMaterial			--<i7>--
--
fn rMaterialList f mattype texEx showdetail = (
	if (readLong f) != 8 then ( format "Error in MaterialList\n"; exit )
	tmp = (readLong f #unsigned)
	if showdetail == true then format "\t\t\tMaterialList(8) Size: %\n" tmp
	readLong f		--Version
	if readLong f != 1 then ( format "Error in MaterialList Data\n"; exit )
	local Data_length = (readLong f)/4
	readLong f		--Version
	material_count = readLong f
	if showdetail == true then format "\t\t\t\t->Material Count:%\n" material_count
	for i = 1 to material_count do (readLong f #unsigned)
    if material_count == 1 then thismtl = rMaterial f mattype texEx showdetail
    else (
        thismtl = MultiMaterial numsubs:material_count
    	for i = 1 to material_count do (
	    	thismtl[i] = rMaterial f mattype texEx showdetail
	    )
    )--end if/else
    return thismtl
)
--end fn rMaterialList		--<i8>--
--
fn rGeometry f Iscale mattype texEx showdetail = (
	if (readLong f) != 15 then ( format "Error in Geometry\n"; exit )
	tmp = (readLong f #unsigned)
	if showdetail == true then format "\t\tGeometry(15) Size: %\n" tmp
	ver = readLong f		--Version
	if readLong f != 1 then ( format "Error in GeometryList Data\n"; exit )
	Geo_length = (readLong f #unsigned)
	readLong f		--Version
	--Info--
	GeometryFlags = readByte f #unsigned
            --byte Flag info.
            --      1   use Tri-Strip
            --      2   Position
            --      4   Texture UV
            --      8   Prelit (Vertex Colors)
            --      16  Normal
            --      32  Light
            --      64  Modulate Material Color
            --      128 Textured2 ??

    readByte f      --unknown?? always 0
	t2count = readShort f		--unknown?? for Textured2 use, no of UV map??
	face_count = readLong f #unsigned
	vert_count = readLong f #unsigned
	mt_count = readLong f #unsigned
	if showdetail == true then (
		format "\t\t\t->No. Faces: %\n" face_count 
		format "\t\t\t->No. Verts: %\n" vert_count 
		format "\t\t\t->No. Frame: %\n" mt_count
	)
	--Light--
	if (ver == 0x1003FFFF)OR(ver == 0x1803FFFF) then ()
	else (
		amb = (readFloat f)
		dif = (readFloat f)
		spe = (readFloat f)
		if showdetail == true then (
			format "\t\t\t->Ambient: %\n" amb
			format "\t\t\t->Diffuse: %\n" dif
			format "\t\t\t->Specular: %\n" spe
		)   
	)
	--===================--
	-- create empty mesh --
	--===================--
	DFFmesh=mesh numverts:vert_count numfaces:face_count


	--Vertex Colors--
	if isIplImport == false then pbUpdate()
	meshop.setMapSupport DFFmesh -2 false
	meshop.setMapSupport DFFmesh -2 true
	if ((mod GeometryFlags 16) >= 8) then (
		if showdetail == true then Format "\t\t\t<<<<<This Model has Vertex Colors!>>>>>\n"
		setNumCPVVerts DFFmesh vert_count
		buildVCFaces DFFmesh
		for i = 1 to vert_count do (
			r = readByte f #unsigned
			g = readByte f #unsigned
			b = readByte f #unsigned
			a = readByte f #unsigned
			VCol = color r g b
			setVertColor DFFmesh i VCol
			--format "%\n" a
			meshop.setMapVert DFFmesh -2 i [(a * 1.0 /255.0),(a * 1.0 /255.0),(a * 1.0 /255.0)]
		)--end for i 
	)--end Vertex Color	

	if isIplImport == false then pbUpdate()
	--UVs--
	if (t2count > 0)OR((mod GeometryFlags 8) >= 4) then (
		DFFmesh.numTVerts = vert_count
		buildTVFaces DFFmesh
		--format "UV1 Start :%\n" (ftell f)
		for i = 1 to vert_count do (
			SetTVert DFFmesh i [(readFloat f),(1 - (readFloat f)),0]
		)--end for i	
	)--end UV
	--format "UV1 End :%\nUV2 Start :%\n" ((ftell f)-1) (ftell f)	

	if isIplImport == false then pbUpdate()
	--UVs Texture2--
	if t2count > 1 then (
		meshop.setNumMaps DFFmesh 3
		meshop.setMapSupport DFFmesh 2 true
		if showdetail == true then Format "\t\t\t<<<<<UV Map2 Skipped!>>>>>\n"
		--if showdetail == true then Format "\t\t\t<<<<<use UV Map2 instead of UV1!>>>>>\n"
		for i = 1 to vert_count do (
			meshop.setMapVert DFFmesh 2 i [(readFloat f),(1 - (readFloat f)),0] 
		)--end for i
	)--end Textured2 UVs

	if isIplImport == false then pbUpdate()
	if t2count > 2 then for  jj = 3 to t2count do (
		format "UV% Start :%\n" jj (ftell f)
		for i = 1 to vert_count do ( (readFloat f);(readFloat f) )
		format "UV% End :%\n" jj ((ftell f)-1)
	)
	
	if isIplImport == false then pbUpdate()
	--Faces--
	for i = 1 to face_count do (
		a2 = (readShort f #unsigned)  + 1.0
		a1 = (readShort f #unsigned) + 1.0
		fg = (readShort f #unsigned) 
		a3 = (readShort f #unsigned) + 1.0
		setFace DFFmesh i a1 a2 a3
		setEdgeVis DFFmesh i 1 true;setEdgeVis DFFmesh i 2 true;setEdgeVis DFFmesh i 3 true
		if ((mod GeometryFlags 8) >= 4)OR((mod GeometryFlags 256) >= 128) then ( setTVFace DFFmesh i a1 a2 a3 )
		if (mod GeometryFlags 16) >= 8 then ( setVCFace DFFmesh i a1 a2 a3 )
		if t2count == 2 then meshop.setMapFace DFFmesh 2 i [a1, a2, a3]
		meshop.setMapFace DFFmesh -2 i [a1, a2, a3]
	)--end for i

	--Bounding Sphere--
	BoundingX = (readFloat f)  * Iscale
	BoundingY = (readFloat f)  * Iscale
	BoundingZ = (readFloat f)  * Iscale
	BoundingRadius = (readFloat f)  * Iscale
	readFloat f		--PositionFlag??
	readFloat f		--NormalsFlag??

	if isIplImport == false then pbUpdate()
	--Vertices--
	for i = 1 to vert_count do (
		tx = (readFloat f)  * Iscale
		ty = (readFloat f)  * Iscale
		tz = (readFloat f)  * Iscale
		setVert DFFmesh i tx ty tz
	)--end for i		

	if isIplImport == false then pbUpdate()
	--Normals--
	if (mod GeometryFlags 32) >= 16 then (
		for i = 1 to vert_count do (
			tx = readFloat f
			ty = readFloat f
			tz = readFloat f
			setNormal DFFmesh i [tx,ty,tz]
		)--end for i
	)--end Normals

if DebugMode == true then (
	global mtlflag = #()
	if (mod GeometryFlags 256) >= 128 then bol = true else bol = false
	setUserProp DFFmesh "Textured2" bol
	if (mod GeometryFlags 128) >= 64 then bol = true else bol = false
	setUserProp DFFmesh "ModulateMaterialColor" bol
	if (mod GeometryFlags 64) >= 32 then bol = true else bol = false
	setUserProp DFFmesh "Light" bol
	if (mod GeometryFlags 32) >= 16 then bol = true else bol = false
	setUserProp DFFmesh "Normal" bol
	if (mod GeometryFlags 16) >= 8 then bol = true else bol = false
	setUserProp DFFmesh "Prelit" bol
	if (mod GeometryFlags 8) >= 4 then bol = true else bol = false
	setUserProp DFFmesh "Textured" bol
	if (mod GeometryFlags 4) >= 2 then bol = true else bol = false
	setUserProp DFFmesh "Position" bol
	if (mod GeometryFlags 2) >= 1 then bol = true else bol = false
	setUserProp DFFmesh "TriStrip" bol	
)
	if isIplImport == false then pbUpdate()
    DFFmesh.material = rMaterialList f mattype texEx showdetail

if DebugMode == true then (
	if mtlflag[1] == true then setUserProp DFFmesh "Tex" true
	if mtlflag[2] == true then setUserProp DFFmesh "Alpha" true
	if mtlflag[3] == true then setUserProp DFFmesh "Ref" true
	if mtlflag[4] == true then setUserProp DFFmesh "SI" true
	if mtlflag[5] == true then setUserProp DFFmesh "SAS" true
)

    if (readLong f) != 3 then ( format "Error in Geometry Extension[Pos: %]\n"  (ftell f); exit )
	GExt = readLong f #unsigned
    if showdetail == true then format "\t\t\tExtension(3) size: %\n" GExt
	readLong f		--Version
	hh = false
	if GExt != 0 then (
		local Loop_end = (ftell f) + GExt
        while (ftell f) < Loop_end do (
			local header = readLong f
            local string_length = readLong f #unsigned
            ver = readLong f		--Version            
            
			case header of (		
				1294: (
					if showdetail == true then format "\t\t\t\tMaterialSplit(1294) Size: %\n" string_length 
					if isIplImport == false then pbUpdate()
					tmp = rMaterialSplit DFFmesh f showdetail
					if tmp == undefined then return undefined
				)
				261: (
					if showdetail == true then format "\t\t\t\tMorph(261) Size: %\n" string_length
					fseek f string_length #seek_cur
				)
				278: (
					if showdetail == true then format "\t\t\t\tSkin(278) Size: %\n" string_length
					if isIplImport == false then pbUpdate()
					SkinData = rSkinPLG f string_length vert_count ver
				)
				39056121: (
					if isIplImport == false then pbUpdate()
					gg = (ftell f)
					rNVC DFFmesh f
					fseek f gg #seek_set
					fseek f string_length #seek_cur
				)
				39056120:(
					if isIplImport == false then pbUpdate()
					gg = (ftell f)
					r2DFX DFFmesh string_length f
					fseek f gg #seek_set
					fseek f string_length #seek_cur
				)
				default: (
					if showdetail == true then format "\t\t\t\tunknown(%) Size: %\n" header string_length
					fseek f string_length #seek_cur
				)
			)--end case
		)--end while
	)--end if GExt
	update DFFmesh
	return DFFmesh
)

--end fn rGeometry			--<i9>--
--

--M------------
--Main Import--
---------------
fn DFFin f Iscale mattype texEx Dummysize autoskin showdetail setsname = (
	imp2dfxCount = 0
	impHas2dfx = false
	local RootObj
	local firstRootName = false
    lightArr_ = #()
	bkupadd = ftell f
	sLDffNow = ""
	sLDffMax = ""
	
    if (LetsRockandRoll != True) then (
        Zmodlocked = CheckZmodLock f
		if Zmodlocked == true then messagebox "This DFF is locked !\nThe author of this model do not allow you to modify it.\n\nPlease contact the author for the permission." title:"Import Failed"
	) else ( Zmodlocked = false )

	if Zmodlocked != true then (
    
		fseek f bkupadd #seek_set

		if showdetail == true then clearlistener()
		SkinData = undefined
		cpary = rClump f showdetail
		FrameAry = rFrameList f Iscale showdetail
		NumGeo = rGeometryList f showdetail
		
		MshAry = #()
		popPrompt()
		if cntLDffNow != 0 and cntLDffMax != 0 then (
			sLDffNow = cntLDffNow as string
			sLDffMax = cntLDffMax as string
		) else (
			sLDffNow = ""
			sLDffMax = ""
		)
		pushPrompt ("Import DFF " + "(" + sLDffNow + "/" + sLDffMax + "): " + (setsname as string) + " - read geometry...")
		for i = 1 to NumGeo do (
			if isIplImport == false then pbUpdate()
			msh = rGeometry f Iscale mattype texEx showdetail 
			if msh == undefined then (return undefined)
			
			append MshAry msh
		)
		if isIplImport == false then pbUpdate()
		popPrompt()
		if cntLDffNow != 0 and cntLDffMax != 0 then (
			sLDffNow = cntLDffNow as string
			sLDffMax = cntLDffMax as string
		) else (
			sLDffNow = ""
			sLDffMax = ""
		)
		pushPrompt ("Import DFF " + "(" + sLDffNow + "/" + sLDffMax + "): " + (setsname as string) + " - read atomic...")
		while (readLong f) != 3 do (
			fseek f -4 #seek_cur
			local Idx = rAtomic f showdetail
			if Idx.count == 3 then FrameAry[(Idx[1])].obj = Idx[2]
			else if Idx != undefined then (
				if (SkinData != undefined)AND(cpary[2] == 0x1803FFFF)AND(NumGeo == 1) then (
					FrameAry[1].transform = FrameAry[(Idx[1])].transform 	
					FrameAry[1].obj = MshAry[1]
				) else FrameAry[(Idx[1])].obj = MshAry[(Idx[2])]
			)
			
if DebugMode == true then ( try(setUserProp MshAry[(Idx[2])] "ATM" Idx[4])catch() )
			
		)

		if showdetail == true then format "Clump END--> %\n\n" ((ftell f) + 8)
			for i = 1 to FrameAry.count do (
				if FrameAry[i].obj == undefined then 				
						FrameAry[i].obj = dummy boxsize:( [1,1,1] * Dummysize * Iscale )
				if FrameAry[i].name != undefined then (
					setUserProp FrameAry[i].obj "FrameName" (stripSpace FrameAry[i].name)
					FrameAry[i].obj.name = FrameAry[i].name
				)
			)
        
		--Here re-calculate transform form IBM--
		--> inverse(this.transform) is transform in related to world
		if (SkinData != undefined) then (
			popPrompt()
			pushPrompt ("Import DFF: " + (setsname as string) + " - read skin data...")
			FrameAry[1].obj.transform = FrameAry[1].transform
			FrameAry[1].obj.pos = FrameAry[1].obj.pos * Iscale
			RootObj = FrameAry[1].obj
			
			ibm = SkinData[3]
			--for tf in ibm do format "%\n" tf
			for i = 1 to ibm.count do (
				ibm[i].pos = ibm[i].pos * Iscale
				fms = for fm in FrameAry where (getUserProp fm.obj "BoneIndex") == (i - 1) collect fm
				if i == 1 then (
					setUserProp fms[1].obj "SPunknown" SkinData[4]
					fms[1].obj.transform = ibm[i] * FrameAry[1].obj.transform
					--format ">>%\n" fms[1].obj.transform
				) else (
					fms[1].obj.transform = inverse(ibm[i]) * FrameAry[1].obj.transform --* FrameAry[pid].transform
					fms[1].obj.parent = FrameAry[(fms[1].parentID)].obj
					if showdetail == true then format "% -> %\n" fms[1].obj.name FrameAry[(fms[1].parentID)].obj.name
				)
			)--end for i

			--check for max version, if < v4 then no auto skin--
			----------------------------------------------------
			mv = maxVersion()
			if mv[1] < 4000 then (
				if autoskin == true then	format "\nNo Auto Skin in Max3!!!\n\n"
				autoskin = false
			)

		) else (
			for i = 1 to FrameAry.count do (
				if (FrameAry[i].parentID == 0)OR( (SkinData != undefined)AND(FrameAry[i].parentID == 1) ) then ( 
					FrameAry[i].obj.transform = FrameAry[i].transform
					if FrameAry[i].parentID == 0 then RootObj = FrameAry[i].obj  
				) else ( 
					bkup = FrameAry[(FrameAry[i].parentID)].obj.transform
					FrameAry[(FrameAry[i].parentID)].obj.transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])
					--FrameAry[i].obj.transform = FrameAry[i].transform * inverse( FrameAry[(FrameAry[i].parentID)].obj.transform )
					FrameAry[i].obj.parent = FrameAry[(FrameAry[i].parentID)].obj				
					if showdetail == true then format "% -> %\n" FrameAry[i].obj.name FrameAry[(FrameAry[i].parentID)].obj.name
					FrameAry[i].obj.transform = FrameAry[i].transform
					FrameAry[(FrameAry[i].parentID)].obj.transform = bkup
				)
			)--end for i
		)

		if (autoskin == true)AND(SkinData != undefined) then (
			skn = skin()
				
			max modify mode
			select RootObj
			addmodifier RootObj skn
			for ii = 1 to ibm.count do (
				tmp = for fm in FrameAry where (getUserProp fm.obj "BoneIndex") == (ii - 1) collect fm.obj
				skinOps.addbone skn tmp[1] 0

				for jj = 1 to 2 do (
					skinOps.SetInnerRadius skn ii jj 0
					skinOps.SetOuterRadius skn ii jj 0
				)

			)--end for ii
			format "\nSkinning... Please Wait\n"
			for jj = 1 to $.numVerts do (
				skinOps.SetVertexWeights skn jj SkinData[1][jj] SkinData[2][jj]
			)
			format "Done!\n"	
		)--end if autoskin

		if setsname != undefined then (
			allObjs = for fm in FrameAry collect fm.obj
			selectionSets[setsname] = allObjs
		)
		
		try (
			if impHas2dfx == true and lightArr_.count > 0 then (
				for i = 1 to lightArr_.count do (	   
					newLight = lightArr_[i]
					newLight.pos.x = s_2dfinfo.v2d_L_posX[i]
					newLight.pos.y = s_2dfinfo.v2d_L_posY[i]
					newLight.pos.z = s_2dfinfo.v2d_L_posZ[i]
					
					--format "%\n" ([s_2dfinfo.v2d_L_posX[i],s_2dfinfo.v2d_L_posY[i],s_2dfinfo.v2d_L_posZ[i]])
					newLight.name = "2dfx" + i as string
					popPrompt()
					if cntLDffNow != 0 and cntLDffMax != 0 then (
						sLDffNow = cntLDffNow as string
						sLDffMax = cntLDffMax as string
					) else (
						sLDffNow = ""
						sLDffMax = ""
					)
					pushPrompt ("Import DFF " + "(" + sLDffNow + "/" + sLDffMax + "): " + (setsname as string) + " - read 2dfx...")
					newLight.color = s_2dfinfo.v2d_L_color[i]
					newLight.pos = [s_2dfinfo.v2d_L_posX[i],s_2dfinfo.v2d_L_posY[i],s_2dfinfo.v2d_L_posZ[i]]
					setUserProp newLight "2d_L_Dist" s_2dfinfo.v2d_L_Dist[i]
					setUserProp newLight "2d_L_OutRange" s_2dfinfo.v2d_L_OutRange[i]
					setUserProp newLight "2d_L_Size" s_2dfinfo.v2d_L_Size[i]
					setUserProp newLight "2d_L_ShSize" s_2dfinfo.v2d_L_ShSize[i]
					setUserProp newLight "2d_L_ShowMode" s_2dfinfo.v2d_L_ShowMode[i]
					setUserProp newLight "2d_L_Refl" s_2dfinfo.v2d_L_Refl[i]
					setUserProp newLight "2d_L_coronaFlareType" s_2dfinfo.v2d_L_coronaFlareType[i]
					setUserProp newLight "2d_L_shadowColorMultiplier" s_2dfinfo.v2d_L_shadowColorMultiplier[i]				
					setUserProp newLight "2d_L_Flags1" s_2dfinfo.v2d_L_Flags1[i]
					setUserProp newLight "2d_L_CoroneName" s_2dfinfo.v2d_L_CoroneName[i]
					setUserProp newLight "2d_L_shadowName" s_2dfinfo.v2d_L_shadowName[i]
					setUserProp newLight "2d_L_shadowZDistance" s_2dfinfo.v2d_L_shadowZDistance[i]
					setUserProp newLight "2d_L_Flags2" s_2dfinfo.v2d_L_Flags2[i]
					setUserProp newLight "2d_L_DirectionX" s_2dfinfo.v2d_L_DirectionX[i]
					setUserProp newLight "2d_L_DirectionY" s_2dfinfo.v2d_L_DirectionY[i]
					setUserProp newLight "2d_L_DirectionZ" s_2dfinfo.v2d_L_DirectionZ[i]
					if MshAry.count == 1 then newLight.parent = MshAry[1]						
				)
			)
		) catch (format "Error set 2dfx param\n")
		gc()
		try (if RootObj.count > 1 then firstRootName = true) catch ()
		if RootObj != undefined and firstRootName == false then RootObj.name = setsname
		popPrompt()
		if cntLDffNow != 0 and cntLDffMax != 0 then (
			sLDffNow = cntLDffNow as string
			sLDffMax = cntLDffMax as string
		) else (
			sLDffNow = ""
			sLDffMax = ""
		)
		pushPrompt ("Import DFF " + "(" + sLDffNow + "/" + sLDffMax + "): " + " Done!")
		return RootObj

	) else (
        return undefined
    )--end if/else Zmodlocked

)--end fn DFFin

fn DFFinInfo = (
	format "\nDFFin SA function\n"
	format "\n"
    format " - Complete new Bones/Skin functions\n"
	format " - Second UV Map Skipped!\n"
	format " - Material Matching based on ashdexx's explanation, many thanks!\n"
	format " - new GTA Material added\n"
	format " - rwLight try (some data skipped)\n"
--	format " - dff form Zmod2 should import correctly\n"
--	format " - debugmode for internal use\n"
	format " - Non-Standard dff import disabled\n"
	format "\nby Kam\t\t15Dec05\nkam.lai@ntlworld.com\n\n"
    
    return (051215)
)