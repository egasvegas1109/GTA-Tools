try (DestroyDialog hrh) catch()

global hierArr

rollout hrh "" width:280 height:110
(
	label txt "Vehicle Scale Helper v 1.0"
	label txt2 ""
	button btn_un "Unlink All" across: 2 height:35 width:114
	button btn_l "Relink" height:35 width:114 
	label how "How to use" across:2 align:#right offset:[90,3]
	button btn_how "?" height:20 width:20 align:#right offset:[-10,2]
	
	on btn_how pressed do (
		try (DestroyDialog how_rol) catch()
		rollout how_rol "How to use" width:250   (
				label how_0 ""
				label how_1 "1) Select the all hierarchy of your vehicle model"  align:#left 
				label how_2 "2) Press \"Unlink All\" KEY" align:#left
				label how_3 "3) Change the scale of your vehicle model" align:#left
				label how_4 "4) Press \"Relink\" KEY" align:#left
				label how_5 "Done! You can export the model to dff" align:#left
				label how_6 ""
				button btn_close "close" align:#right width:69 height:22
				on btn_close pressed do DestroyDialog  how_rol 
		)
		createDialog how_rol 
	)
	
	on btn_un pressed  do(
		if selection.count > 0 then (
			hierArr = #()
			for obj in selection where (superclassof obj == GeometryClass or superclassof obj ==  helper ) do (
				append hierArr #(obj,obj.parent)
				obj.parent = undefined
			)
		) else messagebox "Models not selected!" title: "Error" 
	)
	
	on btn_l pressed  do(
		if (hierArr != undefined and hierArr.count > 0 ) then (
			for hobj in hierArr do (
				ResetXForm hobj[1]
				collapseStack hobj[1]
			)
			for hobj in hierArr do (
				hobj[1].parent = hobj[2]
			)
		)
		hierArr = #()
	)
)

createDialog hrh style: #(#style_titlebar, #style_border, #style_sysmenu,#style_minimizebox)