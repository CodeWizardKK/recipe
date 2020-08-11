import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/store/display_state.dart';
import 'package:recipe_app/services/recipi/recipi_item.dart' as recipiItemRepo;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:recipe_app/model/edit/Ingredient.dart';
import 'package:recipe_app/model/edit/Howto.dart';
import 'package:recipe_app/model/edit/Photo.dart';
import 'package:recipe_app/model/Myrecipi.dart';

class RecipiDetail extends StatefulWidget{
  _RecipiDetailState createState() => _RecipiDetailState();
}

class _RecipiDetailState extends State<RecipiDetail>{

  var _resultData = new Map<String,dynamic>(); //serverからgetした値を格納
  var _isLoading = true;     //通信中:true(円形のグルグルのやつ)
  var _currentPage = 0;      // ページインデックス
  var _errorMessage = '';    //await関連のエラーメッセージ
  final PageController _controller
                = PageController(viewportFraction: 0.8); // ページコントローラ

  @override
  void initState() {
   super.initState();
   //該当レコードを取得
   _getItem();
   //ページ遷移を監視
   _pageController();
  }

  //該当レコードの取得
  Future<void> _getItem() async{
    var option = {};
    //取得する為のIDを取得
    option['id'] = Provider.of<Display>(context, listen: false).getId();

    try{
      //該当レコード取得処理の呼び出し
//      _resultData = await recipiItemRepo.get(option);　//本番用
      _resultData = await recipiItemRepo.getLocal();    //mock用
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
      _isLoading = false;
    });
  }

  // ページコントローラのページ遷移を監視しページ数を丸める
  void _pageController(){
    _controller.addListener(() {
      int next = _controller.page.round();
//      print('currentPage:${_currentPage}');
//      print('next:${next}');
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
      }
    });
  }

  //レシピリストへ戻るボタン押下時処理
  void _onList(){
    Provider.of<Display>(context, listen: false).setState(-1);
  }

  //削除処理
  void _onDelete(){
   //該当レコード削除処理(IDをpushする)

   //レシピリストへ戻る
   _onList();

  }

  //レシピの編集ボタン押下時処理
  void _onEdit(){
//    //該当レコードをstoreに格納
//    Provider.of<Display>(context, listen: false).setSelectItem(_resultData);
//    //
//    Provider.of<Display>(context, listen: false).setImages(_resultData['images']);
    //編集画面へ遷移
    Provider.of<Display>(context, listen: false).setState(1);
  }

  //削除アイコン押下時処理
  Future<void> _showDeleteDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('確認'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('削除してもよろしいですか？'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                _onDelete();
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
    for(var i = 0 ;i<_resultData['images'].length; i++){
      //表示しているページとindexが一致している場合
      if(_currentPage == i){
        //●を追加する
        page.add(Container(key: GlobalKey(),margin: const EdgeInsets.all(5),child: const Icon(Icons.brightness_1,size: 5,color: Colors.grey,)));
      }else{
        //○を追加する
        page.add(Container(key: GlobalKey(),margin: const EdgeInsets.all(5),child: const Icon(Icons.panorama_fish_eye,size: 5,color: Colors.grey,)));
      }
    }
//    print('page:${page}');
    return
      Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: page
      );
  }
  //アニメーションカード生成
  AnimatedContainer _createCardAnimate(Map<String,Object> images, bool active) {

//    print('${images['path']}');

    // アクティブと非アクティブのアニメーション設定値
//    final double top = active ? 100 : 200;
//    final double side = active ? 0 : 40;

    return AnimatedContainer(
      key: GlobalKey(),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutQuint,
      margin: const EdgeInsets.only(top: 0, bottom: 0, right: 30, left: 30),
      child: CachedNetworkImage(
        key: GlobalKey(),
        imageUrl: '${images['path']}',
        progressIndicatorBuilder: (context, url, downloadProgress) =>
            CircularProgressIndicator(value: downloadProgress.progress),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      ),

//      decoration: BoxDecoration(
//        image: DecorationImage(
//          fit: BoxFit.fitWidth,
////          fit: BoxFit.cover,
//          image: NetworkImage('${images['path']}'),
//        ),
//      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white70,
          leading: backBtn(),
          elevation: 0.0,
          title:titleArea(),
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
        padding: const EdgeInsets.only(right: 150),
        child: IconButton(
          icon: const Icon(Icons.delete,size: 30,),
          onPressed: (){
            _showDeleteDialog();
          },
        ),
      );
  }

  //編集ボタン
  Widget editBtn(){
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: FlatButton(
        key: GlobalKey(),
        color: Colors.redAccent,
        child: const Text('レシピの編集',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        onPressed: (){
          _onEdit();
        },
      ),
    );
  }

  //戻るボタン
  Widget backBtn(){
    return IconButton(
        icon: const Icon(Icons.arrow_back_ios,color: Colors.grey,size: 20,),
        onPressed: (){
          _onList();
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
    return
      _resultData == null
      ? Container()
      : Container(
      child:SingleChildScrollView(
        child:Padding(
          padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 10.0),
          child: Column(
//              crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              imageArea(),     //画像エリア
              paginationArea(), //ペジネーションエリア
//              titleArea(),      //タイトルエリア
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
      return
        _resultData['images'] == null
        ? Container()
        : Container(
          child: SizedBox(
            height: 300.0,
            child: PageView.builder(
              controller: _controller,
              itemCount: _resultData['images'] == null ? 0 :_resultData['images'].length,
              itemBuilder: (context, int currentIndex){
                // アクティブ値
                bool active = currentIndex == _currentPage;
                // カードの生成して返す
                return _createCardAnimate(
                  _resultData['images'][currentIndex],
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
      _resultData['images'] == null
      ? Container(
          key: GlobalKey(),
        )
      //作成したペジネーションを表示
      : _createPagination();
  }

  //タイトルエリア
  Widget titleArea(){
        return
          _resultData['title'] == null
            ? Container()
            : Container(
//                margin: EdgeInsets.only(right: 10),
//                padding: EdgeInsets.only(right: 20),
                child: Text('${_resultData['title']}',
                  style: const TextStyle(
                    fontSize: 18,
//                    fontWeight: FontWeight.bold,
                    color: Colors.grey
                  ),
                ),
              );
  }

  //テキストエリア
  Widget contentArea(){
    return Column(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.all(5),
          child: const Text('レシピmemo',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black
            ),
          ),
        ),
        _resultData['body'] == null
            ? Container()
            : Container(
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.all(5),
            child:Text('${_resultData['body']}')
        ),
      ],
    );
  }

  //罫線
  Widget line(){
    return const Divider(
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
        ? const Center(child: CircularProgressIndicator())
      //上記以外の場合
        : Container(height: 0.0,width: 0.0,);
  }
}