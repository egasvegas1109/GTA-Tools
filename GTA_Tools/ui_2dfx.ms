

global gFlags1
global gflags2



if effects==undefined then
(
	global effects=#("prt_blood", "prt_boatsplash", "prt_bubble", "prt_cardebris",
"prt_collisionsmoke", "prt_glass", "prt_gunshell", "prt_sand",
"prt_sand2", "prt_smokeII_3_expand", "prt_smoke_huge", "prt_spark",
"prt_spark_2", "prt_splash", "prt_wake", "prt_watersplash",
"prt_wheeldirt", "boat_prop", "camflash", "exhale", "explosion_fuel_car",
"explosion_large", "explosion_medium", "explosion_molotov", "explosion_small",
"explosion_tiny", "extinguisher", "fire", "fire_bike", "fire_car",
"fire_large", "fire_med", "flamethrower", "gunflash", "gunsmoke",
"heli_dust", "jetpack", "jetthrust", "molotov_flame", "nitro",
"overheat_car", "overheat_car_electric", "riot_smoke", "spraycan",
"tank_fire", "teargas", "teargasAD", "water_hydrant", "water_ripples",
"water_speed", "water_splash", "water_splash_big", "water_splsh_sml",
"water_swim", "cigarette_smoke", "Flame", "insects", "smoke30lit",
"smoke30m", "smoke50lit", "vent", "vent2", "waterfall_end",
"water_fnt_tme", "water_fountain", "tree_hit_fir", "tree_hit_palm",
"blood_heli", "carwashspray", "cement", "cloudfast", "coke_puff", "coke_trail", 
"explosion_barrel", "explosion_crate", "explosion_door",
"petrolcan", "puke", "shootlight", "smoke_flare", "wallbust", "ws_factorysmoke")
	global selectedEffect=undefined
)

rollout DFF2dfx "2DFX" ( 
	button fx_lght "LIGHT" width:155 height:24
	button fx_prt "Particle" width:155 height:24
	button fx_sgn "Sign" width:155 height:24
	button fx_stm "Slotmachine" width:155 height:24
	button fx_esc "Escalator" width:155 height:24
	
	on fx_lght pressed do (
		rollout DFF2dfx_light " Light export" (			
			checkbox DFF2dfxLog "Enable LOG (to Listener)"  height:17  align:#left checked:false
			
			Group "CONTROLS" (
				dropDownList LPresets "Presets:"  width:160 height:20 align:#left items: #("Default","OnAllDay","Mine","bb pickup","m Lamp Post","m Lamp Post coast","Flashing (Maverick1)","Flashing (Maverick2)","Flashing (Tug)","train Crossing1","Traffic")
				button btn_set "Set to selected Lights" align:#left height:30 across: 2
				button btn_get "  Get  " align:#right height:30 width:40
			)
			Group "DEAFULT parameters" (
				colorPicker LColor "Color              "  width:155 height:26 align:#right color:[255,255,255]
				spinner LCoronaSize "Corona size     " width:160 height:16 align:#right range:[0.0,1500.0,1.0] type:#float
				spinner LDrawDistance "Draw distance "  width:160 height:16 align:#right range:[0.0,1500.0,100.0] type:#float
				spinner LLightRange "Light range      "  width:160 height:16 align:#right range:[0.0,1500.0,18.0] type:#float
				dropDownList LCoronaName "Corona Name"  width:157 height:20 align:#right
				
				edittext LShowModeText ""  width:23 height:18 align:#left across:2 offset: [0.0,19.0,0.0]
				dropDownList LShowMode "Show Mode"  width:132 height:10 align:#right
				checkbox LCoronaRefl "Corona reflection"  height:17  align:#left across:2 offset: [0.0,14.0,0.0]
				dropDownList LFlareType "Flare Type"  width:50 height:10 align:#right items: #("0","1","2")
				
				spinner LShadowSize "Shadow size        "  width:160 height:16 align:#right range:[0.0,1500.0,8.0] type:#float
				spinner LShadowDistance "Shadow distance "  width:161 height:16 align:#right range:[0,255,0] type:#integer
				spinner LShadowMP "Shadow multiplier "  width:160 height:16 align:#right range:[0,255,40] type:#integer
				dropDownList LShadowName "Shadow Name"  width:157 height:20
				
				button Lflags1 "Set flags 1..."  width:65 height:20 align:#left across:2
				spinner LSflags1 ""  width:90 height:16 align:#right range:[0,65535,96] type:#integer
				button Lflags2 "Set flags 2..."  width:65 height:20 align:#left across:2
				spinner LSflags2 "" width:90 height:16 align:#right range:[0,65535,0] type:#integer
				
				label lbl1 "View Vector:"  width:66 height:18 align:#left
				spinner LVX "X "  width:52 height:16 align:#left across:3 range:[0,255,0] type:#integer
				spinner LVY "Y "  width:52 height:16 align:#center range:[0,255,0] type:#integer
				spinner LVZ "Z "  width:52 height:16 align:#right range:[0,255,0] type:#integer
				
			)
			on LColor changed cvalue do (
				for lght in  $selection where (superclassof lght == light) do (
					lght.rgb = cvalue
				)
				completeRedraw()
			)
			on LSflags1 changed tmp do (
				gFlags1 = LSflags1.value
			)
			on LSflags2 changed tmp do (
				gflags2 = LSflags2.value
			)
			on btn_get pressed do (
				if $selection.count > 0 then (
					local lght,tmp
					for i = 1 to $selection.count do if (superclassof selection[i] == light) then (
						tmp = selection[i].color
						break
					)
					if tmp != undefined do LColor.color = tmp
					for i= 1 to selection.count do if (superclassof selection[i] == light) then (
						lght = selection[i]
						break
					)
					if lght != undefined do (
						if (getuserprop lght "2d_L_Dist" ) != undefined then (
							--try (
								LDrawDistance.value = (getuserprop lght "2d_L_Dist" ) as float
								LLightRange.value = (getuserprop lght "2d_L_OutRange" ) as float		
								LCoronaSize.value = (getuserprop lght "2d_L_Size" ) as float
								LShadowSize.value = (getuserprop lght "2d_L_ShSize" ) as float
								tmp = (getuserprop lght "2d_L_Refl" ) as integer
								if tmp == 0 then LCoronaRefl.checked = false else LCoronaRefl.checked = true
								LShadowMP.value = (getuserprop lght "2d_L_shadowColorMultiplier" ) as integer
								LSflags1.value = (getuserprop lght "2d_L_Flags1" ) as integer
								gFlags1 = LSflags1.value
								LShadowDistance.value = (getuserprop lght "2d_L_shadowZDistance" ) as integer
								LSflags2.value = (getuserprop lght "2d_L_Flags2" ) as integer
								gflags2 = LSflags2.value
								LVX.value = (getuserprop lght "2d_L_DirectionX" ) as integer
								LVY.value = (getuserprop lght "2d_L_DirectionY" ) as integer
								LVZ.value = (getuserprop lght "2d_L_DirectionZ" ) as integer		
								tmp = getuserprop selection[1] "2d_L_CoroneName"
								for i = 1 to LCoronaName.items.count do (
									if LCoronaName.items[i] == tmp then LCoronaName.selection = i
								)	
								tmp = getuserprop selection[1] "2d_L_shadowName"
								for i = 1 to LShadowName.items.count do (
									if LShadowName.items[i] == tmp then LShadowName.selection = i
								)			
								tmp = getuserprop selection[1] "2d_L_ShowMode"
								tmp2 = false
								for i = 1 to LShowMode.items.count do (
									if (getNum(substring (LShowMode.items[i]) 1 3 ) as integer) == (tmp as integer) then (
										LShowMode.selection = i
										tmp2 = true
										LShowModeText.text = getNum(substring (LShowMode.items[i]) 1 3 )
									)
								)	
								if tmp2 == false then LShowModeText.text = (tmp as string)
								tmp = getuserprop selection[1] "2d_L_coronaFlareType"
								if tmp == 0 then LFlareType.selection = 1 
									else if tmp == 1 then LFlareType.selection = 2 
										else if tmp == 2 then LFlareType.selection = 3
							--) catch ()
						)
					)
				)
			)
			on btn_set pressed do (
				for lght in  selection where (superclassof lght == light) do (
					setUserProp lght "2d_L_Dist" (LDrawDistance.value as string)
					setUserProp lght "2d_L_OutRange" (LLightRange.value as string)
					setUserProp lght "2d_L_Size" (LCoronaSize.value as string)
					setUserProp lght "2d_L_ShSize" (LShadowSize.value as string)
					setUserProp lght "2d_L_ShowMode" ((getNum (LShowModeText.text)) as string) 
					if LCoronaRefl.checked then tmp = "1" else tmp = "0"
					setUserProp lght "2d_L_Refl" tmp
					if LFlareType.selection == 1 then tmp = 0 
						else if LFlareType.selection == 2 then tmp = 1 
							else if LFlareType.selection == 3 then tmp = 2 
					setUserProp lght "2d_L_coronaFlareType" (tmp as string)
					setUserProp lght "2d_L_shadowColorMultiplier" (LShadowMP.value as string)					
					setUserProp lght "2d_L_Flags1" (gFlags1 as string)
					setUserProp lght "2d_L_CoroneName" (LCoronaName.items[LCoronaName.selection])
					setUserProp lght "2d_L_shadowName" (LShadowName.items[LShadowName.selection])
					setUserProp lght "2d_L_shadowZDistance" (LShadowDistance.value as string)
					setUserProp lght "2d_L_Flags2" (gflags2 as string)
					setUserProp lght "2d_L_DirectionX" (LVX.value as string)
					setUserProp lght "2d_L_DirectionY" (LVY.value as string)
					setUserProp lght "2d_L_DirectionZ" (LVZ.value as string)
					
					
				)
			)
			on LPresets selected sItem do (
				if sItem == 1 then (
					--LColor.color = [255,255,255]
					LCoronaSize.value = 1.0
					LDrawDistance.value = 100.0
					LLightRange.value = 18.0
					LCoronaName.selection = 1
					LShowModeText.text = "0"
					LShowMode.selection = 1
					LCoronaRefl.checked = false
					LFlareType.selection = 1
					LShadowSize.value = 8.0
					LShadowDistance.value = 0
					LShadowMP.value = 40
					LShadowName.selection = 1
					LSflags1.value = 96
					LSflags2.value = 0
					LVX.value = 0
					LVY.value = 0
					LVZ.value = 0
				)
				if sItem == 2 then ( -- OnAllDay
					LSflags1.value = 96
					LShowModeText.text = "0"
					LShowMode.selection = 1
					LCoronaRefl.checked = false
					LShadowDistance.value = 0
					LShadowMP.value = 40
					LFlareType.selection = 1
				)
				if sItem == 3 then ( -- Mine
					LSflags1.value = 70
					LShowModeText.text = "0"
					LShowMode.selection = 1
					LCoronaRefl.checked = false
					LShadowDistance.value = 4
					LShadowMP.value = 40
					LFlareType.selection = 1
				)
				if sItem == 4 then ( -- bb_pickup
					LSflags1.value = 96
					LShowModeText.text = "3"
					LShowMode.selection = 4
					LCoronaRefl.checked = false
					LShadowDistance.value = 0
					LShadowMP.value = 40
					LFlareType.selection = 1
				)
				if sItem == 5 then ( -- mLampPost
					LSflags1.value = 66
					LShowModeText.text = "0"
					LShowMode.selection = 1
					LCoronaRefl.checked = true
					LShadowDistance.value = 4
					LShadowMP.value = 80
					LFlareType.selection = 1
				)
				if sItem == 6 then ( -- mLampPost_coast
					LSflags1.value = 66
					LShowModeText.text = "0"
					LShowMode.selection = 1
					LCoronaRefl.checked = true
					LShadowDistance.value = 4
					LShadowMP.value = 40
					LFlareType.selection = 1
				)
				if sItem == 7 then ( -- flashing (Maverick1)
					LSflags1.value = 64
					LShowModeText.text = "0"
					LShowMode.selection = 1
					LCoronaRefl.checked = false
					LShadowDistance.value = 16
					LShadowMP.value = 40
					LFlareType.selection = 1
				)
				if sItem == 8 then ( -- flashing (Maverick2)
					LSflags1.value = 64
					LSflags2.value = 146
					LShowModeText.text = "0"
					LShowMode.selection = 1
					LCoronaRefl.checked = false
					LShadowDistance.value = 16
					LShadowMP.value = 40
					LFlareType.selection = 1
				)
				if sItem == 9 then ( -- flashing (Tug)
					LSflags1.value = 64
					LSflags2.value = 156
					LShowModeText.text = "0"
					LShowMode.selection = 1
					LCoronaRefl.checked = false
					LShadowDistance.value = 16
					LShadowMP.value = 40
					LFlareType.selection = 1
				)
				if sItem == 10 then ( -- trainCrossing1
					LSflags1.value = 96
					LShowModeText.text = "8"
					LShowMode.selection = 8
					LCoronaRefl.checked = false
					LShadowDistance.value = 0
					LShadowMP.value = 40
					LFlareType.selection = 1
				)
				if sItem == 11 then ( -- traffic1(yellow)
					LSflags1.value = 66
					LShowModeText.text = "7"
					LShowMode.selection = 7
					LCoronaRefl.checked = true
					LShadowDistance.value = 4
					LShadowMP.value = 40
					LFlareType.selection = 1
				)
				if sItem == 12 then ( -- traffic
					LSflags1.value = 66
					LShowModeText.text = "7"
					LShowMode.selection = 7
					LCoronaRefl.checked = true
					LShadowDistance.value = 4
					LShadowMP.value = 40
					LFlareType.selection = 1
				)
			)
			on Lflags1 pressed do (
				rollout DFF2dfx_flags1 "set flags:" width:300   (
					Group "FLAGS 1" (
						checkbox flag1 "1   CORONA_CHECK_OBSTACLES"  align:#left
						checkbox flag2 "2   FOG_TYPE "  align:#left
						checkbox flag4 "4   FOG_TYPE "  align:#left
						checkbox flag8 "8   WITHOUT_CORONA"  align:#left
						checkbox flag16 "16  CORONA_ONLY_AT_LONG_DISTANCE"  align:#left
						checkbox flag32 "32  AT_DAY"  align:#left
						checkbox flag64 "64  AT_NIGHT"  align:#left
						checkbox flag128 "128 BLINKING1"  align:#left
					)
					label txt98 "flag:" align:#left across: 3
					label txt99 "0" align:#left
					button btn_close "close" align:#right width:69 height:22
					
					on DFF2dfx_flags1 open do (	
						gFlags1 = LSflags1.value
						txt99.text	= 	(gFlags1	as string)		
						if (mod gFlags1 2) >= 1 then flag1.checked = true else flag1.checked = false
						if (mod gFlags1 4) >= 2 then flag2.checked = true else flag2.checked = false
						if (mod gFlags1 8) >= 4 then flag4.checked = true else flag4.checked = false
						if (mod gFlags1 16) >= 8 then flag8.checked = true else flag8.checked = false
						if (mod gFlags1 32) >= 16 then flag16.checked = true else flag16.checked = false
						if (mod gFlags1 64) >= 32 then flag32.checked = true else flag32.checked = false
						if (mod gFlags1 128) >= 64 then flag64.checked = true else flag64.checked = false
						if (mod gFlags1 256) >= 128 then flag128.checked = true else flag128.checked = false
					)
					on flag1 changed state do (
						if state == true then (gFlags1 += 1;LSflags1.value = gFlags1; txt99.text	= 	(gFlags1	as string)) else (gFlags1 -= 1;LSflags1.value = gFlags1; txt99.text	= 	(gFlags1	as string))
					)
					on flag2 changed state do (
						if state == true then (gFlags1 += 2;LSflags1.value = gFlags1; txt99.text	= 	(gFlags1	as string)) else (gFlags1 -= 2;LSflags1.value = gFlags1; txt99.text	= 	(gFlags1	as string))
					)
					on flag4 changed state do (
						if state == true then (gFlags1 += 4;LSflags1.value = gFlags1; txt99.text	= 	(gFlags1	as string)) else (gFlags1 -= 4;LSflags1.value = gFlags1; txt99.text	= 	(gFlags1	as string))
					)
					on flag8 changed state do (
						if state == true then (gFlags1 += 8;LSflags1.value = gFlags1; txt99.text	= 	(gFlags1	as string)) else (gFlags1 -= 8;LSflags1.value = gFlags1; txt99.text	= 	(gFlags1	as string))
					)
					on flag16 changed state do (
						if state == true then (gFlags1 += 16;LSflags1.value = gFlags1; txt99.text	= 	(gFlags1	as string)) else (gFlags1 -= 16;LSflags1.value = gFlags1; txt99.text	= 	(gFlags1	as string))
					)
					on flag32 changed state do (
						if state == true then (gFlags1 += 32;LSflags1.value = gFlags1; txt99.text	= 	(gFlags1	as string)) else (gFlags1 -= 32;LSflags1.value = gFlags1; txt99.text	= 	(gFlags1	as string))
					)
					on flag64 changed state do (
						if state == true then (gFlags1 += 64;LSflags1.value = gFlags1; txt99.text	= 	(gFlags1	as string)) else (gFlags1 -= 64;LSflags1.value = gFlags1; txt99.text	= 	(gFlags1	as string))
					)
					on flag128 changed state do (
						if state == true then (gFlags1 += 128;LSflags1.value = gFlags1; txt99.text	= 	(gFlags1	as string)) else (gFlags1 -= 128;LSflags1.value = gFlags1; txt99.text	= 	(gFlags1	as string))
					)
					on btn_close pressed do DestroyDialog  DFF2dfx_flags1 
				)
				createDialog DFF2dfx_flags1 modal:true 
			)
			
			on Lflags2 pressed do (
				rollout DFF2dfx_flags2 "set flags:" width:300   (
					Group "FLAGS 2" (
						checkbox flag1 "1   CORONA_ONLY_FROM_BELOW"  align:#left
						checkbox flag2 "2   BLINKING2"  align:#left
						checkbox flag4 "4   UDPDATE_HEIGHT_ABOVE_GROUND"  align:#left
						checkbox flag8 "8   CHECK_DIRECTION"  align:#left
						checkbox flag16 "16  BLINKING3"  align:#left
					)
					label txt98 "flag:" align:#left across: 3
					label txt99 "0" align:#left
					button btn_close "close" align:#right width:69 height:22
					
					on DFF2dfx_flags2 open do (	
						gFlags2 = LSflags2.value
						txt99.text	= 	(gflags2	as string)		
						if (mod gflags2 2) >= 1 then flag1.checked = true else flag1.checked = false
						if (mod gflags2 4) >= 2 then flag2.checked = true else flag2.checked = false
						if (mod gflags2 8) >= 4 then flag4.checked = true else flag4.checked = false
						if (mod gflags2 16) >= 8 then flag8.checked = true else flag8.checked = false
						if (mod gflags2 32) >= 16 then flag16.checked = true else flag16.checked = false
					)
					on flag1 changed state do (
						if state == true then (gflags2 += 1;LSflags2.value = gFlags2; txt99.text	= 	(gflags2	as string)) else (gflags2 -= 1;LSflags2.value = gFlags2; txt99.text	= 	(gflags2	as string))
					)
					on flag2 changed state do (
						if state == true then (gflags2 += 2;LSflags2.value = gFlags2; txt99.text	= 	(gflags2	as string)) else (gflags2 -= 2;LSflags2.value = gFlags2; txt99.text	= 	(gflags2	as string))
					)
					on flag4 changed state do (
						if state == true then (gflags2 += 4;LSflags2.value = gFlags2; txt99.text	= 	(gflags2	as string)) else (gflags2 -= 4;LSflags2.value = gFlags2; txt99.text	= 	(gflags2	as string))
					)
					on flag8 changed state do (
						if state == true then (gflags2 += 8;LSflags2.value = gFlags2; txt99.text	= 	(gflags2	as string)) else (gflags2 -= 8;LSflags2.value = gFlags2; txt99.text	= 	(gflags2	as string))
					)
					on flag16 changed state do (
						if state == true then (gflags2 += 16;LSflags2.value = gFlags2; txt99.text	= 	(gflags2	as string)) else (gflags2 -= 16;LSflags2.value = gFlags2; txt99.text	= 	(gflags2	as string))
					)
					on btn_close pressed do DestroyDialog  DFF2dfx_flags2 
				)
				createDialog DFF2dfx_flags2 modal:true 
			)

			
			on LShowMode selected sItem do (
				tmp = "00"
				tmp[1] = LShowMode.items[sItem][1]
				tmp[2]  = LShowMode.items[sItem][2]
				LShowModeText.text = tmp
			)
			on DFF2dfx_light open do (
				gFlags1 = DFF2dfx_light.LSflags1.value
				gFlags2 = DFF2dfx_light.LSflags2.value
				LShowModeText.text = "0"
				LCoronaName.items  = #(
						"coronastar",
						"shad_heli",
						"shad_exp",
						"shad_car",
						"shad_bike",
						"seabd32",
						"roadsignfont",
						"particleskid",
						"lunar",
						"lockonFire",
						"lockon",
						"lamp_shad_64",
						"headlight1",
						"headlight",
						"handman",
						"finishFlag",
						"coronaringb",
						"coronareflect",
						"coronamoon",
						"coronaheadlightline",
						"cloudmasked",
						"cloudhigh",
						"cloud1",
						"carfx1",
						"bloodpool_64", 
						"wincrack_32",
						"white",
						"waterwake",
						"waterclear256",
						"txgrassbig1",
						"txgrassbig0",
						"target256",
						"shad_rcbaron",
						"shad_ped" 
					)
				LShadowName.items  = #(
						"shad_exp",
						"coronastar",
						"shad_heli",
						"shad_car",
						"shad_bike",
						"seabd32",
						"roadsignfont",
						"particleskid",
						"lunar",
						"lockonFire",
						"lockon",
						"lamp_shad_64",
						"headlight1",
						"headlight",
						"handman",
						"finishFlag",
						"coronaringb",
						"coronareflect",
						"coronamoon",
						"coronaheadlightline",
						"cloudmasked",
						"cloudhigh",
						"cloud1",
						"carfx1",
						"bloodpool_64", 
						"wincrack_32",
						"white",
						"waterwake",
						"waterclear256",
						"txgrassbig1",
						"txgrassbig0",
						"target256",
						"shad_rcbaron",
						"shad_ped" 
				)

				LShowMode.items  = #(
					"0 DEFAULT",
					"1 RANDOM_FLASHING",
					"2 RND_AT_WET_WTHR",
					"3 L_ANIM_SPD_4X",       
					"4 L_ANIM_SPD_2X",  
					"5 L_ANIM_SPD_1X",
					"7 TRAFFICLIGHT",
					"8 TRAINCROSSLIGHT",                     
					"10 AT_RAIN_ONLY" 
				)
			)
			button btn_close_light "close" align:#center width:180 height:22 offset:[0,5]
			on btn_close_light  pressed do  try (closeRolloutFloater DFF2dfx_light_rol) catch () 	
		)
		try (closeRolloutFloater DFF2dfx_light_rol) catch () 
		DFF2dfx_light_rol = newRolloutFloater "Light" 200 510
		addRollout DFF2dfx_light DFF2dfx_light_rol
	)
	
	on fx_prt pressed do (
		rollout DFF2dfx_prt "Particle export" (		
			label txt0 "soon..."
			/*
			label txt1 "Particle name:" align:#left
			editText edt_prt "" width:160 height:20 align:#left
			listBox lbx2 "" items:(effects) selection:1 width:157 height:10 align:#right
			button btn_prt_set "set to sel DUMMY" width:160 height:40 offset:[0,5]
			label txt0 "" 
			*/
			button btn_close_prt "close" align:#center width:180 height:22 offset:[0,5] 	
			/*
			on lbx2 selected prtName do (
				edt_prt.text = lbx2.selected
			)
			on btn_prt_set  pressed do (
				for dm in  selection where (superclassof dm == helper and classof dm == Dummy) do (
					setUserProp dm "2dfx" "true"
					setUserProp dm "2dfx_type" "1"
				)
			)
			*/
			on btn_close_prt  pressed do  try (closeRolloutFloater DFF2dfx_prt_rol) catch ()
		)
		try (closeRolloutFloater DFF2dfx_prt_rol) catch () 
		DFF2dfx_prt_rol = newRolloutFloater "Particle" 200 100 --320
		addRollout DFF2dfx_prt DFF2dfx_prt_rol
	)
	
	on fx_sgn pressed do (
		rollout DFF2dfx_sgn "Sign export" (	
			label txt0 "soon..."
			/*
			Spinner width "Width:" range:[0, 100, 1]
			Spinner length "Length:" range:[0, 100, 1]
			group "Rotation" (
				Spinner y "Y:" range:[-90, 90, 0]
				Spinner x "X:" range:[-90, 90, 0]
				Spinner z "Z:" range:[-90, 90, 0]
			)
			editText edt1 "Line 1: "
			editText edt2 "Line 2: "
			editText edt3 "Line 3: "
			editText edt4 "Line 4: "
			Spinner used "Lines used:" type:#integer range:[1, 4, 4]
			dropDownList symbols "Symbols:" items:#("16", "2", "4", "8")
			dropDownList color "Color:" items:#("white", "black", "grey", "red")		
		*/
			button btn_close_sgn "close" align:#center width:180 height:22 offset:[0,5]
			on btn_close_sgn  pressed do  try (closeRolloutFloater DFF2dfx_sgn_rol) catch () 	
		)
		try (closeRolloutFloater DFF2dfx_sgn_rol) catch () 
		DFF2dfx_sgn_rol = newRolloutFloater "Sign" 200 100
		addRollout DFF2dfx_sgn DFF2dfx_sgn_rol
	)
	
	on fx_stm pressed do (
		rollout DFF2dfx_stm "Slotmachine export" (	
			label txt0 "soon..."		
			button btn_close_stm "close" align:#center width:180 height:22 offset:[0,5]
			on btn_close_stm  pressed do  try (closeRolloutFloater DFF2dfx_stm_rol) catch () 	
		)
		try (closeRolloutFloater DFF2dfx_stm_rol) catch () 
		DFF2dfx_stm_rol = newRolloutFloater "Slotmachine" 200 100
		addRollout DFF2dfx_stm DFF2dfx_stm_rol
	)
	
	on fx_esc pressed do (
		rollout DFF2dfx_esc "Escalator export" (	
			label txt0 "soon..."
			button btn_close_esc "close" align:#center width:180 height:22 offset:[0,5]
			on btn_close_esc  pressed do  try (closeRolloutFloater DFF2dfx_esc_rol) catch () 	
		)
		try (closeRolloutFloater DFF2dfx_esc_rol) catch () 
		DFF2dfx_esc_rol = newRolloutFloater "Escalator" 200 100
		addRollout DFF2dfx_esc DFF2dfx_esc_rol
	)
	
)