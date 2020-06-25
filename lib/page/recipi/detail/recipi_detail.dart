import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/store/display_state.dart';
import 'package:recipe_app/services/recipi/recipi_item.dart' as recipiItemRepo;
import 'package:recipe_app/services/recipi/recipi_list.dart' as recipiListRepo;

class RecipiDetail extends StatefulWidget{
  _RecipiDetailState createState() => _RecipiDetailState();
}

class _RecipiDetailState extends State<RecipiDetail>{

  bool _isLoading = true;    //通信中:true(円形のグルグルのやつ)
  String _errorMessage = ''; //await関連のエラーメッセージ
  var _selectedItem = {}; //リストから選択されたレコード
  int _selectedImage = 0;
  // ページコントローラ
  final PageController controller = PageController(viewportFraction: 0.8);
  // ページインデックス
  int currentPage = 0;
  //レコード毎の画像リスト
  var _data;


  @override
  void initState() {
   //
   super.initState();
   //該当レコードを取得
   this.getItem();
   //ページ遷移を監視
   this.pageController();
  }

  //不要になる  =====> ここから
  //画像を取得
  Future<void> getImage() async{
    var images;
    try{
      //画像を取得
      images = await recipiListRepo.get();
    }catch(e){
      //エラー処理
      print('Error: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
        //ここでエラー画面へ遷移する処理を追加(state=9にセットする)
//        Provider.of<Display>(context, listen: false).setState(9);
      });
    }
    setState(() {
      _data = images['data'];
    });
  }

  //該当レコードの取得
  Future<void> getItem() async{
    var option = {};
    var result;

    //画像を取得 ===> 不要になる
    this.getImage();

    //取得する為のIDを取得
    option['id'] = Provider.of<Display>(context, listen: false).getId();

    try{
      //該当レコード取得処理の呼び出し
      result = await recipiItemRepo.get(option);
    }catch(e){
      //エラー処理
      print('Error: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
        //ここでエラー画面へ遷移する処理を追加(state=9にセットする)
//        Provider.of<Display>(context, listen: false).setState(9);
      });
    }

    //該当レコードをstoreに格納
    Provider.of<Display>(context, listen: false).setSelectItem(result['data']);
    setState(() {
//      _selectedItem = result;
      _isLoading = false;
    });
  }

  // ページコントローラのページ遷移を監視しページ数を丸める
  void pageController(){
    controller.addListener(() {
      int next = controller.page.round();
//      print('currentPage:${currentPage}');
//      print('next:${next}');
      if (currentPage != next) {
        setState(() {
          currentPage = next;
        });
      }
    });
  }

  //レシピリストへ戻るボタン押下時処理
  void onList(){
    Provider.of<Display>(context, listen: false).setState(-1);
  }

  //削除処理
  void onDelete(){
   //該当レコード削除処理(IDをpushする)

   //レシピリストへ戻る
   this.onList();
  }

  //レシピの編集ボタン押下時処理
  void onEdit(){
//    print('selectId[${id}]');
//    //idをset
//    Provider.of<Display>(context, listen: false).setId(id);
//    //新規投稿以外の場合
//    if(id != -1){
//      //詳細画面へ遷移
//      Provider.of<Display>(context, listen: false).setState(2);
//    }else{
      //編集画面へ遷移
      Provider.of<Display>(context, listen: false).setDetailImages(_data);
      Provider.of<Display>(context, listen: false).setState(1);
//    }
  }

  //削除アイコン押下時処理
  Future<void> _showDeleteDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('確認'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('削除してもよろしいですか？'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                onDelete();
              },
            ),
          ],
        );
      },
    );
  }

  //ペジネーション作成し、listにして返す
  Row _createPagination(){
    List<Widget> page = new List<Widget>();
    for(var i = 0 ;i<_data.length; i++){
      if(currentPage == i){
        page.add(Container(margin: EdgeInsets.all(5),child: Icon(Icons.brightness_1,size: 5,color: Colors.grey,)));
      }else{
        page.add(Container(margin: EdgeInsets.all(5),child: Icon(Icons.panorama_fish_eye,size: 5,color: Colors.grey,)));
      }
    }
    print('page:${page}');
    return
      Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: page
      );
  }
  //アニメーションカード生成
  AnimatedContainer _createCardAnimate(Map<String,Object> images, bool active) {

    // アクティブと非アクティブのアニメーション設定値
//    final double top = active ? 100 : 200;
//    final double side = active ? 0 : 40;

    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOutQuint,
      margin: EdgeInsets.only(top: 0, bottom: 0, right: 30, left: 30),
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.fitWidth,
//          fit: BoxFit.cover,
          image: NetworkImage('${images['avatar']}'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white70,
          leading: backBtn(),
          elevation: 0.0,
//          title:backBtn(),
      ),
      //フッターボタン
      persistentFooterButtons: <Widget>[
        //レシピの編集ボタン
        deleteBtn(),//削除
        editBtn(),  //レシピの編集
      ],
      body: showDetail(),
    );
  }

  //削除ボタン
  Widget deleteBtn(){
    return Padding(
        padding: EdgeInsets.only(right: 150),
        child: IconButton(
          icon:Icon(Icons.delete,size: 30,),
          onPressed: (){
            _showDeleteDialog();
          },
        ),
      );
  }

  //編集ボタン
  Widget editBtn(){
    return Padding(
      padding: EdgeInsets.only(right: 10),
      child: FlatButton(
        color: Colors.redAccent,
        child: Text('レシピの編集',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        onPressed: (){
          onEdit();
        },
      ),
    );
  }

  //戻るボタン
  Widget backBtn(){
    return IconButton(
        icon:Icon(Icons.arrow_back_ios,color: Colors.grey,size: 35,),
        onPressed: (){
          onList();
        },
    );
  }

  //ページ全体
  Widget showDetail(){
    return Stack(
      children: <Widget>[
        scrollArea(),           //レシピ詳細全体
        showCircularProgress(), //アクティビティインジケータ
      ],
    );
  }

  //レシピ詳細
  Widget scrollArea(){
    return Container(
      child:SingleChildScrollView(
        child:Padding(
          padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 10.0),
          child: Column(
//              crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              imageArea(),     //画像エリア
              paginationArea(), //ペジネーションエリア
              titleArea(),      //タイトルエリア
              line(),           //罫線
              contentArea(),    //テキストエリア
              line(),           //罫線
            ],
          ),
        ),
      ),
    );
  }

  //画像エリア
  Widget imageArea(){
//    return Consumer<Display>(
//        builder: (context,Display,_){
      return
        Container(
          child: SizedBox(
            height: 300.0,
            child: PageView.builder(
              controller: controller,
              itemCount: _data == null ? 0 :_data.length,
              itemBuilder: (context, int currentIndex){
                // アクティブ値
                bool active = currentIndex == currentPage;
                // カードの生成して返す
                return _createCardAnimate(
                  _data[currentIndex],
                  active,
                );
              },
            ),
          ),
        );
  }

  //ペジネーションエリア( ○○○○○○ )
  Widget paginationArea(){
    return
      _data == null
      ? Container()
      //作成したペジネーションを表示
      : _createPagination();
  }

  //タイトルエリア
  Widget titleArea(){
    return Consumer<Display>(
      builder: (context,Display,_) {
        return
          Display.selectItem['first_name'] == null
            ? Container()
            : Container(
                margin: EdgeInsets.all(5),
                padding: EdgeInsets.all(5),
                child: Text('${Display.selectItem['first_name']}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue
                  ),
                ),
              );
      },
    );
  }

  //テキストエリア
  Widget contentArea(){
    return Consumer<Display>(
        builder: (context,Display,_) {
          return Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(5),
                child: Text('レシピmemo',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black
                  ),
                ),
              ),
              Display.selectItem == null
                  ? Container()
                  : Container(
                  margin: EdgeInsets.all(5),
                  padding: EdgeInsets.all(5),
                  child:Text('${Display.selectItem}テキストが入ります。テキストが入ります。テキストが入ります。テキストが入ります。テキストが入ります。テキストが入ります。テキストが入ります。テキストが入ります。テキストが入ります。テキストが入ります。テキストが入ります。テキストが入ります。テキストが入ります。')
              ),
            ],
          );
        }
        );
  }

  //罫線
  Widget line(){
    return Divider(
        color: Colors.grey
    );
  }

  //アクティビティインジケータ
  //null参照時に落ちない用、flutterで用意されてるを実装
  Widget showCircularProgress() {
    return
      _isLoading
      //通信中の場合
        //CircularProgressIndicator() => 円形にグルグル回るタイプのやつ
        ? Center(child: CircularProgressIndicator())
      //上記以外の場合
        : Container(height: 0.0,width: 0.0,);
  }
}