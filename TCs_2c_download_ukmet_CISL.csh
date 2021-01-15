#!/bin/csh
#################################################################
# Csh Script to retrieve 11 online Data files of 'ds330.3',
# total 1.13M. This script uses 'wget' to download data.
# #
# # Highlight this script by Select All, Copy and Paste it into a file;
# # make the file executable and run it on command line.
# #
# # You need pass in your password as a parameter to execute
# # this script; or you can set an environment variable RDAPSWD
# # if your Operating System supports it.
# #
# # Contact schuster@ucar.edu (Doug Schuster) for further assistance.
# #################################################################

set pswd = $1
if(x$pswd == x && `env | grep RDAPSWD` != '') then
 set pswd = $RDAPSWD
endif
if(x$pswd == x) then
 echo
 echo Usage: csh $0 fyS9qAjD
 echo
 exit 1
endif
set v = `wget -V |grep 'GNU Wget ' | cut -d ' ' -f 3`
set a = `echo $v | cut -d '.' -f 1`
set b = `echo $v | cut -d '.' -f 2`
if(100 * $a + $b > 109) then
 set opt = 'wget --no-check-certificate'
else
 set opt = 'wget'
endif
set opt1 = '-O Authentication.log --save-cookies auth.rda_ucar_edu --post-data'
set opt2 = "email=ambentley@albany.edu&passwd=$pswd&action=login"
$opt $opt1="$opt2" https://rda.ucar.edu/cgi-bin/login
set opt1 = "-N --load-cookies auth.rda_ucar_edu"
set opt2 = "$opt $opt1 http://rda.ucar.edu/data/ds330.3/"
set filelist = ( \
  egrr/2020/20200823/z_tigge_c_egrr_20200823120000_mogreps_glob_prod_etctr_glo.xml.gz \
#  egrr/2018/20181007/z_tigge_c_egrr_20181007120000_mogreps_glob_prod_etctr_glo.xml.gz \
#  egrr/2018/20181008/z_tigge_c_egrr_20181008000000_mogreps_glob_prod_etctr_glo.xml.gz \
#  egrr/2018/20181008/z_tigge_c_egrr_20181008120000_mogreps_glob_prod_etctr_glo.xml.gz \
#  egrr/2018/20181009/z_tigge_c_egrr_20181009000000_mogreps_glob_prod_etctr_glo.xml.gz \
#  egrr/2018/20181009/z_tigge_c_egrr_20181009120000_mogreps_glob_prod_etctr_glo.xml.gz \
#  egrr/2018/20181010/z_tigge_c_egrr_20181010000000_mogreps_glob_prod_etctr_glo.xml.gz \
#  egrr/2018/20181010/z_tigge_c_egrr_20181010120000_mogreps_glob_prod_etctr_glo.xml.gz \
)
while($#filelist > 0)
 set syscmd = "$opt2$filelist[1]"
 echo "$syscmd ..."
 $syscmd
 shift filelist
end



