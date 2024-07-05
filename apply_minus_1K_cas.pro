PRO main

  CPU, TPOOL_NTHREADS=1
  
  VAR = COMMAND_LINE_ARGS()
  
  PRINT, VAR[0] + ' is processed...'
  
  ; save cas-file in output folder
  FILE_COPY, 'input/' + VAR[0] , VAR[1] + '/' + VAR[0], /OVERWRITE
  
  ; load file, containing climate change profiles
  file=NCDF_OPEN('CC_' + VAR[1] + '_' + VAR[2] + '.nc_minus_1K')

  ; get pressure levels [Pa]
  ID=NCDF_VARID(file,'plev')
  NCDF_VARGET,file, ID, plev_CC
  plev_CC = DOUBLE(REFORM(plev_CC, /OVERWRITE))
  ; get air temperature [K]
  ID=NCDF_VARID(file,'ta')
  NCDF_VARGET,file, ID, ta_CC
  ta_CC = DOUBLE(REFORM(ta_CC, /OVERWRITE))
  idx = WHERE(ta_CC GT 1000.0, cnt)
  IF cnt GT 0 THEN ta_CC[idx] = !VALUES.F_NAN
  ; get relative humidity [%]
  ID=NCDF_VARID(file,'hur')
  NCDF_VARGET,file, ID, hur_CC
  hur_CC = DOUBLE(REFORM(hur_CC, /OVERWRITE))
  idx = WHERE(hur_CC GT 1000.0, cnt)
  IF cnt GT 0 THEN hur_CC[idx] = !VALUES.F_NAN
  ; get specific humidity [-]
  ID=NCDF_VARID(file,'hus')
  NCDF_VARGET,file, ID, hus_CC
  hus_CC = DOUBLE(REFORM(hus_CC, /OVERWRITE))
  idx = WHERE(hus_CC GT 1000.0, cnt)
  IF cnt GT 0 THEN hus_CC[idx] = !VALUES.F_NAN
  ; get sea level pressure
  ID=NCDF_VARID(file,'psl')
  NCDF_VARGET,file, ID, psl_CC
  psl_CC = DOUBLE(REFORM(psl_CC, /OVERWRITE))

  NCDF_CLOSE,file
  
  
  ; open cas-file, to be modified
  file=NCDF_OPEN(VAR[1] + '/' + VAR[0], /WRITE)
  ; coefficients, defining sigma pressure coordinates
  ID=NCDF_VARID(file,'akm')
  NCDF_VARGET,file, ID, A
  ID=NCDF_VARID(file,'bkm')
  NCDF_VARGET,file, ID, B
;  ID=NCDF_VARID(file,'ak')
;  NCDF_VARGET,file, ID, Ai    ; coefficients at 'interfaces'
;  ID=NCDF_VARID(file,'bk')
;  NCDF_VARGET,file, ID, Bi    ; coefficients at 'interfaces'

  ID=NCDF_VARID(file,'FIS')
  NCDF_VARGET,file, ID, Zsurf   ; surface geopotential
  Zsurf = DOUBLE(REFORM(Zsurf, /OVERWRITE))
  ID=NCDF_VARID(file,'T_SKIN')
  NCDF_VARGET,file, ID, SKT   ; skin temperature
  SKT = DOUBLE(REFORM(SKT, /OVERWRITE))
  ID=NCDF_VARID(file,'T')
  NCDF_VARGET,file, ID, T   ; air temperature
  T = DOUBLE(REFORM(T, /OVERWRITE))
  ID=NCDF_VARID(file,'QV')
  NCDF_VARGET,file, ID, QV   ; specific humidity
  QV = DOUBLE(REFORM(QV, /OVERWRITE))
  ID=NCDF_VARID(file,'QC')
  NCDF_VARGET,file, ID, QC   ; cloud liquid water content [kg kg-1}
  QC = DOUBLE(REFORM(QC, /OVERWRITE))
  ID =NCDF_VARID(file,'PS')
  NCDF_VARGET,file, ID, SP   ; surface pressure
  SP = REFORM(DOUBLE(SP), /OVERWRITE)

;  NCDF_CLOSE,file
  
  ; get dimensions
  dim = SIZE(T, /DIMENSIONS)

  IF VAR[2] EQ 'SPIP' THEN BEGIN
    ; constants for day of year calculations
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
    
    doy_max = N_ELEMENTS(ta_CC[0,*]) -1L
    
    doy = FIX(doy / 365 * doy_max)
    
    ; extract CC for just this day of the year
    ta_CC = ta_CC[*,doy]
    hus_CC = hus_CC[*,doy]
    hur_CC = hur_CC[*,doy]
    psl_CC = psl_CC[doy]
    
  ENDIF ELSE BEGIN
    doy = 0 
  ENDELSE

  
  ; constants - as double
  Rd      = 287.06D   ; taken from ECMWF geopotential calculator
  
  ; constants - as double - from OpenIFS
  g       = 9.80665D            ;m s-2
  eps     = 1.0D / ( 1.0D + 0.609133D )  ; = Rd/Rw = Mw / Md
  Mw      = 18.0153D * 0.001D ;Kg/mol
  Md      = 28.9644D * 0.001D ;Kg/mol
  Rstar   = 1.380658D * 6.0221367D       ;J/molK
  
  ; calculate 3D pressure
  P = DBLARR(dim[0],dim[1],dim[2], /NOZERO)
  FOR kk=0,dim[2]-1 DO BEGIN
    P[0,0,kk] = ( A[kk] + B[kk] * SP)
  ENDFOR
;  FOR kk=0,dim[2] DO BEGIN
;    Ph[0,0,kk] = ( Ai[kk] + Bi[kk] * SP)
;  ENDFOR
;  Ph[*,*,0] = 0.1D
  
  ; for the calculation of saturation pressure es [Pa] from Murray (1967)
  ai = 21.8745584D
  bi = 7.66D
  aw = 17.2693882D
  bw = 35.86D


  ; =====================
  ; define current state
  ; =====================
  
  ; calculate exponential factor (ratio between sea level pressure and surface pressure), following the IFS documentation 
  ; (YESSAD. K, 2011, "FULL-POS IN THE CYCLE 38 OF ARPEGE/IFS.")
  ; this is needed because there is a climate change signal of mean sea level pressure
  ; and this needs to be transferred into a climate change signal of the surface pressue
  
  lev=dim[2]-1 ; lowest full level

  ; surface temperature
  Tsurf = T[*,*,lev] + 0.0065D * Rd * ( SP[*,*] / P[*,*,lev] - 1.0D ) * T[*,*,lev] / g

  ; surface temperature at sea level 
  T0    = Tsurf[*,*] + 0.0065D * Zsurf[*,*] / g

  ; define temperature lapse rate gamma
  gamma = DBLARR(dim[0],dim[1])
  gamma[*,*] = 0.0065D
  
  ; modify gamma according to temperatures
  idx = WHERE(T0 GT 290.5 AND Tsurf LE 290.5, cnt)
  IF cnt NE 0 THEN gamma[idx] = ( 290.5D - Tsurf[idx] ) * g / Zsurf[idx]
  idx = WHERE(T0 GT 290.5 AND Tsurf GT 290.5, cnt)
  IF cnt NE 0 THEN BEGIN 
    gamma[idx] = 0.0D
    Tsurf[idx] = 0.5D * (290.5D + Tsurf[idx])
  ENDIF
  idx = WHERE(Tsurf LT 255.0, cnt)
  IF cnt NE 0 THEN Tsurf[idx] = 0.5D * (255.0D + Tsurf[idx])
  
  ; exponential factor to modify surface pressure
  x = gamma[*,*] * Zsurf[*,*] / g / Tsurf[*,*]
  EXPFAC = EXP( Zsurf[*,*] / Rd / Tsurf[*,*] * (1.0D - 0.5D * x + 1.0D / 3.0D * x^2) )
  

  ; ==========================
  ; add climate change signals
  ; ==========================

  ; first, add CC in pressure
  SP = SP[*,*] + psl_CC[0] / EXPFAC
  P_new = DBLARR(dim[0],dim[1],dim[2], /NOZERO)
  FOR kk=0,dim[2]-1 DO BEGIN
    P_new[0,0,kk] = ( A[kk] + B[kk] * SP)
  ENDFOR
  
  ; now interpolate current state (T and QV) onto the new pressure levels
  FOR ii=0,dim[0]-1 DO BEGIN
    FOR jj=0,dim[1]-1 DO BEGIN
      T[ii,jj,*] = INTERPOL(T[ii,jj,*], ALOG(P[ii,jj,*]), ALOG(P_new[ii,jj,*]), /NAN)
      QV[ii,jj,*] = INTERPOL(QV[ii,jj,*], ALOG(P[ii,jj,*]), ALOG(P_new[ii,jj,*]), /NAN)
    ENDFOR
  ENDFOR
  ; make sure QV is not negative
  QV = QV > 0.0D
  
  ; calculate RH of current state on new pressure levels
  es = 610.78D * EXP( aw * ( T -273.16D ) / ( T - bw) ) ; over water
  idx = WHERE(T LT 233.15, cnt)
  IF cnt NE 0 THEN es[idx] = 610.78D * EXP( ai * ( T[idx] -273.16D ) / ( T[idx] - bi) ) ; over ice
  
  ; current RH [not in %]
  RH = P_new *  QV / ( Mw/Md + ( 1.0D - Mw/Md ) * QV ) / es
  RH = RH > 0.0D
  
  ; interpolate CC signals onto new pressure levels
  hur_CC_f = DBLARR(dim[0],dim[1],dim[2])
  hus_CC_f = DBLARR(dim[0],dim[1],dim[2])
  ta_CC_f = DBLARR(dim[0],dim[1],dim[2])
  
  FOR ii=0,dim[0]-1 DO BEGIN
    FOR jj=0,dim[1]-1 DO BEGIN
      hur_CC_f[ii,jj,*] = INTERPOL(hur_CC, ALOG(plev_CC), ALOG(P_new[ii,jj,*]), /NAN)
      ta_CC_f[ii,jj,*] = INTERPOL(ta_CC,ALOG(plev_CC), ALOG(P_new[ii,jj,*]), /NAN)
    ENDFOR
  ENDFOR
  

  ; add CC in RH 
  RH = RH + (hur_CC_f/100.0D)
  ; RH must not be negative
  RH = RH > 0.0D
  
  ; add CC in T
  T = T + ta_CC_f
  
  ; calculate QV from changed T, P, and RH
  es = 610.78D * EXP( aw * ( T -273.16D ) / ( T - bw) ) ; over water
  IF cnt NE 0 THEN idx = WHERE(T LT 233.15, cnt)
  es[idx] = 610.78D * EXP( ai * ( T[idx] -273.16D ) / ( T[idx] - bi) ) ; over ice
  
  QV = (Mw/Md) * RH * es / ( P_new - ( 1.0D - Mw/Md ) * RH * es ) 
  QV = QV > 0.0D
  
  ; cloud liquid water content - according to Gultepe and Isaac (1997)
  ; not needed in Aditya's simulations
  ;QC = QC * EXP( 0.01344D * ta_CC_f )
  
  
  ; save T, QV, and SP in file
  ID = NCDF_VARID(file,'QV')
  NCDF_VARPUT,file, ID, FLOAT(QV)
  ID=NCDF_VARID(file,'T')
  NCDF_VARPUT,file, ID, FLOAT(T)
  ID=NCDF_VARID(file,'PS')
  NCDF_VARPUT,file, ID, FLOAT(SP)
;  ID=NCDF_VARID(file,'QC')
;  NCDF_VARPUT,file, ID, FLOAT(QC)
  NCDF_CLOSE,file
  
END
