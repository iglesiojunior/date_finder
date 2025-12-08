class DateSpot {
  final int? id;
  final String name;
  final double latitude;
  final double longitude;
  final String date;
  final String notes;
  final double rating;
  final int? userId;

  DateSpot({
    this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.date,
    this.notes = '',
    this.rating = 0.0,
    this.userId,
  });

  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'date': date,
      'notes': notes,
      'rating': rating,
      'user_id': userId,
    };
  }

  factory DateSpot.fromMap(Map<String, dynamic> map) {
    return DateSpot(
      id: map['id'] ,
      name: map['name'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      date: map['date'],
      notes: map['notes'] ?? '',
      rating: map['rating']?.toDouble() ?? 0.0,
      userId: map['user_id'],
    );
  }
}

