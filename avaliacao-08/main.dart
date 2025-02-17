import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:brasil_fields/brasil_fields.dart'; // For CPF and real validation

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Formulário de Validação',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ValidationForm(),
    );
  }
}

class ValidationForm extends StatefulWidget {
  const ValidationForm({Key? key}) : super(key: key);

  @override
  _ValidationFormState createState() => _ValidationFormState();
}

class _ValidationFormState extends State<ValidationForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formulário de Validação'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Data (dd-mm-aaaa)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a data.';
                  }
                  if (!isValidDate(value)) {
                    return 'Por favor, insira uma data válida no formato dd-mm-aaaa.';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o email.';
                  }
                  if (!isValidEmail(value)) {
                    return 'Por favor, insira um email válido.';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'CPF'),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CpfInputFormatter(),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o CPF.';
                  }
                  if (!isValidCPF(value)) {
                    return 'Por favor, insira um CPF válido.';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Valor'),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  RealInputFormatter(),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o valor.';
                  }
                  if (!isValidReal(value)) {
                    return 'Por favor, insira um valor válido.';
                  }
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Formulário válido!')),
                      );
                    }
                  },
                  child: const Text('Validar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool isValidDate(String date) {
    try {
      DateFormat('dd-MM-yyyy').parseStrict(date);
      return true;
    } catch (e) {
      return false;
    }
  }

  bool isValidEmail(String email) {
    return RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
        .hasMatch(email);
  }

  bool isValidCPF(String cpf) {
    return CPFValidator.isValid(cpf);
  }

  bool isValidReal(String real) {
    // Remove dots and commas to parse as a double
    String cleanedReal = real.replaceAll(RegExp(r'[^\d]'), '');

    // Ensure there are at least three digits (e.g., 001 = 0.01)
    if (cleanedReal.length < 3) {
      return false;
    }

    // Pad with leading zeros if necessary
    while (cleanedReal.length < 3) {
      cleanedReal = '0' + cleanedReal;
    }

    // Split into integer and decimal parts
    String integerPart = cleanedReal.substring(0, cleanedReal.length - 2);
    String decimalPart = cleanedReal.substring(cleanedReal.length - 2);

    try {
      double value = double.parse('$integerPart.$decimalPart');
      return value >= 0; // Ensure it's a non-negative value
    } catch (e) {
      return false;
    }
  }
}
