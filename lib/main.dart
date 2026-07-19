import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const DonationApp());
}

class DonationApp extends StatelessWidget {
  const DonationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Donate to Debraj',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green.shade700),
        useMaterial3: true,
      ),
      home: const DonationPage(),
    );
  }
}

class DonationPage extends StatefulWidget {
  const DonationPage({super.key});

  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  final TextEditingController _amountController = TextEditingController(
    text: '100',
  );
  final String _upiId = 'debrajpratihar@jio';
  final String _payeeName = 'Debraj Pratihar';

  Future<void> _openUpiPayment() async {
    final amount = _amountController.text.trim();
    final parsedAmount = double.tryParse(amount);
    if (parsedAmount == null || parsedAmount <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount in rupees.')),
      );
      return;
    }

    final uri = Uri(
      scheme: 'upi',
      host: 'pay',
      queryParameters: {
        'pa': _upiId,
        'pn': _payeeName,
        'am': parsedAmount.toStringAsFixed(2),
        'cu': 'INR',
        'tn': 'Donation',
      },
    );

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No supported UPI app was opened. Install BHIM, PhonePe, Paytm or Google Pay and try again.',
          ),
        ),
      );
    }
  }

  String _buildUpiString() {
    final amount = _amountController.text.trim();
    final parsedAmount = double.tryParse(amount);
    if (parsedAmount == null || parsedAmount <= 0) {
      return 'upi://pay?pa=$_upiId&pn=$_payeeName&cu=INR&tn=Donation';
    }
    return 'upi://pay?pa=$_upiId&pn=$_payeeName&am=${parsedAmount.toStringAsFixed(2)}&cu=INR&tn=Donation';
  }

  void _showQrDialog() {
    showDialog<void>(
      context: context,
      builder: (context) {
        final upiString = _buildUpiString();
        return AlertDialog(
          title: const Text('Scan to pay'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QrImageView(data: upiString, version: QrVersions.auto, size: 220),
              const SizedBox(height: 12),
              Text('UPI ID: $_upiId'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donate to Debraj'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.volunteer_activism, size: 80, color: Colors.green),
            const SizedBox(height: 16),
            Text(
              'Support Debraj with a small donation',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'UPI ID: $_upiId',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount (₹)',
                border: OutlineInputBorder(),
                prefixText: '₹ ',
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _openUpiPayment,
              icon: const Icon(Icons.payment),
              label: const Text('Donate'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _showQrDialog,
              icon: const Icon(Icons.qr_code_2),
              label: const Text('Generate QR Code'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _openUpiPayment,
              child: const Text('Open UPI payment app'),
            ),
          ],
        ),
      ),
    );
  }
}
