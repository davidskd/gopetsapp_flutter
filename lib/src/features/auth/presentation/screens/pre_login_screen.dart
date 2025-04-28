import 'dart:convert';
import 'dart:io'; // For Platform.isIOS

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:go_router/go_router.dart'; // Import go_router
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
// Remove hide directives as we need both providers now
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http; // For Facebook Graph API call

import 'package:uywapets_flutter/src/features/auth/data/services/auth_service.dart'; // Import AuthService provider
import 'package:uywapets_flutter/src/features/auth/domain/models/apple_token_dto.dart';
import 'package:uywapets_flutter/src/features/auth/domain/models/facebook_token_dto.dart';
// TODO: Import UtilService or implement loading/alert logic directly

// Change to ConsumerStatefulWidget
class PreLoginScreen extends ConsumerStatefulWidget {
  const PreLoginScreen({super.key});

  @override
  ConsumerState<PreLoginScreen> createState() => _PreLoginScreenState();
}

class _PreLoginScreenState extends ConsumerState<PreLoginScreen> {
  bool _isLoadingGoogle = false;
  bool _isLoadingFacebook = false;
  bool _isLoadingApple = false;
  bool _isAppleSignInAvailable = false; // State variable for Apple Sign In availability

  @override
  void initState() {
    super.initState();
    _checkAppleSignInAvailability(); // Check availability on init
  }

  Future<void> _checkAppleSignInAvailability() async {
    final isAvailable = await SignInWithApple.isAvailable();
    if (mounted) { // Check if the widget is still mounted before calling setState
      setState(() {
        _isAppleSignInAvailable = isAvailable;
      });
    }
  }

  // Helper function for button styles (keep as before)
  ButtonStyle _socialButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      foregroundColor: Colors.black87, backgroundColor: Colors.grey.shade200,
      minimumSize: const Size(double.infinity, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
      elevation: 2,
    );
  }

  ButtonStyle _registerButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      foregroundColor: Colors.white, backgroundColor: Colors.lightBlue,
      minimumSize: const Size(double.infinity, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
      elevation: 2,
    );
  }

  // --- Generic Social Sign In Logic ---
  Future<void> _handleSocialSignIn(
      String providerName, Future<String?> Function() getPayload) async {
    // Set loading state based on provider
    setState(() {
      if (providerName == 'GOOGLE') _isLoadingGoogle = true;
      if (providerName == 'FACEBOOK') _isLoadingFacebook = true;
      if (providerName == 'APPLE') _isLoadingApple = true;
    });

    try {
      final payload = await getPayload();
      if (payload == null) {
        throw Exception('Failed to get credentials from provider.');
      }

      final authService = ref.read(authServiceProvider);
      await authService.authenticateSocial(payload, providerName);

      if (mounted) {
        context.go('/modules');
      }
    } catch (e) {
      print('Error during $providerName Sign In: $e');
      if (mounted) {
        // TODO: Show user-friendly error using UtilService or ScaffoldMessenger
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al iniciar sesión con $providerName: ${e.toString()}')),
        );
      }
    } finally {
      // Reset loading state
      if (mounted) {
        setState(() {
          if (providerName == 'GOOGLE') _isLoadingGoogle = false;
          if (providerName == 'FACEBOOK') _isLoadingFacebook = false;
          if (providerName == 'APPLE') _isLoadingApple = false;
        });
      }
    }
  }

  // --- Google Sign In ---
  Future<String?> _getGooglePayload() async {
    try {
      // Inicializar GoogleSignIn con los parámetros necesarios para Android
      final GoogleSignIn googleSignIn = GoogleSignIn(
        // Añadir los scopes necesarios
        scopes: [
          'email',          
          'https://www.googleapis.com/auth/userinfo.profile',
        ],
        // El servidor clientId no es necesario para Android, pero sí para web
        // serverClientId: 'TU_WEB_CLIENT_ID.apps.googleusercontent.com', // Solo necesario para web
      );
      
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        print("Google Sign In cancelled by user.");
        return null; // User cancelled
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
     /*  print("Google Auth tokens - idToken: ${googleAuth.idToken != null ? 'Present' : 'Missing'}, " +
            "accessToken: ${googleAuth.accessToken != null ? 'Present' : 'Missing'}");
       */
      if (googleAuth.idToken == null) {
         print("Google Sign In failed: ID token missing.");
         
         // Si no tenemos ID token pero sí tenemos access token, podemos intentar continuar de todas formas
         if (googleAuth.accessToken != null) {
           // Crear un credential solo con access token
           final credential = GoogleAuthProvider.credential(
             accessToken: googleAuth.accessToken,
             // No incluimos idToken porque es nulo
           );
           
           // Sign in to Firebase with the Google credential
           final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
           
           // Get the Firebase ID token
           final String? firebaseIdToken = await userCredential.user?.getIdToken();
           //print("Firebase ID Token (Google1): $firebaseIdToken"); // Para depuración
           return firebaseIdToken;
         }
         
         return null; // No se pudo obtener ningún token válido
      }

      // Create a Google credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      // Get the Firebase ID token
      final String? firebaseIdToken = await userCredential.user?.getIdToken();
      print("Firebase ID Token (Google2): $firebaseIdToken"); // Para depuración
      return firebaseIdToken;

    } catch (e) {
      print("Error durante la autenticación con Google Firebase: $e");
      return null;
    }
  }

  // --- Facebook Sign In ---
  Future<String?> _getFacebookPayload() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'], // Basic permissions
      );

      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;

        // Create a Facebook credential
        final credential = FacebookAuthProvider.credential(accessToken.tokenString);

        // Sign in to Firebase with the Facebook credential
        final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

        // Get the Firebase ID token
        final String? firebaseIdToken = await userCredential.user?.getIdToken();
        print("Firebase ID Token (Facebook): $firebaseIdToken"); // For debugging
        return firebaseIdToken;

      } else {
        print('Facebook Login Failed: ${result.status} - ${result.message}');
        return null;
      }
    } catch (e) {
      print("Error during Facebook Firebase sign in: $e");
      return null;
    }
  }

  // --- Apple Sign In ---
  // NOTE: Apple Sign In with Firebase might require slightly different handling
  // depending on whether you pass the Apple ID token directly to Firebase Auth
  // or if your backend expects the DTO containing the identityToken.
  // Keeping the DTO approach for now based on previous implementation.
  Future<String?> _getApplePayload() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName, // Request name if needed by backend/DTO
      ],
    );

    // Create DTO
    final dto = AppleTokenDto(
      identityToken: credential.identityToken, // This is the crucial token for backend validation
      email: credential.email, // Email might be null on subsequent logins
      // Note: Apple also provides userIdentifier, givenName, familyName if needed
    );
    return dto.toJsonEncodedBase64();
  }


  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final screenHeight = MediaQuery.of(context).size.height;
    final double bottomImageHeight = screenHeight * 0.2;
    final bool showBottomImage = screenHeight > 667;
    // Use the state variable instead of Platform.isIOS
    final bool isAppleSignInAvailable = _isAppleSignInAvailable;

    return Scaffold(
      body: Stack(
        children: [
          if (showBottomImage)
            Align(
              alignment: Alignment.bottomCenter,
              child: Image.asset(
                'assets/images/paisaje1.png',
                width: double.infinity, height: bottomImageHeight, fit: BoxFit.cover,
              ),
            ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: screenHeight * 0.1),
                    Image.asset('assets/images/logo.png', height: 100),
                    const SizedBox(height: 32.0),
                    Text('Te damos la bienvenida a la app de mascotas', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    const SizedBox(height: 8.0),
                    Text('Crea una cuenta y explora una experiencia virtual con tu peludo', style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade600), textAlign: TextAlign.center),
                    const SizedBox(height: 32.0),

                    // Google Button
                    ElevatedButton.icon(
                      icon: _isLoadingGoogle
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.g_mobiledata, color: Colors.red), // Placeholder
                      label: const Text('Continuar con Google'),
                      onPressed: _isLoadingGoogle || _isLoadingFacebook || _isLoadingApple ? null : () => _handleSocialSignIn('GOOGLE', _getGooglePayload),
                      style: _socialButtonStyle(context),
                    ),
                    const SizedBox(height: 16.0),

                    // Facebook Button
                    ElevatedButton.icon(
                      icon: _isLoadingFacebook
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.facebook, color: Colors.blue),
                      label: const Text('Continuar con Facebook'),
                      onPressed: _isLoadingGoogle || _isLoadingFacebook || _isLoadingApple ? null : () => _handleSocialSignIn('FACEBOOK', _getFacebookPayload),
                      style: _socialButtonStyle(context),
                    ),
                    const SizedBox(height: 16.0),

                    // Apple Button (Conditional based on availability check)
                    if (isAppleSignInAvailable) ...[
                      ElevatedButton.icon(
                        icon: _isLoadingApple
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.apple, color: Colors.black), // Placeholder
                        label: const Text('Continuar con Apple'),
                        onPressed: _isLoadingGoogle || _isLoadingFacebook || _isLoadingApple ? null : () => _handleSocialSignIn('APPLE', _getApplePayload),
                        style: _socialButtonStyle(context),
                      ),
                      const SizedBox(height: 24.0),
                    ] else ... [
                       // Add spacing even if Apple button is hidden to maintain layout consistency
                       const SizedBox(height: 24.0),
                    ],


                    // Register Button
                    ElevatedButton(
                      onPressed: _isLoadingGoogle || _isLoadingFacebook || _isLoadingApple ? null : () => context.go('/register'),
                      style: _registerButtonStyle(context),
                      child: const Text('Continuar con registro único'),
                    ),
                    const SizedBox(height: 24.0),

                    // Login Link
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
                        children: <TextSpan>[
                          const TextSpan(text: '¿Ya tienes Cuenta? '),
                          TextSpan(
                            text: 'Inicia sesión aquí',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.lightBlue, decoration: TextDecoration.underline),
                            recognizer: TapGestureRecognizer()..onTap = () => context.go('/login'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8.0),

                    // Terms Link
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                        children: <TextSpan>[
                          const TextSpan(text: 'Al continuar, aceptas los '),
                          TextSpan(
                            text: 'Términos y Condiciones',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.lightBlue, decoration: TextDecoration.underline),
                            recognizer: TapGestureRecognizer()..onTap = () => print('Navigate to Terms & Conditions'),
                          ),
                        ],
                      ),
                    ),
                    if (showBottomImage) SizedBox(height: bottomImageHeight),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
