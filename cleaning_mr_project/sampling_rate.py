from pathlib import Path
from shutil import copyfile
import re
import matplotlib.pyplot as plt
import math
import os
folder_name="eye-tracking_data/"
folder_name_dst="data_after_mean_std_clean/"
doc_id=["322","2725","3775","3819","4094","4504","4584","4701","5938","6046","6366","6474","7784","9977","10879","11143","11299","13165"]
mean_rate_dict={}
stand_dev={}
#loop through all participants

for i in range(1,37):
    #loop through all articles id
    for j in range(0,len(doc_id)):
        #create the path to the file
        if i<10:
            file_name = 'P0' + str(i) + '_' + str(doc_id[j])
        else:
            file_name = 'P' + str(i) + '_'+ str(doc_id[j])
        path=folder_name+file_name+".txt"
        file=Path(path)
        #check if the file exist
        if file.exists():
            #read the file
            with open(path) as f:
                lines = f.readlines()
            f.close()

            # calculate sampling rate and ratio
            period_list = []
            for k in range(1, len(lines)):
                x = re.split(',+', lines[k])
                if k == 1:
                    first = int(x[0])
                else:
                    second = int(x[0])
                    period_list.append(-1 * (first - second))
                    first = second

            #calculate mean period for this file
            mean_period=0
            for k in range(0,len(period_list)):
                mean_period=mean_period+period_list[k]
            mean_period=mean_period/len(period_list)
            #add it into a dictionary
            mean_rate=float("{0:.2f}".format((1/(mean_period*(10**-6)))))
            mean_rate_dict.update({file_name :mean_rate })
            var=0
            for k in range(0, len(period_list)):
                temp=mean_rate-(1/(period_list[i]*(10**-6)))
                var = var + (temp**2)

            st=float("{0:.2f}".format(math.sqrt(var/len(period_list))))
            stand_dev.update({file_name:st})

#print all files mean period--
all_keys=list(mean_rate_dict.keys())
mean_d={}
std_d={}
values_mean=[]
values_std=[]
cm=0
cs=0
cms=0
thr_m=55
thr_s=10
cc=0
files_d=[]
for i in range(0,len(all_keys)):
    values_mean.append(mean_rate_dict.get(all_keys[i]))
    values_std.append(stand_dev.get(all_keys[i]))
    if values_mean[i]<45:
        cm+=1
        if all_keys[i] not in files_d:
            files_d.append(all_keys[i])

    if values_std[i]>25:
        cs+=1
        if all_keys[i] not in files_d:
            files_d.append(all_keys[i])

    if values_std[i]>thr_s and values_mean[i]<thr_m:
        cms+=1
        if all_keys[i] not in files_d:
            files_d.append(all_keys[i])

    '''
    if values_mean[i] not in mean_d:
        mean_d.update({values_mean[i]:1})
    else:
        mean_d.update({values_mean[i]: mean_d.get(values_mean[i])+1})
    if  values_std[i] not in std_d:
        std_d.update({values_std[i]:1})
    else:
        std_d.update({values_std[i]: std_d.get(values_std[i])+1})

    '''

print(len(files_d))
print("Files to remove due to mean:"+str(cm))
print("Files to remove due to std:"+str(cs))
print("Files to remove due to mean and std:"+str(cms))

for i in range(0,len(all_keys)):
    if all_keys[i] not in files_d:
        src=folder_name+all_keys[i]+".txt"
        dst=folder_name_dst+all_keys[i]+".txt"
        copyfile(src, dst)

'''
temp=list(mean_d.keys())
all_keys_m=[]
for key in sorted(mean_d):
    all_keys_m.append(key)
vm=[]
for i in range(0,len(all_keys_m)):
    vm.append(mean_d.get(all_keys_m[i]))

temp=list(std_d.keys())
all_keys_s=[]
for key in sorted(std_d):
    all_keys_s.append(key)
vs=[]
for i in range(0,len(all_keys_s)):
    vs.append(std_d.get(all_keys_s[i]))

print("Files to remove due to mean:"+str(cm))
print("Files to remove due to std:"+str(cs))
print("Files to remove due to mean and std:"+str(cms))


plt.plot(all_keys_m ,vm, 'ro', markersize=1 )
plt.ylabel('Frequency')
plt.xlabel('Mean Rate')
plt.show()


plt.plot(all_keys_s ,vs, 'ro',markersize=1)
plt.ylabel('Frequency')
plt.xlabel('Std')
plt.show()
'''
'''
temp=[]
temp2=[]
for i in range(0,len(all_keys)):
    val=mean_rate_dict.get(all_keys[i])
    if val>=55:
        temp.append(mean_rate_dict.get(all_keys[i]))
        temp2.append(all_keys[i])

plt.plot(temp2, temp, 'ro', markersize=4)
plt.ylabel('Standard Deviation')
plt.xlabel('File')
plt.show()
'''


#exit()
#print(mean_rate_dict)