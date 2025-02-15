/*
 - CST Files Import script 0.1 -
 
Last update: 15.05.2019

for 3ds max 2009 and higher

-------------------------------
 
Script features:
- mass import
- Import CST Collision Format
- Import collision materials

Author: Goldfish 
Goldfish-1994@yandex.ru 
https://vk.com/vk.goldfish

Support: 
https://vk.com/goldscripts
		
Change the code on your own risk !!!
*/
(
	local faceArray
	local vertexArray
	local pbMax
	local pbcount
	local rl_cstimport
	local pbUpdate
	
	fn pbUpdate varSt = (
		if varSt == -1 then (
			rl_cstimport.prog.value = 0
		)
		else (
			rl_cstimport.prog.value = (((varSt)/pbMax)*100.0)
		)
	)

	fn readCST file = (
		txt = openFile file
		readStatus = 0
		faceArray = #()
		vertexArray = #()
		step = false
		line = readline txt
		--cstType = filterString line " "
		if line[1] == "#" then ( 
			line = readline txt
			line = readline txt
			--cstType = filterString line " "
		)
		if line == "CST2" then (
			format "%.cst\n" (getFilenameFile file)
			while (not eof txt) do (
				line = readline txt
				--format "line \"%\"\n" line
				if line == "" then (
					readStatus = 0
					continue
				)
				data = filterString line ",  "
				--format "data = %1\n" data
				
				if data[2] == "This" then (
					pbcount += 2.0
					pbUpdate pbcount
					return 2
				)
				if data[2] == "Vertex" then (
					readStatus = 1
					pbcount += 1.0
					pbUpdate pbcount
					step = true
					format "[cst import] read Vertex data...\n"
					continue
				) else (
					if data[2] == "Face" then (
						--format "data Face\n" 
						step = true
						readStatus = 2
						pbcount += 1.0
						pbUpdate pbcount
						format "[cst import] read Face data...\n"
						continue
					)
				)
				
				if readStatus == 1  then (
					--format "readStatus == 1\n" 
					fx = data[1] as float
					fy = data[2] as float
					fz = data[3] as float
					append vertexArray #(fx,fy,fz)
				) else (
					if readStatus == 2 then (
						--format "readStatus == 2\n" 
						fx = data[1] as integer
						fy = data[2] as integer
						fz = data[3] as integer
						fmat = data[4] as integer
						funk1 = data[5] as integer
						funk2 = data[6] as integer
						fbright = data[6] as integer
						append faceArray #(fx,fy,fz,fmat,funk1,funk2,fbright)
					)
				)
			)
			pbcount += 1.0
			pbUpdate pbcount
		) else (
			close  txt
			return 0
		)
		close  txt
		return 1
	)

	fn buildMesh mName = (
		--format "mName %\n" mName
		--format "vertexArray.count %\n" vertexArray.count
		--format "faceArray.count %\n" faceArray.count
		colMesh=mesh numverts:vertexArray.count numfaces:faceArray.count
		colMesh.name = mName
		--Vertices--
		for i = 1 to vertexArray.count do (
			setVert colMesh i vertexArray[i][1] vertexArray[i][2] vertexArray[i][3]
		)
		pbcount += 1.0
		pbUpdate pbcount
		--Faces--
		for i = 1 to faceArray.count do (
			setFace colMesh i [faceArray[i][1]+1,faceArray[i][2]+1,faceArray[i][3]+1]
			setEdgeVis colMesh i 1 true
			setEdgeVis colMesh i 2 true
			setEdgeVis colMesh i 3 true
		)
		pbcount += 1.0
		pbUpdate pbcount
		matCount = #()
		append matCount faceArray[1][4]
		for i = 2 to faceArray.count do (
			res = findItem matCount faceArray[i][4]
			if res == 0 then (
				append matCount faceArray[i][4]
				
			)
		)
		matMapid = #()
		matMapsurf = #()
		--try (
			mltmtl = multimaterial numsubs:matCount.count
			for i = 1 to matCount.count do (
				mltmtl[i] = GTA_COLSurface()
				mltmtl[i].surface = matCount[i] as integer
				mltmtl[i].name = matCount[i] as string
				append matMapid i
				append matMapsurf (matCount[i] as integer)
			)
		--) catch (messagebox "Error, GTA COL Surface not found!" title: "CST Import")
		
		for i = 1 to faceArray.count do (
			index = findItem matMapsurf faceArray[i][4]
			setFaceMatID colMesh i matMapid[index]
		)
		pbcount += 1.0
		pbUpdate pbcount
		fList = #()
		for i = 1 to colMesh.numfaces do (
			append fList i
		)
		vList = #()
		for i = 1 to colMesh.numverts do (
			append vList i
		)
		meshop.weldVertsByThreshold colMesh vList 0.001
		meshop.flipNormals colMesh fList
		addModifier colMesh (smooth())
		colMesh.modifiers[1].autosmooth = true
		collapseStack colMesh
		colMesh.material = mltmtl
		convertToPoly colMesh
		pbcount += 1.0
		pbUpdate pbcount
	)

	fn OpenFileDialog_ = (
		try ( 
			theDialog = dotNetObject "System.Windows.Forms.OpenFileDialog" --create a OpenFileDialog
			theDialog.title = "PLEASE Select One Or More Files" --set the title
			theDialog.Multiselect = true --allow multiple files to be selected
			theDialog.Filter = "CST collision format (*.cst)|*.cst|All Files (*.*)|*.*" --specify the filter
			theDialog.FilterIndex = 1 --set the filter drop-down list to All Files
			result = theDialog.showDialog() --display the dialog, get result into variable
			result.ToString() --when closed, convert the result to string
			result.Equals result.OK --returns TRUE if OK was pressed, FALSE otherwise
			result.Equals result.Cancel --returns TRUE if Cancel was pressed, FALSE otherwise
			fname = theDialog.fileNames --the selected filenames will be returned as an array
		) catch (
			fname1 = getopenfilename caption:"Read CST File" types:"CST collision format (*.cst)|*.cst|All Files (*.*)|*.*"
			fname = #(fname)
		)
		return fname -- arrray
	)

	rollout rl_cstimport " Import CST:" (
		label dummy ""
		label objname "" align:#left
		progressbar prog
	)

	fname = OpenFileDialog_() 
	errArray = #()
	pbMax = 0
	pbcount = 0
	scnt = 0
	if fname != undefined then (
		if fname.count > 0 then (
			--disableSceneRedraw()
			createDialog rl_cstimport 220 60
			rl_cstimport.prog.value = 0.0
			pbMax = 7.0 * (fname.count as float)
			clearListener()
			format "CST import:\n----------------------\n\n"
			for i = 1 to fname.count do (
				result = 0
				rl_cstimport.objname.text = (getFilenameFile fname[i]) + ".cst"
				try (
					result = readCST fname[i]
					if result == 2 then (
						format "[cst import] This CST file is DUMMY!\n----------------------\n\n"
					) else format "[cst import] read done (%)\n             vertex:% face: %\n" result vertexArray.count faceArray.count	
				) catch (result = 0)
				try (	
					 if result == 1 then (
						buildMesh (getFilenameFile fname[i])
						format "[cst import] buildMesh done\n----------------------\n\n"
						scnt += 1
					)
				) catch (
					result== 0
				)
				if result == 0 then append errArray (filenameFromPath  fname[i])
			)
			DestroyDialog rl_cstimport
			erStr = ""
			if errArray != undefined then (
				if errArray.count > 0 then (
						erStr = "\n\nImport ERROR:\n\n"
						for str in errArray do (
							erStr += str as string
							erStr += "\n"
						)
				)
			)
			messagebox ("Successfully imported: " + (scnt as string) + erStr)  title: "CST Import"
			enableSceneRedraw()
			redrawViews()
		)
	)
)