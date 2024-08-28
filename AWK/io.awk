#
# General IO functions
#
# isheaderline: check if input line is header/comment/non-data line
function isheaderline(fld1,com, n,ncom,l,a){
ncom=split(com,a,",") # a is array with comment chars
l=0
for(n=1;n<=ncom;n++)if(index(fld1,a[n])==1)l=1
return l} # isheaderline

function readline(nl, l,n,c,buf){
# read nl number of input lines and save in global buffer ALINE
# Global buffers: NLINE, ALINE
NLINE=0
# nl=1: read to 1st non-comment line and return
# nl=0: read all non-comment lines until 1st blank line
l=length($0)
while(l){
    if(getline){
      if(!length($0))l=0 # empty line, return
      else{ # non-empty line
        n=isheaderline($1,"#") # n=1 -> comment/header line
        if(!n)ALINE[++NLINE,0]=$0 # save non-comment line
      } #length
      if(nl>0 && nl==NLINE)l=0 # nl>0: return when NL lines are read
    }else l=0 # getline
} #while(l)
for(l=1;l<=NLINE;l++){
  n=split(ALINE[l,0],buf) # save to array of fields
  for(c=1;c<=n;c++)ALINE[l,c]=buf[c]
}
} # function readline

# Function readline_files: read 1 line from NFILE input files
function readline_files(lgetl,nfile, i,j,n,a){
# Global buffers: FILENAMES, DATA, NDATA
  for(i=0;i<=nfile;i++){
    if(i)getline < FILENAMES[i]
    else{ # input from FILENAME
      if(lgetl)getline # < FILENAME
      else $0=DATA[0,0] # $0 was saved in DATA[0,0] by calling prg
    }
    n=split($0,a); a[0]=$0 # save all fields
    for(j=0;j<=n;j++)DATA[i,j]=a[j]
    NDATA[i]++ # count data lines for each file
  } # i
} # readfile


# function select_cols: select fields from input line
function cols_select_init(t,tname, nc,n,i,s,a,b,colname){
# Format t=COL1,VAL1,[VAL2];COL2,VAL1,[VAL2];COL3,...
# Format for num. comp.: COL,VAL,[t,TOL] (t,TOL=tol. for num. comp.)
# Format for number-range comp.: COL,VAL1,VAL2
# Format for string comp.:     COL,VAL,s
# Format for reg.-expr. comp.: COL,VAL,~
# tname=string of blank-separated data col. names
# tol=tolerance f. num. comp.
  nc=split(t,a,",") # no. of data columns to match
  t_dat[0,0]=nc # number of columns to compare
  if(length(tname))split(tname,colname)
  print "Input data columns to match:"
  for(i=1;i<=nc;i++){
    n=split(a[i],b,":") # (Col#,Value,[Value2]) Value2=number or "s"
    # t_dat[i:0-3]=(Type,Col#,Value,Value2)
    t_dat[i,0]=0 # Type=0
    t_dat[i,1]=b[1]+0 # Col#
    t_dat[i,2]=b[2] # Value
    t_dat[i,3]=1e-6 # Default tol. for num. comp.
    s=sprintf("Val=%s, numeric comparison with tol=%g",b[2],t_dat[i,3])
    if(n>=3){
      if(b[3]=="s"){
	t_dat[i,0]=1 # string
        s=sprintf("Val=\"%s\", string comparison",b[2])
      }else if(b[3]=="~"){ # reg.-expr. comparison
	t_dat[i,0]=3 # reg.expr.
        s=sprintf("Val=\"%s\", reg.-expr. comparison",b[2])
      }else if(b[3]=="t"){ # set num. tol. for number comp.
        t_dat[i,3]=b[4]+0 # New tol. for num. comp.
        s=sprintf("Val=%s, numeric comparison with tol=%g",b[2],t_dat[i,3])
      }else{ # assume b[3] is number
	t_dat[i,0]=2 # number-range comp.
        t_dat[i,3]=b[3] # Value2
        s=sprintf("Values [a,b]=[%s,%s], number range",b[2],b[3])
      }
    }
    # report Col#,Value
    if(length(tname)){
      n=t_dat[i,1] # col#
      b[1]=sprintf(" =%14s",colname[n])
    }else b[1]=""
    printf("Col#%2i%s: %s\n",t_dat[i,1],b[1],s)
  } # i
} # function select_cols

# function compare_cols: column selection
function cols_select( ncol,lc,i,ityp,icol,xcol,x,x2){
# a[] is array with current line fields
# tol=tolerance f. num. comp.
ncol=t_dat[0,0] # number of columns to compare
lc=0
for(i=1;i<=ncol;i++){
  ityp=t_dat[i,0] # Type=0
  icol=t_dat[i,1] # Col#
  xcol=a[icol]+0 # num. val. of actual input column
  if(ityp==0){ # numerical comp.
    x=t_dat[i,2]+0 # Value
    x2=sqrt((x-xcol)*(x-xcol)) # difference
    if(x2<t_dat[i,3])lc++ # t_dat[i,3]=tol
  }else if(ityp==1){ # string comp.
    if(a[icol]==t_dat[i,2])lc++
  }else if(ityp==2){ # number range
    x =t_dat[i,2]+0 # Value
    x2=t_dat[i,3]+0 # Value2
    if(xcol>=x && xcol<=x2)lc++
  }else if(ityp==3){ # reg.-expr. comp.
    #match(s,r[,a]) Return pos. in s where reg. expr r occurs, or 0 if r not present
    if(match(a[icol],t_dat[i,2]))lc++ #s=a[icol]
  }else{ # number range
  }
} #i
i=0; if(lc==ncol)i=1 # all columns match
return i} #function compare_cols

#
# Print functions print_*
#
# print "emtools" welcome
function print_welcome(t, s,i,l){
print "hello"
s=sprintf("|___E_M_T_O_O_L_S_-%s___|",t)
l=length(s)
for(i=1;i<=l;i++)printf("_")
printf("\n%s\n",s)
for(i=1;i<=l;i++)printf("_")
printf("\n")}

# print number and fill with 0s.
function print_num_fill0(n,nmax, s){
s=sprintf("%i",nmax); l=length(s)
if(l==1 || l>4)s=sprintf("%i",n)
else if(l==2)s=sprintf("%2i",n)
else if(l==3)s=sprintf("%3i",n)
else if(l==4)s=sprintf("%4i",n)
gsub(/ /,"0",s)
return s} # print_numfill0

#
# String functions str*
#
function strquote(str, sq,q){
# put " before and after string str
q="\""
sq=sprintf("%s%s%s",q,str,q)
return sq}

function strunderscore(str,sys, s,q,c){
# for gnuplot: also changes underscore to "\\\\_"
q="\\"
if(sys~/cygwin/)c=sprintf("%s%s%s%s_",q,q,q,q) # on CygWin
else c=sprintf("%s%s%s_",q,q,q) # on CentOS Linux
s=str # new string
gsub(/_/,c,s)
return s}

#
# String functions for gnuplot: str_gnup_*
#
function str_gnuplot(iin,n, i,q,s){
s=""
if(iin==1){q="$"; s=sprintf("abs(%s%i)",q,n)} # abs($n)
else if(iin==2)for(i=1;i<=n;i++)s=sprintf("%s\\b",s) # backspace string
return s}
