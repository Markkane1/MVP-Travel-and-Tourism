class ItineraryStepViewModel {
  const ItineraryStepViewModel({
    required this.day,
    required this.title,
    required this.description,
  });

  final int day;
  final String title;
  final String description;
}

ItineraryStepViewModel parseItineraryStep(Object? step, int fallbackDay) {
  if (step is! Map) {
    return ItineraryStepViewModel(
      day: fallbackDay,
      title: '',
      description: '',
    );
  }

  final dynamic rawDay = step['day'];
  final dynamic rawTitle = step['title'];
  final dynamic rawDescription = step['description'];

  return ItineraryStepViewModel(
    day: rawDay is int
        ? rawDay
        : rawDay is num
            ? rawDay.toInt()
            : fallbackDay,
    title: rawTitle is String ? rawTitle : '',
    description: rawDescription is String ? rawDescription : '',
  );
}
