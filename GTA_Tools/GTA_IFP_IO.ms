if DFFinInfo == undefined then fileIn (scriptspath+"\\GTA_Tools\\CharDFFimp.mse") quiet:true
else if DFFinInfo() < 051016 then fileIn (scriptspath+"\\GTA_Tools\\CharDFFimp.mse") quiet:true
if DFFinInfo() < 051016 then messagebox "You didn't have the right import function to run this script!\nTry Install it again!" title:"Import Function Error"

if IFPioInfo == undefined then fileIn (scriptspath+"\\GTA_Tools\\gtaIFPio_Fn.mse") quiet:true 
else if IFPioInfo() != 051014 then fileIn (scriptspath+"\\GTA_Tools\\gtaIFPio_Fn.mse") quiet:true
if IFPioInfo() != 051014 then messagebox "You didn't have the right IFP function to run this script!\nTry Install it again!" title:"SA IFP Function Error"

AnimInfo = #()
ifpname = undefined

rollout saifproll "Animation" (

	local HInfo = undefined

	button loaddff "Import DFF" width:120 --offset:[-1,-3]
	button loadifp "Load IFP" width:120 offset:[-1,-3]
	label lbl1 "Anim. File:" align:#left
	label lbl2 "Total Animation:" align:#left
	label lbl3 "Internal Name:" align:#left
	listbox AnimList height:10
	button RecOrg "M" width:17 align:#left tooltip:"Record Original Pose of selected object" across:3
	button apyAnim "Apply Animation" width:86 align:#center tooltip:"Only Selected objects with SAME Name in the animation will be applied"
	button ResetPose "R" width:17 align:#right tooltip:"Reset Pose to original" --offset:[2,0]
	checkbox skipPos "Skip Pos keys" align:#center
	group "Batch Import Animation"(
		spinner astart "Start" fieldwidth:30 type:#integer range:[0,10000,0] across:2
		spinner aend "End" fieldwidth:30 type:#integer range:[0,10000,0]
		button batAnim "Batch Animation" width:122 align:#center tooltip:"Only Selected objects with SAME Name in the animation will be applied"
	)
	group "Export" (
		checkbutton tyVC "GTA3/VC" width:60 highlightcolor:green align:#right tooltip: "Do not select the Skinned Char" across:2
		checkbutton tySA "SA" width:60 checked:true highlightcolor:green align:#right
		checkbutton useBoneID "Bone ID" height:17 width:120 highlightColor:yellow checked:true enabled:false align:#center offset:[0,-3]
		button ReplaceAnim "Replace" width:120 tooltip:"Replace selected Animation" align:#center --offset:[0,-3] across:2
		button saveAnim "Save As" width:120 tooltip:"Save Animation to new file" align:#center offset:[0,-5]
	)
	--	
	on loaddff pressed do (
		fname = getopenfilename caption:"Read DFF File" types:"dff File (*.dff)|*.dff|"
		if fname != undefined then (
			f = fopen fname "rb"
			if f == undefined then ( Messagebox "Can't open the file!" title:"I/O Error" )
			else (
					DFFin   f   1   2   ".tga"   0.1   true   false   (getFilenameFile fname)
			)--end if/else f
		)
		fclose f
		gc()
	)--end on loaddff
	--	
	on tyVC changed state do (
		if state == false then tyVC.checked = true
		else (
			tySA.checked = false
			useBoneID.enabled = true
		)
	)
	on tySA changed state do (
		if state == false then tySA.checked = true
		else (
			tyVC.checked = false
			useBoneID.enabled = false
		)
	)
	on useBoneID changed state do (
		if useBoneID.checked == true then useBoneID.text = "Bone ID"
		else useBoneID.text = "Sibling"
	)
	--
    on astart changed val do (
        if val < 1 then astart.value = 1
		if HInfo != undefined then (
	        if astart.value > HInfo[1] then astart.value = HInfo[1]
	        if astart.value > aend.value then aend.value = astart.value	
		) else astart.value = 0
    )
    --
    on aend changed val do (
        if val < 1 then aend.value = 1
		if HInfo != undefined then (
	        if aend.value > HInfo[1] then aend.value = HInfo[1]
    	    if aend.value < astart.value then astart.value = aend.value
		) else aend.value = 0
    )
    --
	on ResetPose pressed do (
			sliderTime = 0
			for i = 1 to $selection.count do (
				deletekeys $selection[i].pos.controller
				deletekeys $selection[i].rotation.controller
				deletekeys $selection[i].scale.controller
				try (
					tp 					= readvalue ((getUserProp $selection[i] "OrgRot") as stringstream)
					tpW					= getUserProp $selection[i] "OrgRotW"
					$selection[i].rotation = (quat tp.x tp.y tp.z tpW)
					$selection[i].scale	= readvalue ((getUserProp $selection[i] "Orgscl") as stringstream)
					$selection[i].pos	= readvalue ((getUserProp $selection[i] "OrgPos") as stringstream)
				) catch (RecOrg.text = "M")
			)--end for i	
	)
	--	
	on RecOrg pressed do (
		OrginAry = #()
		for i = 1 to $selection.count do (
			--OrginAry[i] = #($selection[i],$selection[i].transform)
			setUserProp $selection[i] "OrgPos" $selection[i].pos
			setUserProp $selection[i] "OrgRot" [$selection[i].rotation.x,$selection[i].rotation.y,$selection[i].rotation.z]
			setUserProp $selection[i] "OrgRotW" $selection[i].rotation.w
			setUserProp $selection[i] "Orgscl" $selection[i].scale
		)	
		RecOrg.text = "**"
	)
	--
	on saveAnim pressed do (
		if (AnimList.selection != 0)AND($selection.count >0) then (
	
			Sname = getSaveFileName caption:"Save GTA Animation file" types:"IFP animation (*.ifp)|*.ifp"
			if Sname != undefined then (
			
				for obj in $selection where (getUserProp obj "BoneID") == undefined do deselect obj
			
				try (	--undefined*undefined
					f = fopen Sname "wb"

					if tySA.checked == true then (   					--SA  
						writeLong f 0x33504E41		--ANP3
						writeLong f 0
						writeString f "KamMaxScriptExp"
						for i = 1 to 8 do ( writeByte f 0 )
						writeLong f 1

						thisLength = ExpsaIFP f ($selection as array) AnimList.selected
						fseek f 4 #seek_set
						writeLong f (thisLength + 28)
			
					) else (   					   											--VC
                    
						writeLong f 0x4B504E41		--ANPK
						writeLong f 0
						writeLong f 0x4F464E49		--INFO
						writeLong f 20
						writeLong f 1
						writeString f "KamMaxScriptExp"
			
						thisLength = expAnim f ($selection as array) useBoneID.checked AnimList.selected
						fseek f 4 #seek_set
						writeLong f (thisLength + 28)

					)
					format "Size:%\n" (thisLength as integer)
					format "DONE!!\n\n"
					fclose f	
				) catch (
					fclose ff
					fclose f
					-----------------------
					--This is GMax output--
					-----------------------
					Sname = (substring Sname 1 (Sname.count - 4)) + ".txt"
					ss = "" as stringstream

					clearlistener()
					format "<!-- path=\"%\" -->\n" Sname
					format"//\n//\n//This is Header Section\n"  

					if tySA.checked == true then (   					--SA  
						thisLength = gExpsaIFP ss ($selection as array) AnimList.selected
						format "c 4\nANP3\ni 1\n%\n" (thisLength + 28)
						format "c 24\nKamMaxScriptExp\n//\n//\n"
						format "i 1\n1\n"
					) else (																		--VC
						thisLength = gm_expAnim ss ($selection as array) useBoneID.checked AnimList.selected
						format "c 4\nANPK\ni 1\n%\n" (thisLength + 28)
						format "c 4\nINFO\ni 2\n20 1\n"
						format "c 16\nKamMaxScriptExp\n//\n//\n"
					)	

					format "%\n//" (ss as string)

				)--end try/catch
				gc()
			)--end if Sname
			
		)--end if AnimList.selection
	)--end on saveAnim
	--	
	on ReplaceAnim pressed do (
		if (AnimList.selection != 0)AND($selection.count >0) then (
			OK2Append = false
			if (tyVC.checked == true)AND(AnimInfo[3] == 0x4B504E41) then OK2Append = true
			if (tySA.checked == true)AND(AnimInfo[3] == 0x33504E41) then OK2Append = true
			if OK2Append == false then (
            	messagebox "You can not replace DIFFERENT FORMAT\nin animation IFP file." title: "IFP Format Error"
            	--format "%\n" AnimInfo[3] 
			) else (

				for obj in $selection where (getUserProp obj "BoneID") == undefined do deselect obj

				try (	--undefined*undefined
					Sname = (getFilenamePath ifpname) + "ttemp.bin"
					format "\nReplace Anime: % at [%]\n" AnimList.selected AnimInfo[2][AnimList.selection]
					ff = fopen Sname "wb"
					f = fopen ifpname "rb"
					fseek f 0 #seek_end
					edf = ftell f
					fseek f 0 #seek_set
					for i = 1 to AnimInfo[2][AnimList.selection] do (
						writebyte ff (readByte f)
					)--end for i
		
					if AnimInfo[3] == 0x33504E41 then thisLength = ExpsaIFP ff ($selection as array) AnimList.selected
					else  thisLength = expAnim ff ($selection as array) useBoneID.checked AnimList.selected
		
					if AnimList.selection != AnimInfo[2].count then (
						fseek f AnimInfo[2][(AnimList.selection + 1)] #seek_set
						for i = AnimInfo[2][(AnimList.selection + 1)] to (edf - 1) do (
							writebyte ff (readByte f)
						)--end for i
					)--end if
		
					fclose f
					animLength = (ftell ff) - 8
					fseek ff 4 #seek_set
					writeLong ff animLength
					fclose ff
					gc()
			
					deleteFile ifpname
					renameFile Sname ifpname
			
					f = fopen ifpname "rb"
					HInfo = ReadifpHeader f
					AnimInfo = ifpAnimInfo f HInfo[1] HInfo[3]
					fclose f

					format "DONE!!\n\n"	

				) catch (
					fclose ff
					fclose f
					-----------------------
					--This is GMax output--
					-----------------------
					Sname = (getFilenamePath ifpname) + "ReplaceIFP.txt"
					ss = "" as stringstream

					if AnimInfo[3] == 0x33504E4 then thisLength = gExpsaIFP ss ($selection as array) AnimList.selected
					else  thisLength = gm_expAnim ss $selection useBoneID.checked AnimList.selected

					f = fopen ifpname "rb"

					if AnimList.selection != AnimInfo[2].count then (
						oldLength = AnimInfo[2][(AnimList.selection + 1)] - AnimInfo[2][AnimList.selection]
					) else (
						fseek f 0 #seek_end
						oldLength = (ftell f ) - AnimInfo[2][AnimList.selection]
					)
					thisoffset = thisLength - oldLength

					fseek f 4 #seek_set
					IFPLength = readLong f
					readLong f				
					infolength = readLong f

					clearlistener()
					format "<!-- path=\"%\" -->\n" Sname
					format"//\n//\n//This is Header Section\n//Please Replace this over the original Header\n"  

					if AnimInfo[3] == 0x33504E41 then (
						format "c 4\nANP3\ni 1\n%\n" (IFPLength + thisoffset)
						format "c 24\n%\ni 1\n%\n//\n//\n" HInfo[2] HInfo[1]
					) else (
						format "c 4\nANPK\ni 1\n%\n" (IFPLength + thisoffset)
						format "c 4\nINFO\ni 2\n% %\n" infolength (readLong f)
						format "c %\n%\n//\n//\n" (infolength - 4) (readString f)
					)
					format "%\n//" (ss as string)

					fclose f
				)
				gc()
                
			)
		)--end if AnimList.selection
	)--end on ReplaceAnim 
	--
	on batAnim pressed do (
		if (AnimList.selection > 0)AND($selection.count >0) then (
			sliderTime = 0
			if (getUserProp $selection[1] "OrgPos") == undefined then (
				for i = 1 to $selection.count do (
					setUserProp $selection[i] "OrgPos" $selection[i].pos
					setUserProp $selection[i] "OrgRot" [$selection[i].rotation.x,$selection[i].rotation.y,$selection[i].rotation.z]
					setUserProp $selection[i] "OrgRotW" $selection[i].rotation.w
					setUserProp $selection[i] "Orgscl" $selection[i].scale
				)
			)
			
			f = fopen ifpname "rb"
			for tt = astart.value to aend.value do (

				rult = resetPost $selection slidertime
				if rult == false then RecOrg.text = "M"
			
				fseek f AnimInfo[2][tt] #seek_set

				format "Anime: % at [%]\n" AnimInfo[1][tt] (ftell f)
			
				ApplyAnim   f   ($selection as array)   skipPos.checked   slidertime   AnimInfo[3]

				animationRange = interval 0 (animationRange.end + 1)
				slidertime = animationRange.end
		
				gc()
			)--end for tt
			fclose f
			animationRange = interval 0 (animationRange.end - 1)
		)
	)--end on batAnim
    --
	on AnimList doubleclicked idx do (
		if $selection.count >0 then (

			rult = resetPost $selection slidertime
			if rult == false then RecOrg.text = "M"

			f = fopen ifpname "rb"
			fseek f AnimInfo[2][AnimList.selection] #seek_set

			format "\nAnime: % at [%]\n" AnimList.selected (ftell f)
			
			ApplyAnim f ($selection as array) skipPos.checked slidertime AnimInfo[3]
		
			fclose f
			gc()
		)
	)--end on apyAnim
	--
	on apyAnim pressed do (
		if (AnimList.selection > 0)AND($selection.count >0) then (

			rult = resetPost $selection slidertime
			if rult == false then RecOrg.text = "M"

			f = fopen ifpname "rb"
			fseek f AnimInfo[2][AnimList.selection] #seek_set

			format "\nAnime: % at [%]\n" AnimList.selected (ftell f)
			
			ApplyAnim f ($selection as array) skipPos.checked slidertime AnimInfo[3]
		
			fclose f
			gc()
		)
	)--end on apyAnim
	--		
	on loadifp pressed do (
		bkfile = ifpname
		ifpname = getOpenFileName caption:"Open GTA Animation File" types:"IFP animation (*.ifp)|*.ifp|All files (*.*)|*.*|"
		if (ifpname != undefined) then (
			f = fopen ifpname "rb"
			HInfo = ReadifpHeader f
			if HInfo == undefined then (
				fclose f
				messagebox "Header Data not correct!" Title:"IFP File Error"
			) 
            else (
				lbl1.text = "Anim. File: " + (filenameFromPath ifpname)
				lbl2.text = "Total Animation: " + (HInfo[1] as string)
				lbl3.text = "Internal Name: " + HInfo[2]
		
				AnimInfo = ifpAnimInfo f HInfo[1] HInfo[3]
				if AnimInfo == undefined then (
					fclose f
					messagebox "Animation Data not correct!!" Title:"IFP File Error"
				) else ( 
					AnimList.items = AnimInfo[1]
				)--end if/else AnimInfo
				fclose f
				astart.value = 1
				aend.value = HInfo[1]

				if AnimInfo[3] == 0x4B504E41 then (
					tyVC.checked = true
					useBoneID.enabled = true
					tySA.checked = false
				) else (
					tyVC.checked = false
					useBoneID.enabled = false
					tySA.checked = true
				)

			)--end if/else HInfo
			
		) else 	ifpname = bkfile
	)--end on loadifp
	--
)--end rollout ifproll

rollout saifpaboutRoll "About" (
	label l1 "GTA IFP IO V1.1"
	label l1a "   - for both Max/GMax" align:#left
	label l2 "" 
	label l3 "by Kam" align:#left across:2
	label l4 "14Oct05" align:#right
	label l5 "kam.lai@ntlworld.com"
	label l6 " "
	label l7 "**Important GMax User**"
	label l8 "- You need copy/paste all" align:#left
	label l9 "  text from listener and edit" align:#left
	label lA "  the ifp text (from dumper)."	align:#left
	label lb "- Use T2B.exe to convert it."
)

if Kam_GTAsaIFP != undefined then ( closeRolloutFloater Kam_GTAsaIFP; gc() )
Kam_GTAsaIFP = newRolloutFloater "Animation IFP IO" 175 565 10 30		
addRollout saifproll Kam_GTAsaIFP
addRollout saifpaboutRoll Kam_GTAsaIFP rolledup:true