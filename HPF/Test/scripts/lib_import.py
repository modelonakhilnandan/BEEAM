# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""

import sys

# Second append the folder path

#sys.path.insert(0, '../../Utilities/external_lib/buildingspy/')
sys.path.append('/media/avpreetsingh/Documents/Tools_n_libs/python/BuildingsPy-master/buildingspy')

"""
Third Make a blank file called __ init __.py in your subdirectory (this tells Python it is a module)

    name-file.py
        name-folder
            __ init __.py
            name-module.py

Fourth import the module inside the folder
"""

from buildingspy.io.outputfile import Reader