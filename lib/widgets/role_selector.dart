import 'package:flutter/material.dart';
import '../utils/responsive.dart';

class RoleSelector extends StatelessWidget {
  final String selectedRole;
  final Function(String) onSelected;

  const RoleSelector({
    super.key,
    required this.selectedRole,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);
    final roles = ['Company', 'Supplier', 'Customer'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: roles.map((role) {
        final isSelected = role == selectedRole;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelected(role),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: r.wp(1)),
              padding: EdgeInsets.symmetric(vertical: r.hp(2)),
              decoration: BoxDecoration(
                color: isSelected ? Colors.grey.shade700 : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade600),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    role == 'Company'
                        ? Icons.apartment
                        : (role == 'Supplier'
                              ? Icons.local_shipping
                              : Icons.shopping_cart),
                    size: r.sp(18),
                    color: Colors.white70,
                  ),
                  SizedBox(height: r.hp(0.6)),
                  Text(
                    role,
                    style: TextStyle(fontSize: r.sp(12), color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
