import 'package:flutter/material.dart';
import '../../../core/globals.dart';

class AddScreen extends StatelessWidget {
  const AddScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text("ADD",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
      ),
      backgroundColor: Colors.black,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
                Text('This page is under construction.\nStay tuned for more features.',
                style: TextStyle(
                  fontSize: w*0.045,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              // Subtitle Text
            ],
          ),
        ),
      ),
    );
  }
}
