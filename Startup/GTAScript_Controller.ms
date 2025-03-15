
function menuCallback =
(
	local menuMgr = callbacks.notificationParam()

	local mainMenuBar = menuMgr.mainMenuBar

	local newSubMenu = mainMenuBar.CreateSubMenu "8f3bf3c9-774f-48a4-a8b2-3855f8eb6736" "GTA Tools"

	newSubMenu.CreateAction "17fdf993-4c44-4e81-9d68-4ed2fe947131" 647394 ("kams_dffio`KAMs_Scripts")

	local col = newSubMenu.CreateSubMenu "5fb7757e-62e0-4cad-9e75-22ce84e4159a" "Collision"
	local map = newSubMenu.CreateSubMenu "fb7838ad-30f1-40cb-93b9-3a3f7fd57887" "MAP"
	local prelite = newSubMenu.CreateSubMenu "ee56a4a5-e7cb-4746-b0be-70c0a9d596a2" "Prelite"
	local tools = newSubMenu.CreateSubMenu "0e3e6293-9cdf-43a1-a4c2-252d9fa145a8" "Tools"
	local model_fixs = newSubMenu.CreateSubMenu "cbf3f657-b7ad-4be6-85ab-d1258f438a51" "Model FIXs"

	col.CreateAction "c8e96b51-d5a6-4372-a58d-42057944e5b9" 647394 ("kams_colio`KAMs_Scripts")
	col.CreateAction "5c17f39f-9890-4857-81fd-5573d78a8f2b" 647394 ("kams_cstImp`KAMs_Scripts")
	col.CreateAction "f4f73856-6ebf-44e7-9e42-ae90d7fae628" 647394 ("kams_cstExp`KAMs_Scripts")

	map.CreateAction "a837d485-bc0f-480c-b4a3-766e6c12fefe" 647394 ("kams_mapio`KAMs_Scripts")
	map.CreateAction "a2ad3952-a77c-45e1-b9b7-0d03e10af85d" 647394 ("kams_emap`KAMs_Scripts")
	map.CreateAction "44c521cb-c96f-4d28-945b-a718c8eff7bd" 647394 ("kams_t_explode`KAMs_Scripts")

	prelite.CreateAction "de0a47f0-9f00-4017-88a0-859457fbcba2" 647394 ("kams_t_prelit`KAMs_Scripts")
	prelite.CreateAction "c4ba17e3-34e4-404f-91d9-3b97af7e3086" 647394 ("kams_VCsT`KAMs_Scripts")

	tools.CreateAction "4d29be92-5e68-4c4e-aa16-d0f79d6af5d3" 647394 ("kams_waterio`KAMs_Scripts")
	tools.CreateAction "7a2b7134-c35e-4c98-bc4c-98c6f4ee3ea4" 647394 ("kams_t_VRH`KAMs_Scripts")
	tools.CreateAction "1c398d60-1f9b-48ea-ab9c-6874a5ac617c" 647394 ("kams_BM`KAMs_Scripts")
	tools.CreateAction "a8abe4c9-17f5-48e0-be2f-c6fb95c4a542" 647394 ("kams_valph`KAMs_Scripts")

	model_fixs.CreateAction "12e1615c-45ae-44be-9751-ee363550fd24" 647394 ("kams_FixDif`KAMs_Scripts")
	model_fixs.CreateAction "21fb6d45-a935-4884-9378-e0f5b97cfadc" 647394 ("kams_t_fixPivot`KAMs_Scripts")
	model_fixs.CreateAction "23026062-384d-4fb4-aa32-947033e41d06" 647394 ("kams_t_alignPivot`KAMs_Scripts")
)
callbacks.removeScripts id:#menuDemo
callbacks.addScript #cuiRegisterMenus menuCallback id:#menuDemo

fn rebuildMenus =
(
	local iCuiMenuMgr = maxops.GetICuiMenuMgr()
	iCuiMenuMgr.LoadConfiguration (iCuiMenuMgr.GetCurrentConfiguration())
	local iQuadMenuMgr = maxops.GetICuiQuadMenuMgr()
	iQuadMenuMgr.LoadConfiguration (iQuadMenuMgr.GetCurrentConfiguration())
)
rebuildMenus()

try ( closeUtility Kams_Scripts) catch ()
fn runEmt = ()
fn addKamsToolsMenu_ = (
	macroScript kams_cstImp
		buttonText:"Export to CST"
		category:"KAMs_Scripts"
		internalCategory:"KAMs_Scripts" (
		try ( fileIn (scriptspath+"\\GTA_Tools\\tools\\CST_Export.ms") quiet:true   )
		catch messagebox "Please re-install my DFF IO script!" title:"Can't find CST_Export.ms script"
	)
	
	macroScript kams_cstExp
		buttonText:"Import CST"
		category:"KAMs_Scripts"
		internalCategory:"KAMs_Scripts" (
		try ( 
			fileIn (scriptspath+"\\GTA_Tools\\tools\\CST_Import.ms") quiet:true
		)catch messagebox "Please re-install my Map IO script!" title:"Can't find CST_Import.ms script"
	)
	
	macroScript kams_dffio
		buttonText:"DFF IO"
		category:"KAMs_Scripts"
		internalCategory:"KAMs_Scripts" (
		try ( fileIn (scriptspath+"\\GTA_Tools\\GTA_DFF_IO.ms") quiet:true   )
		catch messagebox "Please re-install my DFF IO script!" title:"Can't find DFF IO script"
	)
	macroScript kams_colio
		buttonText:"COL IO"
		category:"KAMs_Scripts"
		internalCategory:"KAMs_Scripts" (
		try ( fileIn (scriptspath+"\\GTA_Tools\\GTA_COL_IO.ms") quiet:true   )
		catch messagebox "Please re-install my Collision IO script!" title:"Can't find Collision IO script"
	)
	macroScript kams_mapio
		buttonText:"Map IO"
		category:"KAMs_Scripts"
		internalCategory:"KAMs_Scripts" (
		try ( fileIn (scriptspath+"\\GTA_Tools\\GTA_Map_IO.ms") quiet:true   )
		catch messagebox "Please re-install my Map IO script!" title:"Can't find Map IO script"
	)
	
	macroScript kams_VCsT
		buttonText:"VC Smooth tool"
		category:"KAMs_Scripts"
		internalCategory:"KAMs_Scripts" (
		try ( 
			fileIn (scriptspath+"\\GTA_Tools\\tools\\VC_smoothTool\\VC_smoothTool.ms") quiet:true
		)catch messagebox "Please re-install my Map IO script!" title:"Can't find VC_smoothTool.ms script"
	)
	
	macroScript kams_waterio
		buttonText:"GTA Water IO"
		category:"KAMs_Scripts"
		internalCategory:"KAMs_Scripts" (
		try ( 
			fileIn (scriptspath+"\\GTA_Tools\\tools\\GTA_Water_IO\\GTAWaterIO.ms") quiet:true
		)catch messagebox "Please re-install my Map IO script!" title:"Can't find GTAWaterIO.ms script"
	)
	
	macroScript kams_emap
		buttonText:"EMAPTool"
		category:"KAMs_Scripts"
		internalCategory:"KAMs_Scripts" (
		try ( 
			fileIn (scriptspath+"\\GTA_Tools\\emt_startup.ms") quiet:true
			runEmt()
		)catch messagebox "Please re-install my Map IO script!" title:"Can't find Map IO script"
	)
	
	macroScript kams_BM
		buttonText:"Bitmaps Manager"
		category:"KAMs_Scripts"
		internalCategory:"KAMs_Scripts" (
		try ( 
			fileIn (scriptspath+"\\GTA_Tools\\tools\\BitmapsManager\\BitmapsManager.ms") quiet:true
		)catch messagebox "Please re-install my Map IO script!" title:"Can't find BitmapsManager.ms script"
	)
	
	macroScript kams_valph
		buttonText:"set VAlpha On Border objs"
		category:"KAMs_Scripts"
		internalCategory:"KAMs_Scripts" (
		try ( 
			fileIn (scriptspath+"\\GTA_Tools\\tools\\setVAlphaOnBorder.ms") quiet:true
		)catch messagebox "Please re-install my Map IO script!" title:"Can't find setVAlphaOnBorder.ms script"
	)
	
	
	macroScript kams_FixDif
		buttonText:"Fix Diffuse Color"
		category:"KAMs_Scripts"
		internalCategory:"KAMs_Scripts" (
		try ( 
			fileIn (scriptspath+"\\GTA_Tools\\tools\\FixDifColor.ms") quiet:true
		)catch messagebox "Please re-install my Map IO script!" title:"Can't find FixDifColor.ms script"
	)
	
	macroScript kams_t_fixPivot
		buttonText:"Fix models pivot"
		category:"KAMs_Scripts"
		internalCategory:"KAMs_Scripts" (
		try (
			if $selection.count > 0 then (
				clearListener()
				format "Fix pivots started:\n"
				for obj in $selection  do (
					if superclassof obj == GeometryClass then (
						CenterPivot obj
						obj.pivot.x = (ceil obj.pivot.x)
						obj.pivot.y = (ceil obj.pivot.y)
						obj.pivot.z = (ceil obj.pivot.z)
						ResetXForm obj
						convertToPoly obj
						format "[Fixed] %\n" obj.name
					) else format "[no Fixed] % - is not a geometry\n" obj.name
				)
			) else messagebox "Models Not Selected!" title: "Fix Pivot - error"
		)
		catch messagebox "Error!" title:"Can't run script"
	)
	
	macroScript kams_t_alignPivot
		buttonText:"Align pivot to center"
		category:"KAMs_Scripts"
		internalCategory:"KAMs_Scripts" (
		try (
			if selection.count > 0 then (
				clearListener()
				format "Fix pivots started:\n"
				for obj in selection  do (
					if superclassof obj == GeometryClass then (
						CenterPivot obj
						ResetXForm obj
						convertToPoly obj
						format "[Fixed] %\n" obj.name
					) else format "[no Fixed] % - is not a geometry\n" obj.name
				)
			) else messagebox "Models Not Selected!" title: "Align pivot - error"
		) catch messagebox "Error!" title:"Can't run script"
	)
	
	macroScript kams_t_prelit
		buttonText:"Prelite Tools"
		category:"KAMs_Scripts"
		internalCategory:"KAMs_Scripts" (
		try (
			try (DestroyDialog G_PrelitTools) catch()
			rollout G_PrelitTools "Prelite Tools"  (
				group "show vertex color" (
					button _day_btn "DAY"  align:#left across:3 
					button _off_btn "Off"  align:#left  width:40 offset:[-4,0]
					button _night_btn "NIGHT"  align:#right 
				)
				group "Set Prelit to Sel Models" (
					colorPicker day_cp "Day  " color:[255,255,255] width:111 height:20 align:#left
					colorPicker nig_cp "Night" color:[0,0,0] width:111 height:20 align:#left
				)
				group "Vertex coping" (
					spinner prVal "+/- value:" width:90 height:16 range:[-255,255,0] type:#integer align:#center
					button DtoN "Day to Night"  height:28 align:#left  across:2 width:68
					button NtoD "Night to Day"  height:28 width:68 align:#right
					button DtoD "Day to Day"  height:24 align:#left  across:2 width:64 offset:[0,5]
					button NtoN "Night to Night"  height:24 width:72 align:#right offset:[0,5]
				)

				on _off_btn pressed do
					if $selection != undefined then (
						for o in $selection where (superclassof o  == GeometryClass ) do (
							o.showVertexColors = false
						)
						completeRedraw()
					)
					
				on _night_btn pressed do
					if $selection != undefined then (
						for o in $selection where (superclassof o  == GeometryClass ) do (
							o.showVertexColors = true
							o.vertexColorType = #illum
						)
						completeRedraw()
					)
				on _day_btn pressed do
					if $selection != undefined then (
						for o in $selection where (superclassof o  == GeometryClass ) do (
							o.showVertexColors = true
							o.vertexColorType = #color
						)
						completeRedraw()
					)
				
				on DtoD pressed do (	
					if $selection !=undefined then (
						suspendediting()
						disableSceneRedraw()
						setWaitCursor()
						enableUndo false
						try (
							for obj in $selection where (superclassof obj == GeometryClass ) do (
								if (classof obj) != Editable_Poly then convertToPoly obj
								if polyop.getMapSupport obj 0 == true then (
									for i = 1 to polyOp.getNumMapVerts obj 0 do (
									  tmp1 = polyOp.getMapVert obj 0 i
									  tmp1 *= 255.0
									  tmp1 += prVal.value
									  tmp1 /= 255.0
										if tmp1[1] > 1.0 then tmp1[1] = 1.0
										if tmp1[2] > 1.0 then tmp1[2] = 1.0
										if tmp1[3] > 1.0 then tmp1[3] = 1.0						
										if tmp1[1] < 0.0  then tmp1[1] = 0.0
										if tmp1[2] < 0.0  then tmp1[2] = 0.0
										if tmp1[3] < 0.0  then tmp1[3] = 0.0
									  polyOp.setMapVert obj 0 i tmp1
									)
									addModifier obj (VertexPaint ())
									collapseStack obj
									format "\nVertex Coping: done! %\n" obj.name
								)
							)
						) catch ( format "\nVertex Coping: error!\n")
						resumeediting()
						enableSceneRedraw()
						setArrowCursor()
						redrawViews()
						enableUndo true
					)
				)
				
				on NtoN pressed do (	
					if $selection !=undefined then (
						suspendediting()
						disableSceneRedraw()
						setWaitCursor()
						enableUndo false
						clearlistener()
						try (
							for obj in $selection where (superclassof obj == GeometryClass ) do (
								if (classof obj) != Editable_Poly then convertToPoly obj
								if polyop.getMapSupport obj -1 == true then (
									for i = 1 to polyOp.getNumMapVerts obj -1 do (
									  tmp1 = polyOp.getMapVert obj -1 i
									  tmp1 *= 255.0
									  tmp1 += prVal.value
									  tmp1 /= 255.0
										if tmp1[1] > 1.0 then tmp1[1] = 1.0
										if tmp1[2] > 1.0 then tmp1[2] = 1.0
										if tmp1[3] > 1.0 then tmp1[3] = 1.0						
										if tmp1[1] < 0.0  then tmp1[1] = 0.0
										if tmp1[2] < 0.0  then tmp1[2] = 0.0
										if tmp1[3] < 0.0  then tmp1[3] = 0.0
										polyOp.setMapVert obj -1 i tmp1
									)
									addModifier obj (VertexPaint ())
									collapseStack obj
									format "\nVertex Coping: done! %\n" obj.name
								)
							)
						) catch ( format "\nVertex Coping: error!\n")
						resumeediting()
						enableSceneRedraw()
						setArrowCursor()
						redrawViews()
						enableUndo true
					)
				)
				
				on DtoN pressed do (	
					if $selection !=undefined then (
						suspendediting()
						disableSceneRedraw()
						setWaitCursor()
						enableUndo false
						try (
							for obj in $selection where (superclassof obj == GeometryClass ) do (
								if (classof obj) != Editable_Poly then convertToPoly obj
								if polyop.getMapSupport obj 0 == true then (
									polyOp.setMapSupport obj -1 false
									polyOp.setMapSupport obj -1 true
									vcnum = polyOp.getNumMapVerts obj 0
									polyOp.setNumMapVerts obj -1 vcnum
									for i = 1 to vcnum do (
									  tmp1 = polyOp.getMapVert obj 0 i
									  tmp1 *= 255.0
									  tmp1 += prVal.value
									  tmp1 /= 255.0
										if tmp1[1] > 1.0 then tmp1[1] = 1.0
										if tmp1[2] > 1.0 then tmp1[2] = 1.0
										if tmp1[3] > 1.0 then tmp1[3] = 1.0						
										if tmp1[1] < 0.0  then tmp1[1] = 0.0
										if tmp1[2] < 0.0  then tmp1[2] = 0.0
										if tmp1[3] < 0.0  then tmp1[3] = 0.0
									  polyOp.setMapVert obj -1 i tmp1
									)
									vcfaces = polyOp.getNumMapFaces obj 0
									polyOp.setnummapfaces obj -1 vcfaces
									for i = 1 to vcfaces do (
										tmp1 = polyOp.getMapFace obj 0 i
										polyOp.setMapFace obj -1 i tmp1
									)
									format "\nVertex Coping: done! %\n" obj.name
								) else format "\nVertex Coping: error! obj % not have this map support\n" obj.name
							)
						) catch ( format "\nVertex Coping: error!\n")
						resumeediting()
						enableSceneRedraw()
						setArrowCursor()
						redrawViews()
						enableUndo true
					)
				)
				on NtoD pressed do (	
					if $selection !=undefined then (
						suspendediting()
						disableSceneRedraw()
						setWaitCursor()
						enableUndo false
						try (
							for obj in $selection where (superclassof obj == GeometryClass ) do (
								if (classof obj) != Editable_Poly then convertToPoly obj
								if polyop.getMapSupport obj -1 == true then (
									polyOp.setMapSupport obj 0 false
									polyOp.setMapSupport obj 0 true
									vcnum = polyOp.getNumMapVerts obj -1
									polyOp.setNumMapVerts obj 0 vcnum
									for i = 1 to vcnum do (
									  tmp1 = polyOp.getMapVert obj -1 i
									  tmp1 *= 255.0
									  tmp1 += prVal.value
									  tmp1 /= 255.0
										if tmp1[1] > 1.0 then tmp1[1] = 1.0
										if tmp1[2] > 1.0 then tmp1[2] = 1.0
										if tmp1[3] > 1.0 then tmp1[3] = 1.0						
										if tmp1[1] < 0.0  then tmp1[1] = 0.0
										if tmp1[2] < 0.0  then tmp1[2] = 0.0
										if tmp1[3] < 0.0  then tmp1[3] = 0.0
									  polyOp.setMapVert obj 0 i tmp1
									)
									vcfaces = polyOp.getNumMapFaces obj -1
									polyOp.setnummapfaces obj 0 vcfaces
									for i = 1 to vcfaces do (
										tmp1 = polyOp.getMapFace obj -1 i
										polyOp.setMapFace obj 0 i tmp1
									)
									format "\nVertex Coping: done! %\n" obj.name
								) else format "\nVertex Coping: error! obj % not have this map support\n" obj.name
							)
							
						) catch ( format "\nVertex Coping: error!\n")
						resumeediting()
						enableSceneRedraw()
						setArrowCursor()
						redrawViews()
						enableUndo true
					)
				)

				on day_cp changed arg do (
					for obj in $selection where superclassof obj == GeometryClass do (
						convertToPoly obj
						polyOp.defaultMapFaces obj 0
						for i = 1 to obj.numverts do polyOp.setMapVert obj 0 i (arg/255.0)
						completeRedraw()
					)
				)
				on nig_cp changed arg do (
					for obj in $selection  where superclassof obj == GeometryClass do (
						convertToPoly obj
						polyOp.defaultMapFaces obj -1
						for i = 1 to obj.numverts do polyOp.setMapVert obj -1 i (arg/255.0)
						completeRedraw()
					)
				)
			)
			createDialog G_PrelitTools
		)
		catch messagebox "Error!" title:"Can't run Prelite Tools script"
	)
	
	macroScript kams_t_VRH
		buttonText:"Vehicle Scale Helper"
		category:"KAMs_Scripts"
		internalCategory:"KAMs_Scripts" (
		try (
			fileIn (scriptspath+"\\GTA_Tools\\tools\\Vehicle_Scale_Helper.ms") quiet:true
		) catch messagebox "Error!" title:"Can't run script"
	)
	
	macroScript kams_t_explode
		buttonText:"Object Explode"
		category:"KAMs_Scripts"
		internalCategory:"KAMs_Scripts" (
		try (
			fileIn (scriptspath+"\\GTA_Tools\\tools\\object_explode.ms") quiet:true
		) catch messagebox "Error!" title:"Can't run script"
	)
)

utility Kams_Scripts "Kam's GTA Scripts" (
	group "" (
		button script01 "DFF IO" width:140 align:#center
		button script02 "Collision IO" width:140 align:#center --offset:[0,-5]
		button script03 "Map IO" width:140 align:#center --offset:[0,-5]
	)
	on script01 pressed do ( 
		try ( fileIn (scriptspath+"\\GTA_Tools\\GTA_DFF_IO.ms") quiet:true   )
		catch messagebox "Please re-install my DFF IO script!" title:"Can't find DFF IO script"
	)		
	
	on Kams_Scripts open do (
		addKamsToolsMenu_()		
	)
	
	on script02 pressed do (   
		try ( fileIn (scriptspath+"\\GTA_Tools\\GTA_COL_IO.ms") quiet:true   )
		catch messagebox "Please re-install my Collision IO script!" title:"Can't find Collision IO script"
	)

	on script03 pressed do ( 
		try ( fileIn (scriptspath+"\\GTA_Tools\\GTA_Map_IO.ms") quiet:true   )
		catch messagebox "Please re-install my Map IO script!" title:"Can't find Map IO script"
	)	
	group "Animation" (
		button script05 "IFP dump" width:140 align:#center tooltip:"This script is for GMax only"--offset:[0,-5]
		button script06 "IFP IO" width:140 align:#center offset:[0,-5]
	)
		on script05 pressed do (
			try ( fileIn (scriptspath+"\\GTA_Tools\\GTA_IFP_dump.ms") quiet:true   )
			catch messagebox "Please re-install my IFP IO script!" title:"Can't find Animation IO script"
		)	
		on script06 pressed do (
			try ( fileIn (scriptspath+"\\GTA_Tools\\GTA_IFP_IO.ms") quiet:true   )
			catch messagebox "Please re-install my IFP IO script!" title:"Can't find Animation IO script"
		)

	group "Tools" (
		button script04 "Prelite Tools" width:140 align:#center 
		button script07_ "Align pivot to center" width:140 align:#center
		button script09 "Vehicle Scale Helper" width:140 align:#center
	)	


	on script09 pressed do (
		try fileIn (scriptspath+"\\GTA_Tools\\tools\\Vehicle_Scale_Helper.ms") quiet:true
		catch messagebox "Error!" title:"Can't run script"
	)
	
	on script07_ pressed do ( 
		if $selection.count > 0 then (
			clearListener()
			format "Fix pivots started:\n"
			for obj in $selection  do (
				if superclassof obj == GeometryClass then (
					CenterPivot obj
					ResetXForm obj
					convertToPoly obj
					format "[Fixed] %\n" obj.name
				) else format "[no Fixed] % - is not a geometry\n" obj.name
			)
		) else messagebox "Models Not Selected!" title: "Align pivot - error"
	)	
	on script04 pressed do (
		try (DestroyDialog G_PrelitTools) catch()
		rollout G_PrelitTools "Prelit Tools"  (
			group "show vertex color" (
				button _day_btn "DAY"  align:#left across:3 
				button _off_btn "Off"  align:#left  width:40 offset:[-4,0]
				button _night_btn "NIGHT"  align:#right 
			)
			group "Set Prelit to Sel Models" (
				colorPicker day_cp "Day  " color:[255,255,255] width:111 height:20 align:#left
				colorPicker nig_cp "Night" color:[0,0,0] width:111 height:20 align:#left
			)
			group "Vertex coping" (
				spinner prVal "+/- value:" width:90 height:16 range:[-255,255,0] type:#integer align:#center
				button DtoN "Day to Night"  height:28 align:#left  across:2 width:68
				button NtoD "Night to Day"  height:28 width:68 align:#right
				button DtoD "Day to Day"  height:24 align:#left  across:2 width:64 offset:[0,5]
				button NtoN "Night to Night"  height:24 width:72 align:#right offset:[0,5]
			)

			on _off_btn pressed do
				if $selection != undefined then (
					for o in $selection where (superclassof o  == GeometryClass ) do (
						o.showVertexColors = false
					)
					completeRedraw()
				)
				
			on _night_btn pressed do
				if $selection != undefined then (
					for o in $selection where (superclassof o  == GeometryClass ) do (
						o.showVertexColors = true
						o.vertexColorType = #illum
					)
					completeRedraw()
				)
			on _day_btn pressed do
				if $selection != undefined then (
					for o in $selection where (superclassof o  == GeometryClass ) do (
						o.showVertexColors = true
						o.vertexColorType = #color
					)
					completeRedraw()
				)
			
			on DtoD pressed do (	
				if $selection !=undefined then (
					suspendediting()
					disableSceneRedraw()
					setWaitCursor()
					enableUndo false
					try (
						for obj in $selection where (superclassof obj == GeometryClass ) do (
							if (classof obj) != Editable_Poly then convertToPoly obj
							if polyop.getMapSupport obj 0 == true then (
								for i = 1 to polyOp.getNumMapVerts obj 0 do (
								  tmp1 = polyOp.getMapVert obj 0 i
								  tmp1 *= 255.0
								  tmp1 += prVal.value
								  tmp1 /= 255.0
									if tmp1[1] > 1.0 then tmp1[1] = 1.0
									if tmp1[2] > 1.0 then tmp1[2] = 1.0
									if tmp1[3] > 1.0 then tmp1[3] = 1.0						
									if tmp1[1] < 0.0  then tmp1[1] = 0.0
									if tmp1[2] < 0.0  then tmp1[2] = 0.0
									if tmp1[3] < 0.0  then tmp1[3] = 0.0
								  polyOp.setMapVert obj 0 i tmp1
								)
								addModifier obj (VertexPaint ())
								collapseStack obj
								format "\nVertex Coping: done! %\n" obj.name
							)
						)
					) catch ( format "\nVertex Coping: error!\n")
					resumeediting()
					enableSceneRedraw()
					setArrowCursor()
					redrawViews()
					enableUndo true
				)
			)
			
			on NtoN pressed do (	
				if $selection !=undefined then (
					suspendediting()
					disableSceneRedraw()
					setWaitCursor()
					enableUndo false
					clearlistener()
					try (
						for obj in $selection where (superclassof obj == GeometryClass ) do (
							if (classof obj) != Editable_Poly then convertToPoly obj
							if polyop.getMapSupport obj -1 == true then (
								for i = 1 to polyOp.getNumMapVerts obj -1 do (
								  tmp1 = polyOp.getMapVert obj -1 i
								  tmp1 *= 255.0
								  tmp1 += prVal.value
								  tmp1 /= 255.0
									if tmp1[1] > 1.0 then tmp1[1] = 1.0
									if tmp1[2] > 1.0 then tmp1[2] = 1.0
									if tmp1[3] > 1.0 then tmp1[3] = 1.0						
									if tmp1[1] < 0.0  then tmp1[1] = 0.0
									if tmp1[2] < 0.0  then tmp1[2] = 0.0
									if tmp1[3] < 0.0  then tmp1[3] = 0.0
									polyOp.setMapVert obj -1 i tmp1
								)
								addModifier obj (VertexPaint ())
								collapseStack obj
								format "\nVertex Coping: done! %\n" obj.name
							)
						)
					) catch ( format "\nVertex Coping: error!\n")
					resumeediting()
					enableSceneRedraw()
					setArrowCursor()
					redrawViews()
					enableUndo true
				)
			)
			
			on DtoN pressed do (	
				if $selection !=undefined then (
					suspendediting()
					disableSceneRedraw()
					setWaitCursor()
					enableUndo false
					try (
						for obj in $selection where (superclassof obj == GeometryClass ) do (
							if (classof obj) != Editable_Poly then convertToPoly obj
							if polyop.getMapSupport obj 0 == true then (
								polyOp.setMapSupport obj -1 false
								polyOp.setMapSupport obj -1 true
								vcnum = polyOp.getNumMapVerts obj 0
								polyOp.setNumMapVerts obj -1 vcnum
								for i = 1 to vcnum do (
								  tmp1 = polyOp.getMapVert obj 0 i
								  tmp1 *= 255.0
								  tmp1 += prVal.value
								  tmp1 /= 255.0
									if tmp1[1] > 1.0 then tmp1[1] = 1.0
									if tmp1[2] > 1.0 then tmp1[2] = 1.0
									if tmp1[3] > 1.0 then tmp1[3] = 1.0						
									if tmp1[1] < 0.0  then tmp1[1] = 0.0
									if tmp1[2] < 0.0  then tmp1[2] = 0.0
									if tmp1[3] < 0.0  then tmp1[3] = 0.0
								  polyOp.setMapVert obj -1 i tmp1
								)
								vcfaces = polyOp.getNumMapFaces obj 0
								polyOp.setnummapfaces obj -1 vcfaces
								for i = 1 to vcfaces do (
									tmp1 = polyOp.getMapFace obj 0 i
									polyOp.setMapFace obj -1 i tmp1
								)
								format "\nVertex Coping: done! %\n" obj.name
							) else format "\nVertex Coping: error! obj % not have this map support\n" obj.name
						)
					) catch ( format "\nVertex Coping: error!\n")
					resumeediting()
					enableSceneRedraw()
					setArrowCursor()
					redrawViews()
					enableUndo true
				)
			)
			on NtoD pressed do (	
				if $selection !=undefined then (
					suspendediting()
					disableSceneRedraw()
					setWaitCursor()
					enableUndo false
					try (
						for obj in $selection where (superclassof obj == GeometryClass ) do (
							if (classof obj) != Editable_Poly then convertToPoly obj
							if polyop.getMapSupport obj -1 == true then (
								polyOp.setMapSupport obj 0 false
								polyOp.setMapSupport obj 0 true
								vcnum = polyOp.getNumMapVerts obj -1
								polyOp.setNumMapVerts obj 0 vcnum
								for i = 1 to vcnum do (
								  tmp1 = polyOp.getMapVert obj -1 i
								  tmp1 *= 255.0
								  tmp1 += prVal.value
								  tmp1 /= 255.0
									if tmp1[1] > 1.0 then tmp1[1] = 1.0
									if tmp1[2] > 1.0 then tmp1[2] = 1.0
									if tmp1[3] > 1.0 then tmp1[3] = 1.0						
									if tmp1[1] < 0.0  then tmp1[1] = 0.0
									if tmp1[2] < 0.0  then tmp1[2] = 0.0
									if tmp1[3] < 0.0  then tmp1[3] = 0.0
								  polyOp.setMapVert obj 0 i tmp1
								)
								vcfaces = polyOp.getNumMapFaces obj -1
								polyOp.setnummapfaces obj 0 vcfaces
								for i = 1 to vcfaces do (
									tmp1 = polyOp.getMapFace obj -1 i
									polyOp.setMapFace obj 0 i tmp1
								)
								format "\nVertex Coping: done! %\n" obj.name
							) else format "\nVertex Coping: error! obj % not have this map support\n" obj.name
						)
						
					) catch ( format "\nVertex Coping: error!\n")
					resumeediting()
					enableSceneRedraw()
					setArrowCursor()
					redrawViews()
					enableUndo true
				)
			)

			on day_cp changed arg do (
				for obj in $selection where superclassof obj == GeometryClass do (
					convertToPoly obj
					polyOp.defaultMapFaces obj 0
					for i = 1 to obj.numverts do polyOp.setMapVert obj 0 i (arg/255.0)
					completeRedraw()
				)
			)
			on nig_cp changed arg do (
				for obj in $selection  where superclassof obj == GeometryClass do (
					convertToPoly obj
					polyOp.defaultMapFaces obj -1
					for i = 1 to obj.numverts do polyOp.setMapVert obj -1 i (arg/255.0)
					completeRedraw()
				)
			)
		)
		createDialog G_PrelitTools
	)

	-----------------------------------------
	button script08 "About"  align:#left across:2 height:16 tooltip:"Authors"
	label SC_t1 "v0.3.7   " align:#right
	on script08 pressed do (
		try (DestroyDialog KAM_About) catch()
		rollout KAM_About "Authors (c)"    (
			label about_1 "[19.12.05]" offset: [0.0,7.0,0.0]
			label about_2 "Kam, Odie, Pioneer"
			HyperLink l_top "Topic on the Gta Forums" align:#center   height:18 address:"http://gtaforums.com/topic/218318-rel-kams-maxscript-going-over-quick-update/" color:(color 10 147 225) hovercolor:(color 94 198 255) visitedcolor:(color 10 147 225)
			
			label about_3 " -- Upd  v0.3.7 --" offset: [0.0,7.0,0.0]
			label about_0 "[13.05.2020]"
			label about_4 "by Goldfish"
			label about_5 "(Goldfish-1994@yandex.ru)"
			HyperLink l_sup "Support" align:#center   height:18 address:"https://vk.com/topic-99725313_37821803" color:(color 10 147 225) hovercolor:(color 94 198 255) visitedcolor:(color 10 147 225) 
			HyperLink l_vk "VK"  align:#center  height:18 address:"https://vk.com/vk.goldfish" color:(color 10 147 225) hovercolor:(color 94 198 255) visitedcolor:(color 10 147 225) 
		)
		createDialog KAM_About
	)

)
openUtility Kams_Scripts
