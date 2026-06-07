import 'package:flutter/material.dart';

import '../../core/tokens/app_tokens.dart';

/// Cover style data — matches the redesign's typographic cover system.
class BookCoverStyle {
  const BookCoverStyle({
    required this.bg,
    required this.ink,
    required this.rule,
  });

  final Color bg;
  final Color ink;
  final Color rule;

  static const sapphire = BookCoverStyle(
    bg: AppColors.deepSapphire,
    ink: AppColors.cloudDancer,
    rule: AppColors.eucalyptus,
  );
  static const terracotta = BookCoverStyle(
    bg: AppColors.terracottaClay,
    ink: Color(0xFF2A1A12),
    rule: AppColors.deepSapphire,
  );
  static const cream = BookCoverStyle(
    bg: AppColors.clay,
    ink: AppColors.deepSapphire,
    rule: AppColors.copperOak,
  );
  static const noir = BookCoverStyle(
    bg: Color(0xFF15171C),
    ink: AppColors.clay,
    rule: AppColors.dopamineRed,
  );
  static const mustard = BookCoverStyle(
    bg: AppColors.mustard,
    ink: Color(0xFF2A2410),
    rule: AppColors.deepSapphire,
  );
  static const fog = BookCoverStyle(
    bg: AppColors.atmosphericFog,
    ink: AppColors.cloudDancer,
    rule: AppColors.clay,
  );
  static const copper = BookCoverStyle(
    bg: AppColors.copperOak,
    ink: AppColors.cloudDancer,
    rule: AppColors.terracottaClay,
  );
}

/// Template — controls the layout pattern of the typographic cover.
enum BookCoverTemplate { stack, playful, center, noir, band }

/// Typographic book cover widget.  No real images — editorial colour blocks.
///
/// [width] controls the size; height is 1.5× width (book proportions).
/// [style] picks the colour palette.
/// [template] picks the layout pattern.
/// [title] and [author] are displayed as typography.
class BookCover extends StatelessWidget {
  const BookCover({
    super.key,
    required this.title,
    required this.author,
    this.width = 84,
    this.style = BookCoverStyle.sapphire,
    this.template = BookCoverTemplate.stack,
  });

  final String title;
  final String author;
  final double width;
  final BookCoverStyle style;
  final BookCoverTemplate template;

  double get _height => width * 1.5;

  @override
  Widget build(BuildContext context) {
    final u = width / 84;
    final r = _mathMin(width * 0.055, 5.0);

    Widget content;
    switch (template) {
      case BookCoverTemplate.playful:
        content = _PlayfulLayout(title: title, author: author, w: width, style: style, u: u);
      case BookCoverTemplate.center:
        content = _CenterLayout(title: title, author: author, w: width, style: style, u: u);
      case BookCoverTemplate.noir:
        content = _NoirLayout(title: title, author: author, w: width, style: style, u: u);
      case BookCoverTemplate.band:
        content = _BandLayout(title: title, author: author, w: width, style: style, u: u);
      case BookCoverTemplate.stack:
        content = _StackLayout(title: title, author: author, w: width, style: style, u: u);
    }

    return SizedBox(
      width: width,
      height: _height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: style.bg),
            content,
            _JacketChrome(u: u, borderRadius: r),
          ],
        ),
      ),
    );
  }
}

double _mathMin(double a, double b) => a < b ? a : b;

// ── Chrome overlay (spine shadow + sheen + inner border) ──────
class _JacketChrome extends StatelessWidget {
  const _JacketChrome({required this.u, required this.borderRadius});
  final double u;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Spine dark strip.
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: _mathMin(2.5, u * 4.2),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0x47000000), Color(0x0D000000), Color(0x0DFFFFFF)],
              ),
            ),
          ),
        ),
        // Paper sheen.
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment(-0.6, -1),
                end: Alignment(1, 1),
                colors: [Color(0x1AFFFFFF), Color(0x00FFFFFF), Color(0x0D000000)],
              ),
            ),
          ),
        ),
        // Inner border.
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: const Color(0x1A000000)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x2E1E2B3C),
                  blurRadius: 22,
                  offset: Offset(0, 8),
                  spreadRadius: -4,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Playful (children's classic) ──────────────────────────────
class _PlayfulLayout extends StatelessWidget {
  const _PlayfulLayout({
    required this.title,
    required this.author,
    required this.w,
    required this.style,
    required this.u,
  });
  final String title, author;
  final double w, u;
  final BookCoverStyle style;

  @override
  Widget build(BuildContext context) {
    final p = w * 0.12;
    return Padding(
      padding: EdgeInsets.all(p),
      child: Stack(
        children: [
          Positioned(
            top: -w * 0.18,
            right: -w * 0.18,
            child: Container(
              width: w * 0.6,
              height: w * 0.6,
              decoration: BoxDecoration(
                color: style.rule,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text(
                title,
                maxLines: 4,
                style: TextStyle(
                  fontFamily: AppTypography.uiFontFamily,
                  fontWeight: FontWeight.w800,
                  fontSize: w * 0.20,
                  color: style.ink,
                  height: 0.98,
                  letterSpacing: -0.03,
                ),
              ),
              SizedBox(height: w * 0.07),
              Container(
                width: w * 0.32,
                height: 2.5 * u,
                decoration: BoxDecoration(
                  color: style.ink.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: w * 0.04),
              Text(
                author,
                style: TextStyle(
                  fontFamily: AppTypography.uiFontFamily,
                  fontWeight: FontWeight.w600,
                  fontSize: w * 0.082,
                  color: style.ink.withValues(alpha: 0.82),
                  letterSpacing: 0.02,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Center (literary classic) ──────────────────────────────────
class _CenterLayout extends StatelessWidget {
  const _CenterLayout({
    required this.title,
    required this.author,
    required this.w,
    required this.style,
    required this.u,
  });
  final String title, author;
  final double w, u;
  final BookCoverStyle style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(w * 0.085),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            color: style.rule,
            width: 1.4 * u,
          ),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Padding(
          padding: EdgeInsets.all(w * 0.10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                author.toUpperCase(),
                style: TextStyle(
                  fontFamily: AppTypography.uiFontFamily,
                  fontWeight: FontWeight.w600,
                  fontSize: w * 0.066,
                  color: style.ink.withValues(alpha: 0.70),
                  letterSpacing: 0.18,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: w * 0.08),
              Container(
                width: w * 0.18,
                height: 1.5 * u,
                color: style.rule,
              ),
              SizedBox(height: w * 0.06),
              Text(
                title,
                style: TextStyle(
                  fontFamily: AppTypography.metricsFontFamily,
                  fontWeight: FontWeight.w500,
                  fontSize: w * 0.165,
                  color: style.ink,
                  height: 1.04,
                  letterSpacing: -0.01,
                ),
                textAlign: TextAlign.center,
                maxLines: 5,
              ),
              SizedBox(height: w * 0.06),
              Container(
                width: w * 0.18,
                height: 1.5 * u,
                color: style.rule,
              ),
              SizedBox(height: w * 0.08),
              Text(
                'ROMAN',
                style: TextStyle(
                  fontFamily: AppTypography.uiFontFamily,
                  fontWeight: FontWeight.w500,
                  fontSize: w * 0.058,
                  color: style.ink.withValues(alpha: 0.55),
                  letterSpacing: 0.10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Noir (crime / drama) ───────────────────────────────────────
class _NoirLayout extends StatelessWidget {
  const _NoirLayout({
    required this.title,
    required this.author,
    required this.w,
    required this.style,
    required this.u,
  });
  final String title, author;
  final double w, u;
  final BookCoverStyle style;

  @override
  Widget build(BuildContext context) {
    final p = w * 0.12;
    return Padding(
      padding: EdgeInsets.all(p),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            author.toUpperCase(),
            style: TextStyle(
              fontFamily: AppTypography.uiFontFamily,
              fontWeight: FontWeight.w600,
              fontSize: w * 0.07,
              color: style.ink.withValues(alpha: 0.72),
              letterSpacing: 0.16,
            ),
          ),
          SizedBox(height: w * 0.06),
          Container(
            height: 1.4 * u,
            color: style.rule.withValues(alpha: 0.80),
          ),
          const Spacer(),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontFamily: AppTypography.uiFontFamily,
              fontWeight: FontWeight.w800,
              fontSize: w * 0.205,
              color: style.ink,
              height: 0.95,
              letterSpacing: -0.03,
            ),
            maxLines: 4,
          ),
        ],
      ),
    );
  }
}

// ── Band (pop / humour) ────────────────────────────────────────
class _BandLayout extends StatelessWidget {
  const _BandLayout({
    required this.title,
    required this.author,
    required this.w,
    required this.style,
    required this.u,
  });
  final String title, author;
  final double w, u;
  final BookCoverStyle style;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          top: w * 0.12,
          left: w * 0.12,
          child: Text(
            author,
            style: TextStyle(
              fontFamily: AppTypography.uiFontFamily,
              fontWeight: FontWeight.w600,
              fontSize: w * 0.07,
              color: style.ink.withValues(alpha: 0.70),
              letterSpacing: 0.06,
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: w * 1.5 * 0.42,
          child: Transform.rotate(
            angle: -0.052,
            child: Container(
              color: style.ink,
              padding: EdgeInsets.symmetric(
                vertical: w * 0.10,
                horizontal: w * 0.12,
              ),
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: AppTypography.uiFontFamily,
                  fontWeight: FontWeight.w800,
                  fontSize: w * 0.165,
                  color: style.bg,
                  height: 0.98,
                  letterSpacing: -0.02,
                ),
                maxLines: 3,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Stack (default modern) ────────────────────────────────────
class _StackLayout extends StatelessWidget {
  const _StackLayout({
    required this.title,
    required this.author,
    required this.w,
    required this.style,
    required this.u,
  });
  final String title, author;
  final double w, u;
  final BookCoverStyle style;

  @override
  Widget build(BuildContext context) {
    final p = w * 0.12;
    return Padding(
      padding: EdgeInsets.all(p),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: w * 0.46,
            height: 2.2 * u,
            decoration: BoxDecoration(
              color: style.rule,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: AppTypography.uiFontFamily,
                fontWeight: FontWeight.w700,
                fontSize: w * 0.16,
                color: style.ink,
                height: 1.06,
                letterSpacing: -0.02,
              ),
              maxLines: 6,
              overflow: TextOverflow.fade,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 1.5 * u,
                color: style.rule.withValues(alpha: 0.60),
              ),
              SizedBox(height: w * 0.04),
              Text(
                author,
                style: TextStyle(
                  fontFamily: AppTypography.uiFontFamily,
                  fontWeight: FontWeight.w500,
                  fontSize: w * 0.085,
                  color: style.ink.withValues(alpha: 0.86),
                  letterSpacing: 0.01,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
