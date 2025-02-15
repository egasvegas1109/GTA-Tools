global isIplImport = false

global st_tTlDFF
global st_tTlLod
global st_tTlObj
global st_tTlAll
global st_tTllines
global st_tTlerr

global st_grge
global st_enex
global st_pick
global st_cars
global st_auzo
global st_jump
global st_cull
global st_inst

global fakeImport

struct checkImport (
	inst = false,
	grge = false,
	pick = false,
	enex = false,
	cars = false,
	jump = false,
	cull = false
)
global sChImport = checkImport()

fileIn (scriptspath+"\\GTA_Tools\\DFFimp.ms") quiet:true 
fileIn (scriptspath+"\\GTA_Tools\\gtaMapIO_Fn.ms") quiet:true

global emtver
try ( fileIn (scriptspath+"\\GTA_Tools\\emt_startup.ms") quiet:true )
catch messagebox "Please install EMAPTool script to GTA_Tools folder!" title:"EMAPTool open error"

interiors = #(
"Outside (standard)",
"Ocean View Hotel in Washington Beach",
"Tommy Vercetti Estate on Starfish Island",
"Bank in Little Havana",
"Mall in Vice Point",
"Pole Position Club in Washington Beach",
"Lawyers in Washington Beach",
"Robina's Cafe in Little Havana",
"Concert hall of Love Fist in Downtown",
"Record studios of Love Fist in Downtown   ",
"Ammu Nation Rifle Range in Downtown",
"Bar of the bikers in Downtown",
"House of the old woman in Little Haiti",
"Printworks in Little Haiti",
"Stadium hall 1 in Downtown",
"Stadium hall 2 in Downtown",
"Stadium hall 3 in Downtown",
"Malibu Club in Vice Point" )

fn OpenFileDialogIPL_ = (
	theDialog = dotNetObject "System.Windows.Forms.OpenFileDialog" --create a OpenFileDialog
	theDialog.title = "PLEASE Select One Or More Files" --set the title
	theDialog.Multiselect = true --allow multiple files to be selected
	theDialog.Filter = "IPL Files (*.ipl)|*.ipl" --specify the filter
	theDialog.FilterIndex = 1 --set the filter drop-down list to All Files
	result = theDialog.showDialog() --display the dialog, get result into variable
	result.ToString() --when closed, convert the result to string
	result.Equals result.OK --returns TRUE if OK was pressed, FALSE otherwise
	result.Equals result.Cancel --returns TRUE if Cancel was pressed, FALSE otherwise
	theFilenames = theDialog.fileNames --the selected filenames will be returned as an array
	return theFilenames
)

Global dffpath = undefined
Global VDary = #()
Global obj = undefined
if fxID == undefined then Global fxID = 0.99991
Global Dummysize = 0.1

Global IORoll
global Roll2dfx

--IO Main--
--=======--
rollout IORoll "IO Control" (

	
    checkbutton G3ctr "GTA3" width:80 tooltip:"Select Import/Export as GTA3 format" checked:false highlightcolor:(color 0 189 0) align:#center across:3
    checkbutton VCctr "VC" width:80 tooltip:"Select Import/Export as VC format" checked:false highlightcolor:(color 0 189 0) align:#center
    checkbutton SActr "SA" width:80 tooltip:"Select Import/Export as SA format" checked:true highlightcolor:(color 0 189 0) align:#center
	on G3ctr changed state do (
		if state == false then IORoll.G3ctr.checked = true
		else (
			VCctr.checked = false
			SActr.checked = false
		)	
	)

	
	on VCctr changed state do (
		if state == false then IORoll.VCctr.checked = true
		else (
			SActr.checked = false
			G3ctr.checked = false
		)	
	)
	on SActr changed state do (
		if state == false then IORoll.SActr.checked = true
		else (
			VCctr.checked = false
			G3ctr.checked = false
		)	
	)
	button dpbtn "DFF Path" width:60 height:25 tooltip:"Select DFF Path" align:#left offset:[0,10] across:2
	edittext dptxt "" width:200 align:#right text:"" offset:[0,10] height:22
	label lblipl6 "" offset:[0,-10]
	on dpbtn pressed do (
		dffpath = getSavePath caption:"Select DFF Path!"
		if dffpath != undefined then (
			dptxt.text = dffpath
			setINISetting (scriptsPath + "GTA_Tools\settings.ini") "MAPIO" "path" dffpath
			ideData = sideData()
		)
		else dptxt.text = ""
	)--end on dpbtn
	
	group "IMPORT" (
		label lblipl "Texture:" align:#left across:3
		radiobuttons textype ""  labels:#("png", "tga", "cust") columns:3 align:#center offset:[17,0]
		edittext textcust "" width:50 align:#right text:"dds" offset:[0,-3] height:20
		label lblipl23 "MATERIAL AS:" align:#left  across:2
		radiobuttons mattype "" labels:#("GTAmaterial  ", "Standart") columns:2 align:#center offset:[-25,0]
		button impipl "IMPORT IPL" width:260 height:30 offset:[0,5]
		label lblipl2 "Supported:" align:#left  
		label lblipl3 "   MASS IPL import,  BINARY IPL import" align:#left  
		label lblipl4 "Import sections:" align:#left offset:[0,5]
		checkbox ch_inst "inst" align:#left offset:[0,0] across:4 checked:true
		checkbox ch_grge "grge" align:#left offset:[-15,0] 
		checkbox ch_cull "cull" align:#left offset:[-26,0]
		checkbox ch_pick "pick" align:#left offset:[-40,0]
		checkbox ch_enex "enex" align:#left across:4
		checkbox ch_cars "cars" align:#left offset:[-15,0]
		checkbox ch_jump "jump" align:#left offset:[-26,0]
		checkbox chFake "fake import"  align:#right offset:[0,13] tooltip:"Replace models with a plein"
		
		
	)
	
	on textype changed state do (
		setINISetting (scriptsPath + "GTA_Tools\settings.ini") "MAPIO" "textype" (state as string)
	)
	
	on textcust changed state do (
		setINISetting (scriptsPath + "GTA_Tools\settings.ini") "MAPIO" "textcust" state
	)
	
	
	on IORoll open do (
		popPrompt()
		IORoll.lblemtv.text = emtver
		chFile = openFile (scriptsPath + "GTA_Tools\settings.ini")
		--clearListener()
		try (
			if chFile != undefined then (
				res = getINISetting (scriptsPath + "GTA_Tools\settings.ini") "MAPIO" "path"
				if res != undefined then dptxt.text = res
				res = getINISetting (scriptsPath + "GTA_Tools\settings.ini") "MAPIO" "textcust"
				if res != undefined and res != "" then textcust.text = res
				res = getINISetting (scriptsPath + "GTA_Tools\settings.ini") "MAPIO" "textype"
				if res != undefined then textype.state = res as integer
				else setINISetting (scriptsPath + "GTA_Tools\settings.ini") "MAPIO" "textype" "dds"
				
			)
		) catch (format "error mapio autoSet(open)\n")
		close chFile
		if ideData != undefined then (
			if ideData.sid.count < 1 then ideData = sideData()
		) else ideData = sideData()
	)
	
	on impipl pressed do (
		if textcust.text != "" then (
			if dptxt.text == "" then (
				messagebox "Select the DFF Path!\n" 
				dffpath = getSavePath caption:"Select DFF Path!"
				if dffpath != undefined then (
					dptxt.text = dffpath
					setINISetting (scriptsPath + "GTA_Tools\settings.ini") "MAPIO" "path" dffpath
				)
				else dptxt.text = ""
			)
			if dptxt.text != "" then (
				dffpath = dptxt.text
				iplname = #()
				iplname = OpenFileDialogIPL_()
				if (iplname != undefined and iplname.count != 0) then (
				
					st_tTlDFF = 0
					st_tTlLod = 0
					st_tTlObj = 0
					st_tTllines = 0
					st_tTlAll = 0
					st_tTlerr = 0   
					st_inst = 0
					st_enex = 0
					st_grge = 0
					st_pick = 0
					st_cars = 0
					st_auzo = 0
					st_jump = 0
					st_cull = 0			
					popPrompt()
					pushPrompt ("MAP IO: Read file preparation...")
					iplCount = getIDcountFromIpl iplname 
					--1-10 -100
					clearlistener()
					format "[map io debug] ipl lines count = %\n" iplCount
					pbideCount = 0.0
					pbideMax = iplCount as float
					--iplname.count
					bincheck = 0
					popPrompt()
					pushPrompt ("MAP IO: Check bin ipl...")
					if ideData.sid.count < 1 then (
						for i = 1 to iplname.count do (
							try ( 
								if (isBinIPL iplname[i]) == true then (
									bincheck = BinIplPrepare()
									exit
								)
							) catch()
						)
					)
					if bincheck != undefined then (
						popPrompt()
						pushPrompt ("MAPIO: Map reading...")
						format "\n -> MAPIO: Map reading...\n"
						progressUpdate 1
						disableSceneRedraw()
						enableUndo false
						
						sChImport.inst = ch_inst.checked
						sChImport.grge = ch_grge.checked
						sChImport.pick = ch_pick.checked
						sChImport.enex = ch_enex.checked
						sChImport.cars = ch_cars.checked
						sChImport.jump = ch_jump.checked
						sChImport.cull = ch_cull.checked
						
						for i = 1 to iplname.count do (
							if IORoll.G3ctr.checked == true then verNo = 1
							if IORoll.VCctr.checked == true then verNo = 2	
							if IORoll.SActr.checked == true then verNo = 3	
							isIplImport = true
							cntLDffNow = 0
							cntLDffMax = 0

							format "\nRead % :\n--------------------------------------------\n" iplname[i]
							progressUpdate 1
							fakeImport = chFake.checked 
							ReadIPL iplname[i] dffpath verNo textype.state mattype.state
							isIplImport = false
							format "\nReading done! %\n\n" iplname[i]
						)
						-- Summary info
						format "\n=============================================\n\n"
						format "[Summary info] (INST)\n\n"
						if st_tTlDFF > 0 then format " Total found DFF and Loaded: %\n" st_tTlDFF
						else format " Total found DFF and Loaded: (Already exist)\n"
						format " Total LODs: -------------- %\n" st_tTlLod
						format " Total Objects: ----------- %\n" st_tTlObj
						format " Total read IPL lines: ---- %\n" st_tTllines
						format " Total models loaded: ----- %\n" st_tTlAll
						format " Total models not loaded: - %\n" st_tTlerr   
						
						format "\nAdditionally:\n"
						format " INST: -- %\n" st_inst
						format " ENEX: -- %\n" st_enex
						format " GRGE: -- %\n" st_grge
						format " PICK: -- %\n" st_pick
						format " CARS: -- %\n" st_cars
						--format " AUZO: -- %\n" st_auzo
						format " JUMP: -- %\n" st_jump
						format " CULL: -- %\n" st_cull
						
						
						---------------
						max tool zoomextents
						gc()
						progressEnd()
						resumeediting()
						enableSceneRedraw()
						redrawViews()
						enableUndo true
						max select none
						
						msgText = "INST info:\n\nTotal LODs: " + (st_tTlLod as string) + "\nTotal Objects: " + (st_tTlObj as string) + "\nTotal read IPL lines: " + (st_tTllines as string) + "\nTotal models loaded: " + (st_tTlAll as string) + "\nTotal models not loaded: " + (st_tTlerr as string) 
						tmptext = ""
						if st_inst > 0 then tmptext += "INST,"
						if st_enex > 0 then tmptext += "ENEX,"
						if st_grge > 0 then tmptext += "GRGE,"
						if st_pick > 0 then tmptext += "PICK,"
						if st_cars > 0 then tmptext += "CARS,"
						if st_jump > 0 then tmptext += "JUMP,"
						if st_cull > 0 then tmptext += "CULL"
						
						msgText += "\n\nReaded sections:\n" + tmptext
						messagebox msgText title:"MAP IO import info:"
					)
				)
			) else ( messagebox "Select the DFF Path first!\n" title:"Not ready to import" )
			popPrompt()
			pushPrompt ("MAPIO: Map loading completed!")
		) else ( messagebox "Custom texture extension is empty!\n"  title:"Import: texture error" )
	)--end on impipl


	group "EXPORT" (
		button btnOpnEmap "Open EMAPTool [GF]" width:260 height:30 
		label lblemtv ""
	)
	
	
	on btnOpnEmap pressed do ( 
		try runEmt()
		catch messagebox "Please install EMAPTool script to GTA_Tools folder!" title:"EMAPTool open error"
	)

	
)--end rollout IORoll

--obj Properities--
--===============--
rollout Mapkamexp "kam ipl/ide export (old)" (
		button expipl "export ipl" width:100 across:2 
		button expide "export ide" width:100 
		button ideIn "import ide" width:100 
	on ideIn pressed do (
		idename = getOpenFileName caption:"Open GTA IDE File" types:"IDE File (*.ide)|*.ide|"
			if (idename != undefined) then (
				if IORoll.G3ctr.checked == true then verNo = 1
				if IORoll.VCctr.checked == true then verNo = 2	
				if IORoll.SActr.checked == true then verNo = 3
				clearlistener()		
				ReadIDE idename VerNo Roll2dfx.fximp.checked Roll2dfx.fxsize.value
				format "\nAll Done!!\n\n"
				max tool zoomextents
			)
	)--end on impipl
	
	on expipl pressed do (
		if $selection.count > 0 then (
			if IORoll.G3ctr.checked == true then verNo = 1
			if IORoll.VCctr.checked == true then verNo = 2	
			if IORoll.SActr.checked == true then verNo = 3

			format "<!--"
			format "\n"

			f = "" as StringStream
			format "#IPL file generated from Kam's GTA Map IO\ninst\n"		to:f
 			f = WriteInst f $selection verNo
			if f != undefined then (
				format "end\ncull\n"								to:f
				WriteCull f $selection verNo
				if verNo != 1 then format "end\npath\nend\n"		to:f
				
				if verNo == 3 then (
					format "grge\n"									to:f
					WriteGrge f $selection
					format "end\nenex\n"							to:f
					WriteEnex f $selection
					format "end\npick\n"							to:f
					WritePick f $selection
					format "end\ncars\n"							to:f
					WriteCars f $selection
					format "end\n"									to:f
				)else format "pick\nend\n"							to:f
				if verNo == 3 then (
					format "jump\n"									to:f
					WriteJump f $selection
					format "end\ntcyc\nend\n"						to:f
					format "auzo\n"									to:f
					WriteAuzo f $selection
					format "end\nmult\nend\n"						to:f
				)
				clearListener()
				format "%\n" ( f as string )		
				format "#"
			)
		)
	)--end on expipl

	on expide pressed do (
		if $selection.count > 0 then (
			if IORoll.G3ctr.checked == true then verNo = 1
			if IORoll.VCctr.checked == true then verNo = 2	
			if IORoll.SActr.checked == true then verNo = 3
			
			format "<!--"
			format "\n"
			f = "" as StringStream
			format "#IDE file generated from Kam's GTA Map IO\n"		to:f
 			f = WriteIDE f $selection verNo
			if f != undefined then (
				clearListener()
				format "%\n" ( f as string )		
				format "#"
			)
		)
	)--end on expide



)

rollout MapRoll "Objects Properities" (
		label lbl1 "Object :  " 	align:#left across:2
		spinner intID "Interior:#" fieldwidth:30 type:#integer align:#right
		
		button getProp "Get" width:123 align:#left across:2
		button setProp "Set" width:123 align:#right --offset:[-8,0]

		spinner idsp "ID : " fieldwidth:45 type:#integer range:[0,99999,5000] align:#left across:3
		button seltxd "Txd" width:35 height:17 align:#left tooltip:"Texture of the object" offset:[7,0]
		edittext txdtext "" fieldwidth:120 align:#right
		button seltxdp "Txdp" width:35 height:17 align:#left tooltip:"Texture Parent for txd" across:4
		edittext txdpant "" fieldwidth:85 align:#right
		button mapanim "Anim" width:35 height:17 align:#left tooltip:"ifp for Animated Objects" offset:[2,0] --across:2
		edittext lblanim "" fieldwidth:85 align:#right offset:[2,0]
    
		spinner farview "View Distance : " fieldwidth:45 range:[0,3000,300]
		label hassub "" align:#left across:2 align:#right type:#integer
		button setsubVD "Set sub-obj View Distance" width:246 enabled:false

		group "Render Effect" (
			checkbox eff1 "Wet Surface (Rain)" across:2	--1
			checkbox eff2 "tobj Night Flag" 		--2
			checkbox eff3 "No Cull behind Alpha" across:2		--4
			checkbox eff4 "!No Cull behind Alpha" across:3			--8
			checkbox eff5 "tobj Day Flag" 	across:2		--16
			checkbox eff6 "** Is Interior"		--32
			checkbox eff7 "Disable Shadow Cull" across:2	--64
			checkbox eff8 "No Surface from Cull"			--128
			checkbox eff9 "Disable DrawDistance" across:2			--256
			checkbox effA "**Breakable with Crack" --across:2			--512
			checkbox effB "**Breakable" --offset:[-41,0]			--1024
			Label FlagInfo1 "   ! disables texture to black when placed in exterior" align:#left
			Label FlagINfo2	"  ** object must be defined in object.dat" align:#left
		)		
	group "Time Object" (
		checkbox usetime "" align:#left across:3
		spinner timeOn "Time On : " type:#integer range:[0,24,0] fieldwidth:45 align:#left offset:[-55,0] enabled:false
		spinner timeOff "Time Off : " type:#integer range:[0,24,0] fieldwidth:45 align:#right enabled: false
	)

	on seltxd pressed do (
		stxd = getOpenFileName caption:"Select Texture TXD File" types:"TXD File (*.txd)|*.txd|"
		if (stxd != undefined) then txdtext.text = filenamefrompath stxd
		else txdtext.text = ""
	)		
	on seltxdp pressed do (
		stxp = getOpenFileName caption:"Select Texture Parent TXD File" types:"TXD File (*.txd)|*.txd|"
		if (stxp != undefined) then txdpant.text = filenamefrompath stxp
		else txdpant.text = ""
	)
	on mapanim pressed do (
		mifp = getOpenFileName caption:"Select Map Animation IFP File" types:"IFP File (*.ifp)|*.ifp|"
		if (mifp != undefined) then lblanim.text = filenamefrompath mifp
		else lblanim.text = ""
	)
	

	group "VC Interiors" (    
		--label lbl2 "VC : " align:#left offset:[0,3] across:2
		dropdownlist intlist "" width:250 items:interiors align:#right offset:[2,0]
	)

	on setsubVD pressed do (
		SB = totalsubobj obj 
		createVDary obj SB
	)
	on usetime changed state do ( 
		if state == true then (
			timeOn.enabled = true
			timeOff.enabled = true
		) else (
			timeOn.enabled = false
			timeOff.enabled = false		
		)
	)--end on usetime 
	on intID changed val do (
		if val < 18 then intlist.selection = val + 1
				 else intlist.selection = 1
	)
	on intlist selected sel do (
		intID.value = intlist.selection - 1	
	)

	
	on setProp pressed do (
		if $selection.count != 1 then messagebox "Select a single object only!" Title:"Please select again"
		else (
			obj = $
			while obj.parent != undefined do obj = obj.parent
			select obj
			lbl1.text = obj.name
		----------------------------------
		--Set up Buffer for all same obj--
		----------------------------------
			upb = ""

			upb += "ID=" + idsp.value as string + "\n"
			if txdtext.text.count > 0 then (
				ttt = findstring txdtext.text ".txd"
				if ttt != undefined then txdtext.text = substring txdtext.text 1 (txdtext.text.count-4)
				upb += "TXD=" + txdtext.text + "\n"
			)
			if txdpant.text.count > 0 then (
				ttt = findstring txdpant.text ".txd"
				if ttt != undefined then txdpant.text = substring txdpant.text 1 (txdpant.text.count-4)
				upb += "TXDP=" + txdpant.text + "\n"
			)
			if lblanim.text.count > 0 then (
				ttt = findstring lblanim.text ".ifp"
				if ttt != undefined then lblanim.text = substring lblanim.text 1 (lblanim.text.count-4)
				upb += "Anim=" + lblanim.text + "\n"
			)
			SB = totalsubobj obj
			upb += "SubObj=" + SB as string + "\n"
			if SB == 1 then upb += "View=" + farview.value as string + "\n"
			else (
				if VDary.count > 0 then (
					for i = 1 to SB do 
						upb += "View" + i as string + "=" + VDary[i] as string + "\n"
				) else 
					for i = 1 to SB do upb += "View" + i as string + "=300\n"				
			)--end if/else SB

			rendeff = 0
			if eff1.checked == true then rendeff += 1
			if eff2.checked == true then rendeff += 2
			if eff3.checked == true then rendeff += 4
			if eff4.checked == true then rendeff += 8
			if eff5.checked == true then rendeff += 16
			if eff6.checked == true then rendeff += 32
			if eff7.checked == true then rendeff += 64
			if eff8.checked == true then rendeff += 128
			if eff9.checked == true then rendeff += 256
			if effA.checked == true then rendeff += 512
			if effB.checked == true then rendeff += 1025
			upb += "RenderEffect=" + rendeff as string + "\n"
			
			if usetime.checked == true then (
				upb += "TimeOn=" + timeOn.value as string + "\n"
				upb += "TimeOff=" + timeOff.value as string + "\n"
			) 

			upb += "Interior=" + intID.value as string + "\n"
			
		----------------------------------		
			intAry = for o in geometry where o.name == lbl1.text collect o
			for o in intAry do setUserPropBuffer o upb
		)--end if/else
	)--end on setProp

	on getProp pressed do (
		if $selection.count != 1 then messagebox "Select a single object only!" Title:"Please select again"
		else (
			obj = $
			while obj.parent != undefined do obj = obj.parent
			ID = getUserProp obj "ID"
			if ID == undefined then (
				messagebox "No ID in this object" title:"Warning"
				idsp.value = 9999
			) else 			idsp.value = ID

			txd = getUserProp obj "TXD"
			if txd != undefined then txdtext.text = txd
			else txdtext.text = ""
			txdp = getUserProp obj "TXDP"
			if txdp != undefined then txdpant.text = txdp
			else txdpant.text = ""

			SB = totalsubobj obj
			if SB > 1 then (
				farview.enabled = false
				setsubVD.enabled = true
				hassub.text = "*Sub-Obj: " + SB as string

				notset = false
				txt = ""
				for j = 1 to SB do (
					txt += "tmp = getUserProp obj \"View" + j as string + "\"\n"
				    txt += "if tmp == undefined then notset = true\n" 
					txt += "else VDary[" + j as string + "] = tmp\n" 
				)
				execute txt
				if notset == true then VDary = #()

			) else (
				VDary = #()
				farview.enabled = true
				setsubVD.enabled = false
				hassub.text = ""
				try (farview.value = getUserProp obj "View") catch (farview.value = 300)
			)	
				
			rendeff = getUserProp obj "RenderEffect"
			if rendeff != undefined then (
				if rendeff >= 1024 then (rendeff -= 1024; effB.checked = true ) else effB.checked = false 
				if rendeff >= 512 then ( rendeff -= 512; effA.checked = true ) else effA.checked = false 
				if rendeff >= 256 then ( rendeff -= 256; eff9.checked = true ) else eff9.checked = false 
				if rendeff >= 128 then ( rendeff -= 128; eff8.checked = true ) else eff8.checked = false 
				if rendeff >= 64 then (  rendeff -= 64;  eff7.checked = true ) else eff7.checked = false 
				if rendeff >= 32 then (  rendeff -= 32;  eff6.checked = true ) else eff6.checked = false 
				if rendeff >= 16 then (  rendeff -= 16;  eff5.checked = true ) else eff5.checked = false 
				if rendeff >= 8 then (   rendeff -= 8;   eff4.checked = true ) else eff4.checked = false 
				if rendeff >= 4 then (   rendeff -= 4;   eff3.checked = true ) else eff3.checked = false 
				if rendeff >= 2 then (   rendeff -= 2;   eff2.checked = true ) else eff2.checked = false 
				if rendeff >= 1 then ( eff1.checked = true ) else eff1.checked = false 
			) else (
				eff1.checked = false; eff2.checked = false
				eff3.checked = false; eff4.checked = false
				eff5.checked = false; eff6.checked = false
				eff7.checked = false; eff8.checked = false
				eff9.checked = false; effA.checked = false
				effB.checked = false
			)--end if rendeff
				
			ton = getUserProp obj "TimeOn"
			toff = getUserProp obj "TimeOff"
			if (ton != undefined) AND (toff != undefined) then (
				usetime.checked = true
				timeOn.enabled = true;  timeOn.value = ton
				timeOff.enabled = true; timeOff.value = toff				
			) else (
				usetime.checked = false
				timeOn.enabled = false
				timeOff.enabled = false
			)
			mifp = getUserProp obj "Anim"
			if mifp != undefined then lblanim.text = mifp
			else lblanim.text = ""

			Intr = getUserProp obj "Interior"
			if Intr != undefined then (
				 intID.value = intr
				 if intr < 18 then intlist.selection = intr + 1
				 else intlist.selection = 1
			) else (
				intID.value = 0
				intlist.selection = 1
			)
			
			select obj
			lbl1.text = "Object :  " + obj.name
		)
	)--end on getProp	
)--end rollout MapRoll


--ZONE--
--====--
rollout ZONRoll "ZON" (
	label lblz "Zone : " 	align:#left
	button zonIn "IMPORT ZON" width:123 height:30 across:2 align:#left
	button expzon "EXPORT ZON" width:123 height:30  align:#right
	
	button getzone "Get" width:123 align:#left across:2 offset:[0,5] 
	button setzone "Set" width:123 align:#right offset:[0,5] 
	radiobuttons ztype "" labels:#("Normal","Navig","Info","Map") columns:4 --align:#right
	group "Island : (GTA3)" (
		radiobuttons island "" labels:#("Portland","Staunton","Shoreside") columns:3 --align:#right
	)	
	on expzon pressed do (
		if $selection.count > 0 then (
			if IORoll.G3ctr.checked == true then verNo = 1
			if IORoll.VCctr.checked == true then verNo = 2	
			if IORoll.SActr.checked == true then verNo = 3

			format "<!--"
			format "\n"	
			f = "" as StringStream
			format "#ZON file generated from Kam's GTA Map IO\n" to:f
			f = WriteZon f $selection verNo
			clearListener()
			format "%\n" ( f as string )		
			format "#"			
		)--end if
	)--end on expzon
	on zonIn pressed do (
		ZONname = getOpenFileName caption:"Open GTA ZON File" types:"ZON File (*.zon)|*.zon|"
			if (ZONname != undefined) then (
				ReadZon ZONname 
			)	
	)--end zonIn
	on getzone pressed do (
		if $selection.count != 1 then messagebox "Select a single object only!" Title:"Please select again"
		else (
			if (classof $ == Box)AND(getUserProp $ "Zone" == true) then (
				type = getUserProp $ "Type"
				IID = getUserProp $ "IslandID"
				if type != undefined then ztype.state = type + 1
				if IID != undefined then island.state = IID
				lblz.text = "Zone : " + $.name
			) else (
				messageBox "Not a ZONE, or\nNo ZONE data in this object." title:"ZONE Warning"
				lblz.text = "Zone : "
			)
		)--end if/else selection
	)--end on getzone

	on setzone pressed do (
		if $selection.count != 1 then messagebox "Select a single object only!" Title:"Please select again"
		else (
			if (classof $ == Box) then (
				lblz.text = "Zone : " + $.name
				setUserProp $ "Zone" true
				setUserProp $ "Type" (ztype.state - 1)
				setUserProp $ "IslandID" island.state
				$.wirecolor = color 255 255 0
				lblz.text = "Zone : " + $.name
			) else messageBox "Use Box primitive as ZONE" title:"ZONE Warning"
		)--end if/else
	)--end on setzone

	
)--end rollout ZONRoll


--2dfx--
--====--
Rollout Roll2dfx "2dfx IDE" (
	label fxname "" align:#left across:2
	spinner Unkn "Unknown:" fieldwidth:45 range:[0,99999,200] type:#integer align:#right
	group "IMPORT" (
	button ideIn "Read 2dfx from IDE" width:130 height:30 across:3 align:#left
	checkbutton fximp "2dfx" width:45 highlightcolor:yellow tooltip:"Read 2dfx when import .ide   (SLOW!!!)"  align:#right  offset:[26,0] 
	spinner fxsize "" fieldwidth:45 range:[0,10000,1] align:#right offset:[0,3] 
	)
	
	group "Lights" (
		spinner spVD "ViewDistance:" fieldwidth:45 range:[0,9999,300] type:#integer align:#right across:2
		spinner spLS "Lamp Size:" fieldwidth:45 range:[0,9999,1] type:#integer align:#right 
		spinner spOutR "Outter Radius:" range:[0,999,10] type:#integer fieldwidth:45 align:#right across:2
		spinner spInR  "Inner Radius:"  range:[0,999,5] type:#integer fieldwidth:45 align:#right
		spinner spCS  "Corona Size:"  range:[0,999,40] type:#integer fieldwidth:45 align:#right across:2
		spinner spRf  "Reflection:"  range:[0,999,0] type:#integer fieldwidth:45 align:#right
		spinner spLF  "Lens Flare:"  range:[0,999,0] type:#integer fieldwidth:45 align:#right across:2
		spinner spDust  "Dust:"  range:[0,999,0] type:#integer fieldwidth:45 align:#right
		colorpicker lgtcolor "" align:#left across:2
		dropdownlist dlcontrol width:200 items:#("light day/night", "light night", \
"flicker day/night", "flicker night", "blink 1 sec, day/night", "blink 1 sec, night", \
"blink 2 sec, day/night", "blink 2 sec, night", "light day", "blink 3 sec, night", \
"blink 3 sec, day/night", "random flicker at night (streetlamps)", "unknown") align:#right
	)
	group "Particles" (
		colorpicker parcolor "" align:#left across:3
		dropdownlist dlpar width:118 items:#("white steam medium", "white steam small", "white steam big", "Fire", "black smoke", "water spray up", "water fall down") align:#right
		spinner spPsize  "Size:"  range:[0,9999,0] fieldwidth:45 align:#right offset:[0,3]
		spinner spukn1  "Unknown:"  range:[-999,999,0] fieldwidth:45 align:#Left across:3
		spinner spukn2  "-"  range:[-999,999,0] fieldwidth:45 align:#right offset:[12,0]
		spinner spukn3  "-"  range:[-999,999,0] fieldwidth:45 align:#right --across:2
	)
	group "Ped Area" (
		colorpicker pedcolor "" align:#left across:2
        dropdownlist pedanim "" width:200 items:#("Automat (handle with object)","Seatplace","Busstop","Display Window","Unknown") align:#right
		spinner spdir1x  "Direction 1:"  range:[-999,999,0] fieldwidth:45 align:#Left across:3
		spinner spdir1y  "-"  range:[-999,999,0] fieldwidth:45 align:#right offset:[12,0]
		spinner spdir1z  "-"  range:[-999,999,0] fieldwidth:45 align:#right --across:2
		spinner spdir2x  "Direction 2:"  range:[-999,999,0] fieldwidth:45 align:#Left across:3
		spinner spdir2y  "-"  range:[-999,999,0] fieldwidth:45 align:#right offset:[12,0]
		spinner spdir2z  "-"  range:[-999,999,0] fieldwidth:45 align:#right --across:2
	)
	group "Sun Flares" (
		colorpicker sfcolor "" align:#left 
	)
	button getfx "Get" width:122 align:#left across:2
	button updatefx "Update" width:123 align:#right

	on ideIn pressed do (
		idename = getOpenFileName caption:"Open GTA IDE File" types:"IDE File (*.ide)|*.ide|"
			if (idename != undefined) then (
				if IORoll.G3ctr.checked == true then verNo = 1
				if IORoll.VCctr.checked == true then verNo = 2	
				if IORoll.SActr.checked == true then verNo = 3
				clearlistener()		
				ReadIDE_2dfx idename VerNo fximp.checked fxsize.value
				format "\nAll Done!!\n\n"
				max tool zoomextents
			)
	)--end on impipl
	
	on updatefx pressed do (
		if superclassof obj == shape then (
			--check if new 2dfx--
			if (subString obj.name 1 5) != "2dfx_" then (
				createfx obj fxID
				fxID -= 0.0001
			)
			update2dfx obj Roll2dfx
		)
	)--end on updatefx 
	
	on getfx pressed do (
		if $selection.count > 1 then messagebox "Select a single shape only!" Title:"Please select again"	
		else
		if superclassof $ != shape then messagebox "Not a 2dfx!" Title:"Selection Error"
		else
		if ($.parent == undefined) then messagebox "Link the 2dfx to a mesh(ID ready) first!" Title:"ID Problem"
		else (	
			obj = $.parent
			while obj.parent != undefined do obj = obj.parent
			if getUserProp obj "ID" == undefined then (
				txt = "No ID in " + obj.name + "\nPlease Set it in Object Properties first!"
				messagebox txt title:"ID Problem"
			) else (
				ss = select2dfx $ Roll2dfx
				if ss == undefined then messagebox "Unknown 2dfx!!" title:"Selection Error"
				else 
				if ss == false then fxname.text = "**" + $.name
				else (
					fxname.text = $.name
					Unkn.value = getUserProp $ "unkn1"
				)
				obj = $
			)
		)
	)--end on getfx

)--end Rollout Roll2dfx



--About--
--=====--
rollout aboutRoll "About" (
	label l1 "MAP IO v0.5.2"
	label l2 "(KAMs scripts 0.3.7)"
	label l3 "Support:" align:#left
	label l4 "   - IPL Import/export" align:#left
	label l4a "         . insts, cull (all Version)" align:#left
	label l4b "         . grge, enex, pick, jump, cars, auzo (SA only)" align:#left
	label l5 "   - ZON Import/export(GTA3/VC)" align:#left	
	label l6 "   - IDE Import/export" align:#left
	label l6a "         . objs, tobj (all Version)" align:#left
	label l6b "         . 2dfx (GTA3/VC/SA)" align:#left
	label l6c "         . anim, txdp (SA only)" align:#left
	label lA ""	
	label lB "(c) Kam & Goldfish 2020" 
	label lC "kam.lai@ntlworld.com"
) 

rollout mapobjRoll "Map Objects Creation" (
	button creGrge "Grge" width:45 across:5
	button crePick "Pick" width:45 
	button creCars "Cars" width:45 
	button creEnex "Enex" width:45 
	button creAuzo "Auzo" width:45
	button creJump "Jump" width:45 across:5
	button creCull "Cull" width:45
	button dmy1 "" width:45 enabled:false
	button dmy2 "" width:45 enabled:false
	button dmy3 "" width:45 enabled:false
	on creGrge pressed do (
		nob = GTAgrge()
		select nob
	)
	on crePick pressed do (
		nob = GTApick()
		select nob
	)
	on creCars pressed do (
		nob = GTAcars()
		select nob
	)
	on creEnex pressed do (
		nob = NewEnex 1 1 [0,0,0] [0,2,0]
		select nob
	)
	on creAuzo pressed do (
		nob = GTAauzo()
		select nob
	)
	on creCull pressed do (
		nob = GTAcull xray:on
		select nob
	)
    on creJump pressed do (
		jmp = GTAland showlinks:true		
		jst = GTAjump pos:[1,-1,0] showlinks:true
		jst.parent = jmp
		jst.name = jmp.name + ".start"
		jcm = GTAjcam pos:[-1,-1,1] target:jmp 
		jcm.name = jmp.name + ".camera"
		jd = dummy boxsize:[1,1,1]
		jd.name = jmp.name + ".dummy"
		jcm.parent = jd
		jmp.parent = jd
		select jd
	)
)

rollout disproll "Display Helper" (
	button mapshow "Show Texture" width:120 tooltip:"Display texture on selected objects" align:#center across:2
	button maphide "Hide Texture" width:120 tooltip:"Hide texture on selected objects" align:#center

	on mapshow pressed do (
		if $selection.count > 0 then (
			freeSceneBitmaps()
			objary = $selection
			for obj in objary where obj.material != undefined do (
				if classof obj.material == Multimaterial then (
					for i = 1 to obj.material.count do (
						try (
							showTextureMap obj.material[i] obj.material[i].colormap on
						) catch (
							try (showTextureMap obj.material[i] obj.material[i].diffusemap on ) catch ()
						)
					)
				) else (
					try (
						showTextureMap obj.material obj.material.colormap on
					) catch (
						try (showTextureMap obj.material obj.material.diffusemap on ) catch ()
					)
				)
			)--end for obj	
		)--end if
	)--end on mapshow
	
		on maphide pressed do (
		if $selection.count > 0 then (
			objary = $selection
			for obj in objary where obj.material != undefined do (
				if classof obj.material == Multimaterial then (
					for i = 1 to obj.material.count do (
						try (
							showTextureMap obj.material[i] obj.material[i].colormap off
						) catch (
							try (showTextureMap obj.material[i] obj.material[i].diffusemap off ) catch ()
						)
					)
				) else (
					try (
						showTextureMap obj.material obj.material.colormap off
					) catch (
						try (showTextureMap obj.material obj.material.diffusemap off ) catch ()
					)
				)
			)--end for obj	
		)--end if
	)--end on mapshow
	
)

if Kam_GTAMAP != undefined then (closeRolloutFloater Kam_GTAMAP; gc() )
Kam_GTAMAP = newRolloutFloater "MAP IO v0.5.2 [0.3.7]" 300 427 10 120		
addRollout IORoll Kam_GTAMAP	--rolledup:true
addRollout mapobjRoll Kam_GTAMAP 	rolledup:true
addRollout MapRoll Kam_GTAMAP 	rolledup:true
addRollout Roll2dfx Kam_GTAMAP  rolledup:true
addRollout ZONRoll Kam_GTAMAP 	rolledup:true
addRollout disproll Kam_GTAMAP 	rolledup:true
addRollout Mapkamexp Kam_GTAMAP rolledup:true
addRollout aboutRoll Kam_GTAMAP	