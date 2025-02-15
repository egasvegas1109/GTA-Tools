
plugin Material GTA_Mtl
    name:"GTA Material (f)"
    classID:#(0x48238272, 0x48206285)
	extends:Standard replaceUI:true version:2
(
	parameters main rollout:params 
	(
		amb					type:#float default:1.0 	ui:amb
		spc					type:#float default:0.0 	ui:spc
		dif					type:#float default:1.0 	ui:dif
		color 				type:#color default:white 	ui:pccol 
		colormap 			type:#TextureMap  			ui:pccolmap
		use_colormap 		type:#boolean default:true	ui:pcuse
		alpha				type:#integer default:255	ui:popy
		alphamap 			type:#TextureMap  			ui:popymap
		use_alphamap 		type:#boolean default:true 	ui:pouse
		Reflection			type:#float default:100		ui:pref
		reflectionmap 		type:#TextureMap  			ui:prefmap
		use_reflectionmap 	type:#boolean default:true	ui:pruse
		specular			type:#color default:white 	ui:pscol 
		specularmap 		type:#TextureMap  			ui:pspcmap
		use_specularmap 	type:#boolean default:true	ui:psuse		
		spec_alpha			type:#integer default:255	ui:pspca
		spec_power			type:#float default:100		ui:pspwr
		blend 				type:#float default:1.0 	ui:srblend
		colhprIdx			type:#integer 	default:1	ui:colhpr
		
		bumpMapAmount		type:#float default:1		ui:bumpv
		bumpMap 			type:#TextureMap  			ui:bumpMap_
		p_srcblend 			type:#integer default:2 	ui:srcblend_
		p_destblend 		type:#integer default:2 	ui:destblend_
		matEffect   		type:#integer default:1 	ui:fxtype_
		dualMap 			type:#TextureMap  			ui:dualMap_
		dkpNmap 			type:#TextureMap  			ui:dkpNmap_
		dkpRmap 			type:#TextureMap  			ui:dkpRmap_
		dkpRAmount		type:#float default:1		ui:dkpRv

		use_RF 				type:#boolean default:false ui:useRF
		use_SAS 			type:#boolean default:false ui:useSAS
		use_SI 				type:#boolean default:false ui:useSI
		
        
		on color set val do delegate.diffuse_color = val 
		on colormap set tex do ( delegate.diffuseMap = tex; delegate.diffuseMapAmount = 90; delegate.diffuseMapEnable = use_colormap )
		on use_colormap set state do delegate.diffuseMapEnable = state
		--on spec_power set val do delegate.specular_level = val
		on spec_power set val do delegate.glossiness = val
		on specular set val do delegate.specular_color = val
		on specularmap set tex do ( delegate.specularMap = tex; delegate.specularMapEnable = use_specularmap  )
		on use_specularmap set state do delegate.specularMapEnable = state
 		on alpha set val do delegate.opacity = val/255.0*100
		on alphamap set tex do ( delegate.opacityMap = tex; delegate.opacityMapEnable = use_alphamap )
		on use_alphamap set state do delegate.opacityMapEnable = state
		on Reflection set val do delegate.reflectionMapAmount = val
		on reflectionmap set tex do ( delegate.reflectionMap = tex; delegate.reflectionMapEnable = use_reflectionmap )
		on use_reflectionmap set state do delegate.reflectionMapEnable = state
	)
	
		
	rollout params  "GTA Parameters" (
 		label info01 "This Shader only works for GTA Exporter."

		label lblc "Color Guide" pos:[130,38]
		dropdownlist colhpr "" width:120 items:#("None","Primary","Sccondary","4 Colors paintjob","Left Headlight","Right Headlight","Left Taillight","Right Taillight") pos:[195,35]

		group "Main"(
      	  label dmy	 ""
			spinner 		amb			"Ambient"	fieldwidth:45 range:[0,1,0]	pos:[10,80] 
			spinner 		spc			"Specular"	fieldwidth:45 range:[0,1,0]	pos:[115,80]
			spinner 		dif			"Diffuse"	fieldwidth:45 range:[0,1,0]	pos:[225,80]
			label			pclbl		"Color " 	pos:[10,105]
 			colorpicker		pccol 		"" 			pos:[65,103] 
			checkbox 		pcuse		""			pos:[130,105]
        	mapbutton		pccolmap	"None" 		width:165 pos:[150,103]			
			label			polbl		"Alpha " 	pos:[10,130]
			spinner			popy		""	fieldwidth:45 type:#integer range:[0,255,255] pos:[65,130]	
			checkbox 		pouse		""			pos:[130,130]
			mapbutton		popymap		"None" 		width:165 pos:[150,128]
		)
		group "Material Effects" (
			label			prlblfx		"TYPE:" pos:[12,183]
			dropdownlist fxtype_ ""  pos:[56,180]  width:260 height:21 items:#("NONE","Reflection map","Bump map","Reflection + Bump map","Dual map","DK plugin adaptation")
			checkbox useRF "Reflection Export" pos:[10,205]
			label			prlbl		"Reflection" pos:[10,230]
			spinner			pref		""	fieldwidth:45 range:[0,100,0] pos:[65,230]	
			checkbox 		pruse		""			pos:[130,230]
	        mapbutton		prefmap		"None" 		width:165 pos:[150,227]
			label			lbl_t1		"----------------------------------------------------------------------------------------------------" pos:[10,250]
			label			lbl_bps		"BUMP Export" pos:[33,265]
			label			lbl_bpv		"Bump" pos:[20,290]
			spinner			bumpv		""	fieldwidth:45 range:[0,100,100] pos:[65,290]	
	        mapbutton	bumpMap_		"None" 		width:165 pos:[150,286]
			label			lbl_t2		"----------------------------------------------------------------------------------------------------" pos:[10,310]
			label			lbl_dls		"DUAL Texture Export" pos:[33,325]
			label        srclbl "Source type Blend . " pos:[13,349] 
			dropdownlist srcblend_ "" pos:[110,345] width:200 height:21 items:#("rpBLENDZERO", "rpBLENDONE", "rpBLENDSRCCOLOR", "rpBLENDINVSRCCOLOR", "rpBLENDSRCALPHA", "rpBLENDINVSRCALPHA", "rpBLENDDESTALPHA", "rpBLENDINVDESTALPHA", "rpBLENDDESTCOLOR", "rpBLENDINVDESTCOLOR", "rpBLENDSRCALPHASAT")
			label        destlbl "Dest type Blend ..... " pos:[13,379] 
			dropdownlist destblend_ "" pos:[110,373] width:200 height:21 items:#("rpBLENDZERO", "rpBLENDONE", "rpBLENDSRCCOLOR", "rpBLENDINVSRCCOLOR", "rpBLENDSRCALPHA", "rpBLENDINVSRCALPHA", "rpBLENDDESTALPHA", "rpBLENDINVDESTALPHA", "rpBLENDDESTCOLOR", "rpBLENDINVDESTCOLOR", "rpBLENDSRCALPHASAT")
	        mapbutton	dualMap_		"None" 		width:305 pos:[10,408]
		)
		group "Specular Image" (
			checkbox useSI "Export Specular Image section"
			label			psplbl		"Glossiness" 	pos:[10,484]
			spinner 		pspwr 		"" fieldwidth:45 range:[0,100,100] pos:[65,484]
			checkbox 		psuse		""			pos:[130,484] 
	        mapbutton		pspcmap		"None" 		width:165 pos:[150,479]
		)
		group "SA Specular" (
			checkbox useSAS "Export SA Specular section"
			label			pslbl		"Specular" 	pos:[15,560] 
	 		colorpicker		pscol 		"" 			pos:[65,555] 
			label			psalbl		"Spec Alpha" 	pos:[145,560] 
			spinner 		pspca 		""			fieldwidth:45 type:#integer range:[0,255,255] pos:[210,560]
			label			psrlbl		"(*SA reflection control) Spec/Ref Blend" 	pos:[15,580] 
			spinner 		srblend		""		fieldwidth:45 range:[0,1,1] pos:[210,580]
		)	
		button veldft "SA Vehicle default" width:120 tooltip:"Setup default Reflection/Specular" across:2
		button othdft "Other default" width:120 tooltip:"For use with weapon, building etc."
		
		label info123 "" offset:[0,20]
		group "DK Plugin adaptation" (
		checkbox 		dkpUse		"use"	 
			label infodkN "Normal Map" align:#left 
			mapbutton	dkpNmap_		"None" 		width:230  offset:[35,-20] enabled: false
			label infodkN2 "Reflection Map" align:#left 
			spinner			dkpRv		"" align:#center 	fieldwidth:45 range:[0,100,1] offset:[-45,-17] enabled: false
			mapbutton	dkpRmap_		"None" 		width:160  offset:[70,-20] enabled: false
		)
		label info12 "" 
        label info13 "(c) By Goldfish, Kam     2005 - 2018" align:#right
		label info14 "" 
		label info15 "** Thanks ashdexx for the detail explanation **" align:#center
		label info16 "** And all guys in GTAF for the further improvenent **" align:#center
		
		on params open do (
			if fxtype_.selection == 6 then (
				dkpRv.enabled = true
				dkpNmap_.enabled = true
				dkpRmap_.enabled = true
				useRF.enabled = false
				pref.enabled = false
				pruse.enabled = false
				prefmap.enabled = false
				bumpv.enabled = false
				bumpMap_.enabled = false
				srcblend_.enabled = false
				destblend_.enabled = false
				dualMap_.enabled = false
				dkpUse.checked = true
			)
		)
		on useRF changed state do (
			if state == true then fxtype_.selection = 2
			else fxtype_.selection = 1
		)
		
		on dkpUse changed state do (
			if state == true then (
				fxtype_.selection = 6
				dkpRv.enabled = true
				dkpNmap_.enabled = true
				dkpRmap_.enabled = true
				useRF.enabled = false
				pref.enabled = false
				pruse.enabled = false
				prefmap.enabled = false
				bumpv.enabled = false
				bumpMap_.enabled = false
				srcblend_.enabled = false
				destblend_.enabled = false
				dualMap_.enabled = false
				dkpUse.checked = true
			) else (
				fxtype_.selection = 1
				dkpRv.enabled = false
				dkpNmap_.enabled = false
				dkpRmap_.enabled = false
				dkpUse.checked = false
				useRF.enabled = true
				pref.enabled = true
				pruse.enabled = true
				prefmap.enabled = true
				bumpv.enabled = true
				bumpMap_.enabled = true
				srcblend_.enabled = true
				destblend_.enabled = true
				dualMap_.enabled = true
			)
		)
		
		on fxtype_ selected sItem do (
			if sItem == 6 then (
				dkpRv.enabled = true
				dkpNmap_.enabled = true
				dkpRmap_.enabled = true
				useRF.enabled = false
				pref.enabled = false
				pruse.enabled = false
				prefmap.enabled = false
				bumpv.enabled = false
				bumpMap_.enabled = false
				srcblend_.enabled = false
				destblend_.enabled = false
				dualMap_.enabled = false
				dkpUse.checked = true
			) else (
				dkpRv.enabled = false
				dkpNmap_.enabled = false
				dkpRmap_.enabled = false
				dkpUse.checked = false
				useRF.enabled = true
				pref.enabled = true
				pruse.enabled = true
				prefmap.enabled = true
				bumpv.enabled = true
				bumpMap_.enabled = true
				srcblend_.enabled = true
				destblend_.enabled = true
				dualMap_.enabled = true
				if sItem != 2 and sItem != 4 then useRF.checked = false
				if sItem == 2 or sItem == 4 then useRF.checked = true
			)
		)
		
		on veldft pressed do (
			this.reflectionmap= Bitmaptexture fileName:"xvehicleenv128.tga"
			this.specularmap = Bitmaptexture fileName:"vehiclespecdot64.tga"
			this.specular.r=255;this.specular.g=255;this.specular.b=255
			pspcmap.text = "vehiclespecdot64.tga"
			prefmap.text = "xvehicleenv128.tga"
			this.blend=0.05
			useRF.checked = true
			useSAS.checked = true
			useSI.checked = true
		)
		on othdft pressed do (
			this.reflectionmap= undefined
			this.specularmap = undefined
			this.color.r=255;this.color.g=255;this.color.b=255
			--this.specular.r=0;this.specular.g=0;this.specular.b=0
			this.alpha = 255
			useRF.checked = false
			useSAS.checked = false
			useSI.checked = false
		)
		
		on colhpr selected val do (
			case val of (
				8: (this.color.r=255;this.color.g=60;this.color.b=0)
				7: (this.color.r=185;this.color.g=255;this.color.b=0)
				6: (this.color.r=0;this.color.g=255;this.color.b=200)
				5: (this.color.r=255;this.color.g=175;this.color.b=0)
				4: (this.color.r=0;this.color.g=255;this.color.b=255)
				3: (this.color.r=255;this.color.g=0;this.color.b=175)
				2: (this.color.r=60;this.color.g=255;this.color.b=0)
			)
			colhprIdx = val			
		)

 	)
	
	on create do (
		this.name = delegate.name
		try (colhpr.selection = colhprIdx) catch()  
	)
	on load do (
		this.name = delegate.name
		try (colhpr.selection = colhprIdx) catch()            
	)
	on update do (
		if version == 1 then (
			if (use_reflectionmap==true)AND(classof reflectionmap == bitmaptexture) then use_RF = true
			if (use_specularmap==true)AND(classof specularmap == bitmaptexture) then use_SI = true
			col = specular as point3
			if (col != [0,0,0]) then use_SAS = true
		)
	)	            
)
