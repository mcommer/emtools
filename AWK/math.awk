#
# Math. functions
#
function abs(x, y){
# return abs(x), usage: x=abs(value)
if(x<0.0)y=-x
else y=x
return y}

function min(x1,x2, y){
y=x1
if(x2<x1)y=x2
return y}

function max(x1,x2, y){
y=x1
if(x2>x1)y=x2
return y}

function floor(x, n){
eps=1e-3
n=int(x)
if(x<0)n--
if(x-n>1-eps)n++
return n}

function ceil(x, n){
eps=1e-3
n=int(x)
if(x>0)n++
if(n-x>1-eps)n--
return n}

function log10(x, y){
y=log(x)/log(10)
return y}

