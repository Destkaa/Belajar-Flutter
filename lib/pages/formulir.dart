import 'package:flutter/material.dart';

class Formulir extends StatefulWidget {
   Formulir({super.key});

  @override
  State<Formulir> createState() => _FormulirState();
}

class _FormulirState extends State<Formulir> {
  //memberikan akses global key untuk formulir
  final _formKey = GlobalKey<FormState>();
  // memberi variable (wadah) untuk textfield
  final TextEditingController _nameController = TextEditingController();
  String _OutputName = '';

  @override
  void dispose() {
  // setelah di submit nilai dari textfield akan terhapus
    _nameController.dispose();
    super.dispose();
  }

  void _submitForm() {
    //In a real app, you would typically send the form data to a server.
    print('Nama Lengkap: ${_nameController.text}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Nama Lengkap: ${_nameController.text}")),
    );
    setState(() {
      _OutputName = _nameController.text;
    });
    // dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('My Form App')),
        body: Center(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Enter your name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 10,),
                ElevatedButton(
                  onPressed: () {
                    print('Name: ${_nameController.text}');
                  },
                  child: const Text('Get Name'),
                ),
                const SizedBox(height: 10,),
                ElevatedButton(
                  onPressed: () {
                    _submitForm();
                  },
                  child: const Text('Submit'),
                ),
                Text(
                  'Name: ${_OutputName.isEmpty ? "-" : _OutputName}',
                  style: const TextStyle(fontSize: 16),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}