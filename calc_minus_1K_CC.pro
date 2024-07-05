PRO main

  CPU, TPOOL_NTHREADS=1
  
  VAR = COMMAND_LINE_ARGS()
  
  PRINT, VAR[0] + ' is processed...'
  
  ; save CC files to be modified
  FILE_COPY, 'CC_'+VAR[0]+'_3D_remapcon.nc' , 'CC_'+VAR[0]+'_3D_remapcon.nc_minus_1K', /OVERWRITE
  FILE_COPY, 'CC_'+VAR[0]+'_SPIP.nc' , 'CC_'+VAR[0]+'_SPIP.nc_minus_1K', /OVERWRITE
  FILE_COPY, 'mrso_CC_'+VAR[0]+'_September_remapcon.nc' , 'mrso_CC_'+VAR[0]+'_September_remapcon.nc_minus_1K', /OVERWRITE
  FILE_COPY, 'mrso_CC_'+VAR[0]+'_SPIP.nc' , 'mrso_CC_'+VAR[0]+'_SPIP.nc_minus_1K', /OVERWRITE

  ; load file, containing climate change factors
  file=NCDF_OPEN('tas_CC_'+VAR[0]+'_global.nc_scaling_minus_1K')

  ; get 1K scaling factor
  ID=NCDF_VARID(file,'tas')
  NCDF_VARGET,file, ID, tas_CC
  tas_CC = DOUBLE(REFORM(tas_CC, /OVERWRITE))
  NCDF_CLOSE,file
  
  ; open file, to be modified
  file=NCDF_OPEN('CC_'+VAR[0]+'_3D_remapcon.nc_minus_1K', /WRITE)
  ; coefficients, defining sigma pressure coordinates
  ID=NCDF_VARID(file,'hur')
  NCDF_VARGET,file, ID, hur   
  idx = WHERE(hur LT 100000.0, cnt)
  IF cnt GT 0 THEN hur[idx] = hur[idx] * tas_CC[0]
  NCDF_VARPUT,file, ID, FLOAT(hur)
  
  ID=NCDF_VARID(file,'hus')
  NCDF_VARGET,file, ID, hus  
  idx = WHERE(hus LT 100000.0, cnt)
  IF cnt GT 0 THEN hus[idx] = hus[idx] * tas_CC[0]
  NCDF_VARPUT,file, ID, FLOAT(hus)

  ID=NCDF_VARID(file,'ta')
  NCDF_VARGET,file, ID, ta  
  idx = WHERE(ta LT 100000.0, cnt)
  IF cnt GT 0 THEN ta[idx] = ta[idx] * tas_CC[0]
  NCDF_VARPUT,file, ID, FLOAT(ta)

  ID=NCDF_VARID(file,'zg')
  NCDF_VARGET,file, ID, zg  
  idx = WHERE(zg LT 100000.0, cnt)
  IF cnt GT 0 THEN zg[idx] = zg[idx] * tas_CC[0]
  NCDF_VARPUT,file, ID, FLOAT(zg)

  ID=NCDF_VARID(file,'psl')
  NCDF_VARGET,file, ID, psl  
  idx = WHERE(psl LT 100000.0, cnt)
  IF cnt GT 0 THEN psl[idx] = psl[idx] * tas_CC[0]
  NCDF_VARPUT,file, ID, FLOAT(psl)

  NCDF_CLOSE,file
  
  ; open file, to be modified
  file=NCDF_OPEN('CC_'+VAR[0]+'_SPIP.nc_minus_1K', /WRITE)
  ; coefficients, defining sigma pressure coordinates
  ID=NCDF_VARID(file,'hur')
  NCDF_VARGET,file, ID, hur   
  idx = WHERE(hur LT 100000.0, cnt)
  IF cnt GT 0 THEN hur[idx] = hur[idx] * tas_CC[0]
  NCDF_VARPUT,file, ID, FLOAT(hur)
  
  ID=NCDF_VARID(file,'hus')
  NCDF_VARGET,file, ID, hus  
  idx = WHERE(hus LT 100000.0, cnt)
  IF cnt GT 0 THEN hus[idx] = hus[idx] * tas_CC[0]
  NCDF_VARPUT,file, ID, FLOAT(hus)

  ID=NCDF_VARID(file,'ta')
  NCDF_VARGET,file, ID, ta  
  idx = WHERE(ta LT 100000.0, cnt)
  IF cnt GT 0 THEN ta[idx] = ta[idx] * tas_CC[0]
  NCDF_VARPUT,file, ID, FLOAT(ta)

  ID=NCDF_VARID(file,'zg')
  NCDF_VARGET,file, ID, zg  
  idx = WHERE(zg LT 100000.0, cnt)
  IF cnt GT 0 THEN zg[idx] = zg[idx] * tas_CC[0]
  NCDF_VARPUT,file, ID, FLOAT(zg)

  ID=NCDF_VARID(file,'psl')
  NCDF_VARGET,file, ID, psl  
  idx = WHERE(psl LT 100000.0, cnt)
  IF cnt GT 0 THEN psl[idx] = psl[idx] * tas_CC[0]
  NCDF_VARPUT,file, ID, FLOAT(psl)

  NCDF_CLOSE,file
  
  ; open file, to be modified
  file=NCDF_OPEN('mrso_CC_'+VAR[0]+'_September_remapcon.nc_minus_1K', /WRITE)
  ID=NCDF_VARID(file,'mrso')
  NCDF_VARGET,file, ID, mrso   
  mrso[*,*,*] = mrso[*,*,*] ^ tas_CC[0]
  NCDF_VARPUT,file, ID, mrso

  NCDF_CLOSE,file
  
  ; open file, to be modified
  file=NCDF_OPEN('mrso_CC_'+VAR[0]+'_SPIP.nc_minus_1K', /WRITE)
  ID=NCDF_VARID(file,'mrso')
  NCDF_VARGET,file, ID, mrso   
  mrso[*,*,*] = mrso[*,*,*] ^ tas_CC[0]
  NCDF_VARPUT,file, ID, mrso

  NCDF_CLOSE,file
  
END
