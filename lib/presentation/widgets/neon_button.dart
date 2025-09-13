import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

/// Futuristic neon-styled button widget
class NeonButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isSecondary;
  final double? width;
  final double height;
  final Gradient? gradient;
  final Color? shadowColor;

  const NeonButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isSecondary = false,
    this.width,
    this.height = AppConstants.buttonHeight,
    this.gradient,
    this.shadowColor,
  });

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 1.0,
      end: 1.5,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveGradient = widget.gradient ??
        (widget.isSecondary
            ? const LinearGradient(
                colors: [AppTheme.dangerNeon, Colors.red],
              )
            : const LinearGradient(
                colors: [AppTheme.primaryNeon, AppTheme.secondaryNeon],
              ));

    final effectiveShadowColor = widget.shadowColor ??
        (widget.isSecondary ? AppTheme.dangerNeon : AppTheme.primaryNeon);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: widget.onPressed != null ? _handleTapDown : null,
            onTapUp: widget.onPressed != null ? _handleTapUp : null,
            onTapCancel: widget.onPressed != null ? _handleTapCancel : null,
            onTap: widget.onPressed,
            child: Container(
              width: widget.width ?? double.infinity,
              height: widget.height,
              decoration: BoxDecoration(
                gradient: effectiveGradient,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: effectiveShadowColor.withOpacity(0.3 * _glowAnimation.value),
                    blurRadius: 15 * _glowAnimation.value,
                    spreadRadius: 2 * _glowAnimation.value,
                  ),
                  BoxShadow(
                    color: effectiveShadowColor.withOpacity(0.1),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onPressed,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingLarge,
                      vertical: AppConstants.paddingMedium,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.isLoading)
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                widget.isSecondary ? Colors.white : Colors.black,
                              ),
                            ),
                          )
                        else if (widget.icon != null)
                          Icon(
                            widget.icon,
                            color: widget.isSecondary ? Colors.white : Colors.black,
                            size: AppConstants.iconSize,
                          ),
                        
                        if ((widget.icon != null || widget.isLoading) && widget.text.isNotEmpty)
                          const SizedBox(width: AppConstants.paddingSmall),
                        
                        if (widget.text.isNotEmpty)
                          Text(
                            widget.text,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: widget.isSecondary ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Specialized neon button for icon-only actions
class NeonIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final double size;
  final String? tooltip;

  const NeonIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.size = 48,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppTheme.primaryNeon;

    Widget button = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            effectiveColor.withOpacity(0.3),
            Colors.transparent,
          ],
        ),
        border: Border.all(
          color: effectiveColor.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: effectiveColor.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Icon(
            icon,
            color: effectiveColor,
            size: size * 0.5,
          ),
        ),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button.animate().scale(duration: 200.ms);
  }
}

/// Neon-styled outline button
class NeonOutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  final double? width;
  final double height;

  const NeonOutlineButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.color,
    this.width,
    this.height = AppConstants.buttonHeight,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppTheme.primaryNeon;

    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: effectiveColor, width: 2),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: effectiveColor.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingLarge,
              vertical: AppConstants.paddingMedium,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null)
                  Icon(
                    icon,
                    color: effectiveColor,
                    size: AppConstants.iconSize,
                  ),
                
                if (icon != null && text.isNotEmpty)
                  const SizedBox(width: AppConstants.paddingSmall),
                
                if (text.isNotEmpty)
                  Text(
                    text,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: effectiveColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}