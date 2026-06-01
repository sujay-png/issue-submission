import 'package:cloud_firestore/cloud_firestore.dart';

class TicketModel {
  final String id; 
  final String ticketId;
  final String category;
  final String brandModel;
  final String description;
  final String contactName;
  final String phone;
  final String center;
  final String? imageUrl;
  final String? assignee;
  final String? department;
  final String? assignedTechnicianId;
  final String status;
  final String? invoiceurl; 
  final String? paymentstatus; 
  final double? serviceCharge;

  final dynamic createdAt;
  final dynamic assignedAt;
  final String? spareparts;

  TicketModel({
    required this.id,
    required this.ticketId,
    required this.category,
    required this.brandModel,
    required this.description,
    required this.contactName,
    required this.phone,
    required this.center,
    this.imageUrl,
    this.assignee,
    this.department,
    this.assignedTechnicianId,
    this.status = 'OPEN',
    this.createdAt,
    this.assignedAt,
    this.paymentstatus,
    this.serviceCharge,
    this.invoiceurl,
    this.spareparts, 
  });

  
  Map<String, dynamic> toMap() {
    return {
      'ticketId': ticketId,
      'category': category,
      'brandModel': brandModel,
      'description': description,
      'contactName': contactName,
      'phone': phone,
      'center': center,
      'imageUrl': imageUrl,
      'assignee': assignee,
      'department': department,
      'assignedTechnicianId': assignedTechnicianId,
      'status': status,
      'sparepartsrequirements':spareparts,
      'InvoiceImage': invoiceurl, 
      'paymentStatus': paymentstatus,
      'serviceCharge':serviceCharge,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'assignedAt': assignedAt,
    };
  }

  /// Factory constructor with null-safety defaults
  factory TicketModel.fromMap(Map<String, dynamic> map, String documentId) {
    return TicketModel(
      id: documentId,
      ticketId: map['ticketId'] ?? 'N/A',
      category: map['category'] ?? 'General',
      brandModel: map['brandModel'] ?? 'Unknown',
      description: map['description'] ?? '',
      contactName: map['contactName'] ?? 'Unknown',
      phone: map['phone'] ?? '',
      center: map['center'] ?? '',
      imageUrl: map['imageUrl'],
      invoiceurl: map['InvoiceImage'], 
      status: map['status'] ?? 'OPEN',
  spareparts: _parseSpareParts(map['sparepartsrequirements']),
      paymentstatus: map['paymentStatus'] ?? 'PENDING',
serviceCharge: (map['serviceCharge'] as num?)?.toDouble(),
      assignee: map['assignee'],
      department: map['department'],
      assignedTechnicianId: map['assignedTechnicianId'],
      createdAt: map['createdAt'],
      assignedAt: map['assignedAt'],
    );
  }

  
  TicketModel copyWith({
    String? id,
    String? ticketId,
    String? category,
    String? brandModel,
    String? description,
    String? contactName,
    String? phone,
    String? center,
    String? imageUrl,
    String? assignee,
    String? department,
    String? assignedTechnicianId,
    String? status,
    String?spareparts,
    dynamic createdAt,
    dynamic assignedAt,
    String? paymentstatus,
    double? servicecharge,
    String? invoiceurl, 
  }) {
    return TicketModel(
      id: id ?? this.id,
      ticketId: ticketId ?? this.ticketId,
      category: category ?? this.category,
      brandModel: brandModel ?? this.brandModel,
      description: description ?? this.description,
      contactName: contactName ?? this.contactName,
      phone: phone ?? this.phone,
      center: center ?? this.center,
      imageUrl: imageUrl ?? this.imageUrl,
      assignee: assignee ?? this.assignee,
      department: department ?? this.department,
      assignedTechnicianId: assignedTechnicianId ?? this.assignedTechnicianId,
      status: status ?? this.status,
      spareparts: spareparts ?? this.spareparts,
      createdAt: createdAt ?? this.createdAt,
      assignedAt: assignedAt ?? this.assignedAt,
      paymentstatus: paymentstatus ?? this.paymentstatus,
      serviceCharge: servicecharge ?? serviceCharge,
      invoiceurl: invoiceurl ?? this.invoiceurl, 
    );
  }

  bool get isAssigned => assignedTechnicianId != null && assignedTechnicianId!.isNotEmpty;

  String get assignedTechnicianDisplay {
    if (!isAssigned) return 'Unassigned';
    return assignee ?? 'Unknown Technician';
  }
static String _parseSpareParts(dynamic value) {
  if (value == null) return 'N/A';
  if (value is List) return value.map((e) => e.toString()).join(', ');
  if (value is String) return value.isEmpty ? 'N/A' : value;
  return 'N/A';
}
  @override
  String toString() {
    return 'TicketModel(id: $id, ticketId: $ticketId, status: $status)';
  }
}