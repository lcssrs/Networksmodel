
##Dropping the part of the raster which is not necessary

params1 = { 'ALPHA_BAND' : False,
            'CROP_TO_CUTLINE' : True,
            'DATA_TYPE' : 0, 
            'EXTRA' : '', 
            'INPUT' : 'G:/Other computers/My laptop/Workarea/QEM Msc/Barcelona/2nd semester/Spatial Economics/Term paper/Data/More data/Volume/GHS_BUILT_V_E2020_GLOBE_R2022A_54009_100_V1_0_R12_C14.tif',
            'KEEP_RESOLUTION' : True, 
            'MASK' : 'G:/Other computers/My laptop/Workarea/QEM Msc/Barcelona/2nd semester/Spatial Economics/Term paper/Data/More data/Created rasters/Vector RMSP.shp', 
            'MULTITHREADING' : False, 
            'NODATA' : None, 
            'OPTIONS' : '', 
            'OUTPUT' : 'G:/Other computers/My laptop/Workarea/QEM Msc/Barcelona/2nd semester/Spatial Economics/Term paper/Data/More data/Created rasters/Vol 2020.tif', 
            'SET_RESOLUTION' : False, 
            'SOURCE_CRS' : None, 
            'TARGET_CRS' : None, 
            'TARGET_EXTENT' : None, 
            'X_RESOLUTION' : None, 
            'Y_RESOLUTION' : None }


processing.run("gdal:cliprasterbymasklayer", params1)


##Adding the raster information to a vector

params2 = { 'COLUMN_PREFIX' : 'Vol20_', 
            'INPUT' : 'G:/Other computers/My laptop/Workarea/QEM Msc/Barcelona/2nd semester/Spatial Economics/Term paper/Data/More data/Created rasters/Vector RMSP.shp', 
            'INPUT_RASTER' : 'G:/Other computers/My laptop/Workarea/QEM Msc/Barcelona/2nd semester/Spatial Economics/Term paper/Data/More data/Created rasters/Vol 2020.tif', 
            'OUTPUT' : 'TEMPORARY_OUTPUT', 
            'RASTER_BAND' : 1, 
            'STATISTICS' : [0,1] }
            
processing.run("qgis:zonalstatistics", params2)

params2 = { 'COLUMN_PREFIX' : 'Vol15_', 
            'INPUT_VECTOR' : 'G:/Other computers/My laptop/Workarea/QEM Msc/Barcelona/2nd semester/Spatial Economics/Term paper/Data/More data/Created rasters/Vector RMSP.shp', 
            'INPUT_RASTER' : 'G:/Other computers/My laptop/Workarea/QEM Msc/Barcelona/2nd semester/Spatial Economics/Term paper/Data/More data/Created rasters/Vol 2015.tif', 
            'OUTPUT' : 'TEMPORARY_OUTPUT', 
            'RASTER_BAND' : 1, 
            'STATISTICS' : [0,1] }
            
processing.run("qgis:zonalstatistics", params2)