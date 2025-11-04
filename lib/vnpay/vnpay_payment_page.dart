// // import 'package:flutter/material.dart';
// // import 'package:vnpay_flutter/vnpay_flutter.dart';
// //
// // // void main() {
// // //   runApp(MyApp());
// // // }
// //
// // class MyApp extends StatelessWidget {
// //   const MyApp({Key? key}) : super(key: key);
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'Flutter Demo',
// //       theme: ThemeData(
// //         primarySwatch: Colors.blue,
// //       ),
// //       home: const Example(),
// //     );
// //   }
// // }
// //
// // class Example extends StatefulWidget {
// //   const Example({Key? key}) : super(key: key);
// //
// //   @override
// //   State<Example> createState() => _ExampleState();
// // }
// //
// // class _ExampleState extends State<Example> {
// //   String responseCode = '';
// //
// //   Future<void> onPayment() async {
// //     final paymentUrl = VNPAYFlutter.instance.generatePaymentUrl(
// //       url:
// //       'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html', //vnpay url, default is https://sandbox.vnpayment.vn/paymentv2/vpcpay.html
// //       version: '2.0.0',
// //       tmnCode: 'ROCTE1IP', //vnpay tmn code, get from vnpay
// //       txnRef: DateTime.now().millisecondsSinceEpoch.toString(),
// //       orderInfo: 'Pay 30.000 VND', //order info, default is Pay Order
// //       amount: 30000,
// //       returnUrl: 'https://sandbox.vnpayment.vn/paymentv2/ReturnResultDemo',
// //       // returnUrl:
// //       // 'xxxxxx', //https://sandbox.vnpayment.vn/apis/docs/huong-dan-tich-hop/#code-returnurl
// //       ipAdress: '10.0.2.16',
// //       vnpayHashKey: 'JDKAOJ2D0OMX7G8AFR899M0OW7FE5WD3', //vnpay hash key, get from vnpay
// //       vnPayHashType: VNPayHashType
// //           .HMACSHA512, //hash type. Default is HMACSHA512, you can chang it in: https://sandbox.vnpayment.vn/merchantv2,
// //       vnpayExpireDate: DateTime.now().add(const Duration(hours: 1)),
// //     );
// //     await VNPAYFlutter.instance.show(
// //       context: context,
// //       paymentUrl: paymentUrl,
// //       onPaymentSuccess: (params) {
// //         setState(() {
// //           responseCode = params['vnp_ResponseCode'];
// //         });
// //       },
// //       onPaymentError: (params) {
// //         setState(() {
// //           responseCode = 'Error';
// //         });
// //       },
// //     );
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: <Widget>[
// //             Text('Response Code: $responseCode'),
// //             TextButton(
// //               onPressed: onPayment,
// //               child: const Text('30.000VND'),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
//
//
// import 'package:flutter/material.dart';
// import 'package:vnpay_flutter/vnpay_flutter.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'VNPAY Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: ExamplePage(),
//     );
//   }
// }
//
// class ExamplePage extends StatefulWidget {
//   @override
//   _ExamplePageState createState() => _ExamplePageState();
// }
//
// class _ExamplePageState extends State<ExamplePage> {
//   String responseCode = '';
//
//   Future<void> onPayment() async {
//     // Tạo URL thanh toán
//     final paymentUrl = VNPAYFlutter.instance.generatePaymentUrl(
//       url: 'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html',
//       version: '2.0.1',
//       tmnCode: 'ROCTE1IP', // lấy từ VNPAY sandbox
//       txnRef: DateTime.now().millisecondsSinceEpoch.toString(),
//       orderInfo: 'Thanh toán 30.000 VND',
//       amount: 30000,
//       returnUrl: 'https://sandbox.vnpayment.vn/paymentv2/ReturnResultDemo',
//       ipAdress: '10.0.2.16', // emulator
//       vnpayHashKey: 'JDKAOJ2D0OMX7G8AFR899M0OW7FE5WD3',
//       vnPayHashType: VNPayHashType.HMACSHA512,
//       vnpayExpireDate: DateTime.now().add(Duration(hours: 1)),
//     );
//
//     // Hiển thị màn hình thanh toán VNPAY
//     await VNPAYFlutter.instance.show(
//       // context: context, // dùng context của State
//       paymentUrl: paymentUrl,
//       onPaymentSuccess: (params) {
//         setState(() {
//           responseCode = params['vnp_ResponseCode'] ?? 'Success';
//         });
//       },
//       onPaymentError: (params) {
//         setState(() {
//           responseCode = 'Error';
//         });
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('VNPAY Demo')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text('Response Code: $responseCode'),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: onPayment,
//               child: Text('Thanh toán 30.000 VND'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
//
//
