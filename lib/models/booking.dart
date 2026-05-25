enum BookingStatus { closed, inProgress, pending }

class Booking {
  final String id;
  final String customerName;
  final String service;
  final String workerName;
  final double amount;
  final BookingStatus status;
  final DateTime date;

  Booking({
    required this.id,
    required this.customerName,
    required this.service,
    required this.workerName,
    required this.amount,
    required this.status,
    required this.date,
  });
}
