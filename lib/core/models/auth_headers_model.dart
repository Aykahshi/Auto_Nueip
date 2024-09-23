class AuthHeaders {
  final String? cookie;
  final String? csrfToken;

  AuthHeaders({
    this.cookie,
    this.csrfToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'cookie': cookie,
      'csrfToken': csrfToken,
    };
  }

  factory AuthHeaders.fromJson(Map<String, dynamic> json) {
    return AuthHeaders(
      cookie: json['cookie'] as String,
      csrfToken: json['csrfToken'] as String,
    );
  }
}
