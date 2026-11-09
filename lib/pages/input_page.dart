
import 'package:flutter/material.dart';
import 'package:rpl2/helpers/size_helper.dart';
import 'package:rpl2/pages/output_page.dart';
import 'package:intl/intl.dart';

class BelajarForm extends StatefulWidget {
  const BelajarForm({super.key});

  @override
  State<BelajarForm> createState() => _BelajarFormState();
}

class _BelajarFormState extends State<BelajarForm> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController namaController = TextEditingController();
  TextEditingController tglLahirController = TextEditingController();

  String _jk = "";
  String? _jkError;
  String _pilihAgama = "";

  final List<String> agama = [
    "Islam",
    "Kristen",
    "Katolik",
    "Hindu",
    "Budha",
  ];

  @override
  void initState() {
    super.initState();
    tglLahirController.text = "";
  }

  @override
  void dispose() {
    namaController.dispose();
    tglLahirController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Belajar Form"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          color: Colors.blueGrey,
          child: Center(
            child: SingleChildScrollView(
              child: Card(
                elevation: 4,
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Formulir Biodata",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 18),

                        // Nama Lengkap
                        TextFormField(
                          controller: namaController,
                          decoration: const InputDecoration(
                            hintText: "Nama Lengkap",
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Input Nama';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 18),

                        // Jenis Kelamin
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Jenis Kelamin",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        Row(
                          children: [
                            Radio<String>(
                              value: "Laki-laki",
                              groupValue: _jk,
                              onChanged: (value) {
                                setState(() {
                                  _jk = value!;
                                  _jkError = null;
                                });
                              },
                            ),
                            const Text("Laki-laki"),

                            const SizedBox(width: 24),

                            Radio<String>(
                              value: "Perempuan",
                              groupValue: _jk,
                              onChanged: (value) {
                                setState(() {
                                  _jk = value!;
                                  _jkError = null;
                                });
                              },
                            ),
                            const Text("Perempuan"),
                          ],
                        ),

                        if (_jkError != null)
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 8,
                              top: 0,
                            ),
                            child: Text(
                              _jkError!,
                              style: const TextStyle(
                                color: Colors.red,
                              ),
                            ),
                          ),

                        const SizedBox(height: 18),

                        // Tanggal Lahir
                        TextFormField(
                          controller: tglLahirController,
                          decoration: const InputDecoration(
                            hintText: "Tanggal Lahir",
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Input Tanggal Lahir';
                            }
                            return null;
                          },
                          readOnly: true,
                          onTap: () async {
                            DateTime? pickedDate =
                                await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2100),
                            );

                            if (pickedDate != null) {
                              setState(() {
                                tglLahirController.text =
                                    DateFormat('yyyy-MM-dd')
                                        .format(pickedDate);
                              });
                            }
                          },
                        ),

                        const SizedBox(height: 18),

                        // Pilihan Agama
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: "Pilih Agama",
                            border: OutlineInputBorder(),
                          ),
                          items: agama.map((item) {
                            return DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _pilihAgama = value ?? "";
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Pilih Agama';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        // Tombol Simpan
                        SizedBox(
                          width: displayWidth(context) * 0.8,
                          height: displayHeight(context) * 0.075,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(24),
                                side: const BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            child: const Text(
                              "Simpan",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            onPressed: _submit,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Fungsi Submit
  void _submit() {
    final isValid = _formKey.currentState!.validate();

    if (_jk.isEmpty) {
      setState(() {
        _jkError = 'Pilih Jenis Kelamin';
      });
    }

    if (!isValid || _jk.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OutputFormScreen(
          nama: namaController.text,
          jk: _jk,
          tglLahir: tglLahirController.text,
          agama: _pilihAgama,
        ),
      ),
    );
  }
}
