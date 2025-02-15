
	
try (DestroyDialog FixDifColor) catch()
rollout FixDifColor "FixDifColor" width:189 height:88
(
	groupBox grp1 "Fix Diffuse Color" pos:[7,8] width:171 height:67
	button btn1 "Fix the selected models !" pos:[19,32] width:148 height:31 toolTip:""
	on btn1 pressed do (
		if selection.count > 0 then (
			clearListener()
			format "Fix Diffuse started:\n"
			for obj in selection  do (
				if superclassof obj == GeometryClass then (
					if classof (obj.material)==Multimaterial do (
						for mtl in obj.material where mtl !=undefined do (
							if classof (mtl)==Standardmaterial do try ( 
								mtl.diffuse=white 
							) catch (format "Fix err #1\n")
							if classof (mtl)==GTA_Mtl do try ( 
								mtl.color=white 
							) catch (format "Fix err #2\n")
						)
						format "[Fixed] %\n" obj.name
					)
					if classof (obj.material)==Standardmaterial do try (
						obj.material.diffuse = white
						format "[Fixed] %\n" obj.name
					) catch (format "Fix err #3\n")
					if classof (obj.material)==GTA_Mtl do try (
						obj.material.color = white 
						format "[Fixed] %\n" obj.name
					) catch (format "Fix err #4\n")				
				) else format "[no Fixed] % - is not a geometry\n" obj.name
			)
		) else messagebox " Models not selected !" title: "FixDifColor - error"
	)
)
createDialog FixDifColor 