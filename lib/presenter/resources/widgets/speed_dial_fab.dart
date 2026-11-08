import 'package:flutter/material.dart';

class SpeedDialFab extends StatefulWidget {
  final VoidCallback onAddChord;
  final VoidCallback onCifraClub;
  final VoidCallback onOpenList;

  const SpeedDialFab({
    super.key,
    required this.onAddChord,
    required this.onCifraClub,
    required this.onOpenList,
  });

  @override
  State<SpeedDialFab> createState() => _SpeedDialFabState();
}

class _SpeedDialFabState extends State<SpeedDialFab>
    with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  Widget _buildOption({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Opacity(
            opacity: _animation.value,
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 8),
            FloatingActionButton.small(
              heroTag: label,
              backgroundColor: color,
              foregroundColor: Colors.white,
              onPressed: () {
                _toggle();
                onPressed();
              },
              child: Icon(icon),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildOption(
          label: 'Cifra Club',
          icon: Icons.my_library_music,
          color: Colors.orange.shade700,
          onPressed: widget.onCifraClub,
        ),
        _buildOption(
          label: 'Lista',
          icon: Icons.library_books,
          color: Theme.of(context).colorScheme.primary,
          onPressed: widget.onOpenList,
        ),
        _buildOption(
          label: 'Nova Cifra',
          icon: Icons.add,
          color: Theme.of(context).colorScheme.primary,
          onPressed: widget.onAddChord,
        ),
        FloatingActionButton(
          heroTag: "main",
          onPressed: _toggle,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _animation.value * 0.75,
                child: Icon(_isOpen ? Icons.close : Icons.add),
              );
            },
          ),
        ),
      ],
    );
  }
}
