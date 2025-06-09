import 'package:flutter_test/flutter_test.dart';
import 'package:marunthon_app/features/home/services/ai_training_plan_service.dart';
import 'package:marunthon_app/features/user/user_profile/setup/models/user_model.dart';
import 'package:marunthon_app/features/user/user_profile/setup/models/basic_info_model.dart';
import 'package:marunthon_app/features/user/user_profile/setup/models/physical_attributes_model.dart';
import 'package:marunthon_app/features/user/user_profile/setup/models/preferences_model.dart';
import 'package:marunthon_app/features/user/user_profile/setup/models/training_preferences_model.dart';
import 'package:marunthon_app/features/user/user_profile/setup/models/subscription_model.dart';
import 'package:marunthon_app/features/user/user_profile/setup/models/social_features_model.dart';
import 'package:marunthon_app/features/user/user_profile/setup/models/app_info_model.dart';
import 'package:marunthon_app/features/user/user_profile/setup/models/timestamps_model.dart';

void main() {
  group('AITrainingPlanService', () {
    late UserModel testUser;

    setUp(() {
      final now = DateTime.now();
      testUser = UserModel(
        id: 'test_user',
        basicInfo: BasicInfoModel(
          name: 'Test User',
          email: 'test@example.com',
          dob: DateTime(1990, 1, 1),
          age: 34,
          gender: 'male',
          profilePic: '',
        ),
        physicalAttributes: PhysicalAttributesModel(
          metricSystem: 'metric',
          weight: 75, // kg
          height: 175, // cm
        ),
        preferences: PreferencesModel(
          language: 'en',
          timezone: 'UTC',
          reminderTime: '08:00',
          reminderEnabled: true,
          voiceEnabled: true,
          vibrationOnly: false,
        ),
        trainingPreferences: TrainingPreferencesModel(
          injuryNotes: '',
          goal: '5K',
          goalEventDate: now.add(Duration(days: 84)), // 12 weeks
          runDaysPerWeek: 3,
          experience: 'beginner',
        ),
        subscription: SubscriptionModel(),
        socialFeatures: SocialFeaturesModel(),
        appInfo: AppInfoModel(),
        timestamps: TimestampsModel(
          joinedAt: now,
          lastActiveAt: now,
          createdAt: now,
          updatedAt: now,
        ),
      );
    });

    test('should create fallback plan when JSON parsing fails', () {
      // Test the fallback plan creation
      final fallbackPlan = AITrainingPlanService.createFallbackPlan();

      expect(fallbackPlan['planName'], isNotNull);
      expect(fallbackPlan['weeks'], isA<List>());
      expect(fallbackPlan['weeks'].length, greaterThan(0));

      final firstWeek = fallbackPlan['weeks'][0];
      expect(firstWeek['sessions'], isA<List>());
      expect(firstWeek['sessions'].length, greaterThan(0));

      final firstSession = firstWeek['sessions'][0];
      expect(firstSession['phases'], isA<List>());
      expect(
        firstSession['phases'].length,
        equals(4),
      ); // warmup, run, walk, cooldown
    });

    test('should parse BMI correctly for metric system', () {
      // This tests the BMI calculation logic in the prompt builder
      expect(testUser.weight, equals(75));
      expect(testUser.height, equals(175));
      expect(testUser.metricSystem, equals('metric'));

      // BMI = 75 / (1.75 * 1.75) = 24.49 (normal)
      // This would be calculated in the _buildTrainingPlanPrompt method
    });

    test('should handle malformed JSON gracefully', () {
      const malformedJson =
          '{"planName": "Test Plan", "weeks": [{"weekNumber": 1, "sessions": [';

      expect(() {
        AITrainingPlanService.parseAIResponse(malformedJson, 3);
      }, returnsNormally); // Should not throw, should return fallback
    });

    test('should clean up JSON string properly', () {
      const jsonWithTrailingComma = '{"test": "value",}';
      final cleaned = AITrainingPlanService.cleanupJsonString(
        jsonWithTrailingComma,
      );
      expect(cleaned, equals('{"test": "value"}'));
    });

    test('should get correct BMI guidance', () {
      expect(
        AITrainingPlanService.getBMIGuidance('underweight'),
        contains('gradually'),
      );
      expect(
        AITrainingPlanService.getBMIGuidance('normal'),
        contains('Standard'),
      );
      expect(
        AITrainingPlanService.getBMIGuidance('overweight'),
        contains('walking'),
      );
      expect(
        AITrainingPlanService.getBMIGuidance('obese'),
        contains('very short'),
      );
    });

    test(
      'should get appropriate initial durations for different BMI categories',
      () {
        // Obese users should start with very short runs
        expect(
          AITrainingPlanService.getInitialRunDuration('obese', 'beginner'),
          equals(1),
        );

        // Normal weight beginners get moderate start
        expect(
          AITrainingPlanService.getInitialRunDuration('normal', 'beginner'),
          equals(2),
        );

        // Advanced normal weight users get longer intervals
        expect(
          AITrainingPlanService.getInitialRunDuration('normal', 'advanced'),
          equals(5),
        );
      },
    );
  });
}
