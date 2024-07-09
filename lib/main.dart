// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

// ignore: unused_import
import 'dart:async';
import 'dart:convert';

import 'package:intl/intl.dart';

//const request = "https://api.hgbrasil.com/finance?format=json&key=60df7606";
const request = "https://api.hgbrasil.com/finance?key=00917df7";

void main() async {
  runApp(MaterialApp(
    home: CurrencyConverter(),
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          hintStyle: TextStyle(color: Colors.amber),
        )),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(Uri.parse(request));
  return json.decode(response.body);
}

class CurrencyConverter extends StatefulWidget {
  @override
  State<CurrencyConverter> createState() => _CurrencyConverterState();
}

class _CurrencyConverterState extends State<CurrencyConverter> {
  double? dolar;
  double? euro;

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  void _realChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double real = double.tryParse(text) as double;
    final formatter = new NumberFormat("#,##0.00", "pt_BR");
    realController.text = ("R\$ " + formatter.format(real / (dolar ?? 0)));
    realController.text = (real / (euro ?? 0)).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double dolar = double.tryParse(text) as double;
    realController.text = (dolar * (this.dolar ?? 0)).toStringAsFixed(2);
    euroController.text =
        (dolar * (this.dolar ?? 0) / (euro ?? 0)).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double euro = double.tryParse(text) as double;
    realController.text = (euro * (this.euro ?? 0)).toStringAsFixed(2);
    dolarController.text =
        (euro * (this.euro ?? 0) / (dolar ?? 0)).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("\$Conversor \$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return const Center(
                  child: Text(
                    "Carregando Dados...",
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 25,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              default:
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      "Erro ao carregar Dados...",
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 25,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else {
                  dolar = snapshot.data!["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data!["results"]["currencies"]["EUR"]["buy"];
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          Icons.monetization_on,
                          size: 150,
                          color: Colors.amber,
                        ),
                        buildTextField(
                            "Reais", "R\$", realController, _realChanged),
                        Divider(),
                        buildTextField(
                            "Dolar", "US\$", dolarController, _dolarChanged),
                        Divider(),
                        buildTextField(
                            "Euros", "€", euroController, _euroChanged)
                      ],
                    ),
                  );
                }
            }
          }),
    );
  }

  void _clearAll() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }
}

Widget buildTextField(String label, String prefix, TextEditingController coins,
    Function(String) converter) {
  return TextField(
    controller: coins,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.amber,
        ),
        border: OutlineInputBorder(),
        prefixText: prefix),
    style: TextStyle(color: Colors.amber, fontSize: 25),
    onChanged: converter,
    keyboardType: TextInputType.numberWithOptions(decimal: true),
  );
}
