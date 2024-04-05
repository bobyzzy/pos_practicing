// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:printing_practice/bloc/reciept_cubit.dart';
import 'package:printing_practice/bloc/reciept_state.dart';
import 'package:printing_practice/services/get_default_printer.dart';
import 'package:printing_practice/services/generate_pdf.dart';

const getPrinter = GetDeafultPrinter();
const generatePdf = GeneratePdf();

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => RecieptCubit(),
        ),
      ],
      child: MaterialApp(
        scrollBehavior: const ScrollBehavior().copyWith(scrollbars: false),
        home: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<RecieptCubit, RecieptState>(
        listener: (context, state) {
          if (state is RecieptOpened) {
            showDialog(
              context: context,
              builder: (context) {
                return const Dialog(
                  elevation: 0,
                  child: CustomModal(),
                );
              },
            );
          }
        },
        child: Center(
          child: ElevatedButton(
            onPressed: () {
              context.read<RecieptCubit>().openModalView();
            },
            child: const Text('Open Modal View'),
          ),
        ),
      ),
    );
  }
}

class CustomModal extends StatelessWidget {
  const CustomModal({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<RecieptCubit, RecieptState>(
      listener: (context, state) {
        if (state is RecieptPrinted) {
          print('reciept Printing');
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
        ),
        width: MediaQuery.of(context).size.width * 0.3,
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 48),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Закрыть смену',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
              const Divider(),
              const Center(
                child: Text(
                  'Итоговый отчет',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text('За смену', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 5),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 5,
                    child: Text('От 10.01.2024 6:20:30', textAlign: TextAlign.center),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    flex: 4,
                    child: Text('До 10.01.2024 6:20:30', softWrap: true),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Торг точка:'),
                  Text('SOLO MOBILE IZZA'),
                ],
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Дата'),
                  Text('10.01.2024 21:00:30'),
                ],
              ),
              InfoShiftReport(jsonData: jsonData),
              const Center(
                child: Text(
                  'Отчет по видам оплат',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              const SizedBox(height: 10),
              MyDataTable(columnHeaders: paymentColumnHeaders, jsonData: paymentData),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  'Отчет по подразделениям',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              const SizedBox(height: 10),
              MyDataTable(columnHeaders: columnHeaders, jsonData: dataTablejson),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  'Отчет сотрудникам',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              const SizedBox(height: 10),
              MyDataTable(columnHeaders: columnHeaders, jsonData: dataTablejson),
              const SizedBox(height: 10),
              const Center(
                child: Text('Отчет по клиентам',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              ),
              MyDataTable(columnHeaders: columnHeaders, jsonData: dataTablejson),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      onPressed: () async {
                        context.read<RecieptCubit>().printReciept();
                        Printing.directPrintPdf(
                          printer: await getPrinter.getPrinters(),
                          onLayout: (format) => generatePdf.generatePdf(format, 'asdas', context),
                        );
                      },
                      child: const Text('Печатать')),
                  ElevatedButton(onPressed: () {}, child: const Text('Назад')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoShiftReport extends StatelessWidget {
  final Map<String, dynamic> jsonData;
  const InfoShiftReport({super.key, required this.jsonData});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.2,
      child: ListView.builder(
        itemCount: jsonData.length,
        itemBuilder: (context, index) {
          return Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(jsonData.keys.elementAt(index)),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  jsonData.values.elementAt(index).toString(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class MyDataTable extends StatelessWidget {
  final List<String> columnHeaders;
  final List<Map<String, dynamic>> jsonData;
  const MyDataTable({super.key, required this.columnHeaders, required this.jsonData});
  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(color: const Color.fromRGBO(233, 234, 236, 1)),
      columnWidths: const {
        0: FixedColumnWidth(30),
      },
      children: [
        // Заголовок таблицы
        TableRow(children: columnHeaders.map((header) => _buildHeaderCell(header)).toList()),
        // Строки данных
        ...jsonData.map((data) => _buildDataRow(data)),
      ],
    );
  }

  Widget _buildHeaderCell(String header) {
    return Expanded(
        child: Center(
      child: Text(header),
    ));
  }

  TableRow _buildDataRow(Map<String, dynamic> data) {
    return TableRow(
      children: [
        Center(child: Text('${data['№']}')),
        ...data.values.skip(1).map((value) => Padding(
              padding: const EdgeInsets.all(5),
              child: Text(value.toString()),
            )),
      ],
    );
  }
}

final Map<String, dynamic> jsonData = {
  'Всего счетов:': 1,
  'Позиции заказов:': 20,
  'Чеков с отказом': 0,
  'Позиций отказов:': 8,
  'Сумма отказов:': 8,
  'Гостей:': 9,
  'Переносов:': 8,
  'Разблокировок': 8,
};

final List<Map<String, dynamic>> dataTablejson = [
  {
    '№': 1,
    'Клиент': 'Бекзод ака',
    'Сч-в': 3,
    'Зак': 43,
    'Сумма': 123890,
    'Сумма без скидки': 126900,
  },
  {
    '№': 1,
    'Клиент': 'Бекзод ака',
    'Сч-в': 5,
    'Зак': 54,
    'Сумма': 368987,
    'Сумма без скидки': 466999,
  },
];

final List<String> columnHeaders = [
  '№',
  'Клиент',
  'Сч-в',
  'Зак',
  'Сумма',
  'Сумма без скидки',
];

final List<Map<String, dynamic>> paymentData = [
  {
    '№': 1,
    'Вид оплаты': 'Долг',
    'Сумма': 12900,
  },
  {
    '№': 2,
    'Вид оплаты': 'Наличными',
    'Сумма': 12900,
  },
];

final List<String> paymentColumnHeaders = ['№', 'Вид оплаты', 'Сумма'];
