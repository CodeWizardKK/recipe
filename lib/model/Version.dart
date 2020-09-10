class Version{
//  double a;
  double s;
  double q;
  Version({this.s, this.q});

  //jsonへ変換
  Map<String,dynamic> toMap(){
    var map = <String,dynamic>{
      'id':1,
      's':s,
      'q':q,
    };
    return map;
  }

  Version.fromMap(Map<String,dynamic> map){
//    a = map['a'].toDouble();
    s = map['s'].toDouble();
    q = map['q'].toDouble();
  }
}