import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:http/http.dart' as http;

import 'components/app_drawer.dart';
import 'components/elevated_container.dart';
import 'main.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (2, 3);

  @override
  String get name => '2x3 (customized)';
}
class _MyHomePageState extends State<MyHomePage> {
  ScrollController scrollController = ScrollController();
  File? _imageFile;
  String _recognizedText = 'No text recognized';
  var prediction,response;
  String result = '';
  final textDetector = GoogleMlKit.vision.textRecognizer();

  // Future<void> _pickImage(ImageSource source) async {
  //   final pickedFile = await ImagePicker().pickImage(source: source);
  //   if (pickedFile != null) {
  //     setState(() {
  //       _imageFile = File(pickedFile.path);
  //       _recognizedText = 'Recognizing...';
  //     });
  //     _recognizeText();
  //   }
  // }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile!.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPresetCustom(),
          ],
        ),
        IOSUiSettings(
          title: 'Cropper',
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPresetCustom(), // IMPORTANT: iOS supports only one custom aspect ratio in preset list
          ],
        ),
        WebUiSettings(
          context: context,
        ),
      ],
    );
    // if (pickedFile != null) {
    //   CroppedFile? croppedFile = await ImageCropper().cropImage(
    //     sourcePath: pickedFile.path,
    //     aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),  // Example aspect ratio
    //     uiSettings: [
    //       AndroidUiSettings(
    //         toolbarTitle: 'Crop Image',
    //         toolbarColor: Colors.deepOrange,
    //         toolbarWidgetColor: Colors.white,
    //         initAspectRatio: CropAspectRatioPreset.original,
    //         lockAspectRatio: false,
    //       ),
    //       IOSUiSettings(
    //         minimumAspectRatio: 1.0,
    //       ),
    //     ],
    //   );
    //
      if (croppedFile != null) {
        setState(() {
          // _imageFile = croppedFile;
          _imageFile = File(croppedFile.path);  // Convert CroppedFile to File
          _recognizedText = 'Recognizing...';
        });
        _recognizeText();
      }
    // }
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
  void initState() {
    // TODO: implement initState
    super.initState();
    sharedPreferences.setString('url', 'http://192.168.5.15:5000/predict');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OCR'),
        centerTitle: true,
      ),
      drawer: AppDrawer(),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width*0.95,
                      height: 150,
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20)
                      ),
                      child: Scrollbar(
                        controller: scrollController,
                        thumbVisibility: true,
                        trackVisibility: true,
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Text(
                            overflow: TextOverflow.clip,
                            _recognizedText,
                            style: TextStyle(
                              fontSize: 16
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
                              '${prediction.toString()}',
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
    prediction != null?prediction=null:null;
    // postRequest('1234567890','Mambo emmy');
    postRequest('1234567890',_recognizedText);
  }
  void postRequest(String phone, String message) async { // To store the result from the API call
    // todo - fix baseUrl
    // var url = 'https://jsonplaceholder.typicode.com/posts';
    // var url = 'http://127.0.0.1:5000/predict';
    // var url = 'http://localhost:5000/predict';
    var url = sharedPreferences.containsKey('url')?sharedPreferences.getString('url'):'http://192.168.5.15:5000/predict';
    // var body = json.encode({
    //   'phone': phone,
    //   'message': message,
    // });
    var body = {
      'phone': phone,
      'message': message,
    };

    print('Body: $body');

    try {
      response = await http.post(
        Uri.parse(url!),
        headers: {
          // 'accept': 'application/json',
          // 'Content-Type': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      print('STATUS: ${response.statusCode}');
      
      // todo - handle non-200 status code, etc
      if (response.statusCode == 200) {
        // Successful POST request, handle the response here
        final responseData = jsonDecode(response.body);
        setState(() {
          // result = 'ID: ${responseData['id']}\nName: ${responseData['name']}\nEmail: ${responseData['email']}';
          result = responseData['result'];

          var presence = sharedPreferences.containsKey('history');
          if(presence){
            List<String> history = sharedPreferences.getStringList('history')!;
            history.add('${_recognizedText}=>${result}');
            sharedPreferences.setStringList('history', history);
          }else{
            sharedPreferences.setStringList('history', ['${_recognizedText}=>${result}']);
          }
          prediction = result;//json.decode(response.body);
          print('IMEFANIKIWA');
        });
      } else {
        // If the server returns an error response, throw an exception
        result = 'Error: Failed!';
        prediction = 'Failed!';
        print('HAIJAFANIKIWA ELSE');
        throw Exception('Failed!');
      }
    } catch (e) {
      setState(() {
        result = 'Error: $e';
        prediction = 'Failed!';
        print('HAIJAFANIKIWA EXCEPTION $result');
      });
    }
  }
}
