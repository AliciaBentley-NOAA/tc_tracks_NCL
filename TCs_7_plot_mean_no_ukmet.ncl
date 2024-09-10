;;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>;;
;;
;; Plots TC track density from various ensembles
;;
;;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>;;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/ut_string.ncl"
;************************************************************************

begin

print(" ")
print("**************")
print(" START SCRIPT ")
print("**************")
print(" ")

cur_year = 2024                 
int_time = 2024062912
model = "all"       
TCname = "beryl"
dir_out_web = "/home/people/emc/www/htdocs/users/Alicia.Bentley/beryl/"

;minlat = 13.
;maxlat = 39.
;minlon = -108.
;maxlon = -70.

; Early ATL for Beryl
minlat = 2.
maxlat = 38.
minlon = -100.0
maxlon = -40.0


;----------------------------------------------------------------------------------------------

dist = "150"

numgefs = todouble(31)     ; number of ensemble members
numec = todouble(51)    
numcmc = todouble(21)
numukmet = todouble(36)

name = model+"_noUK_mean_spread_"+int_time+"_"+TCname

dir_out = "./"

;---------------------------------------------------------------
;   Load all track densities
;---------------------------------------------------------------

file1 = addfile("gefs_track_density_"+int_time+".nc","r")
count1a = file1->count(:,:)
count1b = todouble(count1a - 0)
count1b = (count1b/numgefs)*100
do d=0,2
count1b=smth9(count1b,.5,.25,False)
end do
copy_VarCoords(count1a,count1b)
printMinMax(count1b,True)

file2 = addfile("ec_track_density_"+int_time+".nc","r")
count2a = file2->count(:,:)
count2b = todouble(count2a - 0)
count2b = (count2b/numec)*100
do d=0,2
count2b=smth9(count2b,.5,.25,False)
end do
copy_VarCoords(count2a,count2b)
printMinMax(count2b,True)

file3 = addfile("cmc_track_density_"+int_time+".nc","r")
count3a = file3->count(:,:)
count3b = todouble(count3a - 0)
count3b = (count3b/numcmc)*100
do d=0,2
count3b=smth9(count3b,.5,.25,False)
end do
copy_VarCoords(count3a,count3b)
printMinMax(count3b,True)

;==============================================
; Create Shaded Map
;==============================================
wks_type = "png"

wks_type@wkWidth = 2500
wks_type@wkHeight = 2500

wks = gsn_open_wks(wks_type,name)
gsn_define_colormap(wks,"MPL_rainbow")          ; "NCV_jet")
colors = gsn_retrieve_colormap(wks)  ; retrieve color map for editing. dimensioned (102,3)
;print(colors)

;colors(1,:) = (/ 1,1,1 /) ; replace the 32nd color
colors(8,:) = (/ 1,1,1 /)

;print(colors)

gsn_define_colormap(wks,colors)

;**********************************************
res = True

res@gsnFrame = False                                             ;DO NOT PLOT FIRST MAP
res@gsnDraw = False

res@tiMainString = " "    ; Specify Title
res@tiMainJust = "CenterCenter"
res@tiMainPosition = "Center" 
res@tiMainOffsetYF = -0.03
res@tiXAxisFontHeightF = .015
res@gsnLeftString = " "
res@gsnLeftStringOrthogonalPosF = .014
res@gsnRightString =" "
res@gsnRightStringOrthogonalPosF = .011
res@gsnStringFontHeightF = .013

res@mpFillOn = False
res@mpLandFillColor = "grey93"  ;"grey75"
;res@mpInlandWaterFillColor = "lightsteelblue2"
;res@mpOceanFillColor = "lightsteelblue2"
res@mpInlandWaterFillColor = "white"
res@mpOceanFillColor = "white"
res@mpDataBaseVersion = "MediumRes"                              ; Country Outlines
res@mpDataSetName = "Earth..4"
res@mpOutlineBoundarySets = "National"
res@mpOutlineSpecifiers = (/"Canada : Provinces","United States : States"/)
res@mpOutlineOn = True
res@mpGeophysicalLineColor = "grey65"
res@mpNationalLineColor = res@mpGeophysicalLineColor
res@mpUSStateLineColor = res@mpGeophysicalLineColor
res@mpGeophysicalLineThicknessF = 3
res@mpNationalLineThicknessF = 3
res@mpUSStateLineThicknessF = 3

res@cnFillOn = False   
res@cnFillMode = "AreaFill"
res@cnRasterSmoothingOn = True
res@cnLinesOn = True 
;res@cnLevelSelectionMode = "ManualLevels"
;res@cnLevelSpacingF = 25
;res@cnMinLevelValF = 0
;res@cnMaxLevelValF = 75 
res@cnLevelSelectionMode = "ExplicitLevels"
res@cnLevels = (/5/)
;res@cnFillColors = colors
res@gsnSpreadColors = True
res@gsnSpreadColorStart = 8
res@gsnSpreadColorEnd = 128
res@cnLineColor = "blue"
res@cnLineLabelFontColor = "blue"
res@cnLineLabelsOn = False
res@cnLineThicknessF = 7.0
res@cnLineLabelAngleF = 0.0
res@cnLineLabelInterval = 1
res@cnLineLabelDensityF = .77
res@cnLabelMasking = True
res@cnLineLabelBackgroundColor = -1
res@cnLineLabelFontHeightF = 0.01 
res@cnLineDashPattern = 6 

res@lbAutoManage = False                   ; Label Bar Information
res@pmLabelBarOrthogonalPosF = .02  
res@pmLabelBarHeightF = 0.08
res@pmLabelBarWidthF = 0.41
res@lbLabelAutoStride = False
res@lbLabelFontHeightF = .011
res@lbBoxLinesOn  = True                   ; Outline the color bar 
res@lbTopMarginF = .3
res@cnInfoLabelOn = False 
res@lbLabelStride = 1 
res@lbLabelFontColor = "black"
res@cnExplicitLabelBarLabelsOn = True
res@lbLabelStrings = (/"1"," "," "," "," "," "," "," "," ","10"," "," "," "," "," "," "," "," "," ","20"," "," "," "," "," "," "," "," "," ","30"," "," "," "," "," "," "," "," "," ","40"," "," "," "," "," "," "," "," "," ","50"," "," "," "," "," "," "," "," "," ","60"," "," "," "," "," "," "," "," "," ","70"," "," "," "," "," "," "," "," "," ","80"," "," "," "," "," "," "," "," "," ","90"," "," "," "," "," "," "," "," ","99"/)

res@mpGridAndLimbOn        = True
res@mpGridLineDashPattern  = 5                  ; lat/lon lines dashed
res@mpGridLatSpacingF      = 5
res@mpGridLonSpacingF      = 5
res@mpGridLineColor = "grey25"
res@mpGridLineThicknessF = 2


;---------------------------------------------------

res@mpProjection = "CylindricalEquidistant"
res@mpMinLatF = minlat
res@mpMaxLatF = maxlat
res@mpMinLonF = minlon
res@mpMaxLonF = maxlon

;res@mpProjection = "CylindricalEquidistant"
;res@mpMinLatF = 0.
;res@mpMaxLatF = 40.
;res@mpMinLonF = 170.
;res@mpMaxLonF = 260.


lat_adj = 0.
lon_adj = 0.

if int_time .eq. 2018081400 then
lat_adj = -2.
lon_adj = 24.
end if

;res@mpProjection = "CylindricalEquidistant"
;res@mpMinLatF = 6.+lat_adj
;res@mpMaxLatF = 35.+lat_adj
;res@mpMinLonF = 179.+lon_adj
;res@mpMaxLonF = 224.+lon_adj

res@pmTickMarkDisplayMode = "Always"
res@gsnMajorLatSpacing = 10
res@gsnMajorLonSpacing = 10

;res@tmXBOn = True
;res@tmXBLabelsOn = True
;res@tmXBMode = "Manual"
;res@tmXBTickStartF = 0
;res@tmXBTickEndF = 360
res@tmXBTickSpacingF = 20 
;res@tmXBValues = ispan(0,360,20)
;res@tmXBLabels = (/"160~F34~0~F~W","180~F34~0","160~F34~0~F~E","140~F34~0~F~E","120~F34~0~F~E","100~F34~0~F~E","160~F34~0~F~W","180~F34~0","160~F34~0~F~E","140~F34~0~F~E","120~F34~0~F~E","100~F34~0~F~E"/)
res@tmXBLabelFontHeightF = .011
res@tmXBMajorLengthF = .01
;res@tmXBMinorLengthF = .006
;res@tmXBMinorValues = (/-115.0,-105.0,-95.0,-85.0,-75.0,-65.0,-55.0,-45.0,-35.0/)

;res@tmYLOn = True
;res@tmYLLabelsOn = True
;res@tmYLMode = "Explicit" 
;res@tmYLValues = ispan(20,80,20)
;res@tmYLLabels = (/"20~F34~0~F~N","40~F34~0~F~N","60~F34~0~F~N","80~F34~0~F~N"/)
res@tmYLLabelFontHeightF = .011
;res@tmYLMinorValues = (/32.5,37.5,42.5,47.5,52.5,57.5/)

res@tmYROn = False
res@tmXTOn = False

res@gsnLeftString = "Model: ("+model+") Initialized:  "+int_time
res@gsnLeftStringOrthogonalPosF = .0075 
res@gsnLeftStringFontHeightF = .008
res@gsnRightString = "Mean Track and Probability (5%) that TC center passes within "+dist+" km"
res@gsnRightStringOrthogonalPosF = .0075
res@gsnRightStringFontHeightF = .008

;********************************************

res2 = res

res2@cnLineColor = "red"
res2@cnLineLabelFontColor = "red"
res2@gsnLeftString = " "
res2@gsnRightString = " "

;*********************************************

res3 = res

res3@cnLineColor = "grey30"
res3@cnLineLabelFontColor = "grey30"
res3@gsnLeftString = " "
res3@gsnRightString = " "

;********************************************
res@mpFillOn = True
res@mpOutlineOn = True
res@cnFillDrawOrder = "PreDraw"
res@mpFillDrawOrder = "PreDraw"
res@mpOutlineDrawOrder = "Draw"
res@mpGridAndLimbDrawOrder = "PostDraw"

res2@mpFillOn = False
res2@mpOutlineOn = False

plot = gsn_csm_contour_map(wks, count3b, res)
ecdensity = gsn_csm_contour(wks, count2b, res2) 
gefsdensity = gsn_csm_contour(wks, count1b, res3)

overlay(plot,ecdensity)
overlay(plot,gefsdensity)


;************************************************************************
;************************************************************************
;************************************************************************
;************************************************************************

; Read in CMC mean track from file

track_url = "./"
trk_read := asciiread(track_url+"cmc_det_mean_"+int_time+"_"+TCname+".csv",-1,"string")

delim = ", "
nfields := str_fields_count(trk_read, delim)
;print("nfields: "+nfields)

print("Obtaining data from file of unknown length...")

yyyy_arr_temp := str_get_field(trk_read, 1, delim)
mm_arr_temp := str_get_field(trk_read, 2, delim)
dd_arr_temp := str_get_field(trk_read, 3, delim)
hh_arr_temp := str_get_field(trk_read, 4, delim)
mslp_arr_temp := str_get_field(trk_read, 5, delim)
rlat_arr_temp := str_get_field(trk_read, 6, delim)
rlon_arr_temp := str_get_field(trk_read, 7, delim)
wind_arr_temp := str_get_field(trk_read, 8,delim)
cyc_arr_temp := str_get_field(trk_read, 9,delim)

;printVarSummary(yyyy_arr_temp)

iz := ind(yyyy_arr_temp .eq. cur_year)
;print(iz)

hh_arr := todouble(hh_arr_temp(iz))
rlat_arr := todouble(rlat_arr_temp(iz))
rlon_arr := todouble(rlon_arr_temp(iz))
cyc_arr := todouble(cyc_arr_temp(iz))

print(cyc_arr)

print(" ")
print("Lat/Lons successfully collected from file")

;************************************************************************

tkres = True
tkres@gsLineColor = "blue"
tkres@gsLineThicknessF = 15

dres = True
dres@gsMarkerColor = "blue"
dres@gsMarkerIndex = 1
dres@gsMarkerSizeF = 0.024

timres = True
timres@txFontHeightF = .008

length := doubletoint(dimsizes(cyc_arr))
line2b = new(length,graphic)
dot3b = new(length,graphic)
dot4b = new(length,graphic)

l_lat := new(length,double,0)
l_lon := new(length,double,0)
previous_cyc = todouble(-1)

start_position = 0
spot = 0
cyc_num = 1

;***********************************************************

startpoint = 0
toolong = 0

endvar = dimsizes(cyc_arr)-1

do i = 1,endvar
  previous2_cyc = todouble(-2)
  previous_cyc = cyc_arr(i-1)
  current_cyc = cyc_arr(i)
  l_lat(i-1) = rlat_arr(i-1)
  l_lon(i-1) = rlon_arr(i-1)
  l_lat(i) = rlat_arr(i)
  l_lon(i) = rlon_arr(i)

print("current_cyc: "+current_cyc+" | previous_cyc: "+previous_cyc)

        if (current_cyc .ne. previous_cyc) .or. (i .eq. endvar) then
                print(" ")
                print("******Starting cyclone "+previous_cyc+"******")
                cyc_num = cyc_num + 1
                if i .eq. endvar then
                        endpoint = i-1
                else
                    endpoint = i-2
                end if

                print("startpoint: "+startpoint)
                print("endpoint: "+endpoint)

                do h = startpoint,endpoint
                        spot = spot + 1
;                       print("Line Drawn: "+spot)
                        l_lat_plot := (/l_lat(h),l_lat(h+1)/)
                l_lon_plot := (/l_lon(h),l_lon(h+1)/)
;               print("last lat: "+l_lat(h+1))

                print("cyc_num: "+cyc_num)

                if cyc_num .eq. 2 then

                        line2b(spot-1) = gsn_add_polyline(wks,plot,l_lon_plot,l_lat_plot,tkres)

                        if hh_arr(h) .eq. 0 .or. hh_arr(h) .eq. 12 then
;                       print("hh: "+hh_arr(h))
                        dot3b(spot-1) = gsn_add_polymarker(wks,plot,l_lon(h),l_lat(h),dres)
                        end if

                        if (h .eq. endpoint) .and. (hh_arr(h) .eq. 6 .or. hh_arr(h) .eq. 18) then
                            print("At endpoint!")
                            dot4b(spot-1) = gsn_add_polymarker(wks,plot,l_lon(h+1),l_lat(h+1),dres)
                        end if
                end if

                end do ; end h

                startpoint = i
        end if

        previous_cyc = cyc_arr(i)
        previous2_cyc = cyc_arr(i-1)
end do  ; end plot tracks



;************************************************************************
;************************************************************************
;************************************************************************
;************************************************************************

; Read in EC mean track from file

track_url = "./"
trk_read := asciiread(track_url+"ec_det_mean_"+int_time+"_"+TCname+".csv",-1,"string")

delim = ", "
nfields := str_fields_count(trk_read, delim)
;print("nfields: "+nfields)

print("Obtaining data from file of unknown length...")

yyyy_arr_temp := str_get_field(trk_read, 1, delim)
mm_arr_temp := str_get_field(trk_read, 2, delim)
dd_arr_temp := str_get_field(trk_read, 3, delim)
hh_arr_temp := str_get_field(trk_read, 4, delim)
mslp_arr_temp := str_get_field(trk_read, 5, delim)
rlat_arr_temp := str_get_field(trk_read, 6, delim)
rlon_arr_temp := str_get_field(trk_read, 7, delim)
wind_arr_temp := str_get_field(trk_read, 8,delim)
cyc_arr_temp := str_get_field(trk_read, 9,delim)

;printVarSummary(yyyy_arr_temp)

iz := ind(yyyy_arr_temp .eq. cur_year)
;print(iz)

hh_arr := todouble(hh_arr_temp(iz))
rlat_arr := todouble(rlat_arr_temp(iz))
rlon_arr := todouble(rlon_arr_temp(iz))
cyc_arr := todouble(cyc_arr_temp(iz))

print(cyc_arr)

print(" ")
print("Lat/Lons successfully collected from file")

;************************************************************************

tkres = True
tkres@gsLineColor = "red"
tkres@gsLineThicknessF = 15

dres = True
dres@gsMarkerColor = "red"
dres@gsMarkerIndex = 1
dres@gsMarkerSizeF = 0.024

timres = True
timres@txFontHeightF = .008

length := doubletoint(dimsizes(cyc_arr))
line2c = new(length,graphic)
dot3c = new(length,graphic)
dot4c = new(length,graphic)

l_lat := new(length,double,0)
l_lon := new(length,double,0)
previous_cyc = todouble(-1)

start_position = 0
spot = 0
cyc_num = 1

;***********************************************************

startpoint = 0
toolong = 0

endvar = dimsizes(cyc_arr)-1

do i = 1,endvar
  previous2_cyc = todouble(-2)
  previous_cyc = cyc_arr(i-1)
  current_cyc = cyc_arr(i)
  l_lat(i-1) = rlat_arr(i-1)
  l_lon(i-1) = rlon_arr(i-1)
  l_lat(i) = rlat_arr(i)
  l_lon(i) = rlon_arr(i)

print("current_cyc: "+current_cyc+" | previous_cyc: "+previous_cyc)

        if (current_cyc .ne. previous_cyc) .or. (i .eq. endvar) then
                print(" ")
                print("******Starting cyclone "+previous_cyc+"******")
                cyc_num = cyc_num + 1
                if i .eq. endvar then
                        endpoint = i-1
                else
                    endpoint = i-2
                end if

                print("startpoint: "+startpoint)
                print("endpoint: "+endpoint)

                do h = startpoint,endpoint
                        spot = spot + 1
;                       print("Line Drawn: "+spot)
                        l_lat_plot := (/l_lat(h),l_lat(h+1)/)
                l_lon_plot := (/l_lon(h),l_lon(h+1)/)
;               print("last lat: "+l_lat(h+1))

                print("cyc_num: "+cyc_num)

                if cyc_num .eq. 2 then

                        line2c(spot-1) = gsn_add_polyline(wks,plot,l_lon_plot,l_lat_plot,tkres)

                        if hh_arr(h) .eq. 0 .or. hh_arr(h) .eq. 12 then
;                       print("hh: "+hh_arr(h))
                        dot3c(spot-1) = gsn_add_polymarker(wks,plot,l_lon(h),l_lat(h),dres)
                        end if

                        if (h .eq. endpoint) .and. (hh_arr(h) .eq. 6 .or. hh_arr(h) .eq. 18) then
                            print("At endpoint!")
                            dot4c(spot-1) = gsn_add_polymarker(wks,plot,l_lon(h+1),l_lat(h+1),dres)
                        end if
                end if

                end do ; end h

                startpoint = i
        end if

        previous_cyc = cyc_arr(i)
        previous2_cyc = cyc_arr(i-1)
end do  ; end plot tracks



;************************************************************************
;************************************************************************
;************************************************************************
;************************************************************************

; Read in GEFS mean track from file

track_url = "./"
trk_read := asciiread(track_url+"gefs_det_mean_"+int_time+"_"+TCname+".csv",-1,"string")

delim = ", "
nfields := str_fields_count(trk_read, delim)
;print("nfields: "+nfields)

print("Obtaining data from file of unknown length...")

yyyy_arr_temp := str_get_field(trk_read, 1, delim)
mm_arr_temp := str_get_field(trk_read, 2, delim)
dd_arr_temp := str_get_field(trk_read, 3, delim)
hh_arr_temp := str_get_field(trk_read, 4, delim)
mslp_arr_temp := str_get_field(trk_read, 5, delim)
rlat_arr_temp := str_get_field(trk_read, 6, delim)
rlon_arr_temp := str_get_field(trk_read, 7, delim)
wind_arr_temp := str_get_field(trk_read, 8,delim)
cyc_arr_temp := str_get_field(trk_read, 9,delim)

;printVarSummary(yyyy_arr_temp)

iz := ind(yyyy_arr_temp .eq. cur_year)
;print(iz)

hh_arr := todouble(hh_arr_temp(iz))
rlat_arr := todouble(rlat_arr_temp(iz))
rlon_arr := todouble(rlon_arr_temp(iz))
cyc_arr := todouble(cyc_arr_temp(iz))

print(cyc_arr)

print(" ")
print("Lat/Lons successfully collected from file")

;************************************************************************

tkres = True
tkres@gsLineColor = "grey30"
tkres@gsLineThicknessF = 15

dres = True
dres@gsMarkerColor = "grey30"
dres@gsMarkerIndex = 1
dres@gsMarkerSizeF = 0.024

timres = True
timres@txFontHeightF = .008 

length := doubletoint(dimsizes(cyc_arr))
line2 = new(length,graphic)
dot3 = new(length,graphic)
dot4 = new(length,graphic)

l_lat := new(length,double,0)
l_lon := new(length,double,0)
previous_cyc = todouble(-1)

start_position = 0
spot = 0
cyc_num = 1

;***********************************************************

startpoint = 0
toolong = 0

endvar = dimsizes(cyc_arr)-1

do i = 1,endvar
  previous2_cyc = todouble(-2)
  previous_cyc = cyc_arr(i-1)
  current_cyc = cyc_arr(i)
  l_lat(i-1) = rlat_arr(i-1)
  l_lon(i-1) = rlon_arr(i-1)
  l_lat(i) = rlat_arr(i)
  l_lon(i) = rlon_arr(i)
 
print("current_cyc: "+current_cyc+" | previous_cyc: "+previous_cyc)
 
	if (current_cyc .ne. previous_cyc) .or. (i .eq. endvar) then
		print(" ")
   		print("******Starting cyclone "+previous_cyc+"******")
   		cyc_num = cyc_num + 1
   		if i .eq. endvar then
   			endpoint = i-1
   		else
   		    endpoint = i-2
   		end if
   		
   		print("startpoint: "+startpoint)
   		print("endpoint: "+endpoint)

  		do h = startpoint,endpoint
  	  		spot = spot + 1
;  			print("Line Drawn: "+spot)
  			l_lat_plot := (/l_lat(h),l_lat(h+1)/)
    		l_lon_plot := (/l_lon(h),l_lon(h+1)/)
;    		print("last lat: "+l_lat(h+1))
    
                print("cyc_num: "+cyc_num)
	
    		if cyc_num .eq. 2 then

			line2(spot-1) = gsn_add_polyline(wks,plot,l_lon_plot,l_lat_plot,tkres)
			
			if hh_arr(h) .eq. 0 .or. hh_arr(h) .eq. 12 then
;			print("hh: "+hh_arr(h))
			dot3(spot-1) = gsn_add_polymarker(wks,plot,l_lon(h),l_lat(h),dres)			
			end if
			
			if (h .eq. endpoint) .and. (hh_arr(h) .eq. 6 .or. hh_arr(h) .eq. 18) then
			    print("At endpoint!")
				dot4(spot-1) = gsn_add_polymarker(wks,plot,l_lon(h+1),l_lat(h+1),dres)
			end if
                end if 
			
		end do ; end h
		
		startpoint = i
	end if
	
	previous_cyc = cyc_arr(i)
	previous2_cyc = cyc_arr(i-1)
end do  ; end plot tracks 

;************************************************************************
;************************************************************************
;************************************************************************
;************************************************************************

; Read in BEST TRACK file with cyclone tracks

btrack_url = "./"
btrk_read = asciiread(btrack_url+"best_track_"+TCname+".csv",-1,"string")

delim = ", "
nfields := str_fields_count(btrk_read, delim)
;print("nfields: "+nfields)

print("Obtaining data from file of unknown length...")

yyyy_arr_temp := str_get_field(btrk_read, 1, delim)
mm_arr_temp := str_get_field(btrk_read, 2, delim)
dd_arr_temp := str_get_field(btrk_read, 3, delim)
hh_arr_temp := str_get_field(btrk_read, 4, delim)
mslp_arr_temp := str_get_field(btrk_read, 5, delim)
rlat_arr_temp := str_get_field(btrk_read, 6, delim)
rlon_arr_temp := str_get_field(btrk_read, 7, delim)
wind_arr_temp := str_get_field(btrk_read, 8,delim)
cyc_arr_temp := str_get_field(btrk_read, 9,delim)

;printVarSummary(yyyy_arr_temp)

iz := ind(yyyy_arr_temp .eq. cur_year)
;print(iz)

dd_arr := todouble(dd_arr_temp(iz))
hh_arr := todouble(hh_arr_temp(iz))
rlat_arr := todouble(rlat_arr_temp(iz))
rlon_arr := todouble(rlon_arr_temp(iz))
cyc_arr := todouble(cyc_arr_temp(iz))

print(cyc_arr)

print(" ")
print("Lat/Lons successfully collected from file")


;************************************************************************

tkres = True
tkres@gsLineColor = "black"
tkres@gsLineThicknessF = 16

dres = True
dres@gsMarkerColor = "black"
dres@gsMarkerIndex = 1
dres@gsMarkerSizeF = 0.026

timres = True
timres@txFontColor = "black"
timres@txFontHeightF = .008 

length := doubletoint(dimsizes(cyc_arr))
line = new(length,graphic)
dot = new(length,graphic)
dot2 = new(length,graphic)
time = new(length,graphic)
time2 = new(length,graphic)

l_lat := new(length,double,0)
l_lon := new(length,double,0)
previous_cyc = todouble(-1)

start_position = 0
spot = 0
cyc_num = 1
array2check = ispan(945,1000,1)

;***********************************************************

startpoint = 0
toolong = 0

endvar = dimsizes(cyc_arr)-1

do i = 1,endvar
  previous2_cyc = todouble(-2)
  previous_cyc = cyc_arr(i-1)
  current_cyc = cyc_arr(i)
  l_lat(i-1) = rlat_arr(i-1)
  l_lon(i-1) = rlon_arr(i-1)
  l_lat(i) = rlat_arr(i)
  l_lon(i) = rlon_arr(i)
  
	if (current_cyc .ne. previous_cyc) .or. (i .eq. endvar) then
		print(" ")
   		print("******Starting cyclone "+previous_cyc+"******")
   		cyc_num = cyc_num + 1
   		endpoint = i-1
   		
   		print("startpoint: "+startpoint)
   		print("endpoint: "+endpoint)

  		do h = startpoint,endpoint
  	  		spot = spot + 1
;  			print("Line Drawn: "+spot)
  			l_lat_plot := (/l_lat(h),l_lat(h+1)/)
    		l_lon_plot := (/l_lon(h),l_lon(h+1)/)
;    		print("last lat: "+l_lat(h+1))
    	
 ;   		value2check := pres_arr(h)
 ;   		index = closest_val(value2check,array2check)
    		tkres@gsLineColor = dres@gsMarkerColor             ;colors(index)
			line(spot-1) = gsn_add_polyline(wks,plot,l_lon_plot,l_lat_plot,tkres)
			
			if hh_arr(h) .eq. 0 .or. hh_arr(h) .eq. 12 then
;			print("hh: "+hh_arr(h))
			dot(spot-1) = gsn_add_polymarker(wks,plot,l_lon(h),l_lat(h),dres)			
			
				if hh_arr(h) .eq. 0 then
				label = dd_arr(h)
				time(spot-1) = gsn_add_text(wks,plot,tofloat(label),l_lon(h),l_lat(h)-0.5,timres)
				end if
			end if
			
			if (h .eq. endpoint) .and. (hh_arr(h) .eq. 6 .or. hh_arr(h) .eq. 18) then
			    print("At endpoint!")
			    print(" ")
				dot2(spot-1) = gsn_add_polymarker(wks,plot,l_lon(h+1),l_lat(h+1),dres)
			end if
			
		end do ; end h
		
		startpoint = i
	end if
	
	previous_cyc = cyc_arr(i)
	previous2_cyc = cyc_arr(i-1)
end do  ; end plot tracks 

;********************************************

draw(plot)
frame(wks)

;********************************************

system("convert -trim "+name+".png "+name+".png")
;system ("scp "+name+".png abentley@emcrzdm.ncep.noaa.gov:"+dir_out_web+".")

print(" ")
print("**************")
print(" END SCRIPT ")
print("**************")
print(" ")

end
