// import 'package:flutter/material.dart';

// class showModalCalender extends StatefulWidget {
//   const showModalCalender({super.key});

//   @override
//   State<showModalCalender> createState() => _showModalCalenderState();
// }

// class _showModalCalenderState extends State<showModalCalender> {
//   @override
//   Widget build(BuildContext context) {
//     return showModalBottomSheet(
//       //モーダルの背景の色、透過
//       backgroundColor: Colors.transparent,
//       //ドラッグ可能にする（高さもハーフサイズからフルサイズになる様子）
//       isScrollControlled: true,
//       context: context,
//       builder: (BuildContext context) {
//         return Container(
//             margin: EdgeInsets.only(top: 100),
//             decoration: BoxDecoration(
//               //モーダル自体の色
//               color: Colors.white,
//               //角丸にする
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(20),
//                 topRight: Radius.circular(20),
//               ),
//             ),
//             child: Column(
//               children: [
//                 Text('タイトル'),
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: TextFormField(
//                     controller: TextEditingController(
//                       text: game.title
//                     )
//                   ),
//                 ),
//                 Text('買う場所・説明・補足'),
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: TextFormField(controller: TextEditingController()),
//                 ),
//               ],
//             )
//           );
//       });
//   }
// }