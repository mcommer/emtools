# search config. file .emtools: find a string ID in $1 and return $2
# FILENAME = .emtools config. file
{ # MAIN
if(NR==1){
  out=""
  n=split(args,a,":")
  for(i=1;i<=n;i++)gsub(/ /,"",a[i])
  ID=sprintf("%s:",a[1]) # string to match
  VAR=a[2] # variable to set
}
i=index($1,"#")
#print "fconfig,line=",$0,"comment?",i
if(!i){ # not a comment line
    if(index($1,ID)){split($0,a,":");out=a[2];gsub(/ /,"",out)}
}
} # MAIN
END{
i=length(out) # >0: found, =0: not found
if(i)printf("set ios=1 && set %s=%s",VAR,out)
else printf("set ios=0") # not found
} # END

