from pathlib import Path
import re
import math
folder_name="data_after_fixation_map/"
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
                    #get the 2 lines where between them we will intepolate
                    x = re.split(',', lines[k+1])
                    x2 = re.split(',', lines[k + 2])
                    #check the size of the gab
                    if (gap_size[k]<(75000))and(gap_size[k]>(1.75*sampling_period)):
                        #calculate how many extra samples/lines
                        extra_lines=math.ceil(gap_size[k]/sampling_period)-1
                        #get l_por_x, l_por_y from line1
                        lx=float(x[19])
                        ly=float(x[20])
                        # get l_por_x, l_por_y from line2
                        lx2=float(x2[19])
                        ly2=float(x2[20])
                        #calculate distance bettween the 2 points
                        #distance=math.sqrt(((lx-lx2)**2)+((ly-ly2)**2))
                        dist_x=lx2-lx
                        dist_y=ly2-ly
                        #calculate the distamce between interpolations
                        #dist_btw_inter=distance/(extra_lines+1)
                        dist_btw_inter_x = dist_x / (extra_lines + 1)
                        dist_btw_inter_y = dist_y / (extra_lines + 1)
                        for z in range(0,extra_lines):
                            # calculate new l_por_x, l_por_y  which identical to r_por_x, r_por_y

                            new_lx = float("{0:.4f}".format(lx + dist_btw_inter_x*(z+1)))
                            new_ly =  float("{0:.4f}".format(ly + dist_btw_inter_y*(z+1)))
                            #replace l_por_x, l_por_y and r_por_x, r_por_y with the new ones
                            x[19]=str(new_lx)
                            x[20]=str(new_ly)
                            x[21] = str(new_lx)
                            x[22] = str(new_ly)
                            #recreate the new liine

                            new_line = str(int(x[0]) + (((int(x2[0]) - int(x[0])) / (extra_lines + 1)) * (z + 1))) + ","
                            for h in range(1, len(x) - 1):
                                new_line = new_line + str(x[h]) + ","
                            new_line = new_line + x[len(x) - 1]
                            #write the line
                            the_file.write(new_line)

                        #print(extra_lines)
                        #print(distance)
                        #print(distance/(extra_lines+1))