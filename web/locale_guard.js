// Some headless browsers report a POSIX locale such as "en-US@posix", which
// isn't a valid BCP 47 tag, and Flutter's engine throws on it before the first
// frame. Real browsers never do this; for the ones that do, expose clean tags.
(function () {
  try {
    Intl.getCanonicalLocales(navigator.languages || [navigator.language]);
  } catch (_) {
    var clean = [];
    (navigator.languages || [navigator.language]).forEach(function (l) {
      var tag = String(l || '').split('@')[0].split('.')[0].replace(/_/g, '-');
      try {
        clean.push(Intl.getCanonicalLocales(tag)[0]);
      } catch (_) {}
    });
    if (!clean.length) clean = ['en'];
    try {
      Object.defineProperty(Navigator.prototype, 'languages', { get: function () { return clean.slice(); } });
      Object.defineProperty(Navigator.prototype, 'language', { get: function () { return clean[0]; } });
    } catch (_) {}
  }
})();
