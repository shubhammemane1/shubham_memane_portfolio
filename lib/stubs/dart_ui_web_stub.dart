// Stub library for dart:ui_web when not on web platform
class _PlatformViewRegistry {
  void registerViewFactory(String viewType, Function factory) {}
}

final platformViewRegistry = _PlatformViewRegistry();
