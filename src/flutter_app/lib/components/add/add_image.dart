import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddImage extends StatefulWidget {
  const AddImage({super.key, required this.onAddImage});

  final ValueSetter<ImageSource> onAddImage;

  @override
  State<StatefulWidget> createState() => _AddImageState();
}

class _AddImageState extends State<AddImage>{
  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: const Text('Please choose media to select'),
      content: SizedBox(
        height: MediaQuery.of(context).size.height / 6,
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onAddImage.call(ImageSource.gallery);
              },
              child: Row(
                children: const [
                  Icon(Icons.image),
                  Text('From Gallery'),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onAddImage.call(ImageSource.camera);
              },
              child: Row(
                children: const [
                  Icon(Icons.camera),
                  Text('From Camera'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}