import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:gl_nueip/bloc/user/user_cubit.dart';
import 'package:gl_nueip/core/models/user_model.dart';
import 'package:gl_nueip/core/utils/show_toast.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class InfoForm extends StatelessWidget {
  const InfoForm({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ShadFormState> formKey = GlobalKey<ShadFormState>();

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
              onPressed: () {
                final User user = User(
                  company: formKey.currentState!.value['company'] as String,
                  name: formKey.currentState!.value['name'] as String,
                  id: formKey.currentState!.value['id'] as String,
                  password: formKey.currentState!.value['password'] as String,
                );
                if (formKey.currentState!.saveAndValidate()) {
                  context.read<UserCubit>().saveAll(
                        company: user.company.isNotEmpty ? user.company : null,
                        name: user.name.isNotEmpty ? user.name : null,
                        userId: user.id.isNotEmpty ? user.id : null,
                        password:
                            user.password.isNotEmpty ? user.password : null,
                      );
                  showToast('change_action.changed'.tr(),
                      Colors.brown.withOpacity(0.8));
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShadForm(
              key: formKey,
              child: BlocBuilder<UserCubit, UserState>(
                builder: (context, state) {
                  return Column(
                    children: [
                      ShadInputFormField(
                        id: 'company',
                        label: Text('form.company'.tr()),
                        placeholder: Text('placeholder.company'.tr()),
                      ),
                      ShadInputFormField(
                        id: 'name',
                        label: Text('form.name'.tr()),
                        placeholder: Text('placeholder.name'.tr()),
                      ),
                      ShadInputFormField(
                        id: 'id',
                        label: Text('form.id'.tr()),
                        placeholder: Text('placeholder.id'.tr()),
                      ),
                      ShadInputFormField(
                        id: 'password',
                        label: Text('form.password'.tr()),
                        placeholder: Text('placeholder.password'.tr()),
                        obscureText: true,
                      )
                    ],
                  );
                },
              ),
            ),
            const Gap(10),
          ],
        ),
      ),
    );
  }
}
