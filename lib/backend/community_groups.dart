import 'package:flutter/material.dart';

/// A fixed, in-app definition of a community "Circle of Support".
///
/// Only membership is persisted in Firestore (under `groups/{id}/members`),
/// so the catalog of available circles is defined here. The displayed member
/// count is [baseMembers] plus the live count of joined members.
class CommunityGroup {
  const CommunityGroup({
    required this.id,
    required this.title,
    required this.icon,
    required this.bg,
    required this.iconColor,
    required this.baseMembers,
  });

  final String id;
  final String title;
  final IconData icon;
  final Color bg;
  final Color iconColor;
  final int baseMembers;
}

/// The catalog of support circles shown in the Community tab.
const List<CommunityGroup> kCommunityGroups = [
  CommunityGroup(
    id: 'pcos-warriors',
    title: 'PCOS Warriors',
    icon: Icons.bubble_chart_rounded,
    bg: Color(0xFFFCE4EC),
    iconColor: Color(0xFFF06292),
    baseMembers: 1200,
  ),
  CommunityGroup(
    id: 'pms-relief',
    title: 'PMS Relief',
    icon: Icons.self_improvement_rounded,
    bg: Color(0xFFE8EAF6),
    iconColor: Color(0xFF7986CB),
    baseMembers: 850,
  ),
  CommunityGroup(
    id: 'hormone-diet',
    title: 'Hormone Diet',
    icon: Icons.restaurant_rounded,
    bg: Color(0xFFE0F2F1),
    iconColor: Color(0xFF4DB6AC),
    baseMembers: 2400,
  ),
  CommunityGroup(
    id: 'endo-support',
    title: 'Endo Support',
    icon: Icons.favorite_rounded,
    bg: Color(0xFFFFF3E0),
    iconColor: Color(0xFFFFB74D),
    baseMembers: 620,
  ),
];

/// Formats a member count like `1.2k` / `850`.
String formatMemberCount(int count) {
  if (count >= 1000) {
    final k = count / 1000.0;
    final text = k.toStringAsFixed(1);
    return '${text.endsWith('.0') ? text.substring(0, text.length - 2) : text}k';
  }
  return '$count';
}
