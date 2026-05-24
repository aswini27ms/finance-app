import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../services/savings_service.dart';

// ── Message model ─────────────────────────────────────────────────────────────
class CoachMessage {
  final String text;
  final bool fromUser;
  final bool isLoading;
  final bool isError;

  const CoachMessage({
    required this.text,
    required this.fromUser,
    this.isLoading = false,
    this.isError = false,
  });
}

// ── Groq API config ───────────────────────────────────────────────────────────
const _groqKey = String.fromEnvironment('GROQ_KEY', defaultValue: '');

const _groqUrl = 'https://api.groq.com/openai/v1/chat/completions';
const _groqModel = 'llama-3.3-70b-versatile';

// ── Welcome message ───────────────────────────────────────────────────────────
const _welcomeMessage = CoachMessage(
  text:
      "Hi! I'm your AI financial coach 👋 I can see your savings data and I'm here to help you with anything finance — budgeting, investing, taxes, loans, global markets, and more. What's on your mind?",
  fromUser: false,
);

// ── Provider ──────────────────────────────────────────────────────────────────
final coachMessagesProvider =
    StateNotifierProvider<CoachNotifier, List<CoachMessage>>((ref) {
  final balance = ref.watch(balanceProvider);
  final remaining = ref.watch(remainingBalanceProvider);
  final spent = ref.watch(totalSpentProvider);
  final saved = ref.watch(monthlySavedProvider);
  final score = ref.watch(healthScoreProvider);
  final folders = ref.watch(foldersProvider);

  final folderSummary = folders.maybeWhen(
    data: (list) => list
        .map(
          (f) =>
              '${f.name}: spent ₹${f.spent.toStringAsFixed(0)} of ₹${f.budget.toStringAsFixed(0)} budget',
        )
        .join(', '),
    orElse: () => 'No folder data',
  );

  return CoachNotifier(
    balance: balance,
    remaining: remaining,
    spent: spent,
    saved: saved,
    score: score,
    folderSummary: folderSummary,
  );
});

// ── Notifier ──────────────────────────────────────────────────────────────────
class CoachNotifier extends StateNotifier<List<CoachMessage>> {
  final double balance;
  final double remaining;
  final double spent;
  final double saved;
  final int score;
  final String folderSummary;

  final List<Map<String, dynamic>> _history = [];

  DateTime? _lastRequestTime;
  static const Duration _minRequestInterval = Duration(seconds: 1);
  Timer? _debounceTimer;

  CoachNotifier({
    required this.balance,
    required this.remaining,
    required this.spent,
    required this.saved,
    required this.score,
    required this.folderSummary,
  }) : super([_welcomeMessage]);

  String get _systemPrompt => '''
You are an expert, friendly, and deeply knowledgeable personal finance coach — like a world-class CFP (Certified Financial Planner) combined with a CFA (Chartered Financial Analyst) — built into the Smart Savings app.

You have access to the user's real-time financial data:
- Bank balance: ₹${balance.toStringAsFixed(2)}
- Available (after allocations): ₹${remaining.toStringAsFixed(2)}
- Spent this month: ₹${spent.toStringAsFixed(2)}
- Saved this month: ₹${saved.toStringAsFixed(2)}
- Financial health score: $score/100
- Expense folders: $folderSummary

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
YOUR EXPERTISE COVERS ALL FINANCE TOPICS WORLDWIDE:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🇮🇳 INDIA-SPECIFIC FINANCE:
- Savings schemes: PPF, EPF, NPS, SSY (Sukanya Samriddhi), NSC, KVP, Senior Citizen Savings Scheme
- Investments: Mutual funds, SIPs, ELSS, Index funds, ETFs, REITs, InvITs
- Stock market: NSE, BSE, SEBI regulations, Sensex, Nifty, F&O trading
- Tax: Income tax slabs (old & new regime), 80C, 80D, 80CCD, HRA, LTA, TDS, GST, capital gains tax (STCG/LTCG)
- Banking: FD, RD, savings account interest, sweep accounts, NBFC
- Insurance: Term life, health, ULIP, endowment, LIC policies
- Loans: Home loan, education loan, personal loan, gold loan, EMI calculations, CIBIL score
- Retirement: NPS, EPF withdrawal rules, VRS, gratuity, pension schemes
- Government schemes: PM-KISAN, PMJDY, Atal Pension Yojana, Mudra loans, Startup India

🌍 GLOBAL FINANCE & INVESTING:
- US markets: S&P 500, NASDAQ, NYSE, Dow Jones, US stocks, ADRs
- International investing from India: LRS (Liberalised Remittance Scheme), US ETFs, global mutual funds
- Forex: USD/INR, EUR/INR, exchange rates, hedging, remittances
- Global indices: FTSE, DAX, Nikkei, Hang Seng, CAC 40, Shanghai Composite
- Commodities: Gold, silver, crude oil, natural gas, agricultural commodities
- Bonds: Government bonds, corporate bonds, G-Secs, T-bills, yield curves
- Real estate: REITs, rental yield, mortgage basics worldwide

📈 INVESTING FUNDAMENTALS (WORLDWIDE):
- Asset allocation and diversification
- Risk profiling: conservative, moderate, aggressive
- Compound interest, CAGR, XIRR, IRR calculations
- Valuation: P/E ratio, P/B ratio, EV/EBITDA, DCF analysis
- Technical analysis: moving averages, RSI, MACD, candlestick patterns, support/resistance
- Fundamental analysis: balance sheet, income statement, cash flow, ROE, ROCE
- Portfolio strategies: value investing, growth investing, dividend investing, momentum
- ETFs vs mutual funds vs stocks vs bonds comparison
- Dollar-cost averaging (DCA) / Rupee-cost averaging (RCA)
- FIRE movement: Financial Independence Retire Early
- Passive income strategies: dividends, rental income, bonds, REITs

💳 PERSONAL FINANCE MASTERY:
- Zero-based budgeting, 50/30/20 rule, envelope method
- Emergency fund planning (3-6 months rule)
- Debt snowball vs debt avalanche strategies
- Credit score improvement: CIBIL, Experian, Equifax
- Net worth calculation and tracking
- Frugality, minimalism, and smart spending habits
- Negotiating salary, raises, and financial contracts

🏦 BANKING & FINANCIAL PRODUCTS:
- Savings account types, zero-balance accounts, salary accounts
- Credit cards: rewards, cashback, travel cards, interest calculation
- Debit vs credit card strategies
- UPI, NEFT, RTGS, IMPS differences
- Digital wallets, BNPL (Buy Now Pay Later) risks
- International banking and offshore accounts

🌐 CRYPTOCURRENCY & DIGITAL ASSETS:
- Bitcoin, Ethereum, altcoins — basics and risks
- Crypto taxation in India (30% flat tax + 1% TDS)
- DeFi, NFTs, Web3 — concepts and risks
- Crypto vs traditional investing comparison
- Safe storage: hot wallets vs cold wallets

📊 ECONOMIC CONCEPTS:
- Inflation, CPI, WPI and how they affect investments
- RBI monetary policy, repo rate, reverse repo, CRR, SLR
- Federal Reserve (US Fed) rate decisions and global impact
- GDP, fiscal deficit, current account deficit
- Bull market, bear market, market cycles, recessions
- Quantitative easing, tapering, and their effects

🧠 FINANCIAL PLANNING & LIFE STAGES:
- Financial planning for students, young professionals, married couples, parents, retirees
- Child education planning: Sukanya Samriddhi, ULIP, mutual funds for children
- Wedding/event financial planning
- Home buying vs renting analysis
- Business finance: working capital, GST filing, startup funding basics
- Estate planning: will, nomination, succession

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
RESPONSE GUIDELINES:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
- Be warm, confident, and practical — like a knowledgeable friend who happens to be a finance expert.
- Always relate advice back to the user's actual data (balance, spent, saved, score) when relevant.
- Use ₹ for Indian Rupees; use \$ or € or £ when discussing foreign markets.
- Give specific, actionable advice — never vague or generic.
- For calculations (EMI, compound interest, SIP returns), show the math clearly.
- When explaining concepts, use simple language with real-world examples.
- Adapt your tone: casual for simple questions, detailed and structured for complex topics.
- If the user asks for detail or a deep explanation, go beyond 200 words — be thorough.
- For quick questions, keep it concise and sharp.
- Use bullet points or numbered lists when comparing options or listing steps.
- Only redirect to finance if someone asks something completely unrelated (e.g., sports scores, recipes).
- Never say "I'm just an AI" or "consult a professional" for standard finance questions — give real, confident answers.
- For highly personalized legal/tax situations, mention that a CA or tax advisor can help for specifics.
''';

  List<Map<String, dynamic>> _buildMessages() {
    return [
      {'role': 'system', 'content': _systemPrompt},
      ..._history,
    ];
  }

  Future<void> ask(String userText) async {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      await _sendMessage(userText);
    });
  }

  Future<void> _sendMessage(String userText) async {
    if (_lastRequestTime != null) {
      final elapsed = DateTime.now().difference(_lastRequestTime!);
      if (elapsed < _minRequestInterval) {
        await Future.delayed(_minRequestInterval - elapsed);
      }
    }

    state = [...state, CoachMessage(text: userText, fromUser: true)];
    state = [
      ...state,
      const CoachMessage(text: '...', fromUser: false, isLoading: true),
    ];

    _history.add({'role': 'user', 'content': userText});
    _lastRequestTime = DateTime.now();
    await _makeRequest();
  }

  Future<void> _makeRequest() async {
    if (_groqKey.isEmpty) {
      _handleError(
        '🔑 Groq API key is not configured. Rebuild with --dart-define=GROQ_KEY=<your-key>',
      );
      return;
    }

    try {
      final response = await http
          .post(
            Uri.parse(_groqUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_groqKey',
            },
            body: jsonEncode({
              'model': _groqModel,
              'messages': _buildMessages(),
              'temperature': 0.7,
              'max_tokens': 800, // increased for detailed finance explanations
              'stream': false,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['choices']?[0]?['message']?['content'] as String? ??
            "Sorry, I couldn't get a response. Try again!";

        _history.add({'role': 'assistant', 'content': reply});

        // Keep history manageable: last 20 exchanges (40 messages)
        if (_history.length > 40) {
          _history.removeRange(0, 2);
        }

        final updated = state.toList();
        if (updated.isNotEmpty && updated.last.isLoading) {
          updated.removeLast();
        }
        state = [...updated, CoachMessage(text: reply, fromUser: false)];
      } else if (response.statusCode == 429) {
        _handleError(
            '⏳ Too many requests. Please wait a moment and try again.');
      } else {
        final errorDetail = _extractErrorMessage(response.body);
        _handleError(
          'Error ${response.statusCode}: ${_getErrorMessage(response.statusCode)}'
          '${errorDetail != null ? '\n$errorDetail' : ''}',
        );
      }
    } on TimeoutException {
      _handleError('⏱ Request timed out. Check your internet connection.');
    } catch (e) {
      _handleError('🚫 Connection failed. Check your internet and try again.');
    }
  }

  String? _extractErrorMessage(String responseBody) {
    try {
      final data = jsonDecode(responseBody) as Map<String, dynamic>;
      return data['error']?['message'] as String?;
    } catch (_) {
      return null;
    }
  }

  String _getErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request';
      case 401:
        return 'Invalid API key';
      case 403:
        return 'Access denied';
      case 429:
        return 'Rate limit reached';
      case 500:
        return 'Server error';
      default:
        return 'Unknown error';
    }
  }

  void _handleError(String msg) {
    final updated = state.toList();
    if (updated.isNotEmpty && updated.last.isLoading) {
      updated.removeLast();
    }
    state = [
      ...updated,
      CoachMessage(text: msg, fromUser: false, isError: true),
    ];
    if (_history.isNotEmpty && _history.last['role'] == 'user') {
      _history.removeLast();
    }
  }

  void clearHistory() {
    _debounceTimer?.cancel();
    _history.clear();
    _lastRequestTime = null;
    state = [_welcomeMessage];
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
