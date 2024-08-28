# emtools - a toolbox for geophysical EM-simulation data and model file processing, analysis, plotting, and other gimmicks

## Table of Contents
  - [📖About](#about)
  - [🏗️Installation🚧](#️installation)
  - [📉Plotting EM-data: **emtools\_data\_plot**](#plotting-em-data-emtools_data_plot)
  - [📉Examples for **emtools\_data\_plot**](#examples-for-emtools_data_plot)
  - [📞Contact](#contact)

## 📖About 
Geophysical electromagnetic (EM) simulations involve a host of pre- and post-simulation steps
that prepare, modify, process and analyze simulation inputs and outputs.
**emtools** is a suite of tools for many of these tasks:
1. creation and modification of EM data input/output files
2. creation and modification of EM model input/output files and their corresponding grid (mesh) files
3. plotting of data and models

**emtools** is a derivative of Michael Commer's EMGeo toolboxes emgeo_prc, emgeo_modelcom, em3d_modelcom, and em3d_dataplot. These tools were developed at Lawrence Berkeley Nat'l Lab, California. em3d_dataplot examples can for example be seen in:
*Commer,  M., and Newman, G.A., (2008). New advances in three-dimensional controlled-source electromagnetic inversion, Geophys. J. Int., 172/2, 513–535*. **emtools_data_plot** is based on em3d_dataplot. The **emtools_data_plot** extension for ModEM data files (1st version: 2023.10) was developed at Observatorio Nacional, Rio de Janeiro.

### Currently available **emtools**
1. **emtools_data_plot** - plotting of data, supported formats: ModEM

### Data formats supported by **emtools**
EM simulation codes are often proprietary and have their own specific file formats for data and
model inputs and outputs. **emtools** currently supports the formats of these simulators:
1. **ModEM** - ModEM is a modular system of computer codes for 
inversion of EM geophysical data developed over the past decade at Oregon State University. 
A stable version of the code tailored to inversion of 3D magnetotelluric data has been made freely
available for academic research. See also: *Egbert, G.D., Meqbel, N., and Ritter, O. (2014). 
Implementing novel schemes for inversion of 3D EM data in ModEM, the OSU modular EM inversion system. 
Soc. Expl. Geophys. Tech. Prog. Exp. Abstr.*

## 🏗️Installation🚧
Installation of **emtools** is done from a terminal command prompt.
### 1. ✅Required auxiliary tools
Before installation, ensure that the following tools are available on the system where you run **emtools**:
1. git (also available under https://git-scm.com)
2. csh
3. gawk
4. gnuplot
5. ps2pdf
6. sed

The above components are standard tools. If not present on your system, their installation should be straightforward using your OS-specific package handling utility, for example under Ubuntu:
```shell
sudo apt-get update
sudo apt-get -y install gnuplot
```

### 2. 👭Make the **emtools** parent directory and clone
The **emtools** parent directory is where you will do "git clone ...".
```shell
# 1) Go to your home directory
cd ~
# 2) If not already present: create the parent dir. usr/local in your home
# Note: This is the recommended installation. You can choose another location,
# for example /usr/local or /opt (then the next steps might need to be su-done)
mkdir -p usr/local
cd usr/local
# 3) Clone the repository. Afterwards, you will have ~/usr/local/emtools/
git clone https://github.com/mcommer/emtools.git
# 4) make the emtools executables executable (if needed, dep. on umask) 
chmod u+x emtools/bin/*
```

### 3. 🛒Export the EMTOOLS shell variable
The EMTOOLS shell variable is needed by most tools of the **emtools** package and is set to  
EMTOOLS = \<PARENT-DIR\>/emtools = **${HOME}/usr/local/emtools** (as recommended above in Step 2)  
It is further recommended to set EMTOOLS at shell startup, for example for bash-users:
```shell
# this is in your ~/.bashrc file
export EMTOOLS=${HOME}/usr/local/emtools
# add the $EMTOOLS/bin/ directory to your executable-PATH
export PATH=${PATH}:${EMTOOLS}/bin
```
Alternatively, you can set EMTOOLS via the **emtools** configuration file **${HOME}/.emtools**
```shell
# emtools configuration file for user "me", resides in /home/me/.emtools
EMTOOLS: /home/me/usr/local/emtools  # uncomment to activate / comment to deactivate
```


## 📉Plotting EM-data: **emtools_data_plot**
**emtools_data_plot** is a tool for plotting data from geophysical electromagnetic (EM) input/output files.
**emtools_data_plot** is part of the **emtools** suite. Currently supported EM data file formats:
- ModEM

After installation, you can run
```shell
emtools_data_plot -h
```
to get a manpage-like help screen. Type "q" to exit the help screen.

## 📉Examples for **emtools_data_plot**
Directories with plot examples are contained in the directory
**${EMTOOLS}/doc/examples/emtools_data_plot/**

### 📉Example 1: MT_data_comparison/
- Plots two MT files together
- Output file: mt_base_anom.pdf
```shell
emtools_data_plot mt_base.out mt_anom.out -k base,anomaly -o mt_base_anom
```

### 📉Example 2: InvTest/
- You can plot an arbitrary number of data sets (data files) together
- Here, three data sets are combined in one plot
- Output files: smallmod.pdf, smallmod.dat, smallmod.gnu
- The option "-keep" saves the files smallmod.dat and smallmod.gnu in the same
directory from where **emtools_data_plot** was run
- Option "-keep" is useful if one wants to use the plotting data for other purposes, for example plot
creation in publications, other fine-tuning, etc.
```shell
emtools_data_plot smallmod_NLCG_000.dat smallmod_NLCG_005.dat smallmod_NLCG_010.dat -k Iter_0,Iter_5,Iter10 -o smallmod -w p_pt_5_ps_0.4,l,l -keep
```

### 📉Example 3: MCM/
Example MCM-1:
- Plot measured data, where measured_Ey_20_Err.dat is a CSEM data set and Measured_MT_2_0.5.dat is an MT data set
- Output files: measured_Ey.pdf (ex. MCM-1), Measured_MT_2_0.5_plot.pdf (ex. MCM-2)
- This uses the gnuplot style "-w lp_pt_3_lt_4" = "with linespoints pointtype 3 linetype 4"

Example MCM-2:
- Since no output file is specified, the default name *_plot is used as fileroot, where * is the fileroot of the input file name (Measured_MT_2_0.5).
- Here, the with-argument "-w p_pt_6_lt_2" = "with points pointtype 6 linetype 2" causes the point symbols to be plotted with the color that corresponds to linetype 2.

Example MCM-3:
- Output file: Rx_y_subsets.pdf
- This command will produce 884 plot pages. Each page corresponds to a data subset
- In each data subset, the MT-receiver's x-coordinates represent the abscissa
- All receivers of a subset further share a unique y-coordinate; the latter will be specified in the plot title
```shell
# Example MCM-1
emtools_data_plot -w lp_pt_3_lt_4 -o measured_Ey measured_Ey_20_Err.dat
# Example MCM-2
emtools_data_plot -w p_pt_6_lt_2 Measured_MT_2_0.5.dat -view
# Example MCM-3
emtools_data_plot -w p_pt_5 -r x:y -o Rx_y_subsets Measured_MT_2_0.5.dat -view
```

### 📉Example 4: PauloTest1/
Example PauloTest1-a:
- The example involves data sets that have only small numerical differences
- Demonstrates the option "-col" and data-difference plotting
- Output file: pred_dip1d.pdf
- The first option "-col r:light-green,i:honeydew" sets the background colors of the RE and IM plots to
the color names "light-green" and "honeydew", respectively
- The y-range of each plot is set to the interval [1e-19,1e-11]. This interval applies to
the y-axis of all RE-data subplots and all IM-data subplots
- The two data sets pred_dip1d_bef.dat and pred_dip1d_aft.dat are numerically very similar,
therefore, only one plot line will be visible

Example PauloTest1-b:
- Output files: pred_diff_Abs.pdf, pred_diff_Abs.dat, pred_diff_Abs.gnu
- The example demonstrates the differencing functionality of **emtools_data_plot**
- The resulting plot shows absolute differences between the data sets pred_dip1d_bef.dat and pred_em1d_bef.dat
- The y-range is set to [0,1e-11] (linear y-axis) for all subplots
- The background color of the whole plot page is set to light-magenta
```shell
# Example PauloTest1-a
emtools_data_plot -col r:light-green,i:honeydew -yr 1e-19,1e-11 -k Dipole1d_before,Dipole1D_after -o pred_dip1d pred_dip1d_bef.dat pred_dip1d_aft.dat -view
# Example PauloTest1-b
emtools_data_plot -col b:light-magenta -da -yr 0,1e-11 -o pred_diff_Abs pred_dip1d_bef.dat pred_em1d_bef.dat -keep -view,xpdf
```
To get a list of all possible color names, start gnuplot and type "show colornames":
```shell
 gnuplot> show colornames
         There are 111 predefined color names:
   white              #ffffff = 255 255 255
   black              #000000 =   0   0   0
   dark-grey          #a0a0a0 = 160 160 160
   red                #ff0000 = 255   0   0
   web-green          #00c000 =   0 192   0
   web-blue           #0080ff =   0 128 255
   dark-magenta       #c000ff = 192   0 255
   dark-cyan          #00eeee =   0 238 238
   ...
```

### 📉Example 5: PauloTest2/
Example PauloTest2-a:
- The example shows the usage of the data plotting style yerrorbars
- Output file: pred_em1d_iso_on_plot.pdf
- The plot uses errorbar symbols: "with yerrorbars pointtype 4 pointsize 0.3 linetype 3"
- Here, the T-string is present and is set to "1e-11" (end of "-w"-option argument), which denotes an absolute half-errorbar length of 1e-11
- The option "-yr e" sets all plot-y-axis ranges to the same interval, which is given by the global min and max data value
- The option "-view" will launch the default PDF-file viewer, which you can set via the line "PDFVIEWER: ..." in the **emtools** configuration file

Example PauloTest2-b:
- Output file: pred_em1d_iso_on2_plot.pdf
- The plot uses errorbar symbols: "with yerrorbars pointtype 2 pointsize 0.7 linetype 4"
- Here, the T-string is present and is set to "26.5%", which denotes a relative half-yerrorbar size in percent
- The yerrorbar of a given data point y thus extends over the range [y1,y2] = [y-|y|*p/100,y+|y|*p/100], where p=26.5
- The option "-view,xpdf" will launch the PDF-file viewer "xpdf"

```shell
# Example PauloTest2-a
emtools_data_plot pred_em1d_iso_on.dat -w yerr_pt_4_ps_0.3_lt_3:1e-11 -yr e -view
# Example PauloTest2-b
emtools_data_plot pred_em1d_iso_on.dat -w yerr_pt_2_ps_0.7_lt_4:26.5% -yr e,e -view,xpdf -o pred_em1d_iso_on2_plot
```

### 📉Example 6: SmallModelResponse/
- Play more with colors and experiment with logo-graphic insertion
- Output file: compare_em1d_dip1d.pdf
- Here, the page color is set to gray90 (a light-grey tone), while the RE- and IM-subplots will have other distinct colors
- A logo PNG file is included at the plot page bottom using the option "-logo ./companylogo.png" (PNG-file needs to be present in the run directory)
- The option "-logo" is experimental, as one may have to tweak the logo graphic to achieve a satisfying outcome
- The option "-view,xpdf" will launch the PDF-file viewer "xpdf"
```shell 
emtools_data_plot -k EM1D,Dipole1D csem.em1d csem.di1d -o compare_em1d_dip1d -col b:gray90,r:tan1,i:gray80 -logo ./companylogo.png -view,xpdf
```

## 📞Contact
micha@on.br
