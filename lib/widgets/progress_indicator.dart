import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class MyProgressIndicator extends StatelessWidget {
  const MyProgressIndicator({
    super.key,
    this.size = 50.0,
    this.isDark = false,
    // this.text,
  });

  final double size;
  final bool isDark;
  // final String? text;

  @override
  Widget build(BuildContext context) {
    // if (text == null) {
    return SpinKitCircle(
      duration: const Duration(milliseconds: 1000),
      size: size,
      itemBuilder: (context, index) {
        final darkColors = [
          const Color(0xFF21005D),
          const Color(0xFF6750A4),
          const Color(0xFF625B71),
          const Color(0xFF7D5260),
        ];
        final lightColors = [
          const Color(0xFF9E77ED),
          const Color(0xFFD0BCFF),
          const Color(0xFFADA4C1),
          const Color(0xFFEAB8C2),
        ];
        final colors = isDark ? lightColors : darkColors;
        final color = colors[index % colors.length];
        return DecoratedBox(
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        );
      },
    );
    // }
    // return Scaffold(
    //   backgroundColor: Colors.transparent,
    //   body: Stack(
    //     children: [
    //       const Positioned.fill(
    //         child: Opacity(
    //           opacity: 0.5,
    //           child: ModalBarrier(dismissible: false, color: Colors.black),
    //         ),
    //       ),
    //       Center(
    //         child: Container(
    //           width: MediaQuery.of(context).size.width * 0.8,
    //           padding: const EdgeInsets.all(20.0),
    //           decoration: BoxDecoration(
    //             color: Colors.white,
    //             borderRadius: BorderRadius.circular(10.0),
    //             boxShadow: const [
    //               BoxShadow(
    //                 color: Colors.black26,
    //                 blurRadius: 10.0,
    //                 offset: Offset(0, 2),
    //               ),
    //             ],
    //           ),
    //           child: Column(
    //             mainAxisSize: MainAxisSize.min,
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: [
    //               Row(
    //                 mainAxisAlignment: MainAxisAlignment.start,
    //                 children: [
    //                   SpinKitCircle(
    //                     duration: const Duration(milliseconds: 1000),
    //                     size: size,
    //                     itemBuilder: (context, index) {
    //                       final darkColors = [
    //                         const Color(0xFF21005D),
    //                         const Color(0xFF6750A4),
    //                         const Color(0xFF625B71),
    //                         const Color(0xFF7D5260),
    //                       ];
    //                       final lightColors = [
    //                         const Color(0xFF9E77ED),
    //                         const Color(0xFFD0BCFF),
    //                         const Color(0xFFADA4C1),
    //                         const Color(0xFFEAB8C2),
    //                       ];
    //                       final colors = isDark ? lightColors : darkColors;
    //                       final color = colors[index % colors.length];
    //                       return DecoratedBox(
    //                         decoration: BoxDecoration(
    //                           color: color,
    //                           shape: BoxShape.circle,
    //                         ),
    //                       );
    //                     },
    //                   ),
    //                   const SizedBox(width: 10.0),
    //                   Flexible(
    //                     child: Text(
    //                       text!,
    //                       style: const TextStyle(
    //                         fontSize: 16,
    //                         fontWeight: FontWeight.bold,
    //                         color: Colors.black,
    //                       ),
    //                       overflow: TextOverflow.ellipsis,
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //             ],
    //           ),
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }
}
