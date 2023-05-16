/// USER
class User {
  /// The user's unique ID.
  final int id;

  /// The user's name.
  final String name;

  /// The user's email.
  final String email;

  /// The user's friends.
  final List<Friend> friends;

  User(this.id, this.name, this.email, this.friends);
}

/// A Friend in the system.
class Friend {
  /// The friend's unique ID.
  final int id;

  /// The friend's name.
  final String name;

  Friend(this.id, this.name);
}
