struct quantum(T){
	T payload;
	bool collapsed=false;
	auto opCmp(U)(U a){
		if(collapsed){
			return payload.opcmp(a);}
		assert(false,"I hate how comparisions was implimented");
		return true; /*implied cast(int) for reasons*/
	}
	auto opEquals(U)(U a){
		if(collapsed){
			return payload.opequal(a);}
		else{
			return true;}
	}
	auto opAssign(U)(U a){
		collapsed=true;
		payload=a;
	}
}
unittest{
	quantum!int foo;
	//assert(foo>100);
	//assert(foo<1000);
	assert(foo==-99);
}

struct rangeof(T){
	quantum!T min;
	quantum!T max;
	auto opBinary(string op:"<<",U)(U a){
		max=a;
		return this;
	}
	auto opBinaryRight(string op:"<<",U)(U a){
		min=a;
		return this;
	}
	auto opEquals(U)(U a){
		return (a==min || a >= min) && (a==max ||a <= max);}
	auto opAssign(U)(U a){
		min=a;
		max=a;
		return this;
	}
}
unittest{
	rangeof!int foo= 1<<rangeof!int()<<3;
	assert(foo.min==1);
	assert(foo.max==3);
	assert(foo==2);
	assert(foo==1);
}
unittest{
	rangeof!int bar;
	assert(bar==99);
}
import std.meta;
import std.traits;
struct matcher(T,output){
	static foreach(def;definitions!T){
		mixin("rangeof!(def.T) "~def.name~";");}
	output payload;
	T passthru;
	bool wrong=true;
	auto opBinaryRight(string op:"|")(T a){
		if (a==this){
			wrong=false;}
		else{
			passthru=a;}
		return this;
	}
	auto opBinary(string op:"|")(typeof(this) a){
		if(wrong){
			passthru | a;}
		else{
			a.payload=payload;
			a.wrong=false;
		}
		return a;
	}
	auto opEquals(T a){
		static foreach(def;definitions!T){
			mixin("if("~def.name~"!=a."~def.name~"){return false;}");}
		return true;
	}
	auto getpayload(){
		import std.conv;
		assert(!wrong,"you fell off the end of the list of ranges, or formated wrong;n/"~
				"currentstate:"~payload.to!string~passthru.to!string);
		return payload;
	}
	alias getpayload this;
}
unittest{
	struct vec2{
		int x;
		int y;
	}
	int classify(vec2 foo){
		alias match=matcher!(vec2,int);
		enum x=rangeof!int();
		enum y=rangeof!int();
		assert(x==99);
		assert(y==0);
		return foo|
			match(10<<x<<30,20<<y<<40,1020)|
			match(50<<x<<70, 0<<y<<20,5000)|
			match(50<<x<<70,20<<y<<40,5020)|
			match(100<<x   ,    y<<99,10000)|
			match(     x=1 ,    y=1  ,42)|
			match(x,y,-1);
	}
	assert(classify(vec2(20,30))==1020);
	assert(classify(vec2(60,10))==5000);
	assert(classify(vec2(1,1  ))==  42);
	assert(classify(vec2(99,0 ))==-1);
	assert(classify(vec2(100,99))==10000);
	assert(classify(vec2(60,21))==5020);
	assert(classify(vec2(100,101))==-1);
}
mixin template rangematchsetup(input,output){
	alias pattern=matcher!(input,output);
	static foreach(def;definitions!input){
		mixin("enum "~def.name~"=rangeof!(def.T)();");
	}
}

int opcmp(T,U)(T a,U b){
	if(a<b){return -1;}
	else if(a>b){return 1;}
	return 0;
}
bool opequal(T,U)(T a,U b){
	return a.opcmp(b)==0;}

template uglyzip(elems...){
	static if (elems.length==0){alias uglyzip = AliasSeq!();}
	static if (elems.length==1){ static assert(false);}
	static if (elems.length>1){ 
		alias uglyzip = AliasSeq!(Alias!(elems[0]),Alias!(elems[$-1]),uglyzip!(elems[1..$-1]));}
}
static assert(uglyzip!(AliasSeq!(1,2,3,4,5,6,7,8,9,10))==AliasSeq!(
		Alias!(1),Alias!(10),Alias!(2),Alias!(9),Alias!(3),
		Alias!(8),Alias!(4),Alias!(7),Alias!(5),Alias!(6)));		
template definitions(T){
	template foo(T){ alias foo=FieldNameTuple!T;}
			//AliasSeq!(__traits(derivedMembers,T));}
	template bar(T){ alias bar=Fields!T;}
			//AliasSeq!(typeof(T.tupleof));}
	unittest{
		struct point{int x; int y; enum hi;}
		alias foo_ = foo!(point);
		static assert(foo_ == AliasSeq!("x","y"));
		alias bar_ = bar!(point);
		static assert(is(bar_==AliasSeq!(int,int)));
	}
	template zip(T){ alias zip = uglyzip!(bar!(T),Reverse!(foo!(T)));}
	unittest{
		struct vomit{int x; float y; bool z;}
		struct vomit_{bool x; float y; int z;}
		//static assert(zip!(vomit) == uglyzip!(foo!vomit_,bar!vomit_));
	}
	template cleanup(elems...){
		template def(T_,string name_){ 
			alias T= T_; alias name= name_;
		}
		static if(elems.length==0){alias cleanup = AliasSeq!();}
		static if(elems.length==1){static assert(false);}
		static if(elems.length>1){
			alias cleanup= AliasSeq!(def!(elems[0],elems[1]),cleanup!(elems[2..$]));}}
	unittest{
		alias foo=cleanup!(AliasSeq!(int,"x",float,"y",bool,"z"));
		static assert(foo[0].name=="x");
		static assert(foo[1].name=="y");
		static assert(foo[2].name=="z");
		static assert(is(foo[0].T==int));
		static assert(is(foo[1].T==float));
		static assert(is(foo[2].T==bool));
	}
	alias definitions= cleanup!(zip!(T));
}