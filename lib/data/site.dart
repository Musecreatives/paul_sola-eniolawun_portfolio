/// Site-wide facts that don't change often enough to live in the CMS.
abstract final class Site {
  static const name = 'Paul Sola-Eniolawun';
  static const email = 'paulsolaeniolawun@gmail.com';

  /// Public CV (no referees, no phone number). Served from web/cv/.
  // TODO(paul): replace web/cv/paul-sola-eniolawun-cv.pdf with your own redacted CV PDF.
  static const cvUrl = '/cv/paul-sola-eniolawun-cv.pdf';

  // The old site linked to two different LinkedIn and Figma profiles.
  // TODO(paul): confirm the LinkedIn, Figma, X and Discord URLs below are the current ones.
  static const socials = <(String, String)>[
    ('GitHub', 'https://github.com/Musecreatives'),
    ('LinkedIn', 'https://www.linkedin.com/in/oluwatisehunla-sola-eniolawun-1670501b1'),
    ('Figma', 'https://www.figma.com/@paulostic1'),
    ('X', 'https://x.com/PaulPauLosTic'),
    ('Discord', 'https://discord.gg/paulostic_dev'),
  ];
}
