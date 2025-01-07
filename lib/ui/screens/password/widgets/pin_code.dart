import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:scan_doc/data/services/shared_preferences_service.dart';
import 'package:scan_doc/domain/di/get_it_services.dart';
import 'package:scan_doc/ui/resurses/colors.dart';

class PinCode extends StatefulWidget {
  final Function(String)? onChange;
  final void Function() onSubmit;
  final String? password;

  const PinCode({
    super.key,
    this.onChange,
    required this.onSubmit,
    this.password,
  });

  @override
  State<PinCode> createState() => _PinCodeState();
}

class _PinCodeState extends State<PinCode> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final List<String> _pinNumbers = List.filled(6, '');
  int _currentIndex = 0;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onNumberPressed(String number) {
    if (_currentIndex < 6) {
      setState(() {
        _pinNumbers[_currentIndex] = number;
        _currentIndex++;
        if (_isError) _isError = false;
      });

      if (widget.onChange != null) {
        widget.onChange!(_pinNumbers.join());
      }

      if (_currentIndex == 6) {
        _verifyPin();
      }
    }
  }

  void _onDelete() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _pinNumbers[_currentIndex] = '';
        if (_isError) _isError = false;
      });
    }
  }

  Future<void> _verifyPin() async {
    final enteredPin = _pinNumbers.join();

    if (widget.password != null) {
      if (widget.password == enteredPin) {
        await SharedPreferencesService.setPassword(password: enteredPin);
        widget.onSubmit();
        return;
      }
    } else {
      final savedPassword = await SharedPreferencesService.getPassword();
      if (savedPassword == null) {
        getItService.navigatorService.onPassword(
          onOpen: widget.onSubmit,
          password: enteredPin,
        );
        return;
      } else if (savedPassword == enteredPin) {
        widget.onSubmit();
        return;
      }
    }

    // Show error
    setState(() {
      _isError = true;
      _currentIndex = 0;
      _pinNumbers.fillRange(0, 6, '');
    });
    
    _animController
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // PIN dots
        AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                sin(_animController.value * 2 * pi) * 10,
                0,
              ),
              child: child,
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (index) {
              final isFilled = _pinNumbers[index].isNotEmpty;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isFilled ? AppGradients.primary : null,
                    border: Border.all(
                      color: _isError
                          ? AppColors.error
                          : (isFilled
                              ? Colors.transparent
                              : AppColors.primaryGrad1.withOpacity(0.3)),
                      width: 2,
                    ),
                    boxShadow: isFilled
                        ? [
                            BoxShadow(
                              color: AppColors.primaryGrad1.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                ),
              ).animate().scale(
                    delay: 50.ms * index,
                    duration: 200.ms,
                    curve: Curves.easeOutBack,
                  );
            }),
          ),
        ),

        const SizedBox(height: 40),

        // Number pad
        Column(
          children: [
            for (var i = 0; i < 4; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (i < 3)
                      for (var j = 1; j <= 3; j++)
                        _buildNumberButton((i * 3 + j).toString())
                    else ...[
                      const SizedBox(width: 88), // Placeholder for empty space
                      _buildNumberButton('0'),
                      _buildDeleteButton(),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberButton(String number) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => _onNumberPressed(number),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surfaceDark.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primaryGrad1.withOpacity(0.1),
                ),
              ),
              child: Center(
                child: Text(
                  number,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ).animate().scale(
            delay: 50.ms * int.parse(number),
            duration: 200.ms,
            curve: Curves.easeOutBack,
          ),
    );
  }

  Widget _buildDeleteButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: _onDelete,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surfaceDark.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primaryGrad1.withOpacity(0.1),
                ),
              ),
              child: const Center(
                child: Icon(
                  CupertinoIcons.delete_left_fill,
                  color: AppColors.textPrimary,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ).animate().scale(
            delay: 600.ms,
            duration: 200.ms,
            curve: Curves.easeOutBack,
          ),
    );
  }
}
