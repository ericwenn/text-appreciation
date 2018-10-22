from pathlib import Path
import re
import math
import matplotlib.pyplot as plt

folder_name="eye-tracking_data/"
doc_id=["322","2725","3775","3819","4094","4504","4584","4701","5938","6046","6366","6474","7784","9977","10879","11143","11299","13165"]
final={}

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
            count=0
            result=0
            for k in range(1,len(lines)-1):
                x = re.split(',', lines[k])
                x2 = re.split(',', lines[k + 1])
                # get l_por_x, l_por_y from line1
                lx = float(x[19])
                ly = float(x[20])
                # get l_por_x, l_por_y from line2
                lx2 = float(x2[19])
                ly2 = float(x2[20])
                print(str(ly)+"-"+str(ly2))
                #this should be sqr(Σ((X1-X2)/(Y1-Y2))^2)??
                result=result+(((lx-lx2)**2)/((ly-ly2)**2))
                count+=1
            st=float("{0:.2f}".format(math.sqrt(result)/len(count)))
            final.update({file_name: st})

all_keys=list(final.keys())
values=[]
for i in range(0,len(all_keys)):
    values.append(final.get(all_keys[i]))

plt.plot(all_keys ,values, 'ro',markersize=4 )
plt.ylabel('Mean Samplng Rate')
plt.xlabel('File')
plt.show()