import 'package:printing_practice/models/data_model.dart';

class GetModels {
  const GetModels();

  List<DataModel> getModels() {
    final data =
        List<DataModel>.filled(5, DataModel(id: 1, name: 'Azamov Avaz', count: 10, amount: 100));

    return data;
  }
}
