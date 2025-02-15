
suspendediting()
disableSceneRedraw()
setWaitCursor()
enableUndo false
try(
	for obj in selection where superclassof obj == geometryClass do (
		if classof obj != Editable_Poly then convertToPoly obj
		local vertArr = (polyop.getVertsUsingEdge obj (polyop.getOpenEdges obj) as array)
		polyop.setMapSupport obj -2 false
		polyop.setMapSupport obj -2 true
		for i = 1 to vertArr.count do (
			polyop.setMapVert  obj -2 vertArr[i] [0.0,0.0,0.0]
		)
	)
) catch (messagebox "Set mass vertex Alpha error!")
resumeediting()
enableSceneRedraw()
setArrowCursor()
redrawViews()
enableUndo true