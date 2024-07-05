#!/bin/bash

for file in *.nc; do
  cdo timmean "$file" "temp_$file" && mv "temp_$file" "$file"
done
