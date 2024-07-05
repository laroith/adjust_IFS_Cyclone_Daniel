cdo -monmean -selmonth,9 -sellonlatbox,-16.6114,43.8839,22.5868,47.5721 -selyear,1971/2000 -mergetime /data/reloclim/normal/CMIP6/CMIP/EC-Earth-Consortium/EC-Earth3/historical/r1i1p1f1/day/hus/gr/v20200310/hus_day_EC-Earth3_historical_r1i1p1f1_gr_*.nc hus_EC3_hist.nc

cdo ymonmean -selmonth,9 -selyear,1971/2000 -sellonlatbox,-16.6114,43.8839,22.5868,47.5721 -mergetime /data/reloclim/normal/CMIP6/CMIP/EC-Earth-Consortium/EC-Earth3/historical/r1i1p1f1/day/mrso/gr/v20210324/mrso_day_EC-Earth3_historical_r1i1p1f1_gr_*.nc mrso_EC-Earth3_September_1971_2000_ymonmean.nc

