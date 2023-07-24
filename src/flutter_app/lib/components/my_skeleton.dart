import 'package:flutter/material.dart';
import 'package:skeletons/skeletons.dart';

class MySkeleton extends StatelessWidget {
  const MySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
        padding: EdgeInsets.all(5),
        child: SkeletonAvatar(
          style: SkeletonAvatarStyle(
              shape: BoxShape.rectangle, width: 150, height: 250
          ),
        )
    );
  }
}