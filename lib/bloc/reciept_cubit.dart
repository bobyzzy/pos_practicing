import 'package:bloc/bloc.dart';
import 'package:printing_practice/bloc/reciept_state.dart';

class RecieptCubit extends Cubit<RecieptState> {
  RecieptCubit() : super(RecieptClosed());

  void openModalView() {
    Future.delayed(const Duration(milliseconds: 300));
    emit(RecieptLoading());
    emit(RecieptOpened());
  }

  void closeModalView() {
    emit(RecieptLoading());
    emit(RecieptClosed());
  }

  void printReciept() {
    emit(RecieptPrinted());
  }
}
