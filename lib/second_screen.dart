import 'package:flutter/material.dart';

const String isec_url =
    'https://www.isec.pt/assets_isec/logo-isec-transparente.png';

class SecondScreen extends StatefulWidget  {
  const SecondScreen({super.key});

  static const String routeName = '/SecondScreen';

  @override
  State<SecondScreen> createState() => _SecondScreenState();

  @override
    Widget build(BuildContext context) {
      // TODO: implement build
      throw UnimplementedError();
    }
}

class _SecondScreenState extends State<SecondScreen> {
  late int _counter = ModalRoute.of(context)?.settings.arguments as int ?? 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amberAccent,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text(
            'Locais de Interesse',
        style: TextStyle(color: Colors.indigo)
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //SizedBox(height: 200, child: Image.asset('images/coast.jpg'),),
            SizedBox(height:50 ,child: Image.network(isec_url)),
            Hero(
                tag: 'AMov1',
                child: Text('Value = $_counter'),
            ),
            ElevatedButton(
                onPressed: () => Navigator.of(context).pop(_counter * 2),
                child: const Text('Return')
            ),
          ],
        ),
      ),
    );
  }
}