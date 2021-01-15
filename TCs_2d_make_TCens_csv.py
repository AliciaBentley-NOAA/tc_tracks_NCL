import sys, csv, datetime
import xml.etree.ElementTree as ET



#Determine initial date/time
try:
   cycle = str(sys.argv[1])
except IndexError:
   cycle = None

if cycle is None:
   cycle = raw_input('Enter initial time (YYYYMMDDHH): ')

YYYY = int(cycle[0:4])
MM   = int(cycle[4:6])
DD   = int(cycle[6:8])
HH   = int(cycle[8:10])
print YYYY, MM, DD, HH

date_str = datetime.datetime(YYYY,MM,DD,HH,0,0)


# Determine desired model
try:
   ens_str = str(sys.argv[2])
except IndexError:
   ens_str = None

if ens_str is None:
   print 'Ensemble string options: GEFS, GFS, EC, ECENS, UK, UKMet, CMC, or CENS'
   ens_str = raw_input('Enter desired ensemble system: ')


if str.upper(ens_str) == 'GEFS':
   file_str1 = 'kwbc'
   file_str2 = 'GEFS_glob_prod_esttr_glo.xml'
elif str.upper(ens_str) == 'GFS':
   file_str1 = 'kwbc'
   file_str2 = 'GFS_glob_prod_sttr_glo.xml'
elif str.upper(ens_str[0:2]) == 'EC':
   file_str1 = 'ecmf'
   file_str2 = 'ifs_glob_prod_all_glo.xml'
elif str.upper(ens_str[0:2]) == 'UK':
   file_str1 = 'egrr'
   file_str2 = 'mogreps_glob_prod_etctr_glo.xml'
elif str.upper(ens_str) == 'CENS':
   file_str1 = 'kwbc'
   file_str2 = 'CENS_glob_prod_esttr_glo.xml'
elif str.upper(ens_str) == 'CMC':
   file_str1 = 'kwbc'
   file_str2 = 'CMC_glob_prod_sttr_glo.xml'



### By default, will ask for command line input to determine which analysis files to pull 
### User can uncomment and modify the next line to bypass the command line calls
fhre = 384
valid_time = date_str + datetime.timedelta(hours=fhre)


# Case information
try:
   TC_name = str(sys.argv[3])
except IndexError:
   TC_name = None

if TC_name is None:
   TC_name = raw_input('Enter TC name: ')



# Get observed Best Track data


tree=ET.parse('z_tigge_c_'+file_str1+'_'+cycle+'0000_'+file_str2)
root=tree.getroot()
alllat=[]
alllon=[]
members=[]
clat=[]
clon=[]
cpres=[]
cspeed=[]
ctime=[]


if str.upper(ens_str[0:2]) != 'UK':

   for child in root.findall('data'):
      # Read non-UK ensemble (GEFS, ECENS, CENS) data
      if child.attrib['type']=='ensembleForecast':
         thismember= child.attrib['member']
         print child.attrib
         thishours=[]
         thislat=[]
         thislon=[]
         thispres=[]
         thisspeed=[]
         thistime=[]
         dis=child.findall('disturbance')

         for child2 in dis:
            print child2.attrib
            if child2.attrib['ID']!=cycle+'_00N_00E':
               fhours= child2.findall('fix')
#.attrib['hour']
               for x in fhours:
                  thishours.append(x.attrib['hour'])
               print "made it inside"
               if child2.find('cycloneName')!=None and child2.find('cycloneName').text==TC_name:
                  print "found "+TC_name
                  print child2.attrib

                  for child3 in child2:
                     if child3:
                        if datetime.datetime.strptime(child3.find('validTime').text,"%Y-%m-%dT%H:00:00Z")<=valid_time:
                           ranklat = float(child3.find('latitude').text)
                           ranklon = float(child3.find('longitude').text)
                           thislat.append(ranklat)
                           thislon.append(ranklon)
                           thistime.append(datetime.datetime.strptime(child3.find('validTime').text,"%Y-%m-%dT%H:00:00Z"))
                
                           data1=child3.find('cycloneData')
                           for child4 in data1:
                              pres = child4.findall('pressure')
                              if len(pres)>0:
                                 thispres.append(child4.findall('pressure')[0].text)
                              maxv = child4.findall('speed')
                              if len(maxv)>0:
                                 thisspeed.append(child4.findall('speed')[0].text)

         f = open(str.lower(ens_str)+"_"+cycle+"_"+str.lower(TC_name)+".csv","a")
         try:
            writer = csv.writer(f)
            print len(thislat)
            for i in range(len(thislon)):
               writer.writerow([thistime[i].strftime('%Y'), thistime[i].strftime(' %m'), thistime[i].strftime(' %d'), thistime[i].strftime(' %H'), ' '+str(thispres[i]), ' '+str(thislat[i]), ' '+str(thislon[i]), ' '+str(thisspeed[i]), ' '+str(thismember)])

         finally:
            f.close()


      elif child.attrib['type']=='forecast':
      # Read non-UK forecast data (GFS, EC, CMC) data
         print "FOUND FORECAST"
         dis=child.findall('disturbance')
         thishours=[]
         thislat=[]
         thislon=[]
         thispres=[]
         thisspeed=[]
         thistime=[]

         for child2 in dis:
            if child2.attrib['ID']!=cycle+'_00N_00E':
               fhours= child2.findall('fix')
               for x in fhours:
                  thishours.append(x.attrib['hour'])
                  print "hours"
                  print x.attrib['hour']
               if child2.find('cycloneName')!=None and child2.find('cycloneName').text==TC_name:

                  for child3 in child2:
                     if len(child3):
                        if datetime.datetime.strptime(child3.find('validTime').text,"%Y-%m-%dT%H:00:00Z")<=valid_time:
                           ranklat = float(child3.find('latitude').text)
                           ranklon = float(child3.find('longitude').text)
                           clat.append(ranklat)
                           clon.append(ranklon)
                           ctime.append(datetime.datetime.strptime(child3.find('validTime').text,"%Y-%m-%dT%H:00:00Z"))

                           data1=child3.find('cycloneData')
                           for child4 in data1:
                              pres = child4.findall('pressure')
                              if len(pres)>0:
                                 cpres.append(child4.findall('pressure')[0].text)
                              maxv = child4.findall('speed')
                              if len(maxv)>0:
                                 cspeed.append(child4.findall('speed')[0].text)
        

         f = open(str.lower(ens_str)+"_det_"+cycle+"_"+str.lower(TC_name)+".csv","a")
         try:
            writer = csv.writer(f)
            print len(thislat)
            for i in range(len(clon)):
               writer.writerow([thistime[i].strftime('%Y'), thistime[i].strftime(' %m'), thistime[i].strftime(' %d'), thistime[i].strftime(' %H'), ' '+str(cpres[i]), ' '+str(clat[i]), ' '+str(clon[i]), ' '+str(cspeed[i])])
         finally:
            f.close()



elif str.upper(ens_str[0:2]) == 'UK':

   for child in root.findall('data'):
      # Read non-UK ensemble (GEFS, ECENS, CENS) data
      print child.attrib
      thismember= child.attrib['member']
      members.append(child.attrib['member'])
      if child.attrib['type']=='ensembleForecast':
         thislat=[]
         thislon=[]
         thishours=[]
         thispres=[]
         thisspeed=[]
         thistime=[]
         thishours=[]
         dis=child.findall('disturbance')

         for child2 in dis:
            if child2.find('cycloneName').text==str.upper(TC_name):
               print child2.attrib
               fhours= child2.findall('fix')
               for x in fhours:
                  thishours.append(x.attrib['hour'])

               for child3 in child2:
                  if len(child3):
                     if datetime.datetime.strptime(child3.find('validTime').text,"%Y-%m-%dT%H:00:00Z")<=valid_time:
                        ranklat = float(child3.find('latitude').text)
                        ranklon = 360 - float(child3.find('longitude').text)
                        thislat.append(ranklat)
                        thislon.append(ranklon)
                        thistime.append(datetime.datetime.strptime(child3.find('validTime').text,"%Y-%m-%dT%H:00:00Z"))
                
                        data1=child3.find('cycloneData')
                        for child4 in data1:
                           pres = child4.findall('pressure')
                           print pres
                           if len(pres)>0:
                              thispres.append(child4.findall('pressure')[0].text)
                           maxv = child4.findall('speed')
                           print maxv
                           if len(maxv)>0:
                              thisspeed.append(child4.findall('speed')[0].text)


         f = open(str.lower(ens_str)+"_"+cycle+"_"+str.lower(TC_name)+".csv","a")
         try:
            writer = csv.writer(f)
            print len(thislat)
            for i in range(len(thislon)):
               writer.writerow([thistime[i].strftime('%Y'), thistime[i].strftime(' %m'), thistime[i].strftime(' %d'), thistime[i].strftime(' %H'), ' '+str(thispres[i]), ' '+str(thislat[i]), ' '+str(thislon[i]), ' '+str(thisspeed[i]), ' '+str(thismember)])
         finally:
            f.close()
