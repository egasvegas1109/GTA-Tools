-- s = selection as array
-- Dir = "D:\\SA_MOD\\COL_TEST\\"

(
	local rl_cstexport
	local pbMax
	local pbcount
	local pbUpdate
	
	fn pbUpdate varSt = (
		if varSt == -1 then (
			rl_cstexport.prog.value = 0
		) else (
			rl_cstexport.prog.value = (((varSt)/pbMax)*100.0)
		)
	)


	fn COL_SCRIPT_EXPORT obj Dir = (
	local f, fname, NVerts, Nfaces, V, m, i, mat, Vf, colsph = #(), colbox = #(), ch
		if obj.parent == undefined then (

			-- Delete Zero Area Faces ----------------
			if (classof obj) != Editable_mesh then converttomesh obj
			meshop.deleteIsoVerts obj
			f = #{}
			for i = 1 to obj.numfaces do (
				if abs (meshop.getFaceArea obj i) < 0.00001 then append f i
			)
			if not f.isEmpty then (
			meshop.deleteFaces obj f
			format "%: % faces deleted\n" obj.name f.numberset
			)
			-- Delete Zero Area Faces ----------------
			-------------------------------------------
			
			 meshObj = obj.mesh
			 fname = Dir + "\\" + obj.name + ".cst"
			 f = CreateFile fname
			 
			 format "CST2\n\n" to:f
			 
			 NVerts = meshObj.NumVerts
			 format "%, Vertex\n" NVerts to:f
			 
			 for i = 1 to NVerts do (
			  V = in coordsys local (getVert meshObj i)
			  format "%, %, %\n" V.x V.y V.z to:f
			 )
			pbcount += 1.0
			pbUpdate pbcount
			 Nfaces = meshObj.NumFaces
			 format "\n%, Face\n" NFaces to:f
			 m = obj.material
			 
			for i = 1 to NFaces do (
				Vf = GetFace meshObj i
				mmm = getFaceMatID meshObj i
				if m != undefined then (
					if isKindOf m MultiMaterial then (
						if isKindOf m[getFaceMatID meshObj i] GTA_COLSurface then mat = m[getFaceMatID meshObj i].surface
						else mat = 0 --(mmm)-- (getFaceMatID meshObj i) - 1
					) else (
						if isKindOf m GTA_COLSurface then mat = m.surface
						else mat = 0 --(mmm)  -- ((getFaceMatID meshObj i) -1)
					)
				) else mat = 0
				format "%, %, %, %, 0, 0, 78\n" ( Vf[1] as integer -1) ( Vf[3] as integer -1)( Vf[2] as integer -1) mat to:f
			)
			pbcount += 1.0
			pbUpdate pbcount
			close f
		) else (
			pbcount += 2.0
			pbUpdate pbcount
		)
	) -- fn

	 -----------------------------------------------------------------------------------------
	 -----------------------------------------------------------------------------------------
	 -----------------------------------------------------------------------------------------
	 -----------------------------------------------------------------------------------------
	 -----------------------------------------------------------------------------------------
	fn limitCheck objs = (
		dimch = false
		for i in objs do (
			if  (coordsys local (abs i.min.x)) > 255.99 or (coordsys local (abs i.max.x)) > 255.99 or 
				(coordsys local (abs i.min.y)) > 255.99 or (coordsys local (abs i.max.y)) > 255.99 or
				(coordsys local (abs i.min.z)) > 255.99 or (coordsys local (abs i.max.z)) > 255.99 then (
					format "[COL oversize!] %\n" i.name
					dimch = true
				)
		)
		return dimch
	)

	fn getSelCOLCount = (
		cnt = 0
		for obj in selection where ( superclassof obj == GeometryClass ) do cnt+=1
		return cnt
	)

	if selection.count > 0 then (
		opath = getSavePath caption:"select output path"
		if opath != undefined then (
			rollout rl_cstexport " Export CST:" (
				label dummy ""
				label objname "" align:#left
				progressbar prog
			)
			
			pbMax = 0
			pbcount = 0
			rl_cstexport.prog.value = 0.0
			pbMax = 2.0 * getSelCOLCount()
			createDialog rl_cstexport 220 60
			clearListener()
			for obj in selection where ( superclassof obj == GeometryClass ) do (
				rl_cstexport.objname.text = obj.name + ".cst"
				if limitCheck obj == false then (
					disableSceneRedraw() 
					try (
						COL_SCRIPT_EXPORT obj opath
					) catch ( 
						messagebox " Unknown error !" title: "Export to CST"
						enableSceneRedraw() 
					)
					enableSceneRedraw() 
				) else (
					format "[cst export] %: the COL dimension limits of +/- 255.99 per axis!\n\n(COL Model is very big)" obj.name
					pbcount += 2.0
					pbUpdate pbcount
				)
			)
			DestroyDialog rl_cstexport
		) else messagebox " Models not selected !" title: "Export to CST"	
	)
)