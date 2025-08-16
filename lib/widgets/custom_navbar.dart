// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../cubit/navigation/navigation_cubit.dart';
// import '../cubit/navigation/navigation_state.dart';
// import '../core/theme/app_theme.dart';
//
// class CustomNavBar extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<NavigationCubit, NavigationState>(
//       builder: (context, state) {
//         return Container(
//           height: 74,
//           width: double.infinity,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: const BorderRadius.only(
//               topLeft: Radius.circular(18),
//               topRight: Radius.circular(18),
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: const Color(0x959DA540),
//                 offset: const Offset(0, -3),
//                 blurRadius: 6,
//               ),
//             ],
//           ),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 22),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 _navIcon(context, Icons.person, 0, state.index),
//                 _navIcon(context, Icons.history, 1, state.index),
//                 _navIcon(context, Icons.home, 2, state.index),
//                 _navIcon(context, Icons.picture_as_pdf, 3, state.index),
//                 _navIcon(context, Icons.settings, 4, state.index),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _navIcon(BuildContext context, IconData icon, int index, int selectedIndex) {
//     final isSelected = index == selectedIndex;
//     return GestureDetector(
//       onTap: () => context.read<NavigationCubit>().changePage(index),
//       child: Icon(
//         icon,
//         size: 32,
//         color: isSelected ? AppTheme.primary : Colors.grey,
//       ),
//     );
//   }
// }
