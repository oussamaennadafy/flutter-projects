import 'package:expense_tracker/app_state.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/shared/bottomSheets/add_expense_bottomSheet/index.dart';
import 'package:expense_tracker/shared/components/list_tiles/list_tile.dart';
import 'package:expense_tracker/theme/colors.dart';
import 'package:expense_tracker/utils/formaters/formate_date.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class SlidableItem extends StatefulWidget {
  const SlidableItem({
    super.key,
    required this.context,
    required this.item,
  });

  final BuildContext context;
  final Expense item;

  @override
  State<SlidableItem> createState() => _SlidableItemState();
}

class _SlidableItemState extends State<SlidableItem> {
  Future<void> handleDelete(Expense expense) async {
    // Get the ApplicationState instance
    final applicationState = Provider.of<ApplicationState>(context, listen: false);
    // Call and await addExpense
    await applicationState.deleteExpense(expense);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense deleted successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            backgroundColor: AppColors.green,
            icon: Icons.edit,
            label: "edit",
            onPressed: (context) {
              ExpenseBottomSheet.edit(context, widget.item);
            },
            padding: const EdgeInsets.all(4.0),
          ),
          SlidableAction(
            backgroundColor: AppColors.red,
            icon: Icons.delete,
            label: "delete",
            onPressed: (context) {
              handleDelete(widget.item);
            },
            padding: const EdgeInsets.all(4.0),
          ),
        ],
      ),
      child: AppListTile(
        title: widget.item.title.toString(),
        icon: Icons.arrow_downward,
        iconBackgroundColor: AppColors.red,
        trailingTitle: widget.item.price.toString(),
        trailingSubTitle: formateDate(widget.item.timestamp),
        titleStyle: const TextStyle(
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }
}
