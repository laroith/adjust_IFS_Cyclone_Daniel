import xarray as xr
import numpy as np
import argparse
from pathlib import Path
import glob

"""
This script processes CAS files to update T_SKIN values based on conditions
related to sea surface temperatures (SST), land fraction, .

Arguments:
- --cas_input_dir: Directory containing the CAS files to process.
- --output_dir: Directory where the modified CAS files will be saved.

The script modifies T_SKIN values based on ocean, land,


Example use:
python apply_CC_cas.py --cas_input_dir=/path/to/cas_files --output_dir=/path/to/output_dir
"""


def process_file(cas_file_path, sst_file_path, output_dir):
    #print(cc_signal_file_path)
    file_cas = xr.open_dataset(cas_file_path)

    fr_land = file_cas['FR_LAND']

    file_cas['T_SKIN'] = xr.where(fr_land <= 0.05, file_cas['T_SKIN'] - 1.3, file_cas['T_SKIN'])

    output_file_path = Path(output_dir) / cas_file_path.name
    file_cas.to_netcdf(output_file_path)

def main():
    parser = argparse.ArgumentParser(description='Process SST and CC signal files.')
    parser.add_argument('--cas_input_dir', required=True, help='Input directory for CAS files.')
    parser.add_argument('--output_dir', required=True, help='Output directory for modified CAS files.')
    args = parser.parse_args()

    
    cas_files = glob.glob(f'{args.cas_input_dir}/cas*[0-9].nc')

    for cas_file in cas_files:
        process_file(Path(cas_file), Path(args.sst_file_path), Path(args.output_dir))

if __name__ == "__main__":
    main()
