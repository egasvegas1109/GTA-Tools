/*
 - Bitmaps manager 1.2 -
 
Last update: 12.11.2019

for 3ds max 2009 and higher

-------------------------------
 
Script features:
	- print information about bitmaps of selected models
	- copy bitmaps to the selected folder
	- search incorrect bitmaps

Author: Goldfish 
(Specially for the CRime team)

Support: 
Goldfish-1994@yandex.ru 
https://vk.com/vk.goldfish

		
Change the code on your own risk !!!
*/

try (DestroyDialog bitmapMgRollout) catch()

rollout bmg_about "BMG 1.1 - About" width:275 height:248
(

	button btn_close "close" pos:[103,219] width:69 height:22
	label lbl1 "Bitmaps manager 1.0" pos:[72,12] width:109 height:17
	label lbl2 "Author:" pos:[10,149] width:42 height:18
	label lbl4 "Specially for the" pos:[10,172] width:81 height:18
	label lbl6 "Script features:" pos:[11,43] width:80 height:18
	label lbl7 "- print information about bitmaps of selected models" pos:[13,64] width:250 height:18
	label lbl9 "- copy bitmaps to the selected folder" pos:[13,83] width:183 height:18
	label lbl10 "- search incorrect bitmaps" pos:[13,102] width:131 height:18
	label lbl11 "_____________________________" pos:[46,120] width:179 height:18
	HyperLink toCRime_team "CRime team" pos:[96,172] width:69 height:18 address:"https://vk.com/crime_offcial" color:(color 10 147 225) hovercolor:(color 94 198 255) visitedcolor:(color 10 147 225)
	HyperLink Goldfish "Goldfish" pos:[51,149] width:50 height:18 address:"https://vk.com/vk.goldfish" color:(color 10 147 225) hovercolor:(color 94 198 255) visitedcolor:(color 10 147 225)
	label lbl12 "12.11.2019" pos:[200,200] width:70 height:18
	
	on btn_close pressed  do(
		DestroyDialog bmg_about
	)		
)

actionMan.executeAction 0 "40472" 
clearListener()
format "\n   Bitmaps manager v1.1 by GoldFish\n===========================================\n"

rollout bitmapMgRollout "Bitmaps manager 1.1" width:383 height:217
(
	groupBox grp1 "Print list bitmaps" pos:[8,10] width:366 height:60 enabled:true
	button btn_print "Print" pos:[22,33] width:337 height:26 enabled:true toolTip:"Print to listener"
	groupBox grp3 "Copy to path" pos:[8,75] width:366 height:107 enabled:true
	button btn_dest "to path" pos:[22,96] width:59 height:23 toolTip:"select path"
	editText edt1 "" pos:[84,97] width:273 height:20
	button btn_stCopy "Copy bitmaps to path !" pos:[22,131] width:337 height:39 enabled:true toolTip:"Start copy bitmaps to path"
	button btn_about "About" pos:[131,191] width:126 height:19	
		
	global mapfiles
	global missMapfiles
	
	fn addmap mapfile = (
		local mapfileN=mapfile as name
		local index=finditem mapfiles mapfileN
		if index == 0 do append mapfiles mapfileN
	)
	fn addmissmap mapfile = (
		local mapfileN=mapfile as name
		local index=finditem missMapfiles mapfileN
		if index == 0 do append missMapfiles mapfileN
	)
	
	fn printBitmaps obj = (
		if (classof obj.material) != Multimaterial then (
			format "1 " 
			sp = " "
			if classof obj.material == GTA_Mtl then (
				if obj.material.colormap != undefined then (
					format "DIF| %\n" (getFilenameFile (obj.material.colormap.filename) + getFilenameType(obj.material.colormap.filename))
				)
				if obj.material.alphamap != undefined then
					format "  alp| %\n" (getFilenameFile (obj.material.alphamap.filename) + getFilenameType(obj.material.alphamap.filename))
				if obj.material.reflectionmap != undefined then
					format "  ref| %\n" (getFilenameFile (obj.material.reflectionmap.filename) + getFilenameType(obj.material.reflectionmap.filename))
				format "---\n"
			) else if classof obj.material == Standardmaterial then (
				if obj.material.diffusemap != undefined then (
					format " DIF| %\n" (getFilenameFile (obj.material.diffusemap.filename) + getFilenameType(obj.material.diffusemap.filename))
				)
				if obj.material.opacitymap != undefined then
					format "  alp| %\n" (getFilenameFile (obj.material.opacitymap.filename) + getFilenameType(obj.material.opacitymap.filename))
				if obj.material.reflectionmap != undefined then
					format "  ref| %\n" (getFilenameFile (obj.material.reflectionmap.filename) + getFilenameType(obj.material.reflectionmap.filename))
				format "---\n"
			)
		) else (
			for i = 1 to obj.material.count do (
				format "% " i
				if obj.material[i] == undefined then (format " undefined\n---\n"; continue)
				if classof obj.material[i] == GTA_Mtl then (
					sp = false
					if obj.material[i].colormap != undefined then (
						if i < 10 then format " " 
						sp = true
						format "DIF| %\n" (getFilenameFile (obj.material[i].colormap.filename) + getFilenameType(obj.material[i].colormap.filename))
					)
					if obj.material[i].alphamap != undefined then (
						if sp == true then format "   " else if i < 10 then format " " 
						sp = true
						format "alp| %\n" (getFilenameFile (obj.material[i].alphamap.filename) + getFilenameType(obj.material[i].alphamap.filename))
					)
					if obj.material[i].reflectionmap != undefined then (
						if sp == true then format "   " else if i < 10 then format " " 
						format "ref| %\n" (getFilenameFile (obj.material[i].reflectionmap.filename) + getFilenameType(obj.material[i].reflectionmap.filename))
					) 
					format "---\n"
				) else if classof obj.material[i] == Standardmaterial then (
					sp = false
					if obj.material[i].diffusemap != undefined then (
						sp = true
						if i < 10 then format " " 
						format "DIF| %\n" (getFilenameFile (obj.material[i].diffusemap.filename) + getFilenameType(obj.material[i].diffusemap.filename))
					)
					if obj.material[i].opacitymap != undefined then (
						if sp == true then format "   " else if i < 10 then format " " 
						sp = true
						format "alp| %\n" (getFilenameFile (obj.material[i].opacitymap.filename) + getFilenameType(obj.material[i].opacitymap.filename))
					)
					if obj.material[i].reflectionmap != undefined then (
						if sp == true then format "   " else if i < 10 then format " " 
						format "ref| %\n" (getFilenameFile (obj.material[i].reflectionmap.filename) + getFilenameType(obj.material[i].reflectionmap.filename))
					) 
					format "---\n"
				)
			)	
		)
	)
	
	on btn_about pressed  do(
		createDialog bmg_about
	)

	on btn_print pressed  do(
		if selection.count > 0 then (
			clearListener()
			format "\n   Bitmaps manager v1.1 by GoldFish\n===========================================\n"
			for obj in selection where (superclassof obj == GeometryClass ) do (
				mapfiles = #()
				missMapfiles = #()
				enumeratefiles obj addmissmap #missing
				format "\n% -------------------\n\n" obj.name
				---v 1.1 -----------------
				printBitmaps obj
				--------------------------
				if missMapfiles.count > 0 then (
					format "MISSING bitmaps:\n"
					for mapfile in missMapfiles do (
						format "- %\n" (getFilenameFile (mapfile as string) + getFilenameType(mapfile as string))
					)
				)
			)		
		) else messagebox "Models not selected!" title: "Error"
	)

	on btn_dest pressed  do(
		if edt1.text != undefined then  Item2 = edt1.text else Item2 = ""
		Item = getSavePath caption:"Copy bitmaps to folder:" initialDir: Item2
		if Item != undefined then edt1.text = (Item as string)
	)
	on btn_stCopy pressed  do (
		
		if selection.count > 0 then (
			if edt1.text != "" then (
				clearListener()
				format "\n   Bitmaps manager v1.1 by GoldFish\n===========================================\n"
				for i in selection do (					
					mapfiles = #()
					missMapfiles = #()
					enumeratefiles i addmap
					enumeratefiles i addmissmap #missing
					format "\nmodel: %\n----------------------------------\n" i.name
					if missMapfiles.count > 0 then (
						
						format "bitmaps NOT FOUND:\n" i.name
						for mname in missMapfiles do format "- %\n" (filenameFromPath mname)
						format "\n"
					)
					
					if mapfiles.count > 0 then ( 
						makeDir ((edt1.text) + "\\" + i.name + "\\" )
						for texture in mapfiles do (	
							if (copyFile texture ((edt1.text) + "\\" + i.name + "\\" + (filenameFromPath texture) )) == false then (							
									format "log: error copying bitmaps to: % (maybe the bitmap already exists)\n" ((edt1.text) + "\\" + i.name + "\\" + (filenameFromPath texture) )							
							)
						)
					) 
					format "- done\n"
				)
				format "\nCopying was completed !\n"
			) else messagebox "Select the folder to copy (to path) !" title: "Error"
		) else messagebox "Models not selected!" title: "Error"
	)
)
createDialog bitmapMgRollout style: #(#style_titlebar, #style_border, #style_sysmenu,#style_minimizebox)