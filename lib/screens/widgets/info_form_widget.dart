import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:gl_nueip/bloc/user/user_cubit.dart';
import 'package:gl_nueip/core/utils/show_toast.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class InfoForm extends StatelessWidget {
  const InfoForm({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ShadFormState> formKey = GlobalKey<ShadFormState>();
    savaUserInfo() {
      if (formKey.currentState!.saveAndValidate()) {
        final formData = formKey.currentState!.value;
        context.read<UserCubit>().saveAll(
              company: (formData['company'] as String?)?.isNotEmpty == true
                  ? formData['company'] as String
                  : null,
              name: (formData['name'] as String?)?.isNotEmpty == true
                  ? formData['name'] as String
                  : null,
              userId: (formData['id'] as String?)?.isNotEmpty == true
                  ? formData['id'] as String
                  : null,
              password: (formData['password'] as String?)?.isNotEmpty == true
                  ? formData['password'] as String
                  : null,
            );
        showToast('change_action.changed'.tr(), Colors.brown.withOpacity(0.8));
        Navigator.pop(context);
      }
    }

    return Align(
      child: ShadCard(
        backgroundColor: Colors.grey[800]!.withOpacity(0.15),
        border: ShadBorder.none,
        footer: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ShadButton.secondary(
              width: 100,
              child: Text('button.clear'.tr()),
              onPressed: () {
                formKey.currentState!.reset();
              },
            ),
            ShadButton(
              width: 100,
              child: Text('button.save'.tr()),
              onPressed: () => savaUserInfo(),
            ),
          ],
        ),
        child: FormFields(formKey: formKey),
      ),
    );
  }
}

class FormFields extends StatelessWidget {
  final GlobalKey<ShadFormState> formKey;

  const FormFields({super.key, required this.formKey});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShadForm(
          key: formKey,
          child: BlocBuilder<UserCubit, UserState>(
            builder: (context, state) {
              return Column(
                children: _buildFormFields(),
              );
            },
          ),
        ),
        const Gap(10),
      ],
    );
  }

  List<ShadInputFormField> _buildFormFields() {
    final List<Map<String, dynamic>> fields = [
      {'id': 'name', 'label': 'form.name', 'placeholder': 'placeholder.name'},
      {
        'id': 'company',
        'label': 'form.company',
        'placeholder': 'placeholder.company'
      },
      {'id': 'id', 'label': 'form.id', 'placeholder': 'placeholder.id'},
      {
        'id': 'password',
        'label': 'form.password',
        'placeholder': 'placeholder.password',
        'obscureText': true
      },
    ];
    return fields.map((field) {
      return ShadInputFormField(
        id: field['id'],
        label: Text(field['label']).tr(),
        placeholder: Text(field['placeholder']).tr(),
        obscureText: field['obscureText'] ?? false,
      );
    }).toList();
  }
}
