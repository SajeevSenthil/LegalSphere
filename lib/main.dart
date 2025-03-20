import 'package:deepseek_client/deepseek_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_speech/generated/google/cloud/speech/v1/cloud_speech.pb.dart';
import 'package:google_speech/google_speech.dart' as googleSpeech;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:groq/groq.dart';
import 'dart:math';
import 'package:google_cloud_translation/google_cloud_translation.dart';
import 'package:flutter_regex/flutter_regex.dart';
import 'package:google_speech/speech_client_authenticator.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:cloud_text_to_speech/cloud_text_to_speech.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:deepseek_client/deepseek_client.dart' show DeepSeekClient;
import 'package:http/http.dart' as http;



void main() {
  // Initialize Gemini with the API key
  Gemini.init(apiKey: 'AIzaSyCm8KRWGJl7EExDiYlNwUFDNVTd_qdyXCE');

    const apiKey = String.fromEnvironment('DEEPSEEK_API_KEY');
    print("DEEPSEEK_API_KEY: $apiKey");
    runApp(const MyApp());

  // Remove this line as setToken method doesn't exist
  // DeepSeekClient.setToken('sk-4e5423e4c25d4967ab3e80a120d22b2e');

  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Legal Sphere',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.grey[900],
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  File? _selectedImage;
  late Groq _groq;
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> documents = [];
  List<Map<String, dynamic>> filteredDocuments = [];
  List<List<num>> documentVectors = [];
  bool isRecording = false;
  final _record = AudioRecorder();
  String? _audioFilePath;
  final player = AudioPlayer();

  final speechToText = googleSpeech.SpeechToText.viaServiceAccount(ServiceAccount.fromString(r'''
      {
      "type": "service_account",
      "project_id": "gen-lang-client-0781071786",
      "private_key_id": "1a6f738fcd1ba0c8c2a2ec6e206281af6e41e8b4",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC75TLC4H/FKS5Q\nKQ7JBGeKVIAWk9jXfXf5bc0vVM32xRz/bET3JbTPqffkbor0/22NZ4o6k6mmUzkp\naF20IDpgHwqybq8TlzZK/EEKqNkvbmPsvOymoNP//rlfr9sSvzxfMoDPLaRiGoOV\nY6XUKUzSnKrLh/zNli/8oaFOn2Ntpw5ctFknLamHYWKUUhI+77XusVYqGWQN4Soc\npANcfPew7Lu2YIipAJNCHDdSiDoNKKS4Aagm6k/hovWd1Egbr4pNQUhwjpLWkfSC\nfuV5qPkP16SaP+Tw6i+sGUzVR7j8MZ/Y/CWdK/uck1kO7c8CxYr2RZCISkx8QrYv\n+fCI9rSFAgMBAAECggEAVbiEBwo64G0gNuv0VdsPjbltUl+THwSb1oy0fnJ3IKze\nxNzVPdfS/KazdGDGPm3FwixJkN3LGRmAy5ZUoZfOagnfbHY4o3xqBZ294qoTo6L+\nLYQnhwF6lqDUW4Y0MQJT/a5hu6M8CpHEFESI5BkPdkqJVR+uQvDQ5bWrjN4Ek4JI\nd6u10jj6H4VwNxPpvQPAV0TQ5PLmXtUgNRtl2bL7s9P3Z2M97q5UKE/PmWnz2GMA\nIpLwesr3wXyt7TmsvPkwV+c1kuZpd6vEHC+2PqoTZTYdPz9vrFRkxtlXCdwsf21o\nt+9ZwwdIRHoZWpSzf56mYaiEHhWpkP9zX61p1RboBQKBgQD7jco4LN2Ebkr/mjs+\nt/0GCrGnZOwjinJe/a6l47k/r7GH+uth0u/qr14/zEmfi2f9fd35pVSuy+nlrNsL\ngRGtB9xpBIVe0mknDLlW65ZwFfp6KQfCUmAL5Khon29sT+rBZOtFeOp95Z9fKPNf\nvnBMfUZeKHV2+RxNPG/1INa1WwKBgQC/N18TPHC6wqFppHU5xLyl8yTVH0UCXx3N\nuvtDywFn2yZMw9Weanzk5Y43a/8ucOC7LjqRXxefsaLXBVirvmppX3YJKV8AXlwX\nf1iBaKldlJ7fRZ+cDvOduCF+2YsDrxg2ZqPOB4eG6ZhWOhNIBhfnm13CWbhKcKfX\nSD8KqzQDnwKBgQDDbPom/iPx2EWHoWhZZ1K4uOIfa7ZQPiRwS6C829d09Kd1PqhS\nzS76IdeUtL6VphXZx0kFwz2wtlY1yj46B8GVrT+8jniWm9x5K9dpAYlT9p8q/Gk8\nvAZF9xQmg4ZqnQOBz0dAJ5n0yMkxgnzgavCPW9upFsF69jjYgBVyWFq1dQKBgDRq\njFBsmAZKBg88ernsOT5QaX9WhAdDZZsYr3oE8wyyIUyXvj4fuL7SQmrk2t2zKZeF\n854X8BThj97bY1Qo7WiXN3cJdTZXp2z1hqBqvUqey/IuVrNj0dohOGVaYuYOoFeB\nSVPX8onEDPNOFiz/JpxhlZEKIR+exBOahVV6WtbHAoGBAN3DcNLwPHkjeWyj1Dvj\nEnnLDbRAfNdpuqffsGOXo49WBd7Ar1mrPJvxUGIN98qV9R7o6RyUiYdoqjm9MGdF\ngrmHooLYjBqmjKXJTZa45M5kftPuuFeBW0WmnZ9pMjA20h1Uw/VtZAk7zjlzrAdG\n9+fDbVDvORR6qyMEHt+J4cH1\n-----END PRIVATE KEY-----\n",
      "client_email": "legal-sphere@gen-lang-client-0781071786.iam.gserviceaccount.com",
      "client_id": "115671398490113124056",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/legal-sphere%40gen-lang-client-0781071786.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
      }
      '''));

  final translator = Translation(apiKey: 'AIzaSyDUvtkOPy1QdAJYZzBVjOjBBxnBgRyii10');

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Load JSON file from assets
    final jsonString = await DefaultAssetBundle.of(context).loadString('assets/train.json');
    documents = List<Map<String, dynamic>>.from(json.decode(jsonString));
    filteredDocuments = documents.where((doc) => doc.containsKey('Description') && doc['Description'] != null).toList();
    // print(documents);

    print("Hi");

    // Generate embeddings for each document using Gemini
    documentVectors = await Future.wait(filteredDocuments.map((doc) async {
      // print(doc);
      // print("Description: ${doc['Description']}");
      try {
        final embedding = await _embedTextToVector(doc['Description']);
        print("Processed embedding for: ${doc['Description']}");
        return embedding;
      } catch (e) {
        print("Error processing document: $e");
        return <double>[]; // Handle errors gracefully
      }
    }).toList());

    print("Hello");

    print("documents_list: $documentVectors");

    int emptyVectorsCount = documentVectors.where((vec) => vec.isEmpty).length;
    print("Number of empty vectors: $emptyVectorsCount");

    FlutterNativeSplash.remove();

    //Initialize Google TTS with the access token
    TtsGoogle.init(
      apiKey: "b759c9dd3c688ab5e7f22dadad252df8bdc02ff2",
      withLogs: true,
    );

  }

  Future<String> translateText(String text, String targetLanguage) async {
    try {
      final response = await translator.translate(text: text, to: targetLanguage);
      return response.translatedText;
    } catch (e) {
      print('Translation error: $e');
      return text;
    }
  }

  Future<String> detectLanguage(String text) async {
    if (text==''){
      return 'en';
    }
    try {
      final response = await translator.detectLang(text: text);
      return response.detectedSourceLanguage ?? 'en';
    } catch (e) {
      print('Language detection error: $e');
      return 'en';
    }
  }

  Future<void> _sendMessage(String prompt) async {

    // final dummytext = await translateText("Hi, how are you?", 'ta');
    // setState(() {
    //   _messages.add({'sender': 'bot', 'text': dummytext});
    // });

    final sourceLanguage = await detectLanguage(prompt);

    final translatedPrompt = sourceLanguage != 'en'
        ? await translateText(prompt, 'en')
        : prompt;

    print("Translated: $translatedPrompt");

    String extractedText = '';
    if (_selectedImage != null) {
      extractedText = await _sendImageToGemini(_selectedImage!);
    }

    setState(() {
      _messages.add({
        'sender': 'user',
        'text': prompt,
        'image': _selectedImage,
      });
      _selectedImage = null;
    });

    setState(() {
      _messages.add({'sender': 'bot', 'text': "Generating Response...."});
    });

    String combinedPrompt = extractedText.isNotEmpty
        ? "$extractedText $translatedPrompt"
        : translatedPrompt;

    // Find the best match document using cosine similarity
    final bestMatch = await _getBestMatchingDocument(combinedPrompt);

    print("Best Match: $bestMatch");

    final custom_instr = '''
    You are an expert in analyzing and providing actionable insights based on legal contexts. Your task is to identify the relevant laws under the Bharatiya Nyaya Sanhita (BNS) and the Indian Penal Code (IPC), explain them in simple terms, and, if applicable, provide detailed guidance for filing a case.

       Task:
      1. Applicable Laws:
         - Identify the relevant sections under BNS and IPC that address the situation.
         - Provide the name and section of the law.(explain the law statement in detailed way to the)
         - Summarize the offense or legal provision in simple terms, ensuring clarity for non-legal audiences.
         - Specify whether the offense is "Cognizable" or "Non-Cognizable."
         - State the punishments clearly, including imprisonment terms, fines, or other penalties.
      
      2. Filing a Complaint (If Applicable):
         - Provide a step-by-step guide for filing a legal complaint.
         - Include necessary details such as where to report, what information/documents to prepare, and whom to contact.
         - Provide specific links and helpline numbers, especially for cases involving women, minors, or heinous crimes.
           - Example Resources:
             - National Commission for Women (NCW): Visit [NCW Website](https://ncw.nic.in) or call 1091.
             - Tamil Nadu Helpline: Call 1098 for immediate assistance.
             - State-wise helpline directory: [State Helpline Directory](https://wcd.nic.in/).
      
      3. Actionable Summary:
         - Offer actionable recommendations for safety measures, preserving evidence, and seeking justice.
         - Provide links to legal aid organizations and non-profits for additional support.
         - Ensure that all guidance is specific, concise, and prioritized.
      
       Important Guidelines:
      - Avoid disclaimers or generic explanations about incomplete information.
      - Ensure punishments and penalties provided are accurate and up-to-date as per Indian law.
      - Format the response clearly, using bullet points or numbered lists for ease of understanding.
      - Include helpline details for cases involving women, children, or heinous crimes.''';

    final x = Color(0xffffffff);

    final input_to_deepseek = '''
    
    ${custom_instr}
        
    Current Scenario:
    ${combinedPrompt}
    
    Matching laws:
    ${bestMatch}
    ''';

    final response = await _sendMessageDeepseek(input_to_deepseek);

    print("Groq: $response");

    print("Length: ${response.length}");

    print("$sourceLanguage");

    final cleanedResponse = response.replaceAll(RegExp(r'[\*#]'), '');

    print("cleaned: $cleanedResponse");

    print("substring: ${cleanedResponse.substring(0,100)}");

    final finalResponse = sourceLanguage != 'en'
        ? await translateText(cleanedResponse, sourceLanguage) //substring(0,100)
        : response;

    print("final response: $finalResponse");

    // final cleanedResponse = finalResponse.replaceAll(RegExp(r'[\*#]'), '');

    setState(() {
      _messages.removeLast();
    });

    setState(() {
      _messages.add({'sender': 'bot', 'text': finalResponse});
    });

    texttoVoice(cleanedResponse, sourceLanguage);
  }

  Future<void> texttoVoice(String s, String lang) async {
    final voicesResponse = await TtsGoogle.getVoices();
    final voices = voicesResponse.voices;

    //Print all available voices
    print(voices);

    //Pick an English Voice
    final voice = voicesResponse.voices
        .where((element) => element.locale.code.startsWith("${lang}-"))
        .toList(growable: false)
        .first;

    final ttsParams = TtsParamsGoogle(
      voice: voice,
      audioFormat: AudioOutputFormatGoogle.mp3,
      text: s,
    );

    final ttsResponse = await TtsGoogle.convertTts(ttsParams);

    final audioBytes = ttsResponse.audio.buffer.asUint8List();
    print("Audio generated successfully!");

    await player.play(BytesSource(audioBytes));

  }

  Future<String> _sendImageToGemini(File image) async {
    try {
      final result = await Gemini.instance.textAndImage(
        text: '''
        Analyze the given image to determine if it depicts a situation involving harassment, assault, or any scenario that compromises a woman's security or personal safety. Ensure the output is specific and descriptive, suitable for retrieving relevant laws or resources using the RAG model. Follow these steps:

        Detection and Context:
        
        Analyze the image for visual cues indicating harassment, assault, or a violation of personal safety.
        Focus on body language, facial expressions, gestures, and physical dynamics to determine the nature of the situation.
        Output Requirements (if harassment or insecurity is detected):
        
        Category: Classify the scenario into one of the following categories: Assault, Harassment, Sexual Abuse, Eve-Teasing, or Coercion.
        Description: Provide a detailed and concise explanation of the scene, focusing on:
        The emotions and physical state of the woman (e.g., fear, distress, helplessness).
        The nature of the act (e.g., forceful actions, invasion of personal space).
        The dynamics between the individuals involved (e.g., controlling, aggressive, inappropriate).
        Avoid unnecessary or irrelevant details while ensuring clarity about the victim's insecurity.
        General Description (if no harassment/insecurity is detected):
        
        If the image does not depict harassment or insecurity, provide a brief, general description of the image.
        Do not attempt to force a category or include unwarranted inferences.
        Key Guidelines:
        
        Avoid assumptions beyond what is clearly visible in the image.
        Include information about clothing only if it contributes directly to the context of harassment or insecurity.
        The output must prioritize women's security and clearly identify scenarios requiring legal assistance.
        Output Format:
        
        Category: [Choose from Assault, Harassment, Sexual Abuse, Eve-Teasing, Coercion; leave blank for non-harassment images.]
        Description: [Detailed description emphasizing emotions, circumstances, and women's insecurity. For non-harassment images, provide a simple and general description.]

        ''', // Replace with your fixed text prompt
        images: [image.readAsBytesSync()],
      );
      var temp = result?.content?.parts?.last;
      if(temp is TextPart){
        return temp.text;
      }
      else{
        return '';
      }
    } catch (e) {
      print("Error extracting text from image: $e");
      return '';
    }
  }

  Future<List<num>> _embedTextToVector(String text) async {
    int max_tries = 10;
    while(max_tries>0) {
      try {
        final response = await Gemini.instance.embedContent(text);
        return response!;
      }
      catch (error) {
        print(error);
        max_tries=max_tries-1;
      }
    }
    //print("Hi");
    return [];
    // print(response);
  }

  Future<void> _selectImage() async {
    try {
      final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        setState(() {
          _selectedImage = File(pickedImage.path);
        });
      }
    } catch (e) {
      print("Error selecting image: $e");
    }
  }

  void _clearSelectedImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  // Cosine similarity function
  double _cosineSimilarity(List<num> vec1, List<num> vec2) {
    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;

    for (int i = 0; i < vec1.length; i++) {
      dotProduct += vec1[i] * vec2[i];
      normA += vec1[i] * vec1[i];
      normB += vec2[i] * vec2[i];
    }

    normA = sqrt(normA);
    normB = sqrt(normB);

    if (normA == 0.0 || normB == 0.0) {
      return 0.0;
    }

    return dotProduct / (normA * normB);
  }

  // Find the best match document using cosine similarity
  Future<String> _getBestMatchingDocument(String query) async{
    final queryVector = await _embedTextToVector(query);

    double highestSimilarity = -10000;
    double s_highestSimilarity = -10000;
    double t_highestSimilarity = -10000;
    int bestMatchIndex = -1;
    int s_bestMatchIndex = -1;
    int t_bestMatchIndex = -1;

    print("length : ${documentVectors.length}");

    for (int i = 1; i < documentVectors.length; i++) {
      if(documentVectors[i].isEmpty){
        continue;
      }
      print(documentVectors[i]);
      double similarity = _cosineSimilarity(queryVector, documentVectors[i]);
      print("$i : $similarity");
      if (similarity > highestSimilarity) {
        t_highestSimilarity = s_highestSimilarity;
        s_highestSimilarity = highestSimilarity;
        highestSimilarity = similarity;
        t_bestMatchIndex = s_bestMatchIndex;
        s_bestMatchIndex = bestMatchIndex;
        bestMatchIndex = i;
      }
      else if (similarity > s_highestSimilarity) {
        t_highestSimilarity = s_highestSimilarity;
        s_highestSimilarity = similarity;
        t_bestMatchIndex = s_bestMatchIndex;
        s_bestMatchIndex = i;
      }
      else if (similarity > s_highestSimilarity) {
        t_highestSimilarity = similarity;
        t_bestMatchIndex = i;
      }
    }

    // print("Best match $bestMatchIndex");
    print("Best Match: $bestMatchIndex : ${filteredDocuments[bestMatchIndex]}");

    if (bestMatchIndex != -1) {
      print("Returned correctly");
      return filteredDocuments[bestMatchIndex].toString() + "\n" +
          filteredDocuments[s_bestMatchIndex].toString() + "\n" +
          filteredDocuments[t_bestMatchIndex].toString(); // Return the best matching document text
    } else {
      print("Returned wrong 1");
      return "Not found";
    }
  }

  Future<String> _sendMessageDeepseek(String text) async {
    try {
      // Get the API key from dart-define or use the hardcoded value as fallback
      final apiKey = const String.fromEnvironment('DEEPSEEK_API_KEY',
          defaultValue: 'sk-4e5423e4c25d4967ab3e80a120d22b2e');

      // Create DeepSeek API URL and headers
      final url = Uri.parse('https://api.deepseek.com/v1/chat/completions');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      };

      // Prepare request body
      final body = jsonEncode({
        'model': 'deepseek-chat',
        'messages': [
          {
            'role': 'system',
            'content': text
          }
        ],
        'temperature': 0.7,
        'max_tokens': 1000
      });

      // Make HTTP request
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        return 'Error: Failed to get response from DeepSeek API';
      }
    } on Exception catch (error) {
      print(error);
      return "Deepseek Error: $error";
    }
  }

  Future<void> requestPermissions() async {
    await Permission.microphone.request();
    await Permission.storage.request();
  }

  Future<void> transcribe(String filePath) async {

    final config = googleSpeech.RecognitionConfig(
        encoding: googleSpeech.AudioEncoding.LINEAR16,
        model: googleSpeech.RecognitionModel.basic,
        enableAutomaticPunctuation: true,
        sampleRateHertz: 16000,
        languageCode: 'en-US');

    final audio = await File(filePath).readAsBytes();
    final response = await speechToText.recognize(config, audio);

    final transcript = response.results
        .map((result) => result.alternatives.first.transcript)
        .join('\n');

    setState(() {
      _controller.text = transcript;
    });
  }

  Future<void> _startRecording() async {
    if (await _record.hasPermission()) {
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = '${tempDir.path}/audio.wav';

      await _record.start(
        const RecordConfig(),
        path: tempPath, // File path to save the recording
      );

      setState(() {
        _audioFilePath = tempPath;
      });
    }
  }
  //
  Future<void> _stopRecording() async {
    final path = await _record.stop();
    setState(() {
      _audioFilePath = path;
    });

    if (_audioFilePath != null) {
      await transcribe(_audioFilePath!);
    }
  }

  void handleMicButton() async {
    if (isRecording) {
      final recordedFile = await _stopRecording();
      setState(() => isRecording = false);

    } else {
      await _startRecording();
      setState(() => isRecording = true);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/Logo_inv.png', height: 50, width: 50),
            const SizedBox(width: 10,),
            const Text(
              'LegalSphere',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: Colors.grey[900],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment: message['sender'] == 'user'
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width*0.8,),
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (message['image'] != null)
                          Image.file(
                            message['image'],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        if (message['text'] != null)
                          Text(
                            message['text'],
                            style: const TextStyle(color: Colors.white),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_selectedImage != null)
            Container(
              margin: const EdgeInsets.all(8.0),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Image.file(
                    _selectedImage!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Image selected",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: _clearSelectedImage,
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter your message...',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.image, color: Colors.white),
                  onPressed: _selectImage,
                ),
                IconButton(
                  icon: Icon(isRecording ? Icons.mic_off : Icons.mic),
                  color: isRecording ? Colors.white : Colors.white,
                  onPressed: handleMicButton,
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: () {
                    if (_controller.text.isNotEmpty || _selectedImage != null) {
                      _sendMessage(_controller.text);
                      _controller.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
