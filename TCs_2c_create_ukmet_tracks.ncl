;;;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>;a
;;
;; Creates GEFS TC track .csv files from a-deck .dat file
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

int_time = "2024062912"
TCname = "beryl"
file_load = "aal022024_olivia"         ; do not include the .dat at the end

;-------------------------------------------------------------------------

dir_out = "./"
filename = "ukmet_"+int_time+"_"+TCname+".csv"
filename_mean = "ukmet_det_"+int_time+"_"+TCname+".csv"

print("int_time: "+int_time)

line_num = 0
line_num2 = 0
outlines := new((/3000/),"string")
outlines2 := new((/3000/),"string")

do ens = 0,35,1   				; loop through all ensemble members

if (ens .ne. 100) then
;if (ens .ne. 2) .and. (ens .ne. 3) .and. (ens .ne. 4) .and. (ens .ne. 7) .and. (ens .ne. 9) then
;if (ens .ne. 3) .and. (ens .ne. 17) .and. (ens .ne. 25) .and. (ens .ne. 31) .and. (ens .ne. 34) then                           ; use this line if there is a missing ensemble member in early cycles


	if (ens .ge. 0 .and. ens .le. 9) then
		mem = "UE0"+ens
	end if

        if (ens .ge. 10 .and. ens .le. 34) then
                mem = "UE"+ens
        end if

        if (ens .eq. 35) then 
            mem = "UKM"
        end if  
  
	print("mem: "+mem)	

	atcf_output := get_atcf(file_load,mem,int_time,True)

	printVarSummary(atcf_output)
	print(atcf_output(0,:))

	do i = 0,dimsizes(atcf_output(0,:))-1        ; loop through all times in this ensemble member

   		time = atcf_output(0,i)
   		time@units = "hours since 1800-01-01 00:00:00"
   		utc_date = cd_calendar(time, 0)

   		year   = tointeger(utc_date(:,0))    ; Convert to integer for
   		month  = tointeger(utc_date(:,1))    ; use sprinti 
   		day    = tointeger(utc_date(:,2))
   		hour   = tointeger(utc_date(:,3))
   		
   		mslp = atcf_output(1,i)
   		lat = atcf_output(2,i)
   		lon = atcf_output(3,i)
   		wind = atcf_output(4,i)
   		ensemble = ens
   
        line = year+", "+month+", "+day+", "+hour+", "+mslp+", "+lat+", "+lon+", "+wind+", "+ensemble
;   		print("line: "+line)
   
                if ens .le. 34 then
                        print("line_num: "+line_num)
                        outlines(line_num) = line
                        line_num = line_num + 1
                end if
	
                if ens .ge. 35 then
 ;                      print("line_num2: "+line_num2)
                        outlines2(line_num2) = line
                        line_num2 = line_num2 + 1
                end if

   
	end do

print(" ")
print(" ")
end if
	
end do

        line_num_final = line_num2
        print("line_num_final: "+line_num_final)
        asciiwrite(dir_out+filename, outlines)
        asciiwrite(dir_out+filename_mean, outlines2)


print(" ")
print("**************")
print(" END SCRIPT ")
print("**************")
print(" ")

end
