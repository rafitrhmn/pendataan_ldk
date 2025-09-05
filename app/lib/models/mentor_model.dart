import 'package:equatable/equatable.dart';

class MentorModel extends Equatable {
  final String id;
  final String username;
  final String? jabatan;
  final String? noHp;

  const MentorModel({
    required this.id,
    required this.username,
    this.jabatan,
    this.noHp,
  });

  factory MentorModel.fromJson(Map<String, dynamic> json) {
    return MentorModel(
      id: json['id'] as String,
      username: json['username'] ?? '-',
      jabatan: json['jabatan'] as String?,
      noHp: json['no_hp'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, username, jabatan, noHp];
}
