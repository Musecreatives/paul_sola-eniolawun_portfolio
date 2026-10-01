import '../data/paintings.dart';

/// The eight public rooms, in tour order.
enum Room {
  foyer('I', 'Foyer', '/', Painting.thinkOutside),
  works('II', 'Selected Works', '/works', Painting.boxerAtRest),
  chronicle('III', 'Chronicle', '/chronicle', Painting.schoolOfAthens),
  certificates('IV', 'Certificates', '/certificates', Painting.deathOfSocrates),
  about('V', 'About', '/about', Painting.aureliusFragment),
  journal('VI', 'Journal', '/journal', Painting.meditations),
  // TODO(paul): source public-domain artworks for The Collection and Correspondence menu entries.
  collection('VII', 'The Collection', '/collection', Painting.schoolOfAthens, placeholderArt: true),
  correspondence('VIII', 'Correspondence', '/correspondence', Painting.aureliusFragment, placeholderArt: true);

  const Room(this.numeral, this.title, this.path, this.painting, {this.placeholderArt = false});

  final String numeral;
  final String title;
  final String path;
  final Painting painting;
  final bool placeholderArt;

  Room? get next => index + 1 < values.length ? values[index + 1] : null;
}
