import 'package:flutter/material.dart';
import '../widgets/app_top_bar.dart';
import '../services/user_credit_service.dart';

class PricingScreen extends StatefulWidget {
  const PricingScreen({super.key});

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  bool yearly = false;
  bool business = false;

  int _parseCredits(String credits) {
    final onlyNumber = credits.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(onlyNumber) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07111F),
      body: Column(
        children: [
          const AppTopBar(
            activeMenu: 'Bảng giá',
            isLoggedIn: true,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 34),
              child: Column(
                children: [
                  const Text(
                    'Chọn gói Nemo phù hợp với bạn',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Tạo ảnh, video AI bán hàng với chi phí tối ưu cho creator và shop online',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _tabs(),
                  const SizedBox(height: 24),
                  _billingSwitch(),
                  const SizedBox(height: 44),
                  business ? _businessPlans() : _personalPlans(),
                  const SizedBox(height: 56),
                  const Text(
                    'Có câu hỏi? Liên hệ Nemo AI để được tư vấn gói phù hợp.',
                    style: TextStyle(color: Color(0xFF94A3B8)),
                  ),
                  const SizedBox(height: 50),
                  _footer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _personalPlans() {
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      alignment: WrapAlignment.center,
      children: [
        _planCard(
          name: 'Free',
          subtitle: 'Dùng thử Nemo',
          price: '0',
          credits: '30',
          badge: 'GÓI HIỆN TẠI',
          icon: Icons.star_border,
          iconColor: const Color(0xFF94A3B8),
          borderColor: const Color(0xFF334155),
          buttonText: 'Gói hiện tại',
          features: const [
            '1 ảnh free/ngày',
            'Video demo có watermark',
            'Queue chậm',
            'Model cơ bản',
          ],
          models: const [
            'Flux Schnell',
            'Wan Lite',
            'Kling Lite',
          ],
        ),
        _planCard(
          name: 'Pro',
          subtitle: 'Phù hợp người bán hàng',
          price: yearly ? '119.000' : '149.000',
          credits: '2.000',
          badge: 'PHỔ BIẾN NHẤT',
          icon: Icons.auto_awesome,
          iconColor: const Color(0xFFA855F7),
          borderColor: const Color(0xFFA855F7),
          gradientButton: true,
          buttonText: 'Nâng cấp Pro',
          features: const [
            '100 ảnh free/ngày',
            'Video 720p',
            'Không watermark',
            '8 luồng xử lý đồng thời',
            '16 hàng đợi tự động',
          ],
          models: const [
            'Flux Pro',
            'Kling Standard',
            'Seedance Lite',
            'Wan Pro',
            'Product Ads',
          ],
        ),
        _planCard(
          name: 'Ultimate',
          subtitle: 'Tối ưu cho creator',
          price: yearly ? '319.000' : '399.000',
          credits: '5.000',
          icon: Icons.workspace_premium,
          iconColor: const Color(0xFF06B6D4),
          borderColor: const Color(0xFF06B6D4),
          buttonText: 'Nâng cấp Ultimate',
          features: const [
            '300 ảnh free/ngày',
            'Video 1080p',
            'Ưu tiên queue',
            '12 luồng xử lý đồng thời',
            'Hỗ trợ upscale',
            'Hỗ trợ API dev mode',
          ],
          models: const [
            'Kling Pro',
            'Seedance Pro',
            'Minimax',
            'Hailuo',
            'Flux Kontext',
          ],
        ),
        _planCard(
          name: 'Creator',
          subtitle: 'Cho agency & team',
          price: yearly ? '639.000' : '799.000',
          credits: '10.000',
          icon: Icons.diamond_outlined,
          iconColor: const Color(0xFF22C55E),
          borderColor: const Color(0xFF22C55E),
          buttonText: 'Nâng cấp Creator',
          features: const [
            '1000 ảnh free/ngày',
            'Video batch hàng loạt',
            '24 luồng xử lý đồng thời',
            '48 hàng đợi tự động',
            'Không watermark',
            'API cho team',
          ],
          models: const [
            'Runway VIP',
            'Kling Master',
            'Seedance Pro',
            'HeyGen Lipsync',
            'Veo Premium',
          ],
        ),
      ],
    );
  }

  Widget _businessPlans() {
    return Wrap(
      spacing: 32,
      runSpacing: 32,
      alignment: WrapAlignment.center,
      children: [
        _businessCard(
          name: 'Team',
          subtitle: 'Dành cho shop, agency nhỏ',
          oldPrice: '2.697.000đ',
          price: '1.797.000',
          subPrice: '599.000đ/người x 3 người',
          credits: '6.000 credits/người/tháng',
          totalCredits: 'Tổng cộng 18.000 credits cho cả team',
          borderColor: const Color(0xFF06B6D4),
          badge: 'TỐT NHẤT CHO CỘNG TÁC',
          buttonText: 'Nâng cấp gói',
          features: const [
            '6.000 credits/người/tháng',
            '3-15 thành viên linh hoạt',
            '8 tác vụ đồng thời/người',
            'Không gian làm việc chung',
            'Quy trình cộng tác',
            'Phân tích sử dụng',
            'Thanh toán tập trung',
            'Hỗ trợ email ưu tiên',
          ],
          includes: const [
            'Chia sẻ tài nguyên, thư mục và preset',
            'Bình luận, chỉnh sửa và cộng tác',
            'Theo dõi chi tiêu và hiệu suất thành viên',
          ],
        ),
        _businessCard(
          name: 'Enterprise',
          subtitle: 'Dành cho doanh nghiệp lớn',
          oldPrice: '3.300.000đ',
          price: '2.400.000',
          subPrice: '800.000đ/người x 3 người',
          credits: '5.000 credits/người/tháng',
          totalCredits: 'Tổng cộng 15.000 credits cho cả team',
          borderColor: const Color(0xFFA855F7),
          buttonText: 'Liên hệ tư vấn',
          secondButtonText: 'Tìm hiểu thêm',
          features: const [
            '5.000 credits/người/tháng',
            'Không giới hạn thành viên',
            '12 tác vụ đồng thời/người',
            'Hỗ trợ cao cấp 24/7',
            'Truy cập tất cả model',
            'Giảm giá theo số lượng',
            'Hàng đợi ưu tiên',
            'Truy cập tính năng sớm',
          ],
          includes: const [
            'Pháp lý & bảo mật: DPA, mã hoá, SSO',
            'Phân tích nâng cao & kiểm soát chi tiêu',
            'Phát triển tính năng riêng',
            'Quản lý tài khoản chuyên biệt',
          ],
        ),
      ],
    );
  }

  Widget _tabs() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _tabButton('Cá nhân', !business, () {
            setState(() => business = false);
          }),
          _tabButton('Nhóm & Doanh nghiệp', business, () {
            setState(() => business = true);
          }),
        ],
      ),
    );
  }

  Widget _tabButton(String text, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(
            colors: [
              Color(0xFF7C3AED),
              Color(0xFF06B6D4),
            ],
          )
              : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: active ? Colors.white : const Color(0xFF94A3B8),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _billingSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Hàng tháng',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        Switch(
          value: yearly,
          activeColor: const Color(0xFF06B6D4),
          onChanged: (value) {
            setState(() => yearly = value);
          },
        ),
        const Text(
          'Hàng năm',
          style: TextStyle(color: Color(0xFF94A3B8)),
        ),
        const SizedBox(width: 8),
        const Text(
          '-20%',
          style: TextStyle(
            color: Color(0xFF22C55E),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _businessCard({
    required String name,
    required String subtitle,
    required String oldPrice,
    required String price,
    required String subPrice,
    required String credits,
    required String totalCredits,
    required Color borderColor,
    required String buttonText,
    required List<String> features,
    required List<String> includes,
    String? badge,
    String? secondButtonText,
  }) {
    return Container(
      width: 470,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF101826),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.6),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.12),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (badge != null)
            Positioned(
              top: -46,
              left: 70,
              right: 70,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  badge,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(color: Color(0xFF9CA3AF)),
              ),
              const SizedBox(height: 28),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    oldPrice,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 18,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    price,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 7),
                    child: Text(
                      'đ/tháng',
                      style: TextStyle(color: Color(0xFF9CA3AF)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                subPrice,
                style: const TextStyle(color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: name == 'Team'
                        ? const LinearGradient(
                      colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
                    )
                        : null,
                    color: name == 'Team' ? null : const Color(0xFF334155),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextButton(
                    onPressed: () {
                      _openPaymentDialog(
                        planName: name,
                        price: price,
                        credits: credits,
                      );
                    },
                    child: Text(
                      buttonText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              if (secondButtonText != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF475569)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      secondButtonText,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      borderColor.withValues(alpha: 0.18),
                      const Color(0xFF1E293B),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: borderColor.withValues(alpha: 0.35),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      credits,
                      style: TextStyle(
                        color: borderColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '= $totalCredits',
                      style: const TextStyle(color: Color(0xFF9CA3AF)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ...features.map((e) => _featureLine(e)),
              const SizedBox(height: 24),
              const Divider(color: Color(0xFF334155)),
              const SizedBox(height: 14),
              const Text(
                'BAO GỒM TẤT CẢ GÓI CREATOR VÀ...',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...includes.map(
                    (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '• $e',
                    style: const TextStyle(color: Color(0xFF9CA3AF)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _planCard({
    required String name,
    required String subtitle,
    required String price,
    required String credits,
    required IconData icon,
    required Color iconColor,
    required Color borderColor,
    required String buttonText,
    required List<String> features,
    required List<String> models,
    String? badge,
    bool gradientButton = false,
  }) {
    final isFree = name == 'Free';

    return Container(
      width: 290,
      constraints: const BoxConstraints(minHeight: 620),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF101826),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: borderColor.withValues(alpha: 0.9),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (badge != null)
            Positioned(
              top: -38,
              left: 24,
              right: 24,
              child: Center(
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF7C3AED),
                        Color(0xFF06B6D4),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 30),
              ),
              const SizedBox(height: 18),
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 6),
                    child: Text(
                      'đ/tháng',
                      style: TextStyle(color: Color(0xFF94A3B8)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2937),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    const Text(
                      'CREDITS / THÁNG',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      credits,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _infoBox(
                'XỬ LÝ ĐỒNG THỜI',
                name == 'Creator'
                    ? '24'
                    : name == 'Ultimate'
                    ? '12'
                    : '8',
                borderColor,
              ),
              const SizedBox(height: 12),
              _infoBox(
                'HÀNG ĐỢI TỰ ĐỘNG',
                name == 'Creator'
                    ? '48'
                    : name == 'Ultimate'
                    ? '24'
                    : '16',
                borderColor,
              ),
              const SizedBox(height: 22),
              ...features.map((e) => _featureLine(e)),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: models.map((e) => _modelChip(e)).toList(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: gradientButton
                        ? const LinearGradient(
                      colors: [
                        Color(0xFF7C3AED),
                        Color(0xFF06B6D4),
                      ],
                    )
                        : null,
                    color: gradientButton ? null : const Color(0xFF334155),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextButton(
                    onPressed: isFree
                        ? null
                        : () {
                      _openPaymentDialog(
                        planName: name,
                        price: price,
                        credits: credits,
                      );
                    },
                    child: Text(
                      buttonText,
                      style: TextStyle(
                        color: isFree ? Colors.white54 : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoBox(String label, String value, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$value Luồng',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureLine(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          const Icon(Icons.check, color: Color(0xFF22C55E), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Color(0xFFD1D5DB)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _modelChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A5F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF2563EB).withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFBFDBFE),
          fontSize: 11,
        ),
      ),
    );
  }

  void _openPaymentDialog({
    required String planName,
    required String price,
    required String credits,
  }) {
    int paymentStep = 1;

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.78),
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final creditNumber = _parseCredits(credits);

            return Dialog(
              backgroundColor: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: SizedBox(
                width: 520,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Icon(
                              paymentStep == 3
                                  ? Icons.check_circle
                                  : Icons.auto_awesome,
                              color: paymentStep == 3
                                  ? const Color(0xFF22C55E)
                                  : const Color(0xFFA855F7),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              paymentStep == 1
                                  ? 'Đăng ký $planName'
                                  : paymentStep == 2
                                  ? 'Thanh toán $planName'
                                  : 'Hoàn tất',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            _stepCircle('1', paymentStep >= 1),
                            Expanded(child: _stepLine(paymentStep >= 2)),
                            _stepCircle('2', paymentStep >= 2),
                            Expanded(child: _stepLine(paymentStep >= 3)),
                            _stepCircle('3', paymentStep >= 3),
                          ],
                        ),
                        const SizedBox(height: 24),
                        if (paymentStep == 1) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: const Color(0xFF263244),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  planName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '$priceđ/tháng',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                _checkLine('$credits credits / tháng'),
                                _checkLine('Không watermark'),
                                _checkLine('Tạo ảnh và video AI'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFA855F7),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () {
                                setDialogState(() {
                                  paymentStep = 2;
                                });
                              },
                              icon: const Icon(Icons.credit_card),
                              label: const Text('Tiếp tục thanh toán'),
                            ),
                          ),
                        ],
                        if (paymentStep == 2) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: SizedBox(
                              width: 250,
                              child: Image.asset(
                                'assets/images/qr_payment.jpg',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          _paymentRow('Ngân hàng', 'BIDV'),
                          _paymentRow('Số tiền', '$priceđ'),
                          _paymentRow('Credits', '+$creditNumber / tháng'),
                          _paymentRow('Nội dung CK', 'NEMO-$planName'),
                          const SizedBox(height: 18),
                          const Text(
                            'Đang chờ chuyển khoản...',
                            style: TextStyle(
                              color: Color(0xFF22D3EE),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF22C55E),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () async {
                                // chuyển sang bước 3 ngay để không bị đứng nút
                                setDialogState(() {
                                  paymentStep = 3;
                                });

                                try {
                                  await UserCreditService.addCredits(creditNumber);

                                  if (!mounted) return;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: const Color(0xFF22C55E),
                                      content: Text(
                                        'Đã cộng $creditNumber Credits thành công',
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  if (!mounted) return;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: Colors.red,
                                      content: Text(
                                        'Lỗi cộng Credits: $e',
                                      ),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.check_circle),
                              label: const Text('Giả lập đã thanh toán'),
                            ),
                          ),
                        ],
                        if (paymentStep == 3) ...[
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF22C55E),
                            size: 76,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Đã nâng cấp $planName thành công',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Đã cộng $creditNumber credits vào tài khoản',
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(height: 22),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF06B6D4),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(dialogContext);
                              },
                              child: const Text('Hoàn tất'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _stepCircle(String text, bool active) {
    return CircleAvatar(
      radius: 15,
      backgroundColor:
      active ? const Color(0xFFA855F7) : const Color(0xFF334155),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _stepLine(bool active) {
    return Container(
      height: 2,
      color: active ? const Color(0xFF22C55E) : const Color(0xFF334155),
    );
  }

  Widget _paymentRow(String left, String right) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF334155)),
        ),
      ),
      child: Row(
        children: [
          Text(left, style: const TextStyle(color: Color(0xFF94A3B8))),
          const Spacer(),
          Text(
            right,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _checkLine(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check, color: Color(0xFF22C55E), size: 18),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Color(0xFFD1D5DB))),
        ],
      ),
    );
  }

  Widget _footer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFF1F2937)),
        ),
      ),
      child: const Center(
        child: Text(
          '© 2026 Nemo AI • Made for AI sellers & creators',
          style: TextStyle(color: Color(0xFF64748B)),
        ),
      ),
    );
  }
}