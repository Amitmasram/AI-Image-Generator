import 'dart:async';
import 'dart:typed_data';
import 'package:ai_image_generator/features/prompt/bloc/prompt_state.dart';
import 'package:bloc/bloc.dart';
import 'package:ai_image_generator/features/prompt/repos/prompt_repo.dart';
import 'package:flutter/foundation.dart';

part 'prompt_event.dart';


class PromptBloc extends Bloc<PromptEvent, PromptState> {
  PromptBloc() : super(PromptInitial()) {
    on<PromptIntialEvent>(_onPromptInitialEvent);
    on<PromptEnteredEvent>(_onPromptEnteredEvent);
  }

  FutureOr<void> _onPromptInitialEvent(PromptIntialEvent event, Emitter<PromptState> emit) async {
    // You can remove this if you don't want to show an initial image
    // emit(PromptInitial());
  }

  FutureOr<void> _onPromptEnteredEvent(PromptEnteredEvent event, Emitter<PromptState> emit) async {
    emit(PromptGeneratingImageLoadState());
    try {
      final Uint8List? bytes = await PromptRepo.generateImage(event.prompt);
      if (bytes != null) {
        emit(PromptGeneratingImageSuccessState(bytes));
      } else {
        emit(PromptGeneratingImageErrorState("Failed to generate image"));
      }
    } catch (e) {
      emit(PromptGeneratingImageErrorState(e.toString()));
    }
  }
}
