fn ExplodeObject obj X_STEP Y_STEP val bname = 
(
fs = #()
omin = obj.min
omax = obj.max
gab = omax - omin
x_count = (gab.x/x_step) as integer
x_step2 = gab.x / x_count
x_count += 1
y_count = (gab.y/y_step) as integer
y_step2 = gab.y / y_count

--p = plane pos:obj.center width:gab.x length:gab.y \
--          lengthsegs:y_count widthsegs:(x_count-1)

format "x_count = %\ny_count = %\nx_step = %\ny_step = %\n" (x_count-1) y_count x_step2 y_step2


for i = 1 to obj.numfaces do (
   cpos = polyOp.getFaceCenter obj i
   cpos -= omin
   A = (cpos.x/x_step2) as integer
   B = (cpos.y/y_step2) as integer
   B *= x_count
   N = A + B + 1
   if fs[N] == undefined then fs[N] = #{i}
   else fs[n] += #{i}
)

ccc = 1
for dfs in fs do
  if dfs != undefined then (
     polyOp.detachFaces obj dfs delete:false asNode:true name:(bname + (ccc as string))
	 if dfs.numberSet < val then format "object % ..poly count = %\n" (bname + (ccc as string)) dfs.numberSet
	 ccc += 1
  )
gc ()
) -- fn

rollout obj_explode_rol "object explode"
(
button expl "EXPLODE"
spinner xs "X STEP  " type:#float range:[0.1, 100000, 200]
spinner ys "Y STEP  " type:#float range:[0.1, 100000, 200]
edittext bname "base name" text:"detached" fieldWidth:120  bold:true labelOnTop:true
label l1 "tell if poly cont <" across:2 align:#left
spinner tel "" type:#integer range:[1, 100000, 20] width:40 align:#right
label l2 "delete original  " across:2 align:#left
checkbox delo checked:true align:#right

on expl pressed do 
 if $!=undefined then (
  clearlistener ()   
  obj = selection[1]

  ExplodeObject obj xs.value ys.value tel.value bname.text
  if delo.checked then delete obj
  gc ()
 )
) -- roll

try (CloseRolloutFloater obj_exp_flo) catch ()
obj_exp_flo = NewRolloutFloater "" 165 190 120 150
AddRollout obj_explode_rol obj_exp_flo