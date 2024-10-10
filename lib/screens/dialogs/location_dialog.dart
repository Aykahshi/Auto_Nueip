import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gl_nueip/bloc/cubit.dart';
import 'package:gl_nueip/core/models/location_model.dart';
import 'package:gl_nueip/core/services/location_service.dart';
import 'package:gl_nueip/core/utils/injection_container.dart';
import 'package:gl_nueip/core/utils/show_toast.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class LocationDialog extends StatefulWidget {
  const LocationDialog({super.key});

  @override
  State<LocationDialog> createState() => _LocationDialogState();
}

class _LocationDialogState extends State<LocationDialog> {
  late TextEditingController textController = TextEditingController();
  final LocationCubit locationCubit = locator<LocationCubit>();

  @override
  void initState() {
    super.initState();
    locationCubit.loadLocation();
  }

  @override
  void dispose() {
    super.dispose();
    textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ShadThemeData theme = ShadTheme.of(context);
    final LocationService locationService = locator<LocationService>();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: ShadDialog(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        gap: 20,
        title: Text('change_action.location', style: theme.textTheme.h4).tr(),
        alignment: Alignment.center,
        titleTextAlign: TextAlign.center,
        actionsAxis: Axis.horizontal,
        actionsMainAxisAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          ShadButton.secondary(
            width: 100,
            child: const Text('button.clear').tr(),
            onPressed: () {
              textController.clear();
              locationCubit.clearLocation();
            },
          ),
          ShadButton(
            width: 100,
            child: const Text('button.save').tr(),
            onPressed: () async {
              final String address = textController.text.trim();
              final Location? location =
                  await locationService.convertAddress(address: address);
              locationCubit.saveLocation(location: location!, address: address);
              showToast(
                'change_action.location_changed'.tr(),
                Colors.green.withOpacity(0.7),
              );
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
          ),
        ],
        child: BlocBuilder<LocationCubit, LocationState>(
          builder: (context, state) {
            textController = TextEditingController(
                text: state is LocationHasValue
                    ? state.address.replaceAll('"', '')
                    : '');

            return ShadInput(
              controller: textController,
              placeholder: const Text('placeholder.address').tr(),
            );
          },
        ),
      ),
    );
  }
}
