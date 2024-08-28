# EMTOOLS: emtools_data_plot
# Author: Michael Commer
# Last change: Nov 9 2023
# Description: Plots data subsets from ModEM data file
# Sat Aug 17 20:33:37 CEST 2024: last change before github upload
function print_progress(sp,lb,fout, n,nd,i,s){
# print progress without newline
n=length(sp)
if(lb==0){ # initial call: Print progress line (sp) without newline, no backspace
  s=sp
  len_progress[0]=n; len_progress[1]=0
}else if(lb==1){ 
  # n=len of actual string; len_progress[1]=len of previous string
  nd=len_progress[1]-n # overwrite end of previous string with blanks
  s=sp; if(nd>0){for(i=1;i<=nd;i++)s=sprintf("%s ",s); n+=nd}
  # After printout, backspace as many chars as len(s)
  for(i=1;i<=n;i++)s=sprintf("%s\\b",s)
  len_progress[1]=n
}else if(lb==2){ # finalize call
  # first, backspace to beg. of line, so n=len_progress[0] characters still missing
  s=str_gnuplot(2,len_progress[0]) # chain of "\b" chars
  n=len_progress[0]+len_progress[1] # now overwrite whole line with blanks
  for(i=1;i<=n;i++)s=sprintf("%s ",s)
  s=sprintf("%s\\n",s) } # append newline char
printf("!printf %s #__PP\n",strquote(s)) >> fout
} # function print_progress

function g_setfont(n, f,s,sfnt){
f=g_font[1] # f=font face
s=g_font[2]+n # s=font size
if(s<1)s=1
sfnt=sprintf("%s,%i",f,s) # new font setting
return strquote(sfnt)} # "FACE,SIZE"

function data_minmax(f,idat,ifile, j,xa){
# Update min,max of data (stored in DATA-array)
# dat[ff,n,ifile,:]: dat[ff,0,ifile,1:2]=Re-min,max; dat[ff,0,ifile,3:4]=Im-min,max
#       dat[ff,0,ifile,5:6]=|Re-min,max|; dat[ff,0,ifile,7:8]=|Im-min,max|
if(idat==1){ # init-call at 1st data point for set f=ff
  for(j=1;j<=8;j++){
    if(j%2)dat[f,0,ifile,j]=bignum # 1,3,5,... init min
    else dat[f,0,ifile,j]=-bignum} # 2,4,6,... init max
}else if(idat==-1){ # printout of global min,max for file# ifile
  printf("Re-data min,max: %13.6e %13.6e  |min|,|max|: %13.6e %13.6e\n",dat[f,0,ifile,1],dat[f,0,ifile,2],dat[f,0,ifile,5],dat[f,0,ifile,6])
  printf("Im-data min,max: %13.6e %13.6e  |min|,|max|: %13.6e %13.6e\n",dat[f,0,ifile,3],dat[f,0,ifile,4],dat[f,0,ifile,7],dat[f,0,ifile,8])
  return}
#}else if(idat==-2){ # printout of global min,max for all files
#  for(j=0;j<=nfile;i++){
# xr,xi = Data (Re,Im)
if(xr<dat[f,0,ifile,1])dat[f,0,ifile,1]=xr # Re-min
if(xr>dat[f,0,ifile,2])dat[f,0,ifile,2]=xr # Re-max
if(xi<dat[f,0,ifile,3])dat[f,0,ifile,3]=xi # Im-min
if(xi>dat[f,0,ifile,4])dat[f,0,ifile,4]=xi # Im-max
xa=abs(xr)
if(xa<dat[f,0,ifile,5])dat[f,0,ifile,5]=xa # |Re-min|
if(xa>dat[f,0,ifile,6])dat[f,0,ifile,6]=xa # |Re-max|
xa=abs(xi)
if(xa<dat[f,0,ifile,7])dat[f,0,ifile,7]=xa # |Im-min|
if(xa>dat[f,0,ifile,8])dat[f,0,ifile,8]=xa # |Im-max|
} # function data_minmax

function plotline(indx,is,com, i,icol,icol_err,a,b){
# Create string for plot line, is=subplot# (1: Real, 2: Imag)
# set origin and size for this subplot
printf("# Subplot#%i) %s-data\n",is,com) >> fgnu
# set title font slightly smaller than global
printf("set key font %s noenhanced\n",g_setfont(-1)) >> fgnu
printf("set origin x%i,y%i; set size sx,sy\n",is,is) >> fgnu
# subplot backgrd color
if(length(g_color[is]))printf("set obj 1 rect from graph 0,0 to graph 1,1 fc rgb %s behind\n",g_color[is]) >> fgnu
# prepare using-line
icol=g_xyz+1 # Rx data col#
a[0]="plot"
# If data-errors are present in plotdata file: (errRe1,errRe2),(errIm1,errIm2) after last data columns
# err. col. starts at i=7 (for 1 file), 7,8, 9,10 (i+1,...,i+4)
if(length(g_error))icol_err=4+2*(nfile+is)
else icol_err=0
if(g_log){a[1]=sprintf("i %i u %i:(%s",indx,icol,s_abs); a[20]="))"}
else{a[1]=sprintf("i %i u %i:",indx,icol); a[20]=""} # a[20]=end of using-string
for(i=0;i<=nfile;i++){
  icol=5+2*i      # is=1: Real data comp. in col# 5,7,9,...
  if(is==2)icol++ # is=2: Imag data comp. in col# 6,8,10,...
  # If using error bars: plot ... using 1:2:($2-$3):($2+$3)
  if(i==0 && icol_err){
    # Re, also for Im: (abs($icol)-$(icol_err+1)):(abs($icol)+$(icol_err+2))
    a[3]=str_gnuplot(1,icol) # abs($icol)
    a[2]=sprintf("%s:(%s-%s%i):(%s+%s%i)",a[20],a[3],s_dol,icol_err+1,a[3],s_dol,icol_err+2)
  }else a[2]=a[20] # append to a[2]=end of using-string
  # subplot title/key (->a[3])
  a[3]=sprintf(" title %s",strquote(g_key[i]))
  #gsub(/_/,"\\_",a[3]) # escape _ to \_
  # i indx u irx:(abs($icol)) title "..."
  # lines/points-style: w p ps pt, w l lt 2 lw 1.8 (here "_" = blanks)
  split(g_dstyle[i],b,":"); a[4]=b[1]
  # a[1]= indx and using, icol a[2]=)or"", a[3]=title, a[4]=with...(plot style)
  # w l[p][lp] lt i lw W pt PT ps PS
  a[5]=sprintf("%s%i%s%s with %s",a[1],icol,a[2],a[3],a[4])
  # append lt (linetype), only if not set by user
  if(!index(a[4],"lt")>0 && !index(a[4],"linetype"))a[5]=sprintf("%s lt %i",a[5],i+1)
  # print "plot d i INDX u ..." (file# i=0), or ", d i INDX u ..." (file# i>0)
  printf("%s d %s",a[0],a[5]) >> fgnu; a[0]=","
} # nfile
printf("\n") >> fgnu
} # function plotline

function plotreset(iin){
if(iin==0){
  print "unset xlabel; unset ylabel; unset grid; unset xtics; unset ytics; unset border; unset obj 1" >> fgnu
}else{
  print "set xlabel; set ylabel; set grid; set xtics; set ytics; set border" >> fgnu
}}

BEGIN{
# data types
myname="emtools_data_plot"
# String constants
s_abs="abs($" # for plotting of log data
s_dol="$"
com_chars["modem"]="#,>" # ModEM comment chars
s_coordxyz["x"]=1; s_coordxyz["y"]=2; s_coordxyz["z"]=3
s_xyz[1]="x"; s_xyz[2]="y"; s_xyz[3]="z"
g_multiplot="set multiplot; set size sx,sy"
# Number constants
bignum=1e23; smallnum=1e-20
ndata0=0 # total number of input data (for FILENAME)
nhline=0 # header-line counter
split("MT,CSEM",sdatatype,",")
# Data cols for MT: 9,10; CSEM: 14,15
data_fmt="modem"
# Gnuplot settings:
g_xyz=0 # Default Rx column# to plot (ex: g_xyz=3 -> using 3:5)
g_xyz_profile=0 # Profile binning for Rx
n=split("Rx#,X (m),Y (m),Z (m)",a,",")
for(i=1;i<=n;i++)g_xyz_title[i-1]=a[i]
g_dstyle[0]="l"; g_dstyle[-1]=0 # lines
g_font[1]="Courier"; g_font[2]=13 # default font face,size
g_userheader="" # Additional (optional user-defined) Gnuplot header file
g_sepoutputfile=""
g_log=1
for(i=0;i<3;i++)g_color[i]=""
g_logo="" # insert logo image in each plot page
g_key[0]="" # subplot key
g_diff="" # plot differences between 2 data sets
for(j=0;j<=2;j++){g_xrange[j]=""; g_yrange[j]=""} # init x-range,y-range settings
# Prg variables:
ltest=0 # test run
nfile=0 # number of additional data input FILENAMES
# Progress reporting to stdout during Gnuplot processing
lprogress=1; len_progress[0]=0; len_progress[1]=0
verbose=1 # Verbose level
ios=0 # error flag
delete a
}

#
# MAIN
#
{ # MAIN
DATA[0,0]=$0 # save input line $0
if(!NF)exit # blank line
# Process extra args
if(NR==1){ # process input options
  FILENAMES[0]=FILENAME
  # Default output filenames
  while(getline < args){
    if($1 ~ /OUTFILE:/){froot=$2 # always present
      fdat=sprintf("%s.dat",$2); fgnu=sprintf("%s.gnu",$2)
      flst=sprintf("%s.lst",$2)
      fsta=sprintf("%s.sta",$2) # status output file to return
    }else if($1 ~ /TEST:/)ltest=1
    else if($1 ~ /FILE:/)FILENAMES[++nfile]=$2 # additional input files
    else if($1 ~ /USERHEADER:/)g_userheader=$2
    else if($1 ~ /OUTSEP:/)g_sepoutputfile=$2
    else if($1 ~ /LOGO:/)g_logo="set origin xlogo,ylogo; set size sxlogo,sylogo"
    else if($1 ~ /SYSTEM:/)sys_name=tolower($2)
    else if($1 ~ /VERBOSE:/)verbose=2 # high level
    else if($1 ~ /g_dstyle:/){n=split($2,a,","); g_dstyle[-1]=n-1 # set data style (l/p)
	  for(i=1;i<=n;i++){g_dstyle[i-1]=a[i]; gsub(/_/," ",g_dstyle[i-1])}}
    else if($1 ~ /g_font:/){n=split($2,a,",") # set global font: face,size
	if(length(a[1]))g_font[1]=a[1]; if(length(a[2]))g_font[2]=a[2]+0}
    else if($1 ~ /g_xyz:/){ # select x-axis coordinate (Rx#,x,y,z) 
	s=$2; gsub(/s/,"",s)
	n=split(s,a,":"); s=a[1]
	if(s=="n")i=0
        else if(s=="x" || s=="y" || s=="z")i=s_coordxyz[s]
        else{i=s+0; if(i<0 || i>3)i=0}
	g_xyz=i
	if(n>1){s=a[2]; if(s=="x"|| s=="y" || s=="z")g_xyz_profile=s_coordxyz[s]}}
    else if($1 ~ /g_xrange:/)g_xrange[0]=$2
    else if($1 ~ /g_yrange:/)g_yrange[0]=$2
    else if($1 ~ /g_key:/)g_key[0]=$2 # set subplot keys
    else if($1 ~ /g_diff:/){g_diff=$2; sub(/-/,"",g_diff)} # set subplot keys
    else if($1 ~ /g_color/){ # color settings: "-col b:*,r:*,i:*" (background,real-plot,imag-plot)
	n=split($2,a,",")
	for(i=1;i<=n;i++){split(a[i],d,":"); s=strquote(d[2])
	    if(d[1]~/b/){g_color[0]=s; printf("Background color set to: %s\n",g_color[0])}
	    else if(d[1]~/r/){g_color[1]=s; printf("RE-data-plot background color set to: %s\n",g_color[1])}
	    else if(d[1]~/i/){g_color[2]=s; printf("IM-data-plot background color set to: %s\n",g_color[2])} } #i
    } # 
  } # while getline
} # NR=1
# Start data processing
readline_files(0,nfile)
if(isheaderline(DATA[0,1],com_chars[data_fmt])){ # header/comment line
  lc=0
  nhline++ # count header lines
}else{ # data input line
  lc=1
  ndata0++ # count total number of data lines
}
#
# Only supported here: ModEM data format
#
if(lc){ # data input line
    # xr=tolerance
    if(g_log)xr=smallnum # to avoid 0 on log y-axis
    else xr=0 # ok to have 0 on lin y-axis
    if(length(g_diff))xr=0 # tol=0 for difference plots
    ff=modem_data_plot_dataline(datatype,nfile,g_xyz_profile,xr,g_error) # ID
    n=NPLOTDATA[ff]
    # Save input data fields
    for(i=0;i<=nfile;i++){
      xr=DATA[i,icol]+0; xi=DATA[i,icol+1]+0 # Re,Im-data
      dat[ff,n,i,1]=xr; dat[ff,n,i,2]=xi # Re,Im-data
      data_minmax(ff,n,i) # init data min,max arrays for this data set (ff)
      data_minmax("all",ndata0,i) # update the global min,max (over all data sets of file# i)
      data_minmax("all",ndata0,nfile+1) # update the global min,max (over all data sets of all files)
    } # i
}else{ # header line
    if(nhline==3){ # determine data type (MT or CSEM)
      datatype=modem_get_datatype(DATA[0,2])
      sdatatype[0]=DATA[0,2] # Data type name from header line# 3
      if(datatype==1)icol=9 # Re-data col# MT
      else icol=14 # Re-data col# CSEM
      # Set data style
      if(g_dstyle[-1]<nfile)for(i=g_dstyle[-1]+1;i<=nfile;i++)g_dstyle[i]="l"
      # plot style: with yerr: w ...:%l  only for 1st input file (File#0)
      n=split(g_dstyle[0],a,":"); x1=0; x2=0; x3=0 # perc, lim-factor, lim-const
      if(a[1]~/yerr/){
	# err_perc>0: percentage of data value, <0: abs error, =0: data-error col.
        for(i=2;i<=n;i++){
	  if(length(a[i])){
    	    if(a[i]~/%/){sub(/%/,"",a[i]); x1=a[i]+0} # %-error
	    else if(a[i]~/lf/){sub(/lf/,"",a[i]); x2=a[i]+0} # limit fac
	    else if(a[i]~/lc/){sub(/lc/,"",a[i]); x3=a[i]+0} # limit const
	    else x1=-(a[i]+0)} # abs error
	} #i
	g_error=sprintf("%.4e %.4e %.4e",x1,x2,x3) # const./perc., factor-limit
      }else g_error="" # init
    }else if(nhline==5)data_unit=DATA[0,2] #sub(/\[/,"",data_unit); sub(/\]/,"",data_unit)
} # lc
} # MAIN

END{
# If error: return exit status (ios)
if(ios){
  print "1" > fsta # error
  exit # exit if error ocurred
}
#
# Plot output
#
n_indx=0; n=0
delete a # need to delete for sorting
xi=bignum
for(s in NPLOTDATA){ #s=ff-string
  a[++n_indx]=s
  #print "ff orig",n_indx,s
  n+=NPLOTDATA[s] # checksum
  split(s,d,",")
  xr=d[1]+0
  if(xr<xi)xi=xr # min
}
printf("Total number of Gnuplot plot indeces (one index = one Re+Im-data plot): %i\n",n_indx)
printf("Total number of data points Ndata: %i\n",ndata0)
if(n!=ndata0){
  printf("ERROR: Ndata different to checksum N=%i\n",n)
  print "1" > fsta; exit # 1=error exit code
}
# replace 1st (sorting) col by shifted num
for(i=1;i<=n_indx;i++){
  s0=a[i]
  split(s0,d,",")
  xr=d[1]-xi # shift so that min=0
  #dtst[i]=sprintf("%16.5f",d[1]-xi); gsub(/ /,"0",dtst[i]) #tstsrt
  s=sprintf("%18.5f",xr); gsub(/ /,"0",s) # sorting col
  j=index(s0,",") # pos. of 1st "," in a[i]
  a[i]=sprintf("%s%s",s,substr(s0,j)) # replace sorting col by shifted one
  dorig[a[i]]=s0 # to map sorting string to orig string: dorig[sorting-col]=orig ff
  #print i,s0," sorting col=",a[i] #dorig[a[i]]
}

ios=0; if(ltest)ios=2
print ios,n_indx > fsta
Ldiff=length(g_diff)

#
# Start Gnuplot input file creation
#
delete d
Lsort=1
if(Lsort)asort(a,d) # -> d[1:] is sorted
else for(i=1;i<=n_indx;i++){d[i]=a[i]}
for(i=1;i<=n_indx;i++){s=d[i]; d[i]=dorig[s]} # remap
#print "sorted array has size",n_indx
#for(i=1;i<=n_indx;i++)print "sorted:",i,d[i] #d[i]=dorig[s]} # remap
d[0]="all"
scol="# Data cols: 1:N; 2,3,4:Rx(x),Rx(y),Rx(z)"
# Check if subplot keys are set
# key set by user: "-k string0,string1,..." or disabled/unset: "-k 0"
n=split(g_key[0],a,",")
for(i=0;i<=nfile;i++)g_key[i]="" # init
if(length(a[1])){ # key set/unset by user
  if(n==1 && a[1]=="0")g_key[0]="" # force no key (if user wants key="0" use "-k 0,1" even if nfile=0)
  else for(j=1;j<=n;j++)g_key[j-1]=a[j] # key set by user
}else{ # option "-k" was not used: apply default key = filename
  # only set key if >1 input file (nfile>=1)
  if(Ldiff)g_key[0]="" # -d* (difference) option active
  else if(nfile)for(i=0;i<=nfile;i++)g_key[i]=FILENAMES[i]
}

# Reporting for each file
for(i=0;i<=nfile;i++){
  j=5+2*i # 5,7,9,...
  s=sprintf("# Data input file#%i: %s",i+1,FILENAMES[i])
  if(!i)s=sprintf("%s (reference data)",s)
  print substr(s,3); print s >> fgnu; print s >> fdat
  scol=sprintf("%s; %i,%i:File#%i-Re,Im",scol,j,j+1,i+1)
  #print "key",i":",g_key[i]
  # Reporting of data min,max for each data subset
  if(verbose){
    for(indx=0;indx<=n_indx;indx++){ # loop over all plot indices: 0="all"
      # indx=-1: min,max over all data subsets for file# i
      lc=1; ff=d[indx] # plot-index ID
      if(verbose<2 && indx)lc=0 # no printout of data-subset min,max
      if(lc){
        if(indx)printf("Data-subset#%i:\n",indx) # todo period,Tx,etc
        data_minmax(ff,-1,i) # printout of min,max,|min|,|max| data
      } #lc
    } #indx
  } # verbose reporting
  # printout of min,max,|min|,|max| data over all data files
  if(verbose && i && i==nfile){print "All data input files (global min,max):"
	  data_minmax("all",-1,nfile+1)} 
}

# Write Gnuplot script header
printf ("\n#\n# Begin of plot commands generated by %s (system: %s)\n#\n",myname,sys_name) >> fgnu
# set output terminal (postscript)
# set terminal postscript portrait color background col_bg solid font "Courier" 13
s=g_color[0]; if(!length(s))s=strquote("white")
printf("set terminal postscript portrait color background %s solid font %s %i\n",s,strquote(g_font[1]),g_font[2]) >> fgnu
s=sprintf("%s.ps",froot); printf("set output %s\n",strquote(s)) >> fgnu

# Plotdata error columns
j=4+2*(nfile+1); scol=sprintf("%s; %i,%i:Re-error_dx-,dx+",scol,j+1,j+2)
j+=2; scol=sprintf("%s; %i,%i:Im-error_dx-,dx+",scol,j+1,j+2)
scol=sprintf("%s; %i:Line-ID",scol,j+3)
# Additional (optional user-defined) Gnuplot header
print "# BEGIN Additional (optional user-defined) Gnuplot header" >> fgnu
if(length(g_userheader))while(getline < g_userheader)print $0 >> fgnu
else print "# N/A" >> fgnu
print "#  END  Additional (optional user-defined) Gnuplot header" >> fgnu
printf("\n# Plot data file:\nd=\"%s\"\n\n",fdat) >> fgnu

# Write data file header
printf("# Nindex=%i, %s-datatype=%s\n",n_indx,sdatatype[datatype],sdatatype[0]) >> fdat
print scol >> fdat
if(lprogress){s="Processing plot index#"; print_progress(s,0,fgnu)}
#
# Option -d* = data-difference: calc. difference between data set#1 and set#2
#
if(Ldiff){ # -d* option active
  g_log=0 # default: no log for difference plots
  print "Plotting data differences"
  if(nfile){ # only for >1 input files
    if(g_diff ~ /dr/){s="{/Symbol D}(rel)"; lc=2} # rel. diff.
    else if(g_diff ~ /d%/ || g_diff ~ /dp/){s="{/Symbol D}(%)"; lc=3} # %-diff.
    else{s="{/Symbol D}"; lc=1} # simple diff.
    labs=0; if(g_diff ~ /a/){
	    labs=1 # abs. diff.
	    s=sprintf("|%s|",s)}
    g_diff_label=s # addendum for y-axis labels
    # calc. data difference for all plot indices
    for(indx=1;indx<=n_indx;indx++){ # loop over all plot indices
      ff=d[indx] # plot-index ID, d=sorted array
      ndata=NPLOTDATA[ff]
      for(i=1;i<=2;i++){ # i=1: Re, i=2: Im
        for(n=1;n<=ndata;n++)dif[n]=dat[ff,n,0,i]-dat[ff,n,1,i] # (simple) diff. (file1-file2)
        if(lc>=2){ # rel. diff.
	  x=1; if(lc==3)x=100 # rel. diff. in %
          for(n=1;n<=ndata;n++)dif[n]=dif[n]/dat[ff,n,0,i]*x # rel. diff.
        } # lc=2,3 
        if(labs)for(n=1;n<=ndata;n++)dif[n]=abs(dif[n]) # abs. diff.
        for(n=1;n<=ndata;n++)dat[ff,n,0,i]=dif[n] # final diff. values
      } # i=1,2
      # create new plotdata lines
      for(n=1;n<=ndata;n++){ # put diff-data back into PLOTDATA
        i=split(PLOTDATA[ff,n],a) # a[1:4] = Rx-cols
        s=sprintf("%s %s %s %s ",a[1],a[2],a[3],a[4]) # N,X,Y,Z
        xr=dat[ff,n,0,1]; xi=dat[ff,n,0,2] # diff(Re-data),diff(Im-data)
	# Update min,max
        data_minmax(ff,n,0) # update data min,max arrays for this data set (ff)
        data_minmax("all",n,0) # update global data min,max (over all data sets of file# 0)
	a[1]=sprintf("%.5e",xr); a[2]=sprintf("%.5e",xi)
        if(g_log){ # log y-axis: check for 0-value, to avoid log(0)
	  if(abs(xr)==0)a[1]="nan"
	  if(abs(xi)==0)a[2]="nan" }
        # final PLOTDATA-line compilation
	PLOTDATA[ff,n]=sprintf("%s  %s %s  %s",s,a[1],a[2],a[i]) # a[i]=Line-ID
      } #n
    } # indx
    # Report min,max diff values
    for(indx=0;indx<=n_indx;indx++){ # loop over all plot indices, indx=0: d["all"]
      ff=d[indx] # plot-index ID, d=sorted array
      lc=1; if(verbose<2 && indx)lc=0 # no printout of data-subset min,max
      if(lc){
        if(indx)printf("Data-subset#%i:\n",indx) # todo period,Tx,etc
        data_minmax(ff,-1,0) } } # global min,max over all data sets
    nfile=0 # reset to 1 input file (now containing diff. data)
  }else printf("WARNING: Data differences need two input data sets (ignoring option -%s)\n",g_diff)
} # Ldiff/g_diff
#
# set y_range to global min,max (over all files), in case user set this
#
for(j=1;j<=2;j++){ # j=1: xrange, j=2: yrange
  # xrange=y1,y2:p or y1,y2,y3,y4:p or y1,y2,y3,y4:p1,p2
  if(j==1)ff=g_xrange[0]
  else ff=g_yrange[0]
  if(length(ff)){ # set xrange,yrange of plot
    n=split(ff,a,":"); s=a[1]
    #for(i=1;i<=4;i++)g_range[j]="" # init
    # Default range values = min,max Re,Im values
    i=0; if(g_log)i=4 # global min,max (1-4), or global |min|,|max| (5-8) over all files
    x1=dat["all",0,nfile+1,i+1]; x2=dat["all",0,nfile+1,i+2] # Re min,max
    x3=dat["all",0,nfile+1,i+3]; x4=dat["all",0,nfile+1,i+4] # Im min,max
    n=split(s,a,",") # y1,y2, y3,y4
    switch(n){ # case 0: only axis stretching
    case 1: # same min: Re: x1,data-max  Im: x1,data-max 
      # option "-yr e": x1,x2=x3,x4=global min,max
      if(a[1]!="e"){x1=a[1]+0; x3=x1}
      else{xr=min(x1,x3);xi=max(x2,x4); x1=xr;x2=xi;x3=xr;x4=xi}
      break
    case 2: # same min,max: Re: x1,x2  Im: x1,x2
      # option "-yr e,e": x1,x2=x3,x4=global min,max
      if(a[1]!="e" && a[2]!="e"){
        x1=a[1]+0; x2=a[2]+0; x3=x1; x4=x2} # x1,x2
      break
    case 3: # individual min, same max: Re: x1,x2  Im: x3,x2
      x1=a[1]+0; x2=a[2]+0; x3=a[3]+0; x4=x2 # x1,x2, x3
      break
    case 4: # individual min,max: Re: x1,x2  Im: x3,x4
      x1=a[1]+0; x2=a[2]+0; x3=a[3]+0; x4=a[4]+0 # x1,x2, x3,x4
      break
    } # switch
    # percent
    n=split(ff,a,":")
    fac[1]=0; fac[2]=0
    # fac[1]: Re-buffer-factor, fac[2]: Im-buffer-factor
    if(n>1){ # %-axis buffer given: y1-%,y2+%
      s=a[2]; n=split(s,a,",") # -> fac1,[fac2]
      for(i=1;i<=n;i++)fac[i]=(a[i]+0)/100 # factor = percent/100
      if(n==1)fac[2]=fac[1]
    }
    x1=x1*(1-fac[1]); x2=x2*(1+fac[1]) # Re-d,Re+d
    x3=x3*(1-fac[2]); x4=x4*(1+fac[2]) # Im-d,Im+d
    # g_xrange[1]: Re-xrange; g_xrange[2]: Im-xrange
    # g_yrange[1]: Re-yrange; g_yrange[2]: Im-yrange
    if(j==1){ # set xrange
      g_xrange[1]=sprintf("set xrange[%e:%e] # Re-data",x1,x2) # Re min,max
      g_xrange[2]=sprintf("set xrange[%e:%e] # Im-data",x3,x4) # Im min,max
    }else{ # set yrange
      g_yrange[1]=sprintf("set yrange[%e:%e] # Re-data",x1,x2) # Re min,max
      g_yrange[2]=sprintf("set yrange[%e:%e] # Im-data",x3,x4) # Im min,max
    }
  } # len(s)
} # j=1: xrange, j=2: yrange
# log/lin axis settings
if(g_log)print "set log y" >> fgnu

#
# One subplot for each plot index
#
for(indx=0;indx<n_indx;indx++){ # loop over all plot indices
  ff=d[indx+1] # plot-index ID, d is sorted ID array
  ndata=NPLOTDATA[ff]
  #print indx,ff
  split(ff,a,",")
  i=datatype+1 # datatype: 1: MT, 2: CSEM, period=datatype+1
  if(datatype==1)j=3 # MT: (sort-col,period,comp)
  else j=9 # CSEM: (sort-col,dip,per,azi,dip,tx,ty,tz,comp)
  # strings for period and comp = data component ("_"->"-" in comp)
  period=sprintf("T=%.4gsec (f=%.4gHz)",a[i],1/a[i]); comp=a[j] #; gsub(/_/,"-",comp)
  if(lprogress){
    s=sprintf("%i/%i: %s,Comp=%s",indx+1,n_indx,period,comp)
    print_progress(s,1,fgnu) # print s and backspace
  }
  # Index header (from here a can be recycled)
  s=sprintf("# **** Index=%i, %s, Component=%s, Ndata=%i ****",indx,period,comp,ndata)
  print s >> fdat; print s >> fgnu
  # Write data to plotdata file (*.dat)
  for(n=1;n<=ndata;n++)print PLOTDATA[ff,n] >> fdat
  if(indx<n_indx-1)printf("\n\n") >> fdat
  s_indx=print_num_fill0(indx+1,n_indx) # "001","002",...
  # Gnuplot script
  # Separate output file for each subplot
  if(length(g_sepoutputfile)){
    s=sprintf("%s.%s",s_indx,g_sepoutputfile)
    printf("set output %s\n",strquote(s)) >> fgnu
    print s >> flst # append to list of subplot files
  }
  print g_multiplot >> fgnu # set multiplot; set size ...
  # Each data input file corresponds to one (Re,Im) column-pair
  #
  # 1) Real-data subplot
  #
  s=sprintf("Tx#%s: %s, Rx-comp=%s",s_indx,period,comp)
  if(g_xyz_profile)s=sprintf("%s, Rx(%s)=%gm",s,toupper(s_xyz[g_xyz_profile]),a[1])
  printf("set title %s noenhanced\n",strquote(s)) >> fgnu
  if(length(g_xrange[1]))print g_xrange[1] >> fgnu # set x-range of Re-subplot
  if(length(g_yrange[1]))print g_yrange[1] >> fgnu # set y-range of Re-subplot
  s=sprintf("%s(Real) %s",comp,data_unit)
  printf "unset xlabel" >> fgnu
  if(Ldiff){a[1]="enhanced"; s=sprintf("%s: %s",g_diff_label,strunderscore(s,sys_name))} # maintain "_"
  else a[1]="noenhanced"
  printf("; set ylabel %s %s\n",strquote(s),a[1]) >> fgnu
  plotline(indx,1,"RE")
  #
  # 2) Imag-data subplot
  #
  print "unset title" >> fgnu
  if(length(g_xrange[2]))print g_xrange[2] >> fgnu # set x-range of Im-subplot
  if(length(g_yrange[2]))print g_yrange[2] >> fgnu # set y-range of Im-subplot
  printf("set xlabel %s noenhanced\n",strquote(g_xyz_title[g_xyz])) >> fgnu
  s=sprintf("%s(Imag) %s",comp,data_unit)
  if(Ldiff){a[1]="enhanced"; s=sprintf("%s: %s",g_diff_label,strunderscore(s,sys_name))} # maintain "_"
  else a[1]="noenhanced"
  printf("set ylabel %s %s\n",strquote(s),a[1]) >> fgnu
  plotline(indx,2,"IM")
  # If logo image present: insert here
  if(length(g_logo)){
    print "# Logo image" >> fgnu
    plotreset(0)
    printf("%s\nunset key; plot flogo binary filetype=png with rgbalpha\n",g_logo) >> fgnu
    #else printf("%s\nplot flogo binary filetype=jpg with rgbimage\n",g_logo) >> fgnu
    plotreset(1)
  }
  print "unset multiplot" >> fgnu
  #
  if(indx<n_indx-1)printf("\n") >> fgnu
}
if(lprogress)print_progress("done",2,fgnu) # finalize call
} # END

