from pathlib import Path
import re
import math
folder_name="data_after_fixation_map/"
doc_id=["322","2725","3775","3819","4094","4504","4584","4701","5938","6046","6366","6474","7784","9977","10879","11143","11299","13165"]
#loop through all participants
for i in range(1,37):
    #loop through all articles id
    for j in range(0,len(doc_id)):
        gap_size=[]
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
            output = "data_after_removing_outliers/" + file_name + "_remove_outliers.txt"
           #crate a new file
            with open(output, 'a') as the_file:
                the_file.truncate(0)
                #add the header
                the_file.write(lines[0])
                #go through all lines through the file, except line 0 since is the hearder
                for k in range(1, len(lines)):
                    #split the columns
                    x = re.split(',', lines[k])
                    # check if the x and y gaze position is greater than 0
                    if ((float(x[19])>0) and (float(x[20])>0)):
                        #if yes then it is not an outlier so write it in the file
                        the_file.write(lines[k])
