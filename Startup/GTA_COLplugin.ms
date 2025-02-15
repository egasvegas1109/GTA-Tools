--28Sep05 Updated--
--GTA3/VC Surface text added
plugin Material GTA_COLSurface
    name:"GTA COL Surface"
    classID:#(0x48238272, 0x26507873)
	extends:Standard replaceUI:true 
(
local SurfAry = #( "DEFAULT",
 "TARMAC", "TARMAC_FUCKED", "TARMAC_REALLYFUCKED", "PAVEMENT", "PAVEMENT_FUCKED",
 "GRAVEL", "FUCKED_CONCRETE", "PAINTED_GROUND", "GRASS_SHORT_LUSH", "GRASS_MEDIUM_LUSH",
 "GRASS_LONG_LUSH", "GRASS_SHORT_DRY", "GRASS_MEDIUM_DRY", "GRASS_LONG_DRY", "GOLFGRASS_ROUGH",
 "GOLFGRASS_SMOOTH", "STEEP_SLIDYGRASS", "STEEP_CLIFF", "FLOWERBED", "MEADOW",
 "WASTEGROUND", "WOODLANDGROUND", "VEGETATION", "MUD_WET", "MUD_DRY",
 "DIRT", "DIRTTRACK", "SAND_DEEP", "SAND_MEDIUM", "SAND_COMPACT",
 "SAND_ARID", "SAND_MORE", "SAND_BEACH", "CONCRETE_BEACH", "ROCK_DRY",
 "ROCK_WET", "ROCK_CLIFF", "WATER_RIVERBED", "WATER_SHALLOW", "CORNFIELD",
 "HEDGE", "WOOD_CRATES", "WOOD_SOLID", "WOOD_THIN", "GLASS",
 "GLASS_WINDOWS_LARGE", "GLASS_WINDOWS_SMALL", "EMPTY1", "EMPTY2", "GARAGE_DOOR",
 "THICK_METAL_PLATE", "SCAFFOLD_POLE", "LAMP_POST", "METAL_GATE", "METAL_CHAIN_FENCE",
 "GIRDER", "FIRE_HYDRANT", "CONTAINER", "NEWS_VENDOR", "WHEELBASE",
 "CARDBOARDBOX", "PED", "CAR", "CAR_PANEL", "CAR_MOVINGCOMPONENT",
 "TRANSPARENT_CLOTH", "RUBBER", "PLASTIC", "TRANSPARENT_STONE", "WOOD_BENCH",
 "CARPET", "FLOORBOARD", "STAIRSWOOD", "P_SAND", "P_SAND_DENSE",
 "P_SAND_ARID", "P_SAND_COMPACT", "P_SAND_ROCKY", "P_SANDBEACH", "P_GRASS_SHORT",
 "P_GRASS_MEADOW", "P_GRASS_DRY", "P_WOODLAND", "P_WOODDENSE", "P_ROADSIDE",
 "P_ROADSIDEDES", "P_FLOWERBED", "P_WASTEGROUND", "P_CONCRETE", "P_OFFICEDESK",
 "P_711SHELF1", "P_711SHELF2", "P_711SHELF3", "P_RESTUARANTTABLE", "P_BARTABLE",
 "P_UNDERWATERLUSH", "P_UNDERWATERBARREN", "P_UNDERWATERCORAL", "P_UNDERWATERDEEP", "P_RIVERBED",
 "P_RUBBLE", "P_BEDROOMFLOOR", "P_KIRCHENFLOOR", "P_LIVINGRMFLOOR", "P_CORRIDORFLOOR",
 "P_711FLOOR", "P_FASTFOODFLOOR", "P_SKANKYFLOOR", "P_MOUNTAIN", "P_MARSH",
 "P_BUSHY", "P_BUSHYMIX", "P_BUSHYDRY", "P_BUSHYMID", "P_GRASSWEEFLOWERS",
 "P_GRASSDRYTALL", "P_GRASSLUSHTALL", "P_GRASSGRNMIX", "P_GRASSBRNMIX", "P_GRASSLOW",
 "P_GRASSROCKY", "P_GRASSSMALLTREES", "P_DIRTROCKY", "P_DIRTWEEDS", "P_GRASSWEEDS",
 "P_RIVEREDGE", "P_POOLSIDE", "P_FORESTSTUMPS", "P_FORESTSTICKS", "P_FORRESTLEAVES",
 "P_DESERTROCKS", "P_FORRESTDRY", "P_SPARSEFLOWERS", "P_BUILDINGSITE", "P_DOCKLANDS",
 "P_INDUSTRIAL", "P_INDUSTJETTY", "P_CONCRETELITTER", "P_ALLEYRUBISH", "P_JUNKYARDPILES",
 "P_JUNKYARDGRND", "P_DUMP", "P_CACTUSDENSE", "P_AIRPORTGRND", "P_CORNFIELD",
 "P_GRASSLIGHT", "P_GRASSLIGHTER", "P_GRASSLIGHTER2", "P_GRASSMID1", "P_GRASSMID2",
 "P_GRASSDARK", "P_GRASSDARK2", "P_GRASSDIRTMIX", "P_RIVERBEDSTONE", "P_RIVERBEDSHALLOW",
 "P_RIVERBEDWEEDS", "P_SEAWEED", "DOOR", "PLASTICBARRIER", "PARKGRASS",
 "STAIRSSTONE", "STAIRSMETAL", "STAIRSCARPET", "FLOORMETAL", "FLOORCONCRETE",
 "BIN_BAG", "THIN_METAL_SHEET", "METAL_BARREL", "PLASTIC_CONE", "PLASTIC_DUMPSTER",
 "METAL_DUMPSTER", "WOOD_PICKET_FENCE", "WOOD_SLATTED_FENCE", "WOOD_RANCH_FENCE", "UNBREAKABLE_GLASS",
 "HAY_BALE", "GORE", "RAILTRACK" )
local PartAry = #( "Special",	"Default",
    "Bonnet",            "Boot", 
	"Front Bumper",      "Rear Bumper",
	"Left Front Door",   "Right Front Door",
	"Left Rear Door",    "Right Rear Door",
	"Left Front Wing",   "Right Front Wing",
	"Left Rear Wing",    "Right Rear Wing",
	"ID 13","ID 14","ID 15","ID 16",			--13-16 are emply
	"Windscreen" )
local OldSurf = #( "Standard",
 "Street", "Grass", "Soil", "Dirt", "Beton",
 "Aluminum", "Glas", "Metal Pole", "Door", "Metal Sheet",
 "Metal", "Small Metal Post", "Large Metal Post", "Medium Metal Post", "Steel",
 "Fence", "Unused", "Sand", "Water", "Wooden Box",
 "Wooden Lathes", "Wood", "Metal Box", "Metal Box", "Hedge",
 "Rock", "Metal Container", "Metal Barrel", "Unused", "Metal Card Box",
 "Unused", "Gate/Bars", "Sand 2 (VC)", "Grass 2 (VC)" )
	parameters main rollout:params 
	(
		surface			type:#integer default:0	ui:msur
		part					type:#integer default:0	ui:mpar
		u1					type:#integer default:0xBB	ui:mu1
		u2					type:#integer default:0	ui:mu2
		surfacetext	type:#string default:"Default" ui:dsur	
		parttext	type:#string default:"Default" ui:dpar
		Oldsurftext	type:#string default:"Default" ui:Osur
		on surface set val do (
			if val == 0 then delegate.diffuse = color 255 255 255
			else (
				cs = mod val 3
		m		case cs of ( 
				0: delegate.diffuse = color (245-val) (235-val) (225-val)
				1: delegate.diffuse = color (235-val) (225-val) (245-val)
				2: delegate.diffuse = color (225-val) (245-val) (235-val)
				)
			)
			surfacetext = SurfAry[(val+1)]
			try ( Oldsurftext = OldSurf[(val+1)] ) catch ( Oldsurftext = "undefined" )
		)
		on part set val do (
			try ( parttext = PartAry[(val+2)] ) catch ( parttext = "unknown parts" )
		)
	)
	rollout params  "Collision Parameters"
	(
 		label info01 "This Shader only works with GTA Collision IO."
		label info02 "" 

		spinner 	msur "Surface#: " 	fieldwidth:45 type:#integer range:[0,178,0] align:#right across:2
		edittext 	dsur "" 			align:#right enabled:false 
		label       dmyX "GTA3/VC Surface: " align:#right across:2
 		edittext 	Osur "" 			align:#right enabled:false        
		spinner 	mpar "*Brightness/Part: " 		fieldwidth:45 type:#integer range:[-1,254,0] align:#right across:2
		edittext 	dpar "" 			align:#right enabled:false 
		spinner 	mu1	"Unknown 1:"	fieldwidth:45 type:#integer range:[0,255,0]	align:#right across:2
		spinner 	mu2	"Unknown 2:"	fieldwidth:45 type:#integer range:[0,255,0]	align:#right
		label info03 ""
		label info04 "* Brightness for buildings, as part in GTA3/VC vehicles"
		label info05 ""
		label info06 "Thanks ocram for helping me finish this script!"
		label info07 "" 
		label info08 "By Kam © Oct 2005" align:#right
 	)
	on create do (
		delegate.adLock = on
		delegate.specular = color 0 0 0
	)
)


plugin Material GTA_COLShadow
    name:"GTA COL Shadow"
    classID:#(0x48238272, 0x26574236)
	extends:Standard replaceUI:true 
(
	parameters main rollout:params 
	(
		u1 type:#integer default:0 		ui:su1
		u2 type:#integer default:255 	ui:su2
		on u2 set val do delegate.opacity = val/255.0*100
	)
	rollout params  "Shadow Parameters"
	(
 		label info01 "This Shader only works with GTA Collision IO."
		label info02 "" 
		spinner 	su1	"Unknown 1:"	fieldwidth:45 type:#integer range:[0,255,0]	align:#right across:2
		spinner 	su2	"Brightness:"	fieldwidth:45 type:#integer range:[0,255,0]	align:#right
		label info04 ""
		label info05 "Thanks ocram for helping me finish this script!"
		label info16 "" 
		label info17 "By Kam © Oct 2005" align:#right
 	)
	on create do (
		delegate.adLock = on
		delegate.diffuse = color 60 60 60 
		delegate.specular = color 0 0 0
	)
)