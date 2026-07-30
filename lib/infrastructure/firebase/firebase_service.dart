import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:logger/logger.dart';

import '../../domain/entities/challenge.dart';
import '../../domain/entities/comment.dart';
import '../../domain/entities/user_proposal.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();

  late final FirebaseAuth _auth;
  late final FirebaseFirestore _firestore;
  late final Logger _logger;

  FirebaseService._internal() {
    _auth = FirebaseAuth.instance;
    // Firebaseプロジェクト（apps2-752cb）は他アプリと共用のため、Firestoreは
    // "(default)"ではなく本アプリ専用の名前付きデータベース"japanfuturemap"を使う。
    // 未指定だと(default)につながり、japanfuturemap側にだけ公開したルールが
    // 効かずPERMISSION_DENIEDになるので注意（2026-07-27に発覚）。
    _firestore = FirebaseFirestore.instanceFor(
      app: Firebase.app(),
      databaseId: 'japanfuturemap',
    );
    // オフライン時も直近のデータを表示・投票やコメントの下書き送信ができるよう、
    // ローカルキャッシュと書き込みキューを明示的に有効化する（モバイルではデフォルトでも有効だが明示）
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    _logger = Logger();
  }

  factory FirebaseService() {
    return _instance;
  }

  // 匿名認証
  Future<String?> signInAnonymously() async {
    try {
      final credential = await _auth.signInAnonymously();
      _logger.i('Anonymous sign in successful: ${credential.user?.uid}');
      return credential.user?.uid;
    } catch (e) {
      _logger.e('Anonymous sign in failed: $e');
      return null;
    }
  }

  // 現在のユーザー UID を取得
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  // 課題一覧を取得
  Future<List<Challenge>> getChallenges() async {
    try {
      final snapshot = await _firestore
          .collection('challenges')
          .where('status', isEqualTo: 'published')
          .limit(10)
          .get();

      return snapshot.docs.map((doc) => _challengeFromFirestore(doc)).toList();
    } catch (e) {
      _logger.e('Error fetching challenges: $e');
      return [];
    }
  }

  // 課題に「賛同」をする
  Future<bool> agreeChallenge(String userId, String challengeId) async {
    try {
      await _firestore
          .collection('challenges')
          .doc(challengeId)
          .collection('agrees')
          .doc(userId)
          .set({'userId': userId, 'timestamp': FieldValue.serverTimestamp()});

      // 賛同数を増加
      // 課題ドキュメント自体はFirestoreに事前作成されていない（一覧はモックデータ表示のため）ので、
      // update()だと対象ドキュメント不在でNOT_FOUNDになる。set()+mergeで無ければ作成する。
      await _firestore.collection('challenges').doc(challengeId).set({
        'agreeCount': FieldValue.increment(1),
      }, SetOptions(merge: true));

      _logger.i('Agree recorded for challenge: $challengeId');
      return true;
    } catch (e) {
      _logger.e('Error agreeing challenge: $e');
      return false;
    }
  }

  // 課題データ（ローカルモック）
  static List<Challenge> getMockChallenges() {
    return [
      Challenge(
        id: 'my_pension_balance',
        name: 'あなたの年金は得？損？',
        description: '年齢を入力するだけで、あなた自身の生涯年金損益がわかります',
        category: 'welfare',
        voteCount: 0,
        agreeCount: 0,
        generationAgreement: {
          '20s': 0.90,
          '30s': 0.88,
          '40s': 0.82,
          '50s': 0.70,
          '60s+': 0.55,
        },
        status: 'published',
        createdAt: DateTime(2026, 1, 10),
        tags: ['年金'],
      ),
      // ── 本質的な課題（多くの症状の根っこにある構造的な原因）──
      Challenge(
        id: 'silver_democracy',
        name: 'シルバー民主主義',
        description: '有権者の多数を高齢者が占め、政策が高齢世代に偏り負担が将来へ先送りされる構造',
        category: 'structural',
        voteCount: 0,
        agreeCount: 0,
        generationAgreement: {
          '20s': 0.90,
          '30s': 0.86,
          '40s': 0.78,
          '50s': 0.62,
          '60s+': 0.38,
        },
        status: 'published',
        createdAt: DateTime(2026, 1, 12),
        tags: ['政治', '選挙', '人口', '年金'],
      ),
      Challenge(
        id: 'low_labor_productivity',
        name: '労働生産性の低さ',
        description: '時間あたり労働生産性がG7最下位。長時間労働で量を補う構造が賃金停滞の根本原因',
        category: 'structural',
        voteCount: 0,
        agreeCount: 0,
        generationAgreement: {
          '20s': 0.78,
          '30s': 0.82,
          '40s': 0.80,
          '50s': 0.70,
          '60s+': 0.58,
        },
        status: 'published',
        createdAt: DateTime(2026, 1, 14),
        tags: ['雇用', '格差', '中小企業'],
      ),
      Challenge(
        id: 'unmarried_structure',
        name: '未婚化・晩婚化の進行',
        description: '結婚・出産の経済的・時間的ハードルの高さが、人口減少や年金問題の根っこにある',
        category: 'structural',
        voteCount: 0,
        agreeCount: 0,
        generationAgreement: {
          '20s': 0.84,
          '30s': 0.88,
          '40s': 0.80,
          '50s': 0.66,
          '60s+': 0.52,
        },
        status: 'published',
        createdAt: DateTime(2026, 1, 16),
        tags: ['人口', '子育て', '雇用'],
      ),
      Challenge(
        id: 'reform_deferral',
        name: '改革の先送り体質',
        description: '短期的な痛みを避け抜本改革を先送りする政治・行政の構造が、多くの課題を放置させている',
        category: 'structural',
        voteCount: 0,
        agreeCount: 0,
        generationAgreement: {
          '20s': 0.82,
          '30s': 0.84,
          '40s': 0.80,
          '50s': 0.70,
          '60s+': 0.55,
        },
        status: 'published',
        createdAt: DateTime(2026, 1, 18),
        tags: ['政治', '財政', '選挙'],
      ),
      Challenge(
        id: 'bureaucracy_influence',
        name: '官僚機構の影響力（財務省など）',
        description: '選挙で選ばれない官僚が予算編成などを通じて政策に大きな影響力を持つ、との指摘がある',
        category: 'structural',
        voteCount: 0,
        agreeCount: 0,
        generationAgreement: {
          '20s': 0.80,
          '30s': 0.83,
          '40s': 0.79,
          '50s': 0.68,
          '60s+': 0.52,
        },
        status: 'published',
        createdAt: DateTime(2026, 1, 20),
        tags: ['政治', '財政', '税金'],
      ),
      Challenge(
        id: 'money_in_politics',
        name: '政治とカネの構造',
        description: '企業・団体献金や組織票が政策をゆがめ、有権者より業界の利益が優先されやすい構造',
        category: 'structural',
        voteCount: 0,
        agreeCount: 0,
        generationAgreement: {
          '20s': 0.83,
          '30s': 0.85,
          '40s': 0.80,
          '50s': 0.70,
          '60s+': 0.55,
        },
        status: 'published',
        createdAt: DateTime(2026, 1, 22),
        tags: ['政治', '選挙', '税金'],
      ),
      Challenge(
        id: 'press_independence',
        name: '報道と権力の距離',
        description: '記者クラブ制度などにより報道機関が権力を厳しく監視しにくい、との指摘がある',
        category: 'structural',
        voteCount: 0,
        agreeCount: 0,
        generationAgreement: {
          '20s': 0.74,
          '30s': 0.76,
          '40s': 0.70,
          '50s': 0.60,
          '60s+': 0.46,
        },
        status: 'published',
        createdAt: DateTime(2026, 1, 24),
        tags: ['政治', '選挙'],
      ),
      Challenge(
        id: 'electoral_wasted_votes',
        name: '小選挙区制と死票の多さ',
        description: '1票しか当選しない小選挙区制のもとで、当選に結びつかない「死票」が得票の半数近くに達する',
        category: 'structural',
        voteCount: 0,
        agreeCount: 0,
        generationAgreement: {
          '20s': 0.76,
          '30s': 0.78,
          '40s': 0.72,
          '50s': 0.62,
          '60s+': 0.48,
        },
        status: 'published',
        createdAt: DateTime(2026, 1, 26),
        tags: ['選挙', '政治'],
      ),
      Challenge(
        id: 'amakudari_structure',
        name: '天下りの構造',
        description: '退職した官僚が、かつて監督していた業界の企業や団体に再就職する慣行が利益相反を生みうる',
        category: 'structural',
        voteCount: 0,
        agreeCount: 0,
        generationAgreement: {
          '20s': 0.72,
          '30s': 0.75,
          '40s': 0.70,
          '50s': 0.60,
          '60s+': 0.48,
        },
        status: 'published',
        createdAt: DateTime(2026, 1, 28),
        tags: ['政治', '税金'],
      ),
      Challenge(
        id: 'local_fiscal_dependency',
        name: '中央集権と地方の財源不足（三割自治）',
        description: '地方自治体の歳出の多くが国からの交付金・補助金に依存し、自主的な政策判断がしにくい構造',
        category: 'structural',
        voteCount: 0,
        agreeCount: 0,
        generationAgreement: {
          '20s': 0.55,
          '30s': 0.60,
          '40s': 0.65,
          '50s': 0.68,
          '60s+': 0.62,
        },
        status: 'published',
        createdAt: DateTime(2026, 1, 30),
        tags: ['地方', '財政'],
        budgetTrillionYen: 20.9, // 地方交付税交付金等（令和8年度一般会計）
      ),
      Challenge(
        id: 'policy_evaluation_weakness',
        name: '政策評価・検証の甘さ',
        description: '実施した政策の効果を厳しく検証し、失敗を認めて修正する仕組みが弱く、同じ失敗が繰り返されやすい',
        category: 'structural',
        voteCount: 0,
        agreeCount: 0,
        generationAgreement: {
          '20s': 0.70,
          '30s': 0.74,
          '40s': 0.72,
          '50s': 0.65,
          '60s+': 0.55,
        },
        status: 'published',
        createdAt: DateTime(2026, 2, 1),
        tags: ['政治', '財政'],
      ),
      Challenge(
        id: 'vote_value_disparity',
        name: '一票の格差',
        description: '選挙区によって議員1人あたりの有権者数が異なり、住む場所で「1票の価値」に差がある',
        category: 'structural',
        voteCount: 0,
        agreeCount: 0,
        generationAgreement: {
          '20s': 0.78,
          '30s': 0.80,
          '40s': 0.75,
          '50s': 0.65,
          '60s+': 0.52,
        },
        status: 'published',
        createdAt: DateTime(2026, 2, 3),
        tags: ['選挙', '政治', '地方'],
      ),
      Challenge(
        id: 'hereditary_politicians',
        name: '世襲政治',
        description: '国会議員の地盤・看板・カバンを親族が引き継ぐ「世襲」が突出して多く、政治への新規参入を阻む',
        category: 'structural',
        voteCount: 0,
        agreeCount: 0,
        generationAgreement: {
          '20s': 0.85,
          '30s': 0.86,
          '40s': 0.80,
          '50s': 0.68,
          '60s+': 0.52,
        },
        status: 'published',
        createdAt: DateTime(2026, 2, 5),
        tags: ['選挙', '政治'],
      ),
      Challenge(
        id: 'ministry_silos',
        name: '縦割り行政',
        description: '省庁ごとの権限・予算の縦割りが強く、複数省庁にまたがる課題への対応が遅れがちになる',
        category: 'structural',
        voteCount: 0,
        agreeCount: 0,
        generationAgreement: {
          '20s': 0.72,
          '30s': 0.76,
          '40s': 0.74,
          '50s': 0.66,
          '60s+': 0.55,
        },
        status: 'published',
        createdAt: DateTime(2026, 2, 7),
        tags: ['政治', '財政'],
      ),
      Challenge(
        id: 'kantei_led_politics',
        name: '官邸主導と「忖度」の構造',
        description: '内閣人事局による幹部人事の一元化以降、官僚が官邸の意向を過度に忖度しやすくなった、との指摘がある',
        category: 'structural',
        voteCount: 0,
        agreeCount: 0,
        generationAgreement: {
          '20s': 0.75,
          '30s': 0.78,
          '40s': 0.74,
          '50s': 0.63,
          '60s+': 0.48,
        },
        status: 'published',
        createdAt: DateTime(2026, 2, 9),
        tags: ['政治', '選挙'],
      ),
      Challenge(
        id: 'income_stagnation',
        name: '所得の停滞',
        description: '過去30年間、実質賃金が増加していない',
        category: 'economy',
        voteCount: 0,
        agreeCount: 0,
        generationAgreement: {
          '20s': 0.75,
          '30s': 0.82,
          '40s': 0.85,
          '50s': 0.78,
          '60s+': 0.68,
        },
        status: 'published',
        createdAt: DateTime(2026, 1, 15),
        tags: ['雇用', '格差', '税金'],
      ),
      Challenge(
        id: 'pension_crisis',
        name: '年金危機',
        description: '2050年までに年金積立金が枯渇する予測',
        category: 'welfare',
        voteCount: 0,
        agreeCount: 0,
        generationAgreement: {
          '20s': 0.92,
          '30s': 0.88,
          '40s': 0.82,
          '50s': 0.75,
          '60s+': 0.45,
        },
        status: 'published',
        createdAt: DateTime(2026, 2, 10),
        tags: ['年金', '財政'],
      ),
      Challenge(
        id: 'population_decline',
        name: '人口減少',
        description: '2070年までに人口が20%減少する予測',
        category: 'demographic',
        voteCount: 0,
        agreeCount: 0,
        generationAgreement: {
          '20s': 0.65,
          '30s': 0.72,
          '40s': 0.80,
          '50s': 0.85,
          '60s+': 0.55,
        },
        status: 'published',
        createdAt: DateTime(2026, 1, 20),
        tags: ['人口', '地方'],
      ),
      Challenge(
        id: 'politician_salary',
        name: '政治家の待遇',
        description: '国会議員の給与・特権が一般国民の4倍以上',
        category: 'politics',
        voteCount: 0,
        agreeCount: 0,
        generationAgreement: {
          '20s': 0.58,
          '30s': 0.65,
          '40s': 0.72,
          '50s': 0.68,
          '60s+': 0.48,
        },
        status: 'published',
        createdAt: DateTime(2026, 2, 5),
        tags: ['政治', '税金'],
      ),
      Challenge(
        id: 'national_debt',
        name: '国債残高',
        description: 'GDP比264%の国債残高（世界最悪）',
        category: 'debt',
        voteCount: 0,
        agreeCount: 0,
        generationAgreement: {
          '20s': 0.70,
          '30s': 0.76,
          '40s': 0.82,
          '50s': 0.80,
          '60s+': 0.52,
        },
        status: 'published',
        createdAt: DateTime(2026, 1, 25),
        tags: ['財政', '税金'],
        budgetTrillionYen: 31.3, // 国債費（令和8年度一般会計）
      ),
      Challenge(
        id: 'child_poverty',
        name: '子供の貧困',
        description: '子供の約9人に1人が相対的貧困状態にある',
        category: 'welfare',
        voteCount: 0,
        agreeCount: 0,
        generationAgreement: {
          '20s': 0.80,
          '30s': 0.88,
          '40s': 0.85,
          '50s': 0.70,
          '60s+': 0.60,
        },
        status: 'published',
        createdAt: DateTime(2026, 3, 1),
        tags: ['子育て', '貧困', '格差'],
      ),
      Challenge(
        id: 'regional_extinction',
        name: '地方の消滅可能性',
        description: '若年女性人口の減少で消滅可能性がある自治体が4割超',
        category: 'demographic',
        voteCount: 0,
        agreeCount: 0,
        generationAgreement: {
          '20s': 0.55,
          '30s': 0.62,
          '40s': 0.70,
          '50s': 0.75,
          '60s+': 0.72,
        },
        status: 'published',
        createdAt: DateTime(2026, 3, 5),
        tags: ['地方', '人口'],
      ),
      Challenge(
        id: 'healthcare_cost',
        name: '医療費の増大',
        description: '高齢化で医療費が膨張し、現役世代の保険料負担が増加',
        category: 'welfare',
        voteCount: 0,
        agreeCount: 0,
        generationAgreement: {
          '20s': 0.68,
          '30s': 0.75,
          '40s': 0.78,
          '50s': 0.72,
          '60s+': 0.50,
        },
        status: 'published',
        createdAt: DateTime(2026, 3, 8),
        tags: ['医療', '税金'],
      ),
      Challenge(
        id: 'education_gap',
        name: '教育格差',
        description: '家庭の所得によって大学進学率に大きな差がある',
        category: 'economy',
        voteCount: 0,
        agreeCount: 0,
        generationAgreement: {
          '20s': 0.72,
          '30s': 0.78,
          '40s': 0.74,
          '50s': 0.62,
          '60s+': 0.50,
        },
        status: 'published',
        createdAt: DateTime(2026, 3, 10),
        tags: ['教育', '格差'],
        budgetTrillionYen: 6.0, // 文教及び科学振興費（令和8年度一般会計）
      ),
      Challenge(
        id: 'women_in_politics',
        name: '女性議員比率の低さ',
        description: '国会議員に占める女性の割合は主要国で最低水準',
        category: 'politics',
        voteCount: 0,
        agreeCount: 0,
        generationAgreement: {
          '20s': 0.70,
          '30s': 0.68,
          '40s': 0.60,
          '50s': 0.52,
          '60s+': 0.40,
        },
        status: 'published',
        createdAt: DateTime(2026, 3, 12),
        tags: ['ジェンダー', '政治', '選挙'],
      ),
      Challenge(
        id: 'energy_dependency',
        name: 'エネルギー自給率の低さ',
        description: '化石燃料の大半を輸入に依存し、資源価格の変動に脆弱',
        category: 'economy',
        voteCount: 0,
        agreeCount: 0,
        generationAgreement: {
          '20s': 0.62,
          '30s': 0.68,
          '40s': 0.70,
          '50s': 0.65,
          '60s+': 0.55,
        },
        status: 'published',
        createdAt: DateTime(2026, 3, 15),
        tags: ['エネルギー', '財政'],
      ),
      Challenge(
        id: 'elderly_medical_burden',
        name: '後期高齢者医療費負担',
        description: '75歳以上の医療費が膨張し、現役世代の支援金負担が増加',
        category: 'welfare',
        voteCount: 0,
        agreeCount: 0,
        generationAgreement: {
          '20s': 0.72,
          '30s': 0.80,
          '40s': 0.82,
          '50s': 0.70,
          '60s+': 0.45,
        },
        status: 'published',
        createdAt: DateTime(2026, 3, 18),
        tags: ['医療', '介護', '年金'],
      ),
      Challenge(
        id: 'foreign_direct_investment',
        name: '対内直接投資の少なさ',
        description: '海外からの投資が主要国と比べて極端に少なく、経済活性化の機会損失',
        category: 'economy',
        voteCount: 0,
        agreeCount: 0,
        generationAgreement: {
          '20s': 0.50,
          '30s': 0.55,
          '40s': 0.58,
          '50s': 0.52,
          '60s+': 0.40,
        },
        status: 'published',
        createdAt: DateTime(2026, 3, 20),
        tags: ['雇用', '財政'],
      ),
      Challenge(
        id: 'voter_turnout_decline',
        name: '投票率の低下',
        description: '国政選挙の投票率が長期的に低下し、若年層ほど低い傾向',
        category: 'politics',
        voteCount: 0,
        agreeCount: 0,
        generationAgreement: {
          '20s': 0.78,
          '30s': 0.75,
          '40s': 0.68,
          '50s': 0.60,
          '60s+': 0.45,
        },
        status: 'published',
        createdAt: DateTime(2026, 3, 22),
        tags: ['選挙', '政治'],
      ),
      Challenge(
        id: 'housing_vacancy',
        name: '空き家の増加',
        description: '人口減少に伴い空き家が急増し、防災・治安面でも問題化',
        category: 'demographic',
        voteCount: 0,
        agreeCount: 0,
        generationAgreement: {
          '20s': 0.48,
          '30s': 0.55,
          '40s': 0.62,
          '50s': 0.68,
          '60s+': 0.70,
        },
        status: 'published',
        createdAt: DateTime(2026, 3, 25),
        tags: ['住宅', '地方'],
      ),
      Challenge(
        id: 'childcare_waitlist',
        name: '保育園の待機児童',
        description: '希望しても保育園に入れない子供が都市部を中心に存在し続けている',
        category: 'welfare',
        voteCount: 0,
        agreeCount: 0,
        generationAgreement: {
          '20s': 0.85,
          '30s': 0.90,
          '40s': 0.72,
          '50s': 0.45,
          '60s+': 0.35,
        },
        status: 'published',
        createdAt: DateTime(2026, 3, 28),
        tags: ['子育て', '雇用'],
        budgetTrillionYen: 3.5, // 少子化対策費（令和7年度一般会計）
      ),
      Challenge(
        id: 'sme_succession_crisis',
        name: '中小企業の後継者不足',
        description: '経営者の高齢化が進み、後継者が見つからず廃業する中小企業が急増',
        category: 'economy',
        voteCount: 0,
        agreeCount: 0,
        generationAgreement: {
          '20s': 0.42,
          '30s': 0.50,
          '40s': 0.65,
          '50s': 0.78,
          '60s+': 0.72,
        },
        status: 'published',
        createdAt: DateTime(2026, 3, 30),
        tags: ['中小企業', '雇用', '地方'],
      ),
      Challenge(
        id: 'gender_pay_gap',
        name: '男女の賃金格差',
        description: '同じように働いても、女性の賃金は男性より2割以上低い状態が続いている',
        category: 'economy',
        voteCount: 0,
        agreeCount: 0,
        generationAgreement: {
          '20s': 0.75,
          '30s': 0.80,
          '40s': 0.68,
          '50s': 0.55,
          '60s+': 0.42,
        },
        status: 'published',
        createdAt: DateTime(2026, 4, 1),
        tags: ['ジェンダー', '雇用', '格差'],
      ),
      Challenge(
        id: 'disaster_recovery_cost',
        name: '自然災害の激甚化と復旧費用',
        description: '毎年のように起きる大規模災害の復旧費用が国家財政を圧迫している',
        category: 'debt',
        voteCount: 0,
        agreeCount: 0,
        generationAgreement: {
          '20s': 0.60,
          '30s': 0.65,
          '40s': 0.70,
          '50s': 0.72,
          '60s+': 0.68,
        },
        status: 'published',
        createdAt: DateTime(2026, 4, 3),
        tags: ['防災', '財政'],
        budgetTrillionYen: 6.1, // 公共事業関係費（令和8年度一般会計）
      ),
      Challenge(
        id: 'regional_healthcare_gap',
        name: '地方の医療格差（医師不足）',
        description: '都市部と地方で医師の数に大きな差があり、必要な医療を受けにくい地域がある',
        category: 'welfare',
        voteCount: 0,
        agreeCount: 0,
        generationAgreement: {
          '20s': 0.55,
          '30s': 0.62,
          '40s': 0.68,
          '50s': 0.75,
          '60s+': 0.82,
        },
        status: 'published',
        createdAt: DateTime(2026, 4, 5),
        tags: ['地方', '医療'],
      ),
      Challenge(
        id: 'climate_change_response',
        name: '気候変動対応の遅れ',
        description: '2050年カーボンニュートラル目標に対し、日本の温室効果ガス削減ペースは主要国より遅れている',
        category: 'debt',
        voteCount: 0,
        agreeCount: 0,
        generationAgreement: {
          '20s': 0.68,
          '30s': 0.65,
          '40s': 0.60,
          '50s': 0.55,
          '60s+': 0.42,
        },
        status: 'published',
        createdAt: DateTime(2026, 4, 8),
        tags: ['エネルギー', '財政'],
      ),
      Challenge(
        id: 'young_carers',
        name: 'ヤングケアラーの負担',
        description: '家族の介護や世話を日常的に担う子供・若者が増え、学業や将来に影響が出ている',
        category: 'welfare',
        voteCount: 0,
        agreeCount: 0,
        generationAgreement: {
          '20s': 0.82,
          '30s': 0.85,
          '40s': 0.72,
          '50s': 0.55,
          '60s+': 0.40,
        },
        status: 'published',
        createdAt: DateTime(2026, 4, 10),
        tags: ['介護', '子育て', '貧困'],
      ),
      Challenge(
        id: 'digital_divide',
        name: '行政のデジタル化の遅れ',
        description: 'マイナンバーなど行政手続きのデジタル化が進まず、非効率や情報格差が生じている',
        category: 'politics',
        voteCount: 0,
        agreeCount: 0,
        generationAgreement: {
          '20s': 0.72,
          '30s': 0.75,
          '40s': 0.68,
          '50s': 0.55,
          '60s+': 0.35,
        },
        status: 'published',
        createdAt: DateTime(2026, 4, 12),
        tags: ['政治', '雇用'],
      ),
      Challenge(
        id: 'isolated_elderly',
        name: '単身高齢者の孤立',
        description: '一人暮らしの高齢者が増え、孤立死や社会的孤立が深刻な問題になっている',
        category: 'demographic',
        voteCount: 0,
        agreeCount: 0,
        generationAgreement: {
          '20s': 0.58,
          '30s': 0.62,
          '40s': 0.68,
          '50s': 0.75,
          '60s+': 0.72,
        },
        status: 'published',
        createdAt: DateTime(2026, 4, 15),
        tags: ['介護', '人口', '地方'],
      ),
      // ── 全体拡充（経済・福祉・人口・政治・財政）──
      Challenge(
        id: 'non_regular_employment',
        name: '非正規雇用の広がり',
        description: '雇用者の3〜4割が非正規で、賃金や雇用の安定性で正規社員との格差が続いている',
        category: 'economy',
        voteCount: 0,
        agreeCount: 0,
        generationAgreement: {
          '20s': 0.80,
          '30s': 0.82,
          '40s': 0.75,
          '50s': 0.65,
          '60s+': 0.52,
        },
        status: 'published',
        createdAt: DateTime(2026, 4, 18),
        tags: ['雇用', '格差'],
      ),
      Challenge(
        id: 'low_startup_rate',
        name: '開業率の低さ・産業の新陳代謝不足',
        description: '開業率・廃業率とも欧米より大幅に低く、新しい産業が生まれ替わりにくい構造',
        category: 'economy',
        voteCount: 0,
        agreeCount: 0,
        generationAgreement: {
          '20s': 0.62,
          '30s': 0.65,
          '40s': 0.60,
          '50s': 0.50,
          '60s+': 0.40,
        },
        status: 'published',
        createdAt: DateTime(2026, 4, 20),
        tags: ['雇用', '中小企業'],
      ),
      Challenge(
        id: 'caregiver_shortage',
        name: '介護人材の不足',
        description: '介護職の有効求人倍率は全職種平均の3倍以上。高齢化の加速で不足はさらに深刻化する見通し',
        category: 'welfare',
        voteCount: 0,
        agreeCount: 0,
        generationAgreement: {
          '20s': 0.68,
          '30s': 0.75,
          '40s': 0.80,
          '50s': 0.78,
          '60s+': 0.65,
        },
        status: 'published',
        createdAt: DateTime(2026, 4, 22),
        tags: ['介護', '雇用'],
        budgetTrillionYen: 3.7, // 介護給付費（令和7年度一般会計）
      ),
      Challenge(
        id: 'single_parent_poverty',
        name: 'ひとり親家庭の貧困',
        description: '就業率はOECD最高水準なのに、ひとり親世帯の貧困率は先進国トップクラスという「働いても貧困」の実態',
        category: 'welfare',
        voteCount: 0,
        agreeCount: 0,
        generationAgreement: {
          '20s': 0.82,
          '30s': 0.86,
          '40s': 0.80,
          '50s': 0.68,
          '60s+': 0.55,
        },
        status: 'published',
        createdAt: DateTime(2026, 4, 24),
        tags: ['貧困', '子育て', '格差'],
      ),
      Challenge(
        id: 'tokyo_concentration',
        name: '東京一極集中',
        description: '東京圏への転入超過が続き、人・仕事・大学が集中する一方、地方の人口流出に歯止めがかからない',
        category: 'demographic',
        voteCount: 0,
        agreeCount: 0,
        generationAgreement: {
          '20s': 0.58,
          '30s': 0.62,
          '40s': 0.68,
          '50s': 0.72,
          '60s+': 0.68,
        },
        status: 'published',
        createdAt: DateTime(2026, 4, 26),
        tags: ['地方', '人口'],
      ),
      Challenge(
        id: 'foreign_worker_coexistence',
        name: '外国人との共生の課題',
        description: '在留外国人が過去最多を更新し続ける一方、生活支援・地域との共生の制度整備が追いついていない',
        category: 'demographic',
        voteCount: 0,
        agreeCount: 0,
        generationAgreement: {
          '20s': 0.70,
          '30s': 0.68,
          '40s': 0.62,
          '50s': 0.52,
          '60s+': 0.42,
        },
        status: 'published',
        createdAt: DateTime(2026, 4, 28),
        tags: ['人口', '雇用'],
      ),
      Challenge(
        id: 'local_assembly_shortage',
        name: '地方議会のなり手不足',
        description: '町村議会選挙の3割が無投票当選となるなど、地方議員のなり手不足が全国で深刻化している',
        category: 'politics',
        voteCount: 0,
        agreeCount: 0,
        generationAgreement: {
          '20s': 0.60,
          '30s': 0.62,
          '40s': 0.65,
          '50s': 0.68,
          '60s+': 0.62,
        },
        status: 'published',
        createdAt: DateTime(2026, 4, 30),
        tags: ['選挙', '地方', '政治'],
      ),
      Challenge(
        id: 'candidacy_deposit_barrier',
        name: '選挙供託金の高さ',
        description: '衆院小選挙区で300万円という世界最高水準の供託金が、政治への新規参入のハードルになっている',
        category: 'politics',
        voteCount: 0,
        agreeCount: 0,
        generationAgreement: {
          '20s': 0.72,
          '30s': 0.70,
          '40s': 0.62,
          '50s': 0.50,
          '60s+': 0.38,
        },
        status: 'published',
        createdAt: DateTime(2026, 5, 2),
        tags: ['選挙', '政治'],
      ),
      Challenge(
        id: 'defense_budget_funding',
        name: '防衛費増額の財源問題',
        description: '防衛費をGDP比2%に引き上げる方針の一方、増税や国債発行など財源の負担を誰がどう負うかの議論が続く',
        category: 'debt',
        voteCount: 0,
        agreeCount: 0,
        generationAgreement: {
          '20s': 0.62,
          '30s': 0.65,
          '40s': 0.68,
          '50s': 0.65,
          '60s+': 0.55,
        },
        status: 'published',
        createdAt: DateTime(2026, 5, 4),
        tags: ['財政', '税金'],
        budgetTrillionYen: 8.8, // 防衛関係費（令和8年度一般会計）
      ),
      Challenge(
        id: 'special_account_opacity',
        name: '特別会計の不透明さ',
        description: '特別会計の予算規模は一般会計の約4倍にのぼるが、審査が簡略化されがちで使途の透明性に課題がある',
        category: 'debt',
        voteCount: 0,
        agreeCount: 0,
        generationAgreement: {
          '20s': 0.68,
          '30s': 0.70,
          '40s': 0.68,
          '50s': 0.60,
          '60s+': 0.48,
        },
        status: 'published',
        createdAt: DateTime(2026, 5, 6),
        tags: ['財政', '税金'],
        budgetTrillionYen: 400, // 特別会計の歳出総額（会計間重複計上含む）
      ),
      Challenge(
        id: 'finance_ministry_narrative_control',
        name: '財務省の情報発信力と「ザイム真理教」論争',
        description:
            '財務省が予算編成・税制を通じて「緊縮財政・増税やむなし」という考え方を政治家・メディア・国民に浸透させているとの批判が'
            '「ザイム真理教」という言葉とともに広がっている。財政規律の必要性を訴える反論も根強く、賛否が分かれる構造的な課題',
        category: 'structural',
        voteCount: 0,
        agreeCount: 0,
        generationAgreement: {
          '20s': 0.72,
          '30s': 0.76,
          '40s': 0.74,
          '50s': 0.64,
          '60s+': 0.48,
        },
        status: 'published',
        createdAt: DateTime(2026, 5, 8),
        tags: ['財務省', '財政', '税金', '政治'],
        budgetTrillionYen: 122.3, // 財務省が編成を主導する国の一般会計予算の総額（令和8年度）
      ),
    ];
  }

  // 課題へのコメントを投稿
  Future<bool> postComment(
    String userId,
    String challengeId,
    String text,
  ) async {
    try {
      await _firestore
          .collection('challenges')
          .doc(challengeId)
          .collection('comments')
          .add({
            'text': text,
            'likeCount': 0,
            'userId': userId,
            'createdAt': FieldValue.serverTimestamp(),
          });
      _logger.i('Comment posted for challenge: $challengeId');
      return true;
    } catch (e) {
      _logger.e('Error posting comment: $e');
      return false;
    }
  }

  // 自分のコメントを削除（即時削除機能）
  Future<bool> deleteComment(String challengeId, String commentId) async {
    try {
      await _firestore
          .collection('challenges')
          .doc(challengeId)
          .collection('comments')
          .doc(commentId)
          .delete();
      _logger.i('Comment deleted: $commentId');
      return true;
    } catch (e) {
      _logger.e('Error deleting comment: $e');
      return false;
    }
  }

  // 不適切な投稿を通報する（コメント・提案共通）
  Future<bool> reportContent({
    required String userId,
    required String contentType, // 'comment' or 'proposal'
    required String contentId,
    String? challengeId,
    String? reason,
  }) async {
    try {
      await _firestore.collection('reports').add({
        'contentType': contentType,
        'contentId': contentId,
        'challengeId': challengeId,
        'reason': reason,
        'reportedBy': userId,
        'status': 'open',
        'createdAt': FieldValue.serverTimestamp(),
      });
      _logger.i('Reported $contentType: $contentId');
      return true;
    } catch (e) {
      _logger.e('Error reporting content: $e');
      return false;
    }
  }

  // コメントに「いいね」（同一ユーザーの二重いいねは likes サブコレクションで防止）
  Future<bool> likeComment(
    String userId,
    String challengeId,
    String commentId,
  ) async {
    try {
      final commentRef = _firestore
          .collection('challenges')
          .doc(challengeId)
          .collection('comments')
          .doc(commentId);
      final likeRef = commentRef.collection('likes').doc(userId);

      final likeDoc = await likeRef.get();
      if (likeDoc.exists) {
        return false; // 既にいいね済み
      }

      await likeRef.set({
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
      });
      await commentRef.update({'likeCount': FieldValue.increment(1)});

      _logger.i('Comment liked: $commentId');
      return true;
    } catch (e) {
      _logger.e('Error liking comment: $e');
      return false;
    }
  }

  // 課題のコメント一覧を取得
  Future<List<Comment>> getComments(String challengeId) async {
    try {
      final snapshot = await _firestore
          .collection('challenges')
          .doc(challengeId)
          .collection('comments')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        final timestamp = data['createdAt'] as Timestamp?;
        return Comment(
          id: doc.id,
          challengeId: challengeId,
          text: data['text'] ?? '',
          createdAt: timestamp?.toDate() ?? DateTime.now(),
          likeCount: data['likeCount'] ?? 0,
          userId: data['userId'] as String?,
        );
      }).toList();
    } catch (e) {
      _logger.e('Error fetching comments: $e');
      return [];
    }
  }

  // 対策案に投票（1課題につき1案のみ選択可能。既に投票済みならfalseを返す）
  Future<bool> votePolicyOption(
    String userId,
    String challengeId,
    String optionId,
  ) async {
    try {
      final voteRef = _firestore
          .collection('challenges')
          .doc(challengeId)
          .collection('policyVotes')
          .doc(userId);

      final voteDoc = await voteRef.get();
      if (voteDoc.exists) {
        return false; // 既にこの課題の対策案に投票済み
      }

      await voteRef.set({
        'optionId': optionId,
        'timestamp': FieldValue.serverTimestamp(),
      });
      // set(merge: true) を使うことで、対策案の親ドキュメントが未作成でも
      // （課題データはローカルのモックが基本のため）エラーにならず投票数を積み上げられる
      await _firestore
          .collection('challenges')
          .doc(challengeId)
          .collection('policyOptions')
          .doc(optionId)
          .set({'voteCount': FieldValue.increment(1)}, SetOptions(merge: true));

      _logger.i('Policy option voted: $challengeId / $optionId');
      return true;
    } catch (e) {
      _logger.e('Error voting policy option: $e');
      return false;
    }
  }

  // 対策案ごとの実投票数（モックのベース投票数に加算して表示する）
  Future<Map<String, int>> getPolicyOptionExtraVotes(String challengeId) async {
    try {
      final snapshot = await _firestore
          .collection('challenges')
          .doc(challengeId)
          .collection('policyOptions')
          .get();

      return {
        for (final doc in snapshot.docs)
          doc.id: (doc.data()['voteCount'] as int?) ?? 0,
      };
    } catch (e) {
      _logger.e('Error fetching policy option votes: $e');
      return {};
    }
  }

  // ユーザーからの課題提案を投稿（成功時は新規ドキュメントIDを返す）
  Future<String?> submitProposal({
    required String userId,
    required String title,
    required String description,
    required String category,
  }) async {
    try {
      final ref = await _firestore.collection('userProposals').add({
        'title': title,
        'description': description,
        'category': category,
        'voteCount': 0,
        'submissionStatus': 'none',
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _logger.i('Proposal submitted: $title');
      return ref.id;
    } catch (e) {
      _logger.e('Error submitting proposal: $e');
      return null;
    }
  }

  // 自分の提案を削除（即時削除機能）
  Future<bool> deleteProposal(String proposalId) async {
    try {
      await _firestore.collection('userProposals').doc(proposalId).delete();
      _logger.i('Proposal deleted: $proposalId');
      return true;
    } catch (e) {
      _logger.e('Error deleting proposal: $e');
      return false;
    }
  }

  // 課題提案の一覧を取得
  Future<List<UserProposal>> getProposals() async {
    try {
      final snapshot = await _firestore
          .collection('userProposals')
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();

      return snapshot.docs.map(_proposalFromFirestore).toList();
    } catch (e) {
      _logger.e('Error fetching proposals: $e');
      return [];
    }
  }

  // 課題提案に投票（1ユーザー1票）
  Future<bool> voteProposal(String userId, String proposalId) async {
    try {
      final proposalRef = _firestore
          .collection('userProposals')
          .doc(proposalId);
      final voteRef = proposalRef.collection('votes').doc(userId);

      final voteDoc = await voteRef.get();
      if (voteDoc.exists) {
        return false; // 既に投票済み
      }

      await voteRef.set({
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
      });
      await proposalRef.update({'voteCount': FieldValue.increment(1)});

      _logger.i('Proposal voted: $proposalId');
      return true;
    } catch (e) {
      _logger.e('Error voting proposal: $e');
      return false;
    }
  }

  static UserProposal _proposalFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final submissionTimestamp = data['submissionDate'] as Timestamp?;
    return UserProposal(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'economy',
      voteCount: data['voteCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      submissionStatus: SubmissionStatusLabel.fromString(
        data['submissionStatus'] as String?,
      ),
      submissionNote: data['submissionNote'] as String?,
      submissionUrl: data['submissionUrl'] as String?,
      submissionDate: submissionTimestamp?.toDate(),
      userId: data['userId'] as String?,
    );
  }

  static Challenge _challengeFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Challenge(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'economy',
      voteCount: data['voteCount'] ?? 0,
      agreeCount: data['agreeCount'] ?? 0,
      generationAgreement: Map<String, double>.from(
        data['generationAgreement'] ?? {},
      ),
      status: data['status'] ?? 'candidate',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      tags: List<String>.from(data['tags'] ?? []),
    );
  }
}
