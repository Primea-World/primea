enum Breakpoint {
  phone(width: 480),
  tablet(width: 768),
  desktop(width: 1296);

  final double width;

  const Breakpoint({required this.width});
}
