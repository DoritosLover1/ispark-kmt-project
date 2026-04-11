import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),

                        /// TITLE
                        Text(
                          "İSPARK",
                          style: textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary
                          )
                        ),

                        const SizedBox(height: 12),

                        Text(
                          "Akıllı Otopark, Kolay Ulaşım",
                          textAlign: TextAlign.center,
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          "İstanbul’daki en yakın İSPARK noktalarını anında bul.",
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium,
                        ),

                        const SizedBox(height: 32),

                        /// FEATURES
                        _FeatureCard(
                          icon: Icons.location_on,
                          title: "En Yakın Otoparklar",
                          subtitle:
                              "Size en yakın İSPARK noktalarını anında gösterir.",
                          colorScheme: colorScheme,
                        ),

                        const SizedBox(height: 12),

                        _FeatureCard(
                          icon: Icons.data_usage,
                          title: "Canlı Doluluk Oranı",
                          subtitle:
                              "Otoparkların doluluk durumunu anlık takip edin.",
                          colorScheme: colorScheme,
                        ),

                        const Spacer(),

                        /// BUTTONS
                        _PrimaryButton(
                          text: "Giriş Yap",
                          onTap: () {},
                          colorScheme: colorScheme,
                        ),

                        const SizedBox(height: 12),

                        _SecondaryButton(
                          text: "Giriş Yapmadan Devam Et",
                          onTap: () {},
                        ),

                        const SizedBox(height: 20),

                        /// FOOTER (EN AŞAĞI İTTİK)
                        Text(
                          "Devam ederek Kullanım Koşullarını kabul etmiş olursunuz",
                          textAlign: TextAlign.center,
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),

                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final ColorScheme colorScheme;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.onSurface.withOpacity(0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _PrimaryButton({
    required this.text,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SizedBox(
      width: size.width * 0.90, // %90 ekran genişliği
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            vertical: size.height * 0.02, // ekran yüksekliğine göre
          ),
          backgroundColor: colorScheme.primary,
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
                fontSize: size.width * 0.04,
              ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _SecondaryButton({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SizedBox(
      width: size.width * 0.90,
      child: TextButton(
        onPressed: onTap,
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: size.width * 0.038,
              ),
        ),
      ),
    );
  }
}