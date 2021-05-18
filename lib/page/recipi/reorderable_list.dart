// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import 'package:recipe_app/store/display_state.dart';
//
// class ReorderableList extends StatefulWidget {
//   ReorderableList({Key key,this.reorders, this.type}) : super(key: key);
//
//   final List reorders;
//   final int type;
//
//   @override
//   _ReorderableListState createState() => _ReorderableListState();
// }
//
// class _ReorderableListState extends State<ReorderableList> {
//   List<Model> reorderList;
//   // List reorders;
//
//   @override
//   void initState() {
//     print('++++++++++++++++++++++++++++++++++');
//     print('++++++++++++++++++++++++++++++++++');
//     print('++++++ ReorderableList +++++++++++');
//     print('++++++++++++++++++++++++++++++++++');
//     print('++++++++++++++++++++++++++++++++++');
//     super.initState();
//     reorderList = [];
//     // reorders = [];
//     // if(widget.type == 0){
//     //   Provider.of<Display>(context, listen: false).getIngredientsOCR().forEach((ingredient)  => reorders.add(ingredient));
//     // } else {
//     //   Provider.of<Display>(context, listen: false).getQuantitysOCR().forEach((quantity)  => reorders.add(quantity));
//     // }
//     for (int i = 0; i < widget.reorders.length; i++) {
//       Model model = Model(
//         title: widget.reorders[i].name,
//         subTitle: widget.reorders[i].no.toString(),
//         key: widget.reorders[i].id.toString(),
//       );
//       reorderList.add(model);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Expanded(child: Reorderable(reorderList,widget.type)),
//           ],
//         );
//   }
//
//   ReorderableListView Reorderable(List<Model> modelList,int type){
//     return ReorderableListView(
//       padding: EdgeInsets.all(10.0),
//      onReorder: (oldIndex, newIndex) {
//         if (oldIndex < newIndex) {
//           // removing the item at oldIndex will shorten the list by 1.
//           newIndex -= 1;
//         }
//         final Model model = modelList.removeAt(oldIndex);
//
//         setState(() {
//           modelList.insert(newIndex, model);
//         });
//       },
//       children: modelList.map(
//             (Model model) {
//           return Container(
//             key: Key(model.key),
//             height: 70,
//             child:
//             Card(
//               elevation: 2.0,
//               key: Key(model.key),
//               child: ListTile(
//                 // leading: const Icon(Icons.people),
//                 title: Text(model.title),
//                 subtitle: Text(model.subTitle),
//               ),
//             ),
//           );
//         },
//       ).toList(),
//       // ),
//       // )
//     );
//   }
// }
//
// class Model {
//   final String title;
//   final String subTitle;
//   final String key;
//
//   Model({
//     @required this.title,
//     @required this.subTitle,
//     @required this.key,
//   });
// }