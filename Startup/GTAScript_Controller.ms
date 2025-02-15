try ( closeUtility Kams_Scripts) catch ()
fn runEmt = ()
fn addKamsToolsMenu_ = (
------------------ deleting previous menu
	if ((menuMan.findMenu "GTA Tools") != undefined) then (
		menuMan.unRegisterMenu (menuMan.findMenu "GTA Tools")
		menuMan.updateMenuBar()
	)
	
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
	
	try (
		--------------------creating menu
		mainMenuBar = menuMan.getMainMenuBar()
		subMenu = menuMan.createMenu "GTA Tools"
		testItem = menuMan.createActionItem ("kams_dffio") "KAMs_Scripts"
		subMenu.addItem testItem -1	
		
		separator2 = menuMan.createSeparatorItem() -- LINE
		subMenu.addItem separator2 -1
		subSubMenu2 = menuMan.createMenu "Colision"
		testSubItem2 = menuMan.createSubMenuItem "name" subSubMenu2
		subMenu.addItem testSubItem2 -1
		testItem = menuMan.createActionItem ("kams_colio") "KAMs_Scripts"
		subSubMenu2.addItem testItem -1
		testItem = menuMan.createActionItem ("kams_cstImp") "KAMs_Scripts"
		subSubMenu2.addItem testItem -1
		testItem = menuMan.createActionItem ("kams_cstExp") "KAMs_Scripts"
		subSubMenu2.addItem testItem -1
		
		
		separator1 = menuMan.createSeparatorItem() -- LINE
		subMenu.addItem separator1 -1
		subSubMenu1 = menuMan.createMenu "MAP"
		testSubItem1 = menuMan.createSubMenuItem "name" subSubMenu1
		subMenu.addItem testSubItem1 -1
		testItem = menuMan.createActionItem ("kams_mapio") "KAMs_Scripts"
		subSubMenu1.addItem testItem -1
		testItem = menuMan.createActionItem ("kams_emap") "KAMs_Scripts"
		subSubMenu1.addItem testItem -1
		testItem = menuMan.createActionItem ("kams_t_explode") "KAMs_Scripts"
		subSubMenu1.addItem testItem -1
		
		separator3 = menuMan.createSeparatorItem() -- LINE
		subMenu.addItem separator3 -1
		subSubMenu3 = menuMan.createMenu "Prelite"
		testSubItem3 = menuMan.createSubMenuItem "name" subSubMenu3
		subMenu.addItem testSubItem3 -1
		testItem = menuMan.createActionItem ("kams_t_prelit") "KAMs_Scripts"
		subSubMenu3.addItem testItem -1
		testItem = menuMan.createActionItem ("kams_VCsT") "KAMs_Scripts"
		subSubMenu3.addItem testItem -1
		
		
		separator = menuMan.createSeparatorItem() -- LINE
		subMenu.addItem separator -1
		subSubMenu = menuMan.createMenu "Tools"
		testSubItem = menuMan.createSubMenuItem "name" subSubMenu
		subMenu.addItem testSubItem -1	
		testItem = menuMan.createActionItem ("kams_waterio") "KAMs_Scripts"
		subSubMenu.addItem testItem -1
		testItem = menuMan.createActionItem ("kams_t_VRH") "KAMs_Scripts"
		subSubMenu.addItem testItem -1
		testItem = menuMan.createActionItem ("kams_BM") "KAMs_Scripts"
		subSubMenu.addItem testItem -1
		testItem = menuMan.createActionItem ("kams_valph") "KAMs_Scripts"
		subSubMenu.addItem testItem -1
		
		separator4 = menuMan.createSeparatorItem() -- LINE
		subMenu.addItem separator4 -1
		subSubMenu4 = menuMan.createMenu "Model FIXs"
		testSubItem4 = menuMan.createSubMenuItem "name" subSubMenu4
		subMenu.addItem testSubItem4 -1
		testItem = menuMan.createActionItem ("kams_FixDif") "KAMs_Scripts"
		subSubMenu4.addItem testItem -1
		testItem = menuMan.createActionItem ("kams_t_fixPivot") "KAMs_Scripts"
		subSubMenu4.addItem testItem -1
		testItem = menuMan.createActionItem ("kams_t_alignPivot") "KAMs_Scripts"
		subSubMenu4.addItem testItem -1

			
		-----------------------updating menu
		subMenuItem = menuMan.createSubMenuItem "Test Menu" subMenu
		subMenuIndex = mainMenuBar.numItems() 0
		mainMenuBar.addItem subMenuItem subMenuIndex
		menuMan.updateMenuBar()
	) catch messagebox ("Error creating GTA Tools menu!\n\nYou can run scripts manually from the folder:\n" + scriptspath+"\GTA_Tools\Tools\\") title: "Kam's GTA Scripts (GF)"
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
