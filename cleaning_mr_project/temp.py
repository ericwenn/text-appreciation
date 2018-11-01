
#####
#WE DO NOT USE THIS CODE IS JUST FOR SOME CHECK UPS I MADE
###

from pathlib import Path
from shutil import copyfile
import re
import matplotlib.pyplot as plt
import math
import os
folder_name="data_after_mean_std_clean/"
ff="temp/"
folder_name2="data_after_fixation_map/"
ff2="New_extra_files_need_to_check/"
folder_name_dst="New/"
doc_id=["322","2725","3775","3819","4094","4504","4584","4701","5938","6046","6366","6474","7784","9977","10879","11143","11299","13165"]
mean_rate_dict={}
stand_dev={}
#loop through all participants
files=[]
for i in range(1,37):
    #loop through all articles id
    for j in range(0,len(doc_id)):
        #create the path to the file
        if i<10:
            file_name = 'P0' + str(i) + '_' + str(doc_id[j])
        else:
            file_name = 'P' + str(i) + '_'+ str(doc_id[j])
        path=ff2+file_name+".txt"
        file=Path(path)
        #check if the file exist
        if file.exists():
            files.append(file_name)

for i in range(0,len(files)):
    path1=ff+files[i]+".txt"
    file1 = Path(path1)
    if file1.exists():
        print("h")
    else:
        src = ff2+files[i]+".txt"
        dst = folder_name_dst + files[i] + ".txt"
        copyfile(src, dst)


