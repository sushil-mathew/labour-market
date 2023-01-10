# -*- coding: utf-8 -*-
# DO NOT RUN THIS CODE
# DO NOT RUN THIS CODE
# DO NOT RUN THIS CODE
# DO NOT RUN THIS CODE
# DO NOT RUN THIS CODE

#Sushil wrote this code on Dec27, 2022 to rename ASHE data files
#They were initially named in a whacky format, which was difficult to loop through
#This program changed how the files are named in the raw data folder
#Therefore it should never be used again

import os

#Directory for where the names have to be changed
cd = "C:/Users/u1972955/Dropbox/personal/Potential Research/inflation and labour market/data/raw/ashe_pubpriv/"
#change directory
os.chdir(cd)

for path, subdir, files in os.walk('./'): 
    for name in files:
        if name!="links.txt":
            year=path[2:]
            newnamestr = str(name.split("Table 13",1)[1:]) 
            newnamestr = newnamestr[6:-6]
            newnamestr = newnamestr.strip()
            old_name = name 
            new_name = newnamestr 
            os.rename(f"{year}/{old_name}", f"{year}/{new_name}.xls")
