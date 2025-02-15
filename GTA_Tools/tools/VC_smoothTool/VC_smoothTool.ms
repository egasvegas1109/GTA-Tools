/*
 - Vertex Color Smooth Tool v 1.0 -
 
Last update: 20.05.20
 
Script features (video): https://youtu.be/ettujbyJpwU


Author: 
Goldfish

The script is in beta testing, bout all bugs and offers report in https://vk.com/topic-99725313_35674835

Support: 
Goldfish-1994@yandex.ru 
https://vk.com/topic-99725313_35674835

		
Change the code on your own risk !!!
*/

try destroydialog ro_average_map_vertex catch()
rollout ro_average_map_vertex "VC Smooth Tool v 1.0"
(
	spinner spn_threshold "Threshold:" type:#worldunits range:[0.01,20,0.01] fieldwidth:40 offset:[0,20] 
	button btn_average "Smooth Vertex Color "  height:40 width:160
	label txt2 "(on selected models)"
	label txt3 "___________________________"
	label txt4 "(c) Goldfish and Igorznag 2020"
	
	on btn_average pressed do
	(
		threshold=spn_threshold.value
		objs=selection as array
			if objs.count>1 then
			(
				eps=#(); for obj in objs where superclassof obj.baseobject == GeometryClass do (
					if classof obj != Editable_Poly then converttopoly obj
					append eps obj
				)
				if eps.count>0 then
				(
					objs_has_vertex_color_count=0
					for obj in eps  where (polyop.getMapSupport obj 0 and polyop.getMapSupport obj -1) do objs_has_vertex_color_count+=1
					if eps.count==objs_has_vertex_color_count then
					(
						try (
							geom_vertex_a=#()
							for obj in eps do
							(
								lastobj = obj.name
								vs_a=(polyop.getvertsusingedge obj (polyop.getOpenEdges obj)) as array
								for v in vs_a do
								(
									p=polyop.getvert obj.baseobject v node:obj
									append geom_vertex_a #(obj, v, p)
								)--for v in vs_a do
							)--for obj in eps do
							if geom_vertex_a.count>0 do
							(
								geom_vertex_common_a=#()
								while geom_vertex_a.count>0  do
								(
									temp_geom_vertex_common_a=#(geom_vertex_a[1]); temp_index_geom_vertex_common_a=#(1)
									if geom_vertex_a.count>=2 do
									(
										for i=2 to geom_vertex_a.count do
										(
											if distance geom_vertex_a[1][3] geom_vertex_a[i][3]<=threshold do 
											(
												append temp_geom_vertex_common_a geom_vertex_a[i]
												append temp_index_geom_vertex_common_a i
											)--if distance geom_vertex_a[1][3] geom_vertex_a[i][3]<=threshold do 
										)--for i=2 to geom_vertex_a.count do
									)--if geom_vertex_a.count>=2 do
									sort temp_index_geom_vertex_common_a
									for i=temp_index_geom_vertex_common_a.count to 1 by -1 do deleteitem geom_vertex_a temp_index_geom_vertex_common_a[i]
									if temp_geom_vertex_common_a.count>=2 do append geom_vertex_common_a temp_geom_vertex_common_a
								)--while geom_vertex_a.count>0  do
								if geom_vertex_common_a.count>0 do
								(
									undo off with animate off
									(
										--copy vc to mapchannel 1
										for obj in eps do
										(
											lastobj = "[ChannelInfo 1] "+obj.name
											num_channels=polyop.getNumMaps obj
											ChannelInfo.CopyChannel obj 3 1; ChannelInfo.PasteChannel obj 3 num_channels
											ChannelInfo.CopyChannel obj 3 0; ChannelInfo.PasteChannel obj 3 1
										)--for obj in eps do
										max modify mode; 
										m=Unwrap_UVW(); modPanel.addModToSelection m; subobjectlevel=1;
										for i=1 to geom_vertex_common_a.count do
										(
											tv_vertex_common_i_a=#(); tv_vertex_common_center=[0,0,0]; tv_vertex_common_count=0
											for j=1 to geom_vertex_common_a[i].count do
											(
												obj=geom_vertex_common_a[i][j][1]; vertex_index=geom_vertex_common_a[i][j][2]
												m.setSelectedGeomVertsByNode #{vertex_index} obj; m.syncTVSelection();
												tv_vs=(m.getSelectedVerticesByNode obj) as array
												for tv_index in tv_vs do
												(
													append tv_vertex_common_i_a #(obj, tv_index)
													p=m.GetVertexPositionByNode slidertime  tv_index obj; tv_vertex_common_center+=p; tv_vertex_common_count+=1
												)--for tv_index in tv_vs do
											)--for j=1 to geom_vertex_common_a[i] do
											tv_vertex_common_center/=tv_vertex_common_count
											for tv_vertex_common_i in tv_vertex_common_i_a do
											m.setVertexPositionByNode slidertime tv_vertex_common_i[2] tv_vertex_common_center tv_vertex_common_i[1]
										)--for i=1 to geom_vertex_common_a.count do
										--copy mapcchannel 1 to vc and last mapchannel to mapchannel 1
										for obj in eps do
										(
											lastobj = "[ChannelInfo 2] "+obj.name
											num_channels=(polyop.getNumMaps obj)-1
											ChannelInfo.CopyChannel obj 3 1; ChannelInfo.PasteChannel obj 3 0
											ChannelInfo.CopyChannel obj 3 num_channels; ChannelInfo.PasteChannel obj 3 1; ChannelInfo.ClearChannel obj num_channels
											converttopoly obj
										)--for obj in eps do
										
										for obj in eps do
										(
											lastobj = "[ChannelInfo 3] "+obj.name
											num_channels=polyop.getNumMaps obj
											ChannelInfo.CopyChannel obj 3 1; ChannelInfo.PasteChannel obj 3 num_channels
											ChannelInfo.CopyChannel obj 3 -1; ChannelInfo.PasteChannel obj 3 1
										)--for obj in eps do
										max modify mode; 
										lastobj = "[Unwrap_UVW()...]"
										m=Unwrap_UVW(); modPanel.addModToSelection m; subobjectlevel=1;
										for i=1 to geom_vertex_common_a.count do
										(
											tv_vertex_common_i_a=#(); tv_vertex_common_center=[0,0,0]; tv_vertex_common_count=0
											for j=1 to geom_vertex_common_a[i].count do
											(
												obj=geom_vertex_common_a[i][j][1]; vertex_index=geom_vertex_common_a[i][j][2]
												m.setSelectedGeomVertsByNode #{vertex_index} obj; m.syncTVSelection();
												tv_vs=(m.getSelectedVerticesByNode obj) as array
												for tv_index in tv_vs do
												(
													append tv_vertex_common_i_a #(obj, tv_index)
													p=m.GetVertexPositionByNode slidertime  tv_index obj; tv_vertex_common_center+=p; tv_vertex_common_count+=1
												)--for tv_index in tv_vs do
											)--for j=1 to geom_vertex_common_a[i] do
											tv_vertex_common_center/=tv_vertex_common_count
											for tv_vertex_common_i in tv_vertex_common_i_a do
											m.setVertexPositionByNode slidertime tv_vertex_common_i[2] tv_vertex_common_center tv_vertex_common_i[1]
										)--for i=1 to geom_vertex_common_a.count do
										--copy mapcchannel 1 to vc and last mapchannel to mapchannel 1
										for obj in eps do
										(
											lastobj = "[ChannelInfo 4] "+obj.name
											num_channels=(polyop.getNumMaps obj)-1
											ChannelInfo.CopyChannel obj 3 1; ChannelInfo.PasteChannel obj 3 -1
											ChannelInfo.CopyChannel obj 3 num_channels; ChannelInfo.PasteChannel obj 3 1; ChannelInfo.ClearChannel obj num_channels
											converttopoly obj
										)--for obj in eps do
									)--undo off with animate off
								)--if geom_vertex_common_a.count>0 do
							)--if geom_vertex_a.count>0 do
							messagebox "Done!" title: "VC Smooth Too"
						) catch (
							msg = "Unknown error!\nLast obj: "+lastobj
							messagebox msg title: "VC Smooth Too: error"
						)
					)else messagebox "All objects must have VC and NVC Prelit!" title: "VC Smooth Too: Warning"
				)else messagebox "Select Editable Poly objects!" title: "VC Smooth Too: Warning"
			)else messagebox "Select 2 or more objects" title: "VC Smooth Too: Warning"
	)--on btn_average pressed do
); createdialog ro_average_map_vertex 186 160 
