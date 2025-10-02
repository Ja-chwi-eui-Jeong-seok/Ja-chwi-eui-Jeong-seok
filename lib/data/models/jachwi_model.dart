// 데이터 전송 및 저장에 사용되는 모델 클래스 (DTO)

class JachwiModel {
  final int id;
  final String name;

  JachwiModel({required this.id, required this.name});

  factory JachwiModel.fromJson(Map<String, dynamic> json) {
    return JachwiModel(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
