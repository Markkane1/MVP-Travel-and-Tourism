import '../../../explore/domain/tour.dart';

/// Use case responsible for calculating the total price of a booking configuration.
class CalculateBookingPriceUseCase {
  /// Calculates the total booking price based on participant counts and selected options.
  /// 
  /// Pricing Rules:
  /// - Base price = tour price per person * (adults + children * 0.5)
  /// - children are charged at 50% of the adult rate (assumed business rule).
  /// - Group size modifiers apply if selected group size option matches.
  /// - Private vehicle surcharge applies if selected.
  double call({
    required Tour tour,
    required int adults,
    required int children,
    required bool privateVehicle,
    required String groupSizeOptionLabel,
  }) {
    // 1. Calculate Base Price
    final double basePrice = tour.pricePerPerson * (adults + (children * 0.5));

    // 2. Resolve Group Size Option Modifier
    double groupSizeModifier = 0.0;
    for (final option in tour.groupSizeOptions) {
      if (option['label'] == groupSizeOptionLabel) {
        groupSizeModifier = (option['priceModifier'] as num).toDouble();
        break;
      }
    }

    // 3. Resolve Private Vehicle Surcharge
    final double privateVehicleSurcharge = privateVehicle ? tour.privateVehicleSurcharge : 0.0;

    // 4. Return Total
    return basePrice + groupSizeModifier + privateVehicleSurcharge;
  }
}
