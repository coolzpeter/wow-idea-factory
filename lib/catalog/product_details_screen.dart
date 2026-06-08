import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final dbService = SupabaseService();

  // This tracks if the user has manually clicked the zoom buttons
  int? _userSelectedColumnCount;

  @override
  Widget build(BuildContext context) {
    final String productId = widget.product['id']?.toString() ?? '';
    final String productName =
        widget.product['product_name'] ?? 'Product Details';

    // 1. RESPONSIVE DESIGN: Calculate default columns dynamically
    final screenWidth = MediaQuery.of(context).size.width;
    // If screen is wider than 800px, default to 4. Otherwise, default to 2.
    final defaultColumns = screenWidth > 800 ? 4 : 2;

    // The actual columns we will show on screen
    final currentColumns = _userSelectedColumnCount ?? defaultColumns;

    return Scaffold(
      appBar: AppBar(title: Text(productName)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Available Designs',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.zoom_out),
                      tooltip: 'Show smaller items',
                      // Zooming OUT means MORE columns. Cap it at 6.
                      onPressed: currentColumns < 6
                          ? () => setState(
                              () =>
                                  _userSelectedColumnCount = currentColumns + 1,
                            )
                          : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.zoom_in),
                      tooltip: 'Show larger items',
                      // Zooming IN means FEWER columns. Cap it at 1.
                      onPressed: currentColumns > 1
                          ? () => setState(
                              () =>
                                  _userSelectedColumnCount = currentColumns - 1,
                            )
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: dbService.fetchDesignsForProduct(productId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final designs = snapshot.data;
                if (designs == null || designs.isEmpty) {
                  return const Center(
                    child: Text('No designs found for this product.'),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        currentColumns, // Uses our responsive variable
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: designs.length,
                  itemBuilder: (context, index) {
                    final design = designs[index];
                    return InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => QuantitySelectionDialog(
                            productId: productId,
                            designId: design['id'].toString(),
                            designName: design['design_code'] ?? 'Design',
                          ),
                        );
                      },
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Container(
                                color: Colors.grey.shade50,
                                // 2. PREVENT DOWNLOADS: The Stack and Transparent Shield
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    // Layer 1: The actual image
                                    Image.network(
                                      design['image_url'] ??
                                          'https://via.placeholder.com/150',
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                                Icons.image_not_supported,
                                                size: 40,
                                                color: Colors.grey,
                                              ),
                                    ),
                                    // Layer 2: The invisible shield that intercepts right-clicks
                                    Container(color: Colors.transparent),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              color: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12.0,
                                horizontal: 8.0,
                              ),
                              child: Text(
                                design['design_code'] ?? 'Unknown Code',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class QuantitySelectionDialog extends StatefulWidget {
  final String productId;
  final String designId;
  final String designName;

  const QuantitySelectionDialog({
    super.key,
    required this.productId,
    required this.designId,
    required this.designName,
  });

  @override
  State<QuantitySelectionDialog> createState() =>
      _QuantitySelectionDialogState();
}

class _QuantitySelectionDialogState extends State<QuantitySelectionDialog> {
  final _dbService = SupabaseService();
  bool _isLoading = true;
  int? _selectedQty;
  List<int> _qtyOptions = [];

  @override
  void initState() {
    super.initState();
    _loadMinimumQuantity();
  }

  Future<void> _loadMinimumQuantity() async {
    // 1. Fetch the exact minimum from your price_tiers table
    final minQty = await _dbService.fetchMinQuantity(widget.productId);

    // 2. Generate the scrolling list of 8 options (min, min+100, min+200, etc.)
    final List<int> options = [];
    for (int i = 0; i < 8; i++) {
      options.add(minQty + (i * 100));
    }

    if (mounted) {
      setState(() {
        _qtyOptions = options;
        _selectedQty = options.first; // Default to the minimum quantity
        _isLoading = false;
      });
    }
  }

  Future<void> _submitQuote() async {
    if (_selectedQty == null) return;

    // Close the dialog immediately
    Navigator.pop(context);

    try {
      await _dbService.requestQuote(widget.designId, _selectedQty!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Quote requested successfully! We will contact you soon.',
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Order Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to request quote: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      //title: Text('Request Quote for\n${widget.designName}'),
      content: _isLoading
          ? const SizedBox(
              height: 50,
              child: Center(child: CircularProgressIndicator()),
            )
          : DropdownButtonFormField<int>(
              initialValue: _selectedQty,
              decoration: const InputDecoration(
                labelText: 'Select Quantity',
                border: OutlineInputBorder(),
              ),
              items: _qtyOptions.map((qty) {
                return DropdownMenuItem<int>(
                  value: qty,
                  child: Text('$qty pcs'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedQty = value;
                });
              },
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitQuote,
          child: const Text('Add to Order'),
        ),
      ],
    );
  }
}
