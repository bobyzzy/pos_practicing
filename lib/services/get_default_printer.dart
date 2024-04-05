import 'package:printing/printing.dart';

class GetDeafultPrinter {
  const GetDeafultPrinter();
    
  Future<Printer> getPrinters() async => await Printing.listPrinters().then((value) => value.first);
}
