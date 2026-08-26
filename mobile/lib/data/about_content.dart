/// Copy for the About screen.
///
/// Taken verbatim from the ministry's own about page (`frontend/about.html`).
/// Nothing here is written by me — it is the church describing itself, only
/// re-sectioned for a phone. Keep it that way: if the wording needs to change,
/// it should change on the website first.
class AboutContent {
  const AboutContent._();

  static const String intro =
      'Transformation Project Ministries (TPM) is a Christ-centered, Spirit-led ministry '
      'with a clear mandate to transform lives through the saving knowledge of Jesus '
      'Christ. We exist to raise men and women who are rooted in God’s Word, empowered by '
      'the Holy Spirit, and committed to fulfilling their divine purpose.';

  static const String pullQuote =
      'TPM is more than a church — it is a family, a training ground, and a movement.';

  static const String mission =
      'To transform lives, raise disciples, and equip believers to serve God '
      'wholeheartedly and advance His Kingdom.';

  static const String vision =
      'To transform lives, raise faithful disciples, and build a people who will serve God '
      'wholeheartedly and advance His Kingdom in every sphere of life.';

  static const List<String> mandate = [
    'Winning souls and establishing them in Christ',
    'Raising faithful workers, leaders, and ministers',
    'Teaching believers to serve God with excellence, loyalty, and devotion',
    'Building strong church families that grow spiritually and numerically',
    'Equipping the next generation to walk in purpose and power',
  ];

  static const List<String> beliefs = [
    'The saving power of Jesus Christ',
    'The transforming work of the Holy Spirit',
    'The authority of God’s Word',
    'Every believer having a purpose in God’s house',
  ];

  static const String beliefsNote =
      'Our teachings are practical, Bible-based, and designed to help you live out your '
      'faith daily.';

  static const List<AboutSection> sections = [
    AboutSection(
      eyebrow: 'Our ministry culture',
      title: 'Every believer has a place',
      paragraphs: [
        'TPM is built on love, humility, loyalty, diligence, and excellence. We believe '
            'that every believer has a place and a purpose in God’s house. Our ministry '
            'emphasizes active service, accountability, and spiritual growth — creating an '
            'environment where people are nurtured, trained, and released to serve '
            'effectively.',
      ],
    ),
    AboutSection(
      eyebrow: 'Our gatherings & programs',
      title: 'Trained, strengthened, equipped',
      paragraphs: [
        'Our gatherings are designed to create spaces where people encounter God, grow in '
            'faith, and are empowered for Kingdom advancement. Through our regular '
            'services, leadership trainings, and workers’ camps — including CLAP Breakfast '
            'Meeting, CLAW, Sharpening Camp, Mark 10:29–30 Camp, Mighty Camp, and '
            'Metamorphoo Camp — believers are trained, strengthened, and equipped for '
            'effective service.',
        'Our special gatherings such as the Holy Ghost Festival, TPM Waits, Transformation '
            'Conference, Transformation Experience, and Prophetic Prayer Move are powerful '
            'moments of spiritual renewal. In these meetings, lives are saved, revived, '
            'healed, and stirred with fresh passion for God.',
      ],
    ),
    AboutSection(
      eyebrow: 'Our heart for compassion',
      title: 'Transformed Foundations',
      paragraphs: [
        'Transformation goes beyond the walls of the church. We believe the love of Christ '
            'must be lived out in practical ways that touch lives and restore hope.',
        'Through Transformed Foundations, our compassion and outreach arm, we actively '
            'support orphanages and vulnerable children by providing care, resources, and '
            'encouragement. This initiative reflects our deep conviction that every child '
            'deserves love, dignity, and the opportunity to thrive.',
      ],
      scripture:
          'Religion that God our Father accepts as pure and faultless is this: to look '
          'after orphans and widows in their distress.',
      scriptureRef: 'James 1:27 NIV',
    ),
    AboutSection(
      eyebrow: 'Raising the next generation',
      title: 'It’s a great thing to serve the Lord',
      paragraphs: [
        'A core focus of TPM is the intentional raising of young ministers and leaders. We '
            'believe in identifying, training, and releasing faithful men and women who '
            'will labor tirelessly for the Church.',
        'Our message is simple yet powerful: it’s a great thing to serve the Lord. At TPM, '
            'transformation is not just preached — it is experienced.',
      ],
    ),
  ];

  static const String welcome =
      'Whether you are new to church, returning to faith, or seeking a deeper walk with '
      'God, you are welcome at TPM. We believe God has a place for you, a purpose for you, '
      'and a future filled with hope.';

  // ---- The founder ----
  static const String founderName = 'Apostle Andrews Amoh Ofori';
  static const String founderRole =
      'Founder & Executive President — Transformation Project Ministries';
  static const String founderPhoto = 'assets/leaders/apostle-andrews.png';

  static const String founderIntro =
      'Apostle Andrews Amoh Ofori is the Founder and Executive President of Transformation '
      'Project Ministries, a vibrant Christian ministry with a divine mandate to transform '
      'lives through Christ Jesus.';

  static const List<AboutFact> founderFacts = [
    AboutFact(
      label: 'Ministry & calling',
      body: 'A diligent and devoted minister of the Gospel, he serves through preaching, '
          'teaching, prophetic ministry, and healing — marked by strong biblical '
          'foundations, spiritual depth and wisdom.',
    ),
    AboutFact(
      label: 'Author & teacher',
      body: 'Author of Daily Drops of Transformation, a daily devotional, along with '
          'Crossing the Red Sea, The Fruitful Christian, The Wise and Trusted Servant, '
          'God Is Good and No Delay.',
    ),
    AboutFact(
      label: 'Leadership & affiliation',
      body: 'A member of Young Ministers’ Network International (YMNI), a fellowship of '
          'young Gospel ministers under the leadership of Rev. John Winfred.',
    ),
    AboutFact(
      label: 'Signature program',
      body: 'Hosts the annual Holy Ghost Festival, a spirit-filled gathering where many '
          'lives are saved, empowered, and ignited with fresh passion for the Kingdom.',
    ),
  ];
}

class AboutSection {
  const AboutSection({
    required this.eyebrow,
    required this.title,
    required this.paragraphs,
    this.scripture,
    this.scriptureRef,
  });

  final String eyebrow;
  final String title;
  final List<String> paragraphs;

  /// Optional pull quote closing the section.
  final String? scripture;
  final String? scriptureRef;
}

class AboutFact {
  const AboutFact({required this.label, required this.body});

  final String label;
  final String body;
}
