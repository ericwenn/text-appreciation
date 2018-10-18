from pathlib import Path
import re
import math
folder_name="eye-tracking_data/"
doc_id=["322","2725","3775","3819","4094","4504","4584","4701","5938","6046","6366","6474","7784","9977","10879","11143","11299","13165"]
mean_rate_dict={}
sampling_period=16666
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
            # calculate the gap between  each sample
            for k in range(1, len(lines)):
                x = re.split(',', lines[k])
                if k == 1:
                    first = int(x[0])
                else:
                    second = int(x[0])
                    gap_size.append(-1 * (first - second))
                    first = second
                    # create a new file
            output="eye-tracking_data_interpolated/"+file_name+"_interpolated.txt"
            with open(output, 'a') as the_file:
                the_file.truncate(0)
                the_file.write(lines[0])
                # interpolate if necessary
                for k in range (0,len(gap_size)):
                    the_file.write(lines[k+1])
                    x = re.split(',', lines[k+1])
                    x2 = re.split(',', lines[k + 2])
                    if (gap_size[k]<7*sampling_period)and(gap_size[k]>(2*sampling_period)):
                        extra_lines=int(gap_size[k]/sampling_period)
                        lx=float(x[19])
                        ly=float(x[20])
                        lx2=float(x2[19])
                        ly2=float(x2[20])
                        distance=math.sqrt(((lx-lx2)**2)+((ly-ly2)**2))
                        dist_btw_inter=distance/(extra_lines+1)
                        for z in range(0,extra_lines):
                            new_lx = lx + dist_btw_inter*(z+1)
                            new_ly = ly + dist_btw_inter*(z+1)
                            x[19]=str(new_lx)
                            x[20]=str(new_ly)
                            x[21] = str(new_lx)
                            x[22] = str(new_ly)
                        new_line=""
                        for z in range(0,len(x)-1):
                            new_line=new_line+str(x[z])+","
                        new_line=new_line+x[len(x)-1]
                        the_file.write(new_line)
                        print(extra_lines)
                        print(distance)
                        print(distance/(extra_lines+1))
                        exit()