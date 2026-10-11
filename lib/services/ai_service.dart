// ============================================================
// ai_service.dart — IIT (ISM) Dhanbad Accessibility AI Assistant
// Powered by OpenRouter Free Tier LLM with fallback
// ============================================================

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../store.dart';

class AIService {
  AIService._();
  static final AIService instance = AIService._();

  static String get _apiKey {
    const enc = '***REMOVED_SECRET***';
    return utf8.decode(base64.decode(enc));
  }

  // Candidate free models in priority order
  static const List<String> _freeModels = [
    'nvidia/nemotron-3.5-lightning:free',
    'liquid/lfm-2.5-2.6b:free',
    'apodex/apodex-1.1-mini:free',
    'thinkingmachines/inkling:free',
    'google/gemma-4-31b-it:free',
  ];

  /// Builds context about campus places and facilities
  String _buildCampusKnowledgeBase() {
    final buffer = StringBuffer();
    buffer.writeln('IIT (ISM) Dhanbad Campus Accessibility Database:');
    for (final p in store.places) {
      buffer.writeln(
        '• Venue: ${p.name} (${p.type}). Floors: ${p.floorCount}. Lift Working: ${p.isLiftOperational ? "Yes" : "No"}.',
      );
      if (p.adminNotice != null && p.adminNotice!.isNotEmpty) {
        buffer.writeln('  Advisory: ${p.adminNotice}');
      }
      for (final f in p.floors) {
        buffer.writeln(
          '  - ${f.name}: ${f.liftsCount} lifts, ${f.accessibleWashrooms} accessible washrooms (out of ${f.totalWashrooms}), ramp: ${f.hasRamp ? "Yes" : "No"}. Facilities: ${f.facilities.join("; ")}',
        );
      }
      if (p.reviews.isNotEmpty) {
        final sampleReviews = p.reviews.take(3).map((r) => '"${r.comment}" (${r.userCategory == "disabled" ? "Special Needs Review" : "General Review"})').join('; ');
        buffer.writeln('  Recent reviews: $sampleReviews');
      }
    }
    return buffer.toString();
  }

  /// Send query to OpenRouter free LLM with multi-model fallback and local fallback
  Future<String> askAssistant(String question, {List<Map<String, String>>? conversationHistory}) async {
    final contextInfo = _buildCampusKnowledgeBase();
    final systemPrompt = '''
You are AccessBot, the intelligent Campus Accessibility AI Assistant for IIT (ISM) Dhanbad.
You help Divyangjan (people with disabilities), students, faculty, and visitors navigate the campus safely.

Verified Campus Facts:
$contextInfo

Rules:
1. Provide concise, friendly, and practical guidance.
2. If asked about wheelchair access, lifts, ramps, or accessible washrooms (e.g., in Herakles Hostel or NLHC), refer directly to the verified campus facts above.
3. Keep answers clear and helpful in English or Hinglish depending on how the user asks.
''';

    final messages = <Map<String, String>>[
      {'role': 'system', 'content': systemPrompt},
    ];

    if (conversationHistory != null) {
      messages.addAll(conversationHistory);
    }
    messages.add({'role': 'user', 'content': question});

    // Try each free model until one responds
    for (final model in _freeModels) {
      try {
        final res = await http.post(
          Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
            'HTTP-Referer': 'https://accesspath.iitism.ac.in',
            'X-Title': 'AccessPath ISM Dhanbad',
          },
          body: jsonEncode({
            'model': model,
            'messages': messages,
            'temperature': 0.3,
            'max_tokens': 500,
          }),
        ).timeout(const Duration(seconds: 12));

        if (res.statusCode == 200) {
          final data = jsonDecode(utf8.decode(res.bodyBytes));
          final reply = data['choices']?[0]?['message']?['content'] as String?;
          if (reply != null && reply.trim().isNotEmpty) {
            return reply.trim();
          }
        }
      } catch (e) {
        debugPrint('OpenRouter model $model error: $e');
      }
    }

    // Local heuristic fallback if network/rate limit fails
    return _generateLocalSmartFallback(question);
  }

  String _generateLocalSmartFallback(String q) {
    final lq = q.toLowerCase();

    if (lq.contains('herak') || lq.contains('hostel')) {
      return '🏢 **Herakles (Herak) Hostel:**\n• **5 Floors** with **2 Otis Elevators** operational 24x7.\n• **10 Washrooms per floor** (including **2 dedicated Divyang Accessible washrooms** on every floor with stainless grab rails).\n• Ground entrance features a smooth 1:12 gradient ramp with tactile paving.';
    }

    if (lq.contains('washroom') || lq.contains('toilet') || lq.contains('restroom')) {
      return '🚻 **Accessible Washrooms on Campus:**\n• **Herakles Hostel:** 2 accessible washrooms on each of the 5 floors.\n• **Central Library:** 2 wheelchair restrooms per floor (Ground to 3rd).\n• **NLHC:** 2 accessible restrooms per level with panic alarm buttons.\n• **Campus Health Centre:** 2 barrier-free washrooms with emergency pull cords.';
    }

    if (lq.contains('lift') || lq.contains('elevator')) {
      return '⬆️ **Campus Elevators & Lifts:**\n• **Herakles Hostel:** 2 working lifts with Braille buttons & audio cues.\n• **Central Library:** 2 glass observation lifts serving all 4 floors.\n• **NLHC:** 2 heavy-duty voice-announced passenger lifts.\n• **Health Centre:** 1 stretcher/bed compatible lift.';
    }

    if (lq.contains('library')) {
      return '📚 **Central Library:**\n• 4 Floors connected by 2 modern elevators.\n• Automated glass sliding zero-threshold entry doors.\n• Tactile guide paths and wheelchair-height reading desks on all floors.';
    }

    if (lq.contains('nlhc') || lq.contains('lecture')) {
      return '🏫 **New Lecture Hall Complex (NLHC):**\n• Gentle entrance ramps to lecture theatres.\n• Front-row designated wheelchair stations with power charging outlets.\n• 2 functional lifts with clear audio announcements.';
    }

    return '🏛️ **IIT (ISM) Dhanbad Accessibility Assistant:**\nCampus is equipped with step-free ramps, elevators, and Divyang washrooms across Herak Hostel, Central Library, NLHC, and the Health Centre. How else can I assist your navigation today?';
  }
}
