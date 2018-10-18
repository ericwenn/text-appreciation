#i did not yet create the aggregated files so this file does not work yet
from pathlib import Path
import re

folder_name="eye-tracking_data_aggregate/"
doc_id=["322","2725","3775","3819","4094","4504","4584","4701","5938","6046","6366","6474","7784","9977","10879","11143","11299","13165"]
count_Saccade=0
count_fix=0
ratio_dict={}

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
            # read the file
            with open(path) as f:
                lines = f.readlines()
            f.close()
            for i in range(0, len(lines)):
                x = re.split('\s+', lines[i])
                if x[0] == "Saccade":
                    count_Saccade = count_Saccade + 1
                if x[0] == "Fixation":
                    count_fix = count_fix + 1

            ratio_dict.update({file_name:(count_Saccade/count_fix)})