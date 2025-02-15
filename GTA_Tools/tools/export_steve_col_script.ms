-- s = selection as array
-- Dir = "D:\\SA_MOD\\COL_TEST\\"

fn COL_SCRIPT_EXPORT s Dir = (
local o, obj, f, fname, NVerts, Nfaces, V, m, i, mat, Vf, colsph = #(), colbox = #(), ch
	for o in s do (
		if o.parent == undefined then (

			-- Delete Zero Area Faces ----------------
			convertToMesh o
			meshop.deleteIsoVerts o
			f = #{}
			for i = 1 to o.numfaces do (
				if abs (meshop.getFaceArea o i) < 0.00001 then append f i
			)
			if not f.isEmpty then (
			meshop.deleteFaces o f
			format "%: % faces deleted\n" o.name f.numberset
			) else format "% no zero-area faces2\n" o.name
			-- Delete Zero Area Faces ----------------
			-------------------------------------------
			
			 obj = o.mesh
			 fname = Dir + "\\" + o.name + ".cst"
			 f = CreateFile fname
			 
			 format "CST2\n\n" to:f
			 
			 NVerts = obj.NumVerts
			 format "%, Vertex\n" NVerts to:f
			 
			 for i = 1 to NVerts do (
			  V = in coordsys local (getVert obj i)
			  format "%, %, %\n" V.x V.y V.z to:f
			 )
			 
			 Nfaces = obj.NumFaces
			 format "\n%, Face\n" NFaces to:f
			 m = o.material
			 
			 for i = 1 to NFaces do (
			  Vf = GetFace obj i
			  mmm = getFaceMatID obj i
			  if m!=undefined then (
				if isKindOf m MultiMaterial then (
				  if isKindOf m[getFaceMatID obj i] GTA_COLSurface then mat = m[getFaceMatID obj i].surface
				  else mat = 0 --(mmm)-- (getFaceMatID obj i) - 1
				)else (
				  if isKindOf m GTA_COLSurface then mat = m.surface
				  else mat = 0 --(mmm)  -- ((getFaceMatID obj i) -1)
				  )
				)
			  else mat = 0
			   
			 
				
			  format "%, %, %, %, 0, 0, 78\n" ( Vf[1] as integer -1) ( Vf[3] as integer -1)( Vf[2] as integer -1) mat to:f
			 
			
			 
			)
			
			close f
		)
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

objs = selection
if objs.count==0 then messageBox "select col objects"
else (
	clearListener()
	if limitCheck objs == false then (
		opath = getSavePath caption:"select output path"
		if opath != undefined then
		disableSceneRedraw() 
		try (
			COL_SCRIPT_EXPORT objs opath
		) catch ( 
			format "col script ERROR\n" 
			enableSceneRedraw() 
		)
		enableSceneRedraw() 
	) else messagebox "the COL dimension limits of +/- 255.99 per axis!\n\n(COL Model is very big)" title: "COL Export Error"
) -- obj.count