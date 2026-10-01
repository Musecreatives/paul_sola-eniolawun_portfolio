import 'package:flutter/painting.dart';

/// The paintings hung around the site. Posts pick a cover by [key].
/// Credits are mirrored in ART_CREDITS.md.
class Painting {
  const Painting(this.key, this.asset, this.title, this.artist, this.alt, {this.align = Alignment.center});

  final String key;
  final String asset;
  final String title;
  final String artist;
  final String alt;
  final Alignment align;

  static const thinkOutside = Painting(
    'think_outside',
    'assets/img/art_think_outside.webp',
    'Think Outside the Box',
    'Studio print',
    'Typographic print reading Think Outside the Box',
  );
  static const boxerAtRest = Painting(
    'boxer_at_rest',
    'assets/img/art_boxer_at_rest.webp',
    'Boxer at Rest',
    'Hellenistic bronze',
    'Boxer at Rest, Hellenistic bronze',
    align: Alignment(.7, 0),
  );
  static const schoolOfAthens = Painting(
    'school_of_athens',
    'assets/img/art_school_of_athens.webp',
    'The School of Athens',
    'Raphael, 1509–1511 · Fresco',
    'The School of Athens by Raphael',
  );
  static const deathOfSocrates = Painting(
    'death_of_socrates',
    'assets/img/art_death_of_socrates.webp',
    'The Death of Socrates',
    'Jacques-Louis David, 1787 · Oil on canvas',
    'The Death of Socrates by Jacques-Louis David',
  );
  static const aureliusFragment = Painting(
    'aurelius_fragment',
    'assets/img/art_aurelius_fragment.webp',
    'Marcus Aurelius, fragment',
    'Roman marble',
    'Marble fragment of a portrait of Marcus Aurelius',
  );
  static const meditations = Painting(
    'meditations',
    'assets/img/art_meditations.webp',
    'Meditations',
    'Marcus Aurelius bust · studio print',
    'Bust of Marcus Aurelius with a line from the Meditations',
  );

  static const all = [deathOfSocrates, schoolOfAthens, boxerAtRest, aureliusFragment, meditations, thinkOutside];

  static Painting byKey(String? key) => all.firstWhere((p) => p.key == key, orElse: () => deathOfSocrates);
}
