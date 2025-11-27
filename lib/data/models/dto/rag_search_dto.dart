import 'package:equatable/equatable.dart';

class RagSearchRequestDto extends Equatable {
  final String query;
  final int? limit;

  const RagSearchRequestDto({required this.query, this.limit});

  Map<String, dynamic> toJson() => {
    'query': query,
    if (limit != null) 'limit': limit,
  };

  @override
  List<Object?> get props => [query, limit];
}

class RagSearchResponseDto extends Equatable {
  final bool success;
  final RagSearchData data;

  const RagSearchResponseDto({required this.success, required this.data});

  factory RagSearchResponseDto.fromJson(Map<String, dynamic> json) {
    return RagSearchResponseDto(
      success: json['success'] as bool,
      data: RagSearchData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  @override
  List<Object?> get props => [success, data];
}

class RagSearchData extends Equatable {
  final String context;
  final List<RagSource> sources;

  const RagSearchData({required this.context, required this.sources});

  factory RagSearchData.fromJson(Map<String, dynamic> json) {
    return RagSearchData(
      context: json['context'] as String,
      sources: (json['sources'] as List<dynamic>)
          .map((e) => RagSource.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [context, sources];
}

class RagSource extends Equatable {
  final String type;
  final String title;
  final double score;
  final Map<String, dynamic> data;

  const RagSource({
    required this.type,
    required this.title,
    required this.score,
    required this.data,
  });

  factory RagSource.fromJson(Map<String, dynamic> json) {
    return RagSource(
      type: json['type'] as String,
      title: json['title'] as String,
      score: (json['score'] as num).toDouble(),
      data: json['data'] as Map<String, dynamic>,
    );
  }

  @override
  List<Object?> get props => [type, title, score, data];
}
