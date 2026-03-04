import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/tutorial_keys.dart';
import '../providers/navigation_provider.dart';

class AppTutorial {
  static TutorialCoachMark createTutorial({
    required BuildContext context,
    required WidgetRef ref,
    required GlobalKey dailyBudgetKey,
    required GlobalKey totalBalanceKey,
    required GlobalKey triageKey,
    required GlobalKey zoltMessagesKey,
    required VoidCallback onFinish,
  }) {
    List<TargetFocus> targets = [
      // 1. Budget Quotidien
      TargetFocus(
        identify: "dailyBudget",
        keyTarget: dailyBudgetKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return const _TutorialContent(
                title: "Votre Budget Quotidien",
                description: "C'est l'argent que vous pouvez dépenser aujourd'hui SANS impacter vos charges fixes et vos objectifs. Il se recalcule automatiquement à chaque dépense ou rentrée.",
              );
            },
          ),
        ],
      ),

      // 2. Solde Total
      TargetFocus(
        identify: "totalBalance",
        keyTarget: totalBalanceKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        radius: 16,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return const _TutorialContent(
                title: "Solde Total",
                description: "Ceci représente tout l'argent disponible sur vos différents comptes et portemonnaies (Banque, Mobile Money, Espèces).",
              );
            },
          ),
        ],
      ),

      // 3. Messages Zolt
      TargetFocus(
        identify: "zoltMessages",
        keyTarget: zoltMessagesKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        radius: 16,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return const _TutorialContent(
                title: "L'Intelligence Zolt",
                description: "Notre moteur IA analyse vos finances. Il vous préviendra ici si une facture approche ou si vous dépensez trop vite !",
              );
            },
          ),
        ],
      ),

      // 4. Zone de Triage
      TargetFocus(
        identify: "triageZone",
        keyTarget: triageKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return const _TutorialContent(
                title: "Saisissez vite !",
                description: "Glissez ce logo au centre vers la gauche pour noter une Dépense, ou vers la droite pour une Rentrée d'argent en seulement 2 secondes.",
              );
            },
          ),
        ],
      ),

      // 5. Paramètres / Revenus Fixes
      TargetFocus(
        identify: "settingsTab",
        keyTarget: TutorialKeys.settingsTabKey,
        alignSkip: Alignment.topLeft,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return const _TutorialContent(
                title: "Gérez vos revenus fixes",
                description: "Allez dans les Paramètres pour ajouter vos 'Rentrées régulières' (ex: argent de poche, paiements journaliers) et automatiser votre budget !",
              );
            },
          ),
        ],
      ),
    ];

    return TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      textSkip: "PASSER",
      paddingFocus: 10,
      opacityShadow: 0.9,
      onFinish: onFinish,
      onClickTarget: (target) {
        if (target.identify == "settingsTab") {
          ref.read(navigationIndexProvider.notifier).state = 3; // Index Settings
        }
      },
      onClickTargetWithTapPosition: (target, tapDetails) {},
      onClickOverlay: (target) {},
      onSkip: () {
        onFinish();
        return true;
      },
      textStyleSkip: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _TutorialContent extends StatelessWidget {
  final String title;
  final String description;

  const _TutorialContent({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 24.0,
          ),
        ),
        SizedBox(height: 12),
        Text(
          description,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16.0,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
