import 'package:flutter/material.dart';

SampleItem? selectedItem;

enum SampleItem { edit, block, delete }

class TechnicianComponent extends StatefulWidget {
  final IconData icon;
  final Color iconcolor;
  final String name;
  final IconData categoryicon;
  final String category;
  final String specialty;
  final Color containercolor;
  final String status;
  final Map<String, dynamic> techdata;
  final int? id;

  const TechnicianComponent({
    super.key,
    required this.icon,
    required this.iconcolor,
    required this.name,
    required this.categoryicon,
    required this.category,
    required this.specialty,
    required this.containercolor,
    required this.status,
    this.id,
    required this.techdata, 
  });

  @override
  State<TechnicianComponent> createState() => _TechnicianComponentState();
}

class _TechnicianComponentState extends State<TechnicianComponent>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _shadowAnimation = Tween<double>(
      begin: 2,
      end: 12,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    setState(() => _isHovered = isHovered);
    if (isHovered) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.techdata['techstatus'] ?? 'Blocked';
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isHovered
                      ? const Color(0xFFD1D5DB).withValues(alpha: 0.5)
                      : const Color(0xFFE2E8F0),
                  width: _isHovered ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: _shadowAnimation.value,
                    offset: const Offset(0, 2),
                  ),
                  if (_isHovered)
                    BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 
                  const SizedBox(height: 20),

                  // Name
                  Text(
                    widget.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Category - Enhanced
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.categoryicon,
                          size: 14,
                          color: const Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.category,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374151),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Premium Gradient Divider
                  _premiumDivider(),

                  // Specialty Label
                  const SizedBox(height: 18),
                  Text(
                    'SPECIALTY',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF9CA3AF),
                      letterSpacing: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Specialty Text - Enhanced
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF2563EB).withValues(alpha: 0.03),
                              const Color(0xFF2563EB).withValues(alpha: 0.01),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.08),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          widget.specialty,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                            height: 1.4,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFD1FAE5),
                              const Color(0xFFA7F3D0),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10B981).withValues(alpha: 0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          status,
                          style: const TextStyle(
                            color: Color(0xFF047857),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Premium Gradient Divider with Animation
  Widget _premiumDivider() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Base divider
        Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                const Color(0xFFE5E7EB),
                Colors.transparent,
              ],
            ),
          ),
        ),
        // Animated shimmer effect on hover
        if (_isHovered)
          Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  const Color(0xFF2563EB).withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
      ],
    );
  }


 
}

//PopupMenu
