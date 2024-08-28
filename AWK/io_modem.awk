#
# ModEM-specific IO functions
# Developed using: GNU Awk 5.2.2, API 3.2, PMA Avon 8-g1, (GNU MPFR 4.2.1, GNU MP 6.3.0)
# Last change: Fri Sep  8 17:31:52 -03 2023

# function modem_get_datatype: return datatype (CSEM or MT)
function modem_get_datatype(fld, i,j,d,comp,fldu){
# specify data types and components acc. to 3D_MT/DICT/dataTypes.f90
# Global return value: DATyyATYPE
# MT data type groups
d[1]="Full_Impedance"; d[2]="Off_Diagonal_Impedance"
d[3]="Full_Vertical_Components"; d[4]="Full_Interstation_TF"
d[5]="Off_Diagonal_Rho_Phase"; d[6]="Phase_Tensor"
# MT data components according to type
comp[1]="ZXX,ZXY,ZYX,ZYY"
comp[2]="ZXY,ZYX"
comp[3]="TX,TY"
comp[4]="MXX,MXY,MYX,MYY"
comp[5]="RHOXY,PHSXY,RHOYX,PHSYX"
comp[6]="PTXX,PTXY,PTYX,PTYY"
# CSEM data type groups
d[7]="Ex_Field"
d[8]="Ey_Field"
d[9]="Ez_Field"
d[10]="Bx_Field"
d[11]="By_Field"
d[12]="Bz_Field"
d[13]="Exy_Field"
d[14]="Bxy_Field"
d[15]="Exy_Ampli_Phase"
d[16]="Bxy_Ampli_Phase"
d[17]="Bz_Ampli_Phase"
d[18]="Full_Impedance_wAzimuth"
# CSEM data components accord. to type
for(i=7;i<=length(d);i++)comp[i]=d[i] # for these types: comp=type
j=0
fldu=toupper(fld)
for(i=1;i<=length(d);i++)if(fldu ~ toupper(d[i]))j=i
if(!j){
  print "WARNING: modem_get_datatype: unknown data type",fld
  a[1]=fld; a[2]=fld
  return 1}
# j<=6: MT return type, j>6: CSEM return type
if(j<=6){i=1; a[1]=comp[j]} # return MT comp. list for this data type group
else{i=2; a[1]=d[j]} # CSEM comp = group name
a[2]=d[j] # return data type group name
return i # MT/CSEM return type
# a[1]: comp. or list of comp.
# a[2]: data type group name TODO
}

function modem_uniqtxrx(type, n){
# array a contains data input line
if(type==1){ # MT
  sTx=sprintf(",%s",a[1]) # uniq. MT-freq.
  sRx=sprintf(",%s,%s,%s",a[5],a[6],a[7])  # uniq. x,y,z stn-pos
}else{ # CSEM
  # Unique Tx                            dip  per  azi  dip  tx   ty   tz   comp
  sTx=sprintf(",%s,%s,%s,%s,%s,%s,%s,%s",a[1],a[2],a[4],a[5],a[6],a[7],a[8],a[13])
  # Unique Rx             rx    ry    rz
  sRx=sprintf(",%s,%s,%s",a[10],a[11],a[12])
}
iTx=0; n=0
for(s in uniq_Tx){n++; if(s==sTx)iTx=uniq_Tx[s]}
if(!iTx){uniq_Tx[sTx]=++n; iTx=n; nTx=n} # add new Tx entry
iRx=0; n=0
for(s in uniq_Rx){n++; if(s==sRx)iRx=uniq_Rx[s]}
if(!iRx){uniq_Rx[sRx]=++n; iRx=n; nRx=n} # add new Rx entry
# now set: sTx,sRx,iTx,nTx,iRx,nRx
} #function modem_uniqtxrx

function modem_uniq(colname,scol, i,n){
# type: data type ID
# scol: actual column value (existing, or will be added to uniq. array)
i=0; n=0
switch (colname){
case "Code":
  for(s in uniq_col_Code){n++; if(s==scol)i=uniq_col_Code[s]}
  if(!i){uniq_col_Code[scol]=++n; i=n} # add new uniq. entry
  break
case "Component":
  for(s in uniq_col_Comp){n++; if(s==scol)i=uniq_col_Comp[s]}
  if(!i){uniq_col_Comp[scol]=++n; i=n} # add new uniq. entry
  break
} #switch
return i
} # modem_uniq

#
# Functions for emtools_data_plot
#
function modem_data_plot_dataline(datatype,nfile,pc,tol,werr, ff,s,i,j,n,icol,icol_err,id,x,nf,a,e,err,lerr,err_perc,err_lim){
# Global return values: NPLOTDADTA; PLOTDATA; DATA
# Before this function: call to readline_files: -> DATA
# datatype: 1=MT ,2=CSEM, Data col# for MT: 9,10; CSEM: 14,15
if(datatype==1){ # MT
# Period(s) Code GG_Lat GG_Lon X(m) Y(m) Z(m) Component Real Imag Error
# 1         2    3      4      5    6    7    8         9    10   11    
  ff=sprintf("%s,%s",DATA[0,1],DATA[0,8]) # period, component
  id=2 # ID col#
  icol=9 # Re-data col# MT
}else{ # CSEM
# 1:Tx_Dipole 2:Tx_Period(s) Tx_Moment(Am) Tx_Azi Tx_Dip 6:Tx_X(m) Tx_Y(x) Tx_Z(m) Code 10:X(m) Y(x) Z(m) Component 14:Real Imag, Error
  # Unique source:                     dipole    period    azi       dip       tx        ty        tz        comp
  ff=sprintf("%s,%s,%s,%s,%s,%s,%s,%s",DATA[0,1],DATA[0,2],DATA[0,4],DATA[0,5],DATA[0,6],DATA[0,7],DATA[0,8],DATA[0,13])
  id=9 # ID col#
  icol=14 # Re-data col# CSEM
}
i=datatype*5 # Rx(x) col#: MT: 5; CSEM: 10
# add sorting-column at beginning, if profile sorting active (pc=1,2,3)
if(pc)s=DATA[0,i-1+pc] # x,y,z data col
else s=DATA[0,datatype] # period (period col# = datatype)
ff=sprintf("%s,%s",s,ff) # (sorting col, source tuple)
NPLOTDATA[ff]++; n=NPLOTDATA[ff]
PLOTDATA[ff,n]=sprintf("%i %s %s %s ",n,DATA[0,i],DATA[0,i+1],DATA[0,i+2]) # n,x,y,z
# y-error bars: data errors are supposed to be in File# i=0
lerr=length(werr)
if(lerr){split(werr,a); err_perc=a[1]+0; err_lim[1]=a[2]+0; err_lim[2]=a[3]+0}
for(i=0;i<=nfile+1;i++){
  s=PLOTDATA[ff,n]
  if(i<=nfile){
    # test for tiny numbers, to avoid 0 for log y-axis
    if(tol>0){ # skip this check if tol=0
      x=DATA[i,icol]+0; if(abs(x)<tol)DATA[i,icol]="nan" #sprintf("%.2e",tol)
      x=DATA[i,icol+1]+0; if(abs(x)<tol)DATA[i,icol+1]="nan"} #tol
    PLOTDATA[ff,n]=sprintf("%s %s %s",s,DATA[i,icol],DATA[i,icol+1]) # append Data (Re,Im)
    if(lerr && i==0){ # with errorbars
      for(j=0; j<=1; j++){ # j=0: RE-error; j=1: IM-error
        icol_err=icol+j+2 # RE,IM-data-error-col = icol+2,icol+3
        if(DATA[0,icol+j]!="nan"){
          x=DATA[i,icol+j]+0; x=abs(x)
	  if(err_perc>0)e=x*err_perc/100 # error = percentage of data value
	  else if(err_perc<0)e=abs(err_perc) # error = const. abs. value
	  else{ # err_perc=0: error in column of data errors
            nf=split(DATA[0,0],a)
            if(icol_err>nf)icol_err=nf # set to data-err col.
            e=DATA[0,icol_err]+0} 
	  err[j,1]=e; err[j,2]=e # save RE/IM error value dx1,dx2
  	  # limit size of error bars
	  if(err_lim[1]>0){ # limit factor
  	    if(x-e < x/err_lim[1]){err[j,1]=x/err_lim[1]; err[j,2]=err[j,1]}  # [y1,y2]=[y-y/FAC,y+y/FAC]
          }else if(err_lim[2]>0){ # limit const.
  	    if(x-e < x-err_lim[2]){err[j,1]=err_lim[2]; err[j,2]=err[j,1]}}  # [y1,y2]=[y-CONST,y+CONST]
        }else{err[j,1]=0; err[j,2]=0} # nan
      }} # for j,lerr
  }else{ # nfile+1: append y-error data (if applicable) and Line-ID
    if(lerr){ # with yerrorbars: Re dx1,dx2=err[0,1:2], Im dx1,dx2=err[1,1:2]
      s=sprintf("%s  %.4e %.4e",s,err[0,1],err[0,2])  # append RE-Data-errors dx1,dx2, col# icol+2+1,2
      s=sprintf("%s  %.4e %.4e",s,err[1,1],err[1,2])} # append IM-Data-errors dx1,dx2, col# icol+4+1,2
    PLOTDATA[ff,n]=sprintf("%s  %s",s,DATA[0,id]) # at last: append Line-ID
  }
} # i=0,nfile
return ff
} # fucntion modem_data_plot_dataline
