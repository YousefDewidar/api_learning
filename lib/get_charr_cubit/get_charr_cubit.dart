import 'package:api_learning/api_service.dart';
import 'package:api_learning/char/char.dart';
import 'package:api_learning/get_charr_cubit/get_charr_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GetCharrCubit extends Cubit<GetCharrState> {
  GetCharrCubit() : super(GetCharrInitial());

  void getCharrList() async {
    List<Charr> charr = [];
    emit(GetCharrLoading());
    try {
      final data = await ApiService.getData(endPoint: "characters") as List;
      for (var element in data) {
        charr.add(Charr.fromJson(element));
      }
      emit(GetCharrSuccess(charr: charr));
    } catch (e) {
      emit(GetCharrError(message: e.toString()));
    }
  }


}
// State cubit
// Cubit class

// function getCharrList

// Provide cubit on HomeView
// Trigger function

// 
