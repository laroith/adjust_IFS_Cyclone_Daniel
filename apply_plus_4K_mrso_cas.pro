PRO main

  CPU, TPOOL_NTHREADS=1
  
  VAR = COMMAND_LINE_ARGS()
  
  PRINT, VAR[0] + ' is processed...'
  
  ; load file, containing climate change mrso factors
  ; adopted to 2018 event - every available time step should be modified
  ;file=NCDF_OPEN('mrso_CC_' + VAR[1] + '_October.nc_plus_4K')
  file=NCDF_OPEN('mrso_CC_' + VAR[1] + '_SPIP.nc_plus_4K')

  ; get CC of soil moisture
  ID=NCDF_VARID(file,'mrso')
  NCDF_VARGET,file, ID, mrso_CC
  mrso_CC = DOUBLE(REFORM(mrso_CC, /OVERWRITE))
  NCDF_CLOSE,file
  
  
  ; open cas-file, to be modified
  file=NCDF_OPEN(VAR[1] + '/' + VAR[0], /WRITE)
  ; coefficients, defining sigma pressure coordinates
  ID=NCDF_VARID(file,'W_SO_REL')
  NCDF_VARGET,file, ID, W_SO_REL   ; ratio of volume fraction of soil moisture to pore volume [1]
  W_SO_REL = DOUBLE(W_SO_REL[*,*,*])
  
  ; calculate day of the year
  day_mon = [ 0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 ]

  ; derive day of the year from input file name casYYYYMMDDHHSS.nc
  mon = STRMID(VAR[0], 7, 2)
  day = STRMID(VAR[0], 9, 2)
  doy = 0
  FOR ii=0,mon-1 DO BEGIN
    doy = doy + day_mon[ii]
  ENDFOR
  doy = doy + day
  ; change day of year into time index in CC file
  doy = doy - 1
  
  doy_max = N_ELEMENTS(mrso_CC) -1L
  
  doy = FIX(doy / 365 * doy_max)
    
  ; extract CC for just this day of the year
  
  NCDF_VARPUT,file, ID, FLOAT(W_SO_REL * mrso_CC[doy])

  NCDF_CLOSE,file
  
END
