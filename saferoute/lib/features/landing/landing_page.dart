import 'package:flutter/material.dart';
import 'widgets/hero_section.dart';
import 'widgets/live_map_section.dart';
import 'widgets/features_section.dart';
import 'widgets/problem_solution_section.dart';
import 'widgets/how_it_works_section.dart';
import 'widgets/footer_section.dart';
import 'widgets/landing_navbar.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: const [
                SizedBox(height: 64), // space for navbar
                HeroSection(),
                LiveMapSection(),
                ProblemSolutionSection(),
                FeaturesSection(),
                HowItWorksSection(),
                FooterSection(),
              ],
            ),
          ),
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LandingNavbar(),
          ),
        ],
      ),
    );
  }
}
