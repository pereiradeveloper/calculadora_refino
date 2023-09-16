import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

void main() {
  runApp(const MaterialApp(
    home: CalculadoraRefinamentoMetais(),
    debugShowCheckedModeBanner: false,
  ));
}

class CalculadoraRefinamentoMetais extends StatefulWidget {
  const CalculadoraRefinamentoMetais({super.key});

  @override
  _CalculadoraRefinamentoMetaisState createState() => _CalculadoraRefinamentoMetaisState();
}

class _CalculadoraRefinamentoMetaisState extends State<CalculadoraRefinamentoMetais> {
  // Controladores para os campos de entrada
  TextEditingController ptController = TextEditingController();
  TextEditingController pdController = TextEditingController();
  TextEditingController rhController = TextEditingController();
  TextEditingController pesoController = TextEditingController();

  TextEditingController ptPurityController = TextEditingController(text: '0.724'); // Inicialize com o valor padrão
  TextEditingController pdPurityController = TextEditingController(text: '0.972'); // Inicialize com o valor padrão
  TextEditingController rhPurityController = TextEditingController(text: '3.280'); // Inicialize com o valor padrão

  MaskTextInputFormatter ptPurityMaskFormatter = MaskTextInputFormatter(
    mask: '#.###',
    filter: {"#": RegExp(r'[0-9]')},
  );

  MaskTextInputFormatter pdPurityMaskFormatter = MaskTextInputFormatter(
    mask: '#.###',
    filter: {"#": RegExp(r'[0-9]')},
  );

  MaskTextInputFormatter rhPurityMaskFormatter = MaskTextInputFormatter(
    mask: '#.###',
    filter: {"#": RegExp(r'[0-9]')},
  );

  void colarValores() async {
    ClipboardData? clipboardData = await Clipboard.getData(Clipboard.kTextPlain);

    if (clipboardData != null) {
      String textoColado = clipboardData.text ?? '';
      List<String> valores = textoColado.split(',');

      if (valores.length == 4) {
        setState(() {
          ptController.text = valores[0].trim();
          pdController.text = valores[1].trim();
          rhController.text = valores[2].trim();
          pesoController.text = valores[3].trim();
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    ptPurityController.addListener(() {
      final text = ptPurityController.text;
      if (text.length == 3 && !text.contains('.')) {
        // Adiciona automaticamente o ponto após três dígitos
        ptPurityController.text = '${text.substring(0, 3)}.${text.substring(3)}';
        ptPurityController.selection = TextSelection.fromPosition(
          TextPosition(offset: ptPurityController.text.length),
        );
      }
    });

    pdPurityController.addListener(() {
      final text = pdPurityController.text;
      if (text.length == 3 && !text.contains('.')) {
        pdPurityController.text = '${text.substring(0, 3)}.${text.substring(3)}';
        pdPurityController.selection = TextSelection.fromPosition(
          TextPosition(offset: pdPurityController.text.length),
        );
      }
    });

    // Para RH Purity
    rhPurityController.addListener(() {
      final text = rhPurityController.text;
      if (text.length == 3 && !text.contains('.')) {
        rhPurityController.text = '${text.substring(0, 3)}.${text.substring(3)}';
        rhPurityController.selection = TextSelection.fromPosition(
          TextPosition(offset: rhPurityController.text.length),
        );
      }
    });
  }

  @override
  void dispose() {
    ptPurityController.dispose();
    pdPurityController.dispose();
    rhPurityController.dispose();
    super.dispose();
  }

  _CalculadoraRefinamentoMetaisState() {
    ptPurityController = TextEditingController.fromValue(
      TextEditingValue(
        text: ptPurityController.text,
        selection: TextSelection.fromPosition(
          TextPosition(offset: ptPurityController.text.length),
        ),
      ),
    );
  }

  double taxaProcessamento = 0.0;

  String valorTotal = '0,000'; // Inicializado com zero e três casas decimais
  String taxaProcessamentoLabel = '0%';

  void calcularValorTotal() {
    double gramasPt = double.tryParse(ptController.text) ?? 0;
    double gramasPd = double.tryParse(pdController.text) ?? 0;
    double gramasRh = double.tryParse(rhController.text) ?? 0;
    double pesoQuilos = double.tryParse(pesoController.text) ?? 0;
    double taxa = taxaProcessamento / 100.0;

    double ptPurityValue = double.tryParse(ptPurityController.text) ?? 0.724; // Use o valor padrão se estiver vazio
    double pdPurityValue = double.tryParse(pdPurityController.text) ?? 0.972; // Use o valor padrão se estiver vazio
    double rhPurityValue = double.tryParse(rhPurityController.text) ?? 3.280; // Use o valor padrão se estiver vazio

    double valorPt = (gramasPt * ptPurityValue / 100);
    double valorPd = (gramasPd * pdPurityValue / 100);
    double valorRh = (gramasRh * rhPurityValue / 100);

    double valorTotalAntesDaTaxa = valorPt + valorPd + valorRh; // Convertendo quilos para gramas

    double totalComTaxa = valorTotalAntesDaTaxa * pesoQuilos * (1.0 - taxa);

    double totalFinal = totalComTaxa / 28.35 * 100;

    final formatador = NumberFormat("#,##0.000", "pt_BR");
    setState(() {
      valorTotal = formatador.format(totalFinal);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora de Refinamento'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 10),
              Row(
                children: [
                  SizedBox(
                    width: 90,
                    height: 40,
                    child: TextField(
                      inputFormatters: [ptPurityMaskFormatter],
                      controller: ptPurityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'PT',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(width: 1, color: Colors.blueGrey),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    width: 90,
                    height: 40,
                    child: TextField(
                      inputFormatters: [pdPurityMaskFormatter],
                      controller: pdPurityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'PD',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(width: 1, color: Colors.blueGrey),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    width: 90,
                    height: 40,
                    child: TextField(
                      inputFormatters: [rhPurityMaskFormatter],
                      controller: rhPurityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'RH',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(width: 1, color: Colors.blueGrey),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  Text(
                    'PT',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black.withOpacity(0.8)),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 300,
                    height: 40,
                    child: TextField(
                      textAlignVertical: TextAlignVertical.top,
                      controller: ptController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(width: 1, color: Colors.blueGrey),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    'PD',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black.withOpacity(0.8)),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 300,
                    height: 40,
                    child: TextField(
                      textAlignVertical: TextAlignVertical.top,
                      controller: pdController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(width: 1, color: Colors.blueGrey),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    'RH',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black.withOpacity(0.8)),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 300,
                    height: 40,
                    child: TextField(
                      textAlignVertical: TextAlignVertical.top,
                      controller: rhController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(width: 1, color: Colors.blueGrey),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    'Peso',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black.withOpacity(0.8)),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 286,
                    height: 40,
                    child: TextField(
                      textAlignVertical: TextAlignVertical.top,
                      controller: pesoController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(width: 1, color: Colors.blueGrey),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              // ... Seu código existente ...

              ElevatedButton(
                onPressed: () {
                  colarValores();
                },
                child: const Text('Colar Valores'),
              ),
              const SizedBox(height: 20.0),

// ... O restante do seu código ...

              Text(
                'Taxa de Processamento (-${taxaProcessamento.toStringAsFixed(0)}%):',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black.withOpacity(0.8),
                ),
              ),
              Row(
                children: [
                  SizedBox(
                    width: 300,
                    child: Slider(
                      activeColor: Colors.blueGrey,
                      value: taxaProcessamento,
                      onChanged: (newValue) {
                        setState(() {
                          taxaProcessamento = newValue;
                          taxaProcessamentoLabel = '${newValue.toStringAsFixed(0)}%';
                        });
                      },
                      min: 0,
                      max: 100,
                      divisions: 100,
                      label: '${taxaProcessamento.toStringAsFixed(0)}%',
                    ),
                  ),
                  Text(
                    taxaProcessamentoLabel,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 200,
                    height: 50,
                    child: ElevatedButton(
                      style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.blueGrey)),
                      onPressed: calcularValorTotal,
                      child: const Text('Calcular'),
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    height: 50,
                    child: ElevatedButton(
                      style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.black87)),
                      onPressed: () {
                        // Limpe todos os campos ao clicar
                        ptController.clear();
                        pdController.clear();
                        rhController.clear();
                        pesoController.clear();
                        setState(() {
                          valorTotal = '0,000'; // Reverta o valor para zero
                        });
                      },
                      child: const Text('Reiniciar'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              const Text('Valor Total Refinado:'),
              Text(
                '$valorTotal USD',
                style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
