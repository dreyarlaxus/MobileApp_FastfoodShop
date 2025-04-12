import 'package:flutter/material.dart';
import 'package:ct312h_project/models/order_history.dart';
import 'package:ct312h_project/services/cart_service.dart';
import 'package:intl/intl.dart';

class OrderDetailScreen extends StatefulWidget {
  final OrderHistory order;

  OrderDetailScreen({required this.order});

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final CartService _cartService = CartService();
  List<Map<String, dynamic>> itemDetails = [];
  bool _isLoading = true;

  String formatCurrency(dynamic amount) {
    if (amount == null) return '0';

    // Convert to double
    double value;
    if (amount is int) {
      value = amount.toDouble();
    } else if (amount is double) {
      value = amount;
    } else {
      value = 0.0;
    }

    // Format with thousand separators
    return value.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  @override
  void initState() {
    super.initState();
    // In ra các trường để debug
    print('======= ORDER DETAIL DEBUG =======');
    print('Order ID: ${widget.order.orderId}');
    print('Delivery Address raw: "${widget.order.deliveryAddress}"');
    print('Description raw: "${widget.order.description}"');
    print('Items: ${widget.order.items}');
    print('================================');
    _fetchItemDetails();
  }

  // Định dạng ngày tháng đẹp hơn
  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  // Hàm tạo màu dựa trên tổng đơn hàng
  Color _getAmountColor(double amount) {
    if (amount >= 1000000) return Colors.purple.shade700;
    if (amount >= 500000) return Colors.indigo.shade700;
    if (amount >= 300000) return Colors.blue.shade700;
    if (amount >= 200000) return Colors.teal.shade700;
    return Colors.green.shade700;
  }

  Future<void> _fetchItemDetails() async {
    try {
      List<Map<String, dynamic>> details = [];

      for (var entry in widget.order.items.entries) {
        final itemId = entry.key;
        final quantity = entry.value;

        print('Fetching details for itemId: $itemId');
        final itemData = await _cartService.getItemDetails(itemId);

        details.add({
          'id': itemId,
          'name': itemData['name'] ?? 'Mặt hàng không xác định',
          'quantity': quantity,
          'imageUrl': itemData['imageUrl'] ?? '',
          'price': itemData['price'] ?? 0.0,
        });
      }

      if (mounted) {
        setState(() {
          itemDetails = details;
          _isLoading = false;
        });
      }
    } catch (error) {
      print('Lỗi khi lấy thông tin chi tiết: $error');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final amountColor = _getAmountColor(widget.order.totalAmount);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order detail',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.orange.shade50, Colors.white],
          ),
        ),
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: Colors.orange,
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header với thông tin chính
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.all(16),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Order ID
                          Row(
                            children: [
                              Icon(Icons.receipt_long,
                                  color: Colors.orange.shade800),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Order ID: ${widget.order.orderId}',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          Divider(height: 24),

                          // Date
                          Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 20, color: Colors.grey.shade600),
                              SizedBox(width: 8),
                              Text(
                                'Date: ${_formatDate(widget.order.orderDate)}',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),

                          // Total amount
                          Row(
                            children: [
                              Icon(Icons.attach_money,
                                  size: 20, color: Colors.grey.shade600),
                              SizedBox(width: 8),
                              Text(
                                'Total: ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: amountColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${formatCurrency(widget.order.totalAmount)} VND',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),

                          // Delivery Address
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.location_on,
                                  size: 20, color: Colors.grey.shade600),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Delivery Address: ${widget.order.deliveryAddress == "N/A" ? "N/A" : widget.order.deliveryAddress}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),

                          // Description
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.description,
                                  size: 20, color: Colors.grey.shade600),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Description: ${widget.order.description.isEmpty ? "N/A" : widget.order.description}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Items header
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Icon(Icons.shopping_bag,
                              color: Colors.orange.shade800),
                          SizedBox(width: 8),
                          Text(
                            'Order Items',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Items list
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.all(16),
                      itemCount: itemDetails.length,
                      itemBuilder: (ctx, i) {
                        final item = itemDetails[i];
                        final price = item['price'] ?? 0.0;
                        final quantity = item['quantity'] ?? 0;
                        final totalItemPrice = price * quantity;

                        return Container(
                          margin: EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Item image if available
                                if (item['imageUrl'] != null &&
                                    item['imageUrl'].toString().isNotEmpty)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      item['imageUrl'],
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                      errorBuilder: (ctx, error, _) =>
                                          Container(
                                        width: 70,
                                        height: 70,
                                        color: Colors.grey.shade200,
                                        child: Icon(Icons.image_not_supported,
                                            color: Colors.grey),
                                      ),
                                    ),
                                  ),

                                SizedBox(
                                    width: item['imageUrl'] != null &&
                                            item['imageUrl']
                                                .toString()
                                                .isNotEmpty
                                        ? 16
                                        : 0),

                                // Item details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Mặt hàng: ${item['name']}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade200,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              'Số lượng: ${item['quantity']}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                          ),
                                          Spacer(),
                                          Text(
                                            '${formatCurrency(totalItemPrice)} VND',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: amountColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
