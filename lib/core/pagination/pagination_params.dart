class PaginationParams {
  final int pageNumber;
  final int pageSize;

  const PaginationParams({this.pageNumber = 1, this.pageSize = 20});

  Map<String, dynamic> toQuery() {
    return {'pageNumber': pageNumber, 'pageSize': pageSize};
  }
}
