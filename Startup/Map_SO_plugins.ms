plugin geometry GTAcull 
    name:"Cull" 
    classID:#(0x48274273, 0x62702855) 
    extends:box
    replaceUI:true 
	invisible:true 
(
	parameters main rollout:params 
	(
		length type:#worldUnits default:1  ui:clen
		width  type:#worldUnits default:1  ui:cwid
        height type:#worldUnits default:1  ui:chei
		effect  type:#integer      default:65535  ui:ceff
		e1 type:#boolean default:false ui:e1
		e2 type:#boolean default:false ui:e2
		e3 type:#boolean default:false ui:e3
		e4 type:#boolean default:false ui:e4
		e5 type:#boolean default:false ui:e5
		e6 type:#boolean default:false ui:e6
		e7 type:#boolean default:false ui:e7
		e8 type:#boolean default:false ui:e8
		e9 type:#boolean default:false ui:e9
		e10 type:#boolean default:false ui:e10
		e11 type:#boolean default:false ui:e11
		e12 type:#boolean default:false ui:e12
		e13 type:#boolean default:false ui:e13
		e14 type:#boolean default:false ui:e14
		e15 type:#boolean default:false ui:e15
		e16 type:#boolean default:false ui:e16
		on width set val do delegate.width = width
		on length set val do delegate.length = length
		on height set val do delegate.height = height
		on e1  set val do if val == true then effect += 1 else effect -= 1
		on e2  set val do if val == true then effect += 2 else effect -= 2
		on e3  set val do if val == true then effect += 4 else effect -= 4
		on e4  set val do if val == true then effect += 8 else effect -= 8
		on e5  set val do if val == true then effect += 16 else effect -= 16
		on e6  set val do if val == true then effect += 32 else effect -= 32
		on e7  set val do if val == true then effect += 64 else effect -= 64
		on e8  set val do if val == true then effect += 128 else effect -= 128
		on e9  set val do if val == true then effect += 256 else effect -= 256
		on e10 set val do if val == true then effect += 512 else effect -= 512
		on e11 set val do if val == true then effect += 1024 else effect -= 1024
		on e12 set val do if val == true then effect += 2048 else effect -= 2048
		on e13 set val do if val == true then effect += 4096 else effect -= 4096
		on e14 set val do if val == true then effect += 8192 else effect -= 8192
		on e15 set val do if val == true then effect += 16384 else effect -= 16384
		on e16 set val do if val == true then effect += 32768 else effect -= 32768
	)
	rollout params "Cull Parameters" (
		spinner clen "Length:"
		spinner cwid "Width:"
		spinner chei "Height:"
        label lbleff "Effect: " align:#right across:2
		spinner ceff "" type:#integer range:[0,65536,0] fieldwidth:60 enabled:false align:#right
		checkbox e1 "Closeup" across:2
		checkbox e2 "Far Tracks" --align:#left
		checkbox e3 "" across:2
		checkbox e4 "No Rain"
		checkbox e5 "" across:2
		checkbox e6 ""
		checkbox e7 "" across:2
		checkbox e8 ""
		checkbox e9 "" across:2
		checkbox e10 ""
		checkbox e11 "No Water" across:2
		checkbox e12 ""
		checkbox e13 "" across:2
		checkbox e14 ""
		checkbox e15 "" across:2
		checkbox e16 ""
    )
    on load do (
		effect = 65535
		if e1 == true then effect -= 1 --else tvp += 1
		if e2 == true then effect -= 2 --else tvp += 2
		if e3 == true then effect -= 4 --else tvp += 4
		if e4 == true then effect -= 8 --else tvp += 8
		if e5 == true then effect -= 16 --else tvp += 16
		if e6 == true then effect -= 32 --else tvp += 32
		if e7 == true then effect -= 64 --else tvp += 64
		if e8 == true then effect -= 128 --else tvp += 128
		if e9 == true then effect -= 256 --else tvp += 256
		if e10 == true then effect -= 512 --else tvp += 512
		if e11 == true then effect -= 1024 --else tvp += 1024
		if e12 == true then effect -= 2048 --else tvp += 2048
		if e13 == true then effect -= 4096 --else tvp += 4096
		if e14 == true then effect -= 8192 --else tvp += 8192
		if e15 == true then effect -= 16384 --else tvp += 16384
		if e16 == true then effect -= 32768 --else tvp += 32768
    )
)
--
plugin simpleObject GTAgrge 
    name:"Grge" 
    classID:#(0x48274273, 0x62704743) 
	invisible:true 
(
	parameters main rollout:params (
		length type:#worldUnits default:1  ui:glength
		width  type:#worldUnits default:1  ui:gwidth
		height type:#worldUnits default:1  ui:gheight
		flag   type:#integer default:0 ui:gflag
		type   type:#integer default:0 ui:gtype
		text   type:#string default:"" ui:gname --"
	)
	rollout params "Grge Parameters" (
		spinner glength "Length:" align:#right
		spinner gwidth "Width:" align:#right
		spinner gheight "Heigth:" align:#right
		spinner gflag "Flag:" type:#integer align:#right
		spinner gtype "Type:" type:#integer align:#right
		edittext gname "Text:" align:#right
	)
	on buildMesh do (
		setMesh mesh verts:#([(-0.5*width),(-0.5*length),0], \ 
			[(0.5*width),(-0.5*length),0],[(-0.5*width),(0.5*length),height], \ 
			[(0.5*width),(0.5*length),0],[(-0.5*width),(-0.5*length),height], \ 
			[(0.5*width),(-0.5*length),height],[(-0.5*width),(0.5*length),0], \ 
			[(0.5*width),(0.5*length),height],[(-0.5*width),(-0.4*length),height], \ 
			[(-0.5*width),(0.4*length),height],[(0.5*width),(-0.4*length),height], \ 
			[(0.5*width),(0.4*length),height]) \ 
		faces:#([5,6,8],[5,9,1],[9,5,1],[11,6,2],[6,11,2], \ 
			[8,4,12],[12,4,8],[5,8,3],[10,3,7],[7,3,10],[3,6,5], \ 
			[3,8,6])
	)
)
--
plugin simpleObject GTAexit
	name:"Exit"
	classID:#(0x48274273, 0x62703948) 
	invisible:true 
(
	parameters main rollout:params (
		size type:#float default:1 ui:vsize
	)
	rollout params "Exit Parameters" (
		spinner vsize "Visual Size:"
	)
	on buildMesh do (
		setMesh mesh verts:#([(-0.4*size),(-0.2*size),(0.9*size)], \ 
			[(0.4*size),(-0.2*size),(0.9*size)],[(-0.5*size),(-0.3*size),size], \ 
			[(0.5*size),(-0.3*size),size],[(-0.5*size),(-0.1*size),size], \ 
			[(0.5*size),(-0.1*size),size],[(0.4*size),(-0.2*size),0], \ 
			[(0.5*size),(-0.3*size),0],[(0.5*size),(-0.0999999*size),0], \ 
			[(-0.4*size),(-0.2*size),0],[(-0.5*size),(-0.3*size),0], \ 
			[(-0.5*size),(-0.1*size),0],[(0.40005*size),(-0.2*size),0], \ 
			[(-0.3*size),(-0.5*size),0],[(0.40005*size),(-0.2*size),(0.9*size)], \ 
			[(-0.3*size),(-0.5*size),(0.9*size)],[0,(0.5*size),(0.5*size)], \ 
			[(-0.2*size),0,(0.3*size)],[(0.2*size),0,(0.3*size)], \ 
			[(-0.2*size),0,(0.7*size)],[(0.2*size),0,(0.7*size)]) \ 
		faces:#([3,4,6],[6,5,3],[1,2,4],[4,3,1],[2,1,5], \ 
			[5,6,2],[4,8,9],[9,6,4],[2,7,8],[8,4,2],[7,2,6],[6,9,7], \ 
			[11,3,5],[5,12,11],[10,1,3],[3,11,10],[1,10,12],[12,5,1], \ 
			[13,15,16],[16,14,13],[13,14,16],[16,15,13],[18,19,21], \ 
			[21,20,18],[19,18,17],[21,19,17],[20,21,17],[18,20,17])
	)
)
--
plugin simpleObject GTAenex
	name:"Enex"
	classID:#(0x48274273, 0x62703639) 
	invisible:true 
(
	parameters main rollout:params (
		length type:#float default:1 ui:elen
		width  type:#float default:1 ui:ewid
		angle  type:#angle default:0 ui:eang
		int2   type:#integer    default:0  ui:in2
		int1   type:#integer    default:0  ui:in1
		text   type:#string     default:"" ui:idna --"
		facing type:#angle      default:0  ui:lang
		I1 type:#integer  default:0  ui:unk1
		I2 type:#integer  default:0  ui:unk2
		time_on  type:#integer  default:0  ui:ton
		time_off type:#integer  default:24  ui:toff
		on angle set val do (
			if (classof $ == GTAenex)AND(classof $.children[1] == GTAexit) then (
				tmp = $.children[1].transform
				$.rotation.z_rotation = val
				$.children[1].transform = tmp
			)
		)
		on facing set val do (
			if (classof $ == GTAenex)AND(classof $.children[1] == GTAexit) then
				$.children[1].rotation.z_rotation = val
		)
	)
	rollout params "Enex Parameters" (
		group "Entrance" (
			spinner elen "Length:" fieldwidth:50
			spinner ewid "Width:" fieldwidth:50
			button udea "Update" width:40 align:#left offset:[0,-3] across:2
			spinner eang "Angle:" range:[-360,360,0] fieldwidth:50 align:#right
			spinner in1 "Interior: #" type:#integer fieldwidth:30 align:#right
			spinner in2 "Marker: #" type:#integer fieldwidth:30 align:#right
		)
		edittext idna "Name:"
		group "Exit" (
			button udla "Update" width:40 align:#left offset:[0,-3] across:2
			spinner lang "Angle:" range:[-360,360,0] fieldwidth:50 align:#right
			spinner unk1 "I1(?)" type:#integer fieldwidth:50
			spinner unk2 "I2(?)" type:#integer fieldwidth:50
		)
		group "Time" (
			spinner ton "On:" type:#integer range:[0,24,0] fieldwidth:50
			spinner toff "Off:" type:#integer range:[0,24,24] fieldwidth:50
		)
		on udea pressed do angle = $.rotation.z_rotation
		on udla pressed do 
			if (classof $.children[1] == GTAexit) then facing = $.children[1].rotation.z_rotation
	)
	on buildMesh do (
		setMesh mesh verts:#([(-0.4*width),(0.4*length),0.9], \ 
			[(0.4*width),(0.4*length),0.9],[(-0.5*width),(0.3*length),1], \ 
			[(0.5*width),(0.3*length),1],[(-0.5*width),(0.5*length),1], \ 
			[(0.5*width),(0.5*length),1],[(0.4*width),(0.4*length),0], \ 
			[(0.5*width),(0.3*length),0],[(0.5*width),(0.5*length),0], \ 
			[(-0.4*width),(0.4*length),0],[(-0.5*width),(0.3*length),0], \ 
			[(-0.5*width),(0.5*length),0],[(0.4*width),(0.4*length),0], \ 
			[(0.3*width),(-0.2*length),0],[(0.4*width),(0.4*length),0.9], \ 
			[(0.3*width),(-0.2*length),0.9],[0,0,(0.5*1)], \ 
			[(-0.2*width),(-0.5*length),0.3],[(0.2*width),(-0.5*length),0.3], \ 
			[(-0.2*width),(-0.5*length),0.7],[(0.2*width),(-0.5*length),0.7]) \ 
		faces:#([3,4,6],[6,5,3],[1,2,4],[4,3,1],[2,1,5], \ 
			[5,6,2],[4,8,9],[9,6,4],[2,7,8],[8,4,2],[7,2,6],[6,9,7], \ 
			[11,3,5],[5,12,11],[10,1,3],[3,11,10],[1,10,12],[12,5,1], \ 
			[13,15,16],[16,14,13],[13,14,16],[16,15,13],[18,19,21], \ 
			[21,20,18],[19,18,17],[21,19,17],[20,21,17],[18,20,17])
	)
)
--
plugin simpleObject GTApick 
	name:"Pick" 
	classID:#(0x48274273, 0x62707425) 
	invisible:true 
(
	local weapons = #("Bat","Shovel","Poolcue","Katana","Chainsaw",
			"Molotov","Grenades","Plastic Explosives","9mm","Silenced","Deagle",
			"Shotgun","Automatic shotgun","Tec 9","Micro SMG","SMG","AK74","M4","rifle",
			"Sniper rifle","Flamethrower","Minigun","Purple Dildo","White vibrator",
			"White Dildo","Vibrator","Flowers","Cane","Ringbox","Necklacebox","Nothing?",
			"Cellphone","Nothing?","Teargas","Minigun","Automatic Shotgun","Rocket Launcher",
			"Heat seeking rocket launcher","Detonator","Spray can","Fire Extinguisher",
			"Camera","Nightvision","Infrared","Jetpack","Parachute")
	parameters main rollout:params (
		item type:#integer default:10 ui:pitem
		size type:#float   default:1 ui:psize
		dmy  type:#String default:"" ui:pdmy --"
		on item set val do (
			if (val < 10)OR(val > 55) then dmy = "Unknown"
			else dmy = weapons[(val-9)]
		)
	)
	rollout params "Pick Parameters" (
		spinner pitem "Item # " fieldwidth:60 align:#right type:#integer
		editText pdmy "" enabled:false
		spinner psize "Visual Size:" 
		on item changed val do dmy = weapons[(val-9)]
	)
	on buildMesh do (
		setMesh mesh verts:#([(0.1*size),0,0],[(-0.05*size),(0.0867*size),0], \ 
			[(-0.05*size),(-0.0867*size),0],[(0.0*size),(0.0*size),(1.2*size)], \ 
			[(0.0*size),(0.0*size),(0.7*size)],[(0.574472*size),(-0.400642*size),(1.01612*size)], \ 
			[(0.0*size),(0.0*size),(1.2*size)],[(0.391281*size),(-0.280827*size),(1.13568*size)], \ 
			[(0.354494*size),(-0.206454*size),(0.786842*size)], \ 
			[(0.16862*size),(-0.232131*size),(0.782295*size)], \ 
			[(0.0398633*size),(-0.145775*size),(1.10591*size)], \ 
			[(0.324497*size),(0.384929*size),0],[(0.5012*size),(0.0454845*size),0], \ 
			[(-0.040475*size),(0.500004*size),0],[(-0.379919*size),(0.3233*size),0], \ 
			[(-0.494994*size),(-0.0416713*size),0],[(-0.318291*size),(-0.381116*size),0], \ 
			[(0.0466809*size),(-0.496191*size),0],[(0.386125*size),(-0.319487*size),0]) \ 
		faces:#([1,2,4],[2,3,4],[3,1,4],[8,9,6],[8,6,9], \ 
			[7,1,2],[5,11,10],[7,5,11],[8,11,10],[7,11,5],[8,9,10], \ 
			[8,10,9],[11,8,10],[11,5,10],[12,14,15],[12,15,16], \ 
			[12,16,17],[12,17,18],[12,18,19],[12,19,13])
	)
)
--
plugin simpleObject GTAcars
	name:"Cars" 
	classID:#(0x48274273, 0x62702277) 
	invisible:true 
(
	parameters main rollout:params (
		size     type:#float   default:1 ui:psize
		angle    type:#angle default:0 ui:cang
		u1       type:#integer default:0 ui:cu1
		u2       type:#integer default:(-1) ui:cu2
		u3       type:#integer default:(-1) ui:cu3
		id       type:#integer default:(-1) ui:cid
		color1   type:#integer default:(-1) ui:cpcol
		color2   type:#integer default:(-1) ui:cscol
		alarm    type:#integer default:0 ui:calm
		doorlock type:#integer default:0 ui:cdor
		on angle set val do (
			if (classof $ == GTAcars) then $.rotation.z_rotation = val
		)
	)
	rollout params "Cars Parameters" (
		button udca "Update" width:40 align:#left offset:[0,-3] across:2
		spinner cang "Angle:" range:[-360,360,0] fieldwidth:50 align:#right
		spinner cid "ID #" type:#integer range:[-1,999,-1] fieldwidth:30
		spinner cpcol "Primary Color #" type:#integer range:[-1,999,-1] fieldwidth:30
		spinner cscol "Secondary Color #" type:#integer range:[-1,999,-1] fieldwidth:30
		spinner cu1 "unknown1:" type:#integer fieldwidth:30
		spinner calm "Alarm On Chance:" type:#integer fieldwidth:30
		spinner cdor "Door Lock Chance:" type:#integer fieldwidth:30
		spinner cu2 "unknown2:" type:#integer range:[-1,999,-1] fieldwidth:30
		spinner cu3 "unknown3:" type:#integer range:[-1,999,-1] fieldwidth:30
		group "" (
			spinner psize "Visual Size:" 
		)
		on udca pressed do angle = $.rotation.z_rotation
	)
	on buildMesh do (
		setmesh mesh verts:#([(-0.5*size),size,0],[(-0.5*size),(-1.0*size),0], \
			[(0.5*size),size,0],[(0.5*size),(-1.0*size),0],[(-0.4*size),size,(0.3*size)], \
			[(-0.5*size),(0.4*size),(0.6*size)],[(-0.5*size),(-0.55*size),(0.6*size)], \
			[(-0.5*size),(-1*size),(0.6*size)],[(0.4*size),size,(0.3*size)],[(0.5*size),(0.4*size),(0.6*size)], \
            [(0.5*size),(-0.55*size),(0.6*size)],[(0.5*size),(-1*size),(0.6*size)],[(-0.4*size),(0.15*size),size], \
			[(-0.4*size),(-0.55*size),size],[(0.4*size),(0.15*size),size],[(0.4*size),(-0.55*size),size]) \
		faces:#([5,6,10],[10,9,5],[13,14,16],[16,15,13],[7,8,12],[12,11,7],[6,5,1],[7,6,1],[7,2,8], \
			[2,7,1],[2,4,12],[12,8,2],[4,3,11],[11,12,4],[10,11,3],[9,10,3],[3,1,5],[5,9,3],[10,6,13], \
			[13,15,10],[6,7,14],[14,13,6],[7,11,16],[16,14,7],[11,10,15],[15,16,11])
	)
)
plugin simpleObject GTAauzo 
	name:"Auzo" 
	classID:#(0x48274273, 0x62702896) 
	invisible:true 
(
	parameters main rollout:params (
		length type:#worldUnits default:1  ui:alen
		width  type:#worldUnits default:1  ui:awid
        height type:#worldUnits default:1  ui:ahei
		text  type:#String default:"" ui:aname --"
		u1 type:#integer default:0 ui:au1
		u2 type:#integer default:0 ui:au2
	)
	rollout params "Auzo Parameters" (
		spinner alen "Length:"
		spinner awid "Width:"
		spinner ahei "Height:"
		editText aname "Name:" 
		spinner au1 "unknown1:" type:#integer 
		spinner au2 "unknown2:" type:#integer 
		on item changed val do dmy = weapons[(val-9)]
	)
	on buildMesh do (
		setMesh mesh verts:#([(-0.3*width),(-0.3*length),(0.2*height)], \ 
			[(-0.3*width),(-0.3*length),(0.1*height)],[(-0.5*width),(-0.3*length),(0.1*height)], \ 
			[(-0.5*width),(-0.5*length),(0.1*height)],[(-0.3*width),(-0.5*length),(0.1*height)], \ 
			[(-0.4*width),(-0.4*length),0],[(0.3*width),(0.3*length),(0.3*height)], \ 
			[(0.3*width),(0.3*length),(0.2*height)],[(0.1*width),(0.3*length),(0.2*height)], \ 
			[(0.1*width),(0.1*length),(0.2*height)],[(0.3*width),(0.1*length),(0.2*height)], \ 
			[(0.2*width),(0.2*length),(0.1*height)],[(-0.2*width),(-0.2*length),(0.9*height)], \ 
			[(-0.2*width),(-0.2*length),height],[(0.5*width),(0.5*length),height], \ 
			[(0.5*width),(0.5*length),(0.9*height)],[(0.4*width),(0.4*length),(0.9*height)], \ 
			[(-0.1*width),(-0.1*length),(0.9*height)],[(-0.5*width),(-0.5*length),0], \ 
			[(0.5*width),(-0.5*length),0],[(-0.5*width),(0.5*length),0], \ 
			[(0.5*width),(0.5*length),0],[(0.3*width),(0.5*length),0], \ 
			[(-0.3*width),(0.5*length),0],[(-0.5*width),(0.3*length),0], \ 
			[(0.5*width),(0.3*length),0],[(0.5*width),(-0.3*length),0], \ 
			[(0.3*width),(-0.5*length),0],[(-0.5*width),(-0.3*length),0], \ 
			[(-0.3*width),(-0.5*length),0]) \ 
		faces:#([1,2,3],[1,3,4],[1,4,5],[1,5,2],[6,3,2], \ 
			[6,4,3],[6,5,4],[6,2,5],[7,8,9],[7,9,10],[7,10,11], \ 
			[7,11,8],[12,9,8],[12,10,9],[12,11,10],[12,8,11],[18,1,13], \ 
			[16,7,17],[1,18,13],[7,16,17],[13,16,15],[13,15,14], \ 
			[16,13,14],[14,15,16],[29,19,30],[28,20,27],[26,22,23], \ 
			[24,21,25])
	)
)
--
plugin geometry GTAoccl
    name:"Occl" 
    classID:#(0x48274273, 0x62706225) 
    extends:box
    replaceUI:true 
	invisible:true 
(
	parameters main rollout:params 
	(
		length type:#worldUnits default:1  ui:olen
		width  type:#worldUnits default:1  ui:owid
		height type:#worldUnits default:1  ui:ohei
		angle  type:#angle default:0 ui:orot
		on width set val do delegate.width = width
		on length set val do delegate.length = length
		on height set val do delegate.height = height
		on angle set val do (
			if (classof $ == GTAoccl) then $.rotation.z_rotation = val
		)
	)
	rollout params "Occl Parameters" (
		spinner olen "Length:" fieldwidth:50
		spinner owid "Width:" fieldwidth:50
		spinner ohei "Height:" fieldwidth:50
		button udor "Update" width:40 align:#left offset:[0,-3] across:2
		spinner orot "Angle:" range:[-360,360,0] fieldwidth:50 align:#right
		on udor pressed do angle = $.rotation.z_rotation
	)
)
--
plugin simpleObject GTAjcam
	name:"Jump Camera"
	classID:#(0x48274273, 0x62705226) 
	invisible:true 
(
	parameters main rollout:params (
		size type:#float default:1 ui:vsize
	)
	rollout params "Jump Camera Parameters" (
		spinner vsize "Visual Size:"
	)
	on buildMesh do (
		setMesh mesh verts:#([(-0.3*size),(-0.25*size),(-0.1*size)], \ 
			[(0.3*size),(-0.25*size),(-0.1*size)],[(-0.3*size),(0.25*size),(-0.1*size)], \ 
			[(0.3*size),(0.25*size),(-0.1*size)],[(-0.3*size),(-0.25*size),(0.3*size)], \ 
			[(0.3*size),(-0.25*size),(0.3*size)],[(-0.3*size),(0.25*size),(0.3*size)], \ 
			[(0.3*size),(0.25*size),(0.3*size)],[(0.2*size),(0.0*size),(-0.3*size)], \ 
			[(0.1*size),(0.173205*size),(-0.3*size)],[(-0.1*size),(0.173205*size),(-0.3*size)], \ 
			[(-0.2*size),(0.0*size),(-0.3*size)],[(-0.1*size),(-0.173205*size),(-0.3*size)], \ 
			[(0.1*size),(-0.173205*size),(-0.3*size)],[(0.15*size),(0.0*size),(-0.1*size)], \ 
			[(0.075*size),(0.129904*size),(-0.1*size)],[(-0.075*size),(0.129904*size),(-0.1*size)], \ 
			[(-0.15*size),(0.0*size),(-0.1*size)],[(-0.075*size),(-0.129904*size),(-0.1*size)], \ 
			[(0.075*size),(-0.129904*size),(-0.1*size)]) \ 
		faces:#([1,3,4],[4,2,1],[5,6,8],[8,7,5],[1,2,6], \ 
			[6,5,1],[2,4,8],[8,6,2],[4,3,7],[7,8,4],[3,1,5],[5,7,3], \ 
			[9,11,10],[9,12,11],[9,13,12],[9,14,13],[9,16,15], \ 
			[9,10,16],[10,17,16],[10,11,17],[11,18,17],[11,12,18], \ 
			[12,19,18],[12,13,19],[13,20,19],[13,14,20],[14,15,20], \ 
			[14,9,15])
	)
)
--
plugin simpleObject GTAjump
	name:"Jump Start"
	classID:#(0x48274273, 0x62705867) 
	invisible:true 
(
	parameters main rollout:params (
		length type:#worldUnits default:1  ui:olen
		width  type:#worldUnits default:1  ui:owid
		height type:#worldUnits default:1  ui:ohei
	)
	rollout params "Jump Start Parameters" (
		spinner olen "Length:"
		spinner owid "Width:"
		spinner ohei "Height:"
	)
	on buildMesh do (
		setMesh mesh verts:#([(0.4*width),0,(-0.5*height)], \ 
			[(0.283*width),(0.283*length),(-0.5*height)],[0,(0.4*length),(-0.5*height)], \ 
			[(-0.283*width),(0.283*length),(-0.5*height)],[(-0.4*width),0,(-0.5*height)], \ 
			[(-0.283*width),(-0.283*length),(-0.5*height)],[0,(-0.4*length),(-0.5*height)], \ 
			[(0.283*width),(-0.283*length),(-0.5*height)],[(0.5*width),0,(-0.3*height)], \ 
			[(0.354*width),(0.354*length),(-0.3*height)],[0,(0.5*length),(-0.3*height)], \ 
			[(-0.354*width),(0.354*length),(-0.3*height)],[(-0.5*width),0,(-0.3*height)], \ 
			[(-0.354*width),(-0.354*length),(-0.3*height)],[0,(-0.5*length),(-0.3*height)], \ 
			[(0.354*width),(-0.354*length),(-0.3*height)],[0,0,(0.5*height)], \ 
			[(-0.1*width),(0.1*length),(-0.1*height)],[(0.1*width),(0.1*length),(-0.1*height)], \ 
			[(-0.1*width),(-0.1*length),(-0.1*height)],[(0.1*width),(-0.1*length),(-0.1*height)]) \ 
		faces:#([1,10,9],[1,2,10],[2,11,10],[2,3,11],[3,12,11], \ 
			[3,4,12],[4,13,12],[4,5,13],[5,14,13],[5,6,14],[6,15,14], \ 
			[6,7,15],[7,16,15],[7,8,16],[8,9,16],[8,1,9],[11,9,10], \ 
			[11,12,13],[11,13,14],[11,14,15],[11,15,16],[11,16,9], \ 
			[18,19,21],[21,20,18],[19,18,17],[21,19,17],[20,21,17], \ 
			[18,20,17])
	)
)
--
plugin simpleObject GTAland
	name:"Jump"
	classID:#(0x48274273, 0x62705263) 
	invisible:true 
(
	parameters main rollout:params (
		length type:#worldUnits default:1  ui:olen
		width  type:#worldUnits default:1  ui:owid
		height type:#worldUnits default:1  ui:ohei
		reward type:#integer default:0 ui:jrwd
	)
	rollout params "Jump Land Parameters" (
		spinner olen "Length:"
		spinner owid "Width:"
		spinner ohei "Height:"
		spinner jrwd "Reward:" type:#integer range:[-99999,99999,0]
	)
	on buildMesh do (
		setMesh mesh verts:#([(0.5*width),0,(-0.5*height)], \ 
			[(0.353553*width),(0.353553*length),(-0.5*height)], \ 
			[0,(0.5*length),(-0.5*height)],[(-0.353553*width),(0.353553*length),(-0.5*height)], \ 
			[(-0.5*width),0,(-0.5*height)],[(-0.353553*width),(-0.353553*length),(-0.5*height)], \ 
			[0,(-0.5*length),(-0.5*height)],[(0.353553*width),(-0.353553*length),(-0.5*height)], \ 
			[(0.4*width),0,(-0.3*height)],[(0.282843*width),(0.282843*length),(-0.3*height)], \ 
			[0,(0.4*length),(-0.3*height)],[(-0.282843*width),(0.282843*length),(-0.3*height)], \ 
			[(-0.4*width),0,(-0.3*height)],[(-0.282843*width),(-0.282843*length),(-0.3*height)], \ 
			[0,(-0.4*length),(-0.3*height)],[(0.282843*width),(-0.282843*length),(-0.3*height)], \ 
			[0,0,(-0.1*height)],[(-0.1*width),(-0.1*length),(0.5*height)], \ 
			[(0.1*width),(-0.1*length),(0.5*height)],[(-0.1*width),(0.1*length),(0.5*height)], \ 
			[(0.1*width),(0.1*length),(0.5*height)]) \ 
		faces:#([1,10,9],[1,2,10],[2,11,10],[2,3,11],[3,12,11], \ 
			[3,4,12],[4,13,12],[4,5,13],[5,14,13],[5,6,14],[6,15,14], \ 
			[6,7,15],[7,16,15],[7,8,16],[8,9,16],[8,1,9],[11,9,10], \ 
			[11,12,13],[11,13,14],[11,14,15],[11,15,16],[11,16,9], \ 
			[18,19,21],[21,20,18],[19,18,17],[21,19,17],[20,21,17], \ 
			[18,20,17])
	)
)
--
