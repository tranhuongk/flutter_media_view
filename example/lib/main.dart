import 'package:flutter/material.dart';
import 'package:media_view/media_view.dart';

void main() {
  runApp(const Main());
}

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: MediaViewWrapper(
          builder: (context) => ListView.builder(
            itemCount: 100,
            itemBuilder: (context, index) => switch (index) {
              0 => ImageView(
                  uri: Uri.parse('assets/nokiaa.png'),
                  fit: BoxFit.cover,
                  aspectRatio: 1,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                ),
              1 => ImageView(
                  uri: Uri.parse(
                    'https://hullabaloo.co.uk/wp-content/uploads/2016/03/Hullabaloo-Loughborough-Graphics-Design-Blog-Images-0042..jpg',
                  ),
                  width: 100,
                  height: 400,
                  fit: BoxFit.cover,
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(36),
                  ),
                ),
              2 => ImageView(
                  uri: Uri.parse(
                    'https://ask.damiensymonds.net/uploads/monthly_2017_03/DSC_3367_700x700_damien.jpg.3f8c5dca40e4fa5efc275d2f7ecf771a.jpg',
                  ),
                  fit: BoxFit.cover,
                ),
              _ => ImageView(
                  context: context,
                  uri: Uri.parse(
                    'https://images.pexels.com/photos/842711/pexels-photo-842711.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2?index=$index',
                  ),
                  height: 400,
                  fit: BoxFit.cover,
                ),
            },
          ),
        ),
      ),
    );
  }
}
