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

int_time = "2024070800"
TCname = "beryl"
file_load = "aal022024_ucar"         ; do not include the .dat at the end

;-------------------------------------------------------------------------

dir_out = "./"
filename = "cmc_"+int_time+"_"+TCname+".csv"
filename_mean = "cmc_det_mean_"+int_time+"_"+TCname+".csv"

print("int_time: "+int_time)

line_num = 0
line_num2 = 0
outlines := new((/3000/),"string")
outlines2 := new((/3000/),"string")

do ens = 0,22,1   				; loop through all ensemble members

	if (ens .eq. 0) then
	    mem = "CC00"
	end if

	if (ens .ge. 1 .and. ens .le. 9) then
		mem = "CP0"+ens
	end if

        if (ens .ge. 10 .and. ens .le. 20) then
                mem = "CP"+ens
        end if

        if (ens .eq. 21) then 
            mem = "CEMN"
        end if  

        if (ens .eq. 22) then
            mem = "CMC"
        end if
  
	print("mem: "+mem)	

	atcf_output := get_atcf(file_load,mem,int_time,True)

;	printVarSummary(atcf_output)
	;print(atcf_output(0,:))

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
   		
   		if ens .le. 20 then
   			print("line_num: "+line_num)
			outlines(line_num) = line
			line_num = line_num + 1
		end if

                if ens .ge. 21 then
 ;                       print("line_num2: "+line_num2)
                        outlines2(line_num2) = line
                        line_num2 = line_num2 + 1
                end if

   
	end do
	
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
