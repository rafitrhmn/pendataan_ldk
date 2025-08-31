class Kader {
  final String id;
  final String username;
  final String? jabatan;
  final String? noHp;

  Kader({required this.id, required this.username, this.jabatan, this.noHp});

  factory Kader.fromJson(Map<String, dynamic> json) {
    return Kader(
      id: json['id'] as String,
      username: json['username'] ?? '-',
      jabatan: json['jabatan'],
      noHp: json['no_hp'],
    );
  }
}
