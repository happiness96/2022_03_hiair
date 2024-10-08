import 'package:flutter/material.dart';
import 'package:frontend/src/impeller/application/impeller/load/impeller_event.dart';
import 'package:frontend/src/impeller/dependency_injection.dart';
import 'package:frontend/src/impeller/presentation/viewmodels/impeller_list_notifier.dart';
import 'package:frontend/src/workorder/application/work_order/load/work_order_event.dart';
import 'package:frontend/src/workorder/dependency_injection.dart';
import 'package:frontend/src/workorder/presentation/viewmodels/work_order_list_notifier.dart';
import 'package:frontend/src/workorderCurrent/application/current_work_order_event.dart';
import 'package:frontend/src/workorderCurrent/presentation/dependency_injection.dart';
import 'package:frontend/src/workorderCurrent/presentation/viewmodels/current_work_order_list_notifier.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:async';

final textFieldControllerYard = TextEditingController();
final textFieldControllerHullNo = TextEditingController();

class SubAppBar extends ConsumerStatefulWidget implements PreferredSizeWidget {
  const SubAppBar({
    Key? key,
    required this.code,
  }) : super(key: key);

  final String code;

  @override
  ConsumerState<SubAppBar> createState() => _SubAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SubAppBarState extends ConsumerState<SubAppBar> {
  bool isButtonDisabled = false;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        children: <Widget>[
          Text(
            "Yard ",
            style: Theme.of(context).textTheme.headline6,
          ),
          const SizedBox(width: 20),
          Flexible(
            child: TextField(
              controller: textFieldControllerYard,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Yard',
              ),
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
          const SizedBox(width: 40),
          Text(
            "Hull No ",
            style: Theme.of(context).textTheme.headline6,
          ),
          const SizedBox(width: 20),
          Flexible(
            child: TextField(
              controller: textFieldControllerHullNo,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Hull No',
              ),
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
          ElevatedButton(
            child: const Icon(Icons.search),
            onPressed: () => _onTap(context, ref, textFieldControllerYard.text,
                textFieldControllerHullNo.text),
            style: ElevatedButton.styleFrom(
              primary: const Color.fromARGB(255, 68, 68, 68),
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 25),
            ),
          ),
          ElevatedButton(
            child: const Icon(
              Icons.refresh,
              color: Colors.black,
            ),
            onPressed: isButtonDisabled ? null : () => _onRefresh(context, ref),
            style: ElevatedButton.styleFrom(
              primary: Theme.of(context).scaffoldBackgroundColor,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
            ),
          ),
        ],
      ),
    );
  }

  void _onTap(
      BuildContext context, WidgetRef ref, String yard, String hullNo) async {
    ref.read(workOrderListNotifier.notifier).clear();
    ref.read(currentWorkOrderListNotifier.notifier).clear();
    ref.read(impellerListNotifier.notifier).clear();
    await searchListUpdate(ref);
  }

  Future<void> searchListUpdate(ref) async {
    if (widget.code == 'IMP') {
      await ref.read(impellerStateNotifierProvider.notifier).mapEventToState(
            ImpellerEvent.searchByYardHullNo(
              ref.watch(impellerListNotifier).items,
              ref.watch(impellerListNotifier).page,
              textFieldControllerYard.text,
              textFieldControllerHullNo.text,
            ),
          );
    } else if (widget.code == 'CURRENT_WORK_ORDER') {
      await ref
          .read(currentWorkOrderStateNotifierProvider.notifier)
          .mapEventToState(
            CurrentWorkOrderEvent.fetchCurrentWorkOrder(
              ref.watch(currentWorkOrderListNotifier).items,
              textFieldControllerYard.text,
              textFieldControllerHullNo.text,
            ),
          );
    } else {
      await ref.read(workOrderStateNotifierProvider.notifier).mapEventToState(
            WorkOrderEvent.searchByYardHullNo(
              ref.watch(workOrderListNotifier).items,
              ref.watch(workOrderListNotifier).page,
              textFieldControllerYard.text,
              textFieldControllerHullNo.text,
            ),
          );
    }
  }

  void _onRefresh(BuildContext context, WidgetRef ref) async {
    setState(() {
      isButtonDisabled = true;
    });

    ref.read(workOrderListNotifier.notifier).clear();
    ref.read(currentWorkOrderListNotifier.notifier).clear();
    ref.read(impellerListNotifier.notifier).clear();
    await refreshList(ref);

    Timer(const Duration(seconds: 5), () {
      setState(() {
        isButtonDisabled = false;
      });
    });
  }

  Future<void> refreshList(ref) async {
    if (widget.code == 'CURRENT_WORK_ORDER') {
      await ref
          .read(currentWorkOrderStateNotifierProvider.notifier)
          .mapEventToState(
            CurrentWorkOrderEvent.fetchCurrentWorkOrder(
              ref.watch(currentWorkOrderListNotifier).items,
              '',
              '',
            ),
          );
    } else if (widget.code == 'IMP') {
      await ref.read(impellerStateNotifierProvider.notifier).mapEventToState(
            ImpellerEvent.fetchListByPage(
              ref.watch(impellerListNotifier).items,
              ref.watch(impellerListNotifier).page,
            ),
          );
    } else if (widget.code == 'IMP_SINGLE') {
      await ref.read(impellerStateNotifierProvider.notifier).mapEventToState(
            ImpellerEvent.fetchSingleListByPage(
              ref.watch(impellerListNotifier).items,
              ref.watch(impellerListNotifier).page,
            ),
          );
    } else {
      await ref.read(workOrderStateNotifierProvider.notifier).mapEventToState(
            WorkOrderEvent.fetchListByPage(
              ref.watch(workOrderListNotifier).items,
              ref.watch(workOrderListNotifier).page,
            ),
          );
    }
  }
}
