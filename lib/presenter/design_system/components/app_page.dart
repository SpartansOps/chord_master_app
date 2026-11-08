import 'package:chord_master_app/presenter/design_system/components/app_button.dart';
import 'package:chord_master_app/presenter/design_system/components/pressable.dart';
import 'package:chord_master_app/presenter/design_system/tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:chord_master_app/presenter/design_system/app_icons.dart';

/// Barra superior do app (substitui o AppBar do Material).
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    this.title,
    this.subtitle,
    this.leading,
    this.actions = const [],
    this.showBack = false,
    this.fallbackRoute = '/',
    this.onBack,
    this.maxWidth = AppSpace.maxContentWidth + 2 * AppSpace.gutter,
  });

  final String? title;
  final String? subtitle;

  /// Substitui o botão voltar (ex.: logo na tela inicial).
  final Widget? leading;
  final List<Widget> actions;
  final bool showBack;

  /// Para onde ir quando não há tela anterior (link aberto direto na web).
  final String fallbackRoute;
  final VoidCallback? onBack;

  /// Deve bater com a largura do conteúdo da tela, para alinhar.
  final double maxWidth;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: c.background,
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: SizedBox(
              height: 64,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpace.xs),
                child: Row(
                  children: [
                    if (leading != null)
                      Padding(padding: const EdgeInsets.only(left: AppSpace.xs), child: leading!)
                    else if (showBack)
                      AppIconButton(
                        icon: AppIcons.back,
                        tooltip: 'Voltar',
                        onPressed: onBack ??
                            () => context.canPop() ? context.pop() : context.go(fallbackRoute),
                      ),
                    SizedBox(width: showBack && leading == null ? AppSpace.xxs : AppSpace.sm),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (title != null)
                            Text(
                              title!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.text.subtitle.copyWith(fontSize: 17),
                            ),
                          if (subtitle != null)
                            Text(
                              subtitle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.text.caption.copyWith(fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                    ...actions,
                    const SizedBox(width: AppSpace.xxs),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Estrutura de tela: fundo, barra superior e conteúdo com largura máxima.
class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.body,
    this.topBar,
    this.bottomBar,
    this.maxWidth = AppSpace.maxContentWidth,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpace.gutter),
  });

  final Widget body;
  final PreferredSizeWidget? topBar;
  final Widget? bottomBar;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: topBar,
      bottomNavigationBar: bottomBar,
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth + padding.horizontal),
          child: Padding(padding: padding, child: body),
        ),
      ),
    );
  }
}

class AppNavItem {
  const AppNavItem({required this.icon, required this.activeIcon, required this.label, this.badge});

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int? badge;
}

/// Navegação inferior entre as seções principais.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<AppNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: c.background,
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SizedBox(
              height: 64,
              child: Row(
                children: [
                  for (var i = 0; i < items.length; i++)
                    Expanded(child: _NavButton(item: items[i], selected: i == currentIndex, onTap: () => onTap(i))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.item, required this.selected, required this.onTap});

  final AppNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = selected ? c.accent : c.textMuted;
    return Pressable(
      onTap: onTap,
      pressedScale: 0.94,
      semanticLabel: item.label,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedContainer(
                duration: AppDurations.normal,
                width: 56,
                height: 30,
                decoration: BoxDecoration(
                  color: selected ? c.accentSoft : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Icon(selected ? item.activeIcon : item.icon, size: 20, color: fg),
              ),
              if ((item.badge ?? 0) > 0)
                Positioned(
                  right: 6,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    constraints: const BoxConstraints(minWidth: 18),
                    decoration: BoxDecoration(
                      color: c.accent,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(color: c.background, width: 2),
                    ),
                    child: Text(
                      '${item.badge}',
                      textAlign: TextAlign.center,
                      style: context.text.number.copyWith(fontSize: 10, color: c.onAccent),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(item.label, style: context.text.caption.copyWith(fontSize: 12, color: fg)),
        ],
      ),
    );
  }
}

/// Logo do app (palheta com diagrama de acorde).
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 36});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      width: size,
      height: size,
      filterQuality: FilterQuality.medium,
      semanticLabel: 'Chord Master',
    );
  }
}
