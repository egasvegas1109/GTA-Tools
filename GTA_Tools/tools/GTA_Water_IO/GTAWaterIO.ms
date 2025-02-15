try (DestroyDialog rl_GTAwaterIO) catch()
global rl_GTAwaterIO


/*
 - GTA Water IO 1.0b -
 
Last update: 18.03.2019

for 3ds max 2009 and higher

-------------------------------
 
Script features:
- EXPORT and IMPORT water (water.dat)
- EXPORT and IMPORT water parameters
- built-in utilities for setting up of the water plane

Author: Goldfish 
Goldfish-1994@yandex.ru 
https://vk.com/vk.goldfish
(Specially for the CRime team)

Support: 
https://vk.com/goldscripts
		
Change the code on your own risk !!!
*/

(
	local obj, universal, edgeSel = #{}
	local gPrmtrObj = #()
	local gPrmtrNumVert = #()
	local _LOG
	local ch_log
	
	fn _LOG text_ v1:"" v2:"" v3:"" v4:"" = (
		if ch_log.checked == true then (
			if text_[text_.count] != "\n" then text_+="\n"
			format text_ v1 v2 v3 v4
		)
	)
	
	fn _LOGprocess text_  = (
		if text_[text_.count] != "\n" then text_+="\n"
		format text_ 
	)
	
	fn _LOGar text_ v1:#() = (
		if ch_log.checked == true then (
			if v1 != undefined then (
				format text_
				logText = ""
				if v1.count >=3 then (
					for i = 1 to v1.count by 3 do (
						format "   ---------------\n   % verts = % faces = % flag = %\n   " v1[i].name v1[i].numverts v1[i].numfaces v1[i+1]
						iArr = i + 2
						lineCount = 0
						if v1[iArr].count >= 1 then (
							for j = 1 to v1[iArr].count do (
								if lineCount >= 10 then (
									lineCount = 0
									
									format "%\n   " logText
									logText = ""
									--format "\n   " 
								)
								lineCount +=1
								logText += (v1[iArr][j]) as string
								--format "% " v1[iArr][j]
							)
							format "%\n   " logText
							--format "\n\n" 
						)
					)
				)
			) else format "  arr undefined\n"
		)
	)
	
	fn get3dsMaxVersionAsString = (
		info = maxVersion()
		version = info[1]
		if version == 7000 then return "3ds Max 7"
		if version >= 7800 and version <= 8000  then return "3ds Max 8"
		if version >= 8900 and version <= 9000  then return "3ds Max 9"
		if version >= 9900 and version <= 10000  then return "3ds Max 2008"
		if version >= 10900 and version <= 11000  then return "3ds Max 2009"
		if version >= 11900 and version <= 12000  then return "3ds Max 2010"
		if version >= 12900 and version <= 13000  then return "3ds Max 2011"
		if version >= 13900 and version <= 14000  then return "3ds Max 2012"
		if version >= 14800 and version <= 15000  then return "3ds Max 2013"
		if version >= 15900 and version <= 16000  then return "3ds Max 2014"
		if version >= 16900 and version <= 17000  then return "3ds Max 2015"
		if version >= 17900 and version <= 18000  then return "3ds Max 2016"
		if version >= 18900 and version <= 19000  then return "3ds Max 2017"
		if version >= 19900 and version <= 20000  then return "3ds Max 2018"
		if version >= 20900 and version <= 21000  then return "3ds Max 2019"
		return "3ds Max undefined"
	)
	
	struct polyFns
	(
		getVertPos = polyOp.getVert,
		getEdgeVerts = polyOp.getEdgeVerts,
		getEdgeSel = polyOp.getEdgeSelection,
		setEdgeSel = polyOp.setEdgeSelection,
		getVertsByEdges = polyOp.getVertsUsingEdge,
		getEdgesByVerts = polyOp.getEdgesUsingVert
	)
	struct edgeDef
	(
		edge,
		startVert,
		endVert,
		endVertPos = universal.getVertPos obj endVert,
		dir = normalize (universal.getVertPos obj startVert - endVertPos)
	)

	struct stopConditionsDef (
		angle = true,
		fork = true,
		pole = false,
		angleCos = cos 30,
		forkTol = 5,
		poleVal = 5,
		result,

		fn meet candidates =
		(
			result = if candidates.count > 0 then candidates[1].v1

			if candidates.count == 0 then true
			else if angle AND candidates[1].v2 < angleCos then true
			else if fork AND candidates.count > 1 AND abs(acos candidates[1].v2 - acos candidates[2].v2) < forkTol then true
			else if pole AND candidates.count == poleVal then true
			else false
		)
	)

	local stopConditions = stopConditionsDef()

	---------------------------------------------------------------------------------
	-- Functions
	---------------------------------------------------------------------------------
	fn average2num  num1 num2 = ( -- srednee arifmiticheskoe
		return (num1 + num2) / 2.0
	)

	fn getFirstItem bitArr item:0 =
	(
		for i in bitArr while NOT item > 0 do item = i
		item
	)

	fn compareAngle edge1 edge2 =
		if edge1.v2 < edge2.v2 then 1
		else if edge1.v2 > edge2.v2 then -1
		else 0

	fn getEdgeByVertData edge edgeVerts sharedVerts =
		if (edgeVerts - sharedVerts).numberSet < 1 then edgeDef edge:edge startVert:(getFirstItem edgeVerts) endVert:(edgeVerts as array)[2]
		else edgeDef edge:edge startVert:(getFirstItem (edgeVerts * sharedVerts)) endVert:(getFirstItem (edgeVerts - sharedVerts))
		
	fn getEdgeByEdgeIndex edge =
		getEdgeByVertData edge (universal.getVertsByEdges obj edge) (universal.getVertsByEdges obj (edgeSel - #{edge}))

	fn getTerminalEdges obj edges terminalEdges:#() =
	(
		for edge in edges do
		(
			local edgeCount = (universal.getEdgesByVerts obj (local edgeVerts = universal.getVertsByEdges obj edge) * edgeSel).numberSet
			if edgeCount == 2 do
				
				append terminalEdges (getEdgeByVertData edge edgeVerts (universal.getVertsByEdges obj (edgeSel - #{edge})))
			if edgeCount == 1 do
			(
				edgeVerts = edgeVerts as array
				append terminalEdges (edgeDef edge:edge startVert:edgeVerts[1] endVert:edgeVerts[2])
				append terminalEdges (edgeDef edge:edge startVert:edgeVerts[2] endVert:edgeVerts[1])
			)
		)
		terminalEdges
	)

	fn getCandidates obj edge =
	(
		local indices = universal.getEdgesByVerts obj edge.endVert - edgeSel
		local candidates = for i in indices collect
			dataPair i (dot edge.dir (normalize (edge.endVertPos - universal.getVertPos obj (getFirstItem (universal.getVertsByEdges obj i - #{edge.endVert})))))

		qSort candidates compareAngle
		candidates
	)

	mapped fn modifyLoop edges modify =
	(
		modify edgeSel edges.edge
		universal.setEdgeSel obj edgeSel
		edges
	)

	mapped fn growLoop edges =
		if (NOT stopConditions.meet (getCandidates obj edges)) do
			modifyLoop (getEdgeByEdgeIndex stopConditions.result) append

	mapped fn selectLoop edges =
		if (NOT stopConditions.meet (getCandidates obj edges)) do
			selectLoop (modifyLoop (getEdgeByEdgeIndex stopConditions.result) append)

	fn initLoopData sel =
	(
		edgeSel = sel
		getTerminalEdges obj edgeSel
	)

fn triangleCheck obj i = (
	chFaces = (polyop.getFacesUsingEdge obj i as array)
	if chFaces.count == 1 then (
		chEdges = (polyop.getEdgesUsingFace obj chFaces[1] as array)
		if chEdges.count == 3 then (	
			if i == chEdges[1] then (
				vChkEdge = (polyop.getVertsUsingEdge obj chEdges[1]  as array)
				vByedge1 = (polyop.getVertsUsingEdge obj chEdges[2]  as array)
				vByedge2 = (polyop.getVertsUsingEdge obj chEdges[3]  as array)
				distHypotenuse = sqrt ((distance (polyop.getVert obj vByedge1[1]) (polyop.getVert obj vByedge1[2]))^2 + (distance (polyop.getVert obj vByedge2[1]) (polyop.getVert obj vByedge2[2]))^2)
				if distHypotenuse == (distance (polyop.getVert obj vChkEdge[1]) (polyop.getVert obj vChkEdge[2])) then (
					return true
				)
			) else 
				if i == chEdges[2] then (
					vChkEdge = (polyop.getVertsUsingEdge obj chEdges[2]  as array)
					vByedge1 = (polyop.getVertsUsingEdge obj chEdges[1]  as array)
					vByedge2 = (polyop.getVertsUsingEdge obj chEdges[3]  as array)
					distHypotenuse = sqrt ((distance (polyop.getVert obj vByedge1[1]) (polyop.getVert obj vByedge1[2]))^2 + (distance (polyop.getVert obj vByedge2[1]) (polyop.getVert obj vByedge2[2]))^2)
					if distHypotenuse == (distance (polyop.getVert obj vChkEdge[1]) (polyop.getVert obj vChkEdge[2])) then (
						return true
					)
				) else 
					if i == chEdges[3] then (
						vChkEdge = (polyop.getVertsUsingEdge obj chEdges[3]  as array)
						vByedge1 = (polyop.getVertsUsingEdge obj chEdges[2]  as array)
						vByedge2 = (polyop.getVertsUsingEdge obj chEdges[1]  as array)
						distHypotenuse = sqrt ((distance (polyop.getVert obj vByedge1[1]) (polyop.getVert obj vByedge1[2]))^2 + (distance (polyop.getVert obj vByedge2[1]) (polyop.getVert obj vByedge2[2]))^2)
						if distHypotenuse == (distance (polyop.getVert obj vChkEdge[1]) (polyop.getVert obj vChkEdge[2])) then (
							return true
						)
					)	
		)
	) 
	return false
)

fn write4To txt verts = (
	format "% % % % % % %    % % % % % % %    % % % % % % %    % % % % % % %  %\n" \
	verts[1].x verts[1].y verts[1].z \
	(formattedPrint verts[2][1] format:".5f") (formattedPrint verts[2][2] format:".5f") (formattedPrint verts[2][3] format:".5f") (formattedPrint verts[2][4] format:".5f")  \
	verts[3].x verts[3].y verts[3].z \
	(formattedPrint verts[4][1] format:".5f") (formattedPrint verts[4][2] format:".5f") (formattedPrint verts[4][3] format:".5f") (formattedPrint verts[4][4] format:".5f")  \
	verts[5].x verts[5].y verts[5].z \
	(formattedPrint verts[6][1] format:".5f") (formattedPrint verts[6][2] format:".5f") (formattedPrint verts[6][3] format:".5f") (formattedPrint verts[6][4] format:".5f")  \
	verts[7].x verts[7].y verts[7].z \
	(formattedPrint verts[8][1] format:".5f") (formattedPrint verts[8][2] format:".5f") (formattedPrint verts[8][3] format:".5f") (formattedPrint verts[8][4] format:".5f")  \
	verts[9] to:txt
)	

fn write3To txt verts = (
	format "% % % % % % %    % % % % % % %    % % % % % % %  %\n" \
	verts[1].x verts[1].y verts[1].z \
	(formattedPrint verts[2][1] format:".5f") (formattedPrint verts[2][2] format:".5f") (formattedPrint verts[2][3] format:".5f") (formattedPrint verts[2][4] format:".5f")  \
	verts[3].x verts[3].y verts[3].z \
	(formattedPrint verts[4][1] format:".5f") (formattedPrint verts[4][2] format:".5f") (formattedPrint verts[4][3] format:".5f") (formattedPrint verts[4][4] format:".5f")  \
	verts[5].x verts[5].y verts[5].z \
	(formattedPrint verts[6][1] format:".5f") (formattedPrint verts[6][2] format:".5f") (formattedPrint verts[6][3] format:".5f") (formattedPrint verts[6][4] format:".5f")  \
	verts[7] to:txt
)

function getLineLineAngle &p3Line_1_Point_1 &p3Line_1_Point_2 &p3Line_2_Point_1 &p3Line_2_Point_2 fEpsilon:1E-6 = (
    local p3Vector_A = p3Line_1_Point_2 - p3Line_1_Point_1
    local p3Vector_B = p3Line_2_Point_2 - p3Line_2_Point_1
    local p3Vector_C = p3Line_1_Point_1 - p3Line_2_Point_1

    local p3Cross_AB = cross p3Vector_A p3Vector_B

    if ((abs (dot p3Vector_C p3Cross_AB)) >= fEpsilon) then -- skew
        return undefined
    else if ( ((length (cross p3Vector_A p3Vector_C)) <= fEpsilon) and \
              ((length (cross p3Vector_B p3Vector_C)) <= fEpsilon) ) then -- coincident
        return 0.0
    else if ((length p3Cross_AB) <= fEpsilon) then -- parallel
        return 0.0
    else -- intersecting
        return (acos (dot (normalize p3Vector_A) (normalize p3Vector_B)))

)

fn lineLineAngle pA pB pC pD = (
	local vAB=pB-pA
	local vCD=pD-pC
	local angle=acos (dot (normalize vAB) (normalize vCD))
	if angle<90.0 then angle else (180.0-angle)
)
	


fn getRectVert obj face = (
	vertsArr = (polyop.getVertsUsingFace obj face as array)
	--vertsArr #(1,2,3)
	line1_v1 = (polyop.getVert  obj vertsArr[1])
	line1_v2 = (polyop.getVert  obj vertsArr[2])
	line2_v1 = (polyop.getVert  obj vertsArr[2])
	line2_v2 = (polyop.getVert  obj vertsArr[3])
	thisvert = 2
	lineRes = (lineLineAngle line1_v1 line1_v2 line2_v1 line2_v2)
	_LOG "[dg:] getRectVert() info: angle =  % vert = %\n" v1:lineRes v2:vertsArr[thisvert]
	
	if lineRes == 90.0 then return vertsArr[thisvert]
	--
	line1_v1 = (polyop.getVert  obj vertsArr[1])
	line1_v2 = (polyop.getVert  obj vertsArr[3])
	line2_v1 = (polyop.getVert  obj vertsArr[3])
	line2_v2 = (polyop.getVert  obj vertsArr[2])
	thisvert = 3
	lineRes = (lineLineAngle line1_v1 line1_v2 line2_v1 line2_v2)
	_LOG "[dg:] getRectVert() info: angle =  % vert = %\n" v1:lineRes v2:vertsArr[thisvert]
	if lineRes == 90.0 then return vertsArr[thisvert]
	--
	line1_v1 = (polyop.getVert  obj vertsArr[3])
	line1_v2 = (polyop.getVert  obj vertsArr[1])
	line2_v1 = (polyop.getVert  obj vertsArr[1])
	line2_v2 = (polyop.getVert  obj vertsArr[2])
	thisvert = 1
	lineRes = (lineLineAngle line1_v1 line1_v2 line2_v1 line2_v2)
	_LOG "[dg:] getRectVert() info: angle =  % vert = %\n" v1:lineRes v2:vertsArr[thisvert]
	if lineRes == 90.0 then return vertsArr[thisvert]
	vertsArr = 0
)

fn distance1point  dis1 dis2 = ( 
	if dis1 < 0.0 and dis2 < 0.0 then res = dis1 - dis2
		else if dis1 < 0.0 then res = (abs dis1) + dis2
			else if dis2 < 0.0 then res = (abs dis2) + dis1
				else res = dis1 - dis2
	abs res
)

fn fixWatTriangle obj face = ( 
	firstVert = getRectVert obj face
	var = (polyop.getVertsUsingFace obj face as array)
	deleteItem  var (findItem var firstVert)
	v1 = (polyop.getVert  obj firstVert)
	v2 = (polyop.getVert  obj var[1])
	v3 = (polyop.getVert  obj var[2])
	tmp1 = (distance v1 v2)
	tmp2 = (distance v1 v3)
	if tmp1 != tmp2 then (
		_LOG "[dg:] fixWatTriangle() info: % != %\n" v1:tmp1 v2:tmp2
		if v1.x == v2.x then ( -- var[1]
			_LOG "[dg:] fixWatTriangle() info: v1.x == v2.x\n"
			distx = distance1point v1.x v3.x
			disty = distance1point v1.y v2.y
			if distx < disty then (
				_LOG "[dg:] fixWatTriangle() info: distx < disty\n"
				if v2.y > v1.y then (
					_LOG "[dg:] fixWatTriangle() info: v2.y > v1.y\n"
					v2.y = v1.y + distx
				) else (
					_LOG "[dg:] fixWatTriangle() info: v2.y < v1.y\n"
					v2.y = v1.y - distx
				)
			) else (
				_LOG "[dg:] fixWatTriangle() info: distx > disty\n"
				if v3.x > v1.x then (
					_LOG "[dg:] fixWatTriangle() info: v3.x > v1.x\n"
					v3.x = v1.x + disty
				) else (
					_LOG "[dg:] fixWatTriangle() info: v3.x < v1.x\n"
					v3.x = v1.x - disty
				)
			)
		) else ( -- var[2] v1.x == v3.x
			_LOG "[dg:] fixWatTriangle() info: v1.x == v3.x\n"
			distx = (distance1point v1.x v2.x)
			disty = (distance1point v1.y v3.y)
			if distx < disty then (
				_LOG "[dg:] fixWatTriangle() info: distx < disty\n"
				if v3.y > v1.y then (
					_LOG "[dg:] fixWatTriangle() info: v3.y > v1.y\n"
					v3.y = v1.y + distx
				) else (
					_LOG "[dg:] fixWatTriangle() info: v3.y < v1.y\n"
					v3.y = v1.y - distx
				)
			) else (
				_LOG "[dg:] fixWatTriangle() info: distx > disty\n"
				if v2.x > v1.x then (
					_LOG "[dg:] fixWatTriangle() info: v2.x > v1.x\n"
					v2.x = v1.x + disty
				) else (
					_LOG "[dg:] fixWatTriangle() info: v2.x < v1.x\n"
					v2.x = v1.x - disty
				)
			)
		)
		polyop.setVert  obj firstVert v1
		polyop.setVert  obj var[1] v2
		polyop.setVert  obj var[2] v3
	)
)

fn getVertParam obj vertObj = (
	retn = #()
	if gPrmtrObj.count >= 1 then (
		for ObjI = 1 to gPrmtrObj.count by 3 do (
			if obj == gPrmtrObj[ObjI] then (
				pflag = gPrmtrObj[ObjI + 1]
				arNum = ObjI + 2
				for i = 1 to gPrmtrObj[arNum].count  do (
					if gPrmtrObj[arNum][i] != #() then (
						if gPrmtrObj[arNum][i][1] == vertObj then (
							wDirx = gPrmtrObj[arNum][i][2][1]
							wDiry = gPrmtrObj[arNum][i][2][2]
							wDist = gPrmtrObj[arNum][i][2][3]
							wHgt = gPrmtrObj[arNum][i][2][4]
							/*
							format "== % %\n" wDirx wDiry
							if wDirx > 0.0 and wDiry < 0.0 then (
								format ">\n" 
								wDirx *= -1.0
								wDiry *= -1.0
							) else 
							if wDirx < 0.0 and wDiry > 0.0 then (
								format "<\n" 
								wDirx *= -1.0
								wDiry *= -1.0
							)
							*/
							
							append retn wDirx
							append retn wDiry
							append retn wDist
							append retn wHgt
							append retn pflag
							_LOG "[dg:] getVertParam() return: %\n" v1:retn
							return retn
						)
					)
				)
			)
		)
	)
	_LOG "[dg:] getVertParam() return: default\n"
	append retn 0.00000
	append retn 0.00000
	append retn 0.00000
	append retn 0.00000
	append retn 1
	return retn
)

fn vSort  obj polygon = ( 
	varr = #()
	varrCrd = #()
	varrX1 = #()
	varrX2 = #()
	retn = #()
	retnPrm = #()

	varr = (polyop.getVertsUsingFace obj polygon as array)
	
	if varr.count == 4 then (
		append varrCrd (polyop.getVert  obj varr[1])
		append varrCrd (polyop.getVert  obj varr[2])
		append varrCrd (polyop.getVert  obj varr[3])
		append varrCrd (polyop.getVert  obj varr[4])
		append varrX1 varr[1]
		local ch1 = varr[1]
		local ch2
		for i = 2 to varr.count do (
			if varrCrd[1].x == varrCrd[i].x do (
				ch2 = varr[i] 
				append varrX1 varr[i]
			)
		)

		deleteItem  varr (findItem varr ch1)
		deleteItem  varr (findItem varr ch2)
		append varrX2 varr[1]
		append varrX2 varr[2]
		if (polyop.getVert  obj varrX1[1]).x < (polyop.getVert  obj varrX2[1]).x then (
			tmp1 = varrX1[1]
			tmp2 = varrX1[2]
			varrX1[1] = varrX2[1]
			varrX1[2] = varrX2[2]
			varrX2[1] = tmp1
			varrX2[2] = tmp2
		)  
		if (polyop.getVert  obj varrX1[1]).y > (polyop.getVert  obj varrX1[2]).y then (
			tmp1 = varrX1[1]
			varrX1[1] = varrX1[2]
			varrX1[2] = tmp1
			
			tmp1 = varrX2[1]
			varrX2[1] = varrX2[2]
			varrX2[2] = tmp1
		)
		append retn (polyop.getVert  obj varrX1[1])
		append retn (polyop.getVert  obj varrX1[2])
		append retn (polyop.getVert  obj varrX2[1])
		append retn (polyop.getVert  obj varrX2[2])
		
		append retnPrm (polyop.getVert  obj varrX1[1])
		append retnPrm (getVertParam obj varrX1[1])
		append retnPrm (polyop.getVert  obj varrX1[2])
		append retnPrm (getVertParam obj varrX1[2])
		append retnPrm (polyop.getVert  obj varrX2[1])
		append retnPrm (getVertParam obj varrX2[1])
		append retnPrm (polyop.getVert  obj varrX2[2])
		append retnPrm (getVertParam obj varrX2[2])
		getFalg = getVertParam obj varrX2[2]
		append retnPrm getFalg[5]
		return retnPrm
	) else ( -- 3 verts sort
		
		firstVert = getRectVert obj polygon
		
		deleteItem  varr (findItem varr firstVert)
		crd1v = (polyop.getVert  obj firstVert)
		crd2v = (polyop.getVert  obj varr[1])
		crd3v = (polyop.getVert  obj varr[2])
		
		
		nextVert = 0
		chNorm= polyop.getFaceNormal obj polygon
		defFlag = false
		if chNorm[3] < 0.0 then (
			_LOG "[dg:] vSort() info for triangle:% %\n" v1:crd1v  v2:crd2v
			_LOG "[dg:] vSort() info for triangle: < 0\n"
			if crd1v.x < crd2v.x then (
				_LOG "[dg:] vSort() info for triangle: 1x < 2x\n"
				if crd1v.y < crd3v.y then (
					_LOG "[dg:] vSort() info for triangle: 1y < 3y\n"
					nextVert = varr[2]
					defFlag = true
				) else (
					nextVert = varr[2]
					defFlag = true
					_LOG "[dg:] vSort() info for triangle: 1y > 3y\n"
				)
			) else (
				if crd1v.x < crd3v.x then (
					_LOG "[dg:] vSort() info for triangle: 1x < 3x\n"
					if crd1v.y < crd2v.y then (
						_LOG "[dg:] vSort() info for triangle: 1y < 2y\n"
						nextVert = varr[1]
						defFlag = true
					) else (
						nextVert = varr[2]
						defFlag = true
						_LOG "[dg:] vSort() info for triangle: 1y > 2y\n"
					)
				)
			)
			-----------
			if crd1v.x > crd2v.x then (
				_LOG "[dg:] vSort() info for triangle: 1x > 2x\n"
				if crd1v.y > crd3v.y then (
					_LOG "[dg:] vSort() info for triangle: 1y > 3y\n"
					nextVert = varr[2]
					defFlag = true
				) else (
					nextVert = varr[1]
					defFlag = true
					_LOG "[dg:] vSort() info for triangle: 1y < 3y\n"
				)
			) else (
				if crd1v.x > crd3v.x then (
					_LOG "[dg:] vSort() info for triangle: 1x > 3x\n"
					if crd1v.y > crd2v.y then (
						_LOG "[dg:] vSort() info for triangle: 1y > 2y\n"
						nextVert = varr[1]
						defFlag = true
					) else (
						nextVert = varr[2]
						defFlag = true
						_LOG "[dg:] vSort() info for triangle: 1y < 2y\n"
					)
				)
			)
			
			if defFlag != true then ( 
				_LOG "[dg:] vSort() info for triangle: ERROR\n"
				_LOG "[dg:] vSort() info for triangle: varr = % firstVert = % nextVert = % (findItem varr nextVert) = %\n" v1:varr v2:firstVert v3:nextVert v4:(findItem varr nextVert)
			)
			deleteItem  varr (findItem varr nextVert)
			append retnPrm (polyop.getVert  obj firstVert)
			append retnPrm (getVertParam obj firstVert)
			append retnPrm (polyop.getVert  obj nextVert)
			append retnPrm (getVertParam obj nextVert)
			append retnPrm (polyop.getVert  obj varr[1])
			append retnPrm (getVertParam obj varr[1])
			getFalg = getVertParam obj varr[2]
			append retnPrm getFalg[5]
			
		) else (
			_LOG "[dg:] vSort() info for triangle:% %\n" v1:crd1v  v2:crd2v
			_LOG "[dg:] vSort() info for triangle: > 0\n"
			if crd1v.x < crd2v.x then (
				_LOG "[dg:] vSort() info for triangle: 1x < 2x\n"
				if crd1v.y < crd3v.y then (
					_LOG "[dg:] vSort() info for triangle: 1y < 3y\n"
					tmpV = varr[1]
					varr[1] = varr[2]
					varr[2] = tmpV
					defFlag = true
					defFlag = true
				) else (
					defFlag = true
					_LOG "[dg:] vSort() info for triangle: 1y > 3y\n"
				)
			) else (
				if crd1v.x < crd3v.x then (
					_LOG "[dg:] vSort() info for triangle: 1x < 3x\n"
					if crd1v.y < crd2v.y then (
						_LOG "[dg:] vSort() info for triangle: 1y < 2y\n"
						defFlag = true
					) else (
						tmpV = varr[1]
						varr[1] = varr[2]
						varr[2] = tmpV
						defFlag = true
						defFlag = true
						_LOG "[dg:] vSort() info for triangle: 1y > 2y\n"
					)
				)
			)
			-----------
			if crd1v.x > crd2v.x then (
				_LOG "[dg:] vSort() info for triangle: 1x > 2x\n"
				if crd1v.y > crd3v.y then (
					_LOG "[dg:] vSort() info for triangle: 1y > 3y\n"
					tmpV = varr[1]
					varr[1] = varr[2]
					varr[2] = tmpV
					defFlag = true
				) else (
					defFlag = true
					_LOG "[dg:] vSort() info for triangle: 1y < 3y\n"
				)
			) else (
				if crd1v.x > crd3v.x then (
					_LOG "[dg:] vSort() info for triangle: 1x > 3x\n"
					if crd1v.y > crd2v.y then (
						_LOG "[dg:] vSort() info for triangle: 1y > 2y\n"
						defFlag = true
					) else (
						tmpV = varr[1]
						varr[1] = varr[2]
						varr[2] = tmpV
						defFlag = true
						defFlag = true
						_LOG "[dg:] vSort() info for triangle: 1y < 2y\n"
					)
				)
			)
			if defFlag != true then ( 
				_LOG "[dg:] vSort() info for triangle: ERROR\n"
				_LOG "[dg:] vSort() info for triangle: varr = % firstVert = % nextVert = % (findItem varr nextVert) = %\n" v1:varr v2:firstVert v3:nextVert v4:(findItem varr nextVert)
			)
				
			append retnPrm (polyop.getVert  obj firstVert)
			append retnPrm (getVertParam obj firstVert)
			append retnPrm (polyop.getVert  obj varr[1])
			append retnPrm (getVertParam obj varr[1])
			append retnPrm (polyop.getVert  obj varr[2])
			append retnPrm (getVertParam obj varr[2])
			getFalg = getVertParam obj varr[2]
			append retnPrm getFalg[5]
		)
		return retnPrm
	)
)

rollout rl_GTAwaterIO_help "GTA Water IO - About" width:278 height:230 (

	button btn_close "close" pos:[103,202] width:69 height:22
	label lbl1 "GTA Water IO 1.0b" pos:[72,12] width:109 height:17
	label lbl6 "Script features:" pos:[11,43] width:80 height:18
	label lbl7 "- EXPORT and IMPORT water (water.dat)" pos:[13,64]  height:18
	label lbl9 "- EXPORT and IMPORT water parameters" pos:[13,83]  height:18
	label lbl10 "- built-in utilities for setting up of the water plane" pos:[13,102]  
	label lbl11 "_____________" pos:[8,130] width:179 height:18
	label lbl2 "Author:" pos:[10,149] width:42 height:18
	label lbl4 "Specially for the" pos:[10,166] width:81 height:18
	HyperLink SUPPORT "SUPPORT" pos:[10,184]  height:18 address:"https://vk.com/goldscripts" color:(color 10 147 225) hovercolor:(color 94 198 255) visitedcolor:(color 10 147 225)
	HyperLink toCRime_team "CRime team" pos:[96,166]  height:18 address:"https://vk.com/crime_offcial" color:(color 10 147 225) hovercolor:(color 94 198 255) visitedcolor:(color 10 147 225)
	HyperLink Goldfish "Goldfish" pos:[51,149] height:18 address:"https://vk.com/vk.goldfish" color:(color 10 147 225) hovercolor:(color 94 198 255) visitedcolor:(color 10 147 225)
	label lbl12 "18 Mar 2019" pos:[200,180] width:70 height:18

	on btn_close pressed  do(
		DestroyDialog rl_GTAwaterIO_help
	)		
)
			
	rollout rl_GTAwaterIO ""  width:200 (
		label lbl_head "GTA water IO 1.0b" pos:[50,1]
		groupBox grp1 "Tools" width:180 height:76 align:#center
		button wat_fix "FIX plane" width:68 height:41 pos:[20,46] toolTip:"Alignment of the water geometry mesh and vertex coordinates rounding"
		label lbl_spe "Stitch edge:"  pos:[108,28]
		button wat_stitch_a "A -> B" width:80 height:19 pos:[100,46] toolTip:"stitch the two selected edges"
		button wat_stitch_b "B -> A" width:80 height:19 pos:[100,68] toolTip:"stitch the two selected edges"

		------
		local MouseButtons = dotnetclass "System.Windows.Forms.MouseButtons"
		local bgColor = (dotnetclass "System.Drawing.Color").FromArgb 255 80 80 80
		local circleColor = (dotnetclass "System.Drawing.Color").FromArgb 255 150 150 150
		local pointColor = (dotnetclass "System.Drawing.Color").FromArgb 255 0 255 150
		local lineColor = (dotnetclass "System.Drawing.Color").FromArgb 150 0 255 150
		local circlePen = dotnetobject "System.Drawing.Pen" circleColor 1
		local pointBrush = dotnetobject "System.Drawing.SolidBrush" circleColor
		local pointRadius = 8
		local _g
		
		----
		local font  = dotnetobject "System.Drawing.Font" "Arial" 8
		local font2  = dotnetobject "System.Drawing.Font" "Arial" 10
		local StringFormat  = dotnetobject "System.Drawing.StringFormat"
		local color_green = (dotnetclass "System.Drawing.Color").FromArgb 255 76 255 0
		local coordOk = dotnetobject "System.Drawing.SolidBrush" color_green
		
		local color_red = (dotnetclass "System.Drawing.Color").FromArgb 255 255 81 81
		local color_blue = (dotnetclass "System.Drawing.Color").FromArgb 255 50 108 255
		local coord = dotnetobject "System.Drawing.SolidBrush" color_red
		local coord2 = dotnetobject "System.Drawing.SolidBrush" color_green
		
		local coordTo = dotnetobject "System.Drawing.SolidBrush" color_blue
		local lineclr = dotnetobject "System.Drawing.Pen" color_red 1
		local lineclr2 = dotnetobject "System.Drawing.Pen" color_blue 1
		local lineclr3 = dotnetobject "System.Drawing.Pen" circleColor 1
		local linePen = dotnetobject "System.Drawing.Pen" color_green 2
		
		local directionPickerChangedCallback
		
		groupBox grp3 "Water parameters" width:180 height:336 pos:[10,100]
		button b_help "?" width:20 height:18 pos:[170,4] toolTip:"About"
		label wpq1 "water UV direction: (experimental !)"  pos:[20,120]
		label wpq2 "speed:"  pos:[130,155]
		dotnetcontrol directionPicker "System.Windows.Forms.PictureBox" pos:[20, 135] width:100 height:50
		spinner sp_wpDirs ""  width:50 height:16 pos:[130,170] range:[0.0,100.0,0.0] type:#float 
		edittext ed_wpdir1 "" fieldWidth:78 labelOnTop:true pos:[20,190]
		edittext ed_wpdir2 "" fieldWidth:78 labelOnTop:true pos:[102,190]
		slider sl_wDist "unk height"  ticks:0 range:[-10.0,10.0,0.0] width:80 pos:[20,210]
		slider sl_wH "wave height"  ticks:0 range:[0.0,10.0,0.0] width:80 pos:[100,210]
		spinner sp_wpDist1 ""  width:68  pos:[20,255] range:[-10.0,10.0,0.0] type:#float 
		spinner sp_wpH2 ""  width:68 pos:[102,255] range:[0.0,10.0,0.0] type:#float 
		label wpf1 "Water type FLAG:"  pos:[20,280]
		radiobuttons copy_type  labels:#( "Default   /   Invisible", "Default   /   Visible", "Shallow  /   Invisible", "Shallow  /   Visible") default: 2
		button wpGet "GET" width:70 height:22 pos:[20,364] 
		button wpSet "SET" width:70 height:22 pos:[110,364] 
		button wpRes "reset All"  width:160 height:18 pos:[20,392]  toolTip: "reset default water settings"
		checkbox ch_log1 "enable log (F11)" pos:[20,416] checked:false
		
		label lbl_sp "" 
		groupBox grp2 "WATER.DAT option" width:180 height:70 pos:[10,442]
		button wload "LOAD" width:70 height:40 pos:[20,462] toolTip:"Load water.dat from GTA directory"
		button wexp "EXPORT" width:70 height:40 pos:[110,462] toolTip:"Export water geometry to water.dat in GTA directory"
		
		on ch_log1 changed exp do (
			if exp == true then (
					clearListener()
				if ch_log1.checked == true then (
					format "\n===========================================\n"
					format ":            GTA Water IO LOG             :\n===========================================\n" 
					format "version 1.0b\n"
					ver = get3dsMaxVersionAsString()
					format "Max version: %\n" ver
				)
			)
		)
		
		fn directionPicker_MouseDown e =
		(
			if e.Button == MouseButtons.Left then
			(
				local w = directionPicker.Width/2.0
				local h = directionPicker.Height
				local cx = w / 2.0
				local cy = h / 2.0
				local px = (e.X - cx) / ((w - 20) / 2.0)
				local py = (e.Y - cy) / ((h - 20) / 2.0)
				
				if length [px, py] > 0.1 then
				(
					local n = normalize [px, py]
					px = n.x
					py = n.y
				)
				
				directionPicker.Tag.X = px
				directionPicker.Tag.Y = py
				
				if directionPickerChangedCallback != undefined then
					directionPickerChangedCallback [px, py]
			)
			
			if e.Button == MouseButtons.Middle then
			(
				directionPicker.Tag.X = 0
				directionPicker.Tag.Y = 0
				
				if directionPickerChangedCallback != undefined then
					directionPickerChangedCallback [0, 0]
			)
		)
		
		fn redrawDirectionPicker =
		(
			_g.Clear bgColor
			_g.DrawEllipse circlePen 15 15 ((directionPicker.Width)/2.0 - 30) (directionPicker.Height - 30)
			
			local w = directionPicker.Width/2.0
			local h = directionPicker.Height
			local cx = w / 2.0
			local cy = h / 2.0
			
			local px = cx + directionPicker.Tag.X * ((w - 5) / 2.0)
			local py = cy + directionPicker.Tag.Y * ((h - 5) / 2.0)

			_g.DrawLine linePen cx cy px py
			_g.FillEllipse pointBrush ((directionPicker.Width)/2.0 - 28.8) (directionPicker.Height - 28.8) pointRadius pointRadius

			_g.DrawLine lineclr2 70.0 42.0 70.0 7.0
			_g.DrawLine lineclr 54.0 25.0 86.0 25.0
			_g.DrawLine lineclr3 49.0 47.0 49.0 2.0
			_g.DrawString "x" Font coord2 83.0 27.0 StringFormat
			_g.DrawString "y" Font coord2 60.0 1.0 StringFormat
			
			_g.DrawString ">" Font2 coord 82.0 17.0 StringFormat
			_g.DrawString "^" Font2 coordTo 65.28 2.0 StringFormat
			
			directionPicker.Refresh()
		)
		
		fn getDirPickerValue = (
			x = directionPicker.Tag.X
			y = directionPicker.Tag.Y *= -1.0
			return [x,y]
		)
		
		fn setDirectionPickerValue p2 =
		(
			directionPicker.Tag.X = p2.x*10
			directionPicker.Tag.Y = p2.y*10
			redrawDirectionPicker()
		)
		
		fn myFunc p2 = (
			res = [p2.x,p2.y*-1.0]
			--print res
			if sp_wpDirs.value != 0.0 then (
				ed_wpdir1.text = (formattedPrint (res.x * sp_wpDirs.value) format:".5f") 
				ed_wpdir2.text = (formattedPrint (res.y * sp_wpDirs.value) format:".5f")
			) else (
				ed_wpdir1.text = (formattedPrint 0 format:".5f")
				ed_wpdir2.text = (formattedPrint 0 format:".5f")
			)
		)

		
		------
		on rl_GTAwaterIO open do (
			gPrmtrObj = #()
			directionPicker.Image = dotnetobject "System.Drawing.Bitmap" directionPicker.Width directionPicker.Height
			directionPicker.Tag = dotnetobject "System.Drawing.PointF" 0 -1.0
			_g = (dotnetclass "System.Drawing.Graphics").FromImage directionPicker.Image
			_g.SmoothingMode = (dotnetclass "System.Drawing.Drawing2D.SmoothingMode").AntiAlias
			redrawDirectionPicker()
			directionPickerChangedCallback = myFunc
			
			ed_wpdir1.text = (formattedPrint 0.0 format:".5f")
			ed_wpdir2.text = (formattedPrint 0.0 format:".5f")
			ch_log = ch_log1
			clearListener()
			if ch_log1.checked == true then (
				format "\n===========================================\n"
			format ":            GTA Water IO LOG             :\n===========================================\n" 
			format "version 1.0b\n"
			ver = get3dsMaxVersionAsString()
			format "Max version: %\n" ver
			)
		)
		
		on b_help pressed do (
			try (DestroyDialog rl_GTAwaterIO_help) catch()
			createDialog rl_GTAwaterIO_help
		)
		
		on wpGet pressed do (
			if gPrmtrObj.count >= 1 then (
				_LOGprocess "\n[dg:] process: GET\n"
				if selection.count == 1 then (
					obj = selection[1]
					if classof obj != Editable_Poly then convertToPoly obj
					if subObjectLevel == 1 then (
						vertArray = polyop.getVertSelection obj as array
						if vertArray.count == 1 then (
							vertObj = vertArray[1]
							for ObjI = 1 to gPrmtrObj.count by 3 do (
								if obj == gPrmtrObj[ObjI] then (
									arNum = ObjI + 2
									for i = 1 to gPrmtrObj[arNum].count  do (
										if gPrmtrObj[arNum][i] != #() then (
											if gPrmtrObj[arNum][i][1] == vertObj then (
												wDirx = gPrmtrObj[arNum][i][2][1]
												wDiry = gPrmtrObj[arNum][i][2][2]
												wDist = gPrmtrObj[arNum][i][2][3]
												wHgt = gPrmtrObj[arNum][i][2][4]
												
												vector = (formattedPrint (sqrt ((pow wDirx 2) + (pow wDiry 2))) format:".1f") as float
												_LOG "[dg:] wpGet[] info: wDirx = % wDiry = % wDist = % wHgt = % " v1:wDirx v2:wDiry v3:wDist v4:wHgt
												_LOG "vector = %\n" v1:vector
												ed_wpdir1.text = (formattedPrint wDirx format:".5f")
												ed_wpdir2.text = (formattedPrint wDiry format:".5f")
												sp_wpDist1.value = wDist
												sp_wpH2.value = wHgt
												sl_wDist.value = wDist
												sl_wH.value = wHgt
												sp_wpDirs.value = vector
												if vector != 0.0 then (
													if vector > 0.1 then (
														delta = vector 
														if delta > 0.0 then (
															tmp1 = wDirx 
															tmp1 /= delta
															tmp1 /= 10.0
															tmp2 = wDiry 
															tmp2 /= delta
															tmp2 /= 10.0
															wDirx = tmp1
															wDiry = tmp2
														) else (
															tmp1 = wDirx 
															tmp1 *= delta
															tmp1 /= 10.0
															tmp2 = wDiry 
															tmp2 *= delta
															tmp2 /= 10.0
															wDirx = tmp1
															wDiry = tmp2
														)
													)
												) else (
													wDirx = 0.0
													wDiry = 0.1
												)
												setDirectionPickerValue [wDirx,wDiry*-1.0]
											)
										)
									)
								)
							)
						) else messagebox "Warning:\nfor operation [GET] you can select only 1 vert!" title: "GTA Water IO"
					) else (
						for ObjI = 1 to gPrmtrObj.count by 3 do (
							if obj == gPrmtrObj[ObjI] then (
								copy_type.state = (gPrmtrObj[ObjI+1]+1)
							)
						)
					)
				)							
			)
		)
		
		on wpRes pressed do (
			if queryBox "Are you sure you want to clear all data?" beep:true title: "GTA Water IO" then (
				clearListener()
				if ch_log1.checked == true then (
					format "\n===========================================\n"
					format ":            GTA Water IO LOG             :\n===========================================\n" 
					format "version 1.0b\n"
					ver = get3dsMaxVersionAsString()
					format "Max version: %\n" ver
				)
				_LOGprocess "\n[dg:] process: RESET\n"
				gPrmtrObj = #()
				gPrmtrNumVert = #()
				sp_wpDirs.value = 0.0
				copy_type.state  = 2
				ed_wpdir1.text = (formattedPrint (directionPicker.Tag.X * sp_wpDirs.value) format:".5f")
				ed_wpdir2.text = (formattedPrint ((directionPicker.Tag.Y * -1.0) * sp_wpDirs.value) format:".5f")
				sl_wDist.value = 0.0
				sl_wH.value = 0.0
				sp_wpDist1.value = 0.0
				sp_wpH2.value = 0.0
			)
		)   
		
		on wpSet pressed do (
			if selection.count >= 1 then (
				_LOGprocess "\n[dg:] process: SET\n"
				for obj in selection do (
					-- search obj in arr
					skip = false
					if classof obj != Editable_Poly then convertToPoly obj
					for ObjI = 1 to gPrmtrObj.count by 3 do (
						
						if obj == gPrmtrObj[ObjI] then (
							_LOG "\n[dg:] wpSet[] info: object is found! % \n" v1:obj
							skip = true
							arNum = ObjI + 2
							if subObjectLevel == 1 then (
								gPrmtrObj[arNum-1] = (copy_type.state - 1)
								vertArray = polyop.getVertSelection obj as array
								_LOG "[dg:] wpSet[] info: Vertex selected = %\n" v1:(vertArray.count)
								if vertArray.count >= 1 then (
									for vertObj in vertArray do (
										local indxSrch = 0
										gPrmtrNumVert = #()
										for i = 1 to gPrmtrObj[arNum].count  do (
											if gPrmtrObj[arNum][i] != #() then (
												if gPrmtrObj[arNum][i][1] == vertObj then (
													indxSrch = i
													--_LOG "[dg:] wpSet[] info: Vertex % is found\n" v1:i
												)
											)
										)
										if indxSrch != 0 then (
											_LOG "[dg:] wpSet[] info: add REPLACE custom data for % = %\n" v1:vertObj v2:[ed_wpdir1.text as float,ed_wpdir2.text as float, sp_wpDist1.value, sp_wpH2.value]
											gPrmtrObj[arNum][indxSrch][1] = vertObj
											gPrmtrObj[arNum][indxSrch][2] = [ed_wpdir1.text as float,ed_wpdir2.text as float, sp_wpDist1.value, sp_wpH2.value]
										) else (
											
											append gPrmtrNumVert vertObj
											append gPrmtrNumVert [ed_wpdir1.text as float,ed_wpdir2.text as float, sp_wpDist1.value, sp_wpH2.value]
											append gPrmtrObj[arNum] gPrmtrNumVert
											_LOG "[dg:] wpSet[] info: add NEW custom data obj for % = %\n" v1:gPrmtrNumVert[1] v2:gPrmtrNumVert
										)
									) 
								)
							) else ( -- replace flag only
								/*=====================================================================*/
								vertArray = #()
								for ivt = 1 to obj.numverts do append vertArray ivt
								for vertObj in vertArray do (
									local indxSrch = 0
									gPrmtrNumVert = #()
									for i = 1 to gPrmtrObj[arNum].count  do (
										if gPrmtrObj[arNum][i] != #() then (
											if gPrmtrObj[arNum][i][1] == vertObj then (
												indxSrch = i
											)
										)
									)
									if indxSrch != 0 then (
										_LOG "[dg:] wpSet[] info: add REPLACE data for % = %\n" v1:indxSrch v2:[ed_wpdir1.text as float,ed_wpdir2.text as float, sp_wpDist1.value, sp_wpH2.value]
										gPrmtrObj[arNum][indxSrch][1] = vertObj
										gPrmtrObj[arNum][indxSrch][2] = [ed_wpdir1.text as float,ed_wpdir2.text as float, sp_wpDist1.value, sp_wpH2.value]
									) else (
										
										append gPrmtrNumVert vertObj
										append gPrmtrNumVert [ed_wpdir1.text as float,ed_wpdir2.text as float, sp_wpDist1.value, sp_wpH2.value]
										append gPrmtrObj[arNum] gPrmtrNumVert
										_LOG "[dg:] wpSet[] info: add NEW data obj for = %\n" v1:gPrmtrNumVert
									)
								) 
								gPrmtrObj[arNum-1] = (copy_type.state - 1)
							)
						)
					)
					_LOG "[dg:] wpSet[] info: skip = %\n" v1:skip
					if skip == false then (
						---
						_LOG "\n[dg:] wpSet[] info: object %\n" v1:obj
						append gPrmtrObj obj
						append gPrmtrObj (copy_type.state - 1)
						if subObjectLevel == 1 then (
							vertArray = polyop.getVertSelection obj as array
							_LOG "[dg:] wpSet[] info: Vertex selected = %\n" v1:(vertArray.count)
							if vertArray.count >= 1 then (
								append gPrmtrObj #()
								for vertObj in vertArray do (
									gPrmtrNumVert = #()
									append gPrmtrNumVert vertObj
									append gPrmtrNumVert [ed_wpdir1.text as float,ed_wpdir2.text as float, sp_wpDist1.value, sp_wpH2.value]
									append gPrmtrObj[gPrmtrObj.count] gPrmtrNumVert
									_LOG "[dg:] wpSet[] info: add NEW custom data for % = %\n" v1:vertObj v2:[ed_wpdir1.text as float,ed_wpdir2.text as float, sp_wpDist1.value, sp_wpH2.value]
								)
							)
						) else (
							--_LOG "[dg:] wpSet[] info: add new\n"
							append gPrmtrObj #()
							vertArray = #()
							arNum = gPrmtrObj.count
							for ivt = 1 to obj.numverts do append vertArray ivt
							for vertObj in vertArray do (
								local indxSrch = 0
								gPrmtrNumVert = #()
								for i = 1 to gPrmtrObj[arNum].count  do (
									if gPrmtrObj[arNum][i] != #() then (
										if gPrmtrObj[arNum][i][1] == vertObj then (
											indxSrch = i
										)
									)
								)
								if indxSrch != 0 then (
									_LOG "[dg:] wpSet[] info: add REPLACE data for % = %\n" v1:vertObj v2:[ed_wpdir1.text as float,ed_wpdir2.text as float, sp_wpDist1.value, sp_wpH2.value]
									gPrmtrObj[arNum][indxSrch][1] = vertObj
									gPrmtrObj[arNum][indxSrch][2] = [ed_wpdir1.text as float,ed_wpdir2.text as float, sp_wpDist1.value, sp_wpH2.value]
								) else (
									
									append gPrmtrNumVert vertObj
									append gPrmtrNumVert [ed_wpdir1.text as float,ed_wpdir2.text as float, sp_wpDist1.value, sp_wpH2.value]
									append gPrmtrObj[arNum] gPrmtrNumVert
									_LOG "[dg:] wpSet[] info: add NEW data for % = %\n" v1:vertObj v2:gPrmtrNumVert
								)
							)
						)
					)
				)
				_LOGar "[dg:] wpSet[] ARRAY info:\n" v1:gPrmtrObj
			)
		)
			
		on sl_wDist changed dist do (
			sp_wpDist1.value = dist
		)
		
		on sl_wH changed dist do (
			sp_wpH2.value = dist
		)
		
		on sp_wpDist1 changed dist do (
			sl_wDist.value = dist 
		)
		
		on sp_wpH2 changed dist do ( 
			sl_wH.value = dist
		)
		
		on sp_wpDirs changed dist do (
			tmp1 = directionPicker.Tag.X * sp_wpDirs.value
			tmp2 = (directionPicker.Tag.Y * -1.0) * sp_wpDirs.value
			ed_wpdir1.text = (formattedPrint tmp1 format:".5f")
			ed_wpdir2.text = (formattedPrint tmp2 format:".5f")
			wDirx = tmp1
			wDiry = tmp2 
			vector = (sqrt ((pow wDirx 2) + (pow wDiry 2)))
			if vector != 0.0 then (
				if vector > 0.1 then (
					delta = vector - 0.1
					if delta > 0.0 then (
						tmp1 = wDirx / 10.0
						tmp1 /= delta
						tmp2 = wDiry / 10.0
						tmp2 /= delta
						wDirx = tmp1
						wDiry = tmp2
					) else (
						tmp1 = wDirx / 10.0
						tmp1 *= delta
						tmp2 = wDiry / 10.0
						tmp2 *= delta
						wDirx = tmp1
						wDiry = tmp2
					)
				)
			) else (
				wDirx = 0.0
				wDiry = 0.1
			)
		)
		
		on ed_wpdir1 entered  txt do (
			if sp_wpDirs.value == 0.0 then ed_wpdir1.text = (formattedPrint 0.0 format:".5f") 
			else ed_wpdir1.text = (formattedPrint (directionPicker.Tag.X * sp_wpDirs.value) format:".5f")
		)
		
		on ed_wpdir2 entered  txt do (
			if sp_wpDirs.value == 0.0 then ed_wpdir2.text = (formattedPrint 0.0 format:".5f") 
			else ed_wpdir2.text = (formattedPrint ((directionPicker.Tag.Y * -1.0) * sp_wpDirs.value) format:".5f")
		)
		
		on directionPicker MouseDown e do (
			directionPicker_MouseDown e
			redrawDirectionPicker()
		)
		
		on directionPicker MouseMove e do (
			if e.Button == MouseButtons.Left then
			(
				directionPicker_MouseDown e
				redrawDirectionPicker()
			)
		)

		on wexp pressed do (
			if selection.count >= 1 then (
				chExp = true
				for wObj in selection do (
					if superclassof wObj != GeometryClass then chExp = false
				)
				if chExp == true then (
					disableSceneRedraw()
					try (
						local wIOrecentPath = (getINISetting (scriptsPath + "\gtawaterio.dat") "recent" "patch" )
						if wIOrecentPath != "" then TXT = getSaveFileName types:"SA Water (*.dat)|*.dat"  historyCategory: wIOrecentPath
						else	TXT = getSaveFileName types:"SA Water (*.dat)|*.dat" 
						if TXT != undefined then (
							_LOGprocess "\n[dg:] process: EXPORT\n"
							(setINISetting (scriptsPath + "\gtawaterio.dat") "recent" "patch" TXT )
							txt = createFile (TXT)
							format "processed\n" to:txt
							for obj in selection do (
								if classof obj != Editable_Poly then convertToPoly obj
								nFs = (polyop.getNumFaces obj)
								if nFs > 1 then (
									for fc = 1 to nFs do (
										vChk = ( polyop.getVertsUsingFace obj fc as array)
										if vChk.count == 4 then write4To txt (vSort obj fc)
										else write3To txt (vSort obj fc)
									)
								) else (
									vChk = ( polyop.getVertsUsingFace obj 1 as array)
									if vChk.count == 4 then write4To txt (vSort obj 1)
									else write3To txt (vSort obj 1)
								)
							) --end for obj in sel
							close txt
							_LOGprocess "[dg:] process: EXPORT END\n"
						)
					) catch (
						messagebox "water export unknown error!" title: "GTA Water IO"
						_LOG "[dg:] water export unknown error\n"
						enableSceneRedraw()
					)
					enableSceneRedraw()
					redrawViews()
				)
			)
		)
		
		on wload pressed do (
			local wIOrecentPath = (getINISetting (scriptsPath + "\gtawaterio.dat") "recent" "patch" )
			if wIOrecentPath != "" then TXT = getOpenFileName types:"SA Water (*.dat)|*.dat"  historyCategory: wIOrecentPath
			else	TXT = getOpenFileName types:"SA Water (*.dat)|*.dat" 
			if TXT != undefined then (
				txt = openFile TXT
				n = 0
				max select none
				local gObj
				clearListener()
				if ch_log1.checked == true then (
					format "\n===========================================\n"
					format ":            GTA Water IO LOG             :\n===========================================\n" 
					format "version 1.0b\n"
					ver = get3dsMaxVersionAsString()
					format "Max version: %\n" ver
				)
				
				_LOGprocess "\n[dg:] process: LOAD\n"
				undo off (
					disableSceneRedraw()
					try (
						local v1
						local v2
						local v3
						local v4
						local newObj0
						local newObj1
						local newObj2
						local newObj3
						
						gPrmtrObj = #()
						loadcnt = 0
						loadcntAll = 0
						while not eof txt do (
							line = readline txt
							loadcntAll +=1
							if line != "" then (
								data = filterString line " 	"
								data1 = data
								flagErr = false
								if (data[1] != "#")and(data[1] != "processed") then (
									loadcnt +=1
									v1 = [0,0,0]
									v2 = [0,0,0]
									v3 = [0,0,0]
									v4 = [0,0,0]
									chNumvrt = 0
									v1.x = ((data[1]) as float)
									v1.y = ((data[2]) as float)
									v1.z = ((data[3]) as float)
									v1prm1 = ((data[4]) as float)
									v1prm2 = ((data[5]) as float)
									v1prm3 = ((data[6]) as float)
									v1prm4 = ((data[7]) as float)
									
									v2.x = ((data[8]) as float)
									v2.y = ((data[9]) as float)
									v2.z = ((data[10]) as float)
									v2prm1 = ((data[11]) as float)
									v2prm2 = ((data[12]) as float)
									v2prm3 = ((data[13]) as float)
									v2prm4 = ((data[14]) as float)
									
									v3.x = ((data[15]) as float)
									v3.y = ((data[16]) as float)
									v3.z = ((data[17]) as float)
									v3prm1 = ((data[18]) as float)
									v3prm2 = ((data[19]) as float)
									v3prm3 = ((data[20]) as float)
									v3prm4 = ((data[21]) as float)
									
									if data.count != 22 then (
										if data.count == 29 then (
											_LOG "[dg:] wload[] info: loadcnt = % read line 4 verts\n" v1:loadcnt
											
											chNumvrt = 4
											v4.x = ((data[22]) as float)
											v4.y = ((data[23]) as float)
											v4.z = ((data[24]) as float)
											v4prm1 = ((data[25]) as float)
											v4prm2 = ((data[26]) as float)
											v4prm3 = ((data[27]) as float)
											v4prm4 = ((data[28]) as float)
											pFlag = ((data[29]) as integer)
											
											theObj = mesh numverts:4 numfaces:0
											converttopoly theObj
											polyop.setVert theObj 1 v1
											polyop.setVert theObj 2 v2
											polyop.setVert theObj 3 v3
											polyop.setVert theObj 4 v4
											polyop.createPolygon theObj  #(1,2,4,3)
										) else flagErr = true									
										
									) else (
										_LOG "[dg:] wload[] info: loadcnt = % read line 3 verts\n" v1:loadcnt
										chNumvrt = 3
										pFlag = ((data[22]) as integer)
										theObj = mesh numverts:3 numfaces:0
										converttopoly theObj
										polyop.setVert theObj 1 v1
										polyop.setVert theObj 2 v2
										polyop.setVert theObj 3 v3
										polyop.createPolygon theObj  #(1,3,2)
									)
									
									local defObj
									local defV1
									local defV2
									local defV3
									local defV4
									local newObj
									local defObjIndex = 0
									
									if flagErr == false then (
										if pFlag == 0 then (
											_LOG "[dg:] wload[] info: flag 0\n"
											if newObj0 == undefined then (
												newObj0 = theObj 
												_LOG "[dg:] wload[] info:  create obj\n"
											) else (
												polyop.attach newObj0 theObj
												_LOG "[dg:] wload[] info:  attach to obj\n"
											)
											for cnt = 2 to gPrmtrObj.count by 3 do (
												if gPrmtrObj[cnt] == pFlag then defObjIndex = cnt+1
											)
											_LOG "[dg:] wload[] info:  defObjIndex = %\n" v1:defObjIndex
											newObj = newObj0
										)
										if pFlag == 1 then (
											_LOG "[dg:] wload[] info: flag 1\n"
											if newObj1 == undefined then (
												newObj1 = theObj 
												_LOG "[dg:] wload[] info:  create obj\n"
											) else (
												polyop.attach newObj1 theObj
												_LOG "[dg:] wload[] info:  attach to obj\n"
											)
											for cnt = 2 to gPrmtrObj.count by 3 do (
												if gPrmtrObj[cnt] == pFlag then defObjIndex = cnt+1
											)
											_LOG "[dg:] wload[] info:  defObjIndex = %\n" v1:defObjIndex
											newObj = newObj1
										)
										if pFlag == 2 then (
											_LOG "[dg:] wload[] info: flag 2\n"
											if newObj2 == undefined then (
												newObj2 = theObj 
												_LOG "[dg:] wload[] info:  create obj\n"
											) else (
												polyop.attach newObj2 theObj
												_LOG "[dg:] wload[] info:  attach to obj\n"
											)
											for cnt = 2 to gPrmtrObj.count by 3 do (
												if gPrmtrObj[cnt] == pFlag then defObjIndex = cnt+1
											)
											_LOG "[dg:] wload[] info:  defObjIndex = %\n" v1:defObjIndex
											newObj = newObj2
										)
										if pFlag == 3 then (
											_LOG "[dg:] wload[] info: flag 3\n"
											if newObj3 == undefined then (
												newObj3 = theObj 
												_LOG "[dg:] wload[] info:  create obj\n"
											) else (
												polyop.attach newObj3 theObj
												_LOG "[dg:] wload[] info:  attach to obj\n"
											)
											for cnt = 2 to gPrmtrObj.count by 3 do (
												if gPrmtrObj[cnt] == pFlag then defObjIndex = cnt+1
											)
											_LOG "[dg:] wload[] info:  defObjIndex = %\n" v1:defObjIndex
											newObj = newObj3
										)
										
										for i = 1 to newObj.numverts do (
											vcrd = polyop.getVert newObj i
											if vcrd == v1 then defV1 = i
											if vcrd == v2 then defV2 = i
											if vcrd == v3 then defV3 = i
											if vcrd == v4 then defV4 = i
										)
										
										if defObjIndex != 0 then (
											_LOG "[dg:] wload[] info: add verts data to obj\n"
											-- 1st verts
											gPrmtrNumVert = #()
											append gPrmtrNumVert defV1
											append gPrmtrNumVert [v1prm1,v1prm2,v1prm3,v1prm4]
											append gPrmtrObj[defObjIndex] gPrmtrNumVert
											-- 2st verts
											gPrmtrNumVert = #()
											append gPrmtrNumVert defV2
											append gPrmtrNumVert [v2prm1,v2prm2,v2prm3,v2prm4]
											append gPrmtrObj[defObjIndex] gPrmtrNumVert
											-- 3st verts
											gPrmtrNumVert = #()
											append gPrmtrNumVert defV3
											append gPrmtrNumVert [v3prm1,v3prm2,v3prm3,v3prm4]
											append gPrmtrObj[defObjIndex] gPrmtrNumVert
											
											if chNumvrt == 4 then (
											-- 4st verts
												gPrmtrNumVert = #()
												append gPrmtrNumVert defV4
												append gPrmtrNumVert [v4prm1,v4prm2,v4prm3,v4prm4]
												append gPrmtrObj[defObjIndex] gPrmtrNumVert
											)
										) else (
											_LOG "[dg:] wload[] info: create new verts data obj\n"
											append gPrmtrObj newObj
											append gPrmtrObj pFlag
											append gPrmtrObj #()
											defObjIndex = gPrmtrObj.count
											
											-- 1st verts
											gPrmtrNumVert = #()
											append gPrmtrNumVert defV1
											append gPrmtrNumVert [v1prm1,v1prm2,v1prm3,v1prm4]
											append gPrmtrObj[defObjIndex] gPrmtrNumVert
											-- 2st verts
											gPrmtrNumVert = #()
											append gPrmtrNumVert defV2
											append gPrmtrNumVert [v2prm1,v2prm2,v2prm3,v2prm4]
											append gPrmtrObj[defObjIndex] gPrmtrNumVert
											-- 3st verts
											gPrmtrNumVert = #()
											append gPrmtrNumVert defV3
											append gPrmtrNumVert [v3prm1,v3prm2,v3prm3,v3prm4]
											append gPrmtrObj[defObjIndex] gPrmtrNumVert
											
											if chNumvrt == 4 then (
											-- 4st verts
												gPrmtrNumVert = #()
												append gPrmtrNumVert defV4
												append gPrmtrNumVert [v4prm1,v4prm2,v4prm3,v4prm4]
												append gPrmtrObj[defObjIndex] gPrmtrNumVert
											)
										)
									) else (
										_LOG "[dg:] wload[] ERROR read line: % (pos %)\n" v1:loadcnt v2:loadcntAll
										flagErr = false
									)
								)
							)							
						)
					
						objColor = (color 114 184 216)
							
						if newObj0 != undefined then (
							update newObj0
							newObj0.wirecolor = objColor
							CenterPivot newObj0
							ResetXForm newObj0
							convertToPoly newObj0
						)
						if newObj1 != undefined then (
							update newObj1
							newObj1.wirecolor = objColor
							CenterPivot newObj1
							ResetXForm newObj1
							convertToPoly newObj1
						)
						if newObj2 != undefined then (
							update newObj2
							newObj2.wirecolor = objColor
							CenterPivot newObj2
							ResetXForm newObj2
							convertToPoly newObj2
						)
						if newObj3 != undefined then (
							update newObj3
							newObj3.wirecolor = objColor
							CenterPivot newObj3
							ResetXForm newObj3
							convertToPoly newObj3
						)
					) catch (
						enableSceneRedraw()
						messagebox "water load unknown error!" title: "GTA Water IO"
						_LOG "[dg:] water load unknown error\n"
					)
					_LOGar "[dg:] wload[] ARRAY info:\n" v1:gPrmtrObj
					try (close txt) catch()
					enableSceneRedraw()
					redrawViews()
				)
				_LOGprocess "[dg:] process: LOAD END\n"
			)
		)
			
		on wat_stitch_b pressed do (
			if subObjectLevel == 2 then (
				try (
					obj = selection[1]
					selEdge = (getEdgeSelection obj as array)
					if selEdge.count == 2 then (
						_LOGprocess "\n[dg:] process: STITCH B -> A\n"
						undo on (
							movedge1 = ""
							movedge2= ""
							arrV1 = (polyop.getVertsUsingEdge obj selEdge[1] as array)
							arrV2 = (polyop.getVertsUsingEdge obj selEdge[2] as array)
							cord1Ed1 = polyop.getVert obj arrV1[1]
							cord2Ed1 = polyop.getVert obj arrV1[2]
							cord1Ed2 = polyop.getVert obj arrV2[1]
							cord2Ed2 = polyop.getVert obj arrV2[2]
							if cord1Ed1.x == cord2Ed1.x then movedge1 = "x"
							else if cord1Ed2.y == cord2Ed2.y then movedge1 = "y"
								else movedge1 = "err"
							if movedge1 != "err" then (
								if movedge1 == "x" then (
									--move to X
									cord1Ed1.x = cord1Ed2.x 
									cord2Ed1.x = cord1Ed2.x 
								) else (
									--move to Y
									cord1Ed1.y = cord1Ed2.y
									cord2Ed1.y = cord2Ed2.y
								)
								polyop.setVert obj arrV1[1] cord1Ed1
								polyop.setVert obj arrV1[2] cord2Ed1
							) else _LOG "[dg:] wat_stitch_b[] ERROR Stitch a edges\n"
						)
					) else messagebox "you mast select 2 edge only" title: "GTA Water IO"
				) catch messagebox "edge stitch error!" title: "GTA Water IO"
			)
		)
		
		on wat_stitch_a pressed do (
			if subObjectLevel == 2 then (
				try (
					obj = selection[1]
					if classof obj != Editable_poly then convertToPoly obj
					selEdge = (getEdgeSelection obj as array)
					if selEdge.count == 2 then (
						_LOGprocess "\n[dg:] process: STITCH A -> B\n"
						undo on (
							movedge1 = ""
							movedge2= ""
							arrV1 = (polyop.getVertsUsingEdge obj selEdge[1] as array)
							arrV2 = (polyop.getVertsUsingEdge obj selEdge[2] as array)
							cord1Ed1 = polyop.getVert obj arrV1[1]
							cord2Ed1 = polyop.getVert obj arrV1[2]
							cord1Ed2 = polyop.getVert obj arrV2[1]
							cord2Ed2 = polyop.getVert obj arrV2[2]
							if cord1Ed1.x == cord2Ed1.x then movedge1 = "x"
							else if cord1Ed1.y == cord2Ed1.y then movedge1 = "y"
								else movedge1 = "err"
							if movedge1 != "err" then (
								if movedge1 == "x" then (
									--move to X
									cord1Ed2.x = cord1Ed1.x 
									cord2Ed2.x = cord1Ed1.x 
								) else (
									--move to Y
									cord1Ed2.y = cord1Ed1.y
									cord2Ed2.y = cord2Ed1.y
								)
								polyop.setVert obj arrV2[1] cord1Ed2
								polyop.setVert obj arrV2[2] cord2Ed2
							) else _LOG "[dg:] wat_stitch_a[] ERROR Stitch a edges\n"
						)
					) else messagebox "you mast select 2 edge only" title: "GTA Water IO"
				) catch messagebox "edge stitch error!" title: "GTA Water IO"
			)
		)
		
		on wat_fix pressed do (
			disableSceneRedraw()
			try (
					undo on (
						universal = polyFns()
						if subObjectLevel == 0 then (
							_LOGprocess "\n[dg:] process: FIX\n"
							for itobj in selection do (
								if classof itobj != Editable_poly then convertToPoly itobj
								ResetXForm itobj
								collapseStack itobj
								
								for ip = 1 to (polyop.getNumFaces itobj) do (
									if ((polyop.getVertsUsingFace itobj ip) as array).count == 3 then (
										polyop.detachFaces itobj ip delete:true asNode:false
										_LOG "[dg:] wat_fix[] info: detach triangle (or repeat)\n"
									)
								)
								
								-- Rectangle alignment
								_LOG "[dg report:] wat_fix[]: Rectangle alignment...\n"
								------------------------------------------
								for i = 1 to (polyop.getNumEdges itobj) do (
									if (triangleCheck	itobj i) == false then ( -- CHECK triangle for - i - (edge)
										arrV = (polyop.getVertsUsingEdge itobj i  as array)
										cordV1 = polyop.getVert itobj arrV[1]
										cordV2 = polyop.getVert itobj arrV[2]
										resX = abs ((abs cordV1.x) - (abs cordV2.x))
										if resX != 0 then (
											resY= abs ((abs cordV1.y) - (abs cordV2.y))
											if resY != 0 then (
												if resX > resY then (
													tmpAv = average2num cordV1.y cordV2.y
													tmpV = mod (ceil tmpAv) 4.0
													if tmpV != 0 then (
														tmpAv = (ceil tmpAv) - tmpV
													) else tmpAv = (ceil tmpAv)
													cordV1.y = tmpAv
													cordV2.y = tmpAv
												) else (
													tmpAv = average2num cordV1.x cordV2.x
													tmpV = mod (ceil tmpAv) 4.0
													if tmpV != 0 then (
														tmpAv = (ceil tmpAv) - tmpV
													) else tmpAv = (ceil tmpAv)
													cordV1.x = tmpAv
													cordV2.x = tmpAv
												)
											)
										)
										polyop.setVert itobj arrV[1] cordV1
										polyop.setVert itobj arrV[2] cordV2
									)
								)
							
							adgeArrTmp = #()
							queueEdge = #()
							-- Coordinate alignment for polygon
							_LOG "[dg report:] wat_fix[]: coordinate alignment for polygon...\n"
							for i = 1 to polyop.getNumEdges itobj do (	
								if (triangleCheck	itobj i) == false then ( -- CHECK triangle for - i -
									----------------------------------------
									adgeArrTmp[1] = i
									obj = itobj
									selectLoop (initLoopData (adgeArrTmp as BitArray) )
									edgeSel = edgeSel as array
									if edgeSel != undefined then (
										
										if edgeSel.count == 1 then (
											arrV = (polyop.getVertsUsingEdge itobj edgeSel[1]  as array)
											cordV1 = polyop.getVert itobj arrV[1]
											cordV2 = polyop.getVert itobj arrV[2]
											if cordV1.x == cordV2.x then (  
												--move to X
												tmpAv = ceil cordV1.x
												tmpV = mod tmpAv 4.0
												if tmpV != 0 then (
													tmpAv = tmpAv - tmpV
												) else tmpAv = tmpAv
												
												cordV1.x = tmpAv
												cordV2.x = tmpAv
												polyop.setVert itobj arrV[1] cordV1
												polyop.setVert itobj arrV[2] cordV2
												
												
											) else if cordV1.y == cordV2.y then (
												--move to Y
												tmpAv = ceil cordV1.y
												tmpV = mod tmpAv 4.0
												if tmpV != 0 then (
													tmpAv = tmpAv - tmpV
												) else tmpAv = tmpAv
												
												cordV1.y = tmpAv
												cordV2.y = tmpAv
												polyop.setVert itobj arrV[1] cordV1
												polyop.setVert itobj arrV[2] cordV2
											) else _LOG "[dg:] wat_fix[] ERROR mesh model is curved !\n"
										) else (
												arrV = (polyop.getVertsUsingEdge itobj edgeSel[1]  as array)
												cordV1 = polyop.getVert itobj arrV[1]
												cordV2 = polyop.getVert itobj arrV[2]
												if cordV1.x == cordV2.x then (  
													--move to X
													tmpAv = ceil cordV1.x
													tmpV = mod tmpAv 4.0
													if tmpV != 0 then (
														tmpAv = tmpAv - tmpV
													) else tmpAv = tmpAv
													
													for mEdge in edgeSel do (
														arrV = (polyop.getVertsUsingEdge itobj mEdge  as array)
														cordV1 = polyop.getVert itobj arrV[1]
														cordV2 = polyop.getVert itobj arrV[2]
														cordV1.x = tmpAv
														cordV2.x = tmpAv
														polyop.setVert itobj arrV[1] cordV1
														polyop.setVert itobj arrV[2] cordV2
													)
													
												) else if cordV1.y == cordV2.y then (
													--move to Y
													tmpAv = ceil cordV1.y
													tmpV = mod tmpAv 4.0
													if tmpV != 0 then (
														tmpAv = tmpAv - tmpV
													) else tmpAv = tmpAv
													
													for mEdge in edgeSel do (
														arrV = (polyop.getVertsUsingEdge itobj mEdge  as array)
														cordV1 = polyop.getVert itobj arrV[1]
														cordV2 = polyop.getVert itobj arrV[2]
														cordV1.y = tmpAv
														cordV2.y = tmpAv
														polyop.setVert itobj arrV[1] cordV1
														polyop.setVert itobj arrV[2] cordV2
													)
												) else _LOG "[dg:] wat_fix[] ERROR mesh model is curved !\n"
										)
									) ------------------------------------------------------------------------
								) else (
									append queueEdge i
								)
							)
							
							-- operation for fouded trianges (in queueEdge)
							_LOG "[dg report:] wat_fix[]: operation for found triangles (in queueEdge)...\n"
								for qEdge in queueEdge do (
									arrV = (polyop.getVertsUsingEdge itobj qEdge  as array)
									cordV1 = polyop.getVert itobj arrV[1]
									cordV2 = polyop.getVert itobj arrV[2]
									-- 1st vert
									tmpAv = ceil cordV1.x
									tmpV = mod tmpAv 4.0
									if tmpV != 0 then (
										tmpAv = tmpAv - tmpV
										cordV1.x = tmpAv
									) else (
										tmpAv = ceil cordV1.y
										tmpV = mod tmpAv 4.0
										if tmpV != 0 then (
											tmpAv = tmpAv - tmpV
										)
										cordV1.y = tmpAv
									)
									
									-- 2st vert
									tmpAv = ceil cordV2.x
									tmpV = mod tmpAv 4.0
									if tmpV != 0 then (
										tmpAv = tmpAv - tmpV
										cordV2.x = tmpAv
									) else (
										tmpAv = ceil cordV2.y
										tmpV = mod tmpAv 4.0
										if tmpV != 0 then (
											tmpAv = tmpAv - tmpV
										)
										cordV2.y = tmpAv
									)
									
									polyop.setVert itobj arrV[1] cordV1
									polyop.setVert itobj arrV[2] cordV2
									
									fcAr = polyop.getEdgeFaces itobj qEdge
									if fcAr.count == 1 then fc1 = fcAr[1]
									fixWatTriangle itobj fc1
								)
							
								-- check Z coordinate
								-------------------------------------------
								testVert = false
								oneVert = (polyop.getVert itobj 1).z
								for i = 2 to (polyop.getNumVerts itobj) do (
									if oneVert != (polyop.getVert itobj i).z then (
										testVert = true
										
									)
								)
								if testVert == false then format "no problem\n" else format "(!) not similar\n"
							)	
							_LOGprocess "[dg:] process: FIX END\n"
						)
					) ---------------------------------------------------------------------------
			) catch (
					messagebox "water fix unknown error!" title: "GTA Water IO"
					_LOG "[dg:] water fix unknown error\n"
					enableSceneRedraw()
			)
			enableSceneRedraw()
			setNeedsRedraw()
		)
	)
	createDialog rl_GTAwaterIO  style: #(#style_titlebar, #style_border, #style_sysmenu,#style_minimizebox)
)
