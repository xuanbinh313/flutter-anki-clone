String toIsoWithOffset(DateTime dt) {
  // chắc chắn là UTC
  final utc = dt.toUtc();

  // ISO bình thường (sẽ ra ...Z)
  final iso = utc.toIso8601String();

  // đổi Z ➜ +00:00
  return iso.replaceFirst('Z', '+00:00');
}
