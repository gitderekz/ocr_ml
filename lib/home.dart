import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:http/http.dart' as http;

import 'components/elevated_container.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _imageFile;
  String _recognizedText = 'No text recognized';
  var prediction,response;
  String result = '';
  final textDetector = GoogleMlKit.vision.textRecognizer();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _recognizedText = 'Recognizing...';
      });
      _recognizeText();
    }
  }

  Future<void> _recognizeText() async {
    final inputImage = InputImage.fromFile(_imageFile!);
    final RecognizedText recognisedText = await textDetector.processImage(inputImage);

    setState(() {
      _recognizedText = recognisedText.text;
    });
    _checkPrediction();
  }



  @override
  void dispose() {
    textDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OCR'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _imageFile == null ?
                const Text('No image selected')
                :
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Colors.blueGrey,
                    image: DecorationImage(image: FileImage(_imageFile!)),
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  // child: Padding(
                  //   padding: const EdgeInsets.all(8.0),
                  //   child: Image.file(_imageFile!),
                  // )
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  child: const Text('Select Image from Gallery'),
                ),
                ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.camera),
                  child: const Text('Capture Image from Camera'),
                ),
                const SizedBox(height: 20),
                Text(_recognizedText),
                const SizedBox(height: 20),
                prediction!=null?
                ElevatedContainer(
                  color: Colors.blueGrey,
                  borderRadius: 30.0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'PREDICTION RESULT ',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            Icon(Icons.access_alarm, color: Colors.white,)
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white38,
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(20.0)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${prediction.toString()},\n$result',
                              // style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                )
                :_imageFile == null? //IF NO IMAGE & NO PREDICTION
                const SizedBox()
                :
                const SizedBox(
                  height: 50,
                  width: 50,
                  child: CircularProgressIndicator(),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _checkPrediction(){
    postRequest('Testor','Testor@development.com');
  }
  Future<Map<String, dynamic>> postRequest(String name, String email) async { // To store the result from the API call
    // todo - fix baseUrl
    var url = 'https://jsonplaceholder.typicode.com/posts';
    var body = json.encode({
      'name': name,
      'email': email,
    });

    print('Body: $body');

    try {
      response = await http.post(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        // headers: {
        //   'accept': 'application/json',
        //   'Content-Type': 'application/json-patch+json',
        // },
        body: body,
      );
      setState(() {
        response = response;
      });
      
      // todo - handle non-200 status code, etc
      if (response.statusCode == 201) {
        // Successful POST request, handle the response here
        final responseData = jsonDecode(response.body);
        setState(() {
          result = 'ID: ${responseData['id']}\nName: ${responseData['name']}\nEmail: ${responseData['email']}';
        });
      } else {
        // If the server returns an error response, throw an exception
        throw Exception('Failed to post data');
      }
    } on Exception catch (e) {
      setState(() {
        result = 'Error: $e';
      });
    }

    setState(() {
      prediction = json.decode(response.body);
    });
    return json.decode(response.body);
  }
}
