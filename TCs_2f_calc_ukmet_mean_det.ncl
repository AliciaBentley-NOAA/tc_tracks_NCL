;;;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>;;
;;
;; Calculates and creates UKMET ensemble mean and det. .csv file from other files
;;
;;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>;;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/ut_string.ncl"
load "./get_atcf_output.ncl"
;************************************************************************

begin

print(" ")
print("**************")
print(" START SCRIPT ")
print("**************")
print(" ")

cur_year = 2024
int_time = 2024062912
TCname = "beryl"

;-------------------------------------------------------------------------

dir_out = "./"
track_url = "./"
model = "ukmet"
trk_read := asciiread(track_url+model+"_"+int_time+"_"+TCname+".csv",-1,"string")
filename_mean := model+"_det_mean_"+int_time+"_"+TCname+".csv"

calc_arr := new((/4,33,36/),"double")
date_arr := new((/4,33/),"double")
outlines := new((/3000/),"string")
outlines2 := new((/3000/),"string")
prev_ens = -1
line_num = 0

delim = ", "
nfields = str_fields_count(trk_read, delim)
;print("nfields: "+nfields)

print("Obtaining data from file of unknown length...")

yyyy_arr_temp = str_get_field(trk_read, 1, delim)
mm_arr_temp = str_get_field(trk_read, 2, delim)
dd_arr_temp = str_get_field(trk_read, 3, delim)
hh_arr_temp = str_get_field(trk_read, 4, delim)
mslp_arr_temp = str_get_field(trk_read, 5, delim)
rlat_arr_temp = str_get_field(trk_read, 6, delim)
rlon_arr_temp = str_get_field(trk_read, 7, delim)
wind_arr_temp = str_get_field(trk_read, 8,delim)
cyc_arr_temp = str_get_field(trk_read, 9,delim)

;printVarSummary(yyyy_arr_temp)

iz = ind(yyyy_arr_temp .eq. cur_year)
;print(iz)

yyyy_arr = yyyy_arr_temp(iz)
mm_arr = mm_arr_temp(iz)
dd_arr = dd_arr_temp(iz)
hh_arr = hh_arr_temp(iz)
mslp_arr = mslp_arr_temp(iz)
rlat_arr = rlat_arr_temp(iz)
rlon_arr = rlon_arr_temp(iz)
wind_arr = wind_arr_temp(iz)
cyc_arr = cyc_arr_temp(iz)

;print(cyc_arr)

lines = dimsizes(cyc_arr)

do timestep = 0,lines-1,1

number = timestep + 1
;print("Obtaining line: "+number+" of "+lines)

yyyy = todouble(yyyy_arr(timestep))
mm = todouble(mm_arr(timestep))
dd = todouble(dd_arr(timestep))
hh = todouble(hh_arr(timestep))
pres = todouble(mslp_arr(timestep))
rlat = tofloat(rlat_arr(timestep))
rlon = tofloat(rlon_arr(timestep))
wind = todouble(wind_arr(timestep))
ens = todouble(cyc_arr(timestep))

if ens .ne. prev_ens then
        print("New ensemble!")
        spot = 0
	prev_ens := ens
end if

if (ens .eq. 0) .and. (spot .eq. 0) then
	print("yyyy: "+yyyy+" mm: "+mm+" dd: "+dd+" hh: "+hh+" spot: "+spot)
	timeUnits = "hours since 1800-01-01 00:00:00"
	sdate = cd_inv_calendar(toint(yyyy),toint(mm),toint(dd),toint(hh),00,00,timeUnits,0)
	cdate = sdate
        dspot = 0

	do fill = 0,33-1,1
;        do fill = 0,9-1,1
		str_yyyy = ut_string(cdate,"%Y")
		str_mm = ut_string(cdate,"%N")		
		str_dd = ut_string(cdate,"%D")
		str_hh = ut_string(cdate,"%H")

		date_arr(0,dspot) = todouble(str_yyyy) 
		date_arr(1,dspot) = todouble(str_mm)
		date_arr(2,dspot) = todouble(str_dd)
		date_arr(3,dspot) = todouble(str_hh)

		dspot = dspot + 1
		cdate = cdate + 6
	end do

;print(date_arr(0:3,:))

end if     ; ens

print("pres: "+pres+" rlat: "+rlat+" rlon: "+rlon+" wind: "+wind+" ens: "+ens)
print(" ")
calc_arr(0,spot,toint(ens)) = pres
calc_arr(1,spot,toint(ens)) = rlat
calc_arr(2,spot,toint(ens)) = rlon
calc_arr(3,spot,toint(ens)) = wind
spot = spot + 1
end do    ; end timestep (aka: finding lat/lons to plot)

print(" ")
print("Lat/Lons successfully collected from file")

ens_mean = dim_avg_n_Wrap(calc_arr,2)
ens_mean!0 = "var"
ens_mean!1 = "fcst"
printVarSummary(ens_mean)

print(ens_mean(0,:))

;do j = 0,9-1,1
do j = 0,33-1,1

if (.not.ismissing(ens_mean(0,j))) then
        line = date_arr(0,j)+", "+date_arr(1,j)+", "+date_arr(2,j)+", "+date_arr(3,j)+", "+ens_mean(0,j)+", "+ens_mean(1,j)+", "+ens_mean(2,j)+", "+ens_mean(3,j)+", 36"
        print("line: "+line)
        print("line_num: "+line_num)
        outlines(line_num) = line
        line_num = line_num + 1
end if

end do

;-------------------------------------------------------------------

lines_d = 21
fileread := asciiread("ukmet_det_"+int_time+"_"+TCname+".csv",(/lines_d,9/),"float")

do timestep = 0,lines_d-1

number = timestep + 1
print("Obtaining line: "+number+" of "+lines_d)

year = flt2dble(fileread(timestep,0))
month = flt2dble(fileread(timestep,1))
day = flt2dble(fileread(timestep,2))
hour = flt2dble(fileread(timestep,3))
mslp = decimalPlaces(flt2dble(fileread(timestep,4)),2,True)
lat = tofloat(fileread(timestep,5))
lon = tofloat(fileread(timestep,6))
wind = flt2dble(fileread(timestep,7))
ensemble = 37

        line = year+", "+month+", "+day+", "+hour+", "+mslp+", "+lat+", "+lon+", "+wind+", "+ensemble
        print("line: "+line)
        print("line_num: "+line_num)
        outlines(line_num) = line
        line_num = line_num + 1
end do

        asciiwrite(dir_out+filename_mean, outlines)

print(" ")
print("**************")
print(" END SCRIPT ")
print("**************")
print(" ")

end
