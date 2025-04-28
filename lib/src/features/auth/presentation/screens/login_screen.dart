import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:go_router/go_router.dart'; // Import go_router
import 'package:uywapets_flutter/src/features/auth/domain/repositories/auth_repository.dart'; // Import Interface and Provider

// Change to ConsumerStatefulWidget
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState(); // Change to ConsumerState
}

// Change to ConsumerState
class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true; // State for password visibility
  bool _rememberPassword = false; // State for checkbox

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return; // Don't proceed if form is invalid
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Use ref.read to get the repository instance from Riverpod provider
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.loginWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

       // Navigate to modules screen on success
       if (mounted) { // Check if the widget is still in the tree
         context.go('/modules'); // Corrected route path
       }

    } catch (e) {
      print('Login failed: $e');
      setState(() {
        // Display a user-friendly error message
        _errorMessage = 'Error al iniciar sesión. Verifique sus credenciales.';
        // Consider parsing specific errors from 'e' if needed
      });
    } finally {
       if (mounted) { // Check again before updating state
         setState(() {
           _isLoading = false;
         });
       }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    // Define height for the bottom image
    final double bottomImageHeight = screenHeight * 0.2; // Example: 20% of screen height
    final bool showBottomImage = screenHeight > 667; // Condition to show/hide image

    // Define input decoration theme for the text fields
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: Colors.grey.shade200,
      hintStyle: TextStyle(color: Colors.grey.shade500),
      contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25.0),
        borderSide: BorderSide.none, // No border line
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25.0),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25.0),
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5), // Highlight border on focus
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25.0),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25.0),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 1.5),
      ),
    );

    return Scaffold(
      // Transparent AppBar with only back button
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).primaryColor), // Use standard back arrow
          onPressed: () {
            context.go('/prelogin');
          },
        ),
        automaticallyImplyLeading: false,
      ),
      // Use Stack to layer the background image behind the content
      body: Stack(
        children: [
          // Conditionally display the Bottom Background Image (FIRST child, drawn at the bottom)
          if (showBottomImage)
            Align(
              alignment: Alignment.bottomCenter,
              child: Image.asset(
                'assets/images/paisaje1.png', // Path to the image
                width: double.infinity, // Stretch to fit width
                height: bottomImageHeight, // Set the defined height
                fit: BoxFit.cover, // Use cover to fill the height potentially cropping width
              ),
            ),
          // Main content area wrapped in SafeArea and SingleChildScrollView (drawn ON TOP of the image)
          SafeArea(
            child: SingleChildScrollView(
              // No bottom padding needed here now, content scrolls over the image
              child: Padding( // Inner padding for content alignment
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Form(
                  key: _formKey,
                  child: Column( // Content Column
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: screenHeight * 0.05), // Space from AppBar

                      // Logo
                      Image.asset(
                        'assets/images/logo.png', // Ensure this path is correct
                        height: 100, // Adjust size as needed
                      ),
                      SizedBox(height: screenHeight * 0.08), // Space after logo

                      // Username Field
                      TextFormField(
                        controller: _emailController,
                        decoration: inputDecoration.copyWith(hintText: 'Usuario'),
                        keyboardType: TextInputType.text, // Keep as text, backend might use username or email
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese su usuario'; // Corrected message
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        decoration: inputDecoration.copyWith(
                          hintText: 'Contraseña',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: Colors.grey.shade500,
                            ),
                            onPressed: () {
                              setState(() { _obscurePassword = !_obscurePassword; });
                            },
                          ),
                        ),
                        obscureText: _obscurePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese su contraseña';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),

                      // Remember / Forgot Password Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox( // Constrain checkbox size/tap area
                                height: 24.0,
                                width: 24.0,
                                child: Checkbox(
                                  value: _rememberPassword,
                                  onChanged: (bool? value) { setState(() { _rememberPassword = value ?? false; }); },
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // Reduce tap area
                                  visualDensity: VisualDensity.compact, // Make it smaller
                                ),
                              ),
                              const SizedBox(width: 4), // Small space
                              Text(
                                'Recordar contraseña',
                                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              // TODO: Implement Forgot Password navigation/logic
                              print('Forgot Password Tapped');
                            },
                            style: TextButton.styleFrom(padding: EdgeInsets.zero), // Remove default padding
                            child: Text(
                              'Olvidé mi contraseña',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.orange.shade700, // Orange color from image
                                // decoration: TextDecoration.underline, // Optional underline
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.05), // Space before button

                      if (_isLoading)
                        const Center(child: CircularProgressIndicator())
                      else
                        ElevatedButton( // Login Button
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlue, // Blue color from image
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
                            elevation: 2,
                          ),
                          child: const Text(
                            'Iniciar Sesión',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      if (_errorMessage != null)
                        Padding( // Error Message
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error), textAlign: TextAlign.center),
                        ),
                       // Conditionally add SizedBox at the end of the Column only if the image is shown
                       if (showBottomImage) SizedBox(height: bottomImageHeight),
                    ],
                  ), // End Content Column
                ), // End Form
              ), // End Inner Padding
            ), // End SingleChildScrollView
          ), // End SafeArea
        ], // End Stack Children
      ), // End Stack
    ); // End Scaffold
  } // End build method
} // End class
