// In prompt_state.dart
import 'package:flutter/foundation.dart';

abstract class PromptState {}

class PromptInitial extends PromptState {}

class PromptGeneratingImageLoadState extends PromptState {}

class PromptGeneratingImageErrorState extends PromptState {
  final String error;
  PromptGeneratingImageErrorState(this.error);
}

class PromptGeneratingImageSuccessState extends PromptState {
  final Uint8List uint8list;
  PromptGeneratingImageSuccessState(this.uint8list);
}
