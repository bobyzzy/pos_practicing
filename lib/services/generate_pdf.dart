import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class GeneratePdf {
  const GeneratePdf();

  Future<Uint8List> generatePdf(PdfPageFormat format, String title, BuildContext context) async {
    final _font = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    final _boldFont = await rootBundle.load('assets/fonts/Roboto-Bold.ttf');

    //for info of reciept
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

    //for table headers
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

    //for table content
    final List<Map<String, dynamic>> dataTableContent = [
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

    final pdf = pw.Document(
      theme: pw.ThemeData(
        defaultTextStyle: pw.TextStyle(
          font: pw.Font.ttf(_font),
          fontSize: 8,
          fontBold: pw.Font.ttf(_boldFont),
        ),
      ),
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: format,
        build: (context) => [
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: pw.Text(
              'Закрыть смену',
              style: pw.TextStyle(
                font: pw.Font.ttf(_boldFont),
                fontSize: 8,
              ),
            ),
          ),
          pw.Divider(color: PdfColor.fromHex('#F8F8F8')),
          pw.Center(
            child: pw.Text(
              title,
              style: pw.TextStyle(
                font: pw.Font.ttf(_boldFont),
                fontSize: 8,
              ),
            ),
          ),
          pw.Center(child: pw.Text('За смену')),
          pw.SizedBox(height: 5),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Expanded(
                flex: 5,
                child: pw.Text('От 10.01.2024 6:20:30', textAlign: pw.TextAlign.center),
              ),
              pw.SizedBox(width: 20),
              pw.Expanded(
                flex: 4,
                child: pw.Text('До 10.01.2024 6:20:30', softWrap: true),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Торг точка:'),
              pw.Text('SOLO MOBILE IZZA'),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Дата'),
              pw.Text('10.01.2024 21:00:30'),
            ],
          ),
          pw.SizedBox(height: 10),
          buildInfoList(jsonData),
          pw.SizedBox(height: 10),
          pw.Center(child: pw.Text('Отчет по видам оплат')),
          pw.SizedBox(height: 10),
          buildTable(paymentColumnHeaders, paymentData),
          pw.SizedBox(height: 10),
          pw.Center(child: pw.Text('Отчет сотрудникам')),
          pw.SizedBox(height: 10),
          buildTable(columnHeaders, dataTableContent),
          pw.SizedBox(height: 10),
          pw.Center(child: pw.Text('Отчет по подразделениям')),
          pw.SizedBox(height: 10),
          buildTable(columnHeaders, dataTableContent),
          pw.SizedBox(height: 10),
          pw.Center(child: pw.Text('Отчет по клиентам')),
          pw.SizedBox(height: 10),
          buildTable(columnHeaders, dataTableContent),
          pw.SizedBox(height: 10),
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget buildTitle(String string) {
    return pw.Text(string);
  }

  pw.Widget buildInfoList(Map<String, dynamic> jsonData) {
    return pw.SizedBox(
      height: 100,
      child: pw.ListView.builder(
        itemCount: jsonData.length,
        itemBuilder: (context, index) {
          return pw.Row(
            children: [
              pw.Expanded(
                flex: 2,
                child: pw.Text(jsonData.keys.elementAt(index)),
              ),
              pw.Expanded(
                flex: 3,
                child: pw.Text(jsonData.values.elementAt(index).toString()),
              ),
            ],
          );
        },
      ),
    );
  }

  pw.Widget buildTable(List<String> columnHeaders, List<Map<String, dynamic>> dataTableContent) {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: const pw.FixedColumnWidth(30),
      },
      children: [
        pw.TableRow(children: columnHeaders.map((headers) => buildHeaderCell(headers)).toList()),
        ...dataTableContent.map((data) => buildDataRow(data)),
      ],
    );
  }

  pw.TableRow buildDataRow(Map<String, dynamic> data) {
    return pw.TableRow(
      children: [
        pw.Center(child: pw.Text('${data["№"]}')),
        ...data.values.skip(1).map(
              (value) =>
                  pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(value.toString())),
            ),
      ],
    );
  }

  pw.Widget buildHeaderCell(String header) {
    return pw.Expanded(child: pw.Center(child: pw.Text(header)));
  }
}
