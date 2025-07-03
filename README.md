# tc_tracks_NCL
Tropical cyclone (TC) track density plotting scripts used by the MEG for TC recaps and retrospectives.

File locations on WCOSS2 and www:
WCOSS2 a-deck: /lfs/h1/ops/prod/dcom/nhc/atcf-noaa/aid_nws/aal022024.dat
WCOSS2 b-deck: /lfs/h1/ops/prod/dcom/nhc/atcf-noaa/btk/bal022024.dat
(Naming conventions: al = atlantic, ep = east pacific, cp = central pacific)

UKMET det/ens: 
Pre-processed by Olivia Ostwald (EMC)

sftp Alicia.Bentley@dtn-hera.fairmont.rdhpcs.noaa.gov:/scratch2/NCEPDEV/ovp/Alicia.Bentley/beryl/
Type: RSA PIN (FULL) + RSA TOKEN
put bal022024.dat

CMC:
wget https://hurricanes.ral.ucar.edu/repository/data/adecks_open/aal022024.dat

Obtaining scripts:
git clone https://github.com/AliciaBentley-NOAA/tc_tracks_NCL.git        

Steps to create TC track density plots with GEFS, ECMWF, and UKMET:
1.   Create Best Track .csv file from Best Track .dat file (TCs_1_make_best_track_csv.ncl)
Modify information above dashed line in TCs_1_make_best_track_csv.ncl 
(i.e., first date in Best Track .dat file [regardless if TC was named or not], name of Best Track .dat file, name of TC)
ncl TCs_1_make_best_track_csv.ncl

-----------------------------------------

2a.  Create GEFS .csv files from .dat file (TCs_2a_create_gefs_tracks.ncl)	
Check in the A-deck file that the cycle you want to plot exists. Ensemble member naming conventions can be found here: http://www.hurricanecity.com/models/models.cgi?page=models#GFS-NWS__Global_Forecast_System
Modify information above dashed line in TCs_2a_create_gefs_tracks.ncl 
(i.e., forecast initialization date, name of A-deck .dat file, name of TC)
ncl TCs_2a_create_gefs_tracks.ncl

(You can jump to step 3 and step 4 to make a GEFS plot now, or continue to other models)

-----------------------------------------

2b.  Create ECMWF ensemble .csv files from .dat file (TCs_2b_create_ec_tracks.ncl)	
Check in A-deck file that the cycle you want to plot exists. Ensemble member naming conventions can be found here: http://www.hurricanecity.com/models/models.cgi?page=models#ECMWF_Ensemble_[NCEP_tracker]-European_Centre_for_Medium-Range_Weather_Forecasts
Modify information above dashed line TCs_2b_create_ec_tracks.ncl
(i.e., forecast initialization date, name of A-deck .dat file, name of TC)
ncl TCs_2b_create_ec_tracks.ncl

(You can jump to step 3 and step 4 to make a ECMWF plot now, or continue to other models)

-----------------------------------------

(Run the following UKMET scripts in order multiple times OR individually multiple times for each cycle)

2c.  Download UKMET ens. data from CISL forecast archive (TCs_2c_download_ukmet_CISL.csh)	
Change paths in filelist section of TCs_2c_download_ukmet_CISL.csh to correspond to the dates you want to download
vi TCs_2c_download_ukmet_CISL.csh
csh TCs_2c_download_ukmet_CISL.csh YOUR_PASSWORD
gunzip *.gz


2d.  Create UKMET ensemble .csv file from .xml file (TCs_2d_make_TCens_csv.py)	
python TCs_2d_make_TCens_csv.py
Enter initialization time: YYYYMMDDHH
Enter model: UKMet
Enter TC name: laura
Check to see that a new file of ensemble members was actually produced. If no ensemble members exist at the initialization time that you selected, it will just be blank inside the .csv file. When ensemble members exist, the .csv file will be full.  

2e.  Create UKMET deterministic .csv files from .dat file (TCs_2e_create_ukmet_det.ncl)	
Check in A-deck file that the cycle you want to plot exists. Ensemble member naming conventions can be found here: http://www.hurricanecity.com/models/models.cgi?page=models#UKMET-United_Kingdom_Meteorological_Office
Modify information above dashed line in TCs_2e_create_ukmet_det.ncl 
(i.e., forecast initialization date, name of A-deck .dat file, name of TC)
ncl TCs_2e_create_ukmet_det.ncl

2f.  Create UKMET mean and deterministic .csv files (TCs_2f_calc_ukmet_mean_det.ncl)	
Modify information above dashed line in TCs_2f_calc_ukmet_mean_det.ncl
(i.e., forecast initialization date, name of TC)
ncl TCs_2f_calc_ukmet_mean_det.ncl

(You can jump to step 3 and step 4 to make a UKMET plot now, or continue to other models)

-----------------------------------------

3.  	Create track density netCDF files (TCs_3_calc_track_density.ncl)	
Modify information above dashed line in TCs_3_calc_track_density.ncl
(i.e., forecast initialization date, name of ensemble (e.g., gefs), name of TC)
ncl TCs_3_calc_track_density.ncl

-----------------------------------------

4.  	Plot track density maps with TC tracks (TCs_4_plot_track_density.ncl)	
Modify information above dashed line in TCs_4_plot_track_density.ncl
(i.e., forecast initialization date, name of ensemble (e.g., gefs), name of TC, directory on emcrzdm to move image to with passwordless transfer, boundaries of domain to plot)
Near the bottom of the script (scp line) change my emcrzdm username to yours
ncl TCs_4_plot_track_density.ncl

scp *png abentley@emcrzdm:/home/people/emc/www/htdocs/users/Alicia.Bentley/beryl/track_density/.

-----------------------------------------

5.  	Plot track density maps with TC tracks (TCs_5_plot_best_track.ncl)	
Modify information above dashed line in TCs_5_best_track.ncl
(i.e., forecast initialization date, density date to use, name of TC, directory on emcrzdm to move image to with passwordless transfer, boundaries of domain to plot)
Near the bottom of the script (scp line) change my emcrzdm username to yours

