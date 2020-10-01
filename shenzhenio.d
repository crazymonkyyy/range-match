unittest{

struct vec2{
  int x;
  int y;
}
int fluxstate(vec2 postion){
  import rangematch;
  mixin rangematchsetup!(vec2,int);
  return postion |
    pattern(40<<x<<59,40<<y<<79,50)|
    pattern(59<<x<<79,40<<y<<79,80)|
    pattern(20<<x<<59,    y    , 0)|
    pattern(    x    ,    y    ,30);
}
assert(fluxstate(vec2(79,40))==80);
assert(fluxstate(vec2(80,40))==30);
assert(fluxstate(vec2(40,40))==50);
assert(fluxstate(vec2(50,30))== 0);
}