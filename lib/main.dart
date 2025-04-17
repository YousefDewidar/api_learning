// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pancreas_cancer/in_app_notification.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:lottie/lottie.dart';

void main() {
  runApp(PancreasCancer());
}

class PancreasCancer extends StatelessWidget {
  const PancreasCancer({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pancreas Scan Analyzer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String _modelPath = 'assets/pancreas_cancer_mode_final.tflite';
  final String _labelsPath = 'assets/labels.txt';

  Interpreter? _interpreter;
  List<String>? _labels;

  File? _imageFile;
  bool _loading = false;
  List<double>? _outputs;
  // --- Model Input/Output Details ---
  final int _inputWidth = 224;
  final int _inputHeight = 224;

  @override
  void initState() {
    super.initState();
    _loadModel();
    _loadLabels(); // Optional
  }

  @override
  void dispose() {
    _interpreter?.close();
    super.dispose();
  }

  // --- Load TFLite Model ---
  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(_modelPath);
      log('Interpreter loaded successfully');
      // Optional: log input/output tensor details to verify
      log('Input tensor details: ${_interpreter?.getInputTensor(0).name}');
      log('Output tensor details: ${_interpreter?.getOutputTensor(0).name}');
    } catch (e) {
      log('Error loading interpreter: $e');
      // Show error to user if needed
    }
  }

  // --- Load Labels (Optional) ---
  Future<void> _loadLabels() async {
    try {
      final labelsData = await rootBundle.loadString(_labelsPath);
      _labels =
          labelsData
              .split('\n')
              .map((label) => label.trim())
              .where((label) => label.isNotEmpty)
              .toList();
      log('Labels loaded successfully: $_labels');
      if (_labels?.length != 4) {
        // Check if label count matches output size
        log(
          "Warning: Number of labels (${_labels?.length}) does not match model output size (4).",
        );
        // Consider handling this error, maybe disable label display
      }
    } catch (e) {
      log('Error loading labels: $e');
      _labels = null; // Indicate labels aren't available
    }
  }

  // --- Pick Image ---
  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _outputs = null;
          _loading = false;
        });
      }
    } catch (e) {
      log('Error picking image: $e');
      // Show error to user
    }
  }

  // --- Preprocess Image and Run Inference ---

  Future<void> _runInference() async {
    if (_imageFile == null || _interpreter == null) {
      log('Error: Image or Interpreter not ready.');
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      // --- Step 1: Detect face (reject personal images) ---
      final inputImage = InputImage.fromFile(_imageFile!);
      final faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          enableContours: false,
          enableClassification: false,
        ),
      );
      final faces = await faceDetector.processImage(inputImage);
      await faceDetector.close();

      if (faces.isNotEmpty) {
        setState(() => _loading = false);
        showNotification(
          context,
          'This is a personal image. Please upload X-ray image only.',
        );
        return;
      }

      // --- Step 2: Read and decode image ---
      Uint8List imageBytes = await _imageFile!.readAsBytes();
      img.Image? originalImage = img.decodeImage(imageBytes);

      if (originalImage == null) {
        log('Error: Could not decode image.');
        setState(() => _loading = false);
        return;
      }

      // --- Step 3: Resize image ---
      img.Image resizedImage = img.copyResize(
        originalImage,
        width: _inputWidth,
        height: _inputHeight,
      );

      // --- Step 4: Normalize image ---
      var inputBytes = Float32List(1 * _inputWidth * _inputHeight * 3);
      int pixelIndex = 0;
      for (int y = 0; y < _inputHeight; y++) {
        for (int x = 0; x < _inputWidth; x++) {
          var pixel = resizedImage.getPixel(x, y);
          inputBytes[pixelIndex++] = pixel.r / 255.0;
          inputBytes[pixelIndex++] = pixel.g / 255.0;
          inputBytes[pixelIndex++] = pixel.b / 255.0;
        }
      }

      // --- Step 5: Reshape input ---
      var reshapedInput = List.generate(
        1,
        (_) => List.generate(
          _inputHeight,
          (j) => List.generate(_inputWidth, (k) {
            int index = j * _inputWidth * 3 + k * 3;
            return [
              inputBytes[index],
              inputBytes[index + 1],
              inputBytes[index + 2],
            ];
          }),
        ),
      );

      // --- Step 6: Run inference ---
      var output = List.generate(1, (_) => List<double>.filled(3, 0.0));
      log('Running inference...');
      _interpreter!.run(reshapedInput, output);
      log('Inference complete.');

      // --- Step 7: Update UI ---
      setState(() {
        _outputs = output[0];
        _loading = false;
      });

      log('Output probabilities: $_outputs');
    } catch (e) {
      log('Error running inference: $e');
      setState(() {
        _loading = false;
        _outputs = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء تحليل الصورة.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // --- Build UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pancreas Cancer Disease Detection',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal[700],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // --- Image Preview ---
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      _imageFile == null
                          ? Center(child: Text('No Image Selected'))
                          : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(_imageFile!, fit: BoxFit.cover),
                          ),
                ),
                SizedBox(height: 24),

                // --- Select Buttons ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal[600],
                      ),
                      icon: Icon(Icons.photo_library, color: Colors.white),
                      label: Text(
                        'Gallery',
                        style: TextStyle(color: Colors.white),
                      ),

                      onPressed: () => _pickImage(ImageSource.gallery),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal[600],
                      ),
                      icon: Icon(Icons.camera_alt, color: Colors.white),
                      label: Text(
                        'Camera',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () => _pickImage(ImageSource.camera),
                    ),
                  ],
                ),

                SizedBox(height: 24),

                // --- Analyze Button ---
                ElevatedButton(
                  onPressed:
                      (_imageFile != null && !_loading && _interpreter != null)
                          ? _runInference
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Analyze Image',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // --- Lottie Loading ---
                if (_loading)
                  Lottie.asset('assets/loading.json', width: 150, height: 150),

                // --- Results ---
                if (_outputs != null) _buildResults(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Widget to Build Results Display ---
  Widget _buildResults() {
    if (_outputs == null) return Container();

    int maxIndex = 0;
    double maxValue = _outputs![0];
    for (int i = 1; i < _outputs!.length; i++) {
      if (_outputs![i] > maxValue) {
        maxValue = _outputs![i];
        maxIndex = i;
      }
    }

    String resultLabel =
        (_labels != null && maxIndex < _labels!.length)
            ? _labels![maxIndex]
            : "Class $maxIndex";

    Color resultColor =
        (resultLabel.toLowerCase().contains("cancer") ||
                resultLabel.toLowerCase().contains("class 1"))
            ? Colors.redAccent
            : Colors.green;

    return Card(
      elevation: 4,
      margin: EdgeInsets.only(top: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              '🧬 Analysis Result:',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              resultLabel,
              style: TextStyle(
                fontSize: 20,
                color: resultColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Confidence: ${(maxValue * 100).toStringAsFixed(2)}%',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            Divider(),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '📊 Raw Probabilities:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 6),
            ..._outputs!.asMap().entries.map((entry) {
              int index = entry.key;
              double value = entry.value;
              String label = _labels![index];
              return Row(
                children: [
                  SizedBox(width: 20),
                  Text('$label: ${(value * 100).toStringAsFixed(2)}%'),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
