import 'package:flutter/material.dart';

class WhatsappImages extends StatefulWidget {
  @override
  _WhatsappImagesState createState() => _WhatsappImagesState();
}

class _WhatsappImagesState extends State<WhatsappImages> {
  late final ScrollController scrollController;

  @override
  void initState() {
    scrollController = ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Whatsapp Parallax'),
      ),
      body: ListView.builder(
        controller: scrollController,
        itemBuilder: (context, index) {
          final imagePath = 'images/image${index % 6}.jpg';
          return AnimatedBuilder(
            animation: scrollController,
            builder: (context, child) => SingleImage(
              imagePath: imagePath,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}

class SingleImage extends StatelessWidget {
  final String imagePath;

  const SingleImage({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final renderObject = context.findRenderObject() as RenderBox?;
    final offsetY = renderObject?.localToGlobal(Offset.zero).dy ?? 0;
    final deviceHeight = MediaQuery.of(context).size.height;
    final relativePosition = offsetY / deviceHeight;

    /// Alignment o'rniga rasmni biroz kattalashtirib, offsetY bo'yicha siljitish:
    /// relativePosition ga qarab rasmni Y o'qi bo'yicha siljitish
    /// Enli rasmlarda ham zaxira joy bo'lishi uchun 30% kattalashtiramiz

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 800,
            height: 300,
            child: Transform.translate(
              offset: Offset(0, (relativePosition - 0.5) * -100),
              child: Transform.scale(
                scale: 1.3,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // final renderObject = context.findRenderObject() as RenderBox?;
    // final offsetY = renderObject?.localToGlobal(Offset.zero).dy ?? 0;
    // final deviceHeight = MediaQuery.of(context).size.height;
    // final relativePosition = offsetY / deviceHeight;
    //
    // return Center(
    //   child: Container(
    //     width: 800,
    //     height: 300,
    //     margin: const EdgeInsets.all(16),
    //     decoration: BoxDecoration(
    //       borderRadius: BorderRadius.circular(8),
    //       border: Border.all(color: Colors.black, width: 2),
    //       image: DecorationImage(
    //         fit: BoxFit.cover,
    //         alignment: Alignment(0, relativePosition - 0.5),
    //         image: AssetImage(imagePath),
    //       ),
    //     ),
    //   ),
    // );
  }
}
