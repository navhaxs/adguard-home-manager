// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:adguard_home_manager/screens/filters/fab.dart';
import 'package:adguard_home_manager/screens/filters/remove_custom_rule_modal.dart';

import 'package:adguard_home_manager/models/filtering.dart';
import 'package:adguard_home_manager/providers/app_config_provider.dart';
import 'package:adguard_home_manager/services/http_requests.dart';
import 'package:adguard_home_manager/providers/servers_provider.dart';
import 'package:adguard_home_manager/classes/process_modal.dart';

class CustomRulesList extends StatefulWidget {
  final ScrollController scrollController;
  final List<String> data;
  final void Function() fetchData;

  const CustomRulesList({
    Key? key,
    required this.scrollController,
    required this.data,
    required this.fetchData
  }) : super(key: key);

  @override
  State<CustomRulesList> createState() => _CustomRulesListState();
}

class _CustomRulesListState extends State<CustomRulesList> {
  late bool isVisible;

  @override
  initState(){
    super.initState();
    
    isVisible = true;
    widget.scrollController.addListener(() {
      if (widget.scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        if (mounted && isVisible == true) {
          setState(() => isVisible = false);
        }
      } 
      else {
        if (widget.scrollController.position.userScrollDirection == ScrollDirection.forward) {
          if (mounted && isVisible == false) {
            setState(() => isVisible = true);
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);
    final appConfigProvider = Provider.of<AppConfigProvider>(context);

    void removeCustomRule(String rule) async {
      ProcessModal processModal = ProcessModal(context: context);
      processModal.open(AppLocalizations.of(context)!.updatingRules);

      final List<String> newRules = serversProvider.filtering.data!.userRules.where((r) => r != rule).toList();

      final result = await setCustomRules(server: serversProvider.selectedServer!, rules: newRules);

      processModal.close();

      if (result['result'] == 'success') {
        FilteringData filteringData = serversProvider.filtering.data!;
        filteringData.userRules = newRules;
        serversProvider.setFilteringData(filteringData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.ruleRemovedSuccessfully),
            backgroundColor: Colors.green,
          )
        );
      }
      else {
        appConfigProvider.addLog(result['log']);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.ruleNotRemoved),
            backgroundColor: Colors.red,
          )
        );
      }
    }

    void openRemoveCustomRuleModal(String rule) {
      showDialog(
        context: context, 
        builder: (context) => RemoveCustomRule(
          onConfirm: () => removeCustomRule(rule),
        )
      );
    }

    return Stack(
      children: [
        if (widget.data.isNotEmpty) ListView.builder(
          padding: const EdgeInsets.only(top: 0),
          itemCount: widget.data.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(widget.data[index]),
            trailing: IconButton(
              onPressed: () => openRemoveCustomRuleModal(widget.data[index]),
              icon: const Icon(Icons.delete)
            ),
          )
        ),
        if (widget.data.isEmpty) SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context)!.noBlackLists,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.grey
                ),
              ),
              const SizedBox(height: 30),
              TextButton.icon(
                onPressed: widget.fetchData, 
                icon: const Icon(Icons.refresh_rounded), 
                label: Text(AppLocalizations.of(context)!.refresh),
              )
            ],
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
          bottom: isVisible ? 20 : -70,
          right: 20,
          child: const FiltersFab(
            type: 'custom_rule',
          )
        )
      ],
    );
  }
}