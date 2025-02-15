fn stripSpace str = (
	tmp = ""
	for i = 1 to str.count do (
		if substring str i 1 == " " then tmp += "~"
		else tmp += (substring str i 1)
	)
	return tmp
)

rollout dumproll "" (

	button dumpifp "Dump GTA IFP" width:120
	label l1 "This is a little helper to" align:#left
	label l2 "dump a GTA .ifp file to .txt" align:#left
	label l3 "It's for GMax user to" align:#left
	label l4 "Replace and Rebuild new" align:#left
	label l5 "animations back to ifp file" align:#left
	label l6 "After edited the text file, Use" align:#left
	label l7 "T2B.exe <this.txt> <real.ifp>" align:#left
	label l8 "to create a real .ifp file" align:#left
	label l9 " "
	label la "by Kam" align:#left across:2
	label lb "13Oct05" align:#right
	label lc "kam.lai@ntlworld.com"
		
	on dumpifp pressed do (
		fname = getOpenFileName caption:"Open GTA Animation File" types:"IFP animation (*.ifp)|*.ifp|All files (*.*)|*.*|"
		if (fname != undefined) then (
			f = fopen fname "rb"
			format "//"
			format "\n"
			clearlistener()
			dmpName = (getFilenamePath fname) + (getFilenameFile fname) + ".txt"        
			format "<!-- path=\"%\" -->\n" dmpName
			format"//\n//\n//This is Header Section\n"
			HeaderID = readLong f
			if HeaderID == 0x33504E41 then (
				format "c 4\nANP3\ni 1\n%\n" (readLong f)
				format "c 24\n%\n" (readString f)
				fseek f 32 #seek_set
				totalAnim = readLong f 
				format "i 1\n%\n//\n//\n" totalAnim

				for i = 1 to totalAnim do (
					Aname = readString f
					format "//\n//\n//Animation % Start Here\n" Aname
					format "c 24\n%\n" (stripSpace Aname)
					fseek f (23 - Aname.count) #seek_cur
					totalBones = readLong f
					format "i 3\n% % %\n" totalBones (readLong f) (readLong f)
					
					for j = 1 to totalBones do (
						Bname = readString f
						format "c 24\n%\n" (stripSpace Bname)
						fseek f (23 - Bname.count) #seek_cur
						Atype = readLong f
						Akeys = readLong f
						format "i 3\n% % %\n" Atype Akeys (readLong f)
						if Atype == 3 then (
							format "w %\n" (Akeys * 5)
							for k = 1 to Akeys do 
								format "% % % % %\n" (readShort f) (readShort f) (readShort f) (readShort f) (readShort f)
						) else (
							format "w %\n" (Akeys * 8)
							for k = 1 to Akeys do 
								format "% % % % % % % %\n" (readShort f) (readShort f) (readShort f) (readShort f) (readShort f) (readShort f) (readShort f) (readShort f)
						)
					)--end for j
				)--end for i
			) else if HeaderID == 0x4B504E41 then (

				--readLong f
				format "c 4\nANPK\ni 1\n%\n" (readLong f)
				readLong f
				infolength = readLong f
				totalAnim = readLong f 
				format "c 4\nINFO\ni 2\n% %\n" infolength totalAnim
				format "c %\n%\n" (infolength - 4) (readString f)
			
				for i = 1 to totalAnim do (

					readLong f
					namelength = readLong f
					namespace = (((namelength-1)/4)+1)*4
					Aname = readString f
					nameskip = namespace - namelength
					for j = 1 to nameskip do (readByte f)
				
					format "//\n//\n//Animation % Start Here\n" Aname
					format "c 4\nNAME\n"
					format "i 1\n%\nc %\n%\n" namelength namespace Aname
					readLong f
					format "c 4\nDGAN\ni 1\n%\n" (readLong f)
					readLong f
					infolength = readLong f
					numObj = readLong f
					infocount = infolength/4
					format "c 4\nINFO\ni %\n% % %" infocount infolength numObj (readLong f)
					if infocount == 3 then format "\n" 
					else (
						for i = 4 to infocount do format "% " (readlong f)
						format "\n"
					)
				
					for k = 1 to numObj do (
						readLong f
						format "c 4\nCPAN\ni 1\n%\n" (readLong f)
						readLong f
						rectype = readLong f
						format "c 4\nANIM\ni 1\n%\n" rectype
						animName = readString f
						format "c 28\n%\n" (stripSpace animName)
						for j = 1 to (27 - animName.count) do (readByte f)
						numframe = readLong f
						if 	rectype == 44 then format "i 4\n% % % %\n" numframe (readLong f) (readLong f) (readLong f)
						else format "i 5\n% % % %\n" numframe (readLong f) (readLong f) (readLong f) (readLong f)
	
						keytype = readLong f
						case keytype of (
								0x3030524B: (format "c 4\nKR00\n";cln = 5)
								0x3054524B: (format "c 4\nKRT0\n";cln = 8)
								0x5354524B: (format "c 4\nKRTS\n";cln = 11)
						)--end case
						nfs = numframe * cln			
						format "i 1\n%\nf %\n" (readLong f) nfs
						ctr = 0
						for j = 1 to nfs do (
							format "% " (readFloat f)
							ctr += 1
							if ctr == cln then (
								format "\n"
								ctr = 0
							)
						)--end for j
					)--end for k	
				)--end for i

			) else (clearlistener() ; messagebox "Unknown IFP Format!" title:"Error" ) --end if ANP3
			fclose f
		)
	)
)--end rollout dumproll 

if Kam_IFPDump != undefined then closeRolloutFloater Kam_IFPDump
Kam_IFPDump = newRolloutFloater "GTA IFP Dump" 175 300 10 100		
addRollout dumproll Kam_IFPDump