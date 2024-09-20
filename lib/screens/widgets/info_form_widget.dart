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
    void savaUserInfo() {
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
              onPressed: () => formKey.currentState!.reset(),
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
            builder: (_, state) {
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

  List<Widget> _buildFormFields() {
    final ValueNotifier<bool> obscure = ValueNotifier(false);

    return [
      ShadInputFormField(
        id: 'name',
        label: Text('form.name'.tr()),
        placeholder: Text('placeholder.name'.tr()),
      ),
      ShadInputFormField(
        id: 'company',
        label: Text('form.company'.tr()),
        placeholder: Text('placeholder.company'.tr()),
      ),
      ShadInputFormField(
        id: 'id',
        label: Text('form.id'.tr()),
        placeholder: Text('placeholder.id'.tr()),
      ),
      ValueListenableBuilder(
        valueListenable: obscure,
        builder: (BuildContext context, value, Widget? child) {
          return ShadInputFormField(
            id: 'password',
            label: Text('form.password'.tr()),
            placeholder: Text('placeholder.password'.tr()),
            obscureText: obscure.value,
            suffix: ShadButton.ghost(
              width: 20,
              height: 20,
              onPressed: () => obscure.value = !obscure.value,
              icon: Icon(
                obscure.value
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 20,
                color: Colors.grey,
              ),
            ),
          );
        },
      )
    ];
  }
}
