unittest{
  import rangematch;
	struct vec2{
		int x;
		int y;
	}
	int classify(vec2 foo){
		mixin rangematchsetup!(vec2,int);
		return foo|
      match(    x=42 ,    y    , 100)|
			match(10<<x<<30,20<<y<<40,1020)|
			match(50<<x<<70, 0<<y<<20,5000)|
			match(50<<x<<70,20<<y<<40,5020)|
			match(100<<x   ,    y<<99,1000)|
			match(     x=1 ,    y=1  ,  42)|
			match(x,y,-1);
	}
  assert(classify(vec2(42,10))== 100);
  assert(classify(vec2(42,20))== 100);
  assert(classify(vec2(42,30))== 100);
	assert(classify(vec2(20,30))==1020);
	assert(classify(vec2(60,10))==5000);
	assert(classify(vec2(1,1  ))==  42);
	assert(classify(vec2(99,0 ))==  -1);
	assert(classify(vec2(100,99))==1000);
	assert(classify(vec2(60,21))==5020);
	assert(classify(vec2(100,101))==-1);
}