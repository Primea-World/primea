enum Breakpoint {
  phone(width: 480),
  tablet(width: 768),
  desktop(width: 1024);

  final double width;

  const Breakpoint({required this.width});
}
