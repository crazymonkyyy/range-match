unittest{

enum suit{heart,clubs,diamond,spades} with(suit){
struct card{
  int value;
  suit suit_;
}
alias hand=card[5];
enum handclass{royalflush,straightflush,fourofakind,fullhouse,flush,straight,threeofakind,
    twopair,onepair,high}
handclass classifyhand(hand a){
  import std.algorithm;import std.array; import std.range;
  auto groupsizes(T)(T[] a){
    return cast(int[])
    a.sort!("a<b").group
    .map!"a[1]".array
    .sort!("a>b").array;
  }
  assert(groupsizes([1,2,2,2,1])==[3,2]);
  auto isstaight(int[] a){
    return a==iota(a[0],a[0]+5).array;
  }
  assert(isstaight([9,10,11,12,13]));
  assert(! isstaight([8,10,11,12,13]));
  struct processeddata{
    int[] suitgroups;
    int[] valuegroups;
    bool royal;
    bool staight;
    this(card[] hand_){
      suitgroups =groupsizes(hand_.map!"a.suit_".array);
      valuegroups=groupsizes(hand_.map!"a.value".array);
      royal= ! hand_.map!"a.value".array.any!"a>=2 && a<=9";
      staight=isstaight(hand_.map!"a.value".array.sort.array)||
          isstaight(hand_.map!"a.value".map!"a==1? 14:a".array.sort.array);
    }
  }
  import rangematch;
  mixin rangematchsetup!(processeddata,handclass);
  with(handclass){
    return processeddata(a)|
      pattern(suitgroups=[5],valuegroups          ,royal=true,staight=true,royalflush   )|
      pattern(suitgroups=[5],valuegroups          ,royal     ,staight=true,straightflush)|
      pattern(suitgroups    ,valuegroups=[4,1]    ,royal     ,staight     ,fourofakind  )|
      pattern(suitgroups    ,valuegroups=[3,2]    ,royal     ,staight     ,fullhouse    )|
      pattern(suitgroups=[5],valuegroups          ,royal     ,staight     ,flush        )|
      pattern(suitgroups    ,valuegroups          ,royal     ,staight=true,straight     )|
      pattern(suitgroups    ,valuegroups=[3,1,1]  ,royal     ,staight     ,threeofakind )|
      pattern(suitgroups    ,valuegroups=[2,2,1]  ,royal     ,staight     ,twopair      )|
      pattern(suitgroups    ,valuegroups=[2,1,1,1],royal     ,staight     ,onepair      )|
      pattern(suitgroups    ,valuegroups          ,royal     ,staight     ,high         );
  }
}
//card(13,diamond)
//card(  ,       )
//enum suit{heart,clubs,diamond,spades}
import std.stdio;
with(handclass){
assert(classifyhand([card(10,heart  ),card(11,heart  ),card(12,heart  ),card(13,heart  ),card( 1,heart  )])==royalflush   );
assert(classifyhand([card( 6,heart  ),card( 7,heart  ),card( 8,heart  ),card( 9,heart  ),card(10,heart  )])==straightflush);
assert(classifyhand([card( 7,heart  ),card( 7,diamond),card( 7,clubs  ),card( 7,spades ),card( 9,heart  )])==fourofakind  );
assert(classifyhand([card( 2,diamond),card( 2,clubs  ),card( 2,heart  ),card( 8,clubs  ),card( 8,heart  )])==fullhouse    );
assert(classifyhand([card( 3,heart  ),card( 7,heart  ),card( 9,heart  ),card(11,heart  ),card(13,heart  )])==flush        );
assert(classifyhand([card( 6,heart  ),card( 7,clubs  ),card( 8,heart  ),card( 9,diamond),card(10,clubs  )])==straight     );
assert(classifyhand([card( 2,diamond),card( 2,clubs  ),card( 2,heart  ),card(13,clubs  ),card( 8,heart  )])==threeofakind );
assert(classifyhand([card(10,diamond),card(10,diamond),card( 5,heart  ),card( 5,heart  ),card( 3,diamond)])==twopair      );
assert(classifyhand([card( 7,diamond),card( 7,diamond),card( 5,heart  ),card( 6,clubs  ),card( 3,diamond)])==onepair      );
assert(classifyhand([card( 7,diamond),card( 8,clubs  ),card( 5,heart  ),card(11,clubs  ),card(13,heart  )])==high         );
}}}