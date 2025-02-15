/*
 - Export MAP Tool v1.3b -
 
Last update: 10.12.19
 
Supported functions:
 - Export IPL / IDE
 - Error checking
 - AutoSearch LODs

Author: 
Goldfish (CRime team 2017)

The script is in beta testing, bout all bugs and offers report in https://vk.com/topic-99725313_35674835

Support: 
Goldfish-1994@yandex.ru 
https://vk.com/topic-99725313_35674835

		
Change the code on your own risk !!!
*/


actionMan.executeAction 0 "40472" 
global rl_IMAPT

rollout Utilites_rol "Utilites"(
	button hideErrObj "Hide All OBJ Wth Errs" pos:[8,10] enabled:false  height:18 tooltip:"Hide all objects with errors (after checking for errors)"
	button cpyAsLod "Copy Obs as LODs" pos:[8,35]   height:20 tooltip:"create lods from selected models (lod + model name and a copy of the txd name property)"
	
	on cpyAsLod pressed do (
		for obj in selection do (
			new_ob = copy obj
			new_ob.name = "lod" + obj.name
			txdProp = getuserprop obj "TXD"
			if txdProp != undefined then (
				setUserProp new_ob "TXD" ("lod" + txdProp)
			)
		)
	)
	on hideErrObj pressed do (
		if objForHide.count > 0 then (
			for i in objForHide do (i.isHidden = true)
		)
	)
	
)

rollout About_rol "About"(
	label lb0_about1 "Utility for exporting \nthe GTA SA map in IPL / IDE \n                 ------------------------" pos:[12,15]  height:90 
	label lbl_about1 "Export MAP Tool  (EMAP Tool)" pos:[12,65] 
	label lb2_about1 "Version:  1.3b   (upd 10.12.19)" pos:[12,85] 
	label lb3_about1 "Author:  GoldFish" pos:[12,100] 
	label lb4_about1 "Specially for the" pos:[12,115] 
	HyperLink toCRime_team "CRime team" pos:[91,115] width:100 height:16 address:"https://vk.com/crime_offcial" color:(color 255 255 255) hovercolor:(color 255 255 120) visitedcolor:(color 255 255 255)
	label lbl_about2 "Support:\nAbout all bugs and offers report" pos:[12,140]  height:50
	HyperLink toSupport "to here" pos:[163,153] width:100 height:16 address:"https://vk.com/topic-99725313_35674835" color:(color 255 255 255) hovercolor:(color 255 255 120) visitedcolor:(color 255 255 255)
	label lb2_about2 "\xa9 CRime team 2017" pos:[50,190]
)	

rollout rl_IMAPT "Export MAP tool" 
(
	GroupBox grp1 "Basic parameters" pos:[3,6] width:198 height:94
	button setVal "Set values" pos:[10,29] width:186 height:23 tooltip:"info1"
	checkButton infoStatus "ok" pos:[174,7] width:18 height:15 highlightcolor:(color 188 22 22) checked: true
	label lbl_IDstart "ID start" pos:[15,59]
	checkbox ch_sens "high sensitivity lods search " pos:[15,79] checked: true tooltip:"disable this option if the script does not find Lods"
	spinner IDstart "" pos:[52,58] width:80 height:16 range:[0,99999,0] type:#integer
	GroupBox grp2 "ipl / ide settings" pos:[3,128] width:198 height:202
	label lbl_txdname "TXD Name" pos:[13,153]
	checkbox TXDReplc "replace old names" pos:[13,170] checked: true
	label lbl_operations "Operation" pos:[137,173]
	edittext txdname "" pos:[9,188] width:122 height:19 
	button set_txdname "SET" pos:[134,189] width:30 height:18
	button get_txdname "GET" pos:[166,189] width:30 height:18
	label lbl_Interior "Interior" pos:[15,215] 
	spinner numInterior "" pos:[92,215] width:40 height:16 range:[0,99,0] type:#integer
	button set_numInterior "SET" pos:[134,215] width:30 height:18
	button get_numInterior "GET" pos:[166,215] width:30 height:18
	label lbl_Distance "Distance" pos:[15,235]
	spinner Distance "" pos:[72,235] width:60 height:16 range:[0,3000,299] type:#integer 
	button set_Distance "SET" pos:[134,234] width:30 height:18
	button get_Distance "GET" pos:[166,234] width:30 height:18
	label lbl_objflag "Flag" pos:[15,257]
	spinner objflag "" pos:[52,257] width:80 height:16 range:[0,1073741824,0] type:#integer
	button set_objflag "SET" pos:[134,254] width:30 height:18
	button get_objflag "GET" pos:[166,254] width:30 height:18
	button get_all "GET All" pos:[134,279] width:60 height:45
	label lbl_lodstart "LOD start" pos:[15,277] 
	spinner lodstart "" pos:[72,277] width:60 height:16 range:[0,999,0] type:#integer
	button reSetVal "Re Set All values" pos:[10,301] width:120 height:23 
	GroupBox grp3 "" pos:[3,330] width:198 height:40 
	button EXP_IDE "EXPORT IDE" pos:[8,342] width:184 height:23 tooltip:"Export IDE list"
	GroupBox grp4 "" pos:[3,370] width:198 height:64 
	checkbox LODasch "LOD AutoSearch" pos:[15,384] checked: true
	button EXP_IPL "EXPORT IPL" pos:[8,404] width:184 height:23 tooltip:"Export IPL list"
	GroupBox grp5 "" pos:[3,432] width:198 height:56
	button shStat "- check errors -" pos:[8,466] width:184 height:18 tooltip:"Check for errors in selected models"
	checkButton shstartTest "errors    " pos:[8,444] width:84 height:18 highlightcolor:(color 56 56 56) checked: true -- errors not found  / errors found !
	label shstartCnt "= n/a" pos:[94,447] 
	progressbar progressb pos:[3,108] color:blue width:198 height:10
	label pbtimel "time(sec):" pos:[115,125] 
	label pbsec "0.0000" pos:[160,126] 
	


-----------------  UI Update ------------------
global gTickTime = 0
fn interfaceUpdate gTickTime = (
	--print gTickTime
	if gTickTime > 25 then (
		app=dotNetclass "System.Windows.Forms.Application"
		app.doEvents()
		--windows.processPostedMessages()
		gTickTime = 0
	) else (
		gTickTime += 1
	)
	return gTickTime
)
-------------------------------------------------

global tEnd = 0.0 
global tStart = 0.0
global progressbMax = 0 
global progressbcount = 0 
global Ired = 0
global Igreen = 1
global objList = #()
global gIdeSetFlag = 2 -- errors state: 0 - not set, 1 - changed, 2 - normal
global errExist = 0 
global objForHide = #()

fn progressbUpdate varSt = (
	if varSt == -1 then (
		progressb.value = 0
	)
	else (
		progressb.value = (((varSt as float)/progressbMax)*100)
	)
)

fn fnImap_msg value = (
	case of(
		(value == 0): messagebox "First need to set the basic parameters (Set values) !" title: "EMAPTool notification"
		(value == 1): messagebox "The ID start was changed. \nReSet the basic parameters (Set values) !" title: "EMAPTool notification"
		(value == 2): messagebox "Enter TXD Name !" title: "EMAPTool error"
	)
)
fn listenerOpenState v = (
	if v == 0 then (
		t=windows.getChildHWND 0 "MAXScript Listener"
		UIAccessor.CloseDialog t[1]
	)
	if v == 1 then (
		actionMan.executeAction 0 "40472" 
	)
)
fn fnErrStat ers = (
		if ers == 0 then (	-- NOT ERRORS
			shstartTest.caption = "errors not found "
			shstartCnt.caption = "= n/a"
			shstartTest.highlightcolor = (color 0 112 0)
		)
		if ers > 0 then (	-- ERRORS FOUND
			shstartTest.caption = "errors found !"
			shstartCnt.caption = ("= " + (ers as string))
			shstartTest.highlightcolor = (color 163 32 32)
		)
		if ers == -1 then (	-- RESET ERR STATUS
			shstartTest.caption = "errors    "
			shstartCnt.caption = "= n/a"
			shstartTest.highlightcolor = (color 56 56 56) 
		)
		if ers == -2 then (	-- ERRORS FOUND without count
			shstartTest.caption = "errors found !"
			shstartCnt.caption = "= n/a"
			shstartTest.highlightcolor = (color 163 32 32)
		)
	)
fn fnInfStat value = (
		case of(
			(value == 0): (	-- red - false
				infoStatus.highlightcolor = (color 163 32 32)
				infoStatus.checked = false
				infoStatus.checked = true
			)
			(value == 1): (	-- green - true
				infoStatus.highlightcolor = (color 0 112 0) 
				infoStatus.checked = false
				infoStatus.checked = true
			)
		)
	)
fn lowercase str = (
	 local i, j, ucase, lcase, result
	 ucase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	 lcase = "abcdefghijklmnopqrstuvwxyz"
	 
	 result = copy str
	 for i = 1 to result.count do
	  (
	   j = findString ucase result[i]
	   if j != undefined  do result[i] = lcase[j]
	  )
	 result
) -- end fn tolower

	on rl_IMAPT open do (
		clearListener()	
		format "====================================================\n             Export MAP Tool v1.3b\n\n"
		format "by GoldFish (CRime team 2017)\nSupport: https://vk.com/goldscripts\n=====================================================\n"
		format "\nEMAPTool Started\n\n"
	)
	
	on get_all pressed do (
		for i in selection where (superclassof i == GeometryClass) do (
			if getuserprop i "TXD" != undefined then txdname.text = ((getuserprop i "TXD") as string)
			else txdname.text = ""
			if getuserprop i "numInterior" != undefined then numInterior.value = ((getuserprop i "numInterior") as integer)
			else numInterior.value = 0
			if getuserprop i "DISTANCE" != undefined then Distance.value = ((getuserprop i "DISTANCE") as integer)
			else Distance.value = 0 
			if getuserprop i "FLAG" != undefined then objflag.value = ((getuserprop i "FLAG") as integer)
			else objflag.value = 0
			exit
		)
	)
	on set_txdname pressed do (
		if gIdeSetFlag == 2 then (	
			if txdname.text != "" then (
				for i in selection where (superclassof i == GeometryClass) do (
					setUserProp i "TXD" txdname.text							
				)
			)
		) else (
			fnImap_msg(gIdeSetFlag as integer)
		)
	)
	on get_txdname pressed do ( 
		for i in selection where (superclassof i == GeometryClass) do (
			if getuserprop i "TXD" != undefined then txdname.text = ((getuserprop i "TXD") as string)
			else txdname.text = ""
			exit
		)
	)
	on set_numInterior pressed do (
		if gIdeSetFlag == 2 then (	
			for i in selection where (superclassof i == GeometryClass) do (
				setUserProp i "numInterior" numInterior.value							
			)
		) else (
			fnImap_msg(gIdeSetFlag as integer)
		)
	)
	on get_numInterior pressed do (
		for i in selection where (superclassof i == GeometryClass) do (
			if getuserprop i "numInterior" != undefined then numInterior.value = ((getuserprop i "numInterior") as integer)
			else numInterior.value = 0
			exit
		)
	)
	on set_Distance pressed do (
		if gIdeSetFlag == 2 then (	
			for i in selection where (superclassof i == GeometryClass) do (
				setUserProp i "DISTANCE" Distance.value	
			)
		) else (
			fnImap_msg(gIdeSetFlag as integer)
		)
	)
	on get_Distance pressed do (
		for i in selection where (superclassof i == GeometryClass) do (
			if getuserprop i "DISTANCE" != undefined then Distance.value = ((getuserprop i "DISTANCE") as integer)
			else Distance.value = 0 
			exit
		)
	)
	on set_objflag pressed do (
		if gIdeSetFlag == 2 then (
			for i in selection where (superclassof i == GeometryClass) do (
				setUserProp i "FLAG" objflag.value	
			)
		) else (
			fnImap_msg(gIdeSetFlag as integer)
		)
	)
	on get_objflag pressed do (
		for i in selection where (superclassof i == GeometryClass) do (
			if getuserprop i "FLAG" != undefined then objflag.value = ((getuserprop i "FLAG") as integer)
			else objflag.value = 0
			exit
		)	
	)

	on infoStatus changed state do (
		if state == false then infoStatus.checked = true
	)
	on shstartTest changed state do (
		if state == false then shstartTest.checked = true
	)
	on IDstart changed ch do (
		gIdeSetFlag = 1
		fnInfStat Ired
		clearListener()	
		format "\n[WARNING] - EMAPTool: ID start was changed. \nReSet the basic parameters (Set values)\n"
	) -- IDstart changed
	-----------------------------------------------------------------
	-----------------------------------------------------------------
	-----------------------------------------------------------------
	fn fn_SrchLods lodObj arrObj = ( -- проверка имеет ли лод модель
		local foundObj = undefined
		for i in arrObj where (superclassof i == GeometryClass and (substring (tolower i.name) 1 3)!= "lod") do (
			if ("lod" + (tolower i.name)) == (tolower lodObj.name) then (
				if ch_sens.checked == true then (
					if ((i.position == lodObj.position) or (i.position as string) == (lodObj.position as string)) then (
						foundObj = i
						exit
					)
				) else (
					foundObj = i
					exit
				)
			)
		)
		if foundObj == undefined then (
			for i in selection where (superclassof i == GeometryClass and (substring (tolower i.name) 1 3)!= "lod") do (
				if ("lod" + (tolower(substring i.name 4 -1))) == (tolower lodObj.name) then (
				--format "2 # % | %\n" ("lod" + (tolower(substring lodObj.name 4 -1))) (tolower lodObj.name)
					
					if ((i.position == lodObj.position) or (i.position as string) == (lodObj.position as string)) then (
						foundObj = i
						exit
					)
				)
			)
		)
		return foundObj
	)
	
	on setVal pressed do (
		if selection.count == 0 then ( 
			messagebox "Select the objects !" title: "EMAPTool error"
		) else ( 
			if txdname.text != "" then (
				objList = #()
				clearListener()
				fnErrStat -1
				errExist = 0
				listenerOpenState 1
				Utilites_rol.hideErrObj.enabled = false
				ide = IDstart.value
				progressbcount = 0
				progressbMax = selection.count		
					
				--position FIX (20.03.2019)
				disableSceneRedraw()
				try (
					for obj in selection where (superclassof obj == GeometryClass) do (
						converttomesh obj
						tmp = obj.pos
						obj.pos = [0,0,0]
						obj.pos = tmp
						converttopoly obj
					)
				) catch ()
				enableSceneRedraw()
				for obj in selection where (superclassof obj == GeometryClass) do (
					progressbcount += 1
					progressbUpdate progressbcount
					if obj.name.count < 25 then (
						local modLodsdef = 0
						-- проверка имеет ли лод модель
							if (substring (tolower obj.name) 1 3) == "lod" then (
								modLodsdef = fn_SrchLods obj selection
							)
							if modLodsdef != undefined then (
								local arrIdeFlag = false
								local tmpID
								-- исключение нумерации id моделей с одинаковыми именами
								if objList.count > 0 then (
									for i in objList do (
										if i.name == obj.name then (
											arrIdeFlag = true
											tmpID = (getuserprop i "IDEnum")  
											exit
										)
									)
								)
								tmpTxd_= (getuserprop obj "TXD")
								if tmpTxd_ != undefined then (
									setuserpropbuffer obj ""
									setUserProp obj "TXD" tmpTxd_
								) else setuserpropbuffer obj ""
								
								if arrIdeFlag == true then (
									setUserProp obj "IDEnum" tmpID
								) else (
									
									setUserProp obj "IDEnum" ide
									ide += 1
								)
								if TXDReplc.checked == true then (
									setUserProp obj "TXD" txdname.text	
								) else (
									if (getuserprop obj "TXD") == undefined then setUserProp obj "TXD" txdname.text	
								)		
								setUserProp obj "DISTANCE" Distance.value								
								setUserProp obj "FLAG" objflag.value
								setUserProp obj "numInterior" numInterior.value			
								setUserProp obj "lodFlag" objflag.value
								append objList obj
								
							) else errExist += 1
					) else ( -- если имя > 24
						errExist += 1
					)
				)
				
				gIdeSetFlag = 2
				fnInfStat Igreen	
				format "\n[OK] - EMAPTool: The basic parameters are successfully set\n\n - Now you can change the ipl / ide settings (ReSet values) OR start exporting the mapping (EXPORT IDE/IPL)\n\n"					
				if errExist > 0 then (
					fnErrStat -2
					format "[WARNING] - EMAPTool: Found errors, see the entire list of errors in ( - check errors - )\n\n"
				)
			) else (
				fnImap_msg 2
			)
		)
		progressbUpdate -1
	) -- setVal pressed 
	-----------------------------------------------------------------
	-----------------------------------------------------------------
	-----------------------------------------------------------------	
	on reSetVal pressed do (
		if gIdeSetFlag == 2 then (
			if selection.count == 0 then ( 
				messagebox "Select the objects !"
			) else (
				if txdname.text != "" then (
					clearListener()
					fnErrStat -1
					errExist = 0
					listenerOpenState 1
					ide = IDstart.value
						for obj in selection where (superclassof obj == GeometryClass) do (
							if obj.name.count < 25 then (
								if TXDReplc.checked == true then (
									setUserProp obj "TXD" txdname.text	
								) else (
									if (getuserprop obj "TXD") == undefined then setUserProp obj "TXD" txdname.text	
								)	
								setUserProp obj "DISTANCE" Distance.value
								setUserProp obj "FLAG" objflag.value
								setUserProp obj "numInterior" numInterior.value	
								ide += 1
							) else (-- obj.name.count
									errExist += 1
							)
						)
						if errExist > 0 then fnErrStat -2
					clearListener()	
					format "\n[OK] - EMAPTool: The ipl / ide settings are successfully replaced\n\n - Now you can change the ipl / ide settings (ReSet All values) OR start exporting the mapping (EXPORT IDE/IPL)\n\n"
				) else (
					fnImap_msg 2
				)
			)
		) else (
			fnImap_msg(gIdeSetFlag as integer)
		)
	) -- reSetVal pressed
	-----------------------------------------------------------------
	-----------------------------------------------------------------
	-----------------------------------------------------------------
	on EXP_IDE pressed do( -- IDE EXPORT
		if gIdeSetFlag == 2 then (
			if objList.count > 0 then(
				clearListener()	
				fnErrStat -1
				errExist = 0
				listenerOpenState 0
				local arrIde = #()
				--format "#IDE list - Generated by EMAPTool\n"
				progressbcount = 0
				progressbMax = objList.count
				for obj in objList do (		-- ОСН. ЦИКЛ
					progressbcount += 1
					progressbUpdate progressbcount
					local modLodsdef = undefined
					-- проверка, если это лод, то имеет ли он модель
					if (substring (tolower obj.name) 1 3) == "lod" then (
						modLodsdef = fn_SrchLods obj objList
					) else (
						modLodsdef = 1 
					)
					if modLodsdef != undefined then (
						local arrIdeFlag = false
						if arrIde.count > 0 then (				
						-- исключение нумерации id моделей с одинаковыми именами
							for i in arrIde do (
								if i == obj.name then (
									arrIdeFlag = true
									exit
								)
							)
						)
						if arrIdeFlag == false then (
							format "%, %, %, %, %\n" (getuserprop obj "IDEnum") obj.name (getuserprop obj "TXD") (getuserprop obj "DISTANCE") (getuserprop obj "FLAG")
							append arrIde obj.name
						)
					)
				) -- for
			) else (
				fnImap_msg 0
			)
			listenerOpenState 1
		) else (
			fnImap_msg gIdeSetFlag
		)
		progressbUpdate -1
	) -- EXP_IDE pressed
	-----------------------------------------------------------------
	-----------------------------------------------------------------
	-----------------------------------------------------------------	
	on EXP_IPL pressed do( -- IPL EXPORT	errExist
		if objList.count > 0 then(
			clearListener()	
			fnErrStat -1
			errExist = 0 
			objForHide = #()
			Utilites_rol.hideErrObj.enabled = false
			listenerOpenState 0
			numLOD = (lodstart.value + 1)
			local singleObjs = #()		
			progressbcount = 0
			gTickTime = 0	
			tStart = timeStamp()
			disableSceneRedraw()		
			modelObjLst = #()
			modelObjLst = for obj in objList where (substring (tolower obj.name) 1 3)!= "lod" collect obj
			progressbMax = modelObjLst.count	
			--format "#IPL list - Generated by EMAPTool\n"	
			for obj in modelObjLst do (
				gTickTime = interfaceUpdate gTickTime -- UI update
				progressbcount += 1
				progressbUpdate progressbcount
				if obj.name.count < 24 then (
					r = obj.rotation
					--id, dffName, interrorNum, x, y, z, q.x, q.y, q.z, q.w, lodNum
					format "%, %, %, %, %, %, %, %, %, %, "  \
						 (getuserprop obj "IDEnum")  obj.name (getuserprop obj "numInterior") \
						 (formattedPrint obj.position.x format:".5f")  (formattedPrint obj.position.y format:".5f")  (formattedPrint obj.position.z format:".5f") \
						 (-r.x as float) (-r.y as float) (-r.z as float) (r.w as float)
						 
					--autosearch lod:
					if LODasch.checked == true then (
					local lodObjArr = #()
					--lodObjArr = execute ("$*lod" + obj.name)
					-- search LOD + name = LODname
					for i in objList where ((tolower i.name) == ("lod" + (tolower obj.name))) do append lodObjArr i
					-- search 2 - LOD + name = LODe
					if lodObjArr.count == 0 then (
						for i in objList where ( (substring (tolower i.name) 1 3)== "lod") do (
							--format "\n*** %\n" (tolower i.name) 
							if (tolower i.name) == ("lod" + (tolower(substring obj.name 4 -1))) then (
								--format "\n$$$ 2 %\n" ("lod" + (tolower(substring obj.name 4 -1)))
								append lodObjArr i 
								--format "\n&&& % | % | %\n" (tolower i.name) ("lod" + (tolower(substring obj.name 4 -1))) ((tolower i.name) == ("lod" + (tolower(substring obj.name 4 -1))))
							)
						)
					)	

					if lodObjArr.count > 0 then (
							local cnt = 0
							local chExp = false
							for lodObj in lodObjArr do (
								cnt += 1
								if superclassof lodObj == GeometryClass then (
									if ch_sens.checked == true then (
									
										if (obj.position == lodObj.position) or (obj.position as string) == (lodObj.position as string) then chExp = true
									) else chExp = true
									if chExp == true then (
										format "%\n" numLOD
										numLOD += 2
										format "%, %, %, %, %, %, %, %, %, %, -1\n"  \
											 (getuserprop lodObj "IDEnum")  lodObj.name (getuserprop obj "numInterior") \
											 lodObj.position.x  lodObj.position.y  lodObj.position.z \
											 (-r.x as float) (-r.y as float) (-r.z as float) (r.w as float)
											 setUserProp lodObj "lodFlag" 0
											 exit
									) else (
										if lodObjArr.count == cnt then (
											format "-1\n"
											numLOD += 1
										)
									)
								) else (
									format "-1\n"
									numLOD += 1
									append singleObjs obj.name
								)
							)
						) else (
							format "-1\n"
							numLOD += 1
						)
					) else (
						format "-1\n"
					)
				) else (-- obj.name.count
						errExist += 1
				)
			) -- for
			--search remaining lod
			for obj in objList where ((substring obj.name 1 3)== "lod" and getuserprop obj "lodFlag" == 1) do (
				errExist += 1
			)
			if errExist > 0 then fnErrStat -2
			listenerOpenState 1
		) else (
			fnImap_msg 0
		)	
		enableSceneRedraw()
		tEnd = timeStamp()
		pbsec.text = (((tEnd - tStart) / 1000.0)as string)
		progressbUpdate -1
	) -- EXP_IPL pressed
	-----------------------------------------------------------------
	-----------------------------------------------------------------
	-----------------------------------------------------------------
	on shStat pressed do (
		if selection.count > 0 then ( 		
			listenerOpenState 0
			clearListener()	
			fnErrStat -1
			progressbcount = 0
			objForHide = #()
			Utilites_rol.hideErrObj.enabled = false
			progressbMax = (selection.count * 4)
			tStart = timeStamp()
			disableSceneRedraw()
			format "\n\n--------- EMAPTool Error search system - v 1.0 --------\n"
			format "---------------------------------------------------------\n"
			format "------------------- MAP IPL error log -------------------\n\n\n"
			local foundFlag = false
			local stat_gmclass = 0 
			local stat_cops = 0
			local arr_modwLod = #()
			local arr_lodwMod = #()
			local arr_lngName = #()  
			local arr_notCorctModlist = #()
			local arr_notCorctLodlist = #()
			
			-- check copies
			
			for obj in selection where (superclassof obj) == GeometryClass  do (
				progressbcount += 1
				progressbUpdate progressbcount
				for obj2 in selection where ((superclassof obj) == GeometryClass and obj2 != obj)  do (
					if obj.name == obj2.name then stat_cops += 1
				)
			)
			
			-- check long name
			obj = undefined
			for obj in selection where (superclassof obj) == GeometryClass  do (
				progressbcount += 1
				progressbUpdate progressbcount
				if obj.name.count > 24 then (
					append arr_lngName obj.name
					append objForHide obj
				)
			)

			-- Models with not correct Lods
			obj = undefined
			for obj in selection where ( superclassof obj == GeometryClass and (substring (tolower obj.name) 1 3)!= "lod") do (
				progressbcount += 1
				progressbUpdate progressbcount				
				foundFlag = false
				local formatlodMame = ("lod" + (substring obj.name 4 -1))			
				for i in selection where ((substring (tolower i.name) 1 3)== "lod") do (
					--format "#1 % | % | %\n" (tolower i.name) formatlodMame ((tolower i.name) == formatlodMame)
					if (tolower i.name) == (tolower formatlodMame) then (
						if ((obj.position == i.position) or (obj.position as string) == (i.position as string)) then (
							foundFlag = true
							exit
						)
					)
				)
				if foundFlag == true then (
					for i2 in arr_notCorctModlist where (i2 == obj.name) do (
						foundFlag = false
						exit
					)
					if foundFlag == true then (
						append arr_notCorctModlist obj.name
						append arr_notCorctLodlist (tolower formatlodMame)
					)
				)
			)
				
			--check MODELs without LODs
			obj = undefined
			for obj in selection where ( superclassof obj == GeometryClass and (substring (tolower obj.name) 1 3)!= "lod") do (
				progressbcount += 1
				progressbUpdate progressbcount
				foundFlag = false
				for i in arr_notCorctModlist where (i == obj.name) do (
					foundFlag = true 
					exit
				)
				if foundFlag == false and obj.name.count < 25 then (
					lodNm = "lod" + (tolower obj.name)
					for i in selection where (tolower i.name) == lodNm do (
						if ((obj.position == i.position) or (obj.position as string) == (i.position as string)) then (
							foundFlag = true
							exit
						)
					)
					if foundFlag == false then (
						foundFlag = false
						for i2 in arr_modwLod where (i2 == obj.name) do (
							foundFlag = true
							exit
						)
						if foundFlag == false then append arr_modwLod obj.name 
					)
				)
			)	
			
			--check LODs without MODELs
			obj = undefined
			for obj in selection where ( superclassof obj == GeometryClass and (substring (tolower obj.name) 1 3)== "lod") do (
				progressbcount += 1
				progressbUpdate progressbcount		
				foundFlag = false
				for i in arr_notCorctLodlist where (i == (tolower obj.name)) do (
					foundFlag = true 
					exit
				)
				if foundFlag == false and obj.name.count < 25 then (
					--lodNm = "lod" + (tolower obj.name)
					for i in selection where ((substring (tolower i.name) 1 3)!= "lod") do (
						if ("lod" + (tolower i.name) == (tolower obj.name)) then (
							foundFlag = true
							if ((obj.position == i.position) or (obj.position as string) == (i.position as string)) then (
								foundFlag = true							
							)
							exit
						)
					)
					if foundFlag == false then (
						foundFlag = false
						for i2 in arr_lodwMod where (i2 == obj.name) do (
							foundFlag = true
							exit
						)
						if foundFlag == false then (
							append arr_lodwMod obj.name 
							append objForHide obj 
						)
					)
				)
			)	
			
			if arr_lngName.count > 0 then (
				format "[ERROR #1] - EMAPTool: Found (%)MODELs with LONG NAMEs\nMaximum characters = 24\n(\n" arr_lngName.count
				for i in arr_lngName do format "\t%\n" i
				format ")\n\n"
			)
			if arr_lodwMod.count > 0 then (
				format "[ERROR #2] - EMAPTool: Found (%)LODs without MODELs\n(\n" arr_lodwMod.count
				for i in arr_lodwMod do format "\t%\n" i
				format ")\n\n\n"
			)
			if arr_modwLod.count > 0 then (
				format "[WARNING #3] - EMAPTool: Found (%)MODELs without LODs\n(\n" arr_modwLod.count
				for i in arr_modwLod do format "\t%\n" i
				format ")\n\n\n"
			)
			if arr_notCorctModlist.count > 0 then ( 
				format "[WARNING #4] - EMAPTool: Found (%)MODELs with not correct LODs name\n----------------------------------------------------------\n(!) INCORRECT the name LODs:  modelname - LODelname\n(!) CORRECT the name LODs:  modelname - LODmodelname\n\n(\n" arr_notCorctModlist.count
				for i = 1 to arr_notCorctModlist.count do format "\t% | %\n" arr_notCorctModlist[i] arr_notCorctLodlist[i]
				format ")\n\n\n"
			)			
			for i in selection where (superclassof i == GeometryClass) do stat_gmclass += 1
			format "\nTotal selected MODELs = %\nTotal geometric objects = %\nTotal Warnings = %\nTotal MODELs with ERRORs = %\nTotal copies = %\n------------------------------\nTotal can be exported in IPL = % models\n\n" selection.count  stat_gmclass (arr_notCorctModlist.count +arr_modwLod.count) (arr_lodwMod.count + arr_lngName.count) stat_cops (stat_gmclass - (arr_lodwMod.count + arr_lngName.count))
			listenerOpenState 1
			fnErrStat (arr_lodwMod.count + arr_lngName.count)
			progressbUpdate -1
			enableSceneRedraw()
			tEnd = timeStamp()
			pbsec.text = (((tEnd - tStart) / 1000.0)as string)
			if objForHide.count > 0 then Utilites_rol.hideErrObj.enabled = true else Utilites_rol.hideErrObj.enabled = false
		) else (
			messagebox "Select the objects !"
		)
	) -- shStat pressed
	-----------------------------------------------------------------
	-----------------------------------------------------------------
	-----------------------------------------------------------------
) -- rollout

-----------------------------------------------------------------------------------------------------
try (closeRolloutFloater fl_IMAPT) catch () 
fl_IMAPT = newRolloutFloater "EMT 1.3b" 220 528 50 94
addRollout  Utilites_rol fl_IMAPT rolledUp:true 
addRollout  rl_IMAPT fl_IMAPT 
addRollout  About_rol fl_IMAPT rolledUp:true
