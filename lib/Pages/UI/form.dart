import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Contexte du champ de formulaire
class FormFieldContext<T> {
  final String name;
  T? value;
  String? error;

  FormFieldContext({required this.name, this.value, this.error});
}

/// Formulaire principal
class FormProviderWidget extends StatelessWidget {
  final Widget child;
  final GlobalKey<FormState> formKey;

  const FormProviderWidget({
    Key? key,
    required this.child,
    required this.formKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(key: formKey, child: child);
  }
}

/// Form Item Widget
class FormItem extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const FormItem({Key? key, required this.child, this.padding})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 8),
      child: child,
    );
  }
}

/// Form Label
class FormLabel extends StatelessWidget {
  final String text;
  final String fieldName;

  const FormLabel({Key? key, required this.text, required this.fieldName})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fieldContext = Provider.of<FormFieldContext>(context);
    final hasError = fieldContext.error != null;

    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: hasError ? Colors.red : Colors.black,
      ),
    );
  }
}

/// Form Control (TextField)
class FormControl extends StatelessWidget {
  final String fieldName;
  final TextEditingController controller;

  const FormControl({
    Key? key,
    required this.fieldName,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fieldContext = Provider.of<FormFieldContext>(context);

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        errorText: fieldContext.error,
      ),
      onChanged: (value) {
        fieldContext.value = value;
      },
    );
  }
}

/// Form Description
class FormDescription extends StatelessWidget {
  final String text;

  const FormDescription({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 12, color: Colors.grey));
  }
}

/// Form Message (erreur)
class FormMessage extends StatelessWidget {
  final String fieldName;

  const FormMessage({Key? key, required this.fieldName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fieldContext = Provider.of<FormFieldContext>(context);

    if (fieldContext.error == null) return const SizedBox.shrink();

    return Text(
      fieldContext.error!,
      style: const TextStyle(fontSize: 12, color: Colors.red),
    );
  }
}
