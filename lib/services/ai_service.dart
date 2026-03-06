import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../core/errors/exceptions.dart';
import '../core/utils/logger.dart';
import '../domain/entities/experience.dart';
import '../domain/repositories/ai_repository.dart';

/// AI Service
/// 
/// Сервис для генерации контента с помощью AI
/// Использует агрегатор API: Hugging Face, Replicate, Stability AI
class AIService implements AIRepository {
  final http.Client _httpClient;
  
  // API Keys (should be stored securely, e.g., in environment variables)
  static const String _huggingFaceApiKey = 'YOUR_HF_API_KEY';
  static const String _replicateApiKey = 'YOUR_REPLICATE_API_KEY';
  static const String _stabilityApiKey = 'YOUR_STABILITY_API_KEY';
  
  // API Endpoints
  static const String _huggingFaceBaseUrl = 'https://api-inference.huggingface.co';
  static const String _replicateBaseUrl = 'https://api.replicate.com/v1';
  static const String _stabilityBaseUrl = 'https://api.stability.ai/v1';

  AIService({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  @override
  Future<Either<AppException, AIGenerationResult>> generateImage({
    required String prompt,
    String? negativePrompt,
    AIImageStyle? style,
    AIImageSize size = AIImageSize.square,
    int? seed,
  }) async {
    try {
      AppLogger.i('Generating image with prompt: $prompt');
      
      // Enhance prompt with style
      final enhancedPrompt = style != null
          ? '$prompt, ${style.promptModifier}'
          : prompt;
      
      // Try Replicate first (better quality, more models)
      final result = await _generateWithReplicate(
        prompt: enhancedPrompt,
        negativePrompt: negativePrompt,
        size: size,
        seed: seed,
      );
      
      return Right(result);
    } catch (e, stackTrace) {
      AppLogger.e('Image generation error', error: e, stackTrace: stackTrace);
      
      // Fallback to Hugging Face
      try {
        final result = await _generateWithHuggingFace(
          prompt: prompt,
          size: size,
        );
        return Right(result);
      } catch (fallbackError) {
        return Left(AIGenerationException(
          message: 'Failed to generate image: $e',
          details: fallbackError.toString(),
        ));
      }
    }
  }

  /// Generate image using Replicate API
  Future<AIGenerationResult> _generateWithReplicate({
    required String prompt,
    String? negativePrompt,
    required AIImageSize size,
    int? seed,
  }) async {
    // Using Stable Diffusion XL via Replicate
    const modelVersion = 'stability-ai/stable-diffusion-xl-base-1.0';
    
    final response = await _httpClient.post(
      Uri.parse('$_replicateBaseUrl/predictions'),
      headers: {
        'Authorization': 'Token $_replicateApiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'version': modelVersion,
        'input': {
          'prompt': prompt,
          'negative_prompt': negativePrompt ?? '',
          'width': size.resolution.split('x')[0],
          'height': size.resolution.split('x')[1],
          'seed': seed,
          'num_outputs': 1,
        },
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Replicate API error: ${response.body}');
    }

    final data = jsonDecode(response.body);
    final predictionId = data['id'] as String;
    
    // Poll for result
    String? imageUrl;
    int attempts = 0;
    const maxAttempts = 60; // 2 minutes max (2 seconds * 60)
    
    while (imageUrl == null && attempts < maxAttempts) {
      await Future.delayed(const Duration(seconds: 2));
      
      final statusResponse = await _httpClient.get(
        Uri.parse('$_replicateBaseUrl/predictions/$predictionId'),
        headers: {
          'Authorization': 'Token $_replicateApiKey',
        },
      );
      
      if (statusResponse.statusCode != 200) {
        throw Exception('Failed to check prediction status');
      }
      
      final statusData = jsonDecode(statusResponse.body);
      final status = statusData['status'] as String;
      
      if (status == 'succeeded') {
        final output = statusData['output'];
        if (output is List && output.isNotEmpty) {
          imageUrl = output[0] as String;
        }
      } else if (status == 'failed') {
        throw Exception('Prediction failed: ${statusData['error']}');
      }
      
      attempts++;
    }

    if (imageUrl == null) {
      throw Exception('Image generation timed out');
    }

    // Download and cache image
    final localPath = await _downloadAndCacheImage(imageUrl);

    return AIGenerationResult(
      id: predictionId,
      contentUrl: localPath,
      type: ExperienceType.art,
      prompt: prompt,
      enhancedPrompt: prompt,
      createdAt: DateTime.now(),
      generationTimeMs: attempts * 2000,
    );
  }

  /// Generate image using Hugging Face API (free tier)
  Future<AIGenerationResult> _generateWithHuggingFace({
    required String prompt,
    required AIImageSize size,
  }) async {
    // Using Stable Diffusion model on Hugging Face
    const model = 'stabilityai/stable-diffusion-2-1';
    
    final response = await _httpClient.post(
      Uri.parse('$_huggingFaceBaseUrl/models/$model'),
      headers: {
        'Authorization': 'Bearer $_huggingFaceApiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'inputs': prompt,
        'parameters': {
          'width': int.parse(size.resolution.split('x')[0]),
          'height': int.parse(size.resolution.split('x')[1]),
        },
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Hugging Face API error: ${response.body}');
    }

    // Save image bytes to file
    final bytes = response.bodyBytes;
    final fileName = 'hf_${DateTime.now().millisecondsSinceEpoch}.png';
    final localPath = await _saveBytesToFile(bytes, fileName);

    return AIGenerationResult(
      id: 'hf_${DateTime.now().millisecondsSinceEpoch}',
      contentUrl: localPath,
      type: ExperienceType.art,
      prompt: prompt,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<Either<AppException, AIGenerationResult>> generateText({
    required String prompt,
    required TextContentType contentType,
    int? maxLength,
    String? tone,
    String? language,
  }) async {
    try {
      AppLogger.i('Generating text: $prompt');
      
      // Build enhanced prompt
      final enhancedPrompt = _buildTextPrompt(
        prompt: prompt,
        contentType: contentType,
        tone: tone,
        language: language,
      );

      // Use Hugging Face for text generation
      const model = 'gpt2'; // Can be replaced with better models
      
      final response = await _httpClient.post(
        Uri.parse('$_huggingFaceBaseUrl/models/$model'),
        headers: {
          'Authorization': 'Bearer $_huggingFaceApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'inputs': enhancedPrompt,
          'parameters': {
            'max_length': maxLength ?? 500,
            'temperature': 0.8,
            'top_p': 0.9,
          },
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Text generation API error: ${response.body}');
      }

      final data = jsonDecode(response.body);
      final generatedText = data[0]['generated_text'] as String;

      // Save to file
      final fileName = 'text_${DateTime.now().millisecondsSinceEpoch}.txt';
      final localPath = await _saveTextToFile(generatedText, fileName);

      return Right(AIGenerationResult(
        id: 'text_${DateTime.now().millisecondsSinceEpoch}',
        contentUrl: localPath,
        type: ExperienceType.text,
        prompt: prompt,
        enhancedPrompt: enhancedPrompt,
        createdAt: DateTime.now(),
      ));
    } catch (e, stackTrace) {
      AppLogger.e('Text generation error', error: e, stackTrace: stackTrace);
      return Left(AIGenerationException(message: 'Failed to generate text: $e'));
    }
  }

  @override
  Future<Either<AppException, AIGenerationResult>> generateAudio({
    required String prompt,
    required AudioType audioType,
    int? duration,
    String? genre,
    String? mood,
  }) async {
    // Audio generation requires specialized services
    // For MVP, we'll return a placeholder or use a music generation API
    
    try {
      AppLogger.i('Generating audio: $prompt');
      
      // Placeholder for audio generation
      // In production, integrate with Suno, Udio, or similar services
      
      // For now, return a mock result
      return Right(AIGenerationResult(
        id: 'audio_${DateTime.now().millisecondsSinceEpoch}',
        contentUrl: 'placeholder_audio_url',
        type: ExperienceType.audio,
        prompt: prompt,
        createdAt: DateTime.now(),
        metadata: {
          'duration': duration ?? 30,
          'genre': genre,
          'mood': mood,
        },
      ));
    } catch (e, stackTrace) {
      AppLogger.e('Audio generation error', error: e, stackTrace: stackTrace);
      return Left(AIGenerationException(message: 'Failed to generate audio: $e'));
    }
  }

  @override
  Future<Either<AppException, AIGenerationResult>> generateGameConcept({
    required String prompt,
    GameType? gameType,
    String? difficulty,
  }) async {
    try {
      AppLogger.i('Generating game concept: $prompt');
      
      // Generate game concept as JSON
      final concept = {
        'title': 'Generated Game: $prompt',
        'type': gameType?.name ?? 'puzzle',
        'difficulty': difficulty ?? 'medium',
        'description': 'A $difficulty ${gameType?.name ?? 'puzzle'} game about $prompt',
        'rules': [
          'Match similar items',
          'Complete within time limit',
          'Earn points for combos',
        ],
        'assets': {
          'background': 'generated_background',
          'items': ['item1', 'item2', 'item3'],
        },
      };

      // Save to file
      final fileName = 'game_${DateTime.now().millisecondsSinceEpoch}.json';
      final localPath = await _saveTextToFile(
        jsonEncode(concept),
        fileName,
      );

      return Right(AIGenerationResult(
        id: 'game_${DateTime.now().millisecondsSinceEpoch}',
        contentUrl: localPath,
        type: ExperienceType.miniGame,
        prompt: prompt,
        createdAt: DateTime.now(),
        metadata: concept,
      ));
    } catch (e, stackTrace) {
      AppLogger.e('Game generation error', error: e, stackTrace: stackTrace);
      return Left(AIGenerationException(message: 'Failed to generate game: $e'));
    }
  }

  @override
  Future<Either<AppException, String>> enhancePrompt({
    required String prompt,
    required ExperienceType type,
  }) async {
    try {
      // Add type-specific enhancements
      switch (type) {
        case ExperienceType.art:
          return Right('$prompt, high quality, detailed, professional');
        case ExperienceType.text:
          return Right('Write an engaging $prompt with vivid descriptions');
        case ExperienceType.audio:
          return Right('Create $prompt with clear melody and rhythm');
        case ExperienceType.miniGame:
          return Right('Design a fun and addictive $prompt game');
        default:
          return Right(prompt);
      }
    } catch (e) {
      return Left(AIGenerationException(message: 'Failed to enhance prompt: $e'));
    }
  }

  @override
  Future<Either<AppException, ContentSafetyResult>> checkContentSafety(
    String content, {
    ContentType contentType = ContentType.text,
  }) async {
    try {
      // Use Hugging Face moderation model
      const model = 'cardiffnlp/twitter-roberta-base-hate-latest';
      
      final response = await _httpClient.post(
        Uri.parse('$_huggingFaceBaseUrl/models/$model'),
        headers: {
          'Authorization': 'Bearer $_huggingFaceApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'inputs': content}),
      );

      if (response.statusCode != 200) {
        // If API fails, assume safe
        return const Right(ContentSafetyResult(
          isSafe: true,
          safetyScore: 1.0,
        ));
      }

      final data = jsonDecode(response.body);
      final scores = data[0] as List<dynamic>;
      
      // Check for hate speech or offensive content
      double maxRiskScore = 0.0;
      List<String> flagged = [];
      
      for (final score in scores) {
        final label = score['label'] as String;
        final value = score['score'] as double;
        
        if (label != 'neutral' && value > 0.5) {
          maxRiskScore = value;
          flagged.add(label);
        }
      }

      return Right(ContentSafetyResult(
        isSafe: maxRiskScore < 0.7,
        safetyScore: 1.0 - maxRiskScore,
        flaggedCategories: flagged.isNotEmpty ? flagged : null,
      ));
    } catch (e) {
      // If check fails, assume safe
      return const Right(ContentSafetyResult(
        isSafe: true,
        safetyScore: 1.0,
      ));
    }
  }

  @override
  Future<Either<AppException, GenerationCredits>> getGenerationCredits(String userId) async {
    // This should be fetched from Firestore or backend
    // Placeholder implementation
    return const Right(GenerationCredits(
      userId: 'user_id',
      dailyLimit: 3,
      usedToday: 0,
      remainingToday: 3,
      tier: SubscriptionTier.free,
    ));
  }

  @override
  Future<Either<AppException, GenerationCredits>> useGenerationCredit(String userId) async {
    // This should update Firestore
    // Placeholder implementation
    return const Right(GenerationCredits(
      userId: 'user_id',
      dailyLimit: 3,
      usedToday: 1,
      remainingToday: 2,
      tier: SubscriptionTier.free,
    ));
  }

  @override
  Future<Either<AppException, GenerationCredits>> purchaseCredits({
    required String userId,
    required int amount,
    required PaymentMethod paymentMethod,
  }) async {
    // This should process payment and update credits
    // Placeholder implementation
    return Right(GenerationCredits(
      userId: userId,
      dailyLimit: 3,
      usedToday: 0,
      remainingToday: 3,
      purchasedCredits: amount,
      tier: SubscriptionTier.free,
    ));
  }

  @override
  Future<Either<AppException, List<AIGenerationResult>>> getGenerationHistory(
    String userId, {
    int page = 1,
    int limit = 20,
  }) async {
    // This should fetch from Firestore
    // Placeholder implementation
    return const Right([]);
  }

  @override
  Future<Either<AppException, List<String>>> getSuggestedPrompts(ExperienceType type) async {
    return Right(type.suggestedPrompts);
  }

  @override
  Future<Either<AppException, void>> cancelGeneration(String generationId) async {
    // Cancel ongoing generation if possible
    return const Right(null);
  }

  @override
  Stream<GenerationProgress> generationProgressStream(String generationId) async* {
    // Stream generation progress
    yield GenerationProgress(
      generationId: generationId,
      status: GenerationStatus.generating,
      progress: 0.0,
    );
    
    // Simulate progress
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      yield GenerationProgress(
        generationId: generationId,
        status: GenerationStatus.generating,
        progress: i / 10,
        message: 'Generating... ${(i * 10)}%',
      );
    }
    
    yield GenerationProgress(
      generationId: generationId,
      status: GenerationStatus.completed,
      progress: 1.0,
      message: 'Generation complete!',
    );
  }

  // ==================== PRIVATE METHODS ====================

  String _buildTextPrompt({
    required String prompt,
    required TextContentType contentType,
    String? tone,
    String? language,
  }) {
    final buffer = StringBuffer();
    
    buffer.write('Write a ${contentType.displayName.toLowerCase()} ');
    if (tone != null) buffer.write('in a $tone tone ');
    if (language != null) buffer.write('in $language ');
    buffer.write('about: $prompt');
    
    return buffer.toString();
  }

  Future<String> _downloadAndCacheImage(String url) async {
    final response = await _httpClient.get(Uri.parse(url));
    
    if (response.statusCode != 200) {
      throw Exception('Failed to download image');
    }
    
    final fileName = 'ai_${DateTime.now().millisecondsSinceEpoch}.png';
    return _saveBytesToFile(response.bodyBytes, fileName);
  }

  Future<String> _saveBytesToFile(List<int> bytes, String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(path.join(dir.path, 'ai_generations', fileName));
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes);
    return file.path;
  }

  Future<String> _saveTextToFile(String text, String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(path.join(dir.path, 'ai_generations', fileName));
    await file.parent.create(recursive: true);
    await file.writeAsString(text);
    return file.path;
  }
}

// Type alias for Either
typedef Either<L, R> = ({L? left, R? right});

extension EitherExtension<L, R> on Either<L, R> {
  B fold<B>(B Function(L) left, B Function(R) right) {
    if (this.left != null) return left(this.left as L);
    return right(this.right as R);
  }
}

// Helper functions
Either<L, R> Left<L, R>(L value) => (left: value, right: null);
Either<L, R> Right<L, R>(R value) => (left: null, right: value);
