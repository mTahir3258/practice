import 'package:flutter/material.dart';
import 'package:inward_outward_management/utils/app_colors.dart';
import 'package:inward_outward_management/utils/responsive.dart';
import 'package:inward_outward_management/widgets/app_scaffold.dart';
import 'package:inward_outward_management/widgets/primary_button.dart';

class CustomerPaymentScreen extends StatelessWidget {
  final String customerName;
  final String invoiceId;
  final double amount;
  final String materialName;
  final double quantity;
  final String unitName;
  final double ratePerUnit;

  const CustomerPaymentScreen({
    super.key,
    required this.customerName,
    required this.invoiceId,
    required this.amount,
    required this.materialName,
    required this.quantity,
    required this.unitName,
    required this.ratePerUnit,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return AppScaffold(
      title: 'Customer Payment',
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(r.wp(4)),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.all(r.wp(4)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customer Payment',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: r.sp(15),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: r.hp(1.5)),
                    Text(
                      'Invoice #$invoiceId',
                      style: TextStyle(
                        color: AppColors.textLight.withOpacity(0.8),
                        fontSize: r.sp(11),
                      ),
                    ),
                    SizedBox(height: r.hp(0.4)),
                    Text(
                      'Amount to pay',
                      style: TextStyle(
                        color: AppColors.textLight.withOpacity(0.8),
                        fontSize: r.sp(11),
                      ),
                    ),
                    SizedBox(height: r.hp(0.8)),
                    Text(
                      '₹ ${amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: r.sp(24),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: r.hp(2)),
                    Container(
                      padding: EdgeInsets.all(r.wp(3)),
                      decoration: BoxDecoration(
                        color: AppColors.greyBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  materialName,
                                  style: TextStyle(
                                    color: AppColors.textLight,
                                    fontSize: r.sp(13),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: r.hp(0.4)),
                                Text(
                                  '${quantity.toStringAsFixed(2)} $unitName @ ₹ ${ratePerUnit.toStringAsFixed(2)}/$unitName',
                                  style: TextStyle(
                                    color: AppColors.textLight.withOpacity(0.8),
                                    fontSize: r.sp(10),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '₹ ${amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: AppColors.textLight,
                              fontSize: r.sp(13),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: r.hp(2.5)),
                    Text(
                      'Payment Options',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: r.sp(13),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: r.hp(1.2)),
                    _paymentOptionTile(
                      context,
                      r,
                      icon: Icons.credit_card,
                      label: 'Credit/Debit Card',
                    ),
                    _paymentOptionTile(
                      context,
                      r,
                      icon: Icons.qr_code_2,
                      label: 'UPI',
                    ),
                    _paymentOptionTile(
                      context,
                      r,
                      icon: Icons.account_balance,
                      label: 'Net Banking',
                    ),
                    SizedBox(height: r.hp(3)),
                    PrimaryButton(
                      label: 'Pay Now',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Payment flow not implemented'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _paymentOptionTile(
    BuildContext context,
    Responsive r, {
    required IconData icon,
    required String label,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.symmetric(
        horizontal: r.wp(3),
        vertical: r.hp(1.2),
      ),
      decoration: BoxDecoration(
        color: AppColors.greyBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textLight),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: r.sp(12),
              ),
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppColors.textLight,
          ),
        ],
      ),
    );
  }
}
