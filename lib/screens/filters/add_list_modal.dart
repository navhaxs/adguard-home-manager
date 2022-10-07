import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddListModal extends StatefulWidget {
  final String type;
  final void Function({required String name, required String url}) onConfirm;

  const AddListModal({
    Key? key,
    required this.type,
    required this.onConfirm,
  }) : super(key: key);

  @override
  State<AddListModal> createState() => _AddListModalState();
}

class _AddListModalState extends State<AddListModal> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController urlController = TextEditingController();
  String? urlError;

  bool validData = false;

  void checkValidValues() {
    if (nameController.text != '' && urlController.text != '') {
      setState(() => validData = true);
    }
    else {
      setState(() => validData = false);
    }
  }

  void validateUrl(String value) {
    final urlRegex = RegExp(r'^(https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|www\.[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9]+\.[^\s]{2,}|www\.[a-zA-Z0-9]+\.[^\s]{2,})$');
    if (urlRegex.hasMatch(value)) {
      setState(() => urlError = null);
    }
    else {
      final pathRegex = RegExp(r'^(((\\|\/)[a-z0-9^&@{}\[\],$=!\-#\(\)%\.\+~_]+)*(\\|\/))([^\\\/:\*\<>\|]+\.[a-z0-9]+)$');
      if (pathRegex.hasMatch(value)) {
        setState(() => urlError = null);
      }
      else {
        setState(() => urlError = AppLocalizations.of(context)!.urlNotValid);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        height: 408,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28)
          ),
          color: Theme.of(context).dialogBackgroundColor
        ),
        child: Column(
          children: [
            Icon(
              widget.type == 'whitelist'
                ? Icons.verified_user_rounded
                : Icons.gpp_bad_rounded,
              size: 26,
            ),
            const SizedBox(height: 20),
            Text(
              widget.type == 'whitelist'
                ? AppLocalizations.of(context)!.addWhitelist
                : AppLocalizations.of(context)!.addBlacklist,
              style: const TextStyle(
                fontSize: 24
              ),
            ),
            const SizedBox(height: 30),
            TextFormField(
              controller: nameController,
              onChanged: (_) => checkValidValues(),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.badge_rounded),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10)
                  )
                ),
                labelText: AppLocalizations.of(context)!.name,
              ),
            ),
            const SizedBox(height: 30),
            TextFormField(
              controller: urlController,
              onChanged: validateUrl,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.link_rounded),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10)
                  )
                ),
                errorText: urlError,
                labelText: AppLocalizations.of(context)!.urlAbsolutePath,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context), 
                        child: Text(AppLocalizations.of(context)!.cancel)
                      ),
                      const SizedBox(width: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          widget.onConfirm(
                            name: nameController.text,
                            url: urlController.text
                          );
                        }, 
                        child: Text(AppLocalizations.of(context)!.confirm)
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}