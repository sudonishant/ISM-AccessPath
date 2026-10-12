// ============================================================
// ai_chat_page.dart — Multimodal Text & Vision AI Assistant
// Features: Passive-Aggressive Sassy Mode, Vision AI Auditing,
// Hilarious Taunts, Emoticons, Smooth Animations
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/ai_service.dart';

class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final String? imagePath;
  final bool isVisionAudit;
  final DateTime time;

  _ChatMessage({
    required this.text,
    required this.isUser,
    this.imagePath,
    this.isVisionAudit = false,
    DateTime? time,
  }) : time = time ?? DateTime.now();
}

class _AIChatPageState extends State<AIChatPage> with SingleTickerProviderStateMixin {
  final TextEditingController _textCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isSassyMode = true; // Passive-aggressive mode enabled by default!
  int _tauntIndex = 0;

  final List<String> _suggestedPrompts = [
    'Herak Hostel me 2nd floor pe washroom accessible hai?',
    'Campus me kaunse hostels me lifts chal rahe hain?',
    'Central Library me wheelchair ramp aur automated doors hain?',
    'NLHC me Divyangjan priority front-row seating hai?',
  ];

  final List<Map<String, String>> _sampleAuditPhotos = [
    {'name': '♿ Entrance Ramp', 'path': 'assets/reviews/herak_ramp.jpeg'},
    {'name': '🛗 Otis Passenger Lift', 'path': 'assets/reviews/herak_lift.jpeg'},
    {'name': '🚻 Divyang Toilet', 'path': 'assets/reviews/accessible_toilet.jpeg'},
    {'name': '🏢 Accessible Corridor', 'path': 'assets/reviews/hostel_corridor.jpeg'},
  ];

  @override
  void initState() {
    super.initState();
    _messages.add(
      _ChatMessage(
        text: _isSassyMode
            ? 'Oh great, another human! 💅 I’m SassyBot — IIT (ISM) Dhanbad’s passive-aggressive AI.\n\nAsk me about campus ramps, elevators, or public washrooms. Try not to ask if elevators go horizontally. 🙄✨'
            : 'Namaste! 🙏 Mai AccessBot hoon — IIT (ISM) Dhanbad ka AI Accessibility Assistant.\n\nAap campus ke kisi bhi building, Herak hostel ke lifts, Divyang washrooms, ya ramps ke baare me pooch sakte hain.',
        isUser: false,
      ),
    );
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _cycleTaunt() {
    setState(() {
      _tauntIndex = (_tauntIndex + 1) % AIService.passiveAggressiveTaunts.length;
    });
  }

  Future<void> _sendMessage(String text) async {
    final query = text.trim();
    if (query.isEmpty || _isLoading) return;

    _textCtrl.clear();
    setState(() {
      _messages.add(_ChatMessage(text: query, isUser: true));
      _isLoading = true;
    });
    _scrollToBottom();

    // Prepare history
    final history = _messages
        .take(_messages.length - 1)
        .map((m) => {
              'role': m.isUser ? 'user' : 'assistant',
              'content': m.text,
            })
        .toList();

    try {
      final answer = await AIService.instance.askAssistant(
        query,
        conversationHistory: history,
        isPassiveAggressive: _isSassyMode,
      );
      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(text: answer, isUser: false));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(
            text: _isSassyMode
                ? 'Network disconnected. Looks like your internet is as reliable as a Dhanbad electricity cut 💀☕'
                : 'Maaf karein, network error ki wajah se reply nahi mil paya. Kripya punah prayas karein.',
            isUser: false,
          ));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  /// Vision AI Model: Analyze photo of campus ramp, lift, or washroom
  Future<void> _runVisionAudit(String imagePath, String label) async {
    if (_isLoading) return;

    setState(() {
      _messages.add(_ChatMessage(
        text: '📸 Auditing $label with Multimodal Vision AI...',
        isUser: true,
        imagePath: imagePath,
        isVisionAudit: true,
      ));
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      // Load bytes from asset
      final byteData = await rootBundle.load(imagePath);
      final bytes = byteData.buffer.asUint8List();
      final base64Image = base64Encode(bytes);

      final auditResult = await AIService.instance.analyzeVisionPhoto(
        imageBase64: base64Image,
        prompt: 'Perform detailed accessibility structural compliance audit on this $label.',
        isPassiveAggressive: _isSassyMode,
      );

      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(
            text: auditResult,
            isUser: false,
            isVisionAudit: true,
          ));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(
            text: 'Vision AI Audit Error: $e',
            isUser: false,
          ));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _showVisionPhotoSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '📸 Multimodal Vision AI Audit',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Text(
                  'Select a campus accessibility photo for real-time AI structural inspection (Ramp gradient, grab rails, door clearance):',
                  style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                ),
                const SizedBox(height: 16),
                ..._sampleAuditPhotos.map((item) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: Colors.white10),
                      ),
                      tileColor: const Color(0xFF1E293B),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          item['path']!,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.image, color: Colors.white54),
                        ),
                      ),
                      title: Text(
                        item['name']!,
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      trailing: const Icon(Icons.auto_awesome, color: Color(0xFFFF6B2B), size: 18),
                      onTap: () {
                        Navigator.pop(ctx);
                        _runVisionAudit(item['path']!, item['name']!);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentTaunt = AIService.passiveAggressiveTaunts[_tauntIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isSassyMode
                      ? [const Color(0xFFFF6B2B), const Color(0xFFFF8E53)]
                      : [const Color(0xFF00F0FF), const Color(0xFF14B8A6)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (_isSassyMode ? const Color(0xFFFF6B2B) : const Color(0xFF00F0FF)).withValues(alpha: 0.4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(
                _isSassyMode ? Icons.sentiment_very_satisfied_rounded : Icons.auto_awesome,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isSassyMode ? 'SassyBot AI 💅' : 'AccessBot AI 🤖',
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Text(
                  _isSassyMode ? 'Passive-Aggressive Mode • Text & Vision' : 'Helpful Assistant • Text & Vision',
                  style: TextStyle(
                    color: _isSassyMode ? const Color(0xFFFF8E53) : const Color(0xFF00F0FF),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Sassy / Passive-Aggressive Mode Toggle
          GestureDetector(
            onTap: () {
              setState(() => _isSassyMode = !_isSassyMode);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isSassyMode
                      ? '💅 Passive-Aggressive Sassy Mode Activated!'
                      : '😇 Polite Assistant Mode Activated!'),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _isSassyMode
                    ? const Color(0xFFFF6B2B).withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isSassyMode ? const Color(0xFFFF6B2B) : Colors.white24,
                ),
              ),
              child: Row(
                children: [
                  Text(_isSassyMode ? '💅 Sassy' : '😇 Calm',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: _isSassyMode ? const Color(0xFFFF6B2B) : Colors.white70,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Passive-Aggressive Witty Taunts Banner Ticker
          if (_isSassyMode)
            GestureDetector(
              onTap: _cycleTaunt,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1624),
                  border: Border(
                    bottom: BorderSide(color: const Color(0xFFFF6B2B).withValues(alpha: 0.3)),
                  ),
                ),
                child: Row(
                  children: [
                    const Text('💅', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        currentTaunt,
                        style: const TextStyle(
                          color: Color(0xFFFFD8BF),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.refresh_rounded, size: 14, color: Color(0xFFFF8E53)),
                  ],
                ),
              ),
            ),

          // Chat Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final m = _messages[i];
                return _buildMessageBubble(m);
              },
            ),
          ),

          // Loading Typing Indicator
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131F37),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF6B2B)),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isSassyMode ? 'SassyBot is judging your query... 🙄' : 'Analyzing campus database...',
                          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Suggested Prompts Carousel
          if (_messages.length <= 2 && !_isLoading)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: _suggestedPrompts.map((p) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      backgroundColor: const Color(0xFF131F37),
                      side: const BorderSide(color: Colors.white12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      label: Text(
                        p,
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                      onPressed: () => _sendMessage(p),
                    ),
                  );
                }).toList(),
              ),
            ),

          // Input Bar with Camera Vision Button
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              border: Border(top: BorderSide(color: Colors.white10)),
            ),
            child: Row(
              children: [
                // Vision AI Camera Button
                IconButton(
                  icon: const Icon(Icons.camera_alt_rounded, color: Color(0xFFFF6B2B), size: 24),
                  tooltip: 'Audit photo with Multimodal Vision AI',
                  onPressed: _showVisionPhotoSelector,
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: TextField(
                      controller: _textCtrl,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: _isSassyMode
                            ? 'Ask SassyBot (or upload a photo) 💅...'
                            : 'Ask about ramps, lifts, washrooms...',
                        hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                        border: InputBorder.none,
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF6B2B),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 18),
                  ),
                  onPressed: () => _sendMessage(_textCtrl.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage m) {
    if (m.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12, left: 48),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B2B), Color(0xFFFF8E53)],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF6B2B).withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (m.imagePath != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    m.imagePath!,
                    width: 180,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Text(
                m.text,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      );
    }

    // Assistant reply
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, right: 36),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF131B2E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: m.isVisionAudit
                ? const Color(0xFFFF6B2B).withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  m.isVisionAudit ? Icons.document_scanner_rounded : Icons.auto_awesome,
                  size: 13,
                  color: const Color(0xFFFF6B2B),
                ),
                const SizedBox(width: 6),
                Text(
                  m.isVisionAudit ? 'Vision AI Audit Report' : (_isSassyMode ? 'SassyBot 💅' : 'AccessBot AI 🤖'),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF6B2B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SelectableText(
              m.text,
              style: const TextStyle(
                color: Color(0xFFE2E8F0),
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
