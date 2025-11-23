class MembershipQueryDto {
  const MembershipQueryDto({
    this.page,
    this.limit,
    this.status,
    this.search,
  });

  final int? page;
  final int? limit;
  final String? status;
  final String? search;

  Map<String, String> toQueryParameters() {
    final map = <String, String>{};
    if (page != null) {
      map['page'] = '$page';
    }
    if (limit != null) {
      map['limit'] = '$limit';
    }
    if (status?.isNotEmpty == true) {
      map['status'] = status!.trim();
    }
    if (search?.isNotEmpty == true) {
      map['search'] = search!.trim();
    }
    return map;
  }
}
