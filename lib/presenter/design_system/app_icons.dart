import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:lucide_icons_flutter/lucide_icons_600.dart';

/// Ícones do app (Lucide), com nomes pelo significado.
/// Trocar o pacote de ícones = mexer só neste arquivo.
abstract class AppIcons {
  // Navegação
  static const IconData back = LucideIcons600.chevronLeft;
  static const IconData close = LucideIcons600.x;
  static const IconData more = LucideIcons600.ellipsisVertical;
  static const IconData music = LucideIcons.music;
  static const IconData musicActive = LucideIcons600.music;
  static const IconData setlist = LucideIcons.listMusic;
  static const IconData setlistActive = LucideIcons600.listMusic;

  // Ações
  static const IconData add = LucideIcons600.plus;
  static const IconData remove = LucideIcons600.minus;
  static const IconData check = LucideIcons600.check;
  static const IconData search = LucideIcons.search;
  static const IconData sync = LucideIcons.refreshCw;
  static const IconData import = LucideIcons600.download;
  static const IconData addToSetlist = LucideIcons.listPlus;
  static const IconData edit = LucideIcons.pencil;
  static const IconData copy = LucideIcons.copy;
  static const IconData trash = LucideIcons.trash2;
  static const IconData save = LucideIcons.save;
  static const IconData dragHandle = LucideIcons600.gripVertical;
  static const IconData externalLink = LucideIcons.externalLink;
  static const IconData video = LucideIcons.circlePlay;

  // Leitura
  static const IconData readerSettings = LucideIcons.slidersHorizontal;
  static const IconData fontSize = LucideIcons.aLargeSmall;
  static const IconData margin = LucideIcons.moveHorizontal;

  // Tema
  static const IconData sun = LucideIcons.sun;
  static const IconData moon = LucideIcons.moon;

  // Estados
  static const IconData success = LucideIcons600.circleCheck;
  static const IconData error = LucideIcons600.circleAlert;
  static const IconData info = LucideIcons600.info;
  static const IconData lock = LucideIcons600.lock;
  static const IconData show = LucideIcons.eye;
  static const IconData hide = LucideIcons.eyeOff;
}
