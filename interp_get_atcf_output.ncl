tcf_output.ncl
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
slat = str_get_field(trk_read, 7, delim)
slon = str_get_field(trk_read, 8, delim)
model_type = str_get_field(trk_read, 5, delim)
fhr = str_get_field(trk_read,6, delim)
wind = str_get_field(trk_read,9,delim)
mslp = str_get_field(trk_read,10,delim)
radii = str_get_field(trk_read,12,delim)

;;;; now that we have done that, lets find a way to discriminate
;;;; pick a model, pick a time and pick a radii

cv_yr = toint(str_get_cols(time_str,0,3))
cv_mo = toint(str_get_cols(time_str,4,5))
cv_day = toint(str_get_cols(time_str,6,7))
cv_hr = toint(str_get_cols(time_str,8,9))

base_time = cd_inv_calendar(cv_yr,cv_mo,cv_day,cv_hr,0,0,"hours since 1800-01-01 00:00:00",0)

;print(cd_string(base_time,""))
  
atcf_ind = ind(model_type .eq. model .and. time .eq. time_str .and. radii .eq. "34") 
atcf_lat = tofloat(slat(atcf_ind))
atcf_lon = tofloat(slon(atcf_ind))
atcf_wind = tofloat(wind(atcf_ind))
atcf_mslp = tofloat(mslp(atcf_ind))
atcf_time = toint(time(atcf_ind))
atcf_fhr = toint(fhr(atcf_ind))
atcf_radii = tofloat(radii(atcf_ind))
  
;;;; fix lat and lon to coordinates we can use!!!

print(atcf_lon)
hemi = str_get_cols(slon(atcf_ind),4,4)
print(hemi)

atcf_lat = atcf_lat / 10

do k = 0,dimsizes(atcf_lon)-1

        if hemi(k) .eq. "W" then
                atcf_lon(k) = 360 + ((atcf_lon(k) / 10) * -1)
        else if hemi(k) .eq. "E" then
                atcf_lon(k) = (atcf_lon(k) / 10)
        else
		atcf_lon(k) = 360 + ((atcf_lon(k) / 10) * -1)
	end if
        end if

end do

;print(atcf_lon)

;;;; okay last part is put lat lon and time all in one file

atcf_actual_ftime = atcf_fhr + base_time
atcf_actual_ftime@units = "hours since 1800-01-01 00:00:00"

atcf_lat_lon = new((/dimsizes(atcf_lat),2/),"float")
atcf_lat_lon(:,0) = atcf_lat
atcf_lat_lon(:,1) = atcf_lon

atcf_lat_lon!0 = "time"
;atcf_lat_lon&time = cd_convert(atcf_actual_ftime,time_tot@units)
atcf_lat_lon&time = atcf_actual_ftime

;print(atcf_lat_lon(:,0))
;print(atcf_lat_lon(:,1))
;print(atcf_lat_lon&time)

atcf_hr_times = cd_convert(atcf_lat_lon&time,"hours since 1800-01-01 00:00:00")
;print(atcf_hr_times)

;-------------------------------------------------------

;;;;; lets interpolate tracks to 6h positions

atcf_time_interp := new((dimsizes(atcf_hr_times)*2)-1,"double")
atcf_mslp_interp := new((dimsizes(atcf_hr_times)*2)-1,"double")
atcf_lat_interp := new((dimsizes(atcf_hr_times)*2)-1,"double")
atcf_lon_interp := new((dimsizes(atcf_hr_times)*2)-1,"double")
atcf_wind_interp := new((dimsizes(atcf_hr_times)*2)-1,"double")

printVarSummary(atcf_time_interp)

do i = 0,dimsizes(atcf_hr_times)-2
hr_time = fspan(atcf_hr_times(i),atcf_hr_times(i+1),3)
hr_lat = fspan(atcf_lat_lon(i,0),atcf_lat_lon(i+1,0),3)
hr_lon = fspan(atcf_lat_lon(i,1),atcf_lat_lon(i+1,1),3)

atcf_time_interp(0+(i*2):2+(i*2)) = hr_time
atcf_mslp_interp(0+(i*2):2+(i*2)) = atcf_mslp(i)
atcf_lat_interp(0+(i*2):2+(i*2)) = hr_lat
atcf_lon_interp(0+(i*2):2+(i*2)) = hr_lon
atcf_wind_interp(0+(i*2):2+(i*2)) = atcf_wind(i)

end do

atcf_time_interp@units = opt@timeUnits

;time_day_convert = cd_convert(atcf_time_interp,time_tot@units)

time_day_convert = atcf_time_interp

atcf_lat_interp!0 = "time"
atcf_lat_interp&time = time_day_convert
copy_VarCoords(atcf_lat_interp,atcf_lon_interp)

;-------------------------------------------------------
print(dimsizes(atcf_time_interp))

atcf_fnl_output := new((/5,dimsizes(atcf_time_interp)/),"double")
atcf_fnl_output(0,:) = (/atcf_time_interp/)
atcf_fnl_output(1,:) = (/atcf_mslp_interp/)
atcf_fnl_output(2,:) = (/atcf_lat_interp/)
atcf_fnl_output(3,:) = (/atcf_lon_interp/)
atcf_fnl_output(4,:) = (/atcf_wind_interp/)

;printVarSummary(atcf_fnl_output)

atcf_fnl_output!1 = "time"

printVarSummary(atcf_fnl_output)
atcf_fnl_output&time = time_day_convert
atcf_fnl_output&time@units = opt@timeUnits

return(atcf_fnl_output)

end 

