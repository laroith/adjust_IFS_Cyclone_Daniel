PRO main

  CPU, TPOOL_NTHREADS=1
  
  VAR = COMMAND_LINE_ARGS()
  
  PRINT, VAR[0] + ' is processed...'
  
  ; load file, containing climate change mrso factors
  file=NCDF_OPEN('mrso_CC_' + VAR[1] + '_SPIP.nc')

  ; get pressure levels [Pa]
  ID=NCDF_VARID(file,'mrso')
  NCDF_VARGET,file, ID, mrso_CC
  mrso_CC = DOUBLE(REFORM(mrso_CC, /OVERWRITE))
  NCDF_CLOSE,file
  
  
  ; open cas-file, to be modified
  file=NCDF_OPEN(VAR[0], /WRITE)
  ; coefficients, defining sigma pressure coordinates
  ID=NCDF_VARID(file,'W_SO_REL')
  NCDF_VARGET,file, ID, W_SO_REL   ; ratio of volume fraction of soil moisture to pore volume [1]
  W_SO_REL = DOUBLE(W_SO_REL[*,*,*]) * mrso_CC[0]
  
  
  NCDF_VARPUT,file, ID, FLOAT(W_SO_REL)

  NCDF_CLOSE,file
  
END
