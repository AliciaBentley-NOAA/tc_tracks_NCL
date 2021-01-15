; 
; Alicia Bentley
; Last Updated: 25 September 2018
;
; Basic Description: Obtains ATCF output needed for a script
; 
;
;###############################################################################

undef("get_atcf")
function get_atcf(name,model,time_str,opt)
begin

atcf_url = "./"

; INPUTS ARE:
; name = "aal062018"
; model = "AP01"
; time_str = "2018090100"
; opt = True

;;;; parse data file to obtain GFS track

trk_read = asciiread(atcf_url+name+".dat",-1,"string")
delim = ", "
nfilds = str_fields_count(trk_read(0), delim)
  
;;;; okay lets get the one tcg pathway letter
  
time = str_get_field(trk_read, 3, delim)
slat = str_get_field(trk_read, 6, delim)
slon = str_get_field(trk_read, 7, delim)
model_type = str_get_field(trk_read, 4, delim)
fhr = str_get_field(trk_read, 5, delim)
wind = str_get_field(trk_read, 8,delim)
mslp = str_get_field(trk_read, 9,delim)
radii = str_get_field(trk_read, 11,delim)

;;;; now that we have done that, lets find a way to discriminate
;;;; pick a model, pick a time and pick a radii

cv_yr = toint(str_get_cols(time_str,0,3))
cv_mo = toint(str_get_cols(time_str,4,5))
cv_day = toint(str_get_cols(time_str,6,7))
cv_hr = toint(str_get_cols(time_str,8,9))

base_time = cd_inv_calendar(cv_yr,cv_mo,cv_day,cv_hr,0,0,"hours since 1800-01-01 00:00:00",0)

print("base_time: "+cd_string(base_time,""))

check_hr = toint(str_get_cols(time,8,9))

;print("mslp: "+mslp)
;print("check_hr: "+check_hr)
  
atcf_ind = ind(model_type .eq. model .and. (check_hr .eq. 0 .or. check_hr .eq. 6 .or. check_hr .eq. 12 .or. check_hr .eq. 18) .and. (radii .eq. "34" .or. radii .eq. "0"))
print(atcf_ind)
 
atcf_lat = tofloat(slat(atcf_ind))
atcf_lon = tofloat(slon(atcf_ind))
atcf_wind = tofloat(wind(atcf_ind))
atcf_mslp = tofloat(mslp(atcf_ind))
atcf_time = toint(time(atcf_ind))
atcf_fhr = toint(fhr(atcf_ind))
atcf_radii = tofloat(radii(atcf_ind))
 
printVarSummary(atcf_mslp)
 
;;;; fix lat and lon to coordinates we can use!!!

atcf_lat = atcf_lat / 10
atcf_lon = 360 + ((atcf_lon / 10) * -1)

;;;; okay last part is put lat lon and time all in one file

atcf_actual_ftime = base_time + (ispan(0,dimsizes(atcf_ind),1)*6)
atcf_actual_ftime@units = "hours since 1800-01-01 00:00:00"
printVarSummary(atcf_actual_ftime)

atcf_lat_lon = new((/dimsizes(atcf_lat),2/),"float")
atcf_lat_lon(:,0) = atcf_lat
atcf_lat_lon(:,1) = atcf_lon

;atcf_lat_lon!0 = "time"
;atcf_lat_lon&time = cd_convert(atcf_actual_ftime,time_tot@units)
;atcf_lat_lon&time = atcf_actual_ftime

;print(atcf_lat_lon(:,0))
;print(atcf_lat_lon(:,1))
;print(atcf_lat_lon&time)

atcf_hr_times = cd_convert(atcf_actual_ftime,"hours since 1800-01-01 00:00:00")
;print(atcf_hr_times)

;-------------------------------------------------------

atcf_fnl_output := new((/5,dimsizes(atcf_mslp)/),"float")
atcf_fnl_output(0,:) = (/tofloat(atcf_hr_times(0:dimsizes(atcf_hr_times)-2))/)
atcf_fnl_output(1,:) = (/atcf_mslp/)
atcf_fnl_output(2,:) = (/atcf_lat_lon(:,0)/)
atcf_fnl_output(3,:) = (/atcf_lat_lon(:,1)/)
atcf_fnl_output(4,:) = (/atcf_wind/)

;atcf_fnl_output!0 = "time"

;printVarSummary(atcf_fnl_output)
;atcf_fnl_output&time = atcf_hr_times(0:dimsizes(atcf_hr_times)-2)
;atcf_fnl_output&time@units = opt@timeUnits

return(atcf_fnl_output)

end 

