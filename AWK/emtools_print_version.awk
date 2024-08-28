BEGIN{
    email="micha@on.br"
}
{
t=$1 # myname
h[0]=sprintf("E_M_T_O_O_L_S_-_%s",t)
getline < dir # get version/date-line
h[1]=$0 #"Version 2023.11, last modified: Thu Nov 16 20:29:32 -03 2023"
h[2]=sprintf("Written by Michael Commer, Comments/Questions/Suggestions: %s",email)
# print out
lmax=0
for(i=1;i<3;i++){l=length(h[i]); if(l>lmax)lmax=l}
r=(lmax-(length(h[0])-1))/2
j=int(r)
s="|"; for(i=1;i<=j;i++)s=sprintf("%s_",s)
s=sprintf("%s%s",s,h[0])
for(i=1;i<=j;i++)s=sprintf("%s_",s)
s=sprintf("%s|",s)
l=length(s)
for(i=1;i<=l;i++)printf("_"); printf("\n")
print s
# print version-line and author-line
for(i=1;i<3;i++)print h[i]
printf("\n")
exit
}
