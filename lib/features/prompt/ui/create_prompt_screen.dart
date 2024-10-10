import 'dart:io';
import 'dart:typed_data';
import 'package:ai_image_generator/features/prompt/bloc/prompt_bloc.dart';
import 'package:ai_image_generator/features/prompt/bloc/prompt_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class CreatePromptScreen extends StatefulWidget {
  const CreatePromptScreen({Key? key}) : super(key: key);

  @override
  State<CreatePromptScreen> createState() => _CreatePromptScreenState();
}

class _CreatePromptScreenState extends State<CreatePromptScreen> {
  final TextEditingController controller = TextEditingController();
  final PromptBloc promptBloc = PromptBloc();

  @override
  void initState() {
    super.initState();
    promptBloc.add(PromptIntialEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Generate Images🚀"),
      ),
      body: BlocConsumer<PromptBloc, PromptState>(
        bloc: promptBloc,
        listener: (context, state) {
          if (state is PromptGeneratingImageErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Error generating image")),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: _buildImageArea(state),
              ),
              _buildPromptInput(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImageArea(PromptState state) {
    if (state is PromptGeneratingImageLoadState) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is PromptGeneratingImageSuccessState) {
      return Stack(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: MemoryImage(state.uint8list),
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              onPressed: () => _downloadImage(state.uint8list),
              child: Icon(Icons.download),
            ),
          ),
        ],
      );
    } else {
      return const Center(child: Text("Enter a prompt to generate an image"));
    }
  }

  Widget _buildPromptInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Enter your prompt",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: "Describe the image you want to generate",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  promptBloc.add(PromptEnteredEvent(prompt: controller.text));
                }
              },
              child: const Text("Generate"),
            ),
          ),
        ],
      ),
    );
  }

void _downloadImage(Uint8List imageBytes) async {
  final success = await ImageDownloader.saveImage(imageBytes, context);
  if (success) {
    print('Image downloaded successfully');
  } else {
    print('Failed to download image');
  }
}

  @override
  void dispose() {
    controller.dispose();
    promptBloc.close();
    super.dispose();
  }
}

class ImageDownloader {
  static Future<bool> saveImage(Uint8List imageBytes, BuildContext context) async {
    try {
      // Request storage permission
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (status.isDenied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Storage permission is required to save images')),
          );
          return false;
        }
      }

      // Save image
      final result = await ImageGallerySaver.saveImage(
        imageBytes,
        quality: 100,
        name: "AI_Generated_Image_${DateTime.now().millisecondsSinceEpoch}.png",
      );

      if (result['isSuccess']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image saved to gallery successfully')),
        );
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save image')),
        );
        return false;
      }
    } catch (e) {
      print('Error saving image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while saving the image')),
      );
      return false;
    }
  }
}
