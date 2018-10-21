from pathlib import Path
import re
import matplotlib.pyplot as plt
folder_name="eye-tracking_data/"
doc_id=["322","2725","3775","3819","4094","4504","4584","4701","5938","6046","6366","6474","7784","9977","10879","11143","11299","13165"]
mean_rate_dict={}
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
            mean_rate_dict.update({file_name : float("{0:.2f}".format((1/(mean_period*(10**-6)))))})

#print all files mean period--
all_keys=list(mean_rate_dict.keys())
values=[]
for i in range(0,len(all_keys)):
    values.append(mean_rate_dict.get(all_keys[i]))

plt.plot(all_keys ,values, 'ro',markersize=4 )
plt.ylabel('Mean Samplng Rate')
plt.xlabel('File')
plt.show()
#exit()
#print(mean_rate_dict)