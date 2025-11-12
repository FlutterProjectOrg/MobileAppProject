import 'package:flutter/material.dart';
import 'package:mobile_app_project/Pages/UI/AppColors.dart';
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

class CustomForm extends StatefulWidget {
  final List<FormField> fields;
  final String? submitLabel;
  final VoidCallback? onSubmit;
  final VoidCallback? onCancel;

  const CustomForm({
    Key? key,
    required this.fields,
    this.submitLabel,
    this.onSubmit,
    this.onCancel,
  }) : super(key: key);

  @override
  State<CustomForm> createState() => _CustomFormState();
}

class _CustomFormState extends State<CustomForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryOrange.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryOrange.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...widget.fields.map((field) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: field.widget,
              );
            }),
            if (widget.onSubmit != null || widget.onCancel != null) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (widget.onCancel != null) ...[
                    OutlinedButton(
                      onPressed: widget.onCancel,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: AppColors.primaryOrange.withOpacity(0.3),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                      ),
                      child: const Text(
                        'Annuler',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (widget.onSubmit != null)
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          widget.onSubmit!();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: AppColors.gradientPrimary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          child: Text(
                            widget.submitLabel ?? 'Soumettre',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class FormField {
  final Widget widget;

  FormField({required this.widget});
}
